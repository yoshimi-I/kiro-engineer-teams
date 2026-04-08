
# INCEPTION — Structured Project Planning

Run the full INCEPTION phase: analyze workspace → gather requirements →
write user stories → design architecture → generate GitHub issues.

All interaction happens in chat. Documents are generated after user approval.

## How to run

Read `.kiro/skills/inception/SKILL.md` first, then load each reference file as you
progress through the stages.

## Stage 1: Workspace Detection (always)

1. Read `references/workspace-detection.md` from the inception skill
2. Scan the workspace
3. Create `aidlc-docs/aidlc-state.md`
4. Report findings to user in chat, proceed to Stage 2

## Stage 2: Requirements Analysis (always)

1. Read `references/requirements-analysis.md` and `references/depth-levels.md`
2. Analyze user's request
3. Ask clarification questions directly in chat (multiple-choice format)
4. After gathering answers, present requirements summary in chat
5. **Wait for user approval before proceeding**
6. Generate `aidlc-docs/inception/requirements/requirements.md`
7. Append to `aidlc-docs/audit.md`

## Stage 3: User Stories (conditional)

1. Read `references/user-stories.md`
2. Evaluate if stories add value (see skip conditions)
3. If running: present personas and stories in chat
4. **Wait for user approval**
5. Generate documents after approval

## Stage 4: Architecture Design (conditional)

1. Read `references/architecture-design.md`
2. Evaluate if architecture design is needed
3. If running: propose architecture in chat with ASCII diagrams
4. **Discuss and iterate with user until approved**
5. Generate documents after approval

## Stage 5: Issue Generation (always)

1. Read `references/issue-generation.md`
2. Read all INCEPTION outputs generated so far
3. Decompose into implementable, independent, testable issues
4. Present issue list to user in chat for final confirmation
5. Create issues via `gh issue create`
6. Update `.kiro/steering/development-rules.md` with finalized tech stack
7. Tell user to run `./scripts/start-pipeline.sh`

## Rules

- All interaction happens in chat — no question files
- Respond in Japanese
- Each stage appends decisions to `aidlc-docs/audit.md` with ISO 8601 timestamps
- User approval required at stages 2, 3, 4 before generating documents
- Documents are written only after chat-based approval
- Adapt depth based on complexity (minimal / standard / comprehensive)
