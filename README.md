<div align="center">

# 🏭 kiro-engineer-teams

**8-agent parallel development pipeline**
**powered by [Kiro CLI](https://kiro.dev/docs/cli/) × [zellij](https://zellij.dev/)**

issue → implementation → review → merge → E2E verification — fully automated.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Kiro CLI](https://img.shields.io/badge/Kiro_CLI-compatible-purple.svg)](https://kiro.dev/docs/cli/)

[English](#quick-start) · [日本語](#クイックスタート)

</div>

---

## Quick Start

```bash
# Clone the template
git clone https://github.com/yoshimi-I/kiro-engineer-teams.git my-app
cd my-app

# Point to your own repo
git remote set-url origin <your-repo-url>
git push -u origin main

# Start Kiro CLI — brainstorming begins automatically
kiro-cli chat
```

> 💡 Kiro reads `AGENTS.md` on startup and begins brainstorming.
> Tell it what you want to build. After design is finalized, issues are created automatically.
> Exit Kiro, then run the pipeline.

## クイックスタート

```bash
git clone https://github.com/yoshimi-I/kiro-engineer-teams.git my-app
cd my-app
git remote set-url origin <your-repo-url>
git push -u origin main
kiro-cli chat   # ブレストが自動で始まる
```

> 💡 Kiro起動時にブレストが始まります。作りたいものを伝え、設計→issue作成まで完了したら
> `/quit` で抜けてパイプラインを起動してください。

---

## 🚀 Launch Pipeline / パイプライン起動

```bash
./scripts/start-pipeline.sh
```

<table>
<tr>
<td align="center">🔨<br><b>Impl-1</b><br><sub>issue → impl → PR</sub></td>
<td align="center">🚦<br><b>Fix-CI</b><br><sub>CI failure → fix</sub></td>
</tr>
<tr>
<td align="center">🔨<br><b>Impl-2</b><br><sub>issue → impl → PR</sub></td>
<td align="center">👀<br><b>Watch-Main</b><br><sub>main → E2E test</sub></td>
</tr>
<tr>
<td align="center">🔍<br><b>Review</b><br><sub>PR → review → merge</sub></td>
<td align="center">🧪<br><b>E2E-Hunt</b><br><sub>Playwright patrol</sub></td>
</tr>
<tr>
<td align="center">🔧<br><b>Fix-Review</b><br><sub>fix comments → push</sub></td>
<td align="center">📦<br><b>Dependabot</b><br><sub>dep updates</sub></td>
</tr>
</table>

Each agent waits for work and starts automatically when issues/PRs appear.

各エージェントはissue/PRの発生を待機し、検出次第動き始めます。

---

## 🏗️ Architecture / アーキテクチャ

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
                 Agent 7: /e2e-bug-hunt (Playwright patrol)

Agent 8: /auto-dependabot (dependency updates, separate lane)
```

> All agents share `issue/task.md` for coordination.
> 全エージェントは `issue/task.md` を共有して競合を回避します。

---

## 📋 Prerequisites / 前提条件

| Tool | Required |
|------|----------|
| [Kiro CLI](https://kiro.dev/docs/cli/) | ✅ |
| [zellij](https://zellij.dev/) | ✅ |
| [GitHub CLI](https://cli.github.com/) | ✅ authenticated (`gh auth login`) |
| git remote | ✅ configured |

---

## 📁 Directory Structure / ディレクトリ構成

```
.kiro/
├── 📜 steering/development-rules.md  # Rules (every turn / 毎ターン適用)
├── 📚 skills/                        # Reference (on-demand / 必要時参照)
│   ├── clean-ddd-hexagonal/          #   DDD + Clean Architecture
│   ├── frontend-design/              #   UI design guide
│   ├── baseline-ui/                  #   Tailwind constraints
│   ├── fixing-accessibility/         #   Accessibility
│   ├── fixing-metadata/              #   SEO/OGP
│   └── fixing-motion-performance/    #   Animation performance
├── ⚡ prompts/                       # Workflows (invoke with /name)
│   ├── implement.md                  #   issue → impl → PR loop
│   ├── review.md                     #   7-point strict review
│   ├── fix-review-issues.md          #   Fix review comments
│   ├── fix-ci.md                     #   Fix CI failures
│   ├── watch-main.md                 #   Monitor main → E2E
│   ├── e2e-bug-hunt.md               #   Playwright patrol
│   ├── auto-dependabot.md            #   Dependency PR handling
│   ├── 8-agent-pipeline.md           #   Pipeline guide
│   └── ...                           #   brainstorming, pr, etc.
└── 🤖 agents/default.json            # Agent config
scripts/
├── start-pipeline.sh                 # Launcher
├── agent.sh                          # Agent loop wrapper
└── pipeline.kdl                      # zellij layout
```

---

## 🔄 Steering / Skills / Prompts

| | 📜 Steering | 📚 Skills | ⚡ Prompts |
|---|:---:|:---:|:---:|
| **Loading** | Full text every turn | Metadata only → full on demand | Full text on `/name` |
| **Certainty** | 100% | Agent decides | 100% |
| **Use for** | Rules, conventions | Reference docs | Task workflows |

---

## 🔧 Customization / カスタマイズ

```bash
# Remove unused skills / 不要なスキルを削除
rm -rf .kiro/skills/clean-ddd-hexagonal

# Remove unused prompts / 不要なプロンプトを削除
rm .kiro/prompts/auto-dependabot.md

# Add your own / 追加
mkdir .kiro/skills/my-guide       # + SKILL.md with frontmatter
touch .kiro/prompts/my-workflow.md
```

**For GitLab / GitLabの場合:**
```bash
just to-gitlab   # gh → glab
just to-github   # revert
```

---

<div align="center">

## License / ライセンス

[MIT](LICENSE) © [yoshimi-I](https://github.com/yoshimi-I)

</div>
