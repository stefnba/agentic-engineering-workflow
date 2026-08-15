---
status: todo # todo | doing | done; done means accepted and merged
depends_on: [] # ticket ids that must be done first
blocked_reason: null # optional external blocker; do not duplicate depends_on here
---

# Ticket: <Short imperative title, e.g. "Add rate limiting to /api/login">

<!--
Sizing rule: one ticket = one agent session = one reviewable PR.
If you can't describe "done" as commands + expected results, split or clarify the ticket.
-->

**Spec:** `../spec.md` (§<section>)

---

## Context

<!-- 2–3 sentences so the ticket works standalone even without opening the spec.
     What exists, what this ticket adds, why. -->

## Task

<!-- Specific and bounded. Bullet the concrete changes. -->

- <change 1>
- <change 2>

**Expected touch points (not an allowlist):**

- `src/middleware/rateLimit.ts` (new)
- `src/api/routes.ts` (register middleware on login route)
- `tests/middleware/rateLimit.test.ts` (new)

**Out of scope for this ticket:**

- <thing handled by another ticket — link it>

## Implementation Notes

<!-- Only what the agent can't infer: patterns to copy, gotchas, decisions already made. -->

- Follow the pattern in `src/middleware/auth.ts`
- Config values go in `src/config/index.ts`, not hardcoded
- <known gotcha>

## Autonomy Boundaries

**May decide:**

- <bounded local choice the agent may make>

**Must preserve:**

- <observable behavior, contract, invariant, or approved architectural boundary>

<!--
Do not put unresolved product or cross-cutting design questions here. Material decisions are
resolved before approval. This section grants only bounded implementation discretion.
-->

## Definition of Done

- [ ] <behavioral check, e.g. "6th login attempt within 60s returns 429 with body {error: 'rate_limited'}">
- [ ] <negative check, e.g. "successful logins reset the counter">
- [ ] New tests added and passing
- [ ] Changes outside the expected touch points are limited to required tests, reconciliation, or
      clearly justified local support work

**Verify with:**

```bash
npm test -- rateLimit        # expect: all pass
npm run lint                 # expect: 0 errors
npm run build                # expect: success
```

## Escalate instead of guessing if…

<!-- Tells the agent when to stop and ask rather than improvise. -->

- The task requires changing approved behavior, scope, public contracts, security properties,
  migration behavior, compatibility, or cross-ticket architecture
- An acceptance criterion conflicts with existing behavior/tests
- The ticket or plan is factually stale in a way that changes the approved decomposition
- <domain-specific tripwire>

---

Option 2:

```markdown
# FEAT-003 — Add idempotent order creation API

## Objective

Implement the API described by FR-004 and API-002 in the feature spec.

## Context

Orders can currently be created through the internal service, but there
is no public endpoint. Clients may retry requests, so creation must be
idempotent.

## Scope

- Add POST /v1/orders
- Validate the request
- Persist the order
- Support Idempotency-Key
- Return the documented response
- Add unit and integration tests

## Out of scope

- Order cancellation
- Payment processing
- Admin UI

## References

- Spec: `../spec.md`
- Requirements: FR-004, API-002
- Depends on: FEAT-002

## Acceptance criteria

- [ ] POST /v1/orders implements the API contract.
- [ ] Invalid requests return the documented validation error.
- [ ] A successful request persists exactly one order.
- [ ] Repeating a request with the same Idempotency-Key does not create
      a second order.
- [ ] Concurrent requests with the same Idempotency-Key are safe.
- [ ] Tests cover success, validation failure, retry, and concurrency.
- [ ] Existing tests continue to pass.

## Agent guidance

Inspect existing API, persistence, validation, and error-handling patterns
before introducing new abstractions.

Prefer existing project conventions over introducing new libraries or
architectural patterns.

## Definition of done

- Implementation complete
- Tests passing
- Acceptance criteria verified
- No unrelated changes
- PR/commit describes what was changed and how it was verified
```
