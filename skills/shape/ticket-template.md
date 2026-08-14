# Ticket template

One file per ticket in `tickets/`, named `NN-<slug>.md` (zero-padded: `01-`, `02-`). A ticket
is the brief for one agent session: a vertical slice of the spec, independently testable, with
an objective definition of done. The implementing agent receives this file, the spec, and the
conventions file — not other tickets. A ticket never introduces requirements or decisions
absent from the spec; if the work reveals the spec is wrong, fix the spec first, then the
ticket.

Copy the skeleton, fill it, delete the `<!-- -->` guidance as you go.

```markdown
---
status: todo # todo | doing | done — done requires every "Done when" line to hold
depends_on: [] # ticket numbers ([01, 02]) that must be done first
---

# NN — <Title>

## Scope

<!-- What changes, as a bullet list grouped by file — one change per line. A ticket carrying a
single change may use one sentence instead. Exact file paths belong here (short-lived at
ticket level, banned from the spec). Reference spec decisions by ID (`per ID-2, ID-4`)
instead of restating them. When this ticket's position in the order isn't explained by
depends_on, add the one line of why here ("ships behind a flag so we can measure before 04").

Example:
- `src/billing/retry.ts` — exponential backoff on 429/503 per ID-2
- `src/billing/client.ts` — route retryable errors through the new policy
-->

## Done when

<!-- Concrete, checkable conditions only: commands with expected outcomes, and the spec ACs
this ticket makes pass, by ID. Every ticket covers at least one AC unless it is pure enabling
work — then say what it enables. The agent verifies every line before opening a PR; locked
acceptance tests are never modified to make a line pass.

Example:
- `pytest tests/billing/test_retry_schema.py` passes
- Migration reversible: `alembic downgrade -1` clean
- AC-6 passes, unmodified
-->

## Not in this ticket

<!-- Short list of adjacent work and files deliberately excluded, even where the spec's Out of
Scope is silent. Name where deferred work lands if known.

Example: Backoff policy, alerting (→ 04).
-->
```
