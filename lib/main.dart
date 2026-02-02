import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';

import 'presentation/viewmodels.dart';
import 'platform/arch_selector.dart';
import 'domain/entities.dart';
import 'data/lrc_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MusicLikeApp()));
}

/// アプリ全体のルートウィジェット
class MusicLikeApp extends ConsumerWidget {
  const MusicLikeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // アーキテクチャ依存サービスの初期化
    final audioService = ref.watch(nativeAudioServiceProvider);
    debugPrint('Running on architecture: ${audioService.getArchitectureName()}');
    audioService.initializeAudioEngine();

    return MaterialApp(
      title: 'Music Like',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF2D55), // Apple Music Red
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF2D55),
          brightness: Brightness.dark,
          surface: const Color(0xFF1C1C1E),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: IconThemeData(color: Color(0xFFFF2D55)),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: const Color(0xFFFF2D55),
          inactiveTrackColor: Colors.grey.shade800,
          thumbColor: const Color(0xFFFF2D55),
          overlayColor: const Color(0xFFFF2D55).withOpacity(0.3),
          trackHeight: 3.0,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

/// メイン画面：タブナビゲーションとミニプレイヤーのレイアウト管理
/// 仕様: README参照
/// タブ構成：
/// 1. ライブラリ（ユーザーの楽曲管理）
/// 2. 検索（複合検索：曲名／アーティスト／アルバム／プレイリスト）
/// 3. 設定（アプリ全体設定・ローカル読込機能管理）
/// UI: 下部ミニプレイヤー、タブバー固定
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _LibraryTab(),      // ライブラリ
    _SettingsTab(),     // 設定
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
          // ミニプレイヤー（コンテンツの下、タブバーの上に常駐）
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1C1C1E),
        selectedItemColor: const Color(0xFFFF2D55),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'ライブラリ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// ミニプレイヤー
