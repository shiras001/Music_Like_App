/// LRC歌詞ファイル解析サービス
/// 
/// LRC形式（[mm:ss.xx]歌詞）の解析と歌詞同期機能
/// 参考: LRCStudio アプリ仕様

import 'dart:convert';
import 'dart:io';

/// LRC形式の1行を表現するエンティティ
class LrcLine {
  final int timeMilliseconds; // ミリ秒単位の時間
  final String lyrics;        // 歌詞テキスト

  LrcLine({
    required this.timeMilliseconds,
    required this.lyrics,
  });

  @override
  String toString() => '[$timeMilliseconds] $lyrics';
}

/// LRC歌詞ファイルを解析するサービス
class LrcParseService {
  /// LRCファイルを読み込んで解析
  /// 
  /// [lrcFilePath] - LRCファイルのパス
  /// 戻り値 - 時間順にソートされた LrcLine リスト
  static Future<List<LrcLine>> parseLrcFile(String lrcFilePath) async {
    try {
      final file = File(lrcFilePath);
      
      if (!await file.exists()) {
        print('[LRC] エラー: ファイルが存在しません: $lrcFilePath');
        return [];
      }

      final content = await file.readAsString(encoding: utf8);
      print('[LRC] ファイル読み込み完了: $lrcFilePath (${content.length} bytes)');
      
      final lines = content.split('\n');
      final lrcLines = <LrcLine>[];

      for (final line in lines) {
        final parsed = _parseLrcLine(line);
        if (parsed != null) {
          lrcLines.add(parsed);
          print('[LRC] 行解析: ${parsed.timeMilliseconds}ms - ${parsed.lyrics}');
        }
      }

      // 時間でソート
      lrcLines.sort((a, b) => a.timeMilliseconds.compareTo(b.timeMilliseconds));
      
      print('[LRC] 解析完了: ${lrcLines.length}行');
      return lrcLines;
    } catch (e) {
      print('[LRC] 解析エラー: $e');
      return [];
    }
  }

  /// 単一行を解析（[mm:ss.xx]歌詞 形式）
  /// 
  /// 例: "[00:12.34]歌詞テキスト"
  /// 戻り値 - 解析成功時は LrcLine、失敗時は null
  static LrcLine? _parseLrcLine(String line) {
    final trimmed = line.trim();
    
    if (trimmed.isEmpty) return null;
    
    // [mm:ss.xx] 形式を抽出
    final timePattern = RegExp(r'^\[(\d{2}):(\d{2})\.(\d{2})\](.*)$');
    final match = timePattern.firstMatch(trimmed);
    
    if (match == null) {
      return null;
    }

    try {
      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final centiseconds = int.parse(match.group(3)!);
      final lyrics = match.group(4)!.trim();

      final timeMilliseconds = 
        (minutes * 60 * 1000) + 
        (seconds * 1000) + 
        (centiseconds * 10);

      return LrcLine(
        timeMilliseconds: timeMilliseconds,
        lyrics: lyrics,
      );
    } catch (e) {
      print('[LRC] 行解析失敗: $trimmed - エラー: $e');
      return null;
    }
  }

  /// 指定時間に該当する歌詞行を取得
  /// 
  /// [lrcLines] - 解析済み歌詞行リスト
  /// [currentTimeMilliseconds] - 現在再生時間（ミリ秒）
  /// 戻り値 - 現在の歌詞行、該当なしは null
  static LrcLine? getCurrentLrcLine(
    List<LrcLine> lrcLines,
    int currentTimeMilliseconds,
  ) {
    LrcLine? currentLine;
    
    for (final line in lrcLines) {
      if (line.timeMilliseconds <= currentTimeMilliseconds) {
        currentLine = line;
      } else {
        break;
      }
    }
    
    return currentLine;
  }

  /// 次の歌詞行を取得
  /// 
  /// [lrcLines] - 解析済み歌詞行リスト
  /// [currentIndex] - 現在の行インデックス
  /// 戻り値 - 次の歌詞行、ない場合は null
  static LrcLine? getNextLrcLine(
    List<LrcLine> lrcLines,
    int currentIndex,
  ) {
    if (currentIndex + 1 < lrcLines.length) {
      return lrcLines[currentIndex + 1];
    }
    return null;
  }

  /// 歌詞行のインデックスを取得
  /// 
  /// [lrcLines] - 解析済み歌詞行リスト
  /// [currentTimeMilliseconds] - 現在再生時間（ミリ秒）
  /// 戻り値 - インデックス（見つからない場合は -1）
  static int getCurrentLrcLineIndex(
    List<LrcLine> lrcLines,
    int currentTimeMilliseconds,
  ) {
    for (int i = lrcLines.length - 1; i >= 0; i--) {
      if (lrcLines[i].timeMilliseconds <= currentTimeMilliseconds) {
        return i;
      }
    }
    return -1;
  }
}
