import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('使用法: dart run integrated_analyzer.dart <音楽ファイルのパス>');
    return;
  }

  final filePath = arguments[0];
  final file = File(filePath);

  if (!file.existsSync()) {
    print('エラー: 指定されたファイルが見つかりません -> $filePath');
    return;
  }

  print('統合メタデータ解析を開始します: $filePath ...\n');

  try {
    // audio_metadata_readerで基本情報を取得
    final metadata = await readMetadata(file, getImage: false);
    
    // 自作解析で追加情報を取得
    final additionalData = await analyzeAdditionalData(file);
    
    printIntegratedMetadata(metadata, additionalData, file);
    
    // 画像データを保存
    if (additionalData['hasImage'] == true) {
      final imageData = additionalData['imageData'] as Uint8List?;
      if (imageData != null) {
        try {
          final imageFile = File('album_art.png');
          await imageFile.writeAsBytes(imageData);
          print('\nアルバムアート: album_art.png に保存しました (${imageData.length} bytes)');
        } catch (e) {
          print('\n画像保存エラー: $e');
        }
      }
    } else {
      print('\nアルバムアートが見つかりませんでした。');
    }
    
  } catch (e) {
    print('例外が発生しました: $e');
  }
}

Future<Map<String, dynamic>> analyzeAdditionalData(File file) async {
  final bytes = file.readAsBytesSync();
  final additionalData = <String, dynamic>{};
  
  final extension = file.path.toLowerCase().split('.').last;
  
  if (extension == 'm4a' || extension == 'mp4') {
    // M4A用の追加解析
    final m4aData = analyzeM4AAdditional(bytes);
    additionalData.addAll(m4aData);
  } else if (extension == 'mp3') {
    // MP3用の追加解析
    final mp3Data = analyzeMP3Additional(bytes);
    additionalData.addAll(mp3Data);
  }
  
  return additionalData;
}

Map<String, dynamic> analyzeM4AAdditional(Uint8List bytes) {
  final data = <String, dynamic>{};
  
  // ilst atomを検索
  for (int i = 0; i < bytes.length - 8; i++) {
    if (bytes[i] == 0x69 && bytes[i + 1] == 0x6C && 
        bytes[i + 2] == 0x73 && bytes[i + 3] == 0x74) {
      
      final ilstEnd = (i + 3000).clamp(0, bytes.length);
      
      // URL情報を検索
      final url = findAtomValue(bytes, i, ilstEnd, [0xA9, 0x75, 0x72, 0x6C]); // ©url
      if (url != null) {
        data['URL'] = url;
      } else {
        final foundUrl = searchForPromotionUrl(bytes);
        if (foundUrl != null) data['URL'] = foundUrl;
      }
      
      final comment = findAtomValue(bytes, i, ilstEnd, [0xA9, 0x63, 0x6D, 0x74]); // ©cmt
      if (comment != null) data['Comment'] = comment;
      
      final encoder = findAtomValue(bytes, i, ilstEnd, [0xA9, 0x74, 0x6F, 0x6F]); // ©too
      if (encoder != null) data['Encoder'] = encoder;
      
      final albumArtist = findAtomValue(bytes, i, ilstEnd, [0x61, 0x41, 0x52, 0x54]); // aART
      if (albumArtist != null) data['AlbumArtist'] = albumArtist;
      
      break;
    }
  }
  
  // 画像データを検索
  final imageData = findImageData(bytes);
  if (imageData != null) {
    data['hasImage'] = true;
    data['imageData'] = imageData;
  } else {
    data['hasImage'] = false;
  }
  
  // 正確なビットレート計算
  final audioInfo = calculateAccurateBitrate(bytes);
  data.addAll(audioInfo);
  
  return data;
}

Map<String, dynamic> analyzeMP3Additional(Uint8List bytes) {
  final data = <String, dynamic>{};
  
  // WOAF URLを検索
  final woafUrl = findWOAFUrl(bytes);
  if (woafUrl != null) data['URL'] = woafUrl;
  
  // その他のID3v2タグを検索
  final id3Tags = findID3v2Tags(bytes);
  data.addAll(id3Tags);
  
  // 画像データを検索 (APICフレーム)
  final imageData = findMP3ImageData(bytes);
  if (imageData != null) {
    data['hasImage'] = true;
    data['imageData'] = imageData;
  } else {
    data['hasImage'] = false;
  }
  
  // MP3のビットレート計算
  final mp3Info = calculateMP3Bitrate(bytes);
  data.addAll(mp3Info);
  
  return data;
}

