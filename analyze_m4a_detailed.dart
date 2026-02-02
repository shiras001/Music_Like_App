import 'dart:io';

/// M4A MP4 Atom構造の詳細分析
/// 既存の _findMp4Box 関数の問題を診断する
void main() async {
  print('═' * 80);
  print('M4A MP4 Atom構造 詳細分析 - _findMp4Box 関数の問題診断');
  print('═' * 80);

  final file = File('三原色.m4a');
  if (!file.existsSync()) {
    print('❌ File not found: 三原色.m4a');
    return;
  }

  final bytes = await file.readAsBytes();
  print('\n📊 ファイル情報:');
  print('  ファイルサイズ: ${bytes.length} bytes');
  print('  ファイル名: 三原色.m4a\n');

  // Atom構造を詳しく分析
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('1️⃣  MP4 Atom階層構造の分析');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  print('\n✅ 期待される正常な構造:');
  print('  ftyp                     (ファイルタイプ)');
  print('  moov                     (メタデータコンテナ)');
  print('  ├─ mvhd                  (ムービーヘッダー)');
  print('  ├─ trak                  (トラック情報)');
  print('  │  ├─ tkhd');
  print('  │  ├─ edts');
  print('  │  └─ mdia');
  print('  └─ udta                  (ユーザーデータ) ⬅️ メタデータはここ!');
  print('     └─ meta               (メタデータコンテナ)');
  print('        └─ ilst            (Item List Container)');
  print('           ├─ ©nam         (タイトル)');
  print('           │  └─ data      (テキストデータ)');
  print('           ├─ ©ART         (アーティスト)');
  print('           │  └─ data      (テキストデータ)');
  print('           └─ ©alb         (アルバム)');
  print('              └─ data      (テキストデータ)\n');

  // 実際の位置を分析
  print('✅ 実際の構造 (三原色.m4a):');
  _analyzeAtonStructureDetailed(bytes);

  // 問題分析
  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('2️⃣  _findMp4Box 関数の問題診断');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  _diagnoseFindMp4BoxProblems(bytes);

  // ©alb タグが見つからない理由
  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('3️⃣  なぜ ©alb (アルバム) タグが見つからないのか？');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // ©nam と ©ART を探す
  final namPos = _findTagWithData(bytes, [0xA9, 0x6E, 0x61, 0x6D]);
  final artPos = _findTagWithData(bytes, [0xA9, 0x41, 0x52, 0x54]);
  final albPos = _findTagWithData(bytes, [0xA9, 0x61, 0x6C, 0x62]);

  print('✅ ©nam (タイトル): ${namPos >= 0 ? "見つかった at $namPos" : "見つからない"}');
  print('✅ ©ART (アーティスト): ${artPos >= 0 ? "見つかった at $artPos" : "見つからない"}');
  print('❌ ©alb (アルバム): ${albPos >= 0 ? "見つかった at $albPos" : "見つからない ⬅️ 問題!"}');

  print('\n💡 原因分析:');
  print('  1. ©alb タグがこのファイルに存在しないか');
  print('  2. ©alb タグが異なる構造に存在');
  print('  3. _findMp4Box 関数が udta -> meta -> ilst 階層を正しく走査していない');

  // メタデータ位置を詳しく表示
  if (namPos >= 0) {
    print('\n🔍 ©nam タグの詳細分析 (位置: $namPos):');
    _analyzeTagInDetail(bytes, namPos);
  }

  if (artPos >= 0) {
    print('\n🔍 ©ART タグの詳細分析 (位置: $artPos):');
    _analyzeTagInDetail(bytes, artPos);
  }

  // 他のメタデータ形式をチェック
  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('4️⃣  代替メタデータ形式の検索');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  _findAlternativeMetadata(bytes);

  // 修正提案
  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('5️⃣  修正提案');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  print('''
📌 _findMp4Box 関数の問題点:

1. ✗ メタデータを見つけられない理由:
   - udta -> meta 階層でメタデータ構造のバージョン/フラグをスキップしていない
   - ilst コンテナ内のタグ構造を正しく理解していない
   - 名前空間付きタグ (©nam など) の処理が不完全

2. ✗ 再帰的な検索の問題:
   - meta atom 内の version/flags フィールドをスキップせず
   - ilst を見つけても、その中身を正しく処理していない

3. ✗ サイズ計算の問題:
   - 0 サイズ (ファイル終端まで) の処理が不正確
   - bodyEnd の計算が間違っている可能性

✅ 修正案:

a) 階層を明示的に処理する関数を追加:
   - _findUdtaMetadata(bytes) - udta -> meta -> ilst へのパス確保
   - _parseIlstContainer(bytes, offset) - ilst コンテナの正確な解析

b) meta atom の構造を正しく処理:
   - meta atom のフォーマット:
     [size:4] [type:4] [version:1] [flags:3] [content]
   - version/flags を必ずスキップ (8バイト後から)

c) データ取得の改善:
   - data atom の構造:
     [size:4] [type:4] [version:1] [flags:3] [reserved:4] [text data]
   - reserved をスキップして text data を取得 (16バイト後から)
''');
}

