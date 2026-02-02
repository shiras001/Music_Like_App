/// ローカルファイル読み込み・メタデータ取得サービス
/// 
/// 機能：
/// - オーディオファイルのスキャン（.m4a, .mp3, .flac, .wav）
/// - メタデータ取得（タイトル、アーティスト、アルバム、ジャケット画像）
/// - LRCファイルの自動検出・関連付け
/// - Song エンティティへの変換

import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../domain/entities.dart';

/// ローカルファイル読み込みサービスのインターフェース
abstract class ILocalAudioService {
  /// 指定されたディレクトリ内のオーディオファイルをスキャン
  /// 
  /// [dirPath] - スキャン対象ディレクトリパス
  /// 
  /// 戻り値：
  /// - Song エンティティのリスト
  /// - 自動的に LRC ファイルが関連付けられる
  Future<List<Song>> scanDirectory(String dirPath);

  /// 単一のオーディオファイルからメタデータを取得
  /// 
  /// [filePath] - オーディオファイルパス
  /// 
  /// 戻り値：
  /// - title: ファイルのメタデータから取得、なければファイル名を使用
  /// - artist: メタデータから取得
  /// - album: メタデータから取得
  /// - artworkData: ジャケット画像（バイナリデータ）
  /// - lyrics: 関連する LRC ファイルが存在すれば読み込み
  /// - duration: オーディオファイルの長さ
  Future<AudioFileMetadata> getMetadata(String filePath);

  /// LRC ファイルを読み込み
  /// 
  /// [lrcPath] - LRC ファイルパス
  /// 
  /// 戻り値：
  /// - 歌詞文字列（LRC形式）
  Future<String> readLyricsFile(String lrcPath);
}

/// オーディオファイルのメタデータ
class AudioFileMetadata {
  final String title;
  final String artist;
  final String album;
  final Uint8List? artworkData; // JPEG/PNG形式のバイナリデータ
  final String lyrics; // LRC形式または通常の歌詞
  final Duration duration;
  final String filePath;

  AudioFileMetadata({
    required this.title,
    required this.artist,
    required this.album,
    this.artworkData,
    this.lyrics = '',
    required this.duration,
    required this.filePath,
  });
}

// Uint8List をインポート
typedef Uint8List = List<int>;

/// ローカルファイル読み込みサービスの実装
/// 
/// 依存ライブラリ：
/// - audio_metadata: メタデータ読み込み
/// - file_picker: ファイル選択（UI層から使用）
class LocalAudioServiceImpl implements ILocalAudioService {
  // サポート対象の拡張子
  static const List<String> supportedExtensions = ['.m4a', '.mp3', '.flac', '.wav'];
  static const String lyricsExtension = '.lrc';

