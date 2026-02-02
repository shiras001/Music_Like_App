## 実装完了レポート

### 実装日：2026年1月15日

---

## 1. FullPlayerScreen への再生制御ボタン追加 ✅

### 実装内容
フルプレイヤー画面の下部に、以下の再生制御ボタンを追加しました：

- **10秒戻しボタン** (`skip10SecondsBackward()`)
- **10秒送りボタン** (`skip10SecondsForward()`)
- **早送りボタン**（1.25倍、1.5倍、2倍速度）

### 修正ファイル
- [lib/presentation/viewmodels.dart](lib/presentation/viewmodels.dart)
- [lib/main.dart](lib/main.dart)

### 具体的な実装

#### PlayerState への再生速度プロパティ追加
```dart
class PlayerState {
  // ... 既存フィールド ...
  final double playbackSpeed; // 再生速度（1.0=通常、1.25, 1.5, 2.0など）
  
  PlayerState({
    // ... 既存パラメータ ...
    this.playbackSpeed = 1.0,
  });
}
```

#### PlayerViewModel への再生制御メソッド実装
- `skip10SecondsBackward()` - 10秒戻す
- `skip10SecondsForward()` - 10秒送る
- `setPlaybackSpeed(double speed)` - 再生速度を設定
- `seekTo(Duration position)` - シークバーからの位置指定に対応

#### UI レイアウト
再生ボタン群の下部に新しい制御行を追加：
```
[10秒戻し]  [1.25x]  [1.5x]  [2x]  [10秒送り]
```

各ボタンの状態：
- **スピードボタン**：選択中のスピードがハイライト表示（Apple Music Red色）
- **スキップボタン**：ElevatedButton で統一されたスタイル

---

## 2. シークバー機能の実装 ✅

### 実装内容
シークバーのドラッグ操作で再生位置を変更できるようにしました。

### コード例
```dart
Slider(
  value: playerState.position.inSeconds.toDouble().clamp(...),
  max: song.duration.inSeconds.toDouble(),
  onChanged: (val) {
    ref.read(playerProvider.notifier).seekTo(Duration(seconds: val.toInt()));
  },
)
```

---

## 3. YouTube音声取得・変換機能の設計 ✅

### 実装内容
YouTube動画から音声を取得してMP3/M4Aに変換するためのサービスを設計・実装しました。

### 新規作成ファイル
- [lib/data/youtube_service.dart](lib/data/youtube_service.dart)

### インターフェース定義
```dart
abstract class IYouTubeService {
  /// YouTubeのURLから動画情報を取得
  Future<YouTubeVideoInfo> getVideoInfo(String videoUrl);

  /// 音声をダウンロードして MP3/M4A に変換
  Future<String> downloadAndConvert(
    String videoUrl,
    String outputFormat,
    String outputPath,
    int bitrate,
  );

  /// メタデータを設定（ID3タグ等）
  Future<void> setMetadata(String filePath, Song song);
}
```

### 処理フロー
1. **動画情報取得** - youtube_explode_dart で URL から動画情報（タイトル、チャンネル名、サムネイル）を抽出
2. **音声ストリーム取得** - 利用可能な音声ストリームを取得
3. **ダウンロード** - 一時ファイルに保存
4. **変換** - ffmpeg で MP3/M4A に変換（将来的実装）
5. **メタデータ設定** - ID3タグにタイトル、アーティスト、アルバム、ジャケット画像を設定

### 利用ライブラリ
- `youtube_explode_dart: ^3.0.5` - YouTube動画情報・音声ストリーム取得

### 注意事項
- **技術的検証・個人利用のみ**を目的とする
- ffmpeg による音声変換は、別途 ffmpeg コマンドラインツールのセットアップが必要
- メタデータ設定は、ID3タグ（MP3）または MPEG-4ボックス（M4A）で実装予定

---

## 4. ローカルファイル読み込み機能の設計 ✅

