# kiro-engineer-teams

> 8-agent parallel development pipeline powered by Kiro CLI × zellij
>
> Kiro CLI × zellij で8エージェント並列開発パイプライン

Automate the full cycle: issue → implementation → review → merge → E2E verification.

issue → 実装 → レビュー → マージ → E2E検証を全自動化。

## Quick Start / クイックスタート

```bash
# Clone the template / テンプレートをクローン
git clone https://github.com/yoshimi-I/kiro-engineer-teams.git my-app
cd my-app

# Point to your own repo / 自分のリポジトリに切り替え
git remote set-url origin <your-repo-url>
git push -u origin main

# Start Kiro CLI (brainstorming begins automatically)
# Kiro CLIを起動（ブレストが自動で始まる）
kiro-cli chat
```

Kiro reads `AGENTS.md` on startup and begins brainstorming. Tell it what you want to build.

Kiro起動時に `AGENTS.md` を読み、ブレストが始まります。作りたいものを伝えてください。

After design is finalized:
設計が固まると：

- Tech stack and conventions are written to `.kiro/steering/development-rules.md`
  技術スタック・規約が steering に書き込まれる
- GitHub issues are created automatically
  GitHub issueが自動作成される
- Run the pipeline after exiting Kiro
  Kiroを抜けた後パイプラインを起動

## Launch Pipeline / パイプライン起動

```bash
./scripts/start-pipeline.sh
```

zellij opens with 8 panes. Each agent waits for work and starts automatically when issues/PRs appear.

zellijが8分割で起動。各エージェントはissue/PRの発生を待機し、検出次第動き始めます。

```
┌──────────────┬──────────────┐
│ 🔨 Impl-1    │ 🚦 Fix-CI    │
│ issue→impl→PR│ CI failure fix│
├──────────────┼──────────────┤
│ 🔨 Impl-2    │ 👀 Watch-Main│
│ issue→impl→PR│ main→E2E test │
├──────────────┼──────────────┤
│ 🔍 Review    │ 🧪 E2E-Hunt  │
│ PR→review    │ Playwright    │
├──────────────┼──────────────┤
│ 🔧 Fix-Review│ 📦 Dependabot│
│ fix comments │ dep updates   │
└──────────────┴──────────────┘
```

## Prerequisites / 前提条件

- [Kiro CLI](https://kiro.dev/docs/cli/)
- [zellij](https://zellij.dev/)
- [GitHub CLI](https://cli.github.com/) — authenticated (`gh auth login`)
- git remote configured / git remoteが設定済み

## Architecture / アーキテクチャ

```
GitHub Issue
    │
    ▼
Agent 1,2: /implement ──→ PR
                           │
                           ▼
                     Agent 3: /review
                           │
                      ┌────┴────┐
                   🟢 LGTM   🔴 Fix needed
                      │         │
                      ▼         ▼
                 merge    Agent 4: /fix-review-issues
                      │
                      ▼
                 Agent 5: /fix-ci (if CI fails)
                      │
                      ▼
                 main merged
                      │
                      ▼
                 Agent 6: /watch-main (E2E verification)
                      │
                 Bug found? → issue → Agent 1,2 picks it up
                                ▲
                                │
                 Agent 7: /e2e-bug-hunt (Playwright patrol)

Agent 8: /auto-dependabot (dependency updates, separate lane)
```

All agents share `issue/task.md` for coordination to avoid conflicts.

全エージェントは `issue/task.md` を共有して競合を回避します。

## Directory Structure / ディレクトリ構成

```
.kiro/
├── steering/development-rules.md  # Rules (loaded every turn / 毎ターン自動適用)
├── skills/                        # Reference (on-demand / 必要時に参照)
│   ├── clean-ddd-hexagonal/       # DDD + Clean Architecture
│   ├── frontend-design/           # UI design guide
│   ├── baseline-ui/               # Tailwind constraints
│   ├── fixing-accessibility/      # Accessibility checklist
│   ├── fixing-metadata/           # SEO/OGP checklist
│   └── fixing-motion-performance/ # Animation performance
├── prompts/                       # Workflows (invoke with /name)
│   ├── implement.md               # issue→impl→PR loop
│   ├── review.md                  # 7-point strict review
│   ├── fix-review-issues.md       # Fix review comments
│   ├── fix-ci.md                  # Fix CI failures
│   ├── watch-main.md              # Monitor main→E2E
│   ├── e2e-bug-hunt.md            # Playwright patrol
│   ├── auto-dependabot.md         # Dependency PR handling
│   ├── 8-agent-pipeline.md        # Pipeline guide
│   └── ...                        # brainstorming, pr, create-issue, etc.
└── agents/default.json            # Agent config
scripts/
├── start-pipeline.sh              # Launcher (brainstorm→zellij)
├── agent.sh                       # Agent wrapper (loop runner)
└── pipeline.kdl                   # zellij layout
```

## Steering / Skills / Prompts

| | Steering | Skills | Prompts |
|---|---------|--------|---------|
| Loading | Full text every turn | Metadata only (full on demand) | Full text on `/name` invoke |
| Certainty | 100% | Agent decides | 100% (when invoked) |
| Use for | Rules, conventions | Reference knowledge | Task workflows |

## Customization / カスタマイズ

```bash
# Remove unused skills / 不要なスキルを削除
rm -rf .kiro/skills/clean-ddd-hexagonal

# Remove unused prompts / 不要なプロンプトを削除
rm .kiro/prompts/auto-dependabot.md

# Add a skill / スキルを追加
mkdir .kiro/skills/my-guide
# Create SKILL.md with name + description frontmatter

# Add a prompt / プロンプトを追加
# Create .kiro/prompts/my-workflow.md
```

## For GitLab / GitLabの場合

```bash
just to-gitlab   # gh CLI → glab CLI
just to-github   # revert
```

## License / ライセンス

[MIT](LICENSE)
