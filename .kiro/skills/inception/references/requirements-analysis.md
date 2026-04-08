# Requirements Analysis (Adaptive)

Always runs. Depth adapts to complexity.

## Adaptive Depth

| Level | When | What |
|-------|------|------|
| Minimal | Simple, clear request | Intent analysis only |
| Standard | Normal complexity | Functional + non-functional requirements |
| Comprehensive | Complex, high-risk | Full requirements with traceability |

## Steps

### 1. Analyze user request (Intent Analysis)
- What is the user trying to build?
- What problem does it solve?
- Who are the target users?
- What are the success criteria?

### 2. Determine depth
Based on: number of features, integrations, user types, risk level.

### 3. Ask clarification questions in chat
Ask the user directly in conversation. Use multiple-choice format:

```
以下について教えてください：

1. 認証方式はどれを想定していますか？
   A) メール + パスワード
   B) ソーシャルログイン（Google, GitHub等）
   C) SSO
   D) その他（教えてください）

2. ...
```

- Group related questions together (max 3-5 per message)
- Wait for user response before proceeding
- Ask follow-up questions if answers are ambiguous

### 4. Generate requirements document
Create `aidlc-docs/inception/requirements/requirements.md`:
- Functional requirements (grouped by feature area)
- Non-functional requirements (performance, security, scalability)
- Constraints and assumptions
- Out of scope

### 5. Present summary and get approval
Show a concise summary in chat. Ask user to confirm before proceeding.

### 6. Record in audit
Append to `aidlc-docs/audit.md` with timestamp.
