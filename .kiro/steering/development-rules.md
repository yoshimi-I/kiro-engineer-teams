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

## Issue Creation

### Priority labels (required on every issue)

| Label | Meaning | Example |
|-------|---------|---------|
| `P0-critical` | Blocks users or breaks production | Security vulnerability, data loss |
| `P1-high` | Important but not blocking | Bug affecting UX, missing validation |
| `P2-medium` | Should do soon | Refactoring, performance improvement |
| `P3-low` | Nice to have | Documentation, minor DX improvement |

Every `gh issue create` must include `--label "<priority>"`. Impl agents pick issues in P0→P1→P2→P3 order.

### Conflict prevention

Before creating an issue, check existing open issues for overlapping file changes:
```bash
gh issue list --state open --json number,title,body --jq '.[].body' | grep -i "<target-file-or-module>"
```

| Situation | Action |
|-----------|--------|
| No overlap with open issues | Create independently |
| Overlaps with an open issue | Add `depends-on: #<number>` in body and label `blocked` — Impl agents must not start until dependency is merged |

### Body format for dependencies

```markdown
## Dependencies
- depends-on: #<number> (must be merged first)
```

## Security

- No hardcoded secrets. Input validation. Parameterized queries. Least privilege.

## Parallel Agents

- `issue/task.md` is the shared state file — read before starting any work
- Record "in-progress" before starting, "in-review" after PR creation
- Never modify files another agent is working on
- All issue/PR comments in English
- Decisions recorded in `aidlc-docs/audit.md` with ISO 8601 timestamps
