// Thumbnail crop preview screen matching player appearance
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img_lib;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:music_like/l10n/app_localizations.dart';

class ThumbnailCropResult {
  final String croppedImagePath;

  const ThumbnailCropResult({required this.croppedImagePath});
}

// Compute displayed image size for BoxFit
Size _computeDisplaySize(double imgW, double imgH, double boxW, double boxH, BoxFit fit) {
  if (imgW <= 0 || imgH <= 0) return Size(boxW, boxH);
  if (fit == BoxFit.cover) {
    final scale = math.max(boxW / imgW, boxH / imgH);
    return Size(imgW * scale, imgH * scale);
  }
  // contain
  final scale = math.min(boxW / imgW, boxH / imgH);
  return Size(imgW * scale, imgH * scale);
}

class ThumbnailCropScreen extends StatefulWidget {
  final String imagePath;
  final Color themeBackgroundColor;
  final Color themeTextColor;

  const ThumbnailCropScreen({
    required this.imagePath,
    required this.themeBackgroundColor,
    required this.themeTextColor,
    Key? key,
  }) : super(key: key);

  @override
  State<ThumbnailCropScreen> createState() => _ThumbnailCropScreenState();
}

class _ThumbnailCropScreenState extends State<ThumbnailCropScreen> {
  final TransformationController _controller = TransformationController();
  Size? _viewportSize;
  bool _initialized = false;
  ui.Image? _imageInfo;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadImageInfo();
  }

  Future<void> _loadImageInfo() async {
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _imageInfo = frame.image;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[THUMB CROP] image load failed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _initializeIfNeeded(Size size) {
    if (_initialized) return;
    _viewportSize = size;
    _controller.value = Matrix4.identity()..scale(1.0);
    _initialized = true;
  }

  void _syncSlidersFromController(Size size, Size rendered) {
    // Touch interactions sync is no longer needed since sliders are removed
    // This method is kept for compatibility with InteractiveViewer callback
  }

  Future<void> _applyAndCrop() async {
    final size = _viewportSize;
    final img = _imageInfo;
    if (size == null || img == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final matrix = _controller.value;
      final scale = matrix.getMaxScaleOnAxis();
      final translation = matrix.getTranslation();

      // Use original image dimensions
      final imgW = img.width.toDouble();
      final imgH = img.height.toDouble();

      // Calculate thumbnail preview area (same as in build)
      final previewSize = math.min(size.width * 0.8, size.height * 0.6);
      final previewRect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: previewSize,
        height: previewSize,
      );

      // Calculate image display bounds with BoxFit.contain
      final imgAspect = imgW / imgH;
      final screenAspect = size.width / size.height;
      
      double displayWidth, displayHeight;
      if (imgAspect > screenAspect) {
        // Image is wider - fit to width
        displayWidth = size.width;
        displayHeight = size.width / imgAspect;
      } else {
        // Image is taller - fit to height
        displayHeight = size.height;
        displayWidth = size.height * imgAspect;
      }
      
      final displayLeft = (size.width - displayWidth) / 2;
      final displayTop = (size.height - displayHeight) / 2;
      
      // Apply transform to display bounds
      final transformedLeft = displayLeft * scale + translation.x;
      final transformedTop = displayTop * scale + translation.y;
      final transformedWidth = displayWidth * scale;
      final transformedHeight = displayHeight * scale;
      
      // Convert preview rect to image coordinates
      final cropLeft = ((previewRect.left - transformedLeft) / transformedWidth * imgW).clamp(0.0, imgW);
      final cropTop = ((previewRect.top - transformedTop) / transformedHeight * imgH).clamp(0.0, imgH);
      final cropWidth = (previewRect.width / transformedWidth * imgW).clamp(1.0, imgW - cropLeft);
      final cropHeight = (previewRect.height / transformedHeight * imgH).clamp(1.0, imgH - cropTop);

      // Crop rect in original image pixel coordinates
      final cropRect = Rect.fromLTWH(cropLeft, cropTop, cropWidth, cropHeight);

      debugPrint('[THUMB CROP] viewport=${size.width}x${size.height} scale=$scale cropRect=$cropRect');

      // Load image with image package and crop
      final bytes = await File(widget.imagePath).readAsBytes();
      final image = img_lib.decodeImage(bytes);
      if (image == null) throw Exception('Failed to decode image');

      // Clamp crop rect to image bounds
      final x = cropRect.left.clamp(0.0, image.width.toDouble()).toInt();
      final y = cropRect.top.clamp(0.0, image.height.toDouble()).toInt();
      final maxW = math.max(1.0, (image.width - x).toDouble());
      final maxH = math.max(1.0, (image.height - y).toDouble());
      final w = cropRect.width.clamp(1.0, maxW).toInt();
      final h = cropRect.height.clamp(1.0, maxH).toInt();

      final cropped = img_lib.copyCrop(image, x: x, y: y, width: w, height: h);

      // Save cropped image to temp file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = path.extension(widget.imagePath);
      final outPath = path.join(tempDir.path, 'cropped_thumb_$timestamp$ext');
      final outFile = File(outPath);

      if (ext.toLowerCase() == '.png') {
        await outFile.writeAsBytes(img_lib.encodePng(cropped));
      } else {
        await outFile.writeAsBytes(img_lib.encodeJpg(cropped, quality: 95));
      }

      if (mounted) {
        Navigator.pop(context, ThumbnailCropResult(croppedImagePath: outPath));
      }
    } catch (e) {
      debugPrint('[THUMB CROP] crop failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.e(e.toString()) ?? 'Error')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: widget.themeBackgroundColor,
      appBar: AppBar(
        backgroundColor: widget.themeBackgroundColor.withAlpha((0.8 * 255).round()),
        title: Text(AppLocalizations.of(context)?.adjustThumbnail ?? 'サムネイル調整'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              style: TextButton.styleFrom(foregroundColor: widget.themeTextColor),
              onPressed: _applyAndCrop,
              child: Text(
                '適用',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: widget.themeTextColor))
          : Container(
              color: widget.themeBackgroundColor,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  _initializeIfNeeded(size);
                  final rendered = _imageInfo != null
                      ? Size(_imageInfo!.width.toDouble(), _imageInfo!.height.toDouble())
                      : Size(size.width, size.height);
                  
                  // Calculate thumbnail preview area (square, matching player)
                  final previewSize = math.min(size.width * 0.8, size.height * 0.6);
                  final previewRect = Rect.fromCenter(
                    center: Offset(size.width / 2, size.height / 2),
                    width: previewSize,
                    height: previewSize,
                  );
                  
                  return Stack(
                    children: [
                      // Background interactive viewer with full image
                      InteractiveViewer(
                        transformationController: _controller,
                        minScale: 0.5,
                        maxScale: 4.0,
                        boundaryMargin: const EdgeInsets.all(200),
                        onInteractionEnd: (_) => _syncSlidersFromController(size, rendered),
                        child: SizedBox(
                          width: size.width,
                          height: size.height,
                          child: Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                            errorBuilder: (ctx, error, stack) {
                              debugPrint('[THUMB CROP] image error: $error');
                              return Center(
                                child: Icon(Icons.broken_image, size: 48, color: widget.themeTextColor.withAlpha(100)),
                              );
                            },
                          ),
                        ),
                      ),
                      // Overlay: crop preview frame
                      IgnorePointer(
                        child: CustomPaint(
                          size: size,
                          painter: _CropFramePainter(
                            cropRect: previewRect,
                            frameColor: Colors.white.withOpacity(0.8),
                            overlayColor: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ),
                      // Help text
                      Positioned(
                        bottom: 24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ピンチ・ドラッグで調整',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}

// Custom painter for crop frame overlay
class _CropFramePainter extends CustomPainter {
  final Rect cropRect;
  final Color frameColor;
  final Color overlayColor;

  _CropFramePainter({
    required this.cropRect,
    required this.frameColor,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw darkened overlay outside crop area
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(overlayPath, Paint()..color = overlayColor);

    // Draw crop frame border
    final framePaint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(cropRect, framePaint);

    // Draw corner markers
    final cornerSize = 20.0;
    final cornerPaint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Top-left corner
    canvas.drawLine(Offset(cropRect.left, cropRect.top), Offset(cropRect.left + cornerSize, cropRect.top), cornerPaint);
    canvas.drawLine(Offset(cropRect.left, cropRect.top), Offset(cropRect.left, cropRect.top + cornerSize), cornerPaint);

    // Top-right corner
    canvas.drawLine(Offset(cropRect.right, cropRect.top), Offset(cropRect.right - cornerSize, cropRect.top), cornerPaint);
    canvas.drawLine(Offset(cropRect.right, cropRect.top), Offset(cropRect.right, cropRect.top + cornerSize), cornerPaint);

    // Bottom-left corner
    canvas.drawLine(Offset(cropRect.left, cropRect.bottom), Offset(cropRect.left + cornerSize, cropRect.bottom), cornerPaint);
    canvas.drawLine(Offset(cropRect.left, cropRect.bottom), Offset(cropRect.left, cropRect.bottom - cornerSize), cornerPaint);

    // Bottom-right corner
    canvas.drawLine(Offset(cropRect.right, cropRect.bottom), Offset(cropRect.right - cornerSize, cropRect.bottom), cornerPaint);
    canvas.drawLine(Offset(cropRect.right, cropRect.bottom), Offset(cropRect.right, cropRect.bottom - cornerSize), cornerPaint);
  }

  @override
  bool shouldRepaint(_CropFramePainter oldDelegate) {
    return cropRect != oldDelegate.cropRect ||
        frameColor != oldDelegate.frameColor ||
        overlayColor != oldDelegate.overlayColor;
  }
}
