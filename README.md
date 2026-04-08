# kiro-engineer-teams

Kiro CLI × zellij で8エージェントを並列起動し、issue→実装→レビュー→マージ→検証を全自動化するテンプレート。

## クイックスタート

```bash
# 1. テンプレートからプロジェクト作成
git clone https://github.com/yoshimi-I/kiro-engineer-teams.git my-app
cd my-app

# 2. 自分のリポジトリに切り替え
git remote set-url origin <your-repo-url>
git push -u origin main

# 3. Kiro CLI を起動（ブレストが自動で始まる）
kiro-cli chat
```

Kiroが起動すると自動でブレインストーミングが始まります。
作りたいアプリの概要を伝えてください。

設計が固まると：
- 技術スタック・規約が `.kiro/steering/development-rules.md` に書き込まれる
- GitHub issueが自動作成される
- `/quit` で抜けた後 `./scripts/start-pipeline.sh` でパイプライン起動

## パイプライン起動

```bash
./scripts/start-pipeline.sh
```

zellijが8分割で起動し、各エージェントがissue/PRの発生を待機→検出次第動き始めます。

```
┌──────────────┬──────────────┐
│ 🔨 Impl-1    │ 🚦 Fix-CI    │
│ issue→実装→PR │ CI失敗→修正  │
├──────────────┼──────────────┤
│ 🔨 Impl-2    │ 👀 Watch-Main│
│ issue→実装→PR │ main監視→E2E │
├──────────────┼──────────────┤
│ 🔍 Review    │ 🧪 E2E-Hunt  │
│ PR→レビュー   │ Playwright巡回│
├──────────────┼──────────────┤
│ 🔧 Fix-Review│ 📦 Dependabot│
│ 指摘→修正    │ 依存更新→処理 │
└──────────────┴──────────────┘
```

## 前提条件

- [Kiro CLI](https://kiro.dev/docs/cli/) がインストール済み
- [zellij](https://zellij.dev/) がインストール済み
- [GitHub CLI](https://cli.github.com/) が認証済み (`gh auth login`)
- git remote が設定済み

## ディレクトリ構成

```
.kiro/
├── steering/development-rules.md  # ルール（毎ターン自動適用）
├── skills/                        # リファレンス（エージェントが必要時に参照）
│   ├── clean-ddd-hexagonal/       # DDD + Clean Architecture
│   ├── frontend-design/           # UI設計ガイド
│   ├── baseline-ui/               # Tailwind制約
│   ├── fixing-accessibility/      # アクセシビリティ
│   ├── fixing-metadata/           # SEO/OGP
│   └── fixing-motion-performance/ # アニメーション性能
├── prompts/                       # ワークフロー（/name で呼び出し）
│   ├── implement.md               # issue→実装→PRループ
│   ├── review.md                  # 7視点厳格レビュー
│   ├── fix-review-issues.md       # レビュー指摘修正
│   ├── fix-ci.md                  # CI失敗修正
│   ├── watch-main.md              # main監視→E2E検証
│   ├── e2e-bug-hunt.md            # Playwright巡回
│   ├── auto-dependabot.md         # 依存更新処理
│   ├── 8-agent-pipeline.md        # パイプライン構成ガイド
│   └── ...                        # brainstorming, pr, create-issue 等
└── agents/default.json            # エージェント設定
scripts/
├── start-pipeline.sh              # パイプライン起動（ブレスト→zellij）
├── agent.sh                       # エージェントラッパー（ループ実行）
└── pipeline.kdl                   # zellijレイアウト
```

## steering / skills / prompts の違い

| | steering | skills | prompts |
|---|---------|--------|---------|
| ロード | 毎ターン全文 | メタデータのみ（必要時にフル読み込み） | `/name` で全文送信 |
| 確実性 | 100% | エージェント判断 | 100%（呼び出し時） |
| 用途 | ルール・規約 | リファレンス知識 | タスクの手順書 |

## カスタマイズ

```bash
# 不要なスキルを削除
rm -rf .kiro/skills/clean-ddd-hexagonal  # バックエンドなし

# 不要なプロンプトを削除
rm .kiro/prompts/auto-dependabot.md      # Dependabot未使用

# スキルを追加
mkdir .kiro/skills/my-guide
# SKILL.md を作成（name + description のfrontmatter必須）

# プロンプトを追加
# .kiro/prompts/my-workflow.md を作成
```

## GitLab を使う場合

```bash
just to-gitlab   # gh CLI → glab CLI に一括変換
just to-github   # 元に戻す
```

## ライセンス

MIT
