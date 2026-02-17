part of '../app_ui.dart';

class _ArtworkImage extends StatefulWidget {
  final ImageProvider imageProvider;
  final bool forceContain;

  const _ArtworkImage({
    required this.imageProvider,
    this.forceContain = false,
  });

  @override
  State<_ArtworkImage> createState() => _ArtworkImageState();
}

class _ArtworkImageState extends State<_ArtworkImage> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  BoxFit _fit = BoxFit.contain;
  String? _lastImageSizeKey;

  @override
  void initState() {
    super.initState();
    _fit = widget.forceContain ? BoxFit.contain : BoxFit.cover;
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _ArtworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageProvider != widget.imageProvider || oldWidget.forceContain != widget.forceContain) {
      _fit = widget.forceContain ? BoxFit.contain : BoxFit.cover;
      _resolve();
    }
  }

  void _resolve() {
    if (_listener != null && _stream != null) {
      _stream!.removeListener(_listener!);
    }

    final stream = widget.imageProvider.resolve(const ImageConfiguration());
    _stream = stream;
    _listener = ImageStreamListener((ImageInfo info, bool _) {
      if (!mounted) return;
      final sizeKey = '${info.image.width}x${info.image.height}';
      if (_lastImageSizeKey != sizeKey) {
        _lastImageSizeKey = sizeKey;
        debugPrint('[Artwork] size: $sizeKey');
      }
      if (widget.forceContain) {
        setState(() => _fit = BoxFit.contain);
        return;
      }
      setState(() => _fit = BoxFit.cover);
    });
    stream.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_listener != null && _stream != null) {
      _stream!.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: widget.imageProvider,
      fit: _fit,
      filterQuality: FilterQuality.high,
    );
  }
}
