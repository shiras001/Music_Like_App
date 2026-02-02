import 'dart:io';
import 'dart:convert';

void main(List<String> args) {
  final downloadsDir = Directory('C:\\Users\\pomyu\\Downloads');
  
  final files = [
    'C:\\Users\\pomyu\\Documents\\appmaker\\apple music\\flutter_application_4\\蝶々結び.mp3',
    downloadsDir.path + '\\三原色.m4a',
    downloadsDir.path + '\\BGM ユカリ戦.m4a',
  ];

  for (final file in files) {
    print('\n\n=== 解析: $file ===');
    analyzeFile(file);
  }
}

void analyzeFile(String filePath) {
  try {
    final f = File(filePath);
    if (!f.existsSync()) {
      print('ファイルが見つかりません: $filePath');
      return;
    }

    final bytes = f.readAsBytesSync();
    final ext = filePath.split('.').last.toLowerCase();

    if (ext == 'mp3') {
      analyzeMP3(bytes, filePath);
    } else if (ext == 'm4a' || ext == 'mp4') {
      analyzeM4A(bytes, filePath);
    }
  } catch (e) {
    print('エラー: $e');
  }
}

void analyzeMP3(List<int> bytes, String filePath) {
  print('[MP3 解析] ファイルサイズ: ${bytes.length} bytes');

  // ID3v2 タグを探索
  int id3Start = -1;
  if (bytes.length > 10 && bytes[0] == 0x49 && bytes[1] == 0x44 && bytes[2] == 0x33) {
    id3Start = 0;
    final version = bytes[3];
    final tagSize = ((bytes[6] & 0x7F) << 21) | ((bytes[7] & 0x7F) << 14) | ((bytes[8] & 0x7F) << 7) | (bytes[9] & 0x7F);
    print('ID3v2.$version タグ発見: 開始位置=0, サイズ=$tagSize');

    // フレーム列挙
    int pos = 10;
    final end = pos + tagSize;
    int frameCount = 0;
    while (pos + 10 <= end && pos + 10 <= bytes.length && frameCount < 20) {
      final id = String.fromCharCodes(bytes.sublist(pos, pos + 4));
      final sizeBytes = bytes.sublist(pos + 4, pos + 8);
      int frameSize = 0;
      if (version >= 4) {
        frameSize = ((sizeBytes[0] & 0x7F) << 21) | ((sizeBytes[1] & 0x7F) << 14) | ((sizeBytes[2] & 0x7F) << 7) | (sizeBytes[3] & 0x7F);
      } else {
        frameSize = (sizeBytes[0] << 24) | (sizeBytes[1] << 16) | (sizeBytes[2] << 8) | sizeBytes[3];
      }

      if (frameSize > 0 && pos + 10 + frameSize <= bytes.length) {
        final payload = bytes.sublist(pos + 10, pos + 10 + frameSize);
        final encoding = payload[0];
        final textBytes = payload.length > 1 ? payload.sublist(1) : <int>[];

        // テキストフレームの内容をダンプ
        if (id == 'TIT2' || id == 'TPE1' || id == 'TALB') {
          print('フレーム: $id, サイズ=$frameSize, エンコーディング=$encoding');
          print('  生バイト（最初32）: ${textBytes.take(32).map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
          
          // 複数デコーディング試行
          try {
            final utf8Result = utf8.decode(textBytes, allowMalformed: false);
            print('  UTF-8: "$utf8Result"');
          } catch (_) {}
          
          try {
            final latin1Result = latin1.decode(textBytes, allowInvalid: true);
            print('  Latin1: "$latin1Result"');
          } catch (_) {}

          // UTF-16 BOM チェック
          if (textBytes.length >= 2) {
            if (textBytes[0] == 0xFF && textBytes[1] == 0xFE) {
              print('  UTF-16 LE BOM 検出');
              final codeUnits = <int>[];
              for (int i = 2; i + 1 < textBytes.length; i += 2) {
                codeUnits.add(textBytes[i] | (textBytes[i + 1] << 8));
              }
              final result = String.fromCharCodes(codeUnits);
              print('  UTF-16 LE デコード: "$result"');
            } else if (textBytes[0] == 0xFE && textBytes[1] == 0xFF) {
              print('  UTF-16 BE BOM 検出');
              final codeUnits = <int>[];
              for (int i = 2; i + 1 < textBytes.length; i += 2) {
                codeUnits.add((textBytes[i] << 8) | textBytes[i + 1]);
              }
              final result = String.fromCharCodes(codeUnits);
              print('  UTF-16 BE デコード: "$result"');
            }
          }
        }
        pos += 10 + frameSize;
        frameCount++;
      } else {
        break;
      }
    }
  } else {
    print('ID3v2 タグが見つかりません');
  }

  // MPEG フレームヘッダ検索
  print('\n[MP3フレーム検索]');
  int frameCount = 0;
  for (int i = 0; i < bytes.length - 4 && frameCount < 5; i++) {
    if (bytes[i] == 0xFF && (bytes[i + 1] & 0xE0) == 0xE0) {
      final versionBits = (bytes[i + 1] >> 3) & 0x03;
      final layerBits = (bytes[i + 1] >> 1) & 0x03;
      final bitrateIndex = (bytes[i + 2] >> 4) & 0x0F;
      final srIndex = (bytes[i + 2] >> 2) & 0x03;
      final padding = (bytes[i + 2] >> 1) & 0x01;

      print('フレーム#$frameCount @ 位置 $i:');
      print('  version=$versionBits, layer=$layerBits, bitrateIdx=$bitrateIndex, srIdx=$srIndex');
      frameCount++;
    }
  }
}

void analyzeM4A(List<int> bytes, String filePath) {
  print('[M4A 解析] ファイルサイズ: ${bytes.length} bytes');

  // 'ftyp' ボックス検索
  print('\n[MP4 ボックス検索]');
  searchAndPrintBox(bytes, [0x66, 0x74, 0x79, 0x70], 'ftyp'); // 'ftyp'
  searchAndPrintBox(bytes, [0x6D, 0x64, 0x61, 0x74], 'mdat'); // 'mdat'
  searchAndPrintBox(bytes, [0x6D, 0x6F, 0x6F, 0x76], 'moov'); // 'moov'

  // meta/ilst の ©nam, ©ART, ©alb 探索
  print('\n[メタデータアトム検索]');
  searchMetadataAtom(bytes, [0xA9, 0x6E, 0x61, 0x6D]); // ©nam
  searchMetadataAtom(bytes, [0xA9, 0x41, 0x52, 0x54]); // ©ART
  searchMetadataAtom(bytes, [0xA9, 0x61, 0x6C, 0x62]); // ©alb
  searchMetadataAtom(bytes, [0x63, 0x6F, 0x76, 0x72]); // covr
}

void searchAndPrintBox(List<int> bytes, List<int> tag, String name) {
  for (int i = 0; i < bytes.length - 8; i++) {
    bool match = true;
    for (int j = 0; j < 4; j++) {
      if (bytes[i + 4 + j] != tag[j]) {
        match = false;
        break;
      }
    }
    if (match) {
      final size = (bytes[i] << 24) | (bytes[i + 1] << 16) | (bytes[i + 2] << 8) | bytes[i + 3];
      print('$name ボックス発見 @ 位置 $i: サイズ=$size');
      return;
    }
  }
  print('$name ボックスが見つかりません');
}

void searchMetadataAtom(List<int> bytes, List<int> tag) {
  final tagStr = String.fromCharCodes(tag);
  for (int i = 0; i < bytes.length - 8; i++) {
    bool match = true;
    for (int j = 0; j < 4; j++) {
      if (bytes[i + j] != tag[j]) {
        match = false;
        break;
      }
    }
    if (match) {
      print('\n$tagStr アトム @ 位置 $i');
      // サイズを読む
      if (i >= 4) {
        final size = (bytes[i - 4] << 24) | (bytes[i - 3] << 16) | (bytes[i - 2] << 8) | bytes[i - 1];
        print('  サイズ: $size');
        // data チャイルドを探す
        int pos = i + 4;
        final searchEnd = bytes.length > i + size + 100 ? i + size + 100 : bytes.length;
        while (pos + 8 <= searchEnd) {
          if (bytes[pos] == 0x64 && bytes[pos + 1] == 0x61 && bytes[pos + 2] == 0x74 && bytes[pos + 3] == 0x61) {
            print('  data チャイルド発見 @ 位置 $pos');
            final dataSize = (bytes[pos - 4] << 24) | (bytes[pos - 3] << 16) | (bytes[pos - 2] << 8) | bytes[pos - 1];
            final end = pos + dataSize > bytes.length ? bytes.length : pos + dataSize;
            final dataPayload = bytes.sublist(pos + 8, end);
            print('    ペイロードサイズ: ${dataPayload.length}');
            print('    生バイト（最初48）: ${dataPayload.take(48).map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
            
            // テキストデコード試行
            try {
              final utf8Result = utf8.decode(dataPayload, allowMalformed: false);
              if (utf8Result.length > 0 && !utf8Result.contains('JFIF')) {
                print('    UTF-8: "$utf8Result"');
              }
            } catch (_) {}
            
            try {
              final latin1Result = latin1.decode(dataPayload, allowInvalid: true);
              if (latin1Result.length > 0) {
                print('    Latin1: "$latin1Result"');
              }
            } catch (_) {}
            break;
          }
          pos += 1;
        }
      }
      return;
    }
  }
  print('$tagStr アトムが見つかりません');
}
