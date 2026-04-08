# Architecture Design (Conditional)

## When to run
- New components or services needed
- System architecture decisions required
- Multiple services or modules
- Infrastructure design needed

## When to skip
- Changes within existing component boundaries
- Simple feature additions to existing architecture

## Steps

### 1. Analyze context
Read requirements and user stories (if generated).

### 2. Propose architecture in chat
Present to user:
- Major components and responsibilities
- Communication patterns (REST, WebSocket, events)
- Technology stack recommendation with rationale
- Directory structure

Use simple ASCII diagrams in chat:
```
[Frontend] → [API Server] → [Database]
                ↓
           [WebSocket]
```

### 3. Discuss and refine
Ask user for feedback. Iterate until approved.

### 4. Generate documents
After approval, create in `aidlc-docs/inception/architecture/`:
- `architecture.md`
- `technology-stack.md`
- `directory-structure.md`
