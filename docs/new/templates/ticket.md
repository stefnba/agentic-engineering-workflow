---
Blocked by: <id> | none
Parallel-safe with: <id> | none
---

# Ticket: <Short imperative title, e.g. "Add rate limiting to /api/login">

<!--
Sizing rule: one ticket = one agent session = one reviewable PR.
If you can't describe "done" as commands + expected results, split or clarify the ticket.
-->

**Spec:** specs/<feature-slug>.md (§<section>)
**Blocked by:** #<id> | none
**Blocks:**

---

## Context

<!-- 2–3 sentences so the ticket works standalone even without opening the spec.
     What exists, what this ticket adds, why. -->

## Task

<!-- Specific and bounded. Bullet the concrete changes. -->

- <change 1>
- <change 2>

**Files to modify / create:**

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

## Definition of Done

- [ ] <behavioral check, e.g. "6th login attempt within 60s returns 429 with body {error: 'rate_limited'}">
- [ ] <negative check, e.g. "successful logins reset the counter">
- [ ] New tests added and passing
- [ ] No changes outside the files listed above (or justified in PR description)

**Verify with:**

```bash
npm test -- rateLimit        # expect: all pass
npm run lint                 # expect: 0 errors
npm run build                # expect: success
```

## Escalate instead of guessing if…

<!-- Tells the agent when to stop and ask rather than improvise. -->

- The task requires touching files outside the list above
- An acceptance criterion conflicts with existing behavior/tests
- <domain-specific tripwire>

---

Definition of done — commands to run (test, lint, build) and their expected results. This is the biggest lever: agents self-correct when they can verify.
Dependencies — ordered explicitly ("blocked by #12") so parallel agents don't collide