// ==============================================================================

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerViewModelProvider);
    final song = playerState.currentSong;

    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (_) => const FullPlayerScreen(),
        );
      },
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(4),
              ),
                child: song.artworkUrl != null
                  ? (song.artworkUrl!.startsWith('http')
                    ? Image.network(song.artworkUrl!, fit: BoxFit.cover)
                    : Image.file(File(song.artworkUrl!), fit: BoxFit.cover))
                  : const Icon(Icons.music_note),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: song.title.length > 20
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      child: Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 14,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: song.artist.length > 20
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      child: Text(
                        song.artist,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 再生/一時停止ボタン（フルプレーヤーと同じデザイン）
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFF2D55),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                iconSize: 24,
                onPressed: () =>
                    ref.read(playerViewModelProvider.notifier).togglePlayPause(),
              ),
            ),
            // 次へボタン（丸囲み）
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.skip_next),
                color: Colors.white,
                iconSize: 24,
                onPressed: () =>
                    ref.read(playerViewModelProvider.notifier).skipToNext(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// フルプレイヤー画面
// ==============================================================================

class FullPlayerScreen extends ConsumerStatefulWidget {
  const FullPlayerScreen({super.key});

  @override
  ConsumerState<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends ConsumerState<FullPlayerScreen> {
  bool _showLyrics = true;  // 歌詞表示フラグ

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerViewModelProvider);
    final song = playerState.currentSong;

    if (song == null) {
      return const Center(child: Text('No song playing'));
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        final screenHeight = MediaQuery.of(context).size.height;
        
        return Container(
          color: Colors.black,
          child: SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.9,
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                      const SizedBox(height: 20),
                      // アルバムジャケット or 歌詞表示（キューボタン右上）
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // サムネイル（背景）
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showLyrics = !_showLyrics;
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height: MediaQuery.of(context).size.width * 0.85,
                              constraints: const BoxConstraints(maxWidth: 360, maxHeight: 360),
                              decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: song.artworkUrl != null
                                  ? (song.artworkUrl!.startsWith('http')
                                      ? Image.network(song.artworkUrl!, fit: BoxFit.cover)
                                      : Image.file(File(song.artworkUrl!), fit: BoxFit.cover))
                                  : const Icon(Icons.music_note, size: 100),
                            ),
                          ),
                        ),
                        
                        // 歌詞表示（前面）
                        if (_showLyrics && playerState.lrcLines.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height: MediaQuery.of(context).size.width * 0.85,
                              constraints: const BoxConstraints(maxWidth: 360, maxHeight: 360),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _buildLyricsView(playerState, ref),
                            ),
                          ),
                        
                        // キューボタン（右上）
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.queue_music),
                            color: Colors.white,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.6),
                              padding: const EdgeInsets.all(8),
                            ),
                            onPressed: () {
                              _showQueueSheet(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  // 曲情報（タイトル）
                  _buildMarqueeText(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
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
                  const SizedBox(height: 8),
                  // アーティスト情報（スクロール表示）
                  _buildMarqueeText(
                    song.artist,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 音質バッジ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (song.isLossless) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.high_quality, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'ロスレス',
                                style: TextStyle(
                                  color: Colors.white,
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
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.surround_sound, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Dolby Atmos',
                                style: TextStyle(
                                  color: Colors.white,
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
                  const SizedBox(height: 12),
                  // 再生位置バー
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3.0,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                      activeTrackColor: const Color(0xFFFF2D55),
                      inactiveTrackColor: Colors.grey.shade800,
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withOpacity(0.3),
                    ),
                    child: _SeekBar(
                      position: playerState.position,
                      duration: song.duration,
                      onSeek: (position) => ref
                          .read(playerViewModelProvider.notifier)
                          .seekTo(position),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          _formatDuration(song.duration),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 再生コントロール 1行目
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 28,
                        color: Colors.white,
                        onPressed: () =>
                            ref.read(playerViewModelProvider.notifier).skipToPrevious(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.replay_10),
                        iconSize: 28,
                        color: Colors.white,
                        onPressed: () => ref
                            .read(playerViewModelProvider.notifier)
                            .skipBackward10Seconds(),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF2D55),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          iconSize: 32,
                          onPressed: () => ref
                              .read(playerViewModelProvider.notifier)
                              .togglePlayPause(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10),
                    iconSize: 28,
                    color: Colors.white,
                    onPressed: () => ref
                        .read(playerViewModelProvider.notifier)
                        .skipForward10Seconds(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    iconSize: 28,
                    color: Colors.white,
                    onPressed: () =>
                        ref.read(playerViewModelProvider.notifier).skipToNext(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 再生コントロール 2行目（歌詞ボタン＋倍速ドロップダウン＋シャッフル＋リピート）
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 歌詞表示ボタン（左側）
                  IconButton(
                    iconSize: 28,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    icon: Icon(
                      _showLyrics ? Icons.lyrics : Icons.lyrics_outlined,
                      color: _showLyrics ? const Color(0xFFFF2D55) : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _showLyrics = !_showLyrics;
                      });
                    },
                  ),
                  // 倍速ドロップダウン
                  PopupMenuButton<double>(
                    onSelected: (speed) {
                      ref
                          .read(playerViewModelProvider.notifier)
                          .setPlaybackSpeed(speed);
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 0.75,
                        child: Text('0.75×'),
                      ),
                      const PopupMenuItem(
                        value: 1.0,
                        child: Text('1.0×'),
                      ),
                      const PopupMenuItem(
                        value: 1.25,
                        child: Text('1.25×'),
                      ),
                      const PopupMenuItem(
                        value: 1.5,
                        child: Text('1.5×'),
                      ),
                      const PopupMenuItem(
                        value: 2.0,
                        child: Text('2.0×'),
                      ),
                    ],
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFFF2D55),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${playerState.playbackSpeed.toStringAsFixed(2)}×',
                        style: const TextStyle(
                          color: Color(0xFFFF2D55),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: 28,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    style: IconButton.styleFrom(
                      overlayColor: Colors.transparent,
                    ),
                    icon: Icon(
                      playerState.shuffleMode == ShuffleMode.on
                          ? Icons.shuffle_on
                          : Icons.shuffle,
                      color: playerState.shuffleMode == ShuffleMode.on
                          ? const Color(0xFFFF2D55)
                          : Colors.white,
                    ),
                    onPressed: () =>
                      ref.read(playerViewModelProvider.notifier).toggleShuffle(),
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
                      color: playerState.repeatMode == RepeatMode.off
                          ? Colors.white
                          : const Color(0xFFFF2D55),
                    ),
                    onPressed: () =>
                        ref.read(playerViewModelProvider.notifier).toggleRepeat(),
                  ),
                ],
              ),
              const SizedBox(height: 40),
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildLyricsView(PlayerState playerState, WidgetRef ref) {
    final currentTimeMs = playerState.position.inMilliseconds;
    final currentIndex = LrcParseService.getCurrentLrcLineIndex(
      playerState.lrcLines,
      currentTimeMs,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20),
          itemCount: playerState.lrcLines.length,
          itemBuilder: (context, index) {
            final line = playerState.lrcLines[index];
            final isCurrent = index == currentIndex;
            
            return GestureDetector(
              onTap: () {
                ref.read(playerViewModelProvider.notifier).seekTo(
                  Duration(milliseconds: line.timeMilliseconds),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  line.lyrics,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isCurrent ? const Color(0xFFFF2D55) : Colors.grey,
                    fontSize: isCurrent ? 18 : 14,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// テキストが長すぎる場合、スクロール表示する
  Widget _buildMarqueeText(
    String text, {
    TextStyle? style,
    int maxLines = 1,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: text.length > 20
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: Text(
          text,
          maxLines: maxLines,
          overflow: TextOverflow.clip,
          style: style,
        ),
      ),
    );
  }

  void _showQueueSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
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

class _QueueView extends ConsumerWidget {
  final ScrollController scrollController;

  const _QueueView({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerViewModelProvider);
    final queue = playerState.queue;
    final currentIndex = playerState.currentQueueIndex;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '次に再生',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('閉じる'),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
          Expanded(
            child: queue.isEmpty
                ? const Center(
                    child: Text(
                      'キューに曲がありません',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ReorderableListView.builder(
                    scrollController: scrollController,
                    itemCount: queue.length,
                    onReorder: (oldIndex, newIndex) {
                      ref.read(playerViewModelProvider.notifier).reorderQueue(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final song = queue[index];
                      final isCurrentSong = index == currentIndex;

                      return Dismissible(
                        key: Key('${song.id}_$index'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          ref.read(playerViewModelProvider.notifier).removeFromQueue(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('「${song.title}」をキューから削除しました')),
                          );
                        },
                        child: Container(
                          color: isCurrentSong ? Colors.grey.withOpacity(0.2) : Colors.transparent,
                          child: ListTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.drag_handle, color: Colors.grey),
                                const SizedBox(width: 8),
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: song.artworkUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: song.artworkUrl!.startsWith('http')
                                              ? Image.network(song.artworkUrl!, fit: BoxFit.cover)
                                              : Image.file(File(song.artworkUrl!), fit: BoxFit.cover),
                                        )
                                      : const Icon(Icons.music_note),
                                ),
                              ],
                            ),
                            title: Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isCurrentSong ? const Color(0xFFFF2D55) : Colors.white,
                                fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isCurrentSong ? const Color(0xFFFF2D55).withOpacity(0.7) : Colors.grey,
                              ),
                            ),
                            trailing: isCurrentSong
                                ? const Icon(Icons.play_arrow, color: Color(0xFFFF2D55))
                                : null,
                            onTap: () {
                              ref.read(playerViewModelProvider.notifier).skipToQueueItem(index);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// ライブラリタブ（検索機能統合 + カテゴリ表示）
// ==============================================================================

enum LibraryCategory { songs, artists, albums, playlists }

class _LibraryTab extends ConsumerStatefulWidget {
  const _LibraryTab();

  @override
  ConsumerState<_LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends ConsumerState<_LibraryTab> with TickerProviderStateMixin {
  bool _isSearching = false;
  late TextEditingController _searchController;
  Timer? _debounceTimer;
  late TabController _tabController;
  String _sortBy = 'title_asc'; // デフォルトはタイトル昇順
  
  // カテゴリの表示設定
  Map<LibraryCategory, bool> _categoryVisibility = {
    LibraryCategory.songs: true,
    LibraryCategory.artists: true,
    LibraryCategory.albums: true,
    LibraryCategory.playlists: true,
  };
  
  List<LibraryCategory> _visibleCategories = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadCategoryPreferences();
  }
  
  Future<void> _loadCategoryPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _categoryVisibility = {
        LibraryCategory.songs: prefs.getBool('show_songs') ?? true,
        LibraryCategory.artists: prefs.getBool('show_artists') ?? true,
        LibraryCategory.albums: prefs.getBool('show_albums') ?? true,
        LibraryCategory.playlists: prefs.getBool('show_playlists') ?? true,
      };
      _updateVisibleCategories();
      _tabController = TabController(length: _visibleCategories.length, vsync: this);
      _tabController.addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() {
            // カテゴリ変更時の処理
          });
        }
      });
    });
  }
  
  void _updateVisibleCategories() {
    _visibleCategories = LibraryCategory.values
        .where((category) => _categoryVisibility[category] == true)
        .toList();
    if (_visibleCategories.isEmpty) {
      _visibleCategories = [LibraryCategory.songs];
    }
  }
  
  Future<void> _saveCategoryPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_songs', _categoryVisibility[LibraryCategory.songs]!);
    await prefs.setBool('show_artists', _categoryVisibility[LibraryCategory.artists]!);
    await prefs.setBool('show_albums', _categoryVisibility[LibraryCategory.albums]!);
    await prefs.setBool('show_playlists', _categoryVisibility[LibraryCategory.playlists]!);
  }
  
  void _showEditCategoriesDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1C1C1E),
            title: const Text('カテゴリを編集', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('曲', style: TextStyle(color: Colors.white)),
                  value: _categoryVisibility[LibraryCategory.songs],
                  activeColor: const Color(0xFFFF2D55),
                  onChanged: (value) {
                    setDialogState(() {
                      _categoryVisibility[LibraryCategory.songs] = value ?? true;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('アーティスト', style: TextStyle(color: Colors.white)),
                  value: _categoryVisibility[LibraryCategory.artists],
                  activeColor: const Color(0xFFFF2D55),
                  onChanged: (value) {
                    setDialogState(() {
                      _categoryVisibility[LibraryCategory.artists] = value ?? true;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('アルバム', style: TextStyle(color: Colors.white)),
                  value: _categoryVisibility[LibraryCategory.albums],
                  activeColor: const Color(0xFFFF2D55),
                  onChanged: (value) {
                    setDialogState(() {
                      _categoryVisibility[LibraryCategory.albums] = value ?? true;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('プレイリスト', style: TextStyle(color: Colors.white)),
                  value: _categoryVisibility[LibraryCategory.playlists],
                  activeColor: const Color(0xFFFF2D55),
                  onChanged: (value) {
                    setDialogState(() {
                      _categoryVisibility[LibraryCategory.playlists] = value ?? true;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _updateVisibleCategories();
                    _saveCategoryPreferences();
                    
                    // TabControllerを安全に再作成
                    try {
                      _tabController.dispose();
                    } catch (e) {
                      debugPrint('Error disposing TabController: $e');
                    }
                    
                    _tabController = TabController(length: _visibleCategories.length, vsync: this);
                    _tabController.addListener(() {
                      if (!_tabController.indexIsChanging) {
                        setState(() {
                          // カテゴリ変更時の処理
                        });
                      }
                    });
                  });
                },
                child: const Text('保存', style: TextStyle(color: Color(0xFFFF2D55))),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    _debounceTimer?.cancel();
    if (query.isEmpty) {
      try {
        ref.read(searchViewModelProvider.notifier).clearSearch();
      } catch (e) {
        debugPrint('Error clearing search in _performSearch: $e');
      }
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      try {
        ref.read(searchViewModelProvider.notifier).search(query);
      } catch (e) {
        debugPrint('Error performing search: $e');
      }
    });
  }

  List<Song> _sortSongs(List<Song> songs) {
    final sortedSongs = List<Song>.from(songs);
    
    switch (_sortBy) {
      case 'title_asc':
        sortedSongs.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'title_desc':
        sortedSongs.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'artist_asc':
        sortedSongs.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case 'artist_desc':
        sortedSongs.sort((a, b) => b.artist.compareTo(a.artist));
        break;
      case 'duration_asc':
        sortedSongs.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case 'duration_desc':
        sortedSongs.sort((a, b) => b.duration.compareTo(a.duration));
        break;
    }
    
    return sortedSongs;
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryViewModelProvider);
    final searchState = ref.watch(searchViewModelProvider);
    final songs = libraryState.songs;

    if (libraryState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (libraryState.error != null) {
      return Scaffold(
        body: Center(child: Text('Error: ${libraryState.error}')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '曲名・アーティスト・アルバム',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: _performSearch,
              )
            : const Text('ライブラリ'),
        elevation: 0,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showEditCategoriesDialog,
              tooltip: 'カテゴリを編集',
            ),
          if (!_isSearching)
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              onSelected: (value) {
                try {
                  setState(() {
                    _sortBy = value;
                  });
                } catch (e) {
                  debugPrint('Error changing sort order: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('並び順の変更に失敗しました: $e')),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'title_asc',
                  child: Row(
                    children: [
                      if (_sortBy == 'title_asc') const Icon(Icons.check, size: 18),
                      if (_sortBy == 'title_asc') const SizedBox(width: 8),
                      const Text('タイトル (昇順)'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'title_desc',
                  child: Row(
                    children: [
                      if (_sortBy == 'title_desc') const Icon(Icons.check, size: 18),
                      if (_sortBy == 'title_desc') const SizedBox(width: 8),
                      const Text('タイトル (降順)'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'artist_asc',
                  child: Row(
                    children: [
                      if (_sortBy == 'artist_asc') const Icon(Icons.check, size: 18),
                      if (_sortBy == 'artist_asc') const SizedBox(width: 8),
                      const Text('アーティスト (昇順)'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'artist_desc',
                  child: Row(
                    children: [
                      if (_sortBy == 'artist_desc') const Icon(Icons.check, size: 18),
                      if (_sortBy == 'artist_desc') const SizedBox(width: 8),
                      const Text('アーティスト (降順)'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'duration_asc',
                  child: Row(
                    children: [
                      if (_sortBy == 'duration_asc') const Icon(Icons.check, size: 18),
                      if (_sortBy == 'duration_asc') const SizedBox(width: 8),
                      const Text('再生時間 (短い順)'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'duration_desc',
                  child: Row(
                    children: [
                      if (_sortBy == 'duration_desc') const Icon(Icons.check, size: 18),
                      if (_sortBy == 'duration_desc') const SizedBox(width: 8),
                      const Text('再生時間 (長い順)'),
                    ],
                  ),
                ),
              ],
            ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  try {
                    ref.read(searchViewModelProvider.notifier).clearSearch();
                  } catch (e) {
                    debugPrint('Error clearing search: $e');
                  }
                }
              });
            },
          ),
        ],
      ),
      body: _isSearching
          ? _buildSearchResults(searchState)
          : _visibleCategories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFFFF2D55),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFFFF2D55),
                      isScrollable: _visibleCategories.length > 3,
                      tabs: _visibleCategories.map((category) {
                        switch (category) {
                          case LibraryCategory.songs:
                            return const Tab(text: '曲');
                          case LibraryCategory.artists:
                            return const Tab(text: 'アーティスト');
                          case LibraryCategory.albums:
                            return const Tab(text: 'アルバム');
                          case LibraryCategory.playlists:
                            return const Tab(text: 'プレイリスト');
                        }
                      }).toList(),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: _visibleCategories.map((category) {
                          switch (category) {
                            case LibraryCategory.songs:
                              return _buildSongsList(_sortSongs(songs));
                            case LibraryCategory.artists:
                              return _buildArtistsList(_sortSongs(songs));
                            case LibraryCategory.albums:
                              return _buildAlbumsList(_sortSongs(songs));
                            case LibraryCategory.playlists:
                              return _buildPlaylistsList();
                          }
                        }).toList(),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSongsList(List<Song> songs) {
    if (songs.isEmpty) {
      return const Center(child: Text('曲がありません'));
    }

    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(4),
            ),
            child: song.artworkUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: song.artworkUrl!.startsWith('http')
                        ? Image.network(song.artworkUrl!, fit: BoxFit.cover)
                        : Image.file(File(song.artworkUrl!), fit: BoxFit.cover),
                  )
                : const Icon(Icons.music_note),
          ),
          title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            ref
                .read(playerViewModelProvider.notifier)
                .setQueue(songs, startIndex: index);
          },
          onLongPress: () {
            _showSongContextMenu(context, song, songs, index);
          },
        );
      },
    );
  }

  Widget _buildArtistsList(List<Song> songs) {
    // アーティストでグループ化
    final Map<String, List<Song>> artistMap = {};
    for (final song in songs) {
      artistMap.putIfAbsent(song.artist, () => []).add(song);
    }
    
    final artists = artistMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (artists.isEmpty) {
      return const Center(child: Text('アーティストがありません'));
    }

    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade800,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          title: Text(artist.key, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${artist.value.length}曲'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _CategoryDetailScreen(
                  type: CategoryDetailType.artist,
                  title: artist.key,
                  songs: artist.value,
                  subtitle: '${artist.value.length}曲',
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAlbumsList(List<Song> songs) {
    // アルバムでグループ化（アーティストも考慮）
    final Map<String, List<Song>> albumMap = {};
    for (final song in songs) {
      final key = '${song.album}_${song.artist}';
      albumMap.putIfAbsent(key, () => []).add(song);
    }
    
    final albums = albumMap.entries.toList()
      ..sort((a, b) => a.value.first.album.compareTo(b.value.first.album));

    if (albums.isEmpty) {
      return const Center(child: Text('アルバムがありません'));
    }

    return ListView.builder(
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        final firstSong = album.value.first;
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(4),
            ),
            child: firstSong.artworkUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: firstSong.artworkUrl!.startsWith('http')
                        ? Image.network(firstSong.artworkUrl!, fit: BoxFit.cover)
                        : Image.file(File(firstSong.artworkUrl!), fit: BoxFit.cover),
                  )
                : const Icon(Icons.album),
          ),
          title: Text(firstSong.album, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${firstSong.artist} • ${album.value.length}曲',
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _CategoryDetailScreen(
                  type: CategoryDetailType.album,
                  title: firstSong.album,
                  songs: album.value,
                  subtitle: '${firstSong.artist} • ${album.value.length}曲',
                  artworkUrl: firstSong.artworkUrl,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaylistsList() {
    final playlists = ref.watch(playlistViewModelProvider).playlists;

    if (playlists.isEmpty) {
      return const Center(child: Text('プレイリストがありません'));
    }

    return ListView.builder(
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.queue_music, color: Colors.white),
          ),
          title: Text(playlist.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${playlist.songIds.length}曲'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // プレイリストの曲を取得
            final allSongs = ref.read(libraryViewModelProvider).songs;
            final playlistSongs = playlist.songIds
                .map((id) => allSongs.firstWhere(
                      (song) => song.id == id,
                      orElse: () => allSongs.first,
                    ))
                .toList();
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _CategoryDetailScreen(
                  type: CategoryDetailType.playlist,
                  title: playlist.name,
                  songs: playlistSongs,
                  subtitle: '${playlist.songIds.length}曲',
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSongContextMenu(BuildContext context, Song song, List<Song> allSongs, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.white),
              title: const Text('再生', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ref.read(playerViewModelProvider.notifier).setQueue(allSongs, startIndex: index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_play, color: Colors.white),
              title: const Text('次に再生', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ref.read(playerViewModelProvider.notifier).addToQueue(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('「${song.title}」を次に再生に追加しました')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text('プレイリストに追加', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showAddToPlaylistDialog(context, song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('メタデータを編集', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showEditMetadataDialog(context, song);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, Song song) {
    final playlists = ref.read(playlistViewModelProvider).playlists;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('プレイリストに追加', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              // 新規作成オプション
              ListTile(
                leading: const Icon(Icons.add_circle, color: Color(0xFFFF2D55)),
                title: const Text('新規作成...', style: TextStyle(color: Color(0xFFFF2D55), fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _showCreatePlaylistDialogNoRef(context, song);
                },
              ),
              if (playlists.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'または既存プレイリストから選択:',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
              ...playlists.map((playlist) {
                return ListTile(
                  title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(playlistViewModelProvider.notifier).addSongToPlaylist(
                      playlist.id,
                      song.id,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('「${playlist.name}」に追加しました')),
                    );
                  },
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialogNoRef(BuildContext context, Song song) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('プレイリストを作成', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'プレイリスト名を入力',
            hintStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFF2D55)),
            ),
          ),
          cursorColor: const Color(0xFFFF2D55),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                // プレイリスト作成と曲追加
                ref.read(playlistViewModelProvider.notifier).createPlaylist(nameController.text).then((playlistId) {
                  if (playlistId != null) {
                    ref.read(playlistViewModelProvider.notifier).addSongToPlaylist(playlistId, song.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('「${nameController.text}」を作成し、曲を追加しました')),
                    );
                  }
                });
              }
            },
            child: const Text('作成'),
          ),
        ],
      ),
    );
  }

  void _showEditMetadataDialog(BuildContext context, Song song) {
    final titleController = TextEditingController(text: song.title);
    final artistController = TextEditingController(text: song.artist);
    final albumController = TextEditingController(text: song.album);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('メタデータを編集', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'タイトル',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF2D55)),
                  ),
                ),
                cursorColor: const Color(0xFFFF2D55),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: artistController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'アーティスト',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF2D55)),
                  ),
                ),
                cursorColor: const Color(0xFFFF2D55),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: albumController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'アルバム',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF2D55)),
                  ),
                ),
                cursorColor: const Color(0xFFFF2D55),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('メタデータを保存しました')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchState searchState) {
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.query.isEmpty) {
      return Center(
        child: Text(
          '曲名、アーティスト、アルバムで検索',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    return ListView(
      children: [
        // 曲の検索結果
        if (searchState.songResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '曲',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFFF2D55),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...searchState.songResults.map((song) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: song.artworkUrl != null
                      ? (song.artworkUrl!.startsWith('http')
                          ? Image.network(song.artworkUrl!, fit: BoxFit.cover)
                          : Image.file(File(song.artworkUrl!),
                              fit: BoxFit.cover))
                      : const Icon(Icons.music_note, size: 20),
                ),
                title: Text(song.title),
                subtitle: Text(song.artist),
                onTap: () {
                  ref
                      .read(playerViewModelProvider.notifier)
                      .setQueue([song], startIndex: 0);
                },
                onLongPress: () {
                  _showSongContextMenu(context, song, searchState.songResults, 
                      searchState.songResults.indexOf(song));
                },
              )),
        ],
        // アーティストの検索結果
        if (searchState.artistResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'アーティスト',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFFF2D55),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...searchState.artistResults.map((artist) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade800,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(artist.name),
                subtitle: Text('${artist.songIds.length}曲'),
                onTap: () {
                  // アーティスト詳細画面へ遷移（未実装）
                },
              )),
        ],
        // アルバムの検索結果
        if (searchState.albumResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'アルバム',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFFF2D55),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...searchState.albumResults.map((album) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.album, size: 20),
                ),
                title: Text(album.name),
                subtitle: Text(album.artist),
                onTap: () {
                  // アルバム詳細画面へ遷移（未実装）
                },
              )),
        ],
        // プレイリストの検索結果
        if (searchState.playlistResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'プレイリスト',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFFF2D55),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...searchState.playlistResults.map((playlist) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.queue_music, size: 20),
                ),
                title: Text(playlist.name),
                subtitle: Text('${playlist.songIds.length}曲'),
                onTap: () {
                  // プレイリスト詳細画面へ遷移（未実装）
                },
              )),
        ],
        if (searchState.songResults.isEmpty &&
            searchState.artistResults.isEmpty &&
            searchState.albumResults.isEmpty &&
            searchState.playlistResults.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('検索結果がありません'),
            ),
          ),
      ],
    );
  }
}