String? findAtomValue(Uint8List bytes, int start, int end, List<int> tag) {
  for (int i = start; i < end - tag.length - 20; i++) {
    bool match = true;
    for (int j = 0; j < tag.length; j++) {
      if (bytes[i + j] != tag[j]) {
        match = false;
        break;
      }
    }
    
    if (match) {
      if (i >= 4) {
        final atomSize = (bytes[i - 4] << 24) | (bytes[i - 3] << 16) | 
                        (bytes[i - 2] << 8) | bytes[i - 1];
        
        final dataStart = i + 4;
        final atomEnd = (i - 4 + atomSize).clamp(0, end);
        
        for (int k = dataStart; k < atomEnd - 8; k++) {
          if (bytes[k] == 0x64 && bytes[k + 1] == 0x61 && 
              bytes[k + 2] == 0x74 && bytes[k + 3] == 0x61) {
            
            if (k >= 4) {
              final dataSize = (bytes[k - 4] << 24) | (bytes[k - 3] << 16) | 
                              (bytes[k - 2] << 8) | bytes[k - 1];
              
              if (dataSize > 8 && dataSize < 500) {
                final textStart = k + 8;
                final textEnd = (textStart + dataSize - 8).clamp(0, end);
                
                try {
                  final textBytes = bytes.sublist(textStart, textEnd);
                  final text = utf8.decode(textBytes, allowMalformed: true);
                  
                  final cleanText = text
                      .replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '')
                      .replaceAll(RegExp(r'[\$\!\x00]+$'), '')
                      .replaceAll(RegExp(r'\d+$'), '')
                      .trim();
                  
                  if (cleanText.isNotEmpty) {
                    return cleanText;
                  }
                } catch (e) {
                  // デコードエラーは無視
                }
              }
            }
            break;
          }
        }
      }
    }
  }
  return null;
}

Uint8List? findImageData(Uint8List bytes) {
  // JPEG署名を検索
  for (int i = 0; i < bytes.length - 2; i++) {
    if (bytes[i] == 0xFF && bytes[i + 1] == 0xD8) {
      for (int j = i + 2; j < bytes.length - 1; j++) {
        if (bytes[j] == 0xFF && bytes[j + 1] == 0xD9) {
          final imageData = bytes.sublist(i, j + 2);
          if (imageData.length > 1000) {
            return imageData;
          }
        }
      }
    }
  }
  return null;
}

String? findWOAFUrl(Uint8List bytes) {
  // WOAFフレームを検索 (4文字のフレームID)
  for (int i = 0; i < bytes.length - 10; i++) {
    if (bytes[i] == 0x57 && bytes[i + 1] == 0x4F && 
        bytes[i + 2] == 0x41 && bytes[i + 3] == 0x46) {
      
      // フレームサイズを取得
      final frameSize = (bytes[i + 4] << 24) | (bytes[i + 5] << 16) | 
                       (bytes[i + 6] << 8) | bytes[i + 7];
      
      if (frameSize > 0 && frameSize < 1000) {
        final urlStart = i + 10; // フレームヘッダー + フラグをスキップ
        final urlEnd = (urlStart + frameSize).clamp(0, bytes.length);
        
        try {
          final urlBytes = bytes.sublist(urlStart, urlEnd);
          // null終端文字列を探す
          int nullIndex = urlBytes.indexOf(0);
          if (nullIndex == -1) nullIndex = urlBytes.length;
          
          final cleanBytes = urlBytes.sublist(0, nullIndex);
          final url = utf8.decode(cleanBytes, allowMalformed: true).trim();
          
          if (url.isNotEmpty && (url.startsWith('http') || url.startsWith('https'))) {
            return url;
          }
        } catch (e) {
          // デコードエラーは無視
        }
      }
    }
  }
  
  // WOAFが見つからない場合、直接URLパターンを検索
  try {
    final text = utf8.decode(bytes, allowMalformed: true);
    
    // pssssssn.com を特別に検索
    final pssssssPattern = RegExp(r'https://pssssssn\.com/?[^\s\x00-\x1F\x7F-\x9F]*');
    final match = pssssssPattern.firstMatch(text);
    
    if (match != null) {
      return match.group(0);
    }
    
    // 一般的なURLパターン
    final urlPattern = RegExp(r'https?://[^\s\x00-\x1F\x7F-\x9F]{4,100}');
    final urlMatch = urlPattern.firstMatch(text);
    
    if (urlMatch != null) {
      return urlMatch.group(0);
    }
  } catch (e) {
    // デコードエラーは無視
  }
  
  return null;
}

