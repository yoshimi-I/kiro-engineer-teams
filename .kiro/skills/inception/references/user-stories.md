# User Stories (Conditional)

## When to run
- New user-facing features
- Changes affecting user workflows
- Multiple user types involved
- Complex business requirements

## When to skip
- Pure internal refactoring
- Simple bug fixes with clear scope
- Infrastructure-only changes
- Documentation-only updates

## Steps

### 1. Identify personas
Based on requirements, identify distinct user types.
Present them in chat and confirm with user.

### 2. Write stories
Format: "As a [persona], I want to [action] so that [benefit]"

Each story includes:
- Acceptance criteria (testable conditions)
- Priority (must-have / should-have / nice-to-have)
- Estimated complexity (S/M/L/XL)

### 3. Present in chat for approval
Show stories grouped by persona. Ask user to confirm, modify, or add.

### 4. Generate document
After approval, create `aidlc-docs/inception/user-stories/stories.md` and `personas.md`.
