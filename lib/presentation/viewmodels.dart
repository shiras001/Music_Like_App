/// プレゼンテーション層：ViewModels と Riverpod Providers
/// MVVM パターンで UI ロジックを管理
/// - PlayerViewModel: 再生制御（再生/停止、シャッフル、リピート、再生速度）
/// - LibraryViewModel: ライブラリ管理（ソート、フィルタリング）
/// - PlaylistViewModel: プレイリスト管理
/// - SearchViewModel: 検索機能
/// - SettingsViewModel: アプリ設定
/// - YouTubeViewModel: YouTube音声抽出
/// 
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import '../domain/entities.dart';
import '../domain/usecases.dart';
import '../data/repositories.dart';
import '../data/lrc_service.dart';
import '../data/audio_service.dart';

// ============================================================================
// 再生ViewModel
// ============================================================================

class PlayerState {
  final bool isPlaying;
  final Song? currentSong;
  final Duration position;
  final Duration duration;
  final ShuffleMode shuffleMode;
  final RepeatMode repeatMode;
  final double playbackSpeed;          // 1.0, 1.25, 1.5, 2.0
  final List<Song> queue;              // 再生キュー
  final int currentQueueIndex;         // キュー内の現在位置
  final List<LrcLine> lrcLines;        // 歌詞データ
  final bool showLyrics;               // 歌詞表示ON/OFF

  PlayerState({
    this.isPlaying = false,
    this.currentSong,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.shuffleMode = ShuffleMode.off,
    this.repeatMode = RepeatMode.off,
    this.playbackSpeed = 1.0,
    this.queue = const [],
    this.currentQueueIndex = -1,
    this.lrcLines = const [],
    this.showLyrics = false,
  });

  PlayerState copyWith({
    bool? isPlaying,
    Song? currentSong,
    Duration? position,
    Duration? duration,
    ShuffleMode? shuffleMode,
    RepeatMode? repeatMode,
    double? playbackSpeed,
    List<Song>? queue,
    int? currentQueueIndex,
    List<LrcLine>? lrcLines,
    bool? showLyrics,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentSong: currentSong ?? this.currentSong,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      shuffleMode: shuffleMode ?? this.shuffleMode,
      repeatMode: repeatMode ?? this.repeatMode,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      queue: queue ?? this.queue,
      currentQueueIndex: currentQueueIndex ?? this.currentQueueIndex,
      lrcLines: lrcLines ?? this.lrcLines,
      showLyrics: showLyrics ?? this.showLyrics,
    );
  }
}

class PlayerViewModel extends StateNotifier<PlayerState> {
  late final AudioPlayer _audioPlayer;
  final AudioServiceManager _audioServiceManager = AudioServiceManager();
  bool _audioServiceInitialized = false;

