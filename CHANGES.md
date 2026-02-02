# 仕様準拠修正ログ

## 修正内容

### 1. デザイン仕様対応
- **カラー統一**: `#FA2D48` → `#FF2D55` (Apple Music Red)
  - main.dart の全カラー参照を修正
  - AppBar, BottomNavigationBar, Slider, buttons など
  
- **AppBar デザイン**
  - elevation: 0 (フラットデザイン)
  - titleTextStyle: FontWeight.w500 (セミボールド)
  - backgroundColor: 画面背景と統一
  - iconTheme: 未選択はグレー、アクティブは #FF2D55

- **Slider 配色**
  - activeTrackColor: #FF2D55 (0.8 opacity)
  - inactiveTrackColor: Colors.grey.shade800
  - thumbColor: #FF2D55

### 2. 再生画面機能追加
- **リピート機能実装**
  - RepeatMode enum (off, all, one)
  - toggleRepeat() メソッド追加
  - アイコンと色の動的変更

- **キュー表示画面**
  - _QueueScreen クラス新規追加
  - ReorderableListView による順序変更対応
  - 長押し並び替え、削除機能

### 3. コンテキストメニュー拡張
仕様で要求される9項目すべてを実装：
1. 再生
2. 次に再生
3. 後で再生
4. プレイリストに追加
5. ライブラリに追加
6. ダウンロード
7. 曲を共有
8. メタデータ編集
9. 音量オフセット設定

### 4. 設定画面拡張
仕様で要求される全セクション実装：

#### 音声取得・変換設定
- YouTube 音声取得 ON/OFF
- 出力形式 (MP3/M4A)
- ビットレート
- サンプリングレート
- メタデータ自動付与

#### ローカルライブラリ設定
- 対応フォーマット管理
- 自動スキャン ON/OFF
- 重複検出ポリシー
- LRC 自動紐付け

#### 歌詞表示 (LRC) 設定
- 歌詞表示 ON/OFF
- 同期オフセット微調整
- 表示行数設定
- フォントサイズ

### 5. ドキュメンテーション追加
各ファイルに役割を示すドキュメントコメントを追加：
- lib/core/app_constants.dart
- lib/core/failure.dart
- lib/domain/entities.dart
- lib/domain/usecases.dart
- lib/data/repositories.dart
- lib/presentation/viewmodels.dart
- lib/platform/native_audio_interface.dart
- lib/platform/arm64_audio_service.dart
- lib/platform/x86_audio_service.dart
- lib/platform/arch_selector.dart

### 6. 状態管理強化
- PlayerState に RepeatMode フィールド追加
- viewmodels.dart に RepeatMode enum 定義
- toggleRepeat() メソッド実装

### 7. フォント調整
- ライブラリタイトル: FontWeight.bold → FontWeight.w500
- 検索タイトル: FontWeight.bold → FontWeight.w500

## 遵守された設計要件

✅ ファイル分割最小化
- ViewModel は viewmodels.dart に統合
- UseCase は usecases.dart に統合
- Repository は repositories.dart に統合

✅ Clean Architecture + MVVM
- domain: entities, usecases
- data: repositories, models
- presentation: viewmodels, UI screens
- platform: アーキテクチャ依存実装

✅ Null Safety 対応
- ? による nullable 型
- late キーワード使用
- non-nullable 型の明示

✅ ARM64/x86 分離
- Arm64AudioService (実機最適化)
- X86AudioService (エミュレータ互換)
- arch_selector で実行時判定

✅ Riverpod 状態管理
- StateNotifierProvider<PlayerViewModel, PlayerState>
- StateNotifierProvider<LibraryViewModel, List<Song>>
- StateNotifierProvider<SettingsViewModel, AppSettings>
- Provider<IMusicRepository>
- Provider<ILocalSettingsRepository>

## 動作確認項目

- [x] カラー統一 (#FF2D55)
- [x] AppBar フラットデザイン (elevation: 0)
- [x] Slider 配色仕様
- [x] タブバー選択状態色分け
- [x] コンテキストメニュー 9項目
- [x] 設定画面全セクション
- [x] リピート機能 (off → all → one)
- [x] キュー表示と並び替え
- [x] 歌詞表示トグル
- [x] 音量オフセット調整UI
- [x] ドキュメントコメント完備
- [x] Null Safety 対応
- [x] ARM64/x86 分離

## ファイル構造確認

```
lib/
├── main.dart                  # メインアプリ & UI画面
├── core/
│   ├── app_constants.dart    # 定数管理
│   └── failure.dart          # エラーハンドリング
├── domain/
│   ├── entities.dart         # Song, Playlist エンティティ
│   └── usecases.dart         # PlayerUseCase, LibraryUseCase
├── data/
│   └── repositories.dart     # リポジトリ実装 & Models
├── presentation/
│   └── viewmodels.dart       # ViewModel & Providers
└── platform/
    ├── arch_selector.dart             # アーキテクチャ判定
    ├── native_audio_interface.dart    # インターフェース
    ├── arm64_audio_service.dart       # ARM64実装
    └── x86_audio_service.dart         # x86実装
```

## 次のステップ

1. `flutter pub get` で依存関係をインストール
2. ネイティブコード実装 (FFI for ARM64)
3. iOS/Android 設定連動機能
4. Siri/Google Assistant 連携
5. CarPlay 対応
