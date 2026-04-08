# Kiro Engineer Teams

8-agent parallel development pipeline template.

## First interaction

Tell me what you want to build. Brainstorming starts automatically.

## Rules

All rules are in `.kiro/steering/development-rules.md`. Key points:
- TDD: write tests before implementation
- 3-layer testing: unit + integration + E2E required
- Git: worktree isolation, Conventional Commits (English), squash merge
- PR comments and issues: always in English
- Parallel agents: check `issue/task.md` before starting work

## After brainstorming

1. Tech stack and conventions are written to steering
2. Issues are created via `gh issue create`
3. Run `./scripts/start-pipeline.sh` to launch 8-agent pipeline
