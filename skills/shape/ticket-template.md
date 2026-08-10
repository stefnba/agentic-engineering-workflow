# Ticket — Structure Reference

One file per ticket in `tickets/`, named `NN-<slug>.md` (zero-padded: `01-`, `02-`). A ticket
is the brief for one agent session: a vertical slice of the spec, independently testable,
with an objective definition of done. The implementing agent receives this file, the spec
(sections 1–7), and the conventions file — not other tickets. A ticket never introduces
requirements or decisions absent from the spec; if the work reveals the spec is wrong, fix
the spec first, then the ticket.

```markdown
---
status: todo # todo | doing | done
depends_on: []
---

# NN — <Title>

## Scope

One paragraph. What changes.

## Done when

- `pytest tests/billing/test_retry_schema.py` passes
- Migration reversible: `alembic downgrade -1` clean

## Not in this ticket

Backoff policy, alerting.
```

Section rules:

- **Frontmatter** — `depends_on` lists ticket numbers (`[01, 02]`) that must be `done` first.
  Status is updated as work progresses; `done` requires every "Done when" line to hold.
- **Scope** — one paragraph, what changes. Exact file paths belong here (short-lived at
  ticket level, banned from the spec). Reference spec decisions by ID (`per ID-2, ID-4`)
  instead of restating them.
- **Done when** — concrete, checkable conditions only: commands with expected outcomes, and
  the spec ACs this ticket makes pass, by ID (`AC-6 passes, unmodified`). Every ticket
  covers at least one AC unless it is pure enabling work — then say what it enables. The
  agent verifies every line before opening a PR; locked acceptance tests are never modified
  to make a line pass.
- **Not in this ticket** — short list of adjacent work and files deliberately excluded, even
  where the spec's Out of Scope is silent. Name where deferred work lands if known
  (`backoff policy → 04`).