/// atom構造を詳しく分析
void _analyzeAtonStructureDetailed(List<int> bytes) {
  int pos = 0;
  int level = 0;

  while (pos + 8 <= bytes.length) {
    final size = _readUint32(bytes, pos);
    if (size == 0 || size < 8) break;

    final type = String.fromCharCodes(bytes.sublist(pos + 4, pos + 8));
    final nextPos = pos + size;

    _printAtomInfo(pos, size, type, level);

    // 重要なコンテナを再帰的に処理
    if ((type == 'moov' || type == 'udta' || type == 'meta' || type == 'ilst' || type == 'trak' || type == 'mdia') && pos + 8 < nextPos) {
      level++;
      // meta atom の場合、version/flags をスキップ
      final contentStart = (type == 'meta') ? pos + 12 : pos + 8;
      _analyzeAtomInRange(bytes, contentStart, nextPos, level);
      level--;
    }

    pos = nextPos;
  }
}

/// 指定範囲内のatomを分析
void _analyzeAtomInRange(List<int> bytes, int start, int end, int level) {
  int pos = start;
  while (pos + 8 <= end && pos + 8 <= bytes.length) {
    final size = _readUint32(bytes, pos);
    if (size < 8) break;
    if (pos + size > end) break;

    final type = String.fromCharCodes(bytes.sublist(pos + 4, pos + 8));
    _printAtomInfo(pos, size, type, level);

    pos += size;
  }
}

/// atom情報を表示
void _printAtomInfo(int pos, int size, String type, int level) {
  final indent = '  ' * level;
  print('$indent├─ [$pos] size: $size, type: "$type"');

  // 特定のタグに関する情報
  if (type == '©nam' || type == '©ART' || type == '©alb') {
    print('$indent   ⭐ メタデータタグ!');
  }
}

/// _findMp4Box 関数の問題を診断
void _diagnoseFindMp4BoxProblems(List<int> bytes) {
  print('❌ 問題1: meta atom の構造を正しく処理していない');
  print('   meta atom は [size:4] [type:4] [version:1] [flags:3] [content] の形式');
  print('   しかし _findMp4Box は単純に pos+8 から検索を始めている');
  print('   ⟹ meta 内の ilst を見つけられない!\n');

  print('❌ 問題2: ilst コンテナ内の item を正しく処理していない');
  print('   ilst は複数の item (©nam, ©ART など) を含むが');
  print('   各 item も [size:4] [type:4] [item content] 構造を持つ');
  print('   item 内に data atom があるはずなのに、直接検索している\n');

  print('❌ 問題3: 再帰が浅い');
  print('   ftyp -> moov -> udta -> meta -> ilst -> ©nam -> data');
  print('   という深い階層を正しく走査できていない\n');

  print('❌ 問題4: サイズ0の処理が不正確');
  print('   位置: 20279 で size=0 が出現');
  print('   これは「ファイル終端まで」を意味しますが、');
  print('   meta の content 境界を超えてしまう\n');

  // 実際の searchを試してみる
  print('📋 実装を改善するために必要な処理:\n');

  print('1️⃣  meta atom を正しく処理:');
  print('   // meta atom は version + flags があるため');
  print('   if (type == "meta") {');
  print('     // pos+8: version:1, flags:3, content starts at pos+12');
  print('     searchInMetadata(pos+12, ...');
  print('   }\n');

  print('2️⃣  ilst atom を検出したら、直接子供を処理:');
  print('   // ilst 内は item atoms で構成');
  print('   if (type == "ilst") {');
  print('     parseItems(pos+8, ...);');
  print('   }\n');

  print('3️⃣  item 内の data atom を正しく抽出:');
  print('   // item の構造: [size:4] [type:4] [item content]');
  print('   // item content 内に data atom があるはず');
  print('   if (type == "data") {');
  print('     // data: [size:4] [type:4] [version:1] [flags:3] [reserved:4] [value]');
  print('     const payloadStart = pos + 16;  // 8 + 8');
  print('     extract(payloadStart, ...);');
  print('   }');
}

