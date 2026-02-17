---
name: state-management
description: |
  状態管理に関する方針。Riverpod をメインに使用する本プロジェクト向けの指針。
---

要点:
- Provider/StateNotifier/ChangeNotifier の使い分けを明確にする。
- ViewModel は UI とビジネスロジックの境界であり、I/O はリポジトリ経由で行う。
- グローバル状態は最小限にし、テストしやすい設計を心がける。

テスト:
- ViewModel の単体テストで副作用をモックする。
---
name: state-management
description: |
  状態管理に関する方針。Riverpod をメインに使用する本プロジェクト向けの指針。
---

要点:
- Provider/StateNotifier/ChangeNotifier の使い分けを明確にする。
- ViewModel は UI とビジネスロジックの境界であり、I/O はリポジトリ経由で行う。
- グローバル状態は最小限にし、テストしやすい設計を心がける。

テスト:
- ViewModel の単体テストで副作用をモックする。