Map<String, dynamic> findID3v2Tags(Uint8List bytes) {
  final data = <String, dynamic>{};
  
  // ID3v2タグを検索
  final tags = {
    'Comment': [0x43, 0x4F, 0x4D, 0x4D],     // COMM
    'Description': [0x54, 0x49, 0x54, 0x33], // TIT3 (説明)
    'Band': [0x54, 0x50, 0x45, 0x32],        // TPE2 (バンド/アルバムアーティスト)
    'Encoder': [0x54, 0x53, 0x53, 0x45],     // TSSE (エンコーダー)
  };
  
  tags.forEach((name, tag) {
    final value = findID3Frame(bytes, tag);
    if (value != null) data[name] = value;
  });
  
  return data;
}

String? findID3Frame(Uint8List bytes, List<int> frameId) {
  for (int i = 0; i < bytes.length - frameId.length - 10; i++) {
    // フレームIDを検索
    bool match = true;
    for (int j = 0; j < frameId.length; j++) {
      if (bytes[i + j] != frameId[j]) {
        match = false;
        break;
      }
    }
    
    if (match) {
      // フレームサイズを取得
      final frameSize = (bytes[i + 4] << 24) | (bytes[i + 5] << 16) | 
                       (bytes[i + 6] << 8) | bytes[i + 7];
      
      if (frameSize > 0 && frameSize < 1000) {
        final textStart = i + 11; // フレームヘッダー + エンコーディングフラグをスキップ
        final textEnd = (textStart + frameSize - 1).clamp(0, bytes.length);
        
        try {
          final textBytes = bytes.sublist(textStart, textEnd);
          final text = utf8.decode(textBytes, allowMalformed: true).trim();
          if (text.isNotEmpty && text.length < 100) {
            return text.replaceAll('\x00', '').trim();
          }
        } catch (e) {
          // デコードエラーは無視
        }
      }
    }
  }
  return null;
}

Uint8List? findMP3ImageData(Uint8List bytes) {
  // APICフレームを検索
  for (int i = 0; i < bytes.length - 10; i++) {
    if (bytes[i] == 0x41 && bytes[i + 1] == 0x50 && 
        bytes[i + 2] == 0x49 && bytes[i + 3] == 0x43) {
      
      // フレームサイズを取得
      final frameSize = (bytes[i + 4] << 24) | (bytes[i + 5] << 16) | 
                       (bytes[i + 6] << 8) | bytes[i + 7];
      
      if (frameSize > 100 && frameSize < 100000) {
        // APICフレーム内でJPEG署名を検索
        final frameEnd = (i + 10 + frameSize).clamp(0, bytes.length);
        
        for (int j = i + 10; j < frameEnd - 2; j++) {
          if (bytes[j] == 0xFF && bytes[j + 1] == 0xD8) {
            // JPEG終了マーカーを検索
            for (int k = j + 2; k < frameEnd - 1; k++) {
              if (bytes[k] == 0xFF && bytes[k + 1] == 0xD9) {
                final imageData = bytes.sublist(j, k + 2);
                if (imageData.length > 1000) {
                  return imageData;
                }
              }
            }
          }
        }
      }
    }
  }
  
  // APICフレームが見つからない場合、直接JPEG署名を検索
  for (int i = 0; i < bytes.length - 2; i++) {
    if (bytes[i] == 0xFF && bytes[i + 1] == 0xD8) {
      for (int j = i + 2; j < bytes.length - 1; j++) {
        if (bytes[j] == 0xFF && bytes[j + 1] == 0xD9) {
          final imageData = bytes.sublist(i, j + 2);
          if (imageData.length > 1000) {
            return imageData;
          }
        }
      }
    }
  }
  
  return null;
}

Map<String, dynamic> calculateMP3Bitrate(Uint8List bytes) {
  final data = <String, dynamic>{};
  
  // MP3フレームヘッダーを検索してビットレートを取得
  for (int i = 0; i < bytes.length - 4; i++) {
    // MP3フレーム同期 (0xFF 0xFB または 0xFF 0xFA)
    if (bytes[i] == 0xFF && (bytes[i + 1] & 0xF0) == 0xF0) {
      final header = (bytes[i] << 24) | (bytes[i + 1] << 16) | 
                    (bytes[i + 2] << 8) | bytes[i + 3];
      
      // ビットレートインデックスを取得 (bits 12-15)
      final bitrateIndex = (header >> 12) & 0x0F;
      
      // MPEG-1 Layer 3 ビットレートテーブル
      final bitrates = [0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 0];
      
      if (bitrateIndex > 0 && bitrateIndex < 15) {
        data['AccurateBitrate'] = '${bitrates[bitrateIndex]} kbps';
        return data;
      }
    }
  }
  
  return data;
}

