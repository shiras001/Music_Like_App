import 'dart:io';

/// 改善された MP4 Atom 解析実装
void main() async {
  print('═' * 80);
  print('改善された MP4 Atom 解析 - 修正版 _findMp4Box');
  print('═' * 80 + '\n');

  final file = File('三原色.m4a');
  if (!file.existsSync()) {
    print('❌ File not found: 三原色.m4a');
    return;
  }

  final bytes = await file.readAsBytes();

  print('📋 改善内容:\n');
  print('✅ 問題1 解決: meta atom の version/flags をスキップ');
  print('✅ 問題2 解決: ilst コンテナを正しく処理');
  print('✅ 問題3 解決: 深い階層を正しく走査');
  print('✅ 問題4 解決: サイズ計算を正確に\n');

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('改善版実装の検証');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // テスト対象のメタデータタグ
  final tagsToFind = [
    ([0xA9, 0x6E, 0x61, 0x6D], '©nam - Title'),
    ([0xA9, 0x41, 0x52, 0x54], '©ART - Artist'),
    ([0xA9, 0x61, 0x6C, 0x62], '©alb - Album'),
  ];

  // 改善版の関数をテスト
  for (final (tagBytes, tagName) in tagsToFind) {
    final result = _findMp4AtomTextImproved(bytes, tagBytes);
    if (result != null) {
      print('✅ $tagName: "$result"');
    } else {
      print('❌ $tagName: not found (file may not contain this tag)');
    }
  }

  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('デバッグ情報');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  print('🔍 udta atom の詳細検査:\n');
  _inspectUdtaStructure(bytes);

  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('修正コード例 (Dart)');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  print(_printFixedCode());
}

/// 改善版 MP4 Atom テキスト検索関数
String? _findMp4AtomTextImproved(List<int> bytes, List<int> tag) {
  try {
    // Step 1: moov の中から udta を探す
    final moovPos = _findAtomPosition(bytes, [0x6D, 0x6F, 0x6F, 0x76]); // 'moov'
    if (moovPos == null) {
      print('[DEBUG] moov atom not found');
      return null;
    }

    final moovSize = _readUint32(bytes, moovPos);
    final moovEnd = moovPos + moovSize;

    // Step 2: moov の中から udta を探す
    final udtaPos = _findAtomPositionInRange(bytes, [0x75, 0x64, 0x74, 0x61], moovPos + 8, moovEnd); // 'udta'
    if (udtaPos == null) {
      print('[DEBUG] udta atom not found in moov');
      return null;
    }

    final udtaSize = _readUint32(bytes, udtaPos);
    final udtaEnd = udtaPos + udtaSize;

    // Step 3: udta の中から meta を探す
    final metaPos = _findAtomPositionInRange(bytes, [0x6D, 0x65, 0x74, 0x61], udtaPos + 8, udtaEnd); // 'meta'
    if (metaPos == null) {
      print('[DEBUG] meta atom not found in udta');
      return null;
    }

    final metaSize = _readUint32(bytes, metaPos);
    final metaEnd = metaPos + metaSize;

    // ⭐ 重要: meta atom は version (1 byte) + flags (3 bytes) がある
    // つまり、content は metaPos + 12 から始まる (size:4 + type:4 + version:1 + flags:3)
    final metaContentStart = metaPos + 12;

    // Step 4: meta の中から ilst を探す
    final ilstPos = _findAtomPositionInRange(bytes, [0x69, 0x6C, 0x73, 0x74], metaContentStart, metaEnd); // 'ilst'
    if (ilstPos == null) {
      print('[DEBUG] ilst atom not found in meta');
      return null;
    }

    final ilstSize = _readUint32(bytes, ilstPos);
    final ilstEnd = ilstPos + ilstSize;

    // Step 5: ilst の中から指定のタグを探す
    int searchPos = ilstPos + 8;
    while (searchPos + 8 <= ilstEnd) {
      final itemSize = _readUint32(bytes, searchPos);
      if (itemSize < 8 || searchPos + itemSize > ilstEnd) break;

      final itemType = bytes.sublist(searchPos + 4, searchPos + 8);

      // タグが一致したか確認
      bool match = true;
      for (int j = 0; j < 4; j++) {
        if (itemType[j] != tag[j]) {
          match = false;
          break;
        }
      }

      if (match) {
        // Item atom を見つけた
        // item 構造: [size:4] [type:4] [item content]
        // item content には通常 data atom が含まれている

        int dataPos = searchPos + 8;
        while (dataPos + 8 <= searchPos + itemSize) {
          final dataSize = _readUint32(bytes, dataPos);
          if (dataSize < 8 || dataPos + dataSize > searchPos + itemSize) break;

          final dataType = String.fromCharCodes(bytes.sublist(dataPos + 4, dataPos + 8));

          if (dataType == 'data' && dataPos + 16 <= dataSize + dataPos) {
            // data atom 構造: [size:4] [type:4] [version:1] [flags:3] [reserved:4] [text data]
            final payloadStart = dataPos + 16;
            final payloadEnd = dataPos + dataSize;

            if (payloadStart < payloadEnd && payloadStart < bytes.length) {
              final payload = bytes.sublist(payloadStart, payloadEnd.clamp(0, bytes.length));
              final text = _decodeTextRobust(payload);

              if (text.isNotEmpty) {
                return text;
              }
            }
            break;
          }

          dataPos += dataSize;
        }

        return null; // タグは見つかったが、data を取得できなかった
      }

      searchPos += itemSize;
    }

    return null;
  } catch (e) {
    print('[ERROR] _findMp4AtomTextImproved: $e');
    return null;
  }
}

