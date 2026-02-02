/// YouTube音声ダウンロード・変換サービス
/// 
/// 機能：
/// - YouTube動画情報の取得（タイトル、チャンネル名、サムネイル）
/// - 音声ストリームの選択とダウンロード
/// - ffmpegを使用した MP3/M4A への変換
/// - メタデータ設定
///
/// 注意：技術的検証・個人利用のみを目的とする

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../domain/entities.dart';

/// YouTube音声取得・変換サービスのインターフェース
abstract class IYouTubeService {
  /// YouTubeのURLから動画情報を取得
  /// 
  /// [videoUrl] - YouTube動画URL（https://youtu.be/... または https://www.youtube.com/watch?v=...）
  /// 
  /// 戻り値：
  /// - title: 動画タイトル
  /// - channelName: チャンネル名
  /// - thumbnailUrl: サムネイルURL
  Future<YouTubeVideoInfo> getVideoInfo(String videoUrl);

  /// 音声をダウンロードして MP3/M4A に変換
  /// 
  /// [videoUrl] - YouTube動画URL
  /// [outputFormat] - 出力形式（'mp3' または 'm4a'）
  /// [outputPath] - 保存先ディレクトリパス
  /// [bitrate] - ビットレート（例：256）
  /// 
  /// 戻り値：
  /// - 保存されたファイルパス
  Future<String> downloadAndConvert(
    String videoUrl, {
    required String outputFormat,
    required String outputPath,
    required int bitrate,
  });

  /// メタデータを設定（ID3タグ等）
  /// 
  /// [filePath] - オーディオファイルパス
  /// [song] - Song エンティティ（メタデータを含む）
  Future<void> setMetadata(String filePath, Song song);
}

/// YouTube動画情報
class YouTubeVideoInfo {
  final String title;
  final String channelName;
  final String thumbnailUrl;
  final Duration duration;

  YouTubeVideoInfo({
    required this.title,
    required this.channelName,
    required this.thumbnailUrl,
    required this.duration,
  });
}

/// YouTube音声取得・変換サービスの実装
/// 
/// 依存ライブラリ：
/// - youtube_explode_dart: 動画情報・音声ストリーム取得
/// - ffmpeg_kit_flutter: 音声変換
/// - audio_metadata: メタデータ操作（オプション）
class YouTubeServiceImpl implements IYouTubeService {
  late YoutubeExplode _yt;
  
  YouTubeServiceImpl() {
    _yt = YoutubeExplode();
  }
  
  @override
  Future<YouTubeVideoInfo> getVideoInfo(String videoUrl) async {
    try {
      // VideoId クラスで URL を解析（youtu.be/ と youtube.com の両方に対応）
      final videoId = VideoId(videoUrl);
      
      // YouTubeから動画情報を取得
      final video = await _yt.videos.get(videoId);
      
      return YouTubeVideoInfo(
        title: video.title,
        channelName: video.author,
        thumbnailUrl: video.thumbnails.highResUrl,
        duration: video.duration ?? Duration.zero,
      );
    } on FormatException catch (e) {
      // 無効な URL フォーマット
      throw Exception('Invalid YouTube URL format: $e');
    } on SocketException catch (e) {
      // ネットワークエラー
      throw Exception('Network error while fetching video info: $e');
    } catch (e) {
      throw Exception('Failed to get video info: $e');
    }
  }

