---
name: backend-integration
description: |
  バックエンド連携・外部サービス（AdMob、Firebase など）との接続方針。
---

要点:
- API キーや広告ユニット ID はソースに直書きせず、環境別に分ける（Android/iOS の場合はネイティブ側の設定へ移譲）。
- 広告（AdMob）はユーザーのプライバシーに配慮し、必要ならユーザーに選択肢を提示する。
- ネットワークエラーやタイムアウトは gracefully に処理し、ユーザー向けエラーメッセージは `AppLocalizations` を使用する。
---
name: backend-integration
description: |
  バックエンド連携・外部サービス（AdMob、Firebase など）との接続方針。
---

要点:
- API キーや広告ユニット ID はソースに直書きせず、環境別に分ける（Android/iOS の場合はネイティブ側の設定へ移譲）。
- 広告（AdMob）はユーザーのプライバシーに配慮し、必要ならユーザーに選択肢を提示する。
- ネットワークエラーやタイムアウトは gracefully に処理し、ユーザー向けエラーメッセージは `AppLocalizations` を使用する。
