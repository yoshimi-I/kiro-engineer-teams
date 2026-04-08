
# INCEPTION — Structured Project Planning

Run the full INCEPTION phase from AI-DLC: analyze workspace → gather requirements →
write user stories → design architecture → generate GitHub issues.

This is the entry point for new projects. After completion, the 8-agent pipeline takes over.

## How to run

Read `.kiro/skills/inception/SKILL.md` first, then load each reference file as you
progress through the stages.

## Stage 1: Workspace Detection (always)

1. Read `references/workspace-detection.md` from the inception skill
2. Scan the workspace
3. Create `aidlc-docs/aidlc-state.md`
4. Proceed to Stage 2

## Stage 2: Requirements Analysis (always)

1. Read `references/requirements-analysis.md`
2. Read `references/depth-levels.md` to determine depth
3. Analyze user's request
4. If clarification needed, create question file per `references/question-format.md`
5. Generate `aidlc-docs/inception/requirements/requirements.md`
6. **Wait for user approval before proceeding**
7. Append to `aidlc-docs/audit.md`

## Stage 3: User Stories (conditional)

1. Read `references/user-stories.md`
2. Evaluate if stories add value (see skip conditions)
3. If running: generate personas and stories
4. **Wait for user approval**
5. Append to audit

## Stage 4: Architecture Design (conditional)

1. Read `references/architecture-design.md`
2. Evaluate if architecture design is needed
3. If running: design components, tech stack, directory structure
4. **Wait for user approval**
5. Append to audit

## Stage 5: Issue Generation (always)

1. Read `references/issue-generation.md`
2. Read all INCEPTION outputs generated so far
3. Decompose into implementable, independent, testable issues
4. Create issues via `gh issue create`
5. Update `.kiro/steering/development-rules.md` with finalized tech stack
6. Update `aidlc-docs/aidlc-state.md`
7. Tell user to run `./scripts/start-pipeline.sh`

## Rules

- Each stage must append decisions to `aidlc-docs/audit.md` with ISO 8601 timestamps
- User approval is required at stages 2, 3, 4 before proceeding
- Stage 5 (issue generation) does NOT require approval — it auto-generates
- Adapt depth based on complexity (minimal / standard / comprehensive)
- Questions use file-based format, not inline chat
- All documents go in `aidlc-docs/inception/`