/// タグを詳しく分析
void _analyzeTagInDetail(List<int> bytes, int pos) {
  // Atom の前 4 バイトは size
  if (pos < 4) return;

  final sizePos = pos - 4;
  final size = _readUint32(bytes, sizePos);
  final type = String.fromCharCodes(bytes.sublist(pos, pos + 4));

  print('  位置: $pos (size atom at ${sizePos})');
  print('  size: $size bytes');
  print('  type: "$type"');

  // data atom を探す
  int dataPos = pos + 4; // type の次から
  if (dataPos + 8 <= bytes.length) {
    final dataSize = _readUint32(bytes, dataPos);
    final dataType = String.fromCharCodes(bytes.sublist(dataPos + 4, dataPos + 8));

    print('  └─ data atom at ${dataPos}:');
    print('     size: $dataSize');
    print('     type: "$dataType"');

    if (dataType == 'data' && dataPos + 16 < bytes.length) {
      final version = bytes[dataPos + 8];
      final flags = (bytes[dataPos + 9] << 16) | (bytes[dataPos + 10] << 8) | bytes[dataPos + 11];
      final reserved = _readUint32(bytes, dataPos + 12);

      print('     version: $version');
      print('     flags: 0x${flags.toRadixString(16)}');
      print('     reserved: 0x${reserved.toRadixString(16)}');

      // テキストデータ
      final payloadStart = dataPos + 16;
      final payloadEnd = dataPos + dataSize;
      if (payloadStart < payloadEnd && payloadStart < bytes.length) {
        final payload = bytes.sublist(payloadStart, payloadEnd.clamp(0, bytes.length));
        final text = _decodeText(payload);
        print('     text: "$text"');
      }
    }
  }
}

/// タグとデータを見つけて返す (位置)
int _findTagWithData(List<int> bytes, List<int> tag) {
  for (int i = 0; i <= bytes.length - tag.length; i++) {
    bool match = true;
    for (int j = 0; j < tag.length; j++) {
      if (bytes[i + j] != tag[j]) {
        match = false;
        break;
      }
    }
    if (match) {
      // Atomの先頭(size)を探す
      if (i >= 4) {
        final possibleSize = _readUint32(bytes, i - 4);
        if (possibleSize > 8 && possibleSize < 10000) {
          return i;
        }
      }
    }
  }
  return -1;
}

/// 代替メタデータ形式を検索
void _findAlternativeMetadata(List<int> bytes) {
  print('🔍 iTunes 標準メタデータタグの検索:\n');

  final tags = [
    ([0xA9, 0x6E, 0x61, 0x6D], '©nam - Title'),
    ([0xA9, 0x41, 0x52, 0x54], '©ART - Artist'),
    ([0xA9, 0x61, 0x6C, 0x62], '©alb - Album'),
    ([0xA9, 0x67, 0x72, 0x70], '©grp - Grouping'),
    ([0xA9, 0x63, 0x6D, 0x74], '©cmt - Comments'),
    ([0xA9, 0x67, 0x65, 0x6E], '©gen - Genre (old)'),
    ([0x67, 0x6E, 0x72, 0x65], 'gnre - Genre (new)'),
    ([0x74, 0x72, 0x6B, 0x6E], 'trkn - Track'),
    ([0x64, 0x69, 0x73, 0x6B], 'disk - Disk'),
    ([0xA9, 0x64, 0x61, 0x79], '©day - Year'),
  ];

  for (final (tagBytes, tagName) in tags) {
    var count = 0;
    for (int i = 0; i <= bytes.length - 4; i++) {
      bool match = true;
      for (int j = 0; j < 4; j++) {
        if (bytes[i + j] != tagBytes[j]) {
          match = false;
          break;
        }
      }
      if (match) count++;
    }

    if (count > 0) {
      print('✅ $tagName: found $count time(s)');
    } else {
      print('❌ $tagName: not found');
    }
  }
}

/// テキストをデコード
String _decodeText(List<int> bytes) {
  try {
    return String.fromCharCodes(bytes.where((b) => b >= 32 && b < 127));
  } catch (e) {
    return '';
  }
}

/// UInt32をビッグエンディアンで読み込み
int _readUint32(List<int> bytes, int pos) {
  if (pos + 4 > bytes.length) return 0;
  return (bytes[pos] << 24) | (bytes[pos + 1] << 16) | (bytes[pos + 2] << 8) | bytes[pos + 3];
}
