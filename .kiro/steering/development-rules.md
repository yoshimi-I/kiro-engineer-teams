---
name: development-rules
description: Core rules applied to all tasks
---

## Language

Always respond to the user in Japanese. Code, commit messages, PR titles/body, and issue comments remain in English.

## Initial Setup

If the "Project-specific settings" section below is empty (comments only):
1. Read `.kiro/skills/inception/SKILL.md` and run the INCEPTION workflow
2. Guide user through: workspace detection → requirements → stories → architecture
3. Write finalized tech stack to "Project-specific settings" section
4. Generate GitHub issues via `gh issue create`
5. Instruct user to run `./scripts/start-pipeline.sh`

If settings are already filled in, skip this section.

## Project-specific settings

```
# Fill in after INCEPTION:
# - Frontend: 
# - Backend: 
# - Infra: 
# - Test commands: 
# - Git: Conventional Commits
```

## Prerequisites

- `git init` + `git remote add origin <url>` configured
- `gh auth login` authenticated
- Without these, `gh issue list` etc. will not work

## Code Quality

- Minimal code to solve the problem correctly — YAGNI
- Readability over cleverness
- Single responsibility per function/module
- Understand requirements fully before writing code
- Follow existing project conventions

## Implementation

- TDD: Red → Green → Refactor. No code without tests first.
- 3-layer testing required: unit (per function) + integration (per API) + E2E (per user flow)
- Error handling: no silent catches, actionable user messages, resource cleanup
- API: frontend ↔ backend types always in sync, validation on both ends
- Performance: no N+1, no API calls in loops, prevent unnecessary re-renders
- For detailed guidelines, read `.kiro/skills/quality-guidelines/SKILL.md`

## Git

- **All work in git worktree** — never checkout/switch in main repo
- Branch: `<type>/issue-<number>-<short-description>`
- Commit: Conventional Commits, English, atomic
- PR: English title + body, `Closes #N`, squash merge only
- CI must pass before merge. No force merge.

### pre-commit（必須）

コミット前に必ず lint と test を実行すること。CI失敗を未然に防ぐ。

```bash
# コミット前に必ず実行（Project-specific settings のコマンドを使う）
# 例: npm run lint && npm run test
# 例: cargo clippy && cargo test
# 例: ruff check . && pytest
```

- lint/test が通らないコードはコミットしない
- 「push してから CI で確認」は禁止 — ローカルで通してからpush
- CI失敗した場合は、そのPRの作成者（Implエージェント）が自分で修正する

## Issue作成ルール

### 優先度ラベル（全issue必須）

| ラベル | 意味 | 例 |
|-------|------|-----|
| `P0-critical` | ユーザーをブロック or 本番障害 | セキュリティ脆弱性、データ損失 |
| `P1-high` | 重要だがブロックはしない | UXに影響するバグ、バリデーション欠如 |
| `P2-medium` | 早めに対応すべき | リファクタリング、パフォーマンス改善 |
| `P3-low` | あると嬉しい | ドキュメント、軽微なDX改善 |

`gh issue create` には必ず `--label "優先度" --label "<P0-critical|P1-high|P2-medium|P3-low>"` を含めること。Implエージェントは P0→P1→P2→P3 の順で取得する。

### コンフリクト防止

issue作成前に、既存のopen issueと変更対象ファイルの重複を確認:
```bash
gh issue list --state open --json number,title,body --jq '.[].body' | grep -i "<対象ファイルまたはモジュール>"
```

| 状況 | アクション |
|------|-----------|
| 既存issueと重複なし | 独立issueとして作成 |
| 既存issueと重複あり | 本文に `depends-on: #<番号>` を記載し `blocked` ラベルを付与 — 依存先がmergeされるまでImplは着手禁止 |

### 依存関係の本文フォーマット

```markdown
## 依存関係
- depends-on: #<番号>（先にmergeが必要）
```
```

## Security

- No hardcoded secrets. Input validation. Parameterized queries. Least privilege.

## Parallel Agents

- `issue/task.md` is the shared state file — read before starting any work
- Record "in-progress" before starting, "in-review" after PR creation
- Never modify files another agent is working on
- All issue/PR comments in English
- Decisions recorded in `aidlc-docs/audit.md` with ISO 8601 timestamps
