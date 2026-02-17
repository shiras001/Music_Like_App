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
    this.initialDelayMs = 500,
  });

  @override
  State<_AnimatedMarquee> createState() => _AnimatedMarqueeState();
}

class _AnimatedMarqueeState extends State<_AnimatedMarquee> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    Future.delayed(Duration(milliseconds: widget.initialDelayMs), _startScroll);
  }

  void _startScroll() async {
    if (!mounted) return;
    while (mounted && _scrollController.hasClients) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(seconds: (widget.text.length / 10).ceil()),
          curve: Curves.linear,
        );
        await Future.delayed(Duration(seconds: (widget.text.length / 10).ceil() + 2));
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style: TextStyle(
          color: widget.color ?? Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