  @override
  Future<List<Song>> scanDirectory(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      if (!directory.existsSync()) return <Song>[];

      final songs = <Song>[];
      final files = directory.listSync(recursive: false);

      for (final entry in files) {
        if (entry is File && isSupportedAudioFile(entry.path)) {
          try {
            final metadata = await getMetadata(entry.path);
            final ext = path.extension(entry.path).toLowerCase();

            String? artworkUrl;
            if (metadata.artworkData != null && metadata.artworkData!.isNotEmpty) {
              try {
                final base = getFileNameWithoutExtension(entry.path);
                final outPath = path.join(path.dirname(entry.path), '${base}_cover.jpg');
                final outFile = File(outPath);
                await outFile.writeAsBytes(metadata.artworkData!);
                artworkUrl = outPath;
              } catch (_) {
                artworkUrl = null;
              }
            }

            final lrcPath = buildLrcPath(entry.path);
            final song = Song(
              id: metadata.filePath,
              title: metadata.title,
              artist: metadata.artist,
              album: metadata.album,
              artworkUrl: artworkUrl,
              duration: metadata.duration,
              fileFormat: ext.replaceFirst('.', '').toUpperCase(),
              isLossless: false,
              isDolbyAtmos: false,
              volumeOffsetDb: 0.0,
              localPath: entry.path,
              isLocal: true,
              lyricsPath: File(lrcPath).existsSync() ? lrcPath : null,
            );
            songs.add(song);
          } catch (e) {
            debugPrint('Failed to read metadata for ${entry.path}: $e');
            // skip
          }
        }
      }

      return songs;
    } catch (e) {
      throw Exception('Failed to scan directory: $e');
    }
  }

  @override
  Future<AudioFileMetadata> getMetadata(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final ext = path.extension(filePath).toLowerCase();

      String title = getFileNameWithoutExtension(filePath);
      String artist = 'Unknown Artist';
      String album = 'Unknown Album';
      Uint8List? artwork;

      // MP4/M4A: look for common atoms (©nam = title, ©ART = artist, ©alb = album)
      if (ext == '.m4a' || ext == '.mp4') {
        final name = _findMp4AtomText(bytes, [0xA9, 0x6E, 0x61, 0x6D]); // ©nam
        final art = _findMp4AtomText(bytes, [0xA9, 0x41, 0x52, 0x54]); // ©ART
        final alb = _findMp4AtomText(bytes, [0xA9, 0x61, 0x6C, 0x62]); // ©alb
        if (name != null && name.isNotEmpty) title = name;
        if (art != null && art.isNotEmpty) artist = art;
        if (alb != null && alb.isNotEmpty) album = alb;
        // cover image
        final mp4Image = _findMp4Image(bytes);
        if (mp4Image != null && mp4Image.isNotEmpty) {
          artwork = mp4Image;
        }
      }

      // MP3: ID3v2 frames (TIT2 = title, TPE1 = artist, TALB = album)
      if (ext == '.mp3') {
        final tit2 = _findId3Frame(bytes, [0x54, 0x49, 0x54, 0x32]); // TIT2
        final tpe1 = _findId3Frame(bytes, [0x54, 0x50, 0x45, 0x31]); // TPE1
        final talb = _findId3Frame(bytes, [0x54, 0x41, 0x4C, 0x42]); // TALB
        if (tit2 != null && tit2.isNotEmpty) title = tit2;
        if (tpe1 != null && tpe1.isNotEmpty) artist = tpe1;
        if (talb != null && talb.isNotEmpty) album = talb;

        final mp3Image = _findMp3Image(bytes);
        if (mp3Image != null && mp3Image.isNotEmpty) artwork = mp3Image;
      }

      final duration = await _estimateDuration(filePath);

      // LRCファイルを探して読み込み
      final lrcPath = buildLrcPath(filePath);
      String lyrics = '';
      if (File(lrcPath).existsSync()) {
        lyrics = await readLyricsFile(lrcPath);
      }

      return AudioFileMetadata(
        title: title,
        artist: artist,
        album: album,
        artworkData: artwork,
        lyrics: lyrics,
        duration: duration,
        filePath: filePath,
      );
    } catch (e) {
      throw Exception('Failed to get metadata: $e');
    }
  }

  /// UTF-16 with BOM をデコード（ID3フレーム用の専用関数）
  /// Encoding=1のID3フレームは必ずBOMを含む
  static String _decodeUtf16WithBom(List<int> bytes) {
    try {
      if (bytes.length >= 2) {
        // UTF-16 LE with BOM
        if (bytes[0] == 0xFF && bytes[1] == 0xFE) {
          final codeUnits = <int>[];
          for (int i = 2; i + 1 < bytes.length; i += 2) {
            codeUnits.add(bytes[i] | (bytes[i + 1] << 8));
          }
          final result = String.fromCharCodes(codeUnits);
          debugPrint('[UTF16LE] Decoded: "$result"');
          return result;
        }
        // UTF-16 BE with BOM
        if (bytes[0] == 0xFE && bytes[1] == 0xFF) {
          final codeUnits = <int>[];
          for (int i = 2; i + 1 < bytes.length; i += 2) {
            codeUnits.add((bytes[i] << 8) | bytes[i + 1]);
          }
          final result = String.fromCharCodes(codeUnits);
          debugPrint('[UTF16BE] Decoded: "$result"');
          return result;
        }
      }
      // No BOM found, assume UTF-16 LE (most common for ID3)
      if (bytes.isNotEmpty) {
        final codeUnits = <int>[];
        for (int i = 0; i + 1 < bytes.length; i += 2) {
          codeUnits.add(bytes[i] | (bytes[i + 1] << 8));
        }
        final result = String.fromCharCodes(codeUnits);
        debugPrint('[UTF16LE_NoBOM] Decoded: "$result"');
        return result;
      }
    } catch (e) {
      debugPrint('[UTF16] Error decoding: $e');
    }
    return '';
  }

  // 汎用テキストデコード: UTF-8, UTF-16 (BOM), latin1 を試す
  static String _decodeTextBytes(List<int> bytes) {
    try {
      return utf8.decode(bytes, allowMalformed: true).trim();
    } catch (_) {}

    // UTF-16 BOM 判定
    if (bytes.length >= 2) {
      if (bytes[0] == 0xFF && bytes[1] == 0xFE) {
        // UTF-16 LE
        final codeUnits = <int>[];
        for (int i = 2; i + 1 < bytes.length; i += 2) {
          codeUnits.add(bytes[i] | (bytes[i + 1] << 8));
        }
        return String.fromCharCodes(codeUnits).trim();
      }
      if (bytes[0] == 0xFE && bytes[1] == 0xFF) {
        // UTF-16 BE
        final codeUnits = <int>[];
        for (int i = 2; i + 1 < bytes.length; i += 2) {
          codeUnits.add((bytes[i] << 8) | bytes[i + 1]);
        }
        return String.fromCharCodes(codeUnits).trim();
      }
    }

    try {
      return latin1.decode(bytes).trim();
    } catch (_) {}
    return String.fromCharCodes(bytes).replaceAll(RegExp(r'[\x00-\x1F]'), '').trim();
  }

  // MP4 atom検索: 指定タグのテキストを返す
  // M4Aファイルの一般的なレイアウト: moov -> udta -> meta(version/flags skip) -> ilst -> [atom] -> data
  static String? _findMp4AtomText(List<int> bytes, List<int> tag) {
    try {
      final tagStr = String.fromCharCodes(tag);
      final box = _findMp4Box(bytes, tag);
      debugPrint('[MP4] Looking for atom $tagStr, found box: ${box != null}, size: ${box?.length}');
      if (box == null) return null;
      
      debugPrint('[MP4] Box contents (first 50 bytes): ${box.take(50).toList()}');
      
      // inside box, find 'data' child atom
      int pos = 0;
      int dataFoundCount = 0;
      while (pos + 8 <= box.length) {
        final size = _readUint32(box, pos);
        if (pos + 8 > box.length) break;
        final type = String.fromCharCodes(box.sublist(pos + 4, pos + 8));
        debugPrint('[MP4] Scanning box at pos=$pos, size=$size, type=$type');
        
        if (type == 'data') {
          dataFoundCount++;
          final header = pos + 8;
          if (header >= box.length) {
            debugPrint('[MP4] data atom too close to end');
            break;
          }
          // data atom format: version(1) + flags(3) + reserved(4) + actual payload
          final payloadStart = math.min(box.length, header + 8);  // Skip 8 bytes (version+flags+reserved)
          final payloadEnd = box.length;
          
          debugPrint('[MP4 data] payloadStart=$payloadStart, payloadEnd=$payloadEnd');
          if (payloadStart >= payloadEnd) {
            debugPrint('[MP4] No payload space');
            break;
          }
          
          final slice = box.sublist(payloadStart, payloadEnd);
          debugPrint('[MP4 data] Payload bytes (first 50): ${slice.take(50).toList()}');
          
          final str = _decodeTextBytesRobust(slice).replaceAll(RegExp(r'[\u0000-\u001F]'), '').trim();
          debugPrint('[MP4 data #$dataFoundCount] Decoded text: "$str"');
          
          if (str.isNotEmpty && !str.contains('JFIF') && !str.contains('PNG')) {
            return str;
          }
          // 次のdataを試す前に継続
        }
        
        if (size <= 8) break;
        pos += size;
      }
      debugPrint('[MP4] Finished scanning box, found $dataFoundCount data atoms');
    } catch (e) {
      debugPrint('[MP4 Error] _findMp4AtomText: $e');
    }
    return null;
  }

  // Try multiple decodings and return the most plausible string
  static String _decodeTextBytesRobust(List<int> bytes) {
    // Try UTF-8
    try {
      final s = utf8.decode(bytes, allowMalformed: false).trim();
      if (_plausibleText(s)) return s;
    } catch (_) {}
    // Try UTF-16 with BOM or heuristics
    try {
      final s = _decodeTextBytes(bytes);
      if (_plausibleText(s)) return s;
    } catch (_) {}
    // Try latin1
    try {
      final s = latin1.decode(bytes, allowInvalid: true).trim();
      if (_plausibleText(s)) return s;
      return s;
    } catch (_) {}
    return String.fromCharCodes(bytes).replaceAll(RegExp(r'[\u0000-\u001F]'), '').trim();
  }

  static bool _plausibleText(String s) {
    if (s.isEmpty) return false;
      final cleaned = s.replaceAll(RegExp(r'[\x00-\x1F]'), '').trim();
      return cleaned.length >= 2;
  }

  // Read big-endian uint32 from bytes at pos
  static int _readUint32(List<int> bytes, int pos) {
    if (pos + 4 > bytes.length) return 0;
    return (bytes[pos] << 24) | (bytes[pos + 1] << 16) | (bytes[pos + 2] << 8) | bytes[pos + 3];
  }

  // Recursive MP4 box finder: returns the box body for the given 4-byte tag
  // Searches through meta/ilst hierarchy commonly used in M4A files
  // Important: meta atom has version/flags that must be skipped
  static List<int>? _findMp4Box(List<int> bytes, List<int> tag) {
    int i = 0;
    while (i + 8 <= bytes.length) {
      final size = _readUint32(bytes, i);
      if (i + 8 > bytes.length) break;
      final type = bytes.sublist(i + 4, i + 8);
      final typeStr = String.fromCharCodes(type);
      
      bool match = true;
      for (int j = 0; j < 4; j++) {
        if (type[j] != tag[j]) {
          match = false;
          break;
        }
      }
      if (match) {
        final bodyStart = i + 8;
        final bodyEnd = (size > 1) ? (i + size) : bytes.length;
        if (bodyStart >= 0 && bodyEnd <= bytes.length && bodyEnd > bodyStart) {
          return bytes.sublist(bodyStart, bodyEnd);
        }
      }
      
      // Recurse into contained boxes (especially meta, ilst, moov, udta, trak)
      if (size > 8 && i + 8 < bytes.length) {
        final bodyStart = i + 8;
        final bodyEnd = (size > 1) ? math.min(i + size, bytes.length) : bytes.length;
        if (bodyEnd > bodyStart && bodyEnd <= bytes.length) {
          // meta atom contains version/flags (4 bytes) before child atoms
          final searchBody = (typeStr == 'meta' && bodyEnd - bodyStart > 4)
              ? bytes.sublist(bodyStart + 4, bodyEnd)  // Skip version/flags
              : bytes.sublist(bodyStart, bodyEnd);
          final found = _findMp4Box(searchBody, tag);
          if (found != null) return found;
        }
      }
      
      if (size <= 0 || size > bytes.length - i) break;
      i += size;
    }
    return null;
  }

  // ID3v2 frame検索: エンコーディングバイトを考慮してデコード
  // Parse ID3v2 frames (supports v2.2, v2.3, v2.4) and retrieve a specific text frame
  static Map<String, List<int>> _parseId3Frames(List<int> bytes) {
    final Map<String, List<int>> frames = {};
    try {
      int idx = -1;
      for (int i = 0; i < math.min(4096, bytes.length - 10); i++) {
        if (bytes[i] == 0x49 && bytes[i + 1] == 0x44 && bytes[i + 2] == 0x33) {
          idx = i;
          break;
        }
      }
      if (idx == -1) return frames;
      final version = bytes[idx + 3];
      // syncsafe tag size
      final tagSize = ((bytes[idx + 6] & 0x7F) << 21) | ((bytes[idx + 7] & 0x7F) << 14) | ((bytes[idx + 8] & 0x7F) << 7) | (bytes[idx + 9] & 0x7F);
      int pos = idx + 10;
      final end = pos + tagSize;
      while (pos + 6 <= end && pos + 6 <= bytes.length) {
        if (version == 2) {
          // ID3v2.2: id(3) size(3)
          if (pos + 6 > end || pos + 6 > bytes.length) break;
          final id = String.fromCharCodes(bytes.sublist(pos, pos + 3));
          final size = (bytes[pos + 3] << 16) | (bytes[pos + 4] << 8) | bytes[pos + 5];
          final headerSize = 6;
          if (size <= 0 || pos + headerSize + size > bytes.length) break;
          final payload = bytes.sublist(pos + headerSize, pos + headerSize + size);
          frames[id] = payload;
          pos += headerSize + size;
        } else {
          // ID3v2.3/2.4: id(4) size(4) flags(2)
          if (pos + 10 > end || pos + 10 > bytes.length) break;
          final id = String.fromCharCodes(bytes.sublist(pos, pos + 4));
          final sizeBytes = bytes.sublist(pos + 4, pos + 8);
          int frameSize = 0;
          if (version >= 4) {
            // syncsafe
            frameSize = ((sizeBytes[0] & 0x7F) << 21) | ((sizeBytes[1] & 0x7F) << 14) | ((sizeBytes[2] & 0x7F) << 7) | (sizeBytes[3] & 0x7F);
          } else {
            frameSize = _readUint32(bytes, pos + 4);
          }
          final headerSize = 10;
          if (frameSize <= 0 || pos + headerSize + frameSize > bytes.length) break;
          final payload = bytes.sublist(pos + headerSize, pos + headerSize + frameSize);
          frames[id] = payload;
          pos += headerSize + frameSize;
        }
      }
    } catch (_) {}
    return frames;
  }

  static String? _findId3Frame(List<int> bytes, List<int> frameId) {
    final frames = _parseId3Frames(bytes);
    final id = String.fromCharCodes(frameId);
    debugPrint('[ID3] Looking for frame: $id, found frames: ${frames.keys.toList()}');
    // fallback mapping for v2.2
    final alt = <String, String>{'TIT2': 'TT2', 'TPE1': 'TP1', 'TALB': 'TAL'};
    List<int>? payload = frames[id];
    if (payload == null && alt.containsKey(id)) {
      final altId = alt[id]!;
      payload = frames[altId];
      debugPrint('[ID3] Frame $id not found, trying alt: $altId, got: ${payload != null}');
    }
    if (payload == null) {
      debugPrint('[ID3] No payload found for $id');
      return null;
    }
    try {
      final encoding = payload[0];
      final textBytes = payload.length > 1 ? payload.sublist(1) : <int>[];
      final id = String.fromCharCodes(frameId);
      debugPrint('[ID3] Frame $id: encoding=$encoding, payloadLen=${payload.length}, textLen=${textBytes.length}');
      // ID3 encoding: 0=ISO-8859-1, 1=UTF-16 w/ BOM, 2=UTF-16BE without BOM, 3=UTF-8
      if (encoding == 0) {
        final s = latin1.decode(textBytes, allowInvalid: true).replaceAll('\x00', '').trim();
        if (_plausibleText(s)) return s;
      }
      if (encoding == 1) {
        // UTF-16 with BOM: use dedicated decoder FIRST
        final s = _decodeUtf16WithBom(textBytes).replaceAll('\x00', '').trim();
        if (s.isNotEmpty && _plausibleText(s)) return s;
      }
      if (encoding == 2) {
        // UTF-16BE without BOM
        try {
          final codeUnits = <int>[];
          for (int i = 0; i + 1 < textBytes.length; i += 2) {
            codeUnits.add((textBytes[i] << 8) | textBytes[i + 1]);
          }
          final s = String.fromCharCodes(codeUnits).replaceAll('\x00', '').trim();
          if (_plausibleText(s)) return s;
        } catch (_) {}
      }
      if (encoding == 3) {
        try {
          final s = utf8.decode(textBytes, allowMalformed: true).replaceAll('\x00', '').trim();
          if (_plausibleText(s)) return s;
        } catch (_) {}
      }
      // fallback tries
      final fallback = _decodeTextBytesRobust(textBytes).replaceAll('\x00', '').trim();
      debugPrint('[ID3] Fallback result for ${String.fromCharCodes(frameId)}: $fallback');
      return fallback.isNotEmpty ? fallback : null;
    } catch (e) {
      debugPrint('[ID3] Exception decoding ${String.fromCharCodes(frameId)}: $e');
      return null;
    }
  }

  // MP3 の APIC フレームから画像データを抽出
  static Uint8List? _findMp3Image(List<int> bytes) {
    // Prefer ID3 APIC frame parsing
    final frames = _parseId3Frames(bytes);
    final apic = frames['APIC'];
    if (apic != null && apic.isNotEmpty) {
      try {
        // APIC payload: encoding(1) + mime (null-terminated) + picture type(1) + description (null-terminated) + image data
        int pos = 0;
        final encoding = apic[pos];
        pos++;
        // read mime string until 0x00
        int mimeEnd = pos;
        while (mimeEnd < apic.length && apic[mimeEnd] != 0x00) mimeEnd++;
        final mime = String.fromCharCodes(apic.sublist(pos, mimeEnd));
        pos = mimeEnd + 1;
        if (pos >= apic.length) return null;
        // skip picture type
        pos += 1;
        // description: null-terminated (encoding aware). We'll skip until 0x00
        int descEnd = pos;
        while (descEnd < apic.length && apic[descEnd] != 0x00) descEnd++;
        pos = descEnd + 1;
        if (pos >= apic.length) return null;
        final imageData = apic.sublist(pos);
        if (imageData.length > 100) return imageData;
      } catch (_) {}
    }
    // fallback: search for JPEG/PNG markers anywhere
    for (int i = 0; i < bytes.length - 8; i++) {
      if (bytes[i] == 0xFF && bytes[i + 1] == 0xD8) {
        for (int j = i + 2; j < bytes.length - 1; j++) {
          if (bytes[j] == 0xFF && bytes[j + 1] == 0xD9) {
            final imageData = bytes.sublist(i, j + 2);
            if (imageData.length > 1000) return imageData;
          }
        }
      }
      if (bytes[i] == 0x89 && bytes[i + 1] == 0x50 && bytes[i + 2] == 0x4E && bytes[i + 3] == 0x47) {
        for (int k = i + 8; k < bytes.length - 8; k++) {
          if (bytes[k] == 0x49 && bytes[k + 1] == 0x45 && bytes[k + 2] == 0x4E && bytes[k + 3] == 0x44) {
            final endPos = (k + 8) < bytes.length ? k + 8 : k + 4;
            final imageData = bytes.sublist(i, endPos);
            if (imageData.length > 1000) return imageData;
          }
        }
      }
    }
    return null;
  }

  // MP4 の covr atom から画像を探す
  static Uint8List? _findMp4Image(List<int> bytes) {
    try {
      // M4A format: covr atom contains data atom with image
      // Search for 'covr' atom
      final covrBox = _findMp4Box(bytes, [0x63, 0x6F, 0x76, 0x72]); // 'covr'
      if (covrBox != null && covrBox.isNotEmpty) {
        // Inside covr box, find 'data' atom
        int pos = 0;
        while (pos + 8 <= covrBox.length) {
          final size = _readUint32(covrBox, pos);
          if (pos + 8 > covrBox.length) break;
          final type = String.fromCharCodes(covrBox.sublist(pos + 4, pos + 8));
          
          if (type == 'data') {
            final header = pos + 8;
            if (header >= covrBox.length) break;
            // data atom: version(1) + flags(3) + reserved(4) + image data
            final imageStart = math.min(covrBox.length, header + 8);
            if (imageStart >= covrBox.length) break;
            
            final imageData = covrBox.sublist(imageStart);
            debugPrint('[MP4 covr] Found data atom with ${imageData.length} bytes');
            
            // Verify it's JPEG or PNG
            if (imageData.length > 1000) {
              if ((imageData[0] == 0xFF && imageData[1] == 0xD8) ||
                  (imageData[0] == 0x89 && imageData[1] == 0x50)) {
                debugPrint('[MP4 covr] Valid image data found');
                return imageData;  // sublistは既にUint8Listを返す
              }
            }
            break;
          }
          
          if (size <= 8) break;
          pos += size;
        }
      }
    } catch (e) {
      debugPrint('[MP4 covr Error] $e');
    }
    
    // Fallback: Search for JPEG/PNG markers in entire file
    for (int i = 0; i < bytes.length - 8; i++) {
      if (bytes[i] == 0xFF && bytes[i + 1] == 0xD8) {
        // JPEG start
        for (int j = i + 2; j < bytes.length - 1; j++) {
          if (bytes[j] == 0xFF && bytes[j + 1] == 0xD9) {
            final imageData = bytes.sublist(i, j + 2);
            if (imageData.length > 1000) {
              debugPrint('[MP4 JPEG fallback] Found JPEG ${imageData.length} bytes');
              return imageData;  // sublistは既にUint8Listを返す
            }
          }
        }
      }
      if (bytes[i] == 0x89 && bytes[i + 1] == 0x50 && bytes[i + 2] == 0x4E && bytes[i + 3] == 0x47) {
        // PNG start
        for (int k = i + 8; k < bytes.length - 8; k++) {
          if (bytes[k] == 0x49 && bytes[k + 1] == 0x45 && bytes[k + 2] == 0x4E && bytes[k + 3] == 0x44) {
            final endPos = (k + 8) < bytes.length ? k + 8 : k + 4;
            final imageData = bytes.sublist(i, endPos);
            if (imageData.length > 1000) {
              debugPrint('[MP4 PNG fallback] Found PNG ${imageData.length} bytes');
              return imageData;  // sublistは既にUint8Listを返す
            }
          }
        }
      }
    }
    debugPrint('[MP4 covr] No image data found');
    return null;
  }

  // Try to parse 'mvhd' atom to get accurate duration for MP4/M4A
  static Duration? _parseMp4DurationFromMvhd(List<int> bytes) {
    for (int i = 0; i < bytes.length - 12; i++) {
      // 'mvhd'
      if (bytes[i] == 0x6D && bytes[i + 1] == 0x76 && bytes[i + 2] == 0x68 && bytes[i + 3] == 0x64) {
        final bodyStart = i + 4; // version at bodyStart
        if (bodyStart + 20 >= bytes.length) continue;
        final version = bytes[bodyStart];
        try {
          if (version == 0) {
            final timescalePos = bodyStart + 12;
            final durationPos = bodyStart + 16;
            if (durationPos + 4 <= bytes.length) {
              final timescale = (bytes[timescalePos] << 24) | (bytes[timescalePos + 1] << 16) | (bytes[timescalePos + 2] << 8) | bytes[timescalePos + 3];
              final duration = (bytes[durationPos] << 24) | (bytes[durationPos + 1] << 16) | (bytes[durationPos + 2] << 8) | bytes[durationPos + 3];
              if (timescale > 0 && duration >= 0) {
                final secs = duration / timescale;
                return Duration(seconds: secs.toInt());
              }
            }
          } else if (version == 1) {
            final timescalePos = bodyStart + 20; // version(1)+flags(3)+creation(8)+mod(8)
            final durationPos = bodyStart + 24; // duration is 8 bytes, but we'll read as 64-bit
            if (timescalePos + 4 <= bytes.length && durationPos + 8 <= bytes.length) {
              final timescale = (bytes[timescalePos] << 24) | (bytes[timescalePos + 1] << 16) | (bytes[timescalePos + 2] << 8) | bytes[timescalePos + 3];
              final duration =
                  (bytes[durationPos] << 56) |
                  (bytes[durationPos + 1] << 48) |
                  (bytes[durationPos + 2] << 40) |
                  (bytes[durationPos + 3] << 32) |
                  (bytes[durationPos + 4] << 24) |
                  (bytes[durationPos + 5] << 16) |
                  (bytes[durationPos + 6] << 8) |
                  bytes[durationPos + 7];
              if (timescale > 0 && duration >= 0) {
                final secs = duration / timescale;
                return Duration(seconds: secs.toInt());
              }
            }
          }
        } catch (_) {}
      }
    }
    return null;
  }

  @override
  Future<String> readLyricsFile(String lrcPath) async {
    try {
      final file = File(lrcPath);
      if (!file.existsSync()) {
        return '';
      }
      
      // UTF-8で読み込み
      final content = await file.readAsString();
      return content;
    } catch (e) {
      debugPrint('Failed to read lyrics file: $e');
      return '';
    }
  }

  /// ファイルの再生時間を推定（ファイルサイズから）
  /// 注：正確な時間を得るには、オーディオライブラリが必要
  static Future<Duration> _estimateDuration(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.length();
      // Try to detect MP3 bitrate for a better estimate
      final ext = path.extension(filePath).toLowerCase();
      // For MP4/M4A try parsing mvhd atom for accurate duration
      if (ext == '.m4a' || ext == '.mp4') {
        try {
          final fh = await File(filePath).open();
          final head = await fh.read(math.min(200000, bytes));
          await fh.close();
          final parsed = _parseMp4DurationFromMvhd(head);
          if (parsed != null && parsed.inSeconds > 0) return parsed;
        } catch (_) {}
      }
      if (ext == '.mp3') {
        try {
          final fh = await File(filePath).open();
          // 最初の100KBを読み込む（ビットレートヘッダーは通常最初の方にある）
          final head = await fh.read(math.min(100000, bytes));
          await fh.close();
          
          // Calculate ID3 tag size to exclude from audio data
          int id3Size = 0;
          for (int i = 0; i < math.min(4096, head.length - 10); i++) {
            if (head[i] == 0x49 && head[i + 1] == 0x44 && head[i + 2] == 0x33) {
              // ID3v2 tag found
              final sizeBytes = head.sublist(i + 6, i + 10);
              // Synchsafe integer: ignore bit 7 of each byte
              id3Size = ((sizeBytes[0] & 0x7F) << 21) |
                        ((sizeBytes[1] & 0x7F) << 14) |
                        ((sizeBytes[2] & 0x7F) << 7) |
                        (sizeBytes[3] & 0x7F);
              id3Size += 10; // Include 10-byte header
              debugPrint('[MP3] ID3 tag size: $id3Size bytes');
              break;
            }
          }
          
          // ビットレートヘッダーをスキャン
          // MP3フレームヘッダー: 0xFF 0xFBまたは0xFF 0xFA (11ビット = 1のフレーム同期)
          for (int i = id3Size; i < head.length - 4; i++) {
            if (head[i] == 0xFF && (head[i + 1] & 0xE0) == 0xE0) {
              // 有効なフレームヘッダーを発見
              final byte1 = head[i + 1];
              final byte2 = head[i + 2];
              
              // MPEG version (bits 4-3 of byte1)
              final versionBits = (byte1 >> 3) & 0x03;
              // Layer (bits 2-1 of byte1)
              final layerBits = (byte1 >> 1) & 0x03;
              // Bitrate index (bits 7-4 of byte2)
              final bitrateIndex = (byte2 >> 4) & 0x0F;

              // ビットレートテーブル (MPEG1 Layer3 が最一般的)
              final mpeg1Layer3 = [0,32,40,48,56,64,80,96,112,128,160,192,224,256,320,0];
              final mpeg2Layer3 = [0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,0];
              
              int bitrateKbps = 0;
              if (bitrateIndex > 0 && bitrateIndex < 15) {
                if (versionBits == 3) { // MPEG1
                  bitrateKbps = mpeg1Layer3[bitrateIndex];
                } else { // MPEG2 or MPEG2.5
                  bitrateKbps = mpeg2Layer3[bitrateIndex];
                }
              }
              
              if (bitrateKbps > 0) {
                final bitrateBps = bitrateKbps * 1000;
                final audioDataSize = bytes - id3Size;
                final durationSeconds = (audioDataSize * 8) / bitrateBps;
                debugPrint('[MP3] Found frame at offset=$i, bitrate=$bitrateKbps kbps, audioSize=$audioDataSize, duration=${durationSeconds.toInt()}s');
                return Duration(seconds: durationSeconds.toInt());
              }
            }
          }
          debugPrint('[MP3] No valid frame header found');
        } catch (e) {
          debugPrint('[MP3] Duration parsing error: $e');
        }
      }

      // 単純な推定：ビットレート 128kbps と仮定
      // 128 kbps = 128000 bits/s
      const int estimatedBitrate = 128000; // bits per second
      final durationSeconds = (bytes * 8) / estimatedBitrate;
      
      return Duration(seconds: durationSeconds.toInt());
    } catch (e) {
      return Duration.zero;
    }
  }

  /// ファイル名（拡張子なし）を取得
  static String getFileNameWithoutExtension(String filePath) {
    final fileName = path.basename(filePath);
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return fileName;
    return fileName.substring(0, lastDot);
  }

  /// LRC ファイルのパスを構築
  static String buildLrcPath(String audioFilePath) {
    final dir = path.dirname(audioFilePath);
    final nameWithoutExt = getFileNameWithoutExtension(audioFilePath);
    return path.join(dir, '$nameWithoutExt$lyricsExtension');
  }

  /// 拡張子のチェック
  static bool isSupportedAudioFile(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return supportedExtensions.contains(ext);
  }
}
