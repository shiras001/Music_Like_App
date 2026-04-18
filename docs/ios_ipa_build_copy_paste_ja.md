# iOS IPAビルド手順（コピペ用）

この手順は、GitHub Actions で未署名の iOS IPA を作成し、AltStore で iPhone に入れるための手順です。

変更が必要な場所は、すべて `[ ]` で囲んであります。実行前に置き換えてください。

## 0. 前提

- ビルドはローカル Linux ではなく、GitHub Actions 上で実行します。
- このリポジトリでは iOS の未署名ビルドを `ipa-build-temp` ブランチへの push で起動します。
- 成果物は GitHub Actions の artifact として取得します。

## 1. ビルド対象ブランチへ移動

```bash
git switch [ipa-build-temp]
git status --short --branch
```

## 2. 必要な変更を入れる

必要なファイルを編集したあと、差分を確認してコミットします。

```bash
git add [変更したファイル1] [変更したファイル2] [変更したファイル3]
git commit -m "[commit message]"
git push origin [ipa-build-temp]
```

## 3. GitHub Actions の実行 ID を確認

push 後にワークフローが起動したら、最新の実行 ID を取得します。

```bash
gh run list --branch [ipa-build-temp] --limit 1
gh run list --branch [ipa-build-temp] --limit 1 --json databaseId --jq '.[0].databaseId'
```

## 4. ビルド完了まで待つ

```bash
gh run watch [run_id] --exit-status
```

補足:
- `[run_id]` は 3 で取得した数字に置き換えます。
- 途中で画面表示が崩れる場合は、次のコマンドで状態だけ確認できます。

```bash
gh api repos/[owner]/[repo]/actions/runs/[run_id] --jq '.status+" "+(.conclusion//"")'
```

## 5. IPA をダウンロード

```bash
gh run download [run_id] -n [ios-ipa] -D [ipa-artifact-folder]
ls -lh [ipa-artifact-folder]/Runner.ipa
```

例:

```bash
gh run download 24573852772 -n ios-ipa -D ipa-artifact-build3
ls -lh ipa-artifact-build3/Runner.ipa
```

## 6. IPA の中身を確認

アプリ名、Bundle ID、ビルド番号を確認します。

```bash
unzip -p [ipa-artifact-folder]/Runner.ipa Payload/Runner.app/Info.plist | strings | grep -E "MUSIC LIKE|CFBundleDisplayName|CFBundleName|CFBundleVersion|CFBundleIdentifier|com.musiclike.app"
```

Google Mobile Ads の痕跡が残っていないかも確認します。

```bash
unzip -p [ipa-artifact-folder]/Runner.ipa Payload/Runner.app/Runner | strings | grep -Ei "GADApplicationVerifyPublisherInitializedCorrectly|google_mobile_ads|GoogleMobileAds|ca-app-pub|GADApplicationIdentifier" || true
```

## 7. AltStore で iPhone に入れる

1. iPhone から古いアプリを削除します。
2. AltStore を開きます。
3. `Runner.ipa` を選択してインストールします。
4. 初回起動時に「MUSIC LIKE」と表示されるか確認します。

## 8. 起動確認チェックリスト

- アプリ名が `MUSIC LIKE` になっている
- 起動直後にホーム画面へ戻らない
- 再生画面が開く
- 設定画面が開く

## 9. うまくいかないとき

- 古い IPA を入れていないか確認します。
- iPhone 上の旧アプリを削除してから入れ直します。
- build number と Bundle ID を変えて、別アプリとして再インストールします。
- それでも落ちる場合は、iPhone のクラッシュログ `.ips` を取得して再解析します。

## 10. よく使うコマンドまとめ

```bash
git switch [ipa-build-temp]
git add [files]
git commit -m "[message]"
git push origin [ipa-build-temp]
gh run list --branch [ipa-build-temp] --limit 1 --json databaseId --jq '.[0].databaseId'
gh run watch [run_id] --exit-status
gh run download [run_id] -n [ios-ipa] -D [ipa-artifact-folder]
```