### 実装内容
オーディオファイルのメタデータを取得してライブラリに追加するサービスを設計しました。

### 新規作成ファイル
- [lib/data/local_audio_service.dart](lib/data/local_audio_service.dart)

### インターフェース定義
```dart
abstract class ILocalAudioService {
  /// 指定されたディレクトリ内のオーディオファイルをスキャン
  Future<List<Song>> scanDirectory(String dirPath);

  /// 単一のオーディオファイルからメタデータを取得
  Future<AudioFileMetadata> getMetadata(String filePath);

  /// LRC ファイルを読み込み
  Future<String> readLyricsFile(String lrcPath);
}
```

### サポート対象ファイル形式
- オーディオファイル：`.m4a`, `.mp3`, `.flac`, `.wav`
- 歌詞ファイル：`.lrc`

### メタデータ取得項目
- **タイトル** - ファイルのメタデータから取得（なければファイル名）
- **アーティスト** - メタデータから取得
- **アルバム** - メタデータから取得
- **ジャケット画像** - 埋め込まれた画像データを抽出
- **歌詞** - 同名の LRC ファイルを自動検出・関連付け
- **再生時間** - オーディオファイルの長さ（Duration）

### LRC ファイル自動リンク
同一ディレクトリ内で、オーディオファイルと同じベースネーム（拡張子除く）の LRC ファイルを自動検出し、メタデータに含めます。

例：
```
Music/
├─ song1.mp3         ← メタデータ取得
├─ song1.lrc         ← 自動検出・リンク
├─ song2.flac        ← メタデータ取得
└─ song2.lrc         ← 自動検出・リンク
```

---

## 5. パッケージ依存関係の追加 ✅

### 追加ライブラリ

| ライブラリ | バージョン | 用途 |
|----------|-----------|------|
| `youtube_explode_dart` | ^3.0.5 | YouTube動画情報・音声ストリーム取得 |
| `path` | ^1.8.0 | ファイルパス操作 |
| `http` | ^1.1.0 | HTTP通信（動画情報取得） |

### 非採用ライブラリ
- ~~`ffmpeg_kit_flutter`~~ - Android v1 embedding 非互換のため除外
- ~~`file_picker`~~ - Android v1 embedding 非互換のため除外
- ~~`audio_metadata`~~ - 対応バージョンなし

### 将来的な検討
- FFmpeg Dart バインディングの検索・採用
- ネイティブコード（Kotlin/Swift）でのファイル選択実装
- オーディオメタデータ読み込みライブラリの調査

---

## 6. ビルド結果 ✅

| プラットフォーム | 結果 | 出力ファイル |
|-----------------|------|-----------|
| Android | ✅ 成功 | `build/app/outputs/flutter-apk/app-release.apk` (45.8MB) |

---

## 7. 次のステップ（今後の実装予定）

### YouTube音声取得機能
- [ ] `youtube_explode_dart` を使用した詳細な実装
- [ ] ffmpeg コマンドラインツール連携
- [ ] メタデータ（ID3タグ）の自動設定
- [ ] ダウンロード進捗の表示

### ローカルファイル読み込み機能
- [ ] `Audio_metadata` 相当の軽量ライブラリ探索
- [ ] メタデータ読み込み機能の詳細実装
- [ ] LRC ファイル解析・同期再生機能
- [ ] ファイルスキャン UI の実装

### その他
- [ ] 機能が実装されていない UI 要素の実装（ミニプレイヤーのスキップ、コンテキストメニューなど）
- [ ] Platform層（NativeAudioService）とViewModelの連携
- [ ] アーキテクチャ別オーディオ処理（ARM64、x86）の実装

---

## 8. 備考

- ~~Android ビルド時のプラグイン互換性~~ → 最新のパッケージを使用可能なものに限定
- 本アプリケーションのビルド・利用は **技術的検証・個人利用** を目的とします
- YouTube 動画情報・音声取得に関しては、YouTube の利用規約を遵守してください
