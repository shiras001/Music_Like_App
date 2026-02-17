/// オーディオサービス - MediaSession と バックグラウンド再生制御
/// 
/// iOS: MPRemoteCommandCenter でロック画面/通知を制御
/// Android: MediaSession で通知を表示

import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:just_audio/just_audio.dart';
import '../domain/entities.dart';

/// オーディオサービスを初期化・管理するクラス
class AudioServiceManager {
  static final AudioServiceManager _instance = AudioServiceManager._internal();
  
  late audio_service.AudioHandler _audioHandler;
  bool _isInitialized = false;
  /// 初期化済みフラグの外部参照用
  bool get isInitialized => _isInitialized;
  Future<void>? _initFuture;
  bool _initFailed = false;

  AudioServiceManager._internal();

  factory AudioServiceManager() {
    return _instance;
  }

  /// オーディオサービスを初期化
  Future<void> init(AudioPlayer audioPlayer) async {
    if (_isInitialized || _initFailed) return;
    if (_initFuture != null) return _initFuture!;

    _initFuture = () async {
      try {
        print('[AudioService] init - starting AudioService.init with config');
        _audioHandler = await audio_service.AudioService.init(
          builder: () => _AudioServiceHandler(audioPlayer),
          config: const audio_service.AudioServiceConfig(
            androidNotificationChannelId: 'com.likelife.musiclike.music',
            androidNotificationChannelName: 'Music Playback',
            androidNotificationChannelDescription: 'Music playback controls',
            androidNotificationIcon: 'mipmap/launcher_icon',
            androidShowNotificationBadge: true,
            androidStopForegroundOnPause: false,
            preloadArtwork: true,
          ),
        );
        print('[AudioService] init - AudioService.init returned successfully');
        _isInitialized = true;
        print('[AudioService] 初期化完了');
      } catch (e) {
        _initFailed = true;
        print('[AudioService] 初期化エラー: $e');
      }
    }();

    return _initFuture!;
  }

  /// 現在の AudioHandler を取得
  audio_service.AudioHandler get handler => _audioHandler;

  /// 再生中の曲を更新（ロック画面・通知の更新）
  Future<void> updateMediaItem(Song song) async {
    if (!_isInitialized) return;

    try {
      final item = _buildMediaItem(song);
      await _audioHandler.updateMediaItem(item);
      // Also keep queue/current item in sync for lock-screen metadata
      print('[AudioService] メディアアイテム更新: ${song.title}');
    } catch (e) {
      print('[AudioService] メディアアイテム更新エラー: $e');
    }
  }

  /// キューを更新（通知/ロック画面に反映）
  Future<void> updateQueue(List<Song> songs) async {
    if (!_isInitialized) return;
    try {
      final items = songs.map(_buildMediaItem).toList();
      await _audioHandler.updateQueue(items);
      print('[AudioService] キュー更新: ${items.length}曲');
    } catch (e) {
      print('[AudioService] キュー更新エラー: $e');
    }
  }

  audio_service.MediaItem _buildMediaItem(Song song) {
    return audio_service.MediaItem(
      id: song.id,
      album: song.album,
      title: song.title,
      artist: song.artist,
      duration: song.duration,
      artUri: song.artworkUrl != null
          ? (song.artworkUrl!.startsWith('http')
              ? Uri.parse(song.artworkUrl!)
              : Uri.file(song.artworkUrl!))
          : null,
    );
  }

  /// サービスを停止
  Future<void> stop() async {
    if (!_isInitialized) return;
    try {
      await _audioHandler.stop();
    } catch (e) {
      print('[AudioService] 停止エラー: $e');
    }
  }
}

/// AudioService ハンドラーの実装
class _AudioServiceHandler extends audio_service.BaseAudioHandler with audio_service.SeekHandler {
  final AudioPlayer _audioPlayer;

