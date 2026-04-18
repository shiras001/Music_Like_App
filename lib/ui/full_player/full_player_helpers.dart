part of '../app_ui.dart';

mixin _FullPlayerHelpers on ConsumerState<FullPlayerScreen> {
  List<LrcLine> get _adjustBaseLines;
  set _adjustBaseLines(List<LrcLine> value);

  int get _adjustOffsetMs;
  set _adjustOffsetMs(int value);

  bool get _adjustHasApplied;
  set _adjustHasApplied(bool value);

  int get _lyricsRenderToken;
  Future<File?> _getLrcFileForSong(Song song) async {
    final path = song.lyricsPath;
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  Future<void> _loadAdjustBaseLines(Song song) async {
    final file = await _getLrcFileForSong(song);
    if (file == null) {
      setState(() {
        _adjustBaseLines = const [];
        _adjustOffsetMs = 0;
        _adjustHasApplied = false;
      });
      return;
    }
    final lines = await LrcParseService.parseLrcFile(file.path);
    if (!mounted) return;
    setState(() {
      _adjustBaseLines = lines;
      _adjustOffsetMs = 0;
      _adjustHasApplied = false;
    });
  }

  List<LrcLine> _buildAdjustedLines(List<LrcLine> lines, int offsetMs) {
    if (offsetMs == 0) return lines;
    return lines
        .map((l) => LrcLine(
              timeMilliseconds: math.max(0, l.timeMilliseconds + offsetMs),
              lyrics: l.lyrics,
            ))
        .toList();
  }

  void _applyAdjustOffset(int deltaMs) {
    if (_adjustBaseLines.isEmpty) return;
    setState(() {
      _adjustOffsetMs += deltaMs;
    });
  }

  Future<void> _applyAdjustChanges(Song song) async {
    if (_adjustOffsetMs == 0) return;
    final file = await _getLrcFileForSong(song);
    if (file == null) return;

    final backupPath = '${file.path}.bak';
    final backupFile = File(backupPath);
    if (!backupFile.existsSync()) {
      await backupFile.writeAsString(await file.readAsString());
    }

    final content = await file.readAsString();
    final lines = content.split('\n');
    final timePattern = RegExp(r'^\[(\d{2}):(\d{2})\.(\d{2})\](.*)$');

    final adjusted = lines.map((line) {
      final match = timePattern.firstMatch(line.trim());
      if (match == null) return line;
      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final centiseconds = int.parse(match.group(3)!);
      final lyric = match.group(4) ?? '';
      final currentMs = (minutes * 60000) + (seconds * 1000) + (centiseconds * 10);
      final nextMs = math.max(0, currentMs + _adjustOffsetMs).toInt();
      return '${_formatTimestamp(nextMs)}${lyric}';
    }).join('\n');

    await file.writeAsString(adjusted);
    if (!mounted) return;
    setState(() {
      _adjustHasApplied = true;
      _adjustOffsetMs = 0;
    });
    await ref.read(playerViewModelProvider.notifier).loadLyricsFromPath(file.path);
    await _loadAdjustBaseLines(song);
  }

  Future<void> _resetAdjustChanges(Song song) async {
    if (_adjustHasApplied) {
      final file = await _getLrcFileForSong(song);
      if (file == null) return;
      final backupPath = '${file.path}.bak';
      final backupFile = File(backupPath);
      if (backupFile.existsSync()) {
        await file.writeAsString(await backupFile.readAsString());
        await ref.read(playerViewModelProvider.notifier).loadLyricsFromPath(file.path);
      }
      if (!mounted) return;
      setState(() {
        _adjustHasApplied = false;
        _adjustOffsetMs = 0;
      });
      await _loadAdjustBaseLines(song);
    } else {
      setState(() {
        _adjustOffsetMs = 0;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString()}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTimestamp(int ms) {
    final totalSeconds = (ms / 1000).floor();
    final minutes = (totalSeconds / 60).floor();
    final seconds = totalSeconds % 60;
    final centiseconds = ((ms % 1000) / 10).floor();
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    final cs = centiseconds.toString().padLeft(2, '0');
    return '[$mm:$ss.$cs]';
  }

  Widget _buildAdjustControls(Song song, {bool showApplyReset = true}) {
    final hasLyrics = _adjustBaseLines.isNotEmpty;
    return Column(
      children: [
        if (!hasLyrics)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              AppLocalizations.of(context)!.lyricsFileNotFound,
              style: TextStyle(color: Colors.red[300], fontSize: 12),
            ),
          ),
        const SizedBox(height: 8),
        Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _adjustButton('-1.00s', -1000),
                _adjustButton('-0.10s', -100),
                _adjustButton('-0.01s', -10),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _adjustButton('+1.00s', 1000),
                _adjustButton('+0.10s', 100),
                _adjustButton('+0.01s', 10),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (showApplyReset)
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: !hasLyrics || _adjustOffsetMs == 0 ? null : () => _applyAdjustChanges(song),
                  child: Text(AppLocalizations.of(context)!.commonApply),
                ),
                TextButton(
                  onPressed: !hasLyrics ? null : () => _resetAdjustChanges(song),
                  child: Text(AppLocalizations.of(context)!.commonReset),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _adjustButton(String label, int deltaMs) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: _adjustBaseLines.isEmpty ? null : () => _applyAdjustOffset(deltaMs),
      child: Text(label),
    );
  }

  Widget _buildLyricsView(
    PlayerState playerState,
    WidgetRef ref, {
    required double maxHeight,
    List<LrcLine>? overrideLines,
  }) {
    final currentTimeMs = playerState.position.inMilliseconds;
    final lines = overrideLines ?? playerState.lrcLines;
    final currentIndex = LrcParseService.getCurrentLrcLineIndex(
      lines,
      currentTimeMs,
    );

    final song = playerState.currentSong;
    final settings = ref.watch(settingsViewModelProvider);
    final baseFontSize = settings.lyricsSettings.fontSize.clamp(12.0, 20.0);
    final currentLineHeight = baseFontSize * 1.6;
    final visibleLines = settings.lyricsSettings.contextLines * 2 + 1;

    const linePadding = 6.0;
    final desiredExtent = (currentLineHeight * 2) + (linePadding * 2) + 6.0;
    final lyricsViewHeight = maxHeight;
    final maxPadding = math.max(0.0, (lyricsViewHeight - desiredExtent) / 2);
    final contextPadding = settings.lyricsSettings.contextLines * desiredExtent;
    final verticalPadding = math.min(contextPadding, maxPadding);
    debugPrint('[Lyrics] build: currentIndex=$currentIndex, baseFontSize=$baseFontSize, estimatedItem=${desiredExtent.toStringAsFixed(2)}, visibleLines=$visibleLines, lyricsViewHeight=${lyricsViewHeight.toStringAsFixed(2)}, verticalPadding=${verticalPadding.toStringAsFixed(2)}');

    return Stack(
      children: [
        // 背景：サムネイルを薄く表示（透明度は固定）
        if (settings.lyricsSettings.showBackground && song?.artworkUrl != null)
          Positioned.fill(
            child: Opacity(
              opacity: 1.0,
              child: song!.artworkUrl!.startsWith('http')
                  ? _ArtworkImage(
                      imageProvider: NetworkImage(song.artworkUrl!),
                      forceContain: true,
                    )
                  : _ArtworkImage(
                      imageProvider: FileImage(File(song.artworkUrl!)),
                      forceContain: true,
                    ),
            ),
          ),

        // 半透明のオーバーレイ
        Positioned.fill(
          child: Container(
            color: Colors.black.withAlpha((0.7 * 255).round()),
          ),
        ),

        // 歌詞リスト（現在行が中央に配置）
        Center(
          child: SizedBox(
            width: double.infinity,
            height: lyricsViewHeight,
            child: _LyricsListView(
              key: ValueKey('${song?.id}_${_lyricsRenderToken}_${playerState.autoScrollLyrics}'),
              lines: lines,
              currentIndex: currentIndex,
              autoScroll: playerState.autoScrollLyrics,
              fontSize: baseFontSize,
              contextLines: settings.lyricsSettings.contextLines,
              verticalPadding: verticalPadding,
              linePadding: linePadding,
              currentLineColor: Theme.of(context).textTheme.bodyMedium?.color,
              onSeek: (timeMs) {
                ref.read(playerViewModelProvider.notifier).seekTo(
                  Duration(milliseconds: timeMs),
                );
              },
              onAutoScrollToggle: () {
                ref.read(playerViewModelProvider.notifier).toggleAutoScrollLyrics();
              },
            ),
          ),
        ),
      ],
    );
  }

  /// テキストが長すぎる場合、スクロール表示する
  Widget _buildMarqueeText(
    String text, {
    TextStyle? style,
    int maxLines = 1,
  }) {
    final resolvedStyle = style ?? const TextStyle();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: SizedBox(
        height: (resolvedStyle.fontSize ?? 14) * 1.5,
        child: _AnimatedMarquee(
          text: text,
          fontSize: resolvedStyle.fontSize ?? 14,
          color: resolvedStyle.color,
          initialDelayMs: 2000,
        ),
      ),
    );
  }

  void _showQueueSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _QueueView(scrollController: scrollController);
        },
      ),
    );
  }
}
