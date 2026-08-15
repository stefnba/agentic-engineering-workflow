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
