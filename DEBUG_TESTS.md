# Debug Test List

環境準備
- Flutter とデバイス（例: `CB512BYR8J`）が接続されていること
- 依存取得:
```bash
flutter pub get
```

サンプルファイル（テスト対象）
- C:\Users\pomyu\Documents\appmaker\apple music\flutter_application_4\蝶々結び.m4a
- C:\Users\pomyu\Documents\appmaker\apple music\flutter_application_4\蝶々結び.mp3
- C:\Users\pomyu\Documents\appmaker\apple music\flutter_application_4\三原色.m4a

実行コマンド
```bash
flutter run -d CB512BYR8J
```
またはログ収集用に
```bash
adb logcat -s flutter ActivityManager | grep "Flutter" -n
# または
flutter logs
```

テストケース

1) タイトル／アーティストの文字化け確認（M4A）
- 手順:
  1. アプリを起動する
  2. 設定 > ファイルのインポート で `三原色.m4a` をインポート
- 期待値:
  - コンソールに表示される `[Library] メタデータ取得:` の `タイトル:` が `三原色` と表示される
  - `アーティスト:` が `YOASOBI`（またはファイルに埋め込まれている正しいアーティスト名）となる
- ログ確認パターン:
  - `I/flutter: [Library] メタデータ取得:` の直後の `タイトル:` 行と `アーティスト:` 行
→NG
2) タイトル／アーティストの文字化け確認（MP3）
- 手順:
  1. 同様に `蝶々結び.mp3` をインポート
- 期待値:
  - `TIT2`, `TPE1`, `TALB` の値がそれぞれ UI とログに正しく表示される
- ログ確認パターン: 上と同様
→NG
3) サムネイル（カバー画像）の抽出確認
- 手順:
  1. ファイルをインポート
  2. インポート後、音声ファイルと同じフォルダに `<basename>_cover.jpg` が生成されていることを確認
  3. ライブラリ画面／ミニプレイヤーでジャケットが表示されることを確認
- 期待値:
  - `三原色_cover.jpg` 等のファイルが存在する
  - UI に画像が表示される（ローカル画像は `Image.file` で表示される）
- チェックコマンド:
```bash
# デバイス上のファイル一覧（実行環境に合わせてパスを変更）
adb shell ls /data/user/0/com.example.flutter_application_4/app_flutter/Music
```
→OK（三原色.m4aのみ失敗）
4) 再生（just_audio）の動作確認
- 手順:
  1. ライブラリで曲をタップして再生
  2. ミニプレイヤーの再生/一時停止ボタンを操作
- 期待値:
  - 音が再生される
  - コンソールに `ExoPlayer` や `just_audio` 関連の初期化ログが出る
  - ミニプレイヤーの再生アイコンが切り替わる
- ログ確認キーワード: `ExoPlayerImpl`, `just_audio`, `[Player]`（デバッグ出力がある場合）
W/AudioTrack(31709): getTimestamp() location moved from kernel to server
5) 再生時間（Duration）精度確認
- 手順:
  1. ファイルをインポートしてライブラリに表示される再生時間を確認
  2. 曲を再生し、フル再生時間と UI 表示時間を比較
- 期待値:
  - UI の再生時間が実際の再生時間（フル再生）と大きくずれない（±5秒を目安）
- 補助: もしひどく異なる場合、`_estimateDuration` のビットレート推定ロジックの改善（より多くのヘッダ解析）を行う
→NG（BGM ユカリ戦.m4aの実際の再生時間3:43、表示された再生時間1:52その後エラー画面が表示される）
6) 追加ログ取得と報告方法
- 実行後、端末のコンソール出力（`flutter run` のログ）を丸ごとコピーしてアシスタントへ貼ってください。
- 重要なログブロック:
  - `[Library] メタデータ取得:` の出力全体
  - `ExoPlayer` / `just_audio` 初期化やエラー
  - `ファイルコピー成功` の前後ログ

備考
- 現状の問題点(ログより):
  - M4A のメタデータ抽出でジャケットデータや `data` 部分が誤って文字列として混入しているため、パーサの検索範囲や `data` atom の読み取り位置を限定する必要があります。
  - まずは上記テストを実行して、各ケースごとのログを収集してください。

--
このファイルを実行して得られたログを送ってください。次にログを解析し、文字化けと長さ・ジャケット抽出の修正方針を適用します。
