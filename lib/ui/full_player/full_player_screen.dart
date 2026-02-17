part of '../app_ui.dart';

// ==============================================================================
// フルプレイヤー画面
// ==============================================================================

class FullPlayerScreen extends ConsumerStatefulWidget {
  final bool adjustMode;

  const FullPlayerScreen({super.key, this.adjustMode = false});

  @override
  ConsumerState<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends ConsumerState<FullPlayerScreen> with _FullPlayerHelpers {
  bool _showLyrics = true; // 歌詞表示フラグ
  bool _showBottomButtons = true; // 再生ボタン下のボタン列の表示フラグ
  String? _lastLoadedSongId; // 最後に読み込んだ曲のID
  int _lyricsRenderToken = 0;
  int _adjustOffsetMs = 0;
  bool _adjustHasApplied = false;
  List<LrcLine> _adjustBaseLines = const [];

  @override
  void initState() {
    super.initState();
    if (_isAdjustMode) {
      _showLyrics = true;
    }
  }

  bool get _isAdjustMode => widget.adjustMode;

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerViewModelProvider);
    final playerViewModel = ref.read(playerViewModelProvider.notifier);
    final song = playerState.currentSong;

    if (song == null) {
      return Center(child: Text(AppLocalizations.of(context)!.noSongPlaying));
    }

