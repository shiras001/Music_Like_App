---
name: copilot-instructions
description: |
  このリポジトリの Copilot / Chat の基本動作指示。
  スキルファイル（`.github/skills/*/SKILL.md`）を参照して、関連タスク実行時に追加コンテキストを参照してください。
---

前提:
- 回答は必ず日本語で行うこと。
- 大きな変更（200行を超える可能性がある場合）は事前にユーザーへ確認を取ること。

ルール:
- 変更を加える際は、可能な限り小さな差分で行う。
- 1ファイルが500行を超える場合は分割する。
- スキル関連の参考は `.github/skills` 下の各 `SKILL.md` を参照すること。

参照スキルの場所:
- .github/skills/architecture/SKILL.md
- .github/skills/ui-design/SKILL.md
- .github/skills/state-management/SKILL.md
- .github/skills/backend-integration/SKILL.md
- .github/skills/coding-standards/SKILL.md
- .github/skills/testing/SKILL.md

作業報告:
- 変更が完了したら `作業進捗（三桁の連番）.md` に計画と完了/対応中/未実施の項目を追記すること。
