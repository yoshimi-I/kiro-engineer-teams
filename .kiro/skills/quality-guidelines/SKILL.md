---
name: quality-guidelines
description: >
  Detailed implementation guidelines: TDD workflow, 3-layer testing strategy,
  error handling patterns, API design rules, documentation standards, and performance checklist.
  Use when implementing features, writing tests, designing APIs, or reviewing code quality.
  Triggers on: testing, TDD, error handling, API design, documentation, performance, code quality.
---

# Quality Guidelines

## TDD (Test-Driven Development)

1. **Red**: Write a failing test first
2. **Green**: Write minimal code to pass
3. **Refactor**: Clean up (tests still pass)

Rules:
- No implementation code without tests first
- Bug fixes start with a reproduction test
- Test behavior, not implementation internals

## Testing Strategy (3-layer)

### Unit Tests
- Required for all business logic and utility functions
- Isolate external dependencies with mocks/stubs
- Per function: minimum 1 happy path + 1 error + 1 edge case
- Frontend: component behavior (render, events, state)
- Backend: domain logic, services, validation

### Integration Tests
- Required for every API endpoint
- Backend: full request → response flow (including DB)
- Frontend: API call → UI update flow
- WebSocket: connect → send/receive → disconnect
- DB: migration → CRUD → rollback

### E2E Tests (Playwright)
- Required for every major user flow
- Page navigation, form submission, auth flow
- Responsive: desktop + mobile (375px)
- Error states: 404, network error, validation error
- Screenshots + console error collection in every test

### PR Merge Gate
PRs must satisfy ALL:
- [ ] New code has corresponding unit tests
- [ ] API changes have updated integration tests
- [ ] UI changes have updated E2E tests
- [ ] All tests pass in CI

## Error Handling

- Never silently catch exceptions — log or notify user
- User-facing errors must be specific and actionable (no "An error occurred")
- API errors: unified format (status code + error code + message)
- Resource cleanup: DB connections, file handles, WebSocket
- Network errors: consider retry + fallback
- Frontend: Error Boundary to prevent crashes
- Backend: global exception handler for unhandled errors

## API Design

- Frontend ↔ Backend type definitions must stay in sync
- API changes must update both sides simultaneously
- WebSocket message types must match on both ends
- RESTful: proper HTTP methods + status codes
- Request/response validation on both ends
- Breaking changes require versioning

## Documentation

- Public APIs must be documented
- Comments explain "why", code explains "what"
- README, API specs, architecture docs stay in sync with implementation
- Complex business logic gets inline comments
- All config values and env vars listed in `.env.example`

## Performance

- No N+1 queries — fetch needed data in one query
- No API calls or DB queries inside loops
- Frontend: prevent unnecessary re-renders (memo, useMemo, useCallback)
- Images/assets: appropriate size and format
- Bundle size awareness — no unnecessary dependencies

## Audit Trail

All design decisions recorded in `aidlc-docs/audit.md`:
- Append-only, never overwrite
- ISO 8601 timestamps
- Record user approvals, rejections, issue creation events

## Document Structure

```
aidlc-docs/
├── aidlc-state.md
├── audit.md
└── inception/
    ├── requirements/
    ├── user-stories/
    └── architecture/
```
