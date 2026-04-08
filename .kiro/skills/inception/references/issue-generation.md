# Issue Generation (Always — Pipeline Handoff)

This is the bridge between INCEPTION and the 8-agent pipeline.
Converts design documents into GitHub issues that agents can pick up.

## Steps

### 1. Read all INCEPTION outputs
- `aidlc-docs/inception/requirements/requirements.md`
- `aidlc-docs/inception/user-stories/stories.md` (if exists)
- `aidlc-docs/inception/architecture/` (if exists)

### 2. Decompose into issues
Each issue should be:
- Implementable in a single PR
- Independent (minimal dependencies between issues)
- Testable (clear acceptance criteria)

### 3. Prioritize
1. Project setup / scaffolding (must be first)
2. Core domain models / database schema
3. Backend API endpoints
4. Frontend pages / components
5. Integration (frontend ↔ backend wiring)
6. Testing (E2E, additional integration tests)
7. Polish (UI, error handling, edge cases)
8. Documentation

### 4. Create issues
For each issue:
```bash
gh issue create \
  --title "feat: <concise description>" \
  --body "## Description
<what to implement>

## Acceptance Criteria
- [ ] <testable condition 1>
- [ ] <testable condition 2>

## Technical Notes
<relevant architecture decisions, file paths, dependencies>

## References
- Requirements: aidlc-docs/inception/requirements/requirements.md
- Architecture: aidlc-docs/inception/architecture/architecture.md" \
  --label "<appropriate label>"
```

### 5. Update steering
Write the finalized tech stack and project conventions to
`.kiro/steering/development-rules.md` (project-specific section).

### 6. Update state
Update `aidlc-docs/aidlc-state.md`:
```
- Current phase: INCEPTION ✅ → CONSTRUCTION (via pipeline)
- Issues created: <count>
```

### 7. Instruct user
Tell the user to run `./scripts/start-pipeline.sh` to launch the 8-agent pipeline.
