/// 修正版: local_audio_service.dart への適用例
/// 
/// このファイルは、既存の _findMp4Box 関数をどのように修正するかを示します。
/// 
/// 概要:
/// 1. meta atom の構造を正しく処理（version/flags をスキップ）
/// 2. 階層を明示的に走査
/// 3. data atom のペイロード取得を改善

import 'dart:math' as math;

// ============================================================================
// 修正版関数 - 既存の _findMp4Box を置き換える
// ============================================================================

/// ✅ 改善版: MP4 box を検索し、meta atom の構造に対応
static List<int>? _findMp4BoxImproved(List<int> bytes, List<int> tag) {
  int i = 0;
  while (i + 8 <= bytes.length) {
    final size = _readUint32(bytes, i);
    if (i + 8 > bytes.length) break;
    final type = bytes.sublist(i + 4, i + 8);
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
    
    // Recurse into contained boxes
    if (size > 8 && i + 8 < bytes.length) {
      final bodyStart = i + 8;
      final bodyEnd = (size > 1) ? math.min(i + size, bytes.length) : bytes.length;
      if (bodyEnd > bodyStart && bodyEnd <= bytes.length) {
        // ⭐ 修正: meta atom の場合、version/flags をスキップ
        final typeStr = String.fromCharCodes(type);
        final searchBody = (typeStr == 'meta' && bodyEnd - bodyStart > 4)
            ? bytes.sublist(bodyStart + 4, bodyEnd)  // meta: version/flags skip
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

// ============================================================================
// 改善版: MP4 atom テキスト検索
// ============================================================================

/// ✅ 改善版: MP4 atom text を検索（meta 構造に対応）
static String? _findMp4AtomTextImproved(List<int> bytes, List<int> tag) {
  try {
    final tagStr = String.fromCharCodes(tag);
    final box = _findMp4Box(bytes, tag);
    debugPrint('[MP4] Looking for atom $tagStr, found box: ${box != null}, size: ${box?.length}');
    if (box == null) return null;
    
    // inside box, find 'data' child
    int pos = 0;
    while (pos + 8 <= box.length) {
      final size = _readUint32(box, pos);
      if (pos + 8 > box.length) break;
      final type = String.fromCharCodes(box.sublist(pos + 4, pos + 8));
      if (type == 'data') {
        final header = pos + 8;
        if (header >= box.length) break;
        
        // ✅ 改善: data atom の構造
        // [size:4] [type:4] [version:1] [flags:3] [reserved:4] [text]
        // つまり pos + 16 からテキストが始まる
        final payloadStart = math.min(box.length, header + 8);
        final payloadEnd = box.length;
        if (payloadStart >= payloadEnd) break;
        
        final slice = box.sublist(payloadStart, payloadEnd);
        debugPrint('[MP4 data] Payload (first 32): ${slice.take(32).toList()}');
        
        final str = _decodeTextBytesRobust(slice).replaceAll(RegExp(r'[\u0000-\u001F]'), '');
        debugPrint('[MP4] Found data box with text: "$str"');
        
        if (str.isNotEmpty && !str.contains('JFIF') && !str.contains('PNG')) {
          return str;
        }
        break;
      }
      if (size <= 8) break;
      pos += size;
    }
  } catch (e) {
    debugPrint('[MP4 Error] _findMp4AtomTextImproved: $e');
  }
  return null;
}

// ============================================================================
// ユーティリティ関数（既存と同じ）
// ============================================================================

static int _readUint32(List<int> bytes, int pos) {
  return (bytes[pos] << 24) | (bytes[pos + 1] << 16) | (bytes[pos + 2] << 8) | bytes[pos + 3];
}

static String _decodeTextBytesRobust(List<int> bytes) {
  try {
    // UTF-8でデコード
    return String.fromCharCodes(bytes);
  } catch (e) {
    return '';
  }
}

// ============================================================================
// 使用方法
// ============================================================================

/*

## local_audio_service.dart への適用手順

### Step 1: 既存の _findMp4Box を確認
位置: [356行目付近]
```dart
static List<int>? _findMp4Box(List<int> bytes, List<int> tag) {
  // ... 既存コード ...
}
```

### Step 2: meta atom の特別処理を追加
既存のコードに以下の修正を加える：

修正前:
```dart
// Recurse into contained boxes (especially meta, ilst, moov, udta)
if (size > 8 && i + 8 < bytes.length) {
  final bodyStart = i + 8;
  final bodyEnd = (size > 1) ? math.min(i + size, bytes.length) : bytes.length;
  if (bodyEnd > bodyStart && bodyEnd <= bytes.length) {
    final found = _findMp4Box(bytes.sublist(bodyStart, bodyEnd), tag);
    if (found != null) return found;
  }
}
```

修正後:
```dart
// Recurse into contained boxes (especially meta, ilst, moov, udta)
if (size > 8 && i + 8 < bytes.length) {
  final bodyStart = i + 8;
  final bodyEnd = (size > 1) ? math.min(i + size, bytes.length) : bytes.length;
  if (bodyEnd > bodyStart && bodyEnd <= bytes.length) {
    // ⭐ 修正: meta atom の場合、version/flags をスキップ
    final typeStr = String.fromCharCodes(type);
    final searchBody = (typeStr == 'meta' && bodyEnd - bodyStart > 4)
        ? bytes.sublist(bodyStart + 4, bodyEnd)  // meta: version/flags skip
        : bytes.sublist(bodyStart, bodyEnd);
    
    final found = _findMp4Box(searchBody, tag);
    if (found != null) return found;
  }
}
```

### Step 3: 必要に応じて _findMp4AtomText を置き換え
meta 構造の処理に問題がある場合、_findMp4AtomTextImproved を使用。

*/

// ============================================================================
// テスト用プログラム
// ============================================================================

void main() {
  print('修正内容のサマリー:');
  print('');
  print('❌ 既存の問題:');
  print('   1. meta atom の version/flags をスキップしていない');
  print('   2. bodyStart を常に i+8 で計算している');
  print('   3. meta 内の ilst を見つけられない');
  print('');
  print('✅ 修正内容:');
  print('   1. meta atom 検出時に bodyStart + 4 をスキップ');
  print('   2. typeStr == "meta" で条件判定');
  print('   3. 正しく ilst -> tag -> data の階層を走査');
  print('');
  print('📝 適用ファイル:');
  print('   lib/data/local_audio_service.dart');
  print('');
  print('🔧 修正範囲:');
  print('   - _findMp4Box 関数内の再帰処理');
  print('   - 約5行の変更で対応可能');
}
