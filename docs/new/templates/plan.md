```markdown
# Implementation Plan: Orders

## Architectural approach

...

## Work breakdown

1. FEAT-001 — database foundation
2. FEAT-002 — domain model
3. FEAT-003 — create-order API
4. FEAT-004 — idempotency
5. FEAT-005 — integration tests

## Parallelization

Can run concurrently:

- FEAT-001
- FEAT-005

After FEAT-002:

- FEAT-003
- FEAT-004

## Risks

...
```