    // 曲が変わった場合、歌詞を読み込み（歌詞が無い曲はクリア）
    if (song.id != _lastLoadedSongId) {
      _lastLoadedSongId = song.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (song.lyricsPath != null && song.lyricsPath!.isNotEmpty) {
          playerViewModel.loadLyricsFromPath(song.lyricsPath);
          if (_isAdjustMode) {
            _loadAdjustBaseLines(song);
          }
        } else {
          playerViewModel.loadLyricsFromPath(null);
          if (_isAdjustMode) {
            if (mounted) {
              setState(() {
                _adjustBaseLines = const [];
                _adjustOffsetMs = 0;
                _adjustHasApplied = false;
              });
            }
          }
        }
      });
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final media = MediaQuery.of(context);
        final usableHeight = screenHeight - media.padding.top - media.padding.bottom;
        final isCompactHeight = usableHeight <= 760;
        final isVeryCompactHeight = usableHeight <= 680;
        // サムネイル（アートワーク）は一旦従来の計算に戻す
        final artworkSize = math.min(screenWidth - 16, screenWidth * 0.98);
        final sectionSpacingLarge = isVeryCompactHeight ? 8.0 : (isCompactHeight ? 10.0 : 16.0);
        final sectionSpacingSmall = isVeryCompactHeight ? 2.0 : 4.0;
        final titleFontSize = isCompactHeight ? 19.0 : 22.0;
        final artistFontSize = isCompactHeight ? 13.0 : 14.0;
        final textColor = Theme.of(context).textTheme.bodyMedium?.color ??
          Theme.of(context).iconTheme.color ??
          Theme.of(context).colorScheme.onSurface;
        final seekBarInactiveColor = SliderTheme.of(context).inactiveTrackColor ??
          Theme.of(context).colorScheme.surfaceContainerHighest;
        final shuffleColor = playerState.shuffleMode == ShuffleMode.off ? seekBarInactiveColor : textColor;
        final repeatColor = playerState.repeatMode == RepeatMode.off ? seekBarInactiveColor : textColor;

        final displayDuration = playerState.duration > Duration.zero ? playerState.duration : song.duration;
        final displayLyricsLines = _isAdjustMode
          ? _buildAdjustedLines(_adjustBaseLines, _adjustOffsetMs)
          : playerState.lrcLines;

        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.9,
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(isCompactHeight ? 14 : 20, isCompactHeight ? 10 : 16, isCompactHeight ? 14 : 20, 12 + media.padding.bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      SizedBox(height: sectionSpacingLarge),
                      // アルバムジャケット or 歌詞表示（キューボタン右上）
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // サムネイル（背景）
                          GestureDetector(
                            onTap: () {
                              if (_isAdjustMode) return;
                              _tapFeedback(context);
                              setState(() {
                                _showLyrics = !_showLyrics;
                                _lyricsRenderToken++;
                              });
                              if (_showLyrics) {
                                ref.read(playerViewModelProvider.notifier).setAutoScrollLyrics(true);
                              }
                            },
                            child: Container(
                              width: artworkSize,
                              height: artworkSize,
                              decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha((0.4 * 255).round()),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: song.artworkUrl != null
                                  ? (song.artworkUrl!.startsWith('http')
                                    ? _ArtworkImage(
                                        imageProvider: NetworkImage(song.artworkUrl!),
                                        forceContain: !_showLyrics,
                                      )
                                    : _ArtworkImage(
                                        imageProvider: FileImage(File(song.artworkUrl!)),
                                        forceContain: !_showLyrics,
                                      ))
                                  : const Icon(Icons.music_note, size: 100),
                            ),
                          ),
                        ),
                        // 歌詞表示（前面）
                        if (_showLyrics && playerState.lrcLines.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: artworkSize,
                              height: artworkSize,
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha((0.95 * 255).round()),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _buildLyricsView(
                                playerState,
                                ref,
                                maxHeight: artworkSize,
                                overrideLines: displayLyricsLines,
                              ),
                            ),
                          ),
                        // キューボタン（右上）
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.queue_music),
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withAlpha((0.6 * 255).round()),
                              padding: const EdgeInsets.all(8),
                            ),
                            onPressed: () {
                              _tapFeedback(context);
                              _showQueueSheet(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: sectionSpacingLarge),
                  // 曲情報（タイトル）
                  if (!_isAdjustMode)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _showBottomButtons ? Icons.expand_less : Icons.expand_more,
                            color: textColor,
                          ),
                          tooltip: _showBottomButtons ? 'コントロールを折りたたむ' : 'コントロールを展開',
                          onPressed: () {
                            _tapFeedback(context);
                            setState(() {
                              _showBottomButtons = !_showBottomButtons;
                            });
                          },
                        ),
                        Expanded(
                          child: _buildMarqueeText(
                            song.title,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  if (song.volumeOffsetDb != 0.0) ...[
                    const SizedBox(height: 4),
                    Tooltip(
                      message: '音量調整: ${song.volumeOffsetDb > 0 ? '+' : ''}${song.volumeOffsetDb.toStringAsFixed(1)}dB',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            song.volumeOffsetDb > 0 ? Icons.volume_up : Icons.volume_down,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${song.volumeOffsetDb > 0 ? '+' : ''}${song.volumeOffsetDb.toStringAsFixed(1)}dB',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: sectionSpacingSmall),
                  // アーティスト情報（スクロール表示） -- 調整モード時は非表示
                  if (!_isAdjustMode)
                    _buildMarqueeText(
                      song.artist,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: artistFontSize,
                      ),
                    ),
                  SizedBox(height: sectionSpacingSmall),
                  // 音質バッジ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (song.isLossless) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha((0.2 * 255).round()),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.high_quality, size: 14, color: Theme.of(context).iconTheme.color),
                              const SizedBox(width: 4),
                              Text(
                                'ロスレス',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (song.isDolbyAtmos) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha((0.2 * 255).round()),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.surround_sound, size: 14, color: Theme.of(context).iconTheme.color),
                              const SizedBox(width: 4),
                              Text(
                                'Dolby Atmos',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: isCompactHeight ? 4 : 8),
                  // 再生位置バー
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3.0,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      thumbColor: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                      overlayColor: (Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface).withAlpha((0.3 * 255).round()),
                    ),
                    child: _SeekBar(
                      position: playerState.position,
                      duration: displayDuration,
                      onSeek: (position) => ref
                          .read(playerViewModelProvider.notifier)
                          .seekTo(position),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isCompactHeight ? 12 : 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(playerState.position),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(displayDuration),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isAdjustMode) const SizedBox(height: 12),
                  if (!_isAdjustMode && isCompactHeight) const SizedBox(height: 2),
                  // 再生コントロール 1行目
                  if (_isAdjustMode)
                    Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // 左に再生ボタン
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                    iconSize: 32,
                                    onPressed: () {
                                      _tapFeedback(context);
                                      ref.read(playerViewModelProvider.notifier).togglePlayPause();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    AppLocalizations.of(context)!.offsetLabel('${_adjustOffsetMs >= 0 ? '+' : '-'}${(_adjustOffsetMs.abs() / 1000).toStringAsFixed(2)}s'),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Apply / Reset を別行にして折り返し対応
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(0, 32),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: _adjustBaseLines.isEmpty || _adjustOffsetMs == 0 ? null : () => _applyAdjustChanges(song),
                                    child: Text(AppLocalizations.of(context)!.commonApply),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(0, 32),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: _adjustBaseLines.isEmpty ? null : () => _resetAdjustChanges(song),
                                    child: Text(AppLocalizations.of(context)!.commonReset),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildAdjustControls(song, showApplyReset: false),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          iconSize: 28,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          onPressed: () {
                            _tapFeedback(context);
                            ref.read(playerViewModelProvider.notifier).skipToPrevious();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.replay_10),
                          iconSize: 28,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          onPressed: () {
                            _tapFeedback(context);
                            ref
                                .read(playerViewModelProvider.notifier)
                                .skipBackward10Seconds();
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                            iconSize: 32,
                            onPressed: () {
                              _tapFeedback(context);
                              ref
                                  .read(playerViewModelProvider.notifier)
                                  .togglePlayPause();
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.forward_10),
                          iconSize: 28,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          onPressed: () {
                            _tapFeedback(context);
                            ref
                                .read(playerViewModelProvider.notifier)
                                .skipForward10Seconds();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          iconSize: 28,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          onPressed: () {
                            _tapFeedback(context);
                            ref.read(playerViewModelProvider.notifier).skipToNext();
                          },
                        ),
                      ],
                    ),
                  if (!_isAdjustMode && _showBottomButtons) ...[
                    SizedBox(height: isCompactHeight ? 6 : 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            _showLyrics ? Icons.lyrics : Icons.lyrics_outlined,
                            color: textColor,
                          ),
                          onPressed: () {
                            _tapFeedback(context);
                            setState(() {
                              _showLyrics = !_showLyrics;
                              _lyricsRenderToken++;
                            });
                            if (_showLyrics) {
                              ref.read(playerViewModelProvider.notifier).setAutoScrollLyrics(true);
                            }
                          },
                        ),
                        // 倍速ドロップダウン
                        PopupMenuButton<double>(
                          onSelected: (speed) {
                            ref.read(playerViewModelProvider.notifier).setPlaybackSpeed(speed);
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: 0.75,
                              child: Text(AppLocalizations.of(context)!.k075),
                            ),
                            PopupMenuItem(
                              value: 0.9,
                              child: Text(AppLocalizations.of(context)!.k09),
                            ),
                            PopupMenuItem(
                              value: 1.0,
                              child: Text(AppLocalizations.of(context)!.k10),
                            ),
                            PopupMenuItem(
                              value: 1.1,
                              child: Text(AppLocalizations.of(context)!.k11),
                            ),
                            PopupMenuItem(
                              value: 1.25,
                              child: Text(AppLocalizations.of(context)!.k125),
                            ),
                            PopupMenuItem(
                              value: 1.5,
                              child: Text(AppLocalizations.of(context)!.k15),
                            ),
                            PopupMenuItem(
                              value: 2.0,
                              child: Text(AppLocalizations.of(context)!.k20),
                            ),
                          ],
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: textColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${playerState.playbackSpeed.toStringAsFixed(2)}×',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: shuffleColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            iconSize: 32,
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            style: IconButton.styleFrom(
                              overlayColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                            ),
                            icon: Icon(
                              Icons.shuffle,
                              color: shuffleColor,
                              size: 28,
                            ),
                            onPressed: () {
                              _tapFeedback(context);
                              ref.read(playerViewModelProvider.notifier).toggleShuffle();
                            },
                          ),
                        ),
                        IconButton(
                          iconSize: 28,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                          icon: Icon(
                            playerState.repeatMode == RepeatMode.off
                                ? Icons.repeat
                                : playerState.repeatMode == RepeatMode.all
                                    ? Icons.repeat_on
                                    : Icons.repeat_one,
                            color: repeatColor,
                          ),
                          onPressed: () {
                            _tapFeedback(context);
                            ref.read(playerViewModelProvider.notifier).toggleRepeat();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: isCompactHeight ? 8 : 16),
                  ],
                ], // Column children
              ), // Column
            ), // Padding
          ), // SingleChildScrollView
        ), // ConstrainedBox
      ), // SafeArea
    ); // Container
      }, // builder
    ); // DraggableScrollableSheet
  }
}
