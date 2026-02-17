// Background widgets extracted from main.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:music_like/l10n/app_localizations.dart';

// Helper: compute displayed image size for BoxFit
Size computeDisplaySize(double imgW, double imgH, double boxW, double boxH, BoxFit fit) {
  if (imgW <= 0 || imgH <= 0) return Size(boxW, boxH);
  if (fit == BoxFit.cover) {
    final scale = math.max(boxW / imgW, boxH / imgH);
    return Size(imgW * scale, imgH * scale);
  }
  if (fit == BoxFit.fitHeight) {
    final scale = boxH / imgH;
    return Size(imgW * scale, imgH * scale);
  }
  if (fit == BoxFit.fitWidth) {
    final scale = boxW / imgW;
    return Size(imgW * scale, imgH * scale);
  }
  // default to contain behavior
  final scale = math.min(boxW / imgW, boxH / imgH);
  return Size(imgW * scale, imgH * scale);
}

// BackgroundLayer widget
class BackgroundLayer extends StatefulWidget {
  final String imagePath;
  final Size containerSize;
  final double scale;
  final double offsetX;
  final double offsetY;
  final BoxFit fit;

  const BackgroundLayer({
    required this.imagePath,
    required this.containerSize,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
    this.fit = BoxFit.cover,
    Key? key,
  }) : super(key: key);

  @override
  State<BackgroundLayer> createState() => _BackgroundLayerState();
}

class _BackgroundLayerState extends State<BackgroundLayer> {
  ui.Image? _imageInfo;

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
      setState(() => _imageInfo = frame.image);
    } catch (_) {
      // ignore image load errors; fallback to container fill
    }
  }

  @override
  Widget build(BuildContext context) {
    final img = _imageInfo;
    final cSize = widget.containerSize;

    // Debug: log for diagnostics
    try {
      final exists = File(widget.imagePath).existsSync();
      debugPrint('[BG LAYER] path=${widget.imagePath} exists=$exists cSize=${cSize.width.toStringAsFixed(0)}x${cSize.height.toStringAsFixed(0)} scale=${widget.scale} offsetX=${widget.offsetX.toStringAsFixed(4)} offsetY=${widget.offsetY.toStringAsFixed(4)}');
    } catch (e) {
      debugPrint('[BG LAYER] path check error: $e');
    }

    // Offsets are normalized relative to viewport size
    final dx = widget.offsetX * cSize.width;
    final dy = widget.offsetY * cSize.height;

    return Transform(
      alignment: Alignment.topLeft,
      transform: Matrix4.identity()
        ..translate(dx, dy)
        ..scale(widget.scale),
      child: Container(
        width: cSize.width,
        height: cSize.height,
        color: Colors.black,
        child: Image.file(
          File(widget.imagePath),
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

class BackgroundTransformResult {
  final double scale;
  final double offsetX;
  final double offsetY;

  const BackgroundTransformResult({
    required this.scale,
    required this.offsetX,
    required this.offsetY,
  });
}

class BackgroundImageEditor extends StatefulWidget {
  final String imagePath;
  final double initialScale;
  final double initialOffsetX;
  final double initialOffsetY;
  final Color themeBackgroundColor;
  final Color themeTextColor;

  const BackgroundImageEditor({
    required this.imagePath,
    required this.initialScale,
    required this.initialOffsetX,
    required this.initialOffsetY,
    required this.themeBackgroundColor,
    required this.themeTextColor,
    Key? key,
  }) : super(key: key);

  @override
  State<BackgroundImageEditor> createState() => _BackgroundImageEditorState();
}

class _BackgroundImageEditorState extends State<BackgroundImageEditor> {
  final TransformationController _controller = TransformationController();
  Size? _viewportSize;
  bool _initialized = false;
  ui.Image? _imageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImageInfoIfNeeded();
  }

  Future<void> _loadImageInfoIfNeeded() async {
    if (_imageInfo != null) return;
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _imageInfo = frame.image;
          _isLoading = false;
          _initialized = false;
        });
      }
    } catch (e) {
      debugPrint('[BG EDITOR] image load failed: $e');
      if (mounted) {
        setState(() {
          _imageInfo = null;
          _isLoading = false;
        });
      }
    }
  }

  void _initializeIfNeeded(Size size) {
    if (_initialized) return;
    _viewportSize = size;
    // Initialize with scale and offset
    final dx = widget.initialOffsetX * size.width;
    final dy = widget.initialOffsetY * size.height;
    _controller.value = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(widget.initialScale);
    if (_imageInfo == null) {
      _controller.value = Matrix4.identity()..scale(widget.initialScale);
    }
    _initialized = true;
  }

  void _syncSlidersFromController(Size size, Size rendered) {
    // Touch interactions sync is no longer needed since sliders are removed
    // This method is kept for compatibility with InteractiveViewer callback
  }

  void _applyAndClose() {
    final size = _viewportSize;
    if (size == null) {
      Navigator.pop(context);
      return;
    }
    final matrix = _controller.value;
    final scale = matrix.getMaxScaleOnAxis();
    final topLeft = MatrixUtils.transformPoint(matrix, Offset.zero);
    final dx = topLeft.dx;
    final dy = topLeft.dy;
    // Normalize offsets relative to viewport size
    final offsetX = (dx / size.width).clamp(-1.0, 1.0);
    final offsetY = (dy / size.height).clamp(-1.0, 1.0);
    // Debug output: final transform values
    debugPrint('[BG EDITOR] apply scale=$scale dx=${dx.toStringAsFixed(2)} dy=${dy.toStringAsFixed(2)} offsetX=${offsetX.toStringAsFixed(4)} offsetY=${offsetY.toStringAsFixed(4)} viewport=${size.width.toStringAsFixed(0)}x${size.height.toStringAsFixed(0)}');
    Navigator.pop(
      context,
      BackgroundTransformResult(
        scale: scale,
        offsetX: offsetX,
        offsetY: offsetY,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha((0.6 * 255).round()),
        title: Text(AppLocalizations.of(context)!.adjustBackgroundImage),
        actions: [
          TextButton(
            onPressed: _applyAndClose,
            child: Text(
              AppLocalizations.of(context)!.commonApply,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.black,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  _initializeIfNeeded(size);
                  return InteractiveViewer(
                    transformationController: _controller,
                    minScale: 0.5,
                    maxScale: 4.0,
                    boundaryMargin: const EdgeInsets.all(200),
                    onInteractionEnd: (_) => _syncSlidersFromController(size, size),
                    child: Container(
                      width: size.width,
                      height: size.height,
                      color: Colors.black,
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                        errorBuilder: (ctx, error, stack) {
                          debugPrint('[BG EDITOR] image error: $error');
                          return Center(child: Icon(Icons.broken_image, size: 48, color: Colors.white24));
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
