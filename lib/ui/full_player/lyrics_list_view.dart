part of '../app_ui.dart';

// ==============================================================================
// 歌詞リストビュー（自動スクロール対応）
// ==============================================================================

class _LyricsListView extends StatefulWidget {
  final List<LrcLine> lines;
  final int currentIndex;
  final bool autoScroll;
  final double fontSize;
  final int contextLines;
  final double verticalPadding;
  final double linePadding;
  final Color? currentLineColor;
  final Function(int) onSeek;
  final VoidCallback onAutoScrollToggle;

  const _LyricsListView({
    super.key,
    required this.lines,
    required this.currentIndex,
    required this.autoScroll,
    required this.fontSize,
    required this.contextLines,
    required this.verticalPadding,
    required this.linePadding,
    this.currentLineColor,
    required this.onSeek,
    required this.onAutoScrollToggle,
  });

  @override
  State<_LyricsListView> createState() => _LyricsListViewState();
}

class _LyricsListViewState extends State<_LyricsListView> {
  late ScrollController _scrollController;
  bool _userScrolling = false;
  bool _programmaticScrolling = false;
  List<GlobalKey> _lineKeys = [];
  final GlobalKey _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _lineKeys = List.generate(widget.lines.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 初回表示時は自動送りフラグに関係なく現在行を中央に表示する
      _scrollToCurrent(animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant _LyricsListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lines.length != widget.lines.length) {
      _lineKeys = List.generate(widget.lines.length, (_) => GlobalKey());
    }
    // ユーザーが手動スクロール中でなく、自動送りが有効な場合、現在行を中央に表示
    if (widget.autoScroll && !_userScrolling && _scrollController.hasClients) {
      Future.microtask(() => _scrollToCurrent());
    }

    if (widget.currentIndex != oldWidget.currentIndex && !_userScrolling && _scrollController.hasClients) {
      Future.microtask(() => _scrollToCurrent());
    }

    if (!oldWidget.autoScroll && widget.autoScroll) {
      try {
        HapticFeedback.selectionClick();
      } catch (_) {}
    }
  }

  Future<void> _scrollToCurrent({bool animate = true}) async {
    if (widget.currentIndex >= 0 && widget.currentIndex < _lineKeys.length) {
      final itemCtx = _lineKeys[widget.currentIndex].currentContext;
      final listCtx = _listKey.currentContext;
      if (itemCtx != null && listCtx != null) {
        try {
          final itemBox = itemCtx.findRenderObject() as RenderBox;
          final listBox = listCtx.findRenderObject() as RenderBox;
          final itemOffset = itemBox.localToGlobal(Offset.zero);
          final listOffset = listBox.localToGlobal(Offset.zero);
          final relativeDy = itemOffset.dy - listOffset.dy;
          final listHeight = listBox.size.height;
          final itemHeight = itemBox.size.height;
          // center the item within the visible list area
          double target = _scrollController.offset + relativeDy - (listHeight / 2) + (itemHeight / 2);
          final maxScroll = _scrollController.position.maxScrollExtent;
          if (target < 0) target = 0;
          if (target > maxScroll) target = maxScroll;
          if ((_scrollController.offset - target).abs() < 1.0) return;
          _programmaticScrolling = true;
          if (animate) {
            await _scrollController.animateTo(target, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          } else {
            _scrollController.jumpTo(target);
          }
        } catch (_) {
        } finally {
          _programmaticScrolling = false;
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
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_programmaticScrolling) return false;
        if (notification is ScrollStartNotification) {
          _userScrolling = true;
        } else if (notification is ScrollEndNotification) {
          _userScrolling = false;
          // ユーザー操作終了後、自動送りが有効なときのみ現在行へ再同期
          if (widget.autoScroll && widget.currentIndex >= 0 && _scrollController.hasClients) {
            Future.microtask(() => _scrollToCurrent(animate: false));
          }
        }
        return false;
      },
      child: Container(
        key: _listKey,
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: widget.verticalPadding),
          itemCount: widget.lines.length,
          itemBuilder: (context, index) {
          final line = widget.lines[index];
          final isCurrent = index == widget.currentIndex;

          return GestureDetector(
            key: _lineKeys[index],
            onTap: () {
              widget.onSeek(line.timeMilliseconds);
              if (!widget.autoScroll) {
                // 自動送り再開
                widget.onAutoScrollToggle();
                try {
                  HapticFeedback.selectionClick();
                } catch (_) {}
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: widget.linePadding),
              child: Text(
                line.lyrics,
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: null,
                style: TextStyle(
                  color: isCurrent
                      ? (widget.currentLineColor ?? Theme.of(context).textTheme.bodyMedium?.color)
                      : const Color(0xFFB0B0B0),
                  fontSize: isCurrent ? widget.fontSize + 1 : widget.fontSize,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal,
                  height: 1.6,
                ),
              ),
            ),
          );
        },
        ),
      ),
    );
  }
}
