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

### 2. Design high-level architecture
- Identify major components and responsibilities
- Define component interfaces
- Establish communication patterns (REST, WebSocket, events)
- Choose technology stack (if not already decided)

### 3. Design directory structure
Based on project type, define the directory layout.

### 4. Generate documents
Create in `aidlc-docs/inception/architecture/`:
- `architecture.md` — component diagram, responsibilities, interfaces
- `technology-stack.md` — chosen technologies with rationale
- `directory-structure.md` — project layout

### 5. Get user approval
Present architecture overview. User must confirm.
