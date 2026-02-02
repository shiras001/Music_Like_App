# LRCStudio アプリ機能仕様書

## 📋 概要

**LRCStudio** は音声ファイルの再生とLRC歌詞ファイルの同期表示を行うFlutterベースのAndroidアプリケーションです。

### 基本情報
- **パッケージ名**: `com.edalba.lrc`
- **バージョン**: 2.0.9 (ビルド番号: 29)
- **対応Android**: API 24 (Android 7.0) 以上
- **ターゲットSDK**: API 35 (Android 15)
- **開発フレームワーク**: Flutter
- **アーキテクチャ**: ARM v7a対応

---

## 🎯 主要機能

### 1. 音声ファイル再生機能
- 音声ファイルの再生・一時停止・シーク操作
- バックグラウンド再生対応
- メディア通知による再生制御

### 2. LRC歌詞ファイル同期表示
- LRCファイルの読み込みと解析
- 再生時間に同期した歌詞表示
- リアルタイム歌詞ハイライト

### 3. ファイル管理
- 外部ストレージからの音声・歌詞ファイル読み込み
- Scoped Storage対応（Android 10以降）
- ファイル関連付け機能

---

## 🔧 技術仕様

### 使用ライブラリ・フレームワーク

#### Flutter関連
- **Flutter SDK**: 最新版対応
- **Dart**: 最新版対応

#### AndroidX ライブラリ
- **androidx.media**: 1.7.0 - メディア再生制御
- **androidx.core**: 最新版 - コア機能
- **androidx.lifecycle**: 最新版 - ライフサイクル管理
- **androidx.datastore**: 最新版 - データ永続化

#### Flutter プラグイン（推測）
- **fluttertoast**: トースト通知表示
- **wakelock_plus**: 画面スリープ防止

### 権限設定
```xml
<!-- ストレージアクセス -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

<!-- システム機能 -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- 広告ID（推測：アプリ内広告用） -->
<uses-permission android:name="com.google.android.gms.permission.AD_ID" />
```

---

## 📁 ファイル構造解析

### アセット構成
```
assets/
├── images/
│   └── album_art.png          # デフォルトアルバムアート
├── fonts/
│   ├── CustomIcons.ttf        # カスタムアイコンフォント
│   └── MaterialIcons-Regular.otf
└── packages/
    ├── fluttertoast/          # トースト表示用アセット
    └── wakelock_plus/         # スリープ防止用アセット
```

### 通知テンプレート
- メディア再生用通知レイアウト複数種類
- カスタム通知アクション対応
- Android各バージョン対応レイアウト

---

## 🎵 歌詞ファイル（LRC）処理仕様

### LRCファイル形式対応（推測）
```lrc
[00:12.34]歌詞テキスト1行目
[00:15.67]歌詞テキスト2行目
[01:23.45]歌詞テキスト3行目
```

### 処理フロー（推測）
1. **ファイル読み込み**
   - 外部ストレージからLRCファイルを読み込み
   - UTF-8エンコーディング対応

2. **タイムタグ解析**
   - `[mm:ss.xx]` 形式のタイムスタンプ抽出
   - ミリ秒単位での時間管理

3. **同期表示**
   - 音声再生時間とタイムスタンプの照合
   - 現在行のハイライト表示
   - スムーズなスクロール制御

---

## 🎧 音声再生機能仕様

### 対応音声形式（推測）
- MP3, AAC, FLAC, WAV等の一般的な音声形式
- Android MediaPlayerまたはExoPlayer使用

### 再生制御機能
- **基本操作**: 再生/一時停止/停止
- **シーク操作**: プログレスバーによる位置移動
- **バックグラウンド再生**: フォアグラウンドサービス使用

### メディアセッション管理
- Android Media Session Framework使用
- 通知からの再生制御
- Bluetooth/有線ヘッドセット対応

---

## 📱 ユーザーインターフェース

### 画面構成（推測）
1. **メイン画面**
   - 音声ファイル選択
   - 再生コントロール
   - 歌詞表示エリア

2. **ファイル選択画面**
   - 音声ファイル一覧
   - LRCファイル関連付け

3. **設定画面**
   - 表示設定
   - 音声設定

### UI要素
- **カスタムアイコン**: CustomIcons.ttfによる独自アイコン
- **マテリアルデザイン**: AndroidXライブラリ使用
- **多言語対応**: 19言語のローカライゼーション

---

## 🔄 ファイル関連付け仕様

### 音声ファイルとLRCファイルの紐付け（推測）

#### 方法1: ファイル名一致
```
music.mp3  ←→  music.lrc
song.flac  ←→  song.lrc
```

#### 方法2: 同一フォルダ内検索
- 音声ファイルと同名のLRCファイルを自動検索
- 拡張子のみ異なるファイルを関連付け

#### 方法3: 手動選択
- ユーザーによる手動ファイル選択機能
- ファイルピッカーによる関連付け

