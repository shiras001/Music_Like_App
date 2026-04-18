part of 'app_ui.dart';

// ==============================================================================
// テキストマーキーウィジェット（自動流動表示）
// ==============================================================================

class _AnimatedMarquee extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final int initialDelayMs;

  const _AnimatedMarquee({
    required this.text,
    this.fontSize = 14,
    this.color,
    this.initialDelayMs = 2000,
  });

  @override
  State<_AnimatedMarquee> createState() => _AnimatedMarqueeState();
}

class _AnimatedMarqueeState extends State<_AnimatedMarquee> {
  static const double _gapWidth = 40;
  Timer? _timer;
  double _viewportWidth = 0;
  double _textWidth = 0;
  double _offset = 0;
  int _lastFrameMicros = 0;
  int _holdUntilMicros = 0;
  static const double _pixelsPerSecond = 50;
  bool _wasOverflowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _restartLoopWithDelay();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _AnimatedMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.fontSize != widget.fontSize ||
        oldWidget.color != widget.color ||
        oldWidget.initialDelayMs != widget.initialDelayMs) {
      _offset = 0;
      _lastFrameMicros = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _restartLoopWithDelay();
        }
      });
    }
  }

  TextStyle _textStyle(BuildContext context) {
    return TextStyle(
      color: widget.color ?? Theme.of(context).textTheme.bodyMedium?.color,
      fontSize: widget.fontSize,
      fontWeight: FontWeight.w500,
    );
  }

  void _measureWidths(BuildContext context, BoxConstraints constraints) {
    final previousViewportWidth = _viewportWidth;
    final previousTextWidth = _textWidth;
    _viewportWidth = constraints.maxWidth;
    final style = _textStyle(context);
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    _textWidth = painter.width;

    final isOverflowing = _textWidth > _viewportWidth + 0.5;
    final metricsChanged =
        (previousViewportWidth - _viewportWidth).abs() > 0.5 ||
        (previousTextWidth - _textWidth).abs() > 0.5;

    if (_wasOverflowing != isOverflowing || metricsChanged) {
      _wasOverflowing = isOverflowing;
      _offset = 0;
      _lastFrameMicros = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _restartLoopWithDelay();
        }
      });
    }
  }

  void _restartLoopWithDelay() {
    final overflows = _textWidth > _viewportWidth + 0.5;
    if (!overflows) {
      _timer?.cancel();
      return;
    }
    _timer?.cancel();
    final now = DateTime.now().microsecondsSinceEpoch;
    _lastFrameMicros = now;
    _holdUntilMicros = now + (widget.initialDelayMs * 1000);
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _onFrame());
  }

  void _onFrame() {
    if (!mounted) return;
    final overflows = _textWidth > _viewportWidth + 0.5;
    if (!overflows) return;
    final wallNow = DateTime.now().microsecondsSinceEpoch;
    if (_lastFrameMicros == 0) {
      _lastFrameMicros = wallNow;
      return;
    }
    if (wallNow < _holdUntilMicros) {
      _lastFrameMicros = wallNow;
      return;
    }

    final deltaSec = (wallNow - _lastFrameMicros) / 1000000.0;
    _lastFrameMicros = wallNow;
    if (deltaSec <= 0) return;

    final cycleWidth = _textWidth + _gapWidth;
    if (cycleWidth <= 0) return;

    final nextOffset = _offset + (_pixelsPerSecond * deltaSec);
    final didLoop = nextOffset >= cycleWidth;

    setState(() {
      _offset = didLoop ? 0 : nextOffset;
    });

    if (didLoop) {
      _holdUntilMicros = wallNow + (widget.initialDelayMs * 1000);
    }
  }

  Widget _buildOverflowingText(TextStyle style) {
    return ClipRect(
      child: SizedBox(
        width: _viewportWidth,
        height: widget.fontSize * 1.5,
        child: Stack(
          children: [
            Positioned(
              left: -_offset,
              child: Text(widget.text, maxLines: 1, softWrap: false, style: style),
            ),
            Positioned(
              left: _textWidth + _gapWidth - _offset,
              child: Text(widget.text, maxLines: 1, softWrap: false, style: style),
            ),
            Positioned(
              left: (_textWidth + _gapWidth) * 2 - _offset,
              child: Text(widget.text, maxLines: 1, softWrap: false, style: style),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _measureWidths(context, constraints);
        final style = _textStyle(context);
        final isOverflowing = _textWidth > _viewportWidth + 0.5;

        if (!isOverflowing) {
          return Text(
            widget.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          );
        }

        return SizedBox(
          width: double.infinity,
          child: _buildOverflowingText(style),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