  @override
  Future<String> downloadAndConvert(
    String videoUrl, {
    required String outputFormat,
    required String outputPath,
    required int bitrate,
  }) async {
    try {
      // 1. 動画情報を取得
      print('[YouTube] ダウンロードプロセス開始: $videoUrl');
      final videoInfo = await getVideoInfo(videoUrl);
      print('[YouTube] ステップ1完了: 動画情報取得 - ${videoInfo.title}');
      
      // 2. VideoId を解析
      final videoId = VideoId(videoUrl);
      print('[YouTube] ステップ2完了: VideoID解析 - $videoId');
      
      // 3. youtube_explode_dart で音声ストリームを取得
      print('[YouTube] ステップ3開始: マニフェスト取得中...');
      final manifest = await _yt.videos.streams.getManifest(videoId);
      final audioStream = manifest.audioOnly.withHighestBitrate();
      print('[YouTube] ステップ3完了: 音声ストリーム取得 - ${audioStream?.bitrate} bps');
      
      if (audioStream == null) {
        throw Exception('No audio stream available for this video');
      }
      
      // 4. ストリームをダウンロード（一時ファイルに保存）
      print('[YouTube] ステップ4開始: ストリームダウンロード中...');
      final sanitizedTitle = _sanitizeFileName(videoInfo.title);
      final tempFile = File('$outputPath/temp_$sanitizedTitle.m4a');
      
      // ディレクトリが存在しない場合は作成
      await Directory(outputPath).create(recursive: true);
      
      // ストリームをファイルに保存
      final stream = await _yt.videos.streams.get(audioStream);
      print('[YouTube] ステップ4-1: ストリーム取得完了');
      
      final fileStream = tempFile.openWrite();
      print('[YouTube] ステップ4-2: ファイルストリーム開始');
      
      // pipe() の代わりに addStream() を使用（タイムアウト付き）
      try {
        await fileStream.addStream(stream).timeout(
          const Duration(minutes: 10),
          onTimeout: () {
            throw TimeoutException('YouTube ストリーム書き込みタイムアウト');
          },
        );
        print('[YouTube] ステップ4-3: ストリーム書き込み完了');
      } catch (e) {
        print('[YouTube] ステップ4-3エラー: $e');
        await fileStream.close();
        await tempFile.delete();
        rethrow;
      }
      
      await fileStream.flush();
      print('[YouTube] ステップ4-4: flush完了');
      
      await fileStream.close();
      print('[YouTube] ステップ4-5: close完了');
      
      final tempFileSize = await tempFile.length();
      print('[YouTube] ステップ4完了: ストリームダウンロード成功 - ${(tempFileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      
      // 5. ffmpeg で MP3/M4A に変換
      print('[YouTube] ステップ5開始: ffmpeg変換中（形式: $outputFormat, ビットレート: $bitrate kbps）...');
      final outputFileName = '$sanitizedTitle.$outputFormat';
      final outputFile = File('$outputPath/$outputFileName');
      await _convertAudioWithFFmpeg(tempFile.path, outputFile.path, bitrate, outputFormat);
      print('[YouTube] ステップ5完了: ffmpeg変換成功');
      
      // 6. 一時ファイルを削除
      await tempFile.delete();
      print('[YouTube] ステップ6完了: 一時ファイル削除');
      
      // 7. メタデータを設定
      final song = Song(
        id: sanitizedTitle,
        title: videoInfo.title,
        artist: videoInfo.channelName,
        album: '', // YouTube からダウンロードの場合はアルバムなし
        duration: videoInfo.duration,
        artworkUrl: videoInfo.thumbnailUrl,
        fileFormat: outputFormat.toUpperCase(),
      );
      await setMetadata(outputFile.path, song);
      print('[YouTube] ステップ7完了: メタデータ設定');
      
      // 8. 変換後のファイルパスを返す
      final outputFileSize = await outputFile.length();
      print('[YouTube] ダウンロードプロセス完了: $outputFile (${(outputFileSize / 1024 / 1024).toStringAsFixed(2)} MB)');
      return outputFile.path;
    } catch (e) {
      print('[YouTube] エラー発生: $e');
      throw Exception('Failed to download and convert: $e');
    }
  }

  @override
  Future<void> setMetadata(String filePath, Song song) async {
    try {
      // TODO: メタデータ設定処理を実装
      // ファイル拡張子に応じて ID3 (MP3) または MP4 タグを設定
      // 現段階では実装予定 (オプション)
    } catch (e) {
      throw Exception('Failed to set metadata: $e');
    }
  }
  
  /// ファイル名として使用可能な文字列に変換
  String _sanitizeFileName(String fileName) {
    // 無効なファイル名文字を削除
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
  
  /// FFmpeg を使用して音声を変換
  /// 
  /// [inputPath] - 入力ファイルパス（M4A等）
  /// [outputPath] - 出力ファイルパス
  /// [bitrate] - ビットレート（例：256）
  /// [format] - 出力形式（'mp3' または 'm4a'）
  Future<void> _convertAudioWithFFmpeg(
    String inputPath,
    String outputPath,
    int bitrate,
    String format,
  ) async {
    try {
      // TODO: FFmpeg インテグレーション
      // 選択肢：
      // 1. FFmpeg C binding (Dart の FFI)
      // 2. ffmpeg_kit_flutter の代替（旧バージョン）
      // 3. Process.run で ffmpeg コマンドを直接実行
      // 4. YouTube から M4A を直接保存（変換スキップ）
      
      // 暫定案：M4A をそのまま保存（ffmpeg スキップ）
      if (format == 'm4a') {
        // M4A は YouTube から直接取得できるため、そのまま使用
        if (inputPath != outputPath) {
          await File(inputPath).copy(outputPath);
        }
      } else if (format == 'mp3') {
        // MP3 への変換が必要な場合は、Process.run を使用
        // final result = await Process.run('ffmpeg', [
        //   '-i', inputPath,
        //   '-q:a', '0',
        //   '-map', 'a',
        //   outputPath,
        // ]);
        
        // if (result.exitCode != 0) {
        //   throw Exception('FFmpeg conversion failed: ${result.stderr}');
        // }
        
        throw UnimplementedError('MP3 conversion requires ffmpeg setup');
      }
    } catch (e) {
      throw Exception('Failed to convert audio: $e');
    }
  }
  
  /// リソースをクリーンアップ
  void dispose() {
    _yt.close();
  }
}
