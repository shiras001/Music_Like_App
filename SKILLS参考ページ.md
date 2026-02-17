【最新版】GitHub Copilotを使っている人は全員"SKILL.md"も導入してください
AI
SKILLS
GitHubCopilot
copilot-instructions.md
最終更新日 2026年02月12日
投稿日 2026年02月12日
はじめに
本記事はGitHub Copilotを使っている人は全員"copilot-instructions.md"を作成してくださいの続編になります。

本記事ではカスタムインストラクション(あるいはコンテキストファイル)にcopilot-instructions.mdを使用していますが、AGENTS.mdでも大きく動作は変わりません。

GitHub Copilotを使っている開発者の皆さん、.github/copilot-instructions.mdというファイルを作成していますか？
そして、SKILL.mdというファイルも作成していますか？

2025年10月、GitHub Copilotを使っている人は全員"copilot-instructions.md"を作成してくださいという記事を投稿させていただきました、TooMeです。
あれから3ヶ月以上が経ち、github copilotにもアップデートがいくつか入りました。
中でも大きいのが、2025年12月のversion 1.108でのAgent Skillsへの対応です。

リリースノート：https://code.visualstudio.com/updates/v1_108

本記事では、このAgent Skillsを利用することによって以前の記事のやり方よりもさらにgithub copilotを強力に活用する方法を紹介します。

以前のやり方での弱点
以前の記事では、copilot-instructions.md1つにたくさんの情報を与えていました。そのため、推論に使用するモデルの性能が低かったり、1回のセッションで会話が長続きすると、最初の方に言っていたことや、そもそもcopilot-instructions.mdで定義していることを忘れてしまうことがありました。
また、与えたたくさんのコンテキストがノイズとなり、推論に時間がかかったり、的外れな回答をすることもありました。

Agent Skills とは
エージェント スキルは、Copilot が関連する場合に読み込むことができる命令、スクリプト、およびリソースのフォルダーであり、特殊なタスクのパフォーマンスを向上させます。 エージェント スキルは、さまざまなエージェントで使用される オープン標準です。

エージェントスキルについて - GitHub ドキュメント

スキルという名前から、何かしらツールを使う能力であったり、ツール自体を定義するようのものにも聞こえますが、実態はプロジェクトのドメイン知識等を入れるのが最も一般的な使い方です。
実際に、どのような使われ方なのかを紹介します。
以下がSKILL.mdの1つです。

例: テスト戦略のSKILL.md (クリックで展開)
これ、以前の記事のcopilot-instructions.md例1: ReactでのWebアプリの「テスト戦略」のセクションを抜粋して一部AIに捕捉させたものです。

mdファイルの先頭には、特徴的なパーテーションがあり、そこでnameやdescriptionが設定されています。
軽くですが、これらのパラーメータについて説明します。

パラメーター名	内容
name	SKILL.mdがあるディレクトリの名前。ディレクトリ構成については後述する
description	スキルの機能と使用タイミングを説明する
github copilotは各SKILL.mdを、必要に応じて読み込み、タスクを実行します。その必要に応じてというのを、descriptoinで定義するイメージです。

さきほどの例では、以下のようにdescriptionを定義していました。

TooMe's Task App (Web)のテスト戦略。Vitest、React Testing Library、MSWを使用した単体・コンポーネントテストについて説明。テスト作成時に参照。

そのため、テスト関連のタスク実行時にこのSKILL.mdを読みます。これにより、大きなcopilot-instructions.mdから、テスト戦略に関連するコンテキストを分離することができました。しかも、この分離したコンテキストは必要に応じてのみ読まれます。

SKILL.mdの作り方、使い方
1. vsodeの設定でchat.useAgentSkillsを有効にする
スクリーンショット 2026-02-11 1.44.15.png

今後のvscodeのアップデート次第では、この項目はデフォルトでtrueになったり、そもそも項目自体が無くなる可能性もあるかもです。

2. 以下のようなディレクトリ構成で各SKILL.mdを定義する
これでgithub copilotが必要に応じて必要なSKILL.mdを参照してくれます。
もちろん、ここで定義しているディレクトリは例なので、プロジェクトによっていくらでも新しくディレクトリを作成し、その中にSKILL.mdを作成して大丈夫です。

.github
│── skills
│   ├── architecture
│   │   └── SKILL.md
│   ├── ui-design
│   │   └── SKILL.md
│   ├── state-managment
│   │   └── SKILL.md
│   ├── backend-integration
│   │   └── SKILL.md
│   ├── coding-standards
│   │   └── SKILL.md
│   └── testing
│       └── SKILL.md
└── copilot-instructions.md
Tip 実は上記のような構成にしなくても、vscodeのchat.agentSkillsLocationsを設定すれば、好きなディレクトリ構成にすることも可能です。

これにより、copilot-instructins.mdはとてもスッキリとします。

# Copilot Instructions for TooMe's Task App (Web)

## 前提条件

- **回答は必ず日本語でしてください。**
- コードの変更をする際、変更量が200行を超える可能性が高い場合は、事前に「この指示では変更量が200行を超える可能性がありますが、実行しますか?」とユーザーに確認をとるようにしてください。
- 何か大きい変更を加える場合、まず何をするのか計画を立てた上で、ユーザーに「このような計画で進めようと思います。」と提案してください。

## 参照スキルガイド (Skills)

特定のタスクを実行する際は、必ず以下の対応するドキュメントを参照し、その指針に従ってください。

- **アーキテクチャ・ディレクトリ構成**
  - ファイル配置、モジュール構成、機能の分離
  - 📄 `.github/skills/architecture/SKILL.md`

- **UI 実装・スタイリング**
  - Tailwind CSS、コンポーネント設計、アクセシビリティ (a11y)
  - 📄 `.github/skills/ui-design/SKILL.md`

- **状態管理・データフェッチ**
  - Zustand (グローバル)、React Query (サーバー)、React Hook Form
  - 📄 `.github/skills/state-management/SKILL.md`

- **バックエンド連携・認証**
  - Firebase Authentication、Google Calendar API、通知機能
  - 📄 `.github/skills/backend-integration/SKILL.md`

- **コーディング規約**
  - TypeScript/React のベストプラクティス、命名規則、アンチパターン
  - 📄 `.github/skills/coding-standards/SKILL.md`

- **テスト戦略**
  - Vitest、React Testing Library、MSW、E2E
  - 📄 `.github/skills/testing/SKILL.md`

## プロジェクト概要

**TooMe's Task App (Web)** は、タスク管理とスケジュール管理を統合したWebアプリケーションです。

### 技術スタック概要

| カテゴリ | 技術 |
| --- | --- |
| **Frontend** | React 18, TypeScript 5, Vite 5 |
| **Styling** | Tailwind CSS, Radix UI |
| **State** | Zustand, TanStack Query (React Query) |
| **Backend** | Firebase (Auth, Firestore, Functions, Hosting) |
| **Integration** | Google Calendar API, Web Push API |
| **Testing** | Vitest, React Testing Library, MSW |

### ディレクトリ構成概略

```
src/
├── app/        # エントリーポイント
├── features/   # 機能別モジュール (task, calendar, auth...)
├── shared/     # 共通モジュール (ui, hooks, utils...)
├── lib/        # 外部設定 (firebase, google...)
└── styles/     # グローバルスタイル
```
Tipsこのタスクをする時は、このSKILL.mdを参照して。という情報は無くてもいいです。よりコンテキストファイルを短くしたい場合は消してもらっても大丈夫です。
自分の場合は、まだskillsに対応して間もないため怖いので書いてるだけです。