  PlayerViewModel() : super(PlayerState()) {
    _audioPlayer = AudioPlayer();
    _initAudioService();

    // プレーヤー状態の監視
    _audioPlayer.playerStateStream.listen((ps) {
      final playing = ps.playing && ps.processingState != ProcessingState.completed;
      state = state.copyWith(isPlaying: playing);
      _updateAudioServicePlaybackState();
    });

    _audioPlayer.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
      _updateAudioServicePlaybackState();
    });

    _audioPlayer.durationStream.listen((dur) {
      if (dur != null) state = state.copyWith(duration: dur);
      _updateAudioServicePlaybackState();
    });

    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < state.queue.length) {
        final newSong = state.queue[index];
        state = state.copyWith(
          currentQueueIndex: index,
          currentSong: newSong,
        );
        _audioServiceManager.updateMediaItem(newSong);
      }
    });
  }

  /// AudioService を初期化
  Future<void> _initAudioService() async {
    if (_audioServiceInitialized) return;
    try {
      await _audioServiceManager.init(_audioPlayer);
      _audioServiceInitialized = true;
      debugPrint('[PlayerViewModel] AudioService 初期化完了');
    } catch (e) {
      debugPrint('[PlayerViewModel] AudioService 初期化エラー: $e');
    }
  }

  /// AudioService の再生状態を更新
  void _updateAudioServicePlaybackState() {
    if (!_audioServiceInitialized) return;
    try {
      _audioServiceManager.updatePlaybackState(
        isPlaying: state.isPlaying,
        position: state.position,
        duration: state.duration,
      );
    } catch (e) {
      debugPrint('[PlayerViewModel] AudioService 再生状態更新エラー: $e');
    }
  }

  /// 再生/停止の切り替え
  void togglePlayPause() {
    if (state.isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  /// シャッフルモード切り替え
  void toggleShuffle() {
    final newMode = state.shuffleMode == ShuffleMode.off
        ? ShuffleMode.on
        : ShuffleMode.off;
    state = state.copyWith(shuffleMode: newMode);
    try {
      _audioPlayer.setShuffleModeEnabled(newMode == ShuffleMode.on);
      if (newMode == ShuffleMode.on) {
        _audioPlayer.shuffle();
      }
    } catch (_) {}
  }

  /// リピートモード切り替え (オフ → 全曲 → 1曲)
  void toggleRepeat() {
    final nextMode = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    state = state.copyWith(repeatMode: nextMode);
    try {
      final loopMode = switch (nextMode) {
        RepeatMode.off => LoopMode.off,
        RepeatMode.all => LoopMode.all,
        RepeatMode.one => LoopMode.one,
      };
      _audioPlayer.setLoopMode(loopMode);
    } catch (_) {}
  }

  /// 再生速度を設定 (1.0, 1.25, 1.5, 2.0)
  void setPlaybackSpeed(double speed) {
    // Apply to just_audio player and update state
    try {
      _audioPlayer.setSpeed(speed);
    } catch (_) {}
    state = state.copyWith(playbackSpeed: speed);
  }

  /// トグル方式で再生速度を切り替える。
  /// 同じ速度が指定された場合は 1.0 に戻す。
  void togglePlaybackSpeed(double speed) {
    final current = state.playbackSpeed;
    final next = (current == speed) ? 1.0 : speed;
    setPlaybackSpeed(next);
  }

  /// 10秒戻す
  void skipBackward10Seconds() {
    final newPosition = state.position - const Duration(seconds: 10);
    final adjustedPosition = newPosition.isNegative ? Duration.zero : newPosition;
    _audioPlayer.seek(adjustedPosition);
  }

  /// 10秒送る
  void skipForward10Seconds() {
    final newPosition = state.position + const Duration(seconds: 10);
    final adjustedPosition = newPosition > state.duration ? state.duration : newPosition;
    _audioPlayer.seek(adjustedPosition);
  }

  /// 前の曲へ
  void skipToPrevious() {
    _audioPlayer.seekToPrevious();
  }

  /// 次の曲へ
  void skipToNext() {
    _audioPlayer.seekToNext();
  }

  /// 再生位置をシーク
  void seekTo(Duration position) {
    final adjustedPosition = position > state.duration ? state.duration : (position.isNegative ? Duration.zero : position);
    _audioPlayer.seek(adjustedPosition);
  }

  /// 再生キューを更新
  void setQueue(List<Song> queue, {int? startIndex}) async {
    // 現在の再生状態を保存
    final currentSongId = state.currentSong?.id;
    final currentPosition = _audioPlayer.position;
    final isCurrentlyPlaying = state.isPlaying;
    
    // startIndexが指定されていない場合、キュー内で現在の曲を探す（位置を保持するため）
    int nextStartIndex = startIndex ?? 0;
    if (startIndex == null && currentSongId != null) {
      final foundIndex = queue.indexWhere((s) => s.id == currentSongId);
      if (foundIndex >= 0) {
        nextStartIndex = foundIndex;
      }
    }
    
    final nextSong = queue.isNotEmpty ? queue[nextStartIndex] : null;
    
    // State を更新（位置は保持するか、新規開始かで判定）
    final shouldKeepPosition = startIndex == null && currentSongId != null && 
                               queue.isNotEmpty && 
                               queue[nextStartIndex].id == currentSongId;
    
    state = state.copyWith(
      queue: queue,
      currentQueueIndex: nextStartIndex,
      currentSong: nextSong,
      position: shouldKeepPosition ? currentPosition : Duration.zero,
      isPlaying: false, // 一度停止状態にして、再生準備完了後に再開
      lrcLines: const [],
    );

    // AudioService のメディアアイテムを更新
    if (nextSong != null) {
      _audioServiceManager.updateMediaItem(nextSong);
    }

    // 歌詞ファイルを読み込み
    if (nextSong?.lyricsPath != null) {
      _loadLyrics(nextSong!.lyricsPath!);
    }

    // Build audio source for just_audio
    final sources = <AudioSource>[];
    for (final s in queue) {
      if (s.localPath != null) {
        sources.add(AudioSource.uri(Uri.file(s.localPath!)));
      }
    }

    if (sources.isNotEmpty) {
      final concat = ConcatenatingAudioSource(children: sources);
      try {
        await _audioPlayer.setAudioSource(concat, initialIndex: nextStartIndex);
        
        // 位置を復元（同じ曲の場合）
        if (shouldKeepPosition && currentPosition.inMilliseconds > 0) {
          await _audioPlayer.seek(currentPosition);
        }
        
        // 既存の設定（シャッフル/リピート/速度）を反映
        _audioPlayer.setShuffleModeEnabled(state.shuffleMode == ShuffleMode.on);
        if (state.shuffleMode == ShuffleMode.on) {
          _audioPlayer.shuffle();
        }
        final loopMode = switch (state.repeatMode) {
          RepeatMode.off => LoopMode.off,
          RepeatMode.all => LoopMode.all,
          RepeatMode.one => LoopMode.one,
        };
        _audioPlayer.setLoopMode(loopMode);
        _audioPlayer.setSpeed(state.playbackSpeed);
        
        // 元々再生中だった場合は再開
        if (isCurrentlyPlaying) {
          await _audioPlayer.play();
        }
        
        // State の isPlaying を正確に反映
        state = state.copyWith(isPlaying: isCurrentlyPlaying);
      } catch (e) {
        debugPrint('[Player] failed to set audio source: $e');
      }
    }
  }

  /// 歌詞ファイルを読み込み
  Future<void> _loadLyrics(String lyricsPath) async {
    try {
      final lrcLines = await LrcParseService.parseLrcFile(lyricsPath);
      state = state.copyWith(lrcLines: lrcLines);
      debugPrint('[Player] 歌詞読み込み完了: ${lrcLines.length}行');
    } catch (e) {
      debugPrint('[Player] 歌詞読み込みエラー: $e');
      state = state.copyWith(lrcLines: const []);
    }
  }

  /// 歌詞表示の切り替え
  void toggleLyrics() {
    state = state.copyWith(showLyrics: !state.showLyrics);
  }

  /// 再生位置を更新（ネイティブ層からのコールバック想定）
  void updatePosition(Duration position) {
    state = state.copyWith(position: position);
  }

  /// 再生状態を更新（ネイティブ層からのコールバック想定）
  void updatePlaybackState(bool isPlaying) {
    state = state.copyWith(isPlaying: isPlaying);
  }

  /// キューの並び替え
  void reorderQueue(int oldIndex, int newIndex) {
    final queue = List<Song>.from(state.queue);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final song = queue.removeAt(oldIndex);
    queue.insert(newIndex, song);

    // 現在再生中のインデックスを調整
    int currentIndex = state.currentQueueIndex;
    if (oldIndex == currentIndex) {
      currentIndex = newIndex;
    } else if (oldIndex < currentIndex && newIndex >= currentIndex) {
      currentIndex -= 1;
    } else if (oldIndex > currentIndex && newIndex <= currentIndex) {
      currentIndex += 1;
    }

    state = state.copyWith(
      queue: queue,
      currentQueueIndex: currentIndex,
    );

    // just_audioのキューも更新
    _updateAudioSourceQueue(queue, currentIndex);
  }

  /// キューから曲を削除
  void removeFromQueue(int index) {
    final queue = List<Song>.from(state.queue);
    queue.removeAt(index);

    // 現在再生中のインデックスを調整
    int currentIndex = state.currentQueueIndex;
    if (index < currentIndex) {
      currentIndex -= 1;
    } else if (index == currentIndex && queue.isNotEmpty) {
      // 現在の曲を削除した場合、次の曲へ
      if (currentIndex >= queue.length) {
        currentIndex = queue.length - 1;
      }
    }

    state = state.copyWith(
      queue: queue,
      currentQueueIndex: currentIndex >= 0 && queue.isNotEmpty ? currentIndex : 0,
      currentSong: queue.isNotEmpty ? queue[currentIndex >= 0 ? currentIndex : 0] : null,
    );

    if (queue.isEmpty) {
      _audioPlayer.stop();
    } else {
      _updateAudioSourceQueue(queue, currentIndex >= 0 ? currentIndex : 0);
    }
  }

  /// キュー内の指定位置にスキップ
  void skipToQueueItem(int index) {
    if (index >= 0 && index < state.queue.length) {
      state = state.copyWith(
        currentQueueIndex: index,
        currentSong: state.queue[index],
        isPlaying: true,
      );
      _audioPlayer.seek(Duration.zero, index: index);
      _audioPlayer.play();
    }
  }

  /// 次に再生に追加
  void addToQueue(Song song) {
    final queue = List<Song>.from(state.queue);
    final insertIndex = state.currentQueueIndex + 1;
    queue.insert(insertIndex, song);

    state = state.copyWith(queue: queue);

    _updateAudioSourceQueue(queue, state.currentQueueIndex);
  }

  /// just_audioのキューを更新
  void _updateAudioSourceQueue(List<Song> queue, int currentIndex) {
    final sources = <AudioSource>[];
    for (final s in queue) {
      if (s.localPath != null) {
        sources.add(AudioSource.uri(Uri.file(s.localPath!)));
      }
    }

    if (sources.isNotEmpty) {
      final concat = ConcatenatingAudioSource(children: sources);
      _audioPlayer.setAudioSource(concat, initialIndex: currentIndex).catchError((e) {
        debugPrint('[Player] failed to update audio source: $e');
      });
    }
  }

  @override
  void dispose() {
    _audioServiceManager.stop();
    _audioPlayer.dispose();
    super.dispose();
  }
}

// ============================================================================
// ライブラリViewModel
// ============================================================================

class LibraryState {
  final List<Song> songs;
  final bool isLoading;
  final String? error;
  final String sortBy;              // 'title', 'artist', 'album', 'duration'
  final bool sortAscending;

  LibraryState({
    this.songs = const [],
    this.isLoading = false,
    this.error,
    this.sortBy = 'title',
    this.sortAscending = true,
  });

  LibraryState copyWith({
    List<Song>? songs,
    bool? isLoading,
    String? error,
    String? sortBy,
    bool? sortAscending,
  }) {
    return LibraryState(
      songs: songs ?? this.songs,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

class LibraryViewModel extends StateNotifier<LibraryState> {
  final LibraryUseCase _libraryUseCase;

  LibraryViewModel(this._libraryUseCase)
      : super(LibraryState()) {
    loadLibrary();
  }

  /// ライブラリを読み込む
  Future<void> loadLibrary() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final songs = await _libraryUseCase.getLibrarySongs();
      final sorted = _libraryUseCase.sortSongs(
        songs,
        sortBy: state.sortBy,
        ascending: state.sortAscending,
      );
      state = state.copyWith(songs: sorted, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// ライブラリを更新（ダウンロード/インポート完了後に呼び出す）
  Future<void> refreshLibrary() async {
    try {
      final songs = await _libraryUseCase.getLibrarySongs();
      final sorted = _libraryUseCase.sortSongs(
        songs,
        sortBy: state.sortBy,
        ascending: state.sortAscending,
      );
      state = state.copyWith(songs: sorted);
      print('[Library] ライブラリ更新完了: ${sorted.length}曲');
    } catch (e) {
      print('[Library] ライブラリ更新エラー: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// ソートを変更
  void changeSortOrder(String sortBy) {
    final newAscending =
        state.sortBy == sortBy ? !state.sortAscending : true;
    final sorted = _libraryUseCase.sortSongs(
      state.songs,
      sortBy: sortBy,
      ascending: newAscending,
    );
    state = state.copyWith(
      songs: sorted,
      sortBy: sortBy,
      sortAscending: newAscending,
    );
  }

  /// 楽曲メタデータを更新
  Future<void> updateSongMetadata(String songId, Map<String, dynamic> data) async {
    try {
      await _libraryUseCase.updateSongMetadata(songId, data);
      await loadLibrary();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 楽曲を削除
  Future<void> deleteSong(String songId) async {
    try {
      await _libraryUseCase.deleteSong(songId);
      state = state.copyWith(
        songs: state.songs.where((s) => s.id != songId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// ============================================================================
// プレイリストViewModel
// ============================================================================

class PlaylistState {
  final List<Playlist> playlists;
  final bool isLoading;
  final String? error;

  PlaylistState({
    this.playlists = const [],
    this.isLoading = false,
    this.error,
  });

  PlaylistState copyWith({
    List<Playlist>? playlists,
    bool? isLoading,
    String? error,
  }) {
    return PlaylistState(
      playlists: playlists ?? this.playlists,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PlaylistViewModel extends StateNotifier<PlaylistState> {
  final PlaylistUseCase _playlistUseCase;

  PlaylistViewModel(this._playlistUseCase)
      : super(PlaylistState()) {
    loadPlaylists();
  }

  /// すべてのプレイリストを読み込む
  Future<void> loadPlaylists() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final playlists = await _playlistUseCase.getPlaylists();
      state = state.copyWith(playlists: playlists, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// プレイリストを作成
  Future<String?> createPlaylist(String name, {String? description}) async {
    try {
      final id = await _playlistUseCase.createPlaylist(name, description: description);
      await loadPlaylists();
      return id;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// プレイリストの名前を変更
  Future<void> renamePlaylist(String playlistId, String newName) async {
    try {
      await _playlistUseCase.renamePlaylist(playlistId, newName);
      await loadPlaylists();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// プレイリストに曲を追加
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    try {
      await _playlistUseCase.addSongToPlaylist(playlistId, songId);
      await loadPlaylists();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// プレイリストから曲を削除
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      await _playlistUseCase.removeSongFromPlaylist(playlistId, songId);
      await loadPlaylists();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// プレイリストを削除
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _playlistUseCase.deletePlaylist(playlistId);
      await loadPlaylists();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// ============================================================================
// 検索ViewModel
// ============================================================================

class SearchState {
  final List<Song> songResults;
  final List<Artist> artistResults;
  final List<Album> albumResults;
  final List<Playlist> playlistResults;
  final String query;
  final bool isLoading;
  final String? error;

  SearchState({
    this.songResults = const [],
    this.artistResults = const [],
    this.albumResults = const [],
    this.playlistResults = const [],
    this.query = '',
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    List<Song>? songResults,
    List<Artist>? artistResults,
    List<Album>? albumResults,
    List<Playlist>? playlistResults,
    String? query,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      songResults: songResults ?? this.songResults,
      artistResults: artistResults ?? this.artistResults,
      albumResults: albumResults ?? this.albumResults,
      playlistResults: playlistResults ?? this.playlistResults,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SearchViewModel extends StateNotifier<SearchState> {
  final SearchUseCase _searchUseCase;

  SearchViewModel(this._searchUseCase) : super(SearchState());

  /// 検索を実行
  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(
        query: query,
        songResults: [],
        artistResults: [],
        albumResults: [],
        playlistResults: [],
      );
      return;
    }

    state = state.copyWith(query: query, isLoading: true, error: null);
    try {
      final songs = await _searchUseCase.searchSongs(query);
      final artists = await _searchUseCase.searchArtists(query);
      final albums = await _searchUseCase.searchAlbums(query);
      final playlists = await _searchUseCase.searchPlaylists(query);
      state = state.copyWith(
        songResults: songs,
        artistResults: artists,
        albumResults: albums,
        playlistResults: playlists,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// 検索をクリア
  void clearSearch() {
    state = SearchState();
  }
}

// ============================================================================
// 設定ViewModel
// ============================================================================

class SettingsViewModel extends StateNotifier<AppSettings> {
  final ILocalSettingsRepository _settingsRepository;

  SettingsViewModel(this._settingsRepository) : super(AppSettings()) {
    _loadSettings();
  }

  /// 設定を読み込む
  Future<void> _loadSettings() async {
    state = await _settingsRepository.getSettings();
  }

  /// YouTube設定を更新
  Future<void> updateYouTubeSettings(YouTubeSettings settings) async {
    state = state.copyWith(youtubeSettings: settings);
    await _settingsRepository.saveSettings(state);
  }

  /// ローカルファイル設定を更新
  Future<void> updateLocalFileSettings(LocalFileSettings settings) async {
    state = state.copyWith(localFileSettings: settings);
    await _settingsRepository.saveSettings(state);
  }

  /// 歌詞表示設定を更新
  Future<void> updateLyricsSettings(LyricsSettings settings) async {
    state = state.copyWith(lyricsSettings: settings);
    await _settingsRepository.saveSettings(state);
  }
}

// ============================================================================
// YouTube音声抽出ViewModel
// ============================================================================

class YouTubeState {
  final bool isLoading;
  final String? error;
  final String? downloadProgress;    // "ダウンロード中... 50%"

  YouTubeState({
    this.isLoading = false,
    this.error,
    this.downloadProgress,
  });

  YouTubeState copyWith({
    bool? isLoading,
    String? error,
    String? downloadProgress,
  }) {
    return YouTubeState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}

class YouTubeViewModel extends StateNotifier<YouTubeState> {
  final YouTubeDownloadUseCase _youtubeUseCase;

  YouTubeViewModel(this._youtubeUseCase) : super(YouTubeState());

  /// YouTube動画の情報を取得（ダイアログ表示用）
  Future<dynamic> getVideoInfo(String youtubeUrl) async {
    try {
      final info = await _youtubeUseCase.getVideoInfo(youtubeUrl);
      return info;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// YouTube動画から音声をダウンロード・変換・永続化
  Future<Song?> downloadFromYouTube(
    String youtubeUrl,
    String outputFormat,
    String outputPath,
    int bitrate,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. キャッシュディレクトリにダウンロード
      debugPrint('[ViewModel] ダウンロード開始処理');
      final cachePath = await _getApplicationCachePath();
      debugPrint('[ViewModel] キャッシュパス: $cachePath');
      
      debugPrint('[ViewModel] YouTubeUseCase.downloadAndConvert() 呼び出し');
      final song = await _youtubeUseCase.downloadAndConvert(
        youtubeUrl,
        outputFormat,
        cachePath,
        bitrate,
      );
      debugPrint('[ViewModel] YouTubeUseCase 戻り値: ${song?.title}');

      if (song == null) {
        debugPrint('[ViewModel] エラー: ダウンロード失敗');
        state = state.copyWith(
          error: 'ダウンロード失敗',
          isLoading: false,
        );
        return null;
      }

      // 2. キャッシュから永続ストレージへ移動
      debugPrint('[ViewModel] 永続化開始: ${song.localPath}');
      final persistentPath = await _copyFileToPersistentStorage(
        song.localPath ?? '',
        outputFormat,
      );

      if (persistentPath == null) {
        state = state.copyWith(
          error: 'ファイル永続化失敗',
          isLoading: false,
        );
        return null;
      }

      // 3. Song エンティティを更新
      final persistedSong = Song(
        id: song.id,
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: song.duration,
        fileFormat: song.fileFormat,
        localPath: persistentPath,
        isLocal: true,
      );

      state = state.copyWith(isLoading: false);
      return persistedSong;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return null;
    }
  }

  /// キャッシュディレクトリパスを取得
  Future<String> _getApplicationCachePath() async {
    final cacheDir = await getTemporaryDirectory();
    return cacheDir.path;
  }

  /// ファイルをキャッシュから永続ストレージへコピー（Android 11+ 対応）
  /// 共有ストレージ (Music) へのアクセス権限がない場合は、
  /// アプリ専用ディレクトリ (Documents) に保存
  Future<String?> _copyFileToPersistentStorage(
    String sourceFilePath,
    String outputFormat,
  ) async {
    try {
      // アプリ専用の Documents ディレクトリを取得
      // これはアンインストール時に削除されるが、通常の操作で削除されない
      final appDocDir = await getApplicationDocumentsDirectory();
      
      // Music サブディレクトリを作成
      final musicDir = Directory('${appDocDir.path}/Music');
      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
      }

      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        return null;
      }

      // ファイル名を生成
      final fileName = sourceFile.path.split('/').last;
      final destinationPath = '${musicDir.path}/$fileName';
      
      // ファイルをコピー
      final copiedFile = await sourceFile.copy(destinationPath);
      
      print('[YouTube] ファイル永続化成功: $destinationPath');
      return copiedFile.path;
    } catch (e) {
      print('[YouTube] ファイル永続化エラー: $e');
      return null;
    }
  }

  /// URL検証
  Future<bool> validateURL(String url) async {
    try {
      final info = await _youtubeUseCase.getVideoInfo(url);
      return info != null;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

// ============================================================================
// ローカルファイル読込ViewModel
// ============================================================================

class LocalImportState {
  final bool isLoading;
  final String? error;
  final List<Song> importedSongs;

  LocalImportState({
    this.isLoading = false,
    this.error,
    this.importedSongs = const [],
  });

  LocalImportState copyWith({
    bool? isLoading,
    String? error,
    List<Song>? importedSongs,
  }) {
    return LocalImportState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      importedSongs: importedSongs ?? this.importedSongs,
    );
  }
}

class LocalImportViewModel extends StateNotifier<LocalImportState> {
  final LocalFileImportUseCase _importUseCase;

  LocalImportViewModel(this._importUseCase) : super(LocalImportState());

  /// 単一の音声ファイルをインポート
  Future<Song?> importSingleFile(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final song = await _importUseCase.importSingleAudioFile(filePath);
      if (song != null) {
        state = state.copyWith(
          importedSongs: [...state.importedSongs, song],
        );
      }
      state = state.copyWith(isLoading: false);
      return song;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return null;
    }
  }

  /// フォルダ内のすべてのファイルをインポート
  Future<List<Song>> importFolder(String folderPath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final songs = await _importUseCase.importAudioFolder(folderPath);
      state = state.copyWith(
        importedSongs: [...state.importedSongs, ...songs],
        isLoading: false,
      );
      return songs;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return [];
    }
  }

  /// 歌詞ファイルをインポート
  Future<bool> importLyricsFile(String songId, String lyricsPath) async {
    try {
      return await _importUseCase.importLyricsFile(songId, lyricsPath);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

// ============================================================================
// Riverpod Providers
// ============================================================================

final playerViewModelProvider =
    StateNotifierProvider<PlayerViewModel, PlayerState>((ref) {
  return PlayerViewModel();
});

final libraryViewModelProvider =
    StateNotifierProvider<LibraryViewModel, LibraryState>((ref) {
  final musicRepo = ref.watch(musicRepositoryProvider);
  final useCase = LibraryUseCase(musicRepo);
  return LibraryViewModel(useCase);
});

final playlistViewModelProvider =
    StateNotifierProvider<PlaylistViewModel, PlaylistState>((ref) {
  final playlistRepo = ref.watch(playlistRepositoryProvider);
  final useCase = PlaylistUseCase(playlistRepo, ref.watch(musicRepositoryProvider));
  return PlaylistViewModel(useCase);
});

final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  final searchRepo = ref.watch(searchRepositoryProvider);
  return SearchViewModel(SearchUseCase(searchRepo));
});

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, AppSettings>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return SettingsViewModel(settingsRepo);
});

final youtubeViewModelProvider =
    StateNotifierProvider<YouTubeViewModel, YouTubeState>((ref) {
  final youtubeService = ref.watch(youtubeServiceProvider);
  final musicRepo = ref.watch(musicRepositoryProvider);
  final useCase = YouTubeDownloadUseCase(youtubeService, musicRepo);
  return YouTubeViewModel(useCase);
});

final localImportViewModelProvider =
    StateNotifierProvider<LocalImportViewModel, LocalImportState>((ref) {
  final audioService = ref.watch(localAudioServiceProvider);
  final musicRepo = ref.watch(musicRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  final useCase = LocalFileImportUseCase(audioService, musicRepo, settingsRepo);
  return LocalImportViewModel(useCase);
});