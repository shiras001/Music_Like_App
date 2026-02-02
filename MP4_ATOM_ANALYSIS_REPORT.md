# M4A MP4 Atom 構造分析レポート

## 📋 概要

このレポートは、M4AファイルのMP4 Atom構造の詳細分析と、既存の `_findMp4Box` 関数がメタデータを見つけられない理由の診断です。

---

## 1️⃣ ファイル構造の分析

### テスト対象ファイル
- **三原色.m4a** (1,449,376 bytes)
- **蝶々結び.m4a** (7,431,683 bytes)

### 最初の1000バイトの16進数表示

```
00000000: 00 00 00 1c 66 74 79 70 69 73 6f 6d 00 00 02 00  ....ftypisom....
00000010: 69 73 6f 6d 69 73 6f 32 6d 70 34 31 00 01 64 6c  isomiso2mp41..dl
00000020: 6d 6f 6f 76 00 00 00 6c 6d 76 68 64 00 00 00 00  moov...lmvhd....
```

**解釈:**
- `00 00 00 1c` = サイズ 28 bytes
- `66 74 79 70` = "ftyp" (ファイルタイプ)
- その後の位置 28 から moov が開始

---

## 2️⃣ MP4 Atom 階層構造

### 期待される構造（標準的なM4A）

```
ftyp                           (ファイルタイプボックス)
moov                           (メタデータコンテナ)
├─ mvhd                        (ムービーヘッダー)
├─ trak                        (トラック情報)
│  ├─ tkhd
│  ├─ edts
│  └─ mdia
└─ udta                        ⭐ ユーザーデータ（メタデータはここ）
   └─ meta                     ⭐ メタデータコンテナ
      ├─ hdlr                  (ハンドラー記述)
      └─ ilst                  ⭐ Item List（個別メタデータ）
         ├─ ©nam              (タイトル)
         │  └─ data           (テキストデータ)
         ├─ ©ART              (アーティスト)
         │  └─ data           (テキストデータ)
         ├─ ©alb              (アルバム)
         │  └─ data           (テキストデータ)
         └─ ...その他のタグ
mdat                           (メディアデータ)
```

### 実際の三原色.m4a の構造

```
[0-27]           ftyp (28 bytes) - ファイルタイプ
[28-91271]       moov (91,244 bytes) - メタデータコンテナ
  ├─ [36-143]       mvhd (108 bytes)
  ├─ [144-20262]    trak (20,119 bytes) - オーディオトラック
  └─ [20263-91271]  udta (71,009 bytes) - ユーザーデータ
      └─ [20271-91271]  meta (71,001 bytes) - メタデータコンテナ
          ├─ [20283-20315]  hdlr (33 bytes)
          └─ [20316-88945]  ilst (68,630 bytes) - Item List
              ├─ [20324-20356]  ©nam (33 bytes) - タイトル
              ├─ [20357-20387]  ©ART (31 bytes) - アーティスト
              ├─ [20388-20423]  ©too (36 bytes) - 制作ツール
              └─ [20424-88945]  covr (68,522 bytes) - ジャケット画像
[91272-91279]    free (8 bytes) - 空き領域
[91280-1449375]  mdat (1,358,096 bytes) - 音声データ
```

---

## 3️⃣ 見つかったメタデータタグ

### 成功例：©nam（タイトル）
```
位置:    20324
サイズ:  33 bytes
構造:    [size:4] [type:4] [data atom]

内容:
  [20324] size: 33
  [20328] type: ©nam
  [20332] data size: 25
  [20336] data type: data
  [20340] version: 0, flags: 0x1, reserved: 0x0
  [20348] テキスト: "三原色" (UTF-8)
```

### 成功例：©ART（アーティスト）
```
位置:    20357
サイズ:  31 bytes

内容:
  [20357] size: 31
  [20361] type: ©ART
  [20365] data size: 23
  [20369] data type: data
  [20373] version: 0, flags: 0x1, reserved: 0x0
  [20381] テキスト: "YOASOBI"
```

### 失敗例：©alb（アルバム）
```
❌ 見つかりません

原因: このファイルにはアルバム情報が含まれていない
      （©alb タグが存在しないため）
```

---

## 4️⃣ 既存 _findMp4Box 関数の問題点

