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
import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
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
  final bool autoScrollLyrics;         // 歌詞自動送り ON/OFF

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
    this.autoScrollLyrics = true,
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
    bool? autoScrollLyrics,
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
      autoScrollLyrics: autoScrollLyrics ?? this.autoScrollLyrics,
    );
  }
}

class PlayerViewModel extends StateNotifier<PlayerState> {
  final Ref _ref;
  late final AudioPlayer _audioPlayer;
  ConcatenatingAudioSource? _queueSource;
  final AudioServiceManager _audioServiceManager = AudioServiceManager();
  bool _audioServiceInitialized = false;
  bool _nativeSkipSilenceEnabled = false;
  DateTime? _silenceSkipTrackStartAt;
  bool _legacyStartSkipApplied = false;
  bool _legacyEndSkipApplied = false;
  StreamSubscription<audio_service.PlaybackState>? _audioServicePlaybackSub;
  final Map<String, int> _durationOverrideCache = {};

  PlayerViewModel(this._ref) : super(PlayerState()) {
    _audioPlayer = AudioPlayer();
    // Defer audio_service initialization to the first frame to avoid
    // Activity/engine timing issues that prevent notification display.

    // プレーヤー状態の監視
    _audioPlayer.playerStateStream.listen((ps) {
      final playing = ps.playing && ps.processingState != ProcessingState.completed;
      state = state.copyWith(isPlaying: playing);
    });

    _audioPlayer.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
      _applySilenceSkipForCurrentSong();
      _applyEndSilenceSkipIfNeeded(pos);
    });

    _audioPlayer.durationStream.listen((dur) {
      if (dur != null) {
        state = state.copyWith(duration: dur);
        final current = state.currentSong;
        if (current != null && current.localPath != null && dur > Duration.zero) {
          final diff = (dur - current.duration).abs();
          final cached = _durationOverrideCache[current.id];
          if (diff.inSeconds >= 1 && cached != dur.inMilliseconds) {
            _durationOverrideCache[current.id] = dur.inMilliseconds;
            final updatedSong = current.copyWith(duration: dur);
            final updatedQueue = List<Song>.from(state.queue);
            final idx = updatedQueue.indexWhere((s) => s.id == current.id);
            if (idx >= 0) {
              updatedQueue[idx] = updatedSong;
            }
            state = state.copyWith(currentSong: updatedSong, queue: updatedQueue);
            _ref.read(libraryViewModelProvider.notifier).updateSongMetadata(
              current.id,
              {
                'localPath': current.localPath,
                'durationMs': dur.inMilliseconds,
              },
            );
          }
        }
      }
    });

    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < state.queue.length) {
        final newSong = state.queue[index];
        state = state.copyWith(
          currentQueueIndex: index,
          currentSong: newSong,
        );
        _silenceSkipTrackStartAt = null;
        _legacyStartSkipApplied = false;
        _legacyEndSkipApplied = false;
        _setNativeSkipSilenceEnabled(false);
        _audioServiceManager.updateMediaItem(newSong);
        if (newSong.lyricsPath == null || newSong.lyricsPath!.isEmpty) {
          state = state.copyWith(lrcLines: const []);
        }
      }
    });

    // Attempt to restore saved queue from preferences after initialization
    Future.microtask(() => _restoreQueueFromPrefs());
  }

  /// AudioService を初期化
  Future<void> _initAudioService() async {
    if (_audioServiceInitialized) return;
    try {
      await _audioServiceManager.init(_audioPlayer);
      _audioServiceInitialized = true;
      debugPrint('[PlayerViewModel] AudioService 初期化完了');
      _audioServicePlaybackSub ??= _audioServiceManager.handler.playbackState.listen((ps) {
        final playing = ps.playing && ps.processingState != audio_service.AudioProcessingState.completed;
        if (state.isPlaying != playing) {
          state = state.copyWith(isPlaying: playing);
        }
      });
    } catch (e) {
      debugPrint('[PlayerViewModel] AudioService 初期化エラー: $e');
    }
  }

  Future<void> ensureAudioServiceInitialized() async {
    await _initAudioService();
    // 初期化後、現在のメディアアイテムがあれば通知へ反映しておく
    try {
      if (state.currentSong != null) {
        // AudioServiceManager 側で未初期化チェックを行うが、追加で安全確認
        if (_audioServiceManager.isInitialized) {
          await _audioServiceManager.updateMediaItem(state.currentSong!);
          if (state.isPlaying) {
            await _audioServiceManager.handler.play();
          }
        }
      }
    } catch (e) {
      debugPrint('[PlayerViewModel] ensureAudioServiceInitialized post-update error: $e');
    }
  }

  /// 再生/停止の切り替え
  Future<void> togglePlayPause() async {
    // Do not optimistically flip UI state here. Rely on just_audio's
    // playerStateStream listener to update `state.isPlaying` so UI stays
    // consistent with the actual audio backend (fixes stop->play icon
    // desync on certain native/notification workflows).
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          await Permission.notification.request();
        }
      }
      // Ensure audio_service is initialized before using its handler.
      try {
        await ensureAudioServiceInitialized();
      } catch (e) {
        debugPrint('[PlayerViewModel] ensureAudioServiceInitialized error: $e');
      }

      if (state.isPlaying) {
        try {
          if (_audioServiceInitialized) {
            await _audioServiceManager.handler.pause();
          } else {
            await _audioPlayer.pause();
          }
        } catch (e) {
          debugPrint('[PlayerViewModel] pause fallback error: $e');
          await _audioPlayer.pause();
        }
      } else {
        try {
          if (_audioServiceInitialized) {
            await _audioServiceManager.handler.play();
          } else {
            await _audioPlayer.play();
          }
          _applySilenceSkipForCurrentSong();
        } catch (e) {
          debugPrint('[PlayerViewModel] play fallback error: $e');
          await _audioPlayer.play();
          _applySilenceSkipForCurrentSong();
        }
      }
      // Update UI state after action to avoid repeated taps.
      state = state.copyWith(isPlaying: _audioPlayer.playing);
      if (state.currentSong != null && _audioServiceManager.isInitialized) {
        await _audioServiceManager.updateMediaItem(state.currentSong!);
      }
    } catch (e) {
      debugPrint('[PlayerViewModel] togglePlayPause error: $e');
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
    _silenceSkipTrackStartAt = adjustedPosition <= const Duration(milliseconds: 300)
        ? DateTime.now()
        : null;
    _legacyStartSkipApplied = adjustedPosition > const Duration(milliseconds: 300);
    _legacyEndSkipApplied = false;
    _audioPlayer.seek(adjustedPosition);
  }

  /// 再生キューを更新
  void setQueue(List<Song> queue, {int? startIndex, bool autoPlay = false}) async {
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
    _silenceSkipTrackStartAt = null;
    _legacyStartSkipApplied = false;
    _legacyEndSkipApplied = false;
    _setNativeSkipSilenceEnabled(false);

    // AudioService を先に初期化し、メディアアイテムを通知へ反映
    try {
      await ensureAudioServiceInitialized();
      if (nextSong != null && _audioServiceManager.isInitialized) {
        await _audioServiceManager.updateQueue(queue);
        await _audioServiceManager.updateMediaItem(nextSong);
      }
    } catch (e) {
      debugPrint('[Player] ensureAudioServiceInitialized error in setQueue: $e');
    }

    // 歌詞ファイルを読み込み（再生前に完了させることで、
    // 自動再生時に歌詞がすぐ表示されるようにする）
    if (nextSong?.lyricsPath != null) {
      await _loadLyrics(nextSong!.lyricsPath!);
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
      _queueSource = concat;
      try {
        await _audioPlayer.setAudioSource(
          concat,
          initialIndex: nextStartIndex,
          initialPosition: shouldKeepPosition ? currentPosition : null,
        );
        
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
        
        // autoPlay が true の場合は再生を開始、または元々再生中だった場合は再開
        if (autoPlay || isCurrentlyPlaying) {
            try {
            await ensureAudioServiceInitialized();
            if (_audioServiceManager.isInitialized) {
              await _audioServiceManager.handler.play();
            } else {
              await _audioPlayer.play();
            }
              // 無音スキップの適用（再生開始後に一度だけシーク）
              _applySilenceSkipForCurrentSong();
          } catch (e) {
            debugPrint('[Player] autoplay via audio_service failed: $e');
            await _audioPlayer.play();
              _applySilenceSkipForCurrentSong();
          }
        }
        
        // State の isPlaying を正確に反映
        state = state.copyWith(isPlaying: autoPlay || isCurrentlyPlaying);
      } catch (e) {
        debugPrint('[Player] failed to set audio source: $e');
      }
    } else {
      _queueSource = null;
    }
  }

  void _setNativeSkipSilenceEnabled(bool enabled) {
    if (_nativeSkipSilenceEnabled == enabled) return;
    _nativeSkipSilenceEnabled = enabled;
    _audioPlayer.setSkipSilenceEnabled(enabled).catchError((e) {
      debugPrint('[Player] setSkipSilenceEnabled failed: $e');
    });
  }

  void _applySilenceSkipForCurrentSong() {
    try {
      final settings = _ref.read(settingsViewModelProvider);
      final thresholdMs = settings.silenceSkipThreshold;

      if (!settings.silenceSkipEnabled || thresholdMs <= 0 || !state.isPlaying) {
        _setNativeSkipSilenceEnabled(false);
        return;
      }

      if (_audioPlayer.processingState != ProcessingState.ready) {
        _setNativeSkipSilenceEnabled(false);
        return;
      }

      final useLegacySkip = Platform.isAndroid && _isOldAndroidForNativeSkip();
      if (useLegacySkip) {
        _setNativeSkipSilenceEnabled(false);
        final threshold = Duration(milliseconds: thresholdMs);
        final duration = state.duration;
        final position = state.position;

        if (!_legacyStartSkipApplied && position <= const Duration(milliseconds: 250)) {
          final safeEnd = duration > Duration.zero
              ? Duration(milliseconds: (duration.inMilliseconds - 150).clamp(0, duration.inMilliseconds))
              : threshold;
          final target = safeEnd < threshold ? safeEnd : threshold;
          if (target > position) {
            _audioPlayer.seek(target).catchError((e) {
              debugPrint('[Player] legacy start silence seek failed: $e');
            });
          }
          _legacyStartSkipApplied = true;
          return;
        }

        if (duration > Duration.zero && !_legacyEndSkipApplied) {
          final remaining = duration - position;
          if (remaining <= threshold) {
            _legacyEndSkipApplied = true;
            _audioPlayer.seek(duration).catchError((e) {
              debugPrint('[Player] legacy end silence seek failed: $e');
            });
          }
        }
        return;
      }

      final threshold = Duration(milliseconds: thresholdMs);
      final position = state.position;
      final duration = state.duration;
      _silenceSkipTrackStartAt ??= DateTime.now();
      final elapsed = DateTime.now().difference(_silenceSkipTrackStartAt!);

      // Guard: if native skip jumps too far during the very beginning,
      // clamp to threshold and stop start-side skip immediately.
      final startOvershoot = position - threshold;
      final inEarlyPhase = elapsed <= (threshold + const Duration(seconds: 1));
      if (inEarlyPhase && startOvershoot > const Duration(milliseconds: 700)) {
        _setNativeSkipSilenceEnabled(false);
        _audioPlayer.seek(threshold).catchError((e) {
          debugPrint('[Player] start silence clamp seek failed: $e');
        });
        debugPrint('[Player] start silence overshoot clamped to ${threshold.inMilliseconds}ms');
        return;
      }

      final inStartWindow = position <= threshold;
      final inEndWindow = duration > Duration.zero && (duration - position) <= threshold;

      // Enable native silence-skip only in the configured windows:
      // - start: from 0s up to threshold
      // - end: from (duration-threshold) to end
      // This keeps the setting as "最大◯秒まで" while still stopping early
      // when actual silence ends earlier (e.g. 5s設定で無音が3sなら3sで終了)。
      _setNativeSkipSilenceEnabled(inStartWindow || inEndWindow);
    } catch (e) {
      debugPrint('[Player] silence skip error: $e');
      _setNativeSkipSilenceEnabled(false);
    }
  }

  bool _isOldAndroidForNativeSkip() {
    try {
      final version = Platform.operatingSystemVersion.toLowerCase();
      final match = RegExp(r'android\s+(\d+)').firstMatch(version);
      final major = int.tryParse(match?.group(1) ?? '');
      if (major == null) return false;
      return major <= 9;
    } catch (_) {
      return false;
    }
  }

  void _applyEndSilenceSkipIfNeeded(Duration position) {
    // End-side behavior is unified in _applySilenceSkipForCurrentSong().
    _applySilenceSkipForCurrentSong();
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
    final nextShow = !state.showLyrics;
    state = state.copyWith(
      showLyrics: nextShow,
      autoScrollLyrics: true,
    );
  }

  /// 歌詞を再読み込み（編集後に使用）
  Future<void> loadLyricsFromPath(String? lyricsPath) async {
    if (lyricsPath == null || lyricsPath.isEmpty) {
      state = state.copyWith(lrcLines: const []);
      return;
    }
    await _loadLyrics(lyricsPath);
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
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    final currentSongId = state.currentSong?.id;
    final currentPosition = state.position;
    final wasPlaying = state.isPlaying;
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

    final keepPosition = currentSongId != null && queue.isNotEmpty && queue[currentIndex].id == currentSongId;
    state = state.copyWith(
      queue: queue,
      currentQueueIndex: currentIndex,
      position: keepPosition ? currentPosition : Duration.zero,
    );

    if (_queueSource != null) {
      try {
        await _queueSource!.move(oldIndex, newIndex);
      } catch (e) {
        debugPrint('[Player] failed to move queue item: $e');
        await _updateAudioSourceQueue(
          queue,
          currentIndex,
          position: keepPosition ? currentPosition : Duration.zero,
          resumeIfPlaying: wasPlaying,
        );
      }
    } else {
      await _updateAudioSourceQueue(
        queue,
        currentIndex,
        position: keepPosition ? currentPosition : Duration.zero,
        resumeIfPlaying: wasPlaying,
      );
    }
    // 通知/ロック画面のキューも更新
    ensureAudioServiceInitialized().then((_) {
      if (_audioServiceManager.isInitialized) {
        _audioServiceManager.updateQueue(queue);
      }
    });
    _saveQueueToPrefs();
  }

  /// キューから曲を削除
  Future<void> removeFromQueue(int index) async {
    final currentSongId = state.currentSong?.id;
    final currentPosition = state.position;
    final wasPlaying = state.isPlaying;
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

    final nextIndex = currentIndex >= 0 && queue.isNotEmpty ? currentIndex : 0;
    final nextSong = queue.isNotEmpty ? queue[nextIndex] : null;
    final keepPosition = currentSongId != null && nextSong != null && nextSong.id == currentSongId;
    state = state.copyWith(
      queue: queue,
      currentQueueIndex: nextIndex,
      currentSong: nextSong,
      position: keepPosition ? currentPosition : Duration.zero,
    );

    if (queue.isEmpty) {
      await _audioPlayer.stop();
      state = state.copyWith(isPlaying: false);
    } else {
      if (_queueSource != null) {
        try {
          await _queueSource!.removeAt(index);
        } catch (e) {
          debugPrint('[Player] failed to remove queue item: $e');
          await _updateAudioSourceQueue(
            queue,
            nextIndex,
            position: keepPosition ? currentPosition : Duration.zero,
            resumeIfPlaying: wasPlaying,
          );
        }
      } else {
        await _updateAudioSourceQueue(
          queue,
          nextIndex,
          position: keepPosition ? currentPosition : Duration.zero,
          resumeIfPlaying: wasPlaying,
        );
      }
    }
    // 通知/ロック画面のキューとメディアアイテムを更新
    await ensureAudioServiceInitialized();
    if (_audioServiceManager.isInitialized) {
      await _audioServiceManager.updateQueue(queue);
      if (state.currentSong != null) {
        await _audioServiceManager.updateMediaItem(state.currentSong!);
      }
    }
    _saveQueueToPrefs();
  }

  /// キュー内の指定位置にスキップ
  void skipToQueueItem(int index) {
    if (index == state.currentQueueIndex) {
      if (!state.isPlaying) {
        togglePlayPause();
      }
      return;
    }
    if (index >= 0 && index < state.queue.length) {
      state = state.copyWith(
        currentQueueIndex: index,
        currentSong: state.queue[index],
        isPlaying: true,
      );
      _audioPlayer.seek(Duration.zero, index: index);
      ensureAudioServiceInitialized().then((_) async {
        try {
          if (_audioServiceManager.isInitialized) {
            await _audioServiceManager.updateMediaItem(state.queue[index]);
            await _audioServiceManager.handler.play();
          } else {
            await _audioPlayer.play();
          }
        } catch (e) {
          debugPrint('[Player] skipToQueueItem play error: $e');
          await _audioPlayer.play();
        }
      });
    }
  }

  /// 次に再生に追加
  Future<void> addToQueue(Song song) async {
    final currentPosition = state.position;
    final wasPlaying = state.isPlaying;
    final queue = List<Song>.from(state.queue);
    final insertIndex = state.currentQueueIndex + 1;
    queue.insert(insertIndex, song);

    state = state.copyWith(queue: queue);

    if (_queueSource != null) {
      try {
        if (song.localPath != null) {
          await _queueSource!.insert(
            insertIndex,
            AudioSource.uri(Uri.file(song.localPath!)),
          );
        }
      } catch (e) {
        debugPrint('[Player] failed to insert queue item: $e');
        await _updateAudioSourceQueue(
          queue,
          state.currentQueueIndex,
          position: currentPosition,
          resumeIfPlaying: wasPlaying,
        );
      }
    } else {
      await _updateAudioSourceQueue(
        queue,
        state.currentQueueIndex,
        position: currentPosition,
        resumeIfPlaying: wasPlaying,
      );
    }
    ensureAudioServiceInitialized().then((_) {
      if (_audioServiceManager.isInitialized) {
        _audioServiceManager.updateQueue(queue);
      }
    });
    _saveQueueToPrefs();
  }

  /// just_audioのキューを更新
  Future<void> _updateAudioSourceQueue(
    List<Song> queue,
    int currentIndex, {
    Duration? position,
    bool resumeIfPlaying = false,
  }) async {
    final sources = <AudioSource>[];
    for (final s in queue) {
      if (s.localPath != null) {
        sources.add(AudioSource.uri(Uri.file(s.localPath!)));
      }
    }

    if (sources.isNotEmpty) {
      final concat = ConcatenatingAudioSource(children: sources);
      _queueSource = concat;
      try {
        await _audioPlayer.setAudioSource(
          concat,
          initialIndex: currentIndex,
          initialPosition: position,
        );
        if (resumeIfPlaying) {
          await ensureAudioServiceInitialized();
          if (_audioServiceManager.isInitialized) {
            await _audioServiceManager.handler.play();
          } else {
            await _audioPlayer.play();
          }
        }
      } catch (e) {
        debugPrint('[Player] failed to update audio source: $e');
      }
    } else {
      _queueSource = null;
    }
    _saveQueueToPrefs();
  }

  // Persist queue (song ids) and current index to SharedPreferences
  Future<void> _saveQueueToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = state.queue.map((s) => s.id).toList();
      await prefs.setStringList('saved_queue_ids', ids);
      await prefs.setInt('saved_queue_index', state.currentQueueIndex);
      debugPrint('[Player] saved queue to prefs: ${ids.length} items');
    } catch (e) {
      debugPrint('[Player] failed to save queue prefs: $e');
    }
  }

  Future<void> _restoreQueueFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('saved_queue_ids');
      final idx = prefs.getInt('saved_queue_index') ?? 0;
      if (ids == null || ids.isEmpty) return;
      // Try to map saved ids to existing library songs
      final libState = _ref.read(libraryViewModelProvider);
      final available = libState.songs;
      final restored = <Song>[];
      for (final id in ids) {
        final matches = available.where((x) => x.id == id).toList();
        if (matches.isNotEmpty) restored.add(matches.first);
      }
      if (restored.isNotEmpty) {
        // Use setQueue to restore internal audio player and state
        setQueue(restored, startIndex: idx, autoPlay: false);
        debugPrint('[Player] restored queue from prefs: ${restored.length} items');
      }
    } catch (e) {
      debugPrint('[Player] failed to restore queue prefs: $e');
    }
  }

  /// 歌詞自動送り機能の ON/OFF 切り替え
  void toggleAutoScrollLyrics() {
    // 要件: 自動送りを常時有効にする
    state = state.copyWith(autoScrollLyrics: true);
  }

  /// 歌詞自動送り機能を有効にする
  void setAutoScrollLyrics(bool enabled) {
    state = state.copyWith(autoScrollLyrics: true);
  }

  @override
  void dispose() {
    _silenceSkipTrackStartAt = null;
    _setNativeSkipSilenceEnabled(false);
    _audioServiceManager.stop();
    _audioServicePlaybackSub?.cancel();
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
  final LocalFileImportUseCase _localImportUseCase;
  bool _isBackfillRunning = false;

  LibraryViewModel(this._libraryUseCase, this._localImportUseCase)
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
      _triggerLazyBackfill();
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
      _triggerLazyBackfill();
    } catch (e) {
      print('[Library] ライブラリ更新エラー: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  void _triggerLazyBackfill() {
    if (_isBackfillRunning) return;
    _isBackfillRunning = true;
    _localImportUseCase.backfillUnparsed(limit: 200, batchSize: 30).whenComplete(() {
      _isBackfillRunning = false;
    });
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

  /// 既存ライブラリに重複検出を適用
  Future<int> applyDuplicateDetectionToLibrary() async {
    try {
      final removed = await _localImportUseCase.applyDuplicateDetectionToLibrary();
      await refreshLibrary();
      return removed;
    } catch (_) {
      return 0;
    }
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
    final loaded = await _settingsRepository.getSettings();
    // 無音スキップは現時点で安定性優先のため強制OFF
    if (loaded.silenceSkipEnabled) {
      state = loaded.copyWith(silenceSkipEnabled: false);
      await _settingsRepository.saveSettings(state);
      return;
    }
    state = loaded;
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

  /// テーマ色を更新
  Future<void> updateThemeColors({int? backgroundColor, int? textColor}) async {
    state = state.copyWith(
      themeBackgroundColor: backgroundColor ?? state.themeBackgroundColor,
      themeTextColor: textColor ?? state.themeTextColor,
    );
    await _settingsRepository.saveSettings(state);
  }

  /// 無音スキップ設定を更新
  Future<void> updateSilenceSkip({required bool enabled, required int threshold}) async {
    state = state.copyWith(
      silenceSkipEnabled: enabled,
      silenceSkipThreshold: threshold,
    );
    await _settingsRepository.saveSettings(state);
  }

  /// 設定全体を更新
  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
    await _settingsRepository.saveSettings(state);
  }
}

// YouTubeダウンロード機能は削除されました。関連ViewModelは廃止しています。

// ============================================================================
// ローカルファイル読込ViewModel
// ============================================================================

class LocalImportState {
  final bool isLoading;
  final bool isImporting;
  final String? error;
  final List<Song> importedSongs;
  final int total;
  final int processed;
  final String? statusMessage;
  final ImportResult? lastResult;

  LocalImportState({
    this.isLoading = false,
    this.isImporting = false,
    this.error,
    this.importedSongs = const [],
    this.total = 0,
    this.processed = 0,
    this.statusMessage,
    this.lastResult,
  });

  LocalImportState copyWith({
    bool? isLoading,
    bool? isImporting,
    String? error,
    List<Song>? importedSongs,
    int? total,
    int? processed,
    String? statusMessage,
    ImportResult? lastResult,
  }) {
    return LocalImportState(
      isLoading: isLoading ?? this.isLoading,
      isImporting: isImporting ?? this.isImporting,
      error: error ?? this.error,
      importedSongs: importedSongs ?? this.importedSongs,
      total: total ?? this.total,
      processed: processed ?? this.processed,
      statusMessage: statusMessage ?? this.statusMessage,
      lastResult: lastResult ?? this.lastResult,
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

  /// 複数ファイルのバッチインポート
  Future<ImportResult> importFilesBatched(
    List<String> filePaths, {
    Map<String, String?>? lyricsByPath,
    int batchSize = 30,
    bool? lazyParse,
    bool duplicateDetection = false,
  }) async {
    state = state.copyWith(
      isImporting: true,
      isLoading: true,
      error: null,
      processed: 0,
      total: filePaths.length,
      statusMessage: 'インポート準備中...'
    );

    try {
      final originalTotal = filePaths.length;
      final result = await _importUseCase.importAudioFilesBatched(
        filePaths,
        lyricsByPath: lyricsByPath,
        batchSize: batchSize,
        lazyParse: lazyParse ?? false,
        duplicateDetection: duplicateDetection,
        onProgress: (progress) {
          state = state.copyWith(
            processed: progress.processed,
            total: originalTotal,
            statusMessage: progress.message,
          );
        },
      );

      state = state.copyWith(
        isImporting: false,
        isLoading: false,
        lastResult: result,
        statusMessage: 'インポート完了',
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        isImporting: false,
        isLoading: false,
        error: e.toString(),
      );
      return const ImportResult(total: 0, imported: 0, skipped: 0, failed: 0, lazyParse: false);
    }
  }

  /// フォルダのバッチインポート
  Future<ImportResult> importFolderBatched(
    String folderPath, {
    int batchSize = 30,
    bool? lazyParse,
    bool duplicateDetection = false,
  }) async {
    state = state.copyWith(
      isImporting: true,
      isLoading: true,
      error: null,
      processed: 0,
      total: 0,
      statusMessage: 'フォルダをスキャン中...'
    );

    try {
      final result = await _importUseCase.importAudioFolderBatched(
        folderPath,
        batchSize: batchSize,
        lazyParse: lazyParse,
        duplicateDetection: duplicateDetection,
        onProgress: (progress) {
          state = state.copyWith(
            processed: progress.processed,
            total: progress.total,
            statusMessage: progress.message,
          );
        },
      );

      state = state.copyWith(
        isImporting: false,
        isLoading: false,
        lastResult: result,
        statusMessage: 'インポート完了',
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        isImporting: false,
        isLoading: false,
        error: e.toString(),
      );
      return const ImportResult(total: 0, imported: 0, skipped: 0, failed: 0, lazyParse: false);
    }
  }
}

// ============================================================================
// Riverpod Providers
// ============================================================================

final playerViewModelProvider =
    StateNotifierProvider<PlayerViewModel, PlayerState>((ref) {
  return PlayerViewModel(ref);
});

final libraryViewModelProvider =
    StateNotifierProvider<LibraryViewModel, LibraryState>((ref) {
  final musicRepo = ref.watch(musicRepositoryProvider);
  final useCase = LibraryUseCase(musicRepo);
  final localAudioService = ref.watch(localAudioServiceProvider);
  final importUseCase = LocalFileImportUseCase(localAudioService, musicRepo);
  return LibraryViewModel(useCase, importUseCase);
});

final playlistViewModelProvider =
    StateNotifierProvider<PlaylistViewModel, PlaylistState>((ref) {
  final playlistRepo = ref.watch(playlistRepositoryProvider);
  final useCase = PlaylistUseCase(playlistRepo);
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

// YouTubeダウンロード機能は削除されました。

final localImportViewModelProvider =
    StateNotifierProvider<LocalImportViewModel, LocalImportState>((ref) {
  final audioService = ref.watch(localAudioServiceProvider);
  final musicRepo = ref.watch(musicRepositoryProvider);
  final useCase = LocalFileImportUseCase(audioService, musicRepo);
  return LocalImportViewModel(useCase);
});