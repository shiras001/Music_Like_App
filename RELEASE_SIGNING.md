# Release signing と AAB 生成手順

以下は Google Play にアップロードするための署名と AAB 生成の簡単な手順です。

1) キーストアを作成する

  下記のコマンドを実行して `android/keystore.jks` を生成します（`keytool` が必要です）。

  ```sh
  keytool -genkey -v -keystore android/keystore.jks -alias key0 -keyalg RSA -keysize 2048 -validity 9125
  ```

  実行中にパスワードや名前などを聞かれます。`key0` は `keyAlias` の例です。

2) `android/key.properties` を作成する

  既に `android/key.properties.template` があるので、それをコピーして `android/key.properties` とし、値を埋めてください。

  例 (`android/key.properties`):

  ```properties
  storePassword=（上で指定した keystore パスワード）
  keyPassword=（鍵のパスワード）
  keyAlias=key0
  storeFile=keystore.jks
  ```

  `storeFile` は `android/` フォルダからの相対パスです（例: `keystore.jks`）。

3) `.gitignore` の確認

  セキュリティのため、`android/key.properties` と keystore ファイルがコミットされないよう `.gitignore` に追加済みです。

4) (必要なら) Gradle の signingConfig を確認

  多くの Flutter テンプレートは `android/app/build.gradle`（または Kotlin DSL の場合 `build.gradle.kts`）で `signingConfigs` を参照する設定が入っています。既に設定されていれば何も変更は不要です。設定が無い場合は、Android Studio の「Generate Signed Bundle」で署名設定を追加するか、`build.gradle` に下記のような設定を追加してください。

  例（Groovy）:

  ```groovy
  def keystoreProperties = new Properties()
  keystoreProperties.load(new FileInputStream(rootProject.file('key.properties')))

  android {
    signingConfigs {
      release {
        storeFile file(keystoreProperties['storeFile'])
        storePassword keystoreProperties['storePassword']
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
      }
    }
    buildTypes {
      release {
        signingConfig signingConfigs.release
      }
    }
  }
  ```

5) AAB をビルドする

  `android/key.properties` と keystore が配置されていれば、下記コマンドで署名付き AAB を生成できます。

  ```sh
  flutter build appbundle --release
  ```

6) 注意点

  - キーストアのパスワードやファイルは厳重に管理してください。紛失するとアプリ更新ができなくなります。
  - `android/key.properties` と keystore ファイルはリポジトリにコミットしないでください（`.gitignore` に追加済み）。

必要なら私の方で `android/app/build.gradle.kts` の signingConfig 部分を挿入しておきます。keystore を用意できる場合、ファイルをワークスペースに追加していただければ署名付きビルドを作成します。
