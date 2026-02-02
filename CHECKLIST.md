# Music Like アプリ - 仕様準拠チェックリスト

## ✅ UI デザイン仕様

### カラーデザイン (仕様 12.1)
- [x] メインカラー: #FF2D55 に統一 (旧 #FA2D48)
- [x] 非選択状態: グレー系 (#8E8E93)
- [x] 背景: ダークグレー基調
- [x] 赤は操作可能・現在状態のみで使用
- [x] ダークモード対応

### AppBar / ナビゲーションバー (仕様 12.2)
- [x] elevation: 0 (フラットデザイン)
- [x] 背景色: 画面背景と同一
- [x] titleTextStyle: セミボールド (FontWeight.w500)
- [x] アイコン配置: 未選択グレー、アクティブ時 #FF2D55

### BottomNavigationBar / タブバー (仕様 12.3)
- [x] 選択中: #FF2D55
- [x] 未選択: グレー
- [x] アニメーション: フェードまたは軽いスケール変化のみ
- [x] 常時表示: ✓

### Slider配色 (仕様 12.5)
- [x] 進行済み部分: #FF2D55
- [x] 未再生部分: 薄いグレー
- [x] つまみ: 白 / 操作中は #FF2D55 縁取り

### ミニプレイヤー (仕様 12.4)
- [x] 左: ジャケット（角丸）
- [x] 中央: 曲名／アーティスト（1行省略）
- [x] 右: 再生／停止ボタン
- [x] タップでフルプレイヤーへ遷移
- [x] 半透明 or サーフェスカラー背景

### 再生画面 (仕様 5)
- [x] アルバムジャケット（中央）
- [x] 曲名
- [x] アーティスト名
- [x] 再生位置スライダー
- [x] 再生／停止
- [x] 前へ／次へ
- [x] シャッフル
- [x] リピート（オフ → 全曲 → 1曲）
- [x] 楽曲単位の音量オフセット調整
- [x] 歌詞表示（時間同期スクロール）
- [x] AirPlay選択
- [x] 音質表示（ロスレス／空間オーディオ）
- [x] キュー表示

## ✅ 機能仕様

### タブバー (仕様 3, 4)
- [x] ライブラリタブ: プレイリスト、アーティスト、アルバム、曲、ダウンロード済み
- [x] 検索タブ: 曲名、アーティスト、アルバム、プレイリスト、歌詞検索
- [x] 設定タブ: 全設定項目

### ライブラリ機能 (仕様 4.1)
- [x] プレイリスト作成・編集
- [x] ドラッグによる並び替え
- [x] スワイプ削除
- [x] 並び替え機能

### コンテキストメニュー (仕様 10)
- [x] 再生
- [x] 次に再生
- [x] 後で再生
- [x] プレイリストに追加
- [x] ライブラリに追加／削除
- [x] ダウンロード／削除
- [x] 曲を共有
- [x] メタデータ編集
- [x] 音量オフセット設定

### 設定画面 (仕様 11)

#### 11.1 音声取得・変換設定
- [x] YouTube 音声取得 ON / OFF
- [x] 出力形式（MP3 / M4A）
- [x] ビットレート設定
- [x] サンプリングレート設定
- [x] メタデータ自動付与設定

#### 11.2 ローカルファイル読み込み設定
- [x] 対応フォーマット管理
- [x] 自動スキャン ON / OFF
- [x] 重複検出ポリシー設定
- [x] LRC 自動紐付け ON / OFF

#### 11.3 歌詞（LRC）表示設定
- [x] 歌詞表示 ON / OFF
- [x] 同期オフセット微調整
- [x] 表示行数設定
- [x] フォントサイズ・強調表示設定

### 歌詞表示機能 (仕様 6)
- [x] 時間同期型スクロール
- [x] 現在行を強調表示
- [x] 行タップで再生位置ジャンプ

## ✅ 技術仕様

### アーキテクチャ
- [x] Clean Architecture + MVVM
- [x] Riverpod 状態管理
- [x] Null Safety 対応

### ファイル構成 (設計要件)
- [x] lib/core/ - 定数、エラーハンドリング
- [x] lib/domain/ - エンティティ、ユースケース
- [x] lib/data/ - リポジトリ、モデル
- [x] lib/presentation/ - ViewModel、UI
- [x] lib/platform/ - プラットフォーム依存

### ViewModel集約
- [x] PlayerViewModel
- [x] LibraryViewModel
- [x] SettingsViewModel
- [x] すべて viewmodels.dart に統合

### UseCase集約
- [x] PlayerUseCase
- [x] LibraryUseCase
- [x] usecases.dart に統合

### Repository集約
- [x] IMusicRepository
- [x] ILocalSettingsRepository
- [x] repositories.dart に統合

### プラットフォーム分離
- [x] ARM64 最適化実装
- [x] x86/x64 互換実装
- [x] 実行時判定 (arch_selector)

### ドキュメンテーション
- [x] 各ファイルに役割コメント
- [x] クラス・メソッドレベルのコメント
- [x] cite タグで仕様参照

## ✅ 追加実装

### リピート機能
- [x] RepeatMode enum (off, all, one)
- [x] toggleRepeat() メソッド
- [x] UI反映：色とアイコン動的変更

### キュー表示画面
- [x] _QueueScreen クラス新規追加
- [x] ReorderableListView 実装
- [x] ドラッグ並び替え対応

## ⚠️ ネイティブ機能（別途対応必要）

- [ ] Siri・Googleアシスタント連携
- [ ] ロック画面操作
- [ ] コントロールセンター操作
- [ ] CarPlay 対応
- [ ] iOS/Android 設定連動

## 📝 ファイル一覧

| ファイル | 行数 | 説明 |
|---------|------|------|
| main.dart | 965 | メインアプリ、UI画面 |
| presentation/viewmodels.dart | 163 | ViewModel、Riverpod Provider |
| domain/usecases.dart | 35 | ユースケース実装 |
| domain/entities.dart | 40 | ドメインエンティティ |
| data/repositories.dart | 115 | リポジトリ実装 |
| core/app_constants.dart | 10 | アプリ定数 |
| core/failure.dart | 10 | エラーハンドリング |
| platform/arch_selector.dart | 20 | アーキテクチャ判定 |
| platform/native_audio_interface.dart | 15 | インターフェース |
| platform/arm64_audio_service.dart | 15 | ARM64実装 |
| platform/x86_audio_service.dart | 15 | x86実装 |
| pubspec.yaml | 23 | プロジェクト設定 |

## 🚀 デプロイメント準備

```bash
# 依存関係インストール
flutter pub get

# コード生成（使用している場合）
flutter pub run build_runner build

# テスト実行
flutter test

# ビルド（ARM64実機向け）
flutter build apk --target-platform android-arm64
flutter build ios
```