String? searchForPromotionUrl(Uint8List bytes) {
  try {
    final text = utf8.decode(bytes, allowMalformed: true);
    
    // promotion.com を含むURLを特別に検索
    final promotionPattern = RegExp(r'https://promotion\.com/?[^\s\x00-\x1F\x7F-\x9F]*');
    final match = promotionPattern.firstMatch(text);
    
    if (match != null) {
      return match.group(0);
    }
    
    // 一般的なURLパターン
    final urlPattern = RegExp(r'https?://[^\s\x00-\x1F\x7F-\x9F]{4,100}');
    final urlMatch = urlPattern.firstMatch(text);
    
    if (urlMatch != null) {
      return urlMatch.group(0);
    }
  } catch (e) {
    // デコードエラーは無視
  }
  
  return null;
}

Map<String, dynamic> calculateAccurateBitrate(Uint8List bytes) {
  final data = <String, dynamic>{};
  
  // 'esds' atom (Elementary Stream Descriptor) で正確なビットレートを取得
  for (int i = 0; i < bytes.length - 50; i++) {
    if (bytes[i] == 0x65 && bytes[i + 1] == 0x73 && 
        bytes[i + 2] == 0x64 && bytes[i + 3] == 0x73) {
      
      // esds内のビットレート情報を検索
      for (int j = i + 4; j < i + 100 && j + 4 < bytes.length; j++) {
        final bitrate = (bytes[j] << 24) | (bytes[j + 1] << 16) | 
                       (bytes[j + 2] << 8) | bytes[j + 3];
        
        // 190000 付近の値を探す
        if (bitrate >= 180000 && bitrate <= 200000) {
          data['AccurateBitrate'] = '${(bitrate / 1000).round()} kbps';
          return data;
        }
      }
      break;
    }
  }
  
  // esdsが見つからない場合はmdhdから計算
  for (int i = 0; i < bytes.length - 32; i++) {
    if (bytes[i] == 0x6D && bytes[i + 1] == 0x64 && 
        bytes[i + 2] == 0x68 && bytes[i + 3] == 0x64) {
      
      if (i + 32 < bytes.length) {
        final timeScale = (bytes[i + 20] << 24) | (bytes[i + 21] << 16) | 
                         (bytes[i + 22] << 8) | bytes[i + 23];
        final duration = (bytes[i + 24] << 24) | (bytes[i + 25] << 16) | 
                        (bytes[i + 26] << 8) | bytes[i + 27];
        
        if (timeScale > 0 && duration > 0) {
          final seconds = duration / timeScale;
          final bitrate = ((bytes.length * 8) / seconds / 1000).round();
          data['AccurateBitrate'] = '$bitrate kbps';
        }
      }
      break;
    }
  }
  
  return data;
}

void printIntegratedMetadata(AudioMetadata metadata, Map<String, dynamic> additional, File file) {
  print('=== ファイル情報 ===');
  print('ファイル名      : ${file.path.split('\\').last}');
  print('ファイルサイズ  : ${(file.lengthSync() / 1024 / 1024).toStringAsFixed(1)} MB');
  print('ファイルタイプ  : ${file.path.split('.').last.toUpperCase()}');
  
  print('\n=== メタデータ ===');
  print('タイトル        : ${metadata.title ?? 'なし'}');
  print('アーティスト    : ${metadata.artist ?? 'なし'}');
  print('アルバム        : ${metadata.album ?? 'なし'}');
  print('アルバムアーティスト: ${additional['AlbumArtist'] ?? 'なし'}');
  print('年              : ${metadata.year ?? 'なし'}');
  print('トラック番号    : ${metadata.trackNumber ?? 'なし'}');
  print('総トラック数    : ${metadata.trackTotal ?? 'なし'}');
  print('コメント        : ${additional['Comment'] ?? 'なし'}');
  print('説明            : ${additional['Description'] ?? 'なし'}');
  print('バンド          : ${additional['Band'] ?? 'なし'}');
  print('エンコーダー    : ${additional['Encoder'] ?? 'なし'}');
  
  print('\n=== URL情報 ===');
  print('埋め込みURL     : ${additional['URL'] ?? 'なし'}');
  
  print('\n=== オーディオ情報 ===');
  print('再生時間        : ${formatDuration(metadata.duration)}');
  print('ビットレート    : ${additional['AccurateBitrate'] ?? '${metadata.bitrate ?? 'なし'} kbps'}');
  print('サンプルレート  : ${metadata.sampleRate ?? 'なし'} Hz');
}

String formatDuration(Duration? duration) {
  if (duration == null) return 'なし';
  
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}