### ❌ 問題1：meta atom の構造を無視

**meta atom の形式:**
```
[0-3]   size        (4 bytes, ビッグエンディアン)
[4-7]   type = "meta" (4 bytes)
[8]     version      (1 byte)
[9-11]  flags        (3 bytes)
[12+]   content      ← ここから ilst atom が始まる
```

**既存の実装の問題:**
```dart
// 既存コード（間違い）
final bodyStart = i + 8;  // version/flags をスキップしていない！
final bodyEnd = (size > 1) ? (i + size) : bytes.length;
return bytes.sublist(bodyStart, bodyEnd);
```

**何が起きているか:**
- `version` (1 byte) + `flags` (3 bytes) をスキップせず
- `hdlr` atom（33 bytes）の中から `ilst` を探そうとしている
- 結果：検索位置がずれて `ilst` を見つけられない

### ❌ 問題2：階層の走査が不正確

**必要な階層:**
```
moov (bodyStart=28)
  → udta (bodyStart=20271)
    → meta (bodyStart=20279, but version/flags at [20279-20282])
      → ilst (bodyStart=20316, but meta's version/flags ignored!)
```

**既存の実装:**
```dart
// meta の中身を探索しても、version/flags の4バイトが無視されている
final found = _findMp4Box(bytes.sublist(bodyStart, bodyEnd), tag);
```

結果：`ilst` の位置がずれて、その中のタグが見つからない

### ❌ 問題3：サイズが0の場合の処理

```
位置: 20279 の byte 値をサイズとして読むと 0
これは「ファイル終端まで」を意味するが、
meta の内容は [20283, 91272) の範囲
```

---

## 5️⃣ 修正方法

### 解決策1：meta atom の version/flags をスキップ

```dart
// meta 用の特別な処理
if (type == 'meta' && size > 12) {
  // version (1) + flags (3) をスキップして content を取得
  final metaContent = bytes.sublist(i + 12, i + size);
  final found = _findMp4Box(metaContent, tag);
  if (found != null) return found;
}
```

### 解決策2：構造を明示的に走査

```dart
/// ✅ 修正版：階層を正しく処理
static String? _findMp4AtomTextFixed(List<int> bytes, List<int> tag) {
  try {
    // Step 1: moov → udta → meta → ilst の順で検索
    
    // moov を見つける
    final moovBody = _findMp4Box(bytes, [0x6D, 0x6F, 0x6F, 0x76]); // 'moov'
    if (moovBody == null) return null;
    
    // udta を見つける
    final udtaBody = _findMp4Box(moovBody, [0x75, 0x64, 0x74, 0x61]); // 'udta'
    if (udtaBody == null) return null;
    
    // meta を見つける
    final metaBody = _findMp4Box(udtaBody, [0x6D, 0x65, 0x74, 0x61]); // 'meta'
    if (metaBody == null) return null;
    
    // ⭐ 重要：meta の version/flags をスキップ
    final metaContent = (metaBody.length > 4) 
        ? metaBody.sublist(4)
        : metaBody;
    
    // ilst を見つける
    final ilstBody = _findMp4Box(metaContent, [0x69, 0x6C, 0x73, 0x74]); // 'ilst'
    if (ilstBody == null) return null;
    
    // 目的のタグを見つける
    final tagBody = _findMp4Box(ilstBody, tag);
    if (tagBody == null) return null;
    
    // data atom を見つける
    final dataBody = _findMp4Box(tagBody, [0x64, 0x61, 0x74, 0x61]); // 'data'
    if (dataBody == null) return null;
    
    // ⭐ data の version/flags/reserved をスキップ
    if (dataBody.length <= 8) return null;
    final payload = dataBody.sublist(8);
    
    return _decodeTextBytesRobust(payload);
  } catch (e) {
    debugPrint('[MP4 Error] $e');
    return null;
  }
}
```

---

## 6️⃣ 修正版の検証結果

### テスト実行

```
✅ ©nam - Title: "三原色" (正常に取得できた！)
✅ ©ART - Artist: "YOASOBI" (正常に取得できた！)
❌ ©alb - Album: not found (ファイルに存在しないため)
```

### udta 構造の詳細確認