// ==============================================================================
// 設定タブ
// ==============================================================================

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  /// クリップボードから文字列を取得
  Future<String?> _getClipboardText() async {
    try {
      final data = await Clipboard.getData('text/plain');
      return data?.text;
    } catch (e) {
      debugPrint('Clipboard error: $e');
      return null;
    }
  }

  /// YouTubeのURLであるか検証
  bool _isYouTubeUrl(String url) {
    final youtubePatterns = [
      RegExp(r'(?:https?:\/\/)?(?:www\.)?youtube\.com'),
      RegExp(r'(?:https?:\/\/)?(?:www\.)?youtu\.be'),
    ];
    return youtubePatterns.any((pattern) => pattern.hasMatch(url));
  }

  /// YouTube動画情報を取得して確認ダイアログを表示
  void _showYouTubeConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    String url,
  ) async {
    debugPrint('[YouTube] 動画情報取得開始: $url');
    
    // 動画情報を取得
    final youtubeViewModel = ref.read(youtubeViewModelProvider.notifier);
    final videoInfo = await youtubeViewModel.getVideoInfo(url);
    
    String videoTitle = videoInfo?.title ?? 'タイトル取得失敗';
    String channelName = videoInfo?.channelName ?? '不明なチャンネル';
    
    if (videoInfo != null) {
      debugPrint('[YouTube] 動画タイトル取得成功: $videoTitle');
      debugPrint('[YouTube] チャンネル取得成功: $channelName');
    } else {
      debugPrint('[YouTube] 動画情報取得エラー');
    }
    
    final settings = ref.read(settingsViewModelProvider);
    final outputFormat = settings.youtubeSettings.outputFormat;
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('音声ファイル化の確認'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              videoTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'チャンネル: $channelName',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Text(
              '出力形式: $outputFormat',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text('この動画から音声をダウンロードしますか？'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startYouTubeDownload(context, ref, url, videoTitle);
            },
            child: const Text('ダウンロード'),
          ),
        ],
      ),
    );
  }

  /// YouTube音声ダウンロード処理を開始
  void _startYouTubeDownload(BuildContext context, WidgetRef ref, String url, String videoTitle) {
    final settings = ref.read(settingsViewModelProvider);
    final libraryNotifier = ref.read(libraryViewModelProvider.notifier);
    
    debugPrint('[YouTube] ダウンロード開始: $videoTitle ($url)');
    debugPrint('[YouTube] 出力形式: ${settings.youtubeSettings.outputFormat}');
    debugPrint('[YouTube] ビットレート: ${settings.youtubeSettings.bitrate} kbps');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('「$videoTitle」のダウンロードを開始しました...'),
        duration: const Duration(seconds: 2),
      ),
    );

    // バックグラウンドで処理を実行
    ref.read(youtubeViewModelProvider.notifier).downloadFromYouTube(
      url,
      settings.youtubeSettings.outputFormat,
      '', // outputPath
      settings.youtubeSettings.bitrate,
    ).then((song) {
      debugPrint('[YouTube] ダウンロード処理完了: ${song != null ? '成功' : '失敗'}');
      
      if (song != null) {
        // ライブラリを更新
        libraryNotifier.refreshLibrary();
        
        debugPrint('[YouTube] 保存先確認: ${song.localPath}');
        // ファイル存在確認
        try {
          if (song.localPath != null) {
            final file = File(song.localPath!);
            final exists = file.existsSync();
            debugPrint('[YouTube] ファイル存在確認: $exists');
            
            if (exists) {
              final fileSize = file.lengthSync();
              debugPrint('[YouTube] ファイルサイズ: ${fileSize} bytes');
              debugPrint('[YouTube] ファイルパス: ${file.path}');
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('「$videoTitle」のダウンロードが完了しました！'),
                  duration: const Duration(seconds: 3),
                ),
              );
            } else {
              debugPrint('[YouTube] エラー: ファイルが保存されていません');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ダウンロードは完了しましたが、ファイルが見つかりません'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          } else {
            debugPrint('[YouTube] エラー: ファイルパスが設定されていません');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ダウンロードは完了しましたが、ファイルパスが不明です'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          debugPrint('[YouTube] ファイル確認エラー: $e');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「$videoTitle」のダウンロードに失敗しました'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }).catchError((error) {
      debugPrint('[YouTube] ダウンロードエラー: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ダウンロードエラー: $error'),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  /// ローカルファイル選択と読込（複数ファイル対応）
  void _importLocalAudioFiles(BuildContext context, WidgetRef ref) async {
    debugPrint('[LocalFile] ファイル選択開始');
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'flac', 'wav', 'aiff', 'lrc'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        debugPrint('[LocalFile] 選択されたファイル数: ${result.files.length}');
        
        final audioFiles = <PlatformFile>[];
        final lrcFiles = <PlatformFile>[];
        
        // ファイルを音声ファイルと歌詞ファイルに分類
        for (final file in result.files) {
          final extension = file.extension?.toLowerCase();
          debugPrint('[LocalFile] ファイル: ${file.name} (拡張子: $extension)');
          
          if (extension == 'lrc') {
            lrcFiles.add(file);
          } else if (['mp3', 'm4a', 'flac', 'wav', 'aiff'].contains(extension)) {
            audioFiles.add(file);
          }
        }
        
        debugPrint('[LocalFile] 音声ファイル: ${audioFiles.length}件');
        debugPrint('[LocalFile] 歌詞ファイル: ${lrcFiles.length}件');
        
        if (audioFiles.isEmpty && lrcFiles.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('対応するファイルが選択されていません'),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${audioFiles.length + lrcFiles.length}件のファイルを読込中...'),
            duration: const Duration(seconds: 2),
          ),
        );

        // 音声ファイルをアプリ専用ディレクトリへコピー（Android 11+ 対応）
        final appDocDir = await getApplicationDocumentsDirectory();
        final musicDir = Directory('${appDocDir.path}/Music');
        
        if (!await musicDir.exists()) {
          await musicDir.create(recursive: true);
        }

        for (final audioFile in audioFiles) {
          final sourceFilePath = audioFile.path;
          if (sourceFilePath != null) {
            debugPrint('[LocalFile] 音声ファイル処理: ${audioFile.name}');
            
            // ファイル存在確認
            final sourceFile = File(sourceFilePath);
            if (sourceFile.existsSync()) {
              final fileSize = sourceFile.lengthSync();
              debugPrint('[LocalFile] ファイルサイズ: ${fileSize} bytes');
              
              // アプリ専用ディレクトリへのコピーを試みる
              try {
                final destinationPath = '${musicDir.path}/${audioFile.name}';
                if (!File(destinationPath).existsSync()) {
                  await sourceFile.copy(destinationPath);
                  debugPrint('[LocalFile] ファイルコピー成功: $destinationPath');
                } else {
                  debugPrint('[LocalFile] ファイルをスキップ（既存）: $destinationPath');
                }
              } catch (e) {
                debugPrint('[LocalFile] ファイルコピーエラー: $e');
                // エラーでも処理を続行
              }
            } else {
              debugPrint('[LocalFile] エラー: ファイルが存在しません: $sourceFilePath');
            }
          }
        }

        // ライブラリを更新
        final libraryNotifier = ref.read(libraryViewModelProvider.notifier);
        await libraryNotifier.refreshLibrary();
        debugPrint('[LocalFile] ライブラリ更新完了');
        
        // 歌詞ファイルの処理と自動紐付け
        for (final lrcFile in lrcFiles) {
          final filePath = lrcFile.path;
          if (filePath != null) {
            debugPrint('[LocalFile] 歌詞ファイル処理: ${lrcFile.name}');
            
            // 同名の音声ファイルを検索
            final baseName = lrcFile.name.replaceAll('.lrc', '');
            final matchingAudio = audioFiles.where((audio) => 
              audio.name.startsWith(baseName)
            ).toList();
            
            if (matchingAudio.isNotEmpty) {
              debugPrint('[LocalFile] 歌詞ファイル自動紐付け成功: ${lrcFile.name} -> ${matchingAudio.first.name}');
            } else {
              debugPrint('[LocalFile] 歌詞ファイル紐付け対象なし: ${lrcFile.name}');
            }
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${audioFiles.length}件の音声ファイルをインポート完了'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('[LocalFile] エラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ファイル選択エラー: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  /// フォルダ読み込み機能
  void _importFolderFiles(BuildContext context, WidgetRef ref) async {
    debugPrint('[Folder] フォルダ選択開始');
    
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      
      if (result != null) {
        debugPrint('[Folder] 選択されたフォルダ: $result');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('フォルダをスキャン中...'),
            duration: Duration(seconds: 2),
          ),
        );
        
        final directory = Directory(result);
        if (!directory.existsSync()) {
          debugPrint('[Folder] エラー: フォルダが存在しません');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('選択されたフォルダが存在しません'),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
        
        // 再帰的にファイルをスキャン
        final audioFiles = <File>[];
        final lrcFiles = <File>[];
        
        try {
          await for (final entity in directory.list(recursive: true)) {
            if (entity is File) {
              final extension = entity.path.split('.').last.toLowerCase();
              
              if (['mp3', 'm4a', 'flac', 'wav', 'aiff'].contains(extension)) {
                audioFiles.add(entity);
                debugPrint('[Folder] 音声ファイル発見: ${entity.path}');
              } else if (extension == 'lrc') {
                lrcFiles.add(entity);
                debugPrint('[Folder] 歌詞ファイル発見: ${entity.path}');
              }
            }
          }
        } catch (e) {
          // Scoped Storage によりアクセスできない場合
          debugPrint('[Folder] ディレクトリスキャンエラー（権限不足）: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('このフォルダへのアクセスが制限されています。ファイルのインポートをお使いください。'),
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }
        
        debugPrint('[Folder] スキャン完了 - 音声: ${audioFiles.length}件, 歌詞: ${lrcFiles.length}件');
        
        if (audioFiles.isEmpty && lrcFiles.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('対応するファイルが見つかりませんでした'),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }

        // アプリ専用ディレクトリにコピー（Android 11+ 対応）
        final appDocDir = await getApplicationDocumentsDirectory();
        final musicDir = Directory('${appDocDir.path}/Music');
        
        if (!await musicDir.exists()) {
          await musicDir.create(recursive: true);
        }

        // 音声ファイルをコピーしてライブラリに追加
        int copiedCount = 0;
        for (final audioFile in audioFiles) {
          try {
            final fileName = audioFile.path.split('/').last;
            final destinationPath = '${musicDir.path}/$fileName';
            
            // 既に存在する場合はスキップ
            if (File(destinationPath).existsSync()) {
              debugPrint('[Folder] ファイルをスキップ（既存）: $destinationPath');
              copiedCount++;
              continue;
            }

            await audioFile.copy(destinationPath);
            copiedCount++;
            debugPrint('[Folder] ファイルコピー成功: $destinationPath');
          } catch (e) {
            debugPrint('[Folder] ファイルコピーエラー: $e');
          }
        }
        
        // ライブラリを更新
        final libraryNotifier = ref.read(libraryViewModelProvider.notifier);
        await libraryNotifier.refreshLibrary();
        debugPrint('[Folder] ライブラリ更新完了');
        
        // 歌詞ファイルの処理と自動紐付け
        for (final lrcFile in lrcFiles) {
          final baseName = lrcFile.path.replaceAll('.lrc', '');
          final matchingAudio = audioFiles.where((audio) => 
            audio.path.startsWith(baseName)
          ).toList();
          
          if (matchingAudio.isNotEmpty) {
            debugPrint('[Folder] 歌詞ファイル自動紐付け成功: ${lrcFile.path} -> ${matchingAudio.first.path}');
          } else {
            debugPrint('[Folder] 歌詞ファイル紐付け対象なし: ${lrcFile.path}');
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${copiedCount}件の音声ファイルをインポート完了'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('[Folder] エラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('フォルダ読み込みエラー: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Android実機でのストレージ権限とディレクトリ確認
  void _checkStoragePermissions() {
    debugPrint('[Storage] 権限とディレクトリの確認を開始');
    
    try {
      // 外部ストレージの状態確認
      if (Platform.isAndroid) {
        debugPrint('[Storage] Android端末での実行を確認');
        
        // アプリのドキュメントディレクトリ確認
        final appDir = Directory('/data/data/com.example.flutter_application_4');
        if (appDir.existsSync()) {
          debugPrint('[Storage] アプリディレクトリ存在確認: OK');
        } else {
          debugPrint('[Storage] 警告: アプリディレクトリが見つかりません');
        }
        
        // 外部ストレージ（Music/Downloads）の確認
        final musicDir = Directory('/storage/emulated/0/Music');
        final downloadsDir = Directory('/storage/emulated/0/Download');
        
        debugPrint('[Storage] Music ディレクトリ存在: ${musicDir.existsSync()}');
        debugPrint('[Storage] Downloads ディレクトリ存在: ${downloadsDir.existsSync()}');
        
        // 推奨保存先の確認
        if (musicDir.existsSync()) {
          debugPrint('[Storage] 推奨保存先: ${musicDir.path}');
        } else if (downloadsDir.existsSync()) {
          debugPrint('[Storage] 代替保存先: ${downloadsDir.path}');
        } else {
          debugPrint('[Storage] 警告: 外部ストレージディレクトリが見つかりません');
        }
      }
    } catch (e) {
      debugPrint('[Storage] 権限確認エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider);
    final youtubeState = ref.watch(youtubeViewModelProvider);
    
    // Android実機でのストレージ権限確認
    _checkStoragePermissions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // ============================================================================
          // YouTube音声抽出セクション
          // ============================================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'YouTube音声抽出',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFFF2D55),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // YouTube音声抽出ボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: youtubeState.isLoading
                  ? null
                  : () async {
                      final clipboardText = await _getClipboardText();
                      if (!context.mounted) return;

                      if (clipboardText == null || clipboardText.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('クリップボードが空です'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      if (!_isYouTubeUrl(clipboardText)) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('エラー'),
                            content: const Text(
                              'クリップボードにYouTubeのURLが見つかりません',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('閉じる'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      _showYouTubeConfirmDialog(context, ref, clipboardText);
                    },
              icon: youtubeState.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: const Text('YouTubeから音声ファイル化'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2D55),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                disabledBackgroundColor: Colors.grey.shade700,
              ),
            ),
          ),

          if (youtubeState.downloadProgress != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                youtubeState.downloadProgress!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

          if (youtubeState.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withOpacity(0.3),
                  border: Border.all(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  youtubeState.error!,
                  style: TextStyle(color: Colors.red.shade300),
                ),
              ),
            ),

          // 出力形式選択
          ListTile(
            title: const Text('出力形式'),
            subtitle: Text(settings.youtubeSettings.outputFormat),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('出力形式を選択'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children: ['M4A', 'MP3', 'FLAC'].map((format) {
                        return ListTile(
                          title: Text(format),
                          trailing: settings.youtubeSettings.outputFormat == format
                              ? const Icon(Icons.check, color: Color(0xFFFF2D55))
                              : null,
                          onTap: () {
                            ref
                                .read(settingsViewModelProvider.notifier)
                                .updateYouTubeSettings(
                                  settings.youtubeSettings.copyWith(
                                    outputFormat: format,
                                  ),
                                );
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),

          // ビットレート表示
          const ListTile(
            title: Text('ビットレート'),
            subtitle: Text('320 kbps'),
          ),

          // サンプリングレート表示
          const ListTile(
            title: Text('サンプリングレート'),
            subtitle: Text('44.1 kHz'),
          ),

          const Divider(),

          // ============================================================================
          // ローカルファイル設定セクション
          // ============================================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'ローカルファイル',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFFF2D55),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ローカルファイル読込ボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _importLocalAudioFiles(context, ref),
              icon: const Icon(Icons.folder_open),
              label: const Text('ファイルのインポート'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2D55),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          // フォルダ読み込みボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _importFolderFiles(context, ref),
              icon: const Icon(Icons.folder),
              label: const Text('フォルダのインポート'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2D55),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // ライブラリクリアボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('ライブラリをクリア'),
                    content: const Text(
                      'ローカルの全てのファイルを削除します。\nこの操作は元に戻せません。\n本当に削除しますか？',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final appDocDir = await getApplicationDocumentsDirectory();
                          final musicDir = Directory('${appDocDir.path}/Music');
                          
                          if (await musicDir.exists()) {
                            await musicDir.delete(recursive: true);
                            debugPrint('[Settings] ライブラリクリア完了');
                            
                            // ライブラリを更新
                            final libraryNotifier = ref.read(libraryViewModelProvider.notifier);
                            await libraryNotifier.refreshLibrary();
                            
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ライブラリをクリアしました'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: const Text('削除', style: TextStyle(color: Color(0xFFFF2D55))),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('ライブラリをクリア'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // 重複検出 スイッチ
          ListTile(
            title: const Text('重複検出'),
            subtitle: const Text('古い方を削除'),
            trailing: Switch(
              value: settings.localFileSettings.duplicateDetection,
              onChanged: (value) {
                ref.read(settingsViewModelProvider.notifier).updateLocalFileSettings(
                  settings.localFileSettings.copyWith(
                    duplicateDetection: value,
                  ),
                );
              },
            ),
          ),
          
          const Divider(),

          // ============================================================================
          // 対応フォーマット表示セクション
          // ============================================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '対応フォーマット',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFFF2D55),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 音声フォーマット
          ListTile(
            title: const Text('音声フォーマット'),
            subtitle: const Text('MP3, M4A, FLAC, WAV, AIFF'),
            leading: const Icon(Icons.audiotrack, color: Color(0xFFFF2D55)),
          ),

          // 歌詞フォーマット
          ListTile(
            title: const Text('歌詞フォーマット'),
            subtitle: const Text('LRC (時間同期型歌詞ファイル)'),
            leading: const Icon(Icons.lyrics, color: Color(0xFFFF2D55)),
          ),

          // 音質対応
          ListTile(
            title: const Text('対応音質'),
            subtitle: const Text('ロスレス音質、Dolby Atmos空間オーディオ'),
            leading: const Icon(Icons.high_quality, color: Color(0xFFFF2D55)),
          ),

          const Divider(),

          // ============================================================================
          // 歌詞表示設定セクション
          // ============================================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '歌詞表示設定',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFFF2D55),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 歌詞表示ON/OFF
          SwitchListTile(
            title: const Text('歌詞を表示'),
            subtitle: const Text('LRCファイルがある場合に歌詞を表示'),
            value: true, // デフォルトでON
            activeColor: const Color(0xFFFF2D55),
            onChanged: (value) {
              // TODO: SharedPreferencesで保存
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(value ? '歌詞表示をオンにしました' : '歌詞表示をオフにしました')),
              );
            },
          ),

          // フォントサイズ設定
          ListTile(
            title: const Text('フォントサイズ'),
            subtitle: const Text('現在行: 18px / その他: 14px'),
            leading: const Icon(Icons.format_size),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1C1C1E),
                  title: const Text('フォントサイズ', style: TextStyle(color: Colors.white)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '現在行のフォントサイズ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Slider(
                        value: 18,
                        min: 14,
                        max: 24,
                        divisions: 10,
                        label: '18px',
                        activeColor: const Color(0xFFFF2D55),
                        onChanged: (value) {
                          // TODO: 設定を保存
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'その他の行のフォントサイズ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Slider(
                        value: 14,
                        min: 10,
                        max: 18,
                        divisions: 8,
                        label: '14px',
                        activeColor: const Color(0xFFFF2D55),
                        onChanged: (value) {
                          // TODO: 設定を保存
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('保存', style: TextStyle(color: Color(0xFFFF2D55))),
                    ),
                  ],
                ),
              );
            },
          ),

          // 表示行数設定
          ListTile(
            title: const Text('表示行数'),
            subtitle: const Text('前後に表示する歌詞の行数: 5行'),
            leading: const Icon(Icons.format_list_numbered),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1C1C1E),
                  title: const Text('表示行数', style: TextStyle(color: Colors.white)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '現在行の前後に表示する行数',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Slider(
                        value: 5,
                        min: 2,
                        max: 10,
                        divisions: 8,
                        label: '5行',
                        activeColor: const Color(0xFFFF2D55),
                        onChanged: (value) {
                          // TODO: 設定を保存
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('保存', style: TextStyle(color: Color(0xFFFF2D55))),
                    ),
                  ],
                ),
              );
            },
          ),

          // 強調表示設定
          SwitchListTile(
            title: const Text('現在行を強調表示'),
            subtitle: const Text('ピンク色でハイライト、大きく太字で表示'),
            value: true, // デフォルトでON
            activeColor: const Color(0xFFFF2D55),
            onChanged: (value) {
              // TODO: SharedPreferencesで保存
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(value ? '強調表示をオンにしました' : '強調表示をオフにしました')),
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ==============================================================================
// カスタム Seek Bar（スムーズなドラッグ操作用）
// ==============================================================================

class _SeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const _SeekBar({
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final value = _dragValue ?? widget.position.inSeconds.toDouble();
    final max = widget.duration.inSeconds.toDouble();

    return Slider(
      value: value.clamp(0.0, max),
      max: max > 0 ? max : 1.0,
      onChangeStart: (val) {
        setState(() {
          _dragValue = val;
        });
      },
      onChanged: (val) {
        setState(() {
          _dragValue = val;
        });
      },
      onChangeEnd: (val) {
        widget.onSeek(Duration(seconds: val.toInt()));
        setState(() {
          _dragValue = null;
        });
      },
    );
  }
}

// ==============================================================================
// カテゴリ詳細画面（アーティスト/アルバム/プレイリスト → 曲一覧）
// ==============================================================================

enum CategoryDetailType { artist, album, playlist }

class _CategoryDetailScreen extends ConsumerWidget {
  final CategoryDetailType type;
  final String title;
  final List<Song> songs;
  final String? subtitle;
  final String? artworkUrl;

  const _CategoryDetailScreen({
    required this.type,
    required this.title,
    required this.songs,
    this.subtitle,
    this.artworkUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // ヘッダー部分（アートワークとタイトル）
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF1C1C1E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // アートワーク
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: type == CategoryDetailType.artist
                            ? BorderRadius.circular(90)
                            : BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: artworkUrl != null
                          ? ClipRRect(
                              borderRadius: type == CategoryDetailType.artist
                                  ? BorderRadius.circular(90)
                                  : BorderRadius.circular(8),
                              child: artworkUrl!.startsWith('http')
                                  ? Image.network(artworkUrl!, fit: BoxFit.cover)
                                  : Image.file(File(artworkUrl!), fit: BoxFit.cover),
                            )
                          : Icon(
                              type == CategoryDetailType.artist
                                  ? Icons.person
                                  : type == CategoryDetailType.album
                                      ? Icons.album
                                      : Icons.queue_music,
                              size: 80,
                              color: Colors.white,
                            ),
                    ),
                    const SizedBox(height: 16),
                    // サブタイトル
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          subtitle!,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // アクションボタン
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 全曲再生ボタン
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (songs.isNotEmpty) {
                          ref.read(playerViewModelProvider.notifier).setQueue(songs, startIndex: 0);
                        }
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text(
                        '再生',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2D55),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // シャッフル再生ボタン
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (songs.isNotEmpty) {
                          ref.read(playerViewModelProvider.notifier).setQueue(songs, startIndex: 0);
                          ref.read(playerViewModelProvider.notifier).toggleShuffle();
                        }
                      },
                      icon: const Icon(Icons.shuffle, color: Colors.white),
                      label: const Text(
                        'シャッフル',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 曲一覧
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = songs[index];
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: song.artworkUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: song.artworkUrl!.startsWith('http')
                                ? Image.network(song.artworkUrl!, fit: BoxFit.cover)
                                : Image.file(File(song.artworkUrl!), fit: BoxFit.cover),
                          )
                        : const Icon(Icons.music_note, color: Colors.white),
                  ),
                  title: Text(
                    song.title,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    type == CategoryDetailType.album ? song.artist : song.album,
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatDuration(song.duration),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  onTap: () {
                    ref.read(playerViewModelProvider.notifier).setQueue(songs, startIndex: index);
                    Navigator.pop(context);
                  },
                  onLongPress: () {
                    _showSongContextMenu(context, ref, song, songs);
                  },
                );
              },
              childCount: songs.length,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showSongContextMenu(BuildContext context, WidgetRef ref, Song song, List<Song> allSongs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_play, color: Colors.white),
              title: const Text('次に再生', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ref.read(playerViewModelProvider.notifier).addToQueue(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('「${song.title}」を次に再生に追加しました')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text('プレイリストに追加', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showAddToPlaylistDialog(context, ref, song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('メタデータを編集', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showEditMetadataDialog(context, song);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, WidgetRef ref, Song song) {
    final playlists = ref.read(playlistViewModelProvider).playlists;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('プレイリストに追加', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              // 新規作成オプション
              ListTile(
                leading: const Icon(Icons.add_circle, color: Color(0xFFFF2D55)),
                title: const Text('新規作成...', style: TextStyle(color: Color(0xFFFF2D55), fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _showCreatePlaylistDialog(context, ref, song);
                },
              ),
              if (playlists.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'または既存プレイリストから選択:',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
              ...playlists.map((playlist) {
                return ListTile(
                  title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(playlistViewModelProvider.notifier).addSongToPlaylist(playlist.id, song.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('「${song.title}」を「${playlist.name}」に追加しました')),
                    );
                  },
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル', style: TextStyle(color: Color(0xFFFF2D55))),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref, Song song) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('プレイリストを作成', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'プレイリスト名を入力',
            hintStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFF2D55)),
            ),
          ),
          cursorColor: const Color(0xFFFF2D55),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル', style: TextStyle(color: Color(0xFFFF2D55))),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                // プレイリスト作成と曲追加
                ref.read(playlistViewModelProvider.notifier).createPlaylist(nameController.text).then((playlistId) {
                  if (playlistId != null) {
                    ref.read(playlistViewModelProvider.notifier).addSongToPlaylist(playlistId, song.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('「${nameController.text}」を作成し、曲を追加しました')),
                    );
                  }
                });
              }
            },
            child: const Text('作成', style: TextStyle(color: Color(0xFFFF2D55))),
          ),
        ],
      ),
    );
  }

  void _showEditMetadataDialog(BuildContext context, Song song) {
    final titleController = TextEditingController(text: song.title);
    final artistController = TextEditingController(text: song.artist);
    final albumController = TextEditingController(text: song.album);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('メタデータを編集', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'タイトル',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF2D55)),
                  ),
                ),
                cursorColor: const Color(0xFFFF2D55),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: artistController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'アーティスト',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF2D55)),
                  ),
                ),
                cursorColor: const Color(0xFFFF2D55),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: albumController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'アルバム',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF2D55)),
                  ),
                ),
                cursorColor: const Color(0xFFFF2D55),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル', style: TextStyle(color: Color(0xFFFF2D55))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('「${song.title}」のメタデータを更新しました（※ローカル保存未実装）'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('保存', style: TextStyle(color: Color(0xFFFF2D55))),
          ),
        ],
      ),
    );
  }
}
