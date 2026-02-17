/// プレイヤー画面コンポーネント
/// 
/// フルプレイヤー: 歌詞表示、倍速制御、アルバムアート表示
/// ミニプレイヤー: ステータスバー相当の簡易表示

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_like/l10n/app_localizations.dart';
import '../domain/entities.dart';
import '../data/lrc_service.dart';
import 'viewmodels.dart';

/// フルプレイヤー画面
/// タップで表示/非表示を切り替え
class FullPlayerScreen extends ConsumerStatefulWidget {
  final Song song;

  const FullPlayerScreen({
    super.key,
    required this.song,
  });

  @override
  ConsumerState<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends ConsumerState<FullPlayerScreen> {
  double _playbackSpeed = 1.0;
  int _currentTimeMillis = 0;
  List<LrcLine> _lrcLines = [];
  int _currentLrcIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadLyrics();
  }

  /// LRC歌詞ファイルを読み込む
  Future<void> _loadLyrics() async {
    if (widget.song.lyricsPath != null && widget.song.lyricsPath!.isNotEmpty) {
      _lrcLines = await LrcParseService.parseLrcFile(widget.song.lyricsPath!);
      debugPrint('[Player] 歌詞読み込み完了: ${_lrcLines.length}行');
    }
  }

  /// 倍速ボタンタップハンドラ
  /// 選択中の倍速再度押下で 1.0x に戻る
  void _onPlaybackSpeedTap(double speed) {
    // 現在の再生速度を取得
    final vm = ref.read(playerViewModelProvider.notifier);
    final currentSpeed = ref.read(playerViewModelProvider).playbackSpeed;
    final nextSpeed = (currentSpeed == speed) ? 1.0 : speed;
    
    // ViewModel と UI を同時に更新
    vm.setPlaybackSpeed(nextSpeed);
    
    // ローカル状態を即座に更新
    if (mounted) {
      setState(() {
        _playbackSpeed = nextSpeed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerViewModelProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final media = MediaQuery.of(context);
    final viewportHeight = media.size.height - media.padding.top - media.padding.bottom - kToolbarHeight;
    final isCompact = viewportHeight < 700;
    final isVeryCompact = viewportHeight < 620;
    final artworkSize = (screenHeight * 0.34).clamp(180.0, 280.0);
    final artworkPadding = screenHeight < 720 ? 10.0 : 16.0;
    final sectionSpacing = isVeryCompact ? 8.0 : (isCompact ? 12.0 : 24.0);
    final lyricsHeight = (viewportHeight * (isVeryCompact ? 0.14 : isCompact ? 0.18 : 0.24)).clamp(80.0, 150.0);
    final controlIconSize = isVeryCompact ? 40.0 : 48.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.nowPlaying2),
        centerTitle: true,
        backgroundColor: Colors.black.withAlpha((0.3 * 255).round()),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // アルバムアート
            Padding(
              padding: EdgeInsets.all(artworkPadding),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: artworkSize,
                  height: artworkSize,
                  color: Colors.grey.shade800,
                  child: widget.song.artworkUrl != null
                      ? Image.network(
                          widget.song.artworkUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            _buildPlaceholderArt(),
                        )
                      : _buildPlaceholderArt(),
                ),
              ),
            ),

            // 曲情報
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
              child: Column(
                children: [
                  Text(
                    widget.song.title,
                    style: TextStyle(
                      fontSize: isCompact ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.song.artist,
                    style: TextStyle(
                      fontSize: isCompact ? 13 : 14,
                      color: Colors.grey.shade400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.song.album,
                    style: TextStyle(
                      fontSize: isCompact ? 11 : 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: sectionSpacing),

            // 歌詞表示エリア（LRCがある場合）
            if (_lrcLines.isNotEmpty)
              _buildLyricsDisplay(lyricsHeight)
            else
              Padding(
                padding: EdgeInsets.all(isCompact ? 8 : 16),
                child: Text(
                  '歌詞はありません',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),

            SizedBox(height: sectionSpacing),

            // プログレスバー
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
              child: Column(
                children: [
                  Slider(
                    value: _currentTimeMillis.toDouble(),
                    max: widget.song.duration.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        _currentTimeMillis = value.toInt();
                      });
                      // TODO: 音声のシーク処理
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(_currentTimeMillis),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          _formatTime(widget.song.duration.inMilliseconds),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isCompact ? 8 : 16),

            // 再生制御ボタン
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () {
                      debugPrint('[Player] 前の曲');
                    },
                  ),
                  IconButton(
                    icon: Icon(playerState.isPlaying ? Icons.pause : Icons.play_arrow),
                    iconSize: controlIconSize,
                    onPressed: () {
                      ref.read(playerViewModelProvider.notifier).togglePlayPause();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: () {
                      debugPrint('[Player] 次の曲');
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: sectionSpacing),

            // 倍速ボタン
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '再生速度',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: isCompact ? 6 : 8),
                  Wrap(
                    spacing: 8,
                    children: [1.0, 1.25, 1.5, 2.0].map((speed) {
                      final isSelected = _playbackSpeed == speed;
                      return FilterChip(
                        label: Text('${speed}x'),
                        selected: isSelected,
                        onSelected: (_) => _onPlaybackSpeedTap(speed),
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Theme.of(context).textTheme.bodyMedium?.color : Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: isCompact ? 12 : 24),
          ],
        ),
      ),
    );
  }

  /// 歌詞表示ウィジェット
  Widget _buildLyricsDisplay(double height) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade900,
      ),
      child: _lrcLines.isEmpty
          ? Center(
              child: Text(
                '歌詞を読み込み中...',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          : ListView.builder(
              itemCount: _lrcLines.length,
              itemBuilder: (context, index) {
                final isCurrentLine = index == _currentLrcIndex;
                return Text(
                  _lrcLines[index].lyrics,
                  style: TextStyle(
                    color: isCurrentLine
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade400,
                    fontSize: isCurrentLine ? 16 : 14,
                    fontWeight: isCurrentLine ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              },
            ),
    );
  }

  /// プレースホルダーアート
  Widget _buildPlaceholderArt() {
    return Container(
      color: Colors.grey.shade800,
      child: Icon(
        Icons.music_note,
        size: 120,
        color: Colors.grey.shade600,
      ),
    );
  }

  /// ミリ秒を mm:ss 形式に変換
  String _formatTime(int millis) {
    final minutes = (millis ~/ 60000) % 60;
    final seconds = (millis ~/ 1000) % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// ミニプレイヤー：タブバー上部に常表示
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 現在再生中の曲情報を取得
    // final currentSong = ref.watch(playerViewModelProvider).currentSong;

    return Container(
      color: Colors.grey.shade900,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // アルバムアート（小さいサイズ）
          Container(
            width: 48,
            height: 48,
            color: Colors.grey.shade800,
            child: const Icon(Icons.music_note, size: 24),
          ),
          const SizedBox(width: 12),

          // 曲情報
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Now Playing',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'アーティスト名',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 再生/一時停止ボタン
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              // フルプレイヤーを開く
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FullPlayerScreen(
                    song: Song(
                      id: '1',
                      title: 'Sample',
                      artist: 'Artist',
                      album: 'Album',
                      duration: const Duration(minutes: 3),
                      fileFormat: 'MP3',
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
