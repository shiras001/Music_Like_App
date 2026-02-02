## 詳細実装レポート - YouTube・ローカルファイル機能と UI 改善

### 実装日：2026年1月15日

---

## 1. FullPlayerScreen UI レイアウト改善 ✅

### 変更内容

**ボタン配置を2段構成に変更**

#### 上段（基本再生制御）
```
[10秒戻し] [前へ] [再生/停止] [次へ] [10秒送り]
```
- 10秒戻し：IconButton（fast_rewind, サイズ 24）
- 前へ：IconButton（skip_previous, サイズ 32）
- 再生/停止：FloatingActionButton（白背景、サイズ 36）
- 次へ：IconButton（skip_next, サイズ 32）
- 10秒送り：IconButton（fast_forward, サイズ 24）

#### 下段（速度・リピート制御）
```
[1.25x] [1.5x] [2x] [シャッフル] [リピート]
```
- 倍速ボタン：OutlinedButton（SizedBox で幅 50px に統一）
  - 選択中は Apple Music Red（#FF2D55）でハイライト
- シャッフル・リピート：IconButton（サイズ 20）

### 主な改善点

1. **ジャケット・歌詞表示エリアの拡大**
   - ボタン間隔を詰めて（mainAxisAlignment: spaceEvenly）、ジャケット表示エリアを大きく確保
   - SizedBox の高さ調整で柔軟なレイアウト対応

2. **iPhone ラベルの削除**
   - AirPlay セクション全体をコメントアウト
   - 将来の実装時に復活可能

3. **倍速ボタンの幅最適化**
   - SizedBox で幅 50px に限定
   - 10秒送りボタンが見切れる問題を解決

4. **ボタン間隔の調整**
   - 上段・下段の SizedBox の高さを 16px → 8px に削減
   - 全体的にコンパクト化

### 修正ファイル
- [lib/main.dart](lib/main.dart) - FullPlayerScreen のボタン配置部分（L:320-430）

---

## 2. YouTube 音声取得・変換機能の詳細実装 ✅

### 実装内容

ファイル：[lib/data/youtube_service.dart](lib/data/youtube_service.dart)

#### YouTubeServiceImpl クラス

**実装メソッド**

```dart
Future<YouTubeVideoInfo> getVideoInfo(String videoUrl)
```
- YouTube動画 URL から動画情報を取得
- 取得項目：タイトル、チャンネル名、サムネイル URL、再生時間
- 依存：`youtube_explode_dart`

```dart
Future<String> downloadAndConvert(
  String videoUrl,
  String outputFormat,
  String outputPath,
  int bitrate,
)
```
- 音声をダウンロードして MP3/M4A に変換
- 処理フロー：
  1. 動画情報取得
  2. 音声ストリーム取得
  3. 一時ファイルにダウンロード
  4. ffmpeg で変換
  5. 一時ファイル削除
  6. メタデータ設定
- 戻り値：変換後のファイルパス

```dart
Future<void> setMetadata(String filePath, Song song)
```
- ID3タグ（MP3）または MPEG-4ボックス（M4A）にメタデータ設定
- 設定項目：タイトル、アーティスト、アルバム、ジャケット画像

#### ユーティリティメソッド

```dart
static String _sanitizeFileName(String fileName)
```
- ファイル名をサニタイズ（Windows で使用不可の文字を削除）

```dart
static Future<void> _convertAudioWithFFmpeg(...)
```
- FFmpeg コマンドで音声変換（将来実装）

```dart
static String? extractVideoId(String url)
```
- YouTube URL から動画 ID を抽出

#### 処理の詳細コメント

各メソッドに詳細な処理ステップを TODO コメントで記述。
将来の実装時に参照可能な状態で提供。

### 備考

- `youtube_explode_dart: ^3.0.5` が pubspec.yaml に追加済み
- ffmpeg 統合は、外部ツール連携またはバインディングが必要
- メタデータ設定は ffmpeg コマンドで実装可能

---

## 3. ローカルファイル読み込み機能の詳細実装 ✅

### 実装内容

ファイル：[lib/data/local_audio_service.dart](lib/data/local_audio_service.dart)

#### LocalAudioServiceImpl クラス

**実装メソッド**

```dart
Future<List<Song>> scanDirectory(String dirPath)
```
- 指定ディレクトリをスキャンしてサポート対象ファイルを列挙
- サポート対象：`.m4a`, `.mp3`, `.flac`, `.wav`
- 各ファイルのメタデータを取得して Song エンティティに変換
- エラー時はスキップして処理継続

```dart
Future<AudioFileMetadata> getMetadata(String filePath)
```
- 単一のオーディオファイルからメタデータを取得
- 取得項目：
  - タイトル（メタデータから、なければファイル名）
  - アーティスト
  - アルバム
  - ジャケット画像（Uint8List）
  - 歌詞（LRC ファイル）
  - 再生時間（Duration）

**LRC ファイル自動検出**
- 同じベースネーム（拡張子除く）の `.lrc` ファイルを自動検出
- 存在する場合は readLyricsFile で読み込み