---

## 💾 データ管理

### ストレージアクセス
- **Scoped Storage対応**: Android 10以降の制限に準拠
- **MediaStore API**: 音声ファイルメタデータ取得
- **SAF (Storage Access Framework)**: ユーザー選択ファイルアクセス

### 設定データ保存
- **DataStore**: アプリ設定の永続化
- **SharedPreferences**: 軽量設定データ

---

## 🎨 メタデータ処理

### 音声ファイル情報取得（推測）
```dart
// 取得可能なメタデータ
- タイトル
- アーティスト
- アルバム名
- 再生時間
- アルバムアート
- ジャンル
```

### 使用API（推測）
- **MediaMetadataRetriever**: ネイティブメタデータ取得
- **Flutter audio metadata plugin**: Flutterプラグイン経由

---

## 🔧 全体アーキテクチャ

### システム構成図（文章説明）

```
┌─────────────────┐    ┌─────────────────┐
│   Flutter UI    │    │  Native Android │
│                 │    │                 │
│ ・歌詞表示      │◄──►│ ・MediaPlayer   │
│ ・再生制御      │    │ ・MediaSession  │
│ ・ファイル選択  │    │ ・通知管理      │
└─────────────────┘    └─────────────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│  File System    │    │   Background    │
│                 │    │    Service      │
│ ・音声ファイル  │    │                 │
│ ・LRCファイル   │    │ ・バックグラウンド│
│ ・設定データ    │    │   再生制御      │
└─────────────────┘    └─────────────────┘
```

### データフロー
1. **ファイル読み込み** → ストレージアクセス → メタデータ抽出
2. **LRC解析** → タイムタグパース → 歌詞データ構造化
3. **音声再生** → MediaPlayer制御 → 再生位置監視
4. **歌詞同期** → 時間比較 → UI更新

---

## ✅ 実装方式のメリット・デメリット

### メリット
- **クロスプラットフォーム**: Flutterによる効率的開発
- **ネイティブ性能**: AndroidXライブラリ活用
- **モダンUI**: Material Designによる統一感
- **多言語対応**: 19言語サポート
- **バックグラウンド対応**: 継続的な音楽再生

### デメリット
- **APKサイズ**: Flutterエンジン込みで約17.8MB
- **メモリ使用量**: Flutter + ネイティブの二重構造
- **デバッグ複雑性**: Flutter-Android間の連携部分
- **権限管理**: 複数ストレージ権限の必要性

---

## 🚀 Flutter/別アプリでの再実装時の注意点

### 1. 権限管理
```dart
// Android 13以降の細分化された権限
- READ_MEDIA_AUDIO (音声ファイル)
- READ_EXTERNAL_STORAGE (レガシー)
- MANAGE_EXTERNAL_STORAGE (特権アプリのみ)
```

### 2. メディア再生
```dart
// 推奨プラグイン
- just_audio: 高機能音声再生
- audio_service: バックグラウンド再生
- media_kit: 次世代メディアフレームワーク
```

### 3. ファイルアクセス
```dart
// Scoped Storage対応
- file_picker: ユーザーファイル選択
- path_provider: アプリディレクトリ
- permission_handler: 権限管理
```

### 4. 歌詞同期実装
```dart
// 実装考慮点
- Timer.periodic による定期更新
- Stream による状態管理
- CustomScrollView による歌詞表示
- AnimatedContainer による滑らかなハイライト
```

### 5. 状態管理
```dart
// 推奨パターン
- Provider/Riverpod: 状態管理
- GetX: 軽量状態管理
- Bloc: 複雑な状態管理
```

---

## 📊 技術的推測の根拠

### APK解析からの確実な情報
- ✅ Flutterアプリケーション（flutter_assetsフォルダ存在）
- ✅ androidx.media 1.7.0使用（バージョンファイル確認）
- ✅ 19言語対応（config.*.apk存在）
- ✅ ARM v7a対応（config.armeabi_v7a.apk存在）
- ✅ 通知機能実装（notification_template_*.xml存在）

### 一般的なAndroid音楽プレイヤー実装からの推測
- 🔍 MediaPlayer/ExoPlayer使用
- 🔍 MediaMetadataRetriever使用
- 🔍 LRCファイル形式対応
- 🔍 ファイル名による関連付け
- 🔍 バックグラウンド再生サービス

---

## 📝 まとめ

LRCStudioは、Flutterフレームワークを基盤とした音声再生・歌詞同期アプリケーションです。AndroidXライブラリを活用したネイティブレベルの音声制御と、Flutterによる柔軟なUI実装を組み合わせた設計となっています。

多言語対応や最新のAndroid権限システムへの対応など、モダンなAndroidアプリケーションとしての要件を満たしており、同様の機能を持つアプリケーションの参考実装として価値の高い構成となっています。