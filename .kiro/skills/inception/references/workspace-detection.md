# Workspace Detection

## Purpose
Determine workspace state and project type before planning.

## Steps

### 1. Check for existing project state
- Look for `aidlc-docs/aidlc-state.md` — if found, resume from last phase
- Look for existing `issue/task.md` — if found, check current status

### 2. Scan workspace for existing code
- Scan for source files (.ts, .tsx, .py, .java, .go, .rs, etc.)
- Check for build files (package.json, pyproject.toml, Cargo.toml, etc.)
- Check for infrastructure (Dockerfile, terraform/, CDK, etc.)

### 3. Classify project
- **Greenfield**: No existing code → full planning needed
- **Brownfield**: Existing code → analyze before planning

### 4. Record findings
Create `aidlc-docs/aidlc-state.md`:
```markdown
# Project State
- Type: greenfield / brownfield
- Detected stack: [languages, frameworks]
- Workspace root: [path]
- Current phase: INCEPTION
- Current stage: workspace-detection ✅
```

### 5. Proceed
- Brownfield → read existing code structure before requirements
- Greenfield → proceed to requirements analysis
