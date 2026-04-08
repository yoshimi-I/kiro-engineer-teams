<div align="center">

# 🏭 kiro-engineer-teams

**8-agent parallel development pipeline**
**powered by [Kiro CLI](https://kiro.dev/docs/cli/) × [zellij](https://zellij.dev/)**

issue → implementation → review → merge → E2E verification — fully automated.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Kiro CLI](https://img.shields.io/badge/Kiro_CLI-compatible-purple.svg)](https://kiro.dev/docs/cli/)

**English** · [日本語](docs/README.ja.md)

</div>

---

## Quick Start

**1. Create project directory and clone template**
```bash
mkdir <your-project>
cd <your-project>
git clone https://github.com/yoshimi-I/kiro-engineer-teams.git .
```

**2. Install prerequisites**
```bash
./scripts/setup.sh
```

**3. Initialize as your own private repo**
```bash
just init
```

**4. Start (INCEPTION → 8-agent pipeline)**
```bash
just start
```

> 💡 You can also use GitHub's **"Use this template"** button to create a new repo directly.

---

## 🔄 Full Flow

```
./scripts/start-pipeline.sh
│
├── Phase 1: INCEPTION (you + AI)
│   ├── 1. Workspace Detection — scan existing code
│   ├── 2. Requirements Analysis — clarify what to build
│   ├── 3. User Stories — define user behavior (if needed)
│   ├── 4. Architecture Design — tech stack + structure (if needed)
│   └── 5. Issue Generation — auto-create GitHub issues
│
└── Phase 2: 8-Agent Pipeline (fully autonomous)
    ├── Impl-1, Impl-2 → pick issues → implement → PR
    ├── Review → strict 7-point review → merge
    ├── Fix-Review → fix review comments → re-push
    ├── Fix-CI → fix CI failures → re-push
    ├── Watch-Main → E2E verification after merge
    ├── E2E-Hunt → Playwright patrol → bug issues
    └── Dependabot → dependency update PRs
```

Phase 1 requires your input. Phase 2 is fully automated — agents wait for work and start when issues/PRs appear.

---

## 🚀 Launch Pipeline

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

---

## 🏗️ Architecture

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

> All agents share `issue/task.md` for coordination to avoid conflicts.

---

## 📋 Prerequisites

| Tool | Install | Required |
|------|---------|----------|
| [Kiro CLI](https://kiro.dev/docs/cli/) | See [downloads](https://kiro.dev/downloads/) | ✅ |
| [zellij](https://zellij.dev/) | `brew install zellij` | ✅ |
| [GitHub CLI](https://cli.github.com/) | `brew install gh` → `gh auth login` | ✅ |
| [just](https://just.systems/) | `brew install just` | Optional (for GitLab switch) |

> **Linux**: Replace `brew install` with your package manager or see each tool's install docs.
> **Windows**: Use WSL2 or see each tool's Windows install docs.

---

## 🛡️ Built-in Rules

The steering file (`.kiro/steering/development-rules.md`) enforces these rules on every agent, every turn:

| Category | Key Rules |
|----------|-----------|
| **TDD** | Red → Green → Refactor. No code without tests first. |
| **Testing** | 3-layer: Unit (per function) + Integration (per API) + E2E (per user flow) |
| **PR Gate** | Unit + Integration + E2E must pass. Missing tests = no merge. |
| **Error Handling** | Unified API error format. Actionable messages. Resource cleanup. Error Boundary. |
| **API Design** | Frontend ↔ Backend types always in sync. Validation on both ends. |
| **Git** | Worktree isolation. Conventional Commits in English. Squash merge only. |
| **Security** | No hardcoded secrets. Input validation. Parameterized queries. Least privilege. |
| **Performance** | No N+1. No API calls in loops. Prevent unnecessary re-renders. |
| **Parallel Agents** | `issue/task.md` shared state. Conflict detection before work. |

---

## 📁 Directory Structure

```
.kiro/
├── steering/development-rules.md  # Rules (loaded every turn)
├── skills/                        # Reference (on-demand)
│   ├── clean-ddd-hexagonal/       #   DDD + Clean Architecture
│   ├── frontend-design/           #   UI design guide
│   ├── baseline-ui/               #   Tailwind constraints
│   ├── fixing-accessibility/      #   Accessibility checklist
│   ├── fixing-metadata/           #   SEO/OGP checklist
│   └── fixing-motion-performance/ #   Animation performance
├── prompts/                       # Workflows (invoke with /name)
│   ├── implement.md               #   issue → impl → PR loop
│   ├── review.md                  #   7-point strict review
│   ├── fix-review-issues.md       #   Fix review comments
│   ├── fix-ci.md                  #   Fix CI failures
│   ├── watch-main.md              #   Monitor main → E2E
│   ├── e2e-bug-hunt.md            #   Playwright patrol
│   ├── auto-dependabot.md         #   Dependency PR handling
│   ├── 8-agent-pipeline.md        #   Pipeline guide
│   └── ...                        #   brainstorming, pr, etc.
└── agents/default.json            # Agent config
scripts/
├── start-pipeline.sh              # Launcher
├── agent.sh                       # Agent loop wrapper
└── pipeline.kdl                   # zellij layout
```

---

## 🔄 Steering / Skills / Prompts

| | Steering | Skills | Prompts |
|---|:---:|:---:|:---:|
| **Loading** | Full text every turn | Metadata only → full on demand | Full text on `/name` |
| **Certainty** | 100% | Agent decides | 100% |
| **Use for** | Rules, conventions | Reference docs | Task workflows |

---

## 🔧 Customization

```bash
# Remove unused skills
rm -rf .kiro/skills/clean-ddd-hexagonal

# Remove unused prompts
rm .kiro/prompts/auto-dependabot.md

# Add your own
mkdir .kiro/skills/my-guide       # + SKILL.md with frontmatter
touch .kiro/prompts/my-workflow.md

# Switch language
# /to-japanese — translate prompts/steering to Japanese
# /to-english  — translate prompts/steering to English
```

**For GitLab:**
```bash
just to-gitlab   # gh → glab
just to-github   # revert
```

---

<div align="center">

[MIT](LICENSE) © [yoshimi-I](https://github.com/yoshimi-I)

</div>