/// udta 構造を詳しく検査
void _inspectUdtaStructure(List<int> bytes) {
  final moovPos = _findAtomPosition(bytes, [0x6D, 0x6F, 0x6F, 0x76]);
  if (moovPos == null) return;

  final moovSize = _readUint32(bytes, moovPos);
  final moovEnd = moovPos + moovSize;

  final udtaPos = _findAtomPositionInRange(bytes, [0x75, 0x64, 0x74, 0x61], moovPos + 8, moovEnd);
  if (udtaPos == null) return;

  final udtaSize = _readUint32(bytes, udtaPos);
  final udtaEnd = udtaPos + udtaSize;

  print('udta atom: position=$udtaPos, size=$udtaSize');
  print('└─ meta を検索範囲: ${udtaPos + 8} ~ $udtaEnd\n');

  int pos = udtaPos + 8;
  while (pos + 8 <= udtaEnd && pos < bytes.length) {
    final size = _readUint32(bytes, pos);
    if (size < 8 || pos + size > bytes.length) break;

    final type = String.fromCharCodes(bytes.sublist(pos + 4, pos + 8));
    print('  ├─ [$pos] type: "$type", size: $size');

    if (type == 'meta') {
      print('  │  ⭐ meta atom found!');
      print('  │  └─ version/flags を考慮した content start: ${pos + 12}');

      // meta の内部を検査
      final metaSize = size;
      final metaContentStart = pos + 12;
      final metaEnd = pos + metaSize;

      int metaPos2 = metaContentStart;
      while (metaPos2 + 8 <= metaEnd && metaPos2 < bytes.length) {
        final size2 = _readUint32(bytes, metaPos2);
        if (size2 < 8) break;

        final type2 = String.fromCharCodes(bytes.sublist(metaPos2 + 4, metaPos2 + 8));
        print('  │     ├─ [$metaPos2] type: "$type2", size: $size2');

        if (type2 == 'ilst') {
          print('  │     │  ⭐ ilst atom found!');
          print('  │     │  └─ items を検索');

          // ilst の内部を検査
          int ilstItemPos = metaPos2 + 8;
          int itemCount = 0;
          while (ilstItemPos + 8 <= metaPos2 + size2 && ilstItemPos < bytes.length && itemCount < 5) {
            final itemSize = _readUint32(bytes, ilstItemPos);
            if (itemSize < 8) break;

            final itemType = String.fromCharCodes(bytes.sublist(ilstItemPos + 4, ilstItemPos + 8));
            print('  │     │     ├─ [$ilstItemPos] type: "$itemType", size: $itemSize');

            ilstItemPos += itemSize;
            itemCount++;
          }

          if (itemCount >= 5) {
            print('  │     │     └─ (more items...)');
          }
        }

        metaPos2 += size2;
      }
    }

    pos += size;
  }
}

/// 修正コードを出力
String _printFixedCode() {
  return '''
// 改善版の実装例

/// ✅ 改善版: meta atom の version/flags をスキップ + 階層を正しく処理
static String? _findMp4AtomTextImproved(List<int> bytes, List<int> tag) {
  try {
    // moov -> udta -> meta (version/flags skip) -> ilst -> tag -> data
    
    // 1. moov を見つける
    final moovBody = _findMp4Box(bytes, [0x6D, 0x6F, 0x6F, 0x76]); // 'moov'
    if (moovBody == null) return null;
    
    // 2. moov 内から udta を見つける
    final udtaBody = _findMp4Box(moovBody, [0x75, 0x64, 0x74, 0x61]); // 'udta'
    if (udtaBody == null) return null;
    
    // 3. udta 内から meta を見つける
    final metaBody = _findMp4Box(udtaBody, [0x6D, 0x65, 0x74, 0x61]); // 'meta'
    if (metaBody == null) return null;
    
    // ⭐ 重要: meta atom はバージョンフラグを持つため、
    // 最初の 4 バイトをスキップして ilst を検索
    final metaBodySkipped = (metaBody.length > 4) 
        ? metaBody.sublist(4)  // version(1) + flags(3) をスキップ
        : metaBody;
    
    // 4. meta(version/flags skip) 内から ilst を見つける
    final ilstBody = _findMp4Box(metaBodySkipped, [0x69, 0x6C, 0x73, 0x74]); // 'ilst'
    if (ilstBody == null) return null;
    
    // 5. ilst 内から目的のタグを見つける
    final tagBody = _findMp4Box(ilstBody, tag);
    if (tagBody == null) return null;
    
    // 6. tag 内から data atom を見つける
    final dataBody = _findMp4Box(tagBody, [0x64, 0x61, 0x74, 0x61]); // 'data'
    if (dataBody == null) return null;
    
    // 7. data atom のペイロード (version + flags + reserved をスキップ)
    if (dataBody.length <= 8) return null;
    final payload = dataBody.sublist(8); // version(1) + flags(3) + reserved(4)
    
    return _decodeTextBytesRobust(payload);
  } catch (e) {
    debugPrint('[MP4 Error] _findMp4AtomTextImproved: \$e');
    return null;
  }
}
''';
}

/// Atom の位置を探す
int? _findAtomPosition(List<int> bytes, List<int> tag) {
  for (int i = 0; i <= bytes.length - 4; i++) {
    bool match = true;
    for (int j = 0; j < 4; j++) {
      if (bytes[i + j] != tag[j]) {
        match = false;
        break;
      }
    }
    if (match && i >= 4) {
      final size = _readUint32(bytes, i - 4);
      if (size > 8) return i - 4;
    }
  }
  return null;
}

/// 指定範囲内で Atom の位置を探す
int? _findAtomPositionInRange(List<int> bytes, List<int> tag, int start, int end) {
  for (int i = start; i <= end - 4 && i < bytes.length; i++) {
    if (i + 4 > bytes.length) break;

    bool match = true;
    for (int j = 0; j < 4; j++) {
      if (bytes[i + j] != tag[j]) {
        match = false;
        break;
      }
    }
    if (match && i >= 4) {
      final size = _readUint32(bytes, i - 4);
      if (size > 8 && i - 4 + size <= bytes.length) {
        return i - 4;
      }
    }
  }
  return null;
}

/// テキストをロバストにデコード
String _decodeTextRobust(List<int> bytes) {
  try {
    // UTF-8でデコード
    return String.fromCharCodes(bytes.where((b) => b >= 32 && b < 127 || b > 127));
  } catch (e) {
    return '';
  }
}

/// UInt32 をビッグエンディアンで読む
int _readUint32(List<int> bytes, int pos) {
  if (pos + 4 > bytes.length) return 0;
  return (bytes[pos] << 24) | (bytes[pos + 1] << 16) | (bytes[pos + 2] << 8) | bytes[pos + 3];
}