  _AudioServiceHandler(this._audioPlayer) {
    // just_audio の状態変化を監視して通知バーの状態を自動更新
    _audioPlayer.playbackEventStream.listen((event) {
      _updatePlaybackState();
    });

    // プレイヤー状態の監視（再生/一時停止）
    _audioPlayer.playerStateStream.listen((playerState) {
      _updatePlaybackState();
    });

    // 位置の監視
    _audioPlayer.positionStream.listen((position) {
      _updatePlaybackState();
    });

    // キューのインデックス変化に合わせてメディアアイテムを更新
    _audioPlayer.currentIndexStream.listen((index) {
      if (index == null) return;
      final items = queue.value;
      if (index >= 0 && index < items.length) {
        mediaItem.add(items[index]);
      }
    });

    // 再生時間が確定したらメディアアイテム/キューのdurationを更新
    _audioPlayer.durationStream.listen((duration) {
      if (duration == null) return;
      final index = _audioPlayer.currentIndex;
      if (index == null) return;
      final items = queue.value;
      if (index < 0 || index >= items.length) return;
      final updated = items[index].copyWith(duration: duration);
      mediaItem.add(updated);
      final newQueue = List<audio_service.MediaItem>.from(items);
      newQueue[index] = updated;
      queue.add(newQueue);
    });
  }

  @override
  Future<void> updateQueue(List<audio_service.MediaItem> newQueue) async {
    queue.add(newQueue);
    final index = _audioPlayer.currentIndex ?? 0;
    if (newQueue.isNotEmpty && index >= 0 && index < newQueue.length) {
      mediaItem.add(newQueue[index]);
    }
  }

  @override
  Future<void> updateMediaItem(audio_service.MediaItem item) async {
    mediaItem.add(item);
    final items = queue.value;
    final index = items.indexWhere((q) => q.id == item.id);
    if (index >= 0) {
      final updated = List<audio_service.MediaItem>.from(items);
      updated[index] = item;
      queue.add(updated);
    }
  }

  /// 通知バーの再生状態を更新
  void _updatePlaybackState() {
    final playing = _audioPlayer.playing;
    final processingState = _audioPlayer.processingState;

    // audio_service の PlaybackState に変換
    final audioServiceState = _mapProcessingState(processingState);

    playbackState.add(playbackState.value.copyWith(
      controls: [
        audio_service.MediaControl.skipToPrevious,
        if (playing) audio_service.MediaControl.pause else audio_service.MediaControl.play,
        audio_service.MediaControl.skipToNext,
      ],
      systemActions: const {
        audio_service.MediaAction.seek,
        audio_service.MediaAction.seekForward,
        audio_service.MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: audioServiceState,
      playing: playing,
      updatePosition: _audioPlayer.position,
      bufferedPosition: _audioPlayer.bufferedPosition,
      speed: _audioPlayer.speed,
      queueIndex: _audioPlayer.currentIndex,
    ));
  }

  /// just_audio の ProcessingState を audio_service の AudioProcessingState に変換
  audio_service.AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return audio_service.AudioProcessingState.idle;
      case ProcessingState.loading:
        return audio_service.AudioProcessingState.loading;
      case ProcessingState.buffering:
        return audio_service.AudioProcessingState.buffering;
      case ProcessingState.ready:
        return audio_service.AudioProcessingState.ready;
      case ProcessingState.completed:
        return audio_service.AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      print('[AudioHandler] 再生エラー: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('[AudioHandler] 一時停止エラー: $e');
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('[AudioHandler] シーク エラー: $e');
    }
  }

  @override
  Future<void> skipToNext() async {
    try {
      await _audioPlayer.seekToNext();
    } catch (e) {
      print('[AudioHandler] 次へスキップ エラー: $e');
    }
  }

  @override
  Future<void> skipToPrevious() async {
    try {
      await _audioPlayer.seekToPrevious();
    } catch (e) {
      print('[AudioHandler] 前へスキップ エラー: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      await super.stop();
    } catch (e) {
      print('[AudioHandler] 停止エラー: $e');
    }
  }
}
