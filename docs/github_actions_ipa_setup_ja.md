# GitHub Actionsで未署名IPAをビルドする手順（AltStore向け）

## 1. 追加済みファイル
- `.github/workflows/ios-build.yml`

## 2. 前提
- Windows環境でAltStoreを使って個人インストールする
- App Store公開は行わない
- Apple Developer有料登録は不要（無料Apple IDで可）

## 3. GitHub Secrets
このワークフローでは **Secretsは不要** です。

## 4. ビルド内容
ワークフローは以下を実行します。

- `flutter pub get`
- `cd ios && pod install`
- `flutter build ipa --release --no-codesign`
- 生成したIPAをArtifactsへアップロード

## 5. 実行方法
- GitHub の `Actions` タブから `Build iOS IPA (Unsigned)` を選択
- `Run workflow` を実行
- 成功後、Artifacts の `ios-ipa` から `.ipa` を取得

## 6. AltStoreでの利用
1. Windowsに AltServer / AltStore をインストール
2. iPhoneにAltStoreを導入
3. 取得した `.ipa` をAltStoreから読み込み
4. AltStore側でApple ID署名してインストール

## 7. よくあるエラー
- CocoaPods関連エラー: `ios/Podfile` や依存関係の不整合を確認
- ビルド失敗: Flutter SDKバージョン差分を確認
- AltStoreインストール失敗: Apple IDログイン状態、端末接続状態を確認
