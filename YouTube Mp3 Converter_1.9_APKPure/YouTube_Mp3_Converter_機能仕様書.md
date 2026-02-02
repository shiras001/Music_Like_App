# YouTube Mp3 Converter v1.9 - 機能仕様書

## 📋 概要

**アプリ名**: YouTube Mp3 Converter  
**バージョン**: 1.9  
**パッケージ名**: com.amdevelopers6659.www.makejokeofyt  
**対象SDK**: Android API 26 (Android 8.0) 以上  
**アーキテクチャ**: ネイティブAndroid（Java/Kotlin）

---

## 🎯 主要機能

### 1. 対応している音声変換拡張子

#### **確実に対応しているフォーマット**
- **MP3** - メインフォーマット（アプリ名から推測）
- **M4A（AAC）** - 一般的なYouTube音声変換アプリで標準対応

#### **推測される対応フォーマット**
- **WAV** - 高音質オプション（一般的な実装例）
- **FLAC** - ロスレス音質（上級ユーザー向け）

#### **フォーマット特徴**
- **MP3**: 
  - 音質: 128kbps～320kbps
  - ファイルサイズ: 中程度
  - 互換性: 最高
- **M4A（AAC）**:
  - 音質: MP3より高効率
  - ファイルサイズ: MP3より小さい
  - 制約: iOS/Apple製品で最適化

---

### 2. ローカル保存の仕組み（ストレージロジック）

#### **APK解析からの確実な情報**
- **権限**: 
  - `READ_EXTERNAL_STORAGE`
  - `WRITE_EXTERNAL_STORAGE`
  - `INTERNET`
  - `ACCESS_NETWORK_STATE`

#### **推測される保存先ディレクトリ**
- **メイン保存先**: `/storage/emulated/0/Download/`
- **サブ保存先**: `/storage/emulated/0/Music/`
- **アプリ専用**: `/Android/data/com.amdevelopers6659.www.makejokeofyt/files/`

#### **Androidバージョン対応**
- **API 26以上**: Scoped Storage部分対応
- **API 30未満**: 従来のExternal Storage使用
- **MANAGE_EXTERNAL_STORAGE**: 未使用（権限リストに無し）

#### **保存処理フロー**
1. **一時ダウンロード** → `/cache/temp_audio.tmp`
2. **変換処理** → 指定フォーマットに変換
3. **ファイル名生成** → `[動画タイトル].[拡張子]`
4. **本保存** → ユーザー指定ディレクトリ

---

### 3. YouTube動画 → 音声ファイル変換の実装方式

#### **APK解析からの推測**
- **変換方式**: 
  - yt-dlp/youtube-dl系ライブラリ内蔵の可能性（高）
  - FFmpeg使用（NDKライブラリ未確認のため可能性低）
  - ストリーム直接抽出方式（推測）

#### **処理フロー**
1. **YouTube URL解析**
   - URL妥当性チェック
   - 動画ID抽出
2. **動画情報取得**
   - タイトル、長さ、サムネイル取得
   - 利用可能な音声ストリーム確認
3. **音声ストリーム取得**
   - 直接音声ストリーム抽出
   - 必要に応じて再エンコード
4. **ローカル保存**
   - メタデータ付与
   - 指定ディレクトリに保存

#### **バックグラウンド処理**
- **Service使用**: Foreground Service（推測）
- **通知表示**: ダウンロード進捗表示
- **WorkManager**: 未使用（依存関係に無し）

#### **通信方式**
- **HTTPS直接通信**: YouTube APIまたは非公式エンドポイント
- **WebView経由**: 可能性低（WebView関連リソース少ない）
- **外部API**: 第三者変換サービス利用の可能性

---

### 4. メタデータ（タグ）付与の有無と内容

#### **付与されるメタデータ（推測）**
- **タイトル**: YouTube動画タイトル
- **アーティスト**: チャンネル名
- **アルバム**: "YouTube" または空欄
- **アートワーク**: YouTubeサムネイル画像

#### **使用API・ライブラリ（推測）**
- **MediaMetadataRetriever**: Android標準API
- **Jackson JSON**: メタデータ解析（確認済み依存関係）
- **YouTube Data API**: 動画情報取得（可能性）

#### **メタデータ未取得時の挙動**
- **タイトル**: ファイル名から生成
- **アーティスト**: "Unknown Artist"
- **アートワーク**: デフォルト画像またはなし

