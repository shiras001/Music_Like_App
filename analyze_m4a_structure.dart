import 'dart:io';
import 'dart:typed_data';

/// M4A/MP4 Atom構造を分析するプログラム
void main() async {
  // テスト対象のM4Aファイル
  final testFiles = [
    'lib/data/BGM ユカリ戦.m4a',
    '三原色.m4a',
    '蝶々結び.m4a'
  ];

  for (final filename in testFiles) {
    final file = File(filename);
    if (!file.existsSync()) {
      print('❌ File not found: $filename');
      continue;
    }

    print('\n' + '=' * 80);
    print('📄 ファイル: $filename');
    print('=' * 80);

    final bytes = await file.readAsBytes();
    print('📊 ファイルサイズ: ${bytes.length} bytes');

    // 最初の1000バイトの16進数表示
    print('\n🔍 最初の1000バイトの16進数表示:');
    _printHexDump(bytes, 0, 1000);

    // Atom構造の分析
    print('\n📦 MP4 Atom構造:');
    _analyzeAtomStructure(bytes, 0, bytes.length, 0);

    // 重要なタグの位置を検索
    print('\n🔎 重要なタグの位置:');
    _findImportantTags(bytes);
  }
}

/// 16進数ダンプを表示
void _printHexDump(List<int> bytes, int start, int length) {
  final end = (start + length > bytes.length) ? bytes.length : start + length;
  for (int i = start; i < end; i += 16) {
    final nextEnd = (i + 16 > end) ? end : i + 16;
    final hex = bytes.sublist(i, nextEnd).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    final ascii = bytes.sublist(i, nextEnd).map((b) => (b >= 32 && b < 127) ? String.fromCharCode(b) : '.').join('');
    print('${i.toRadixString(16).padLeft(8, '0')}: $hex  $ascii');
  }
}

/// Atom構造を再帰的に分析
void _analyzeAtomStructure(List<int> bytes, int offset, int maxLength, int indent) {
  int pos = offset;
  final baseOffset = offset;
  int atomCount = 0;

  while (pos + 8 <= baseOffset + maxLength && pos + 8 <= bytes.length) {
    // サイズを読み込み（ビッグエンディアン）
    final size = _readUint32(bytes, pos);
    if (size == 0) {
      // サイズ0はファイル終端まで
      final type = String.fromCharCodes(bytes.sublist(pos + 4, pos + 8));
      print(_getIndent(indent) + '├─ [${pos}] size: 0 (to EOF), type: $type');
      break;
    }

    if (size < 8) {
      print(_getIndent(indent) + '└─ [${pos}] Invalid size: $size (< 8)');
      break;
    }

    final type = String.fromCharCodes(bytes.sublist(pos + 4, pos + 8));
    final nextPos = pos + size;

    // Atomの情報を表示
    print(_getIndent(indent) + '├─ [$pos-${nextPos - 1}] size: $size, type: $type');

    // ネストされたAtomを含むかどうか
    if (_isContainerAtom(type) && pos + 8 < nextPos) {
      // 子のAtomを再帰的に分析
      _analyzeAtomStructure(bytes, pos + 8, nextPos - pos - 8, indent + 1);
    } else if (type == 'data') {
      // dataアトムの内容を表示
      final version = bytes[pos + 8];
      final flags = (bytes[pos + 9] << 16) | (bytes[pos + 10] << 8) | bytes[pos + 11];
      final reserved = (bytes[pos + 12] << 24) | (bytes[pos + 13] << 16) | (bytes[pos + 14] << 8) | bytes[pos + 15];
      print(_getIndent(indent + 1) + '  version: $version, flags: ${flags.toRadixString(16)}, reserved: ${reserved.toRadixString(16)}');

      // ペイロード
      if (size > 16) {
        final payload = bytes.sublist(pos + 16, nextPos);
        final str = _decodeTextBytes(payload);
        if (str.isNotEmpty) {
          print(_getIndent(indent + 1) + '  payload: "$str"');
        }
      }
    }

    pos = nextPos;
    atomCount++;

    // 無限ループを防ぐ
    if (atomCount > 1000) {
      print(_getIndent(indent) + '  ⚠️ Too many atoms, stopping');
      break;
    }
  }
}

/// コンテナAtomかどうかを判定
bool _isContainerAtom(String type) {
  const containers = ['moov', 'mdat', 'meta', 'ilst', 'udta', 'trak', 'edts', 'minf', 'stbl', 'dinf'];
  return containers.contains(type);
}

/// 重要なタグ（©nam, ©ART, ©albなど）を検索
void _findImportantTags(List<int> bytes) {
  final tagsToFind = [
    ([0xA9, 0x6E, 0x61, 0x6D], '©nam - Title'),  // ©nam
    ([0xA9, 0x41, 0x52, 0x54], '©ART - Artist'), // ©ART
    ([0xA9, 0x61, 0x6C, 0x62], '©alb - Album'),  // ©alb
    ([0x74, 0x72, 0x6B, 0x6E], 'trkn - Track Number'),
    ([0x64, 0x69, 0x73, 0x6B], 'disk - Disk Number'),
    ([0x67, 0x6E, 0x72, 0x65], 'gnre - Genre'),
    ([0x64, 0x61, 0x79, 0x79], 'davy - Year'),
  ];

  for (final (tagBytes, tagName) in tagsToFind) {
    final positions = _findAllOccurrences(bytes, tagBytes);
    if (positions.isNotEmpty) {
      print('  ✓ $tagName found at positions: $positions');
      for (final pos in positions) {
        // tagの前後を確認
        if (pos >= 4) {
          final size = _readUint32(bytes, pos - 4);
          print('    └─ 位置: ${pos - 4}, サイズ: $size');
        }
      }
    } else {
      print('  ✗ $tagName not found');
    }
  }
}

/// 指定のバイト列がすべて出現する位置を検索
List<int> _findAllOccurrences(List<int> bytes, List<int> pattern) {
  final positions = <int>[];
  for (int i = 0; i <= bytes.length - pattern.length; i++) {
    bool match = true;
    for (int j = 0; j < pattern.length; j++) {
      if (bytes[i + j] != pattern[j]) {
        match = false;
        break;
      }
    }
    if (match) {
      positions.add(i);
    }
  }
  return positions;
}

/// UInt32をビッグエンディアンで読み込み
int _readUint32(List<int> bytes, int pos) {
  if (pos + 4 > bytes.length) return 0;
  return (bytes[pos] << 24) | (bytes[pos + 1] << 16) | (bytes[pos + 2] << 8) | bytes[pos + 3];
}

/// テキストをデコード
String _decodeTextBytes(List<int> bytes) {
  try {
    // UTF-8でデコード
    return String.fromCharCodes(bytes.where((b) => b >= 32 && b < 127));
  } catch (e) {
    return '';
  }
}

/// インデント文字列を生成
String _getIndent(int level) {
  return '  ' * level;
}