```
udta atom: position=20263, size=71009
└─ meta を検索範囲: 20271 ~ 91272

  ├─ [20271] type: "meta", size: 71001
  │  ⭐ meta atom found!
  │  └─ version/flags を考慮した content start: 20283
  │     ├─ [20283] type: "hdlr", size: 33
  │     ├─ [20316] type: "ilst", size: 68630
  │     │  ⭐ ilst atom found!
  │     │  └─ items を検索
  │     │     ├─ [20324] type: "©nam", size: 33 ✅
  │     │     ├─ [20357] type: "©ART", size: 31 ✅
  │     │     ├─ [20388] type: "©too", size: 36
  │     │     └─ [20424] type: "covr", size: 68522 (ジャケット)
```

**結論:**
- `meta` の version/flags をスキップすることで、`ilst` を正しく検出可能
- `ilst` 内のすべてのタグが正しく配置されている
- 既存の関数は、このスキップ処理がないため失敗していた

---

## 7️⃣ 推奨修正

### local_audio_service.dart への適用

```dart
// 既存コード の後に、改善版を追加

/// ✅ 改善版：meta atom の構造を正しく処理
static String? _findMp4AtomTextFixed(List<int> bytes, List<int> tag) {
  // 上記の修正版実装を使用
}

// 既存の _findMp4AtomText を以下のように修正:
// 1. meta atom 検出時に version/flags をスキップ
// 2. または、新しい _findMp4AtomTextFixed を使用
```

### 具体的な修正内容

**修正前:**
```dart
static List<int>? _findMp4Box(List<int> bytes, List<int> tag) {
  // ... 既存コード ...
  // meta atom の処理が不正確
}
```

**修正後:**
```dart
static List<int>? _findMp4Box(List<int> bytes, List<int> tag) {
  // ... 既存コード ...
  
  // ⭐ 追加: meta atom の特別処理
  if (match) {
    // meta の場合、version/flags をスキップ
    if (String.fromCharCodes(type) == 'meta' && size > 12) {
      final metaContent = bytes.sublist(bodyStart + 4, bodyEnd);
      final found = _findMp4Box(metaContent, tag);
      if (found != null) return found;
    }
    // ... その他のコード ...
  }
}
```

---

## 📊 分析結果サマリー

| 項目 | 詳細 |
|------|------|
| **©nam タグ** | ✅ 見つかった at 位置 20324 |
| **©ART タグ** | ✅ 見つかった at 位置 20357 |
| **©alb タグ** | ❌ ファイルに存在しない |
| **meta 構造** | ❌ version/flags がスキップされていない |
| **ilst 構造** | ❌ meta の処理ミスで見つけられない |
| **修正版での回復** | ✅ meta の version/flags をスキップで解決 |

---

## 🎯 結論

### 既存関数がメタデータを見つけられない理由

1. **meta atom の構造を無視**
   - `[size:4] [type:4] [version:1] [flags:3] [content]` 
   - version/flags の4バイトをスキップしていない

2. **検索位置のずれ**
   - `ilst` を見つけられず、その中のタグを検索できない

3. **階層走査の不正確性**
   - 再帰的な検索では、各レベルの特殊な構造を考慮していない

### 修正のポイント

✅ **meta atom 内のコンテンツは `pos + 12` から始まる**
- meta は特殊な atom で version/flags を持つ
- 通常の atom (`pos + 8`) とは異なる

✅ **階層を明示的に処理**
- `moov → udta → meta (skip 4) → ilst → tag → data`
- 各レベルで特殊な処理が必要な場合がある

✅ **data atom のペイロードも同様に処理**
- `data: [size:4] [type:4] [version:1] [flags:3] [reserved:4] [text]`
- テキストは `offset + 16` から開始

---

## 🔧 実装ファイル

分析に使用したDartプログラム：
- `analyze_m4a_structure.dart` - 基本的なatom構造分析
- `analyze_m4a_detailed.dart` - 詳細分析と問題診断
- `analyze_m4a_fixed.dart` - 修正版実装とテスト

すべてのプログラムは、以下のコマンドで実行可能：
```bash
dart analyze_m4a_structure.dart
dart analyze_m4a_detailed.dart
dart analyze_m4a_fixed.dart
```

---

*生成日: 2026年2月1日*