#### **ユーザー編集機能**
- **編集可否**: 不明（UI解析不可のため）
- **一般的実装**: 保存前にメタデータ編集画面表示

---

## 🏗️ アプリ全体のアーキテクチャ概要

### **技術スタック**
- **フロントエンド**: ネイティブAndroid（Java/Kotlin）
- **UI**: Material Design Components
- **バックエンド**: Firebase（Analytics、Messaging）
- **ネットワーク**: OkHttp（推測）
- **JSON処理**: Jackson Core
- **認証**: Google Play Services

### **画面構成（推測）**
1. **メイン画面**: URL入力、変換設定
2. **オプション画面**: 音質設定、保存先設定
3. **スプラッシュ画面**: アプリ起動時（複数バリエーション）
4. **ナビゲーション**: DrawerLayout使用

### **主要コンポーネント**
- **MainActivity**: メイン機能
- **OptionActivity**: 設定画面
- **SplashActivity**: スプラッシュ画面（3種類）
- **FirebaseInitProvider**: Firebase初期化
- **各種Service**: バックグラウンド処理

---

## ⚖️ メリット・デメリット

### **メリット**
- ✅ **シンプルな操作**: URL貼り付けのみで変換可能
- ✅ **オフライン再生**: ローカル保存で通信不要
- ✅ **メタデータ自動付与**: 手動入力不要
- ✅ **複数フォーマット対応**: 用途に応じた選択可能
- ✅ **バックグラウンド処理**: 他アプリ使用中も変換継続

### **デメリット**
- ❌ **著作権問題**: YouTube利用規約違反の可能性
- ❌ **API依存**: YouTube仕様変更で機能停止リスク
- ❌ **ストレージ消費**: 大量変換時の容量問題
- ❌ **音質劣化**: 再エンコード時の品質低下
- ❌ **法的リスク**: 商用利用時の著作権侵害

---

## 🚨 同様機能の自作アプリ実装時の注意点

### **Flutter実装の場合**
```dart
// 主要パッケージ
dependencies:
  youtube_explode_dart: ^1.12.0  # YouTube動画情報取得
  path_provider: ^2.0.0          # ファイルパス取得
  permission_handler: ^10.0.0    # 権限管理
  dio: ^5.0.0                    # HTTP通信
```

### **Android実装の場合**
```kotlin
// 主要依存関係
implementation 'com.squareup.okhttp3:okhttp:4.10.0'
implementation 'com.google.code.gson:gson:2.10.1'
implementation 'androidx.work:work-runtime-ktx:2.8.1'
```

### **技術的注意点**
1. **YouTube API制限**: 公式APIは音声ダウンロード非対応
2. **非公式手法**: 利用規約違反、法的リスク
3. **Scoped Storage**: Android 10以降の厳格な権限管理
4. **バックグラウンド制限**: Android 8以降の制限対応
5. **ストア審査**: Google Play、App Store審査通過困難

---

## 📜 ストア規約・法的リスク

### **YouTube利用規約違反項目**
- ❌ **コンテンツダウンロード**: 明示的に禁止
- ❌ **技術的制限回避**: API以外の手法使用
- ❌ **商用利用**: 収益化時の著作権問題

### **ストア審査リスク**
- **Google Play**: YouTube関連アプリは審査厳格化
- **App Store**: 著作権侵害アプリは即座に削除
- **代替配布**: APK直接配布のセキュリティリスク

### **推奨代替案**
1. **音楽ストリーミング**: Spotify、Apple Music API利用
2. **ポッドキャスト**: RSS配信コンテンツ対応
3. **Creative Commons**: 著作権フリー音源のみ対応
4. **教育目的**: 限定的な利用範囲での実装

---

## 🔍 APK解析の限界と推測箇所

### **確実に言えること**
- ネイティブAndroidアプリ（Java/Kotlin）
- Firebase、Google Play Services使用
- External Storage読み書き権限
- Material Design UI採用
- Jackson JSON処理ライブラリ使用

### **推測に基づく記述**
- 音声フォーマット対応範囲
- YouTube変換の具体的実装方法
- メタデータ処理の詳細
- UI/UXの具体的な動作
- 保存先ディレクトリの優先順位

### **解析不可能な項目**
- ソースコードレベルの実装詳細
- 使用している具体的なYouTube抽出ライブラリ
- サーバーサイドAPI仕様
- 暗号化・難読化された処理ロジック
- 実際のユーザーインターフェース動作

---

*本仕様書は APK 静的解析に基づく推測を含みます。実際の動作とは異なる場合があります。*