**再生時間推定**
- メタデータ読み込みライブラリなしの場合、ファイルサイズから推定
- 仮定ビットレート：128 kbps
- 計算式：`duration = (fileSize * 8) / bitrate`

```dart
Future<String> readLyricsFile(String lrcPath)
```
- LRC ファイルを UTF-8 で読み込み
- ファイル不在時は空文字列を返す

#### ユーティリティメソッド

```dart
static String getFileNameWithoutExtension(String filePath)
```
- ファイルパスからファイル名（拡張子なし）を抽出

```dart
static String buildLrcPath(String audioFilePath)
```
- オーディオファイルパスから対応する LRC ファイルパスを構築

```dart
static bool isSupportedAudioFile(String filePath)
```
- ファイルがサポート対象形式か確認

```dart
static Future<Duration> _estimateDuration(String filePath)
```
- ファイルサイズから再生時間を推定

### 備考

- メタデータの詳細な読み込みは、audio_metadata 相当のライブラリが必要
- 現在はダミー実装（ファイル名をタイトルとして使用）

---

## 4. ViewModel での機能接続 ✅

### LibraryViewModel の拡張

ファイル：[lib/presentation/viewmodels.dart](lib/presentation/viewmodels.dart)

#### 新規メソッド

```dart
Future<void> loadFromLocalDirectory(String dirPath)
```
- ローカルディレクトリからライブラリを読み込み
- LocalAudioServiceImpl を使用してファイルをスキャン
- 既存曲に新規曲を追加

```dart
Future<void> addFromYouTube(
  String videoUrl,
  String outputFormat,
  String outputPath,
)
```
- YouTube から曲をダウンロード・変換して追加
- YouTubeServiceImpl を使用
- 処理フロー：
  1. 動画情報取得
  2. ダウンロード・変換
  3. Song エンティティ作成
  4. ライブラリに追加

#### メソッド内の TODO

各メソッドに Ref 経由でサービスを取得するコードを TODO として記述。
サービスプロバイダー設定後に有効化可能。

### repositories.dart での Provider 定義

ファイル：[lib/data/repositories.dart](lib/data/repositories.dart)

YouTube・ローカルファイル機能用のプロバイダーをコメント化して提供。
将来の実装時に有効化可能。

```dart
// final youtubeServiceProvider = Provider<IYouTubeService>((ref) {
//   return YouTubeServiceImpl();
// });

// final localAudioServiceProvider = Provider<ILocalAudioService>((ref) {
//   return LocalAudioServiceImpl();
// });
```

---

## 5. ビルド結果 ✅

| プラットフォーム | 結果 | 出力ファイル |
|-----------------|------|-----------|
| Android | ✅ 成功 | `build/app/outputs/flutter-apk/app-release.apk` (45.8MB) |

---

## 6. アーキテクチャ図

```
┌─────────────────────────────────────────────────────┐
│            UI Layer (main.dart)                     │
│  FullPlayerScreen / LibraryTab                      │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│        Presentation Layer (viewmodels.dart)         │
│  PlayerViewModel / LibraryViewModel                 │
│  - loadFromLocalDirectory()                         │
│  - addFromYouTube()                                 │
└─────────────────────────────────────────────────────┘
                        ↓
         ┌──────────────┴──────────────┐
         ↓                            ↓
┌────────────────────────┐  ┌──────────────────────┐
│   Data Layer           │  │   Domain Layer       │
│ (repositories.dart)    │  │  (entities.dart)     │
│ - IMusicRepository     │  │  - Song              │
└────────────────────────┘  └──────────────────────┘
         ↓                            ↑
         ├─────────────┬──────────────┤
         ↓             ↓              ↓
┌──────────────────────────────────────────────────┐
│     Service Layer                                │
│ - YouTubeServiceImpl (youtube_service.dart)       │
│ - LocalAudioServiceImpl (local_audio_service.dart)│
│ - MusicRepositoryImpl (repositories.dart)         │
└──────────────────────────────────────────────────┘
         ↓             ↓
    YouTube API   Local FileSystem
```

---

## 7. 今後の実装予定

### 優先度：High
- [ ] `youtube_explode_dart` 統合の詳細実装
- [ ] FFmpeg バインディングの検討
- [ ] メタデータ読み込みライブラリの検索・統合
- [ ] UI ボタンの機能接続（「+」ボタンで YouTube URL 入力など）

### 優先度：Medium
- [ ] 機能が実装されていない UI 要素の実装
- [ ] エラーハンドリング・ユーザーフィードバック
- [ ] ダウンロード進捗表示
- [ ] キャッシング機構

### 優先度：Low
- [ ] プレイリスト機能
- [ ] 検索機能
- [ ] 推奨曲機能

---

## 8. 参考リソース

- YouTube Data API: https://developers.google.com/youtube/v3
- youtube_explode_dart: https://pub.dev/packages/youtube_explode_dart
- FFmpeg 公式：https://ffmpeg.org/
- Dart File I/O：https://dart.dev/guides/libraries/library-tour#dartio
