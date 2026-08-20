---
status: accepted
date: 2026-08-10
areas: [docs, skills]
---

# 0011 Shape creates the full ticket set, specified end to end

## Context

The inherited rule was "don't create all tickets upfront — beyond the first two or three, they're written against assumptions implementation will invalidate; generate the rest after the first lands." But it named no owner for the later tickets (shape's session is gone, and one-creator-per-artifact says shape creates tickets), and the Plan gate could only approve a partial decomposition. The question was genuinely contested in design: full-upfront, lazy generation, and a stub-gradient hybrid were all argued.

## Decision

Shape writes **every** ticket, each with a concrete `Done when`, before the Plan gate. Writing the check is a test of the spec — a ticket whose check can't be written yet is a spec hole found while it's cheap — and full decomposition makes coverage checkable: every acceptance criterion maps to some ticket's done-when, verified by the critic and the human at the Plan gate. Staleness is handled by existing machinery, not avoided: tickets invalidated by landed work are amended in the landing PR's reconcile half, reviewed at Accept; a scope change is a deviation that re-arms the Plan gate. There is no re-shaping mid-flight.

## Rejected

- **Lazy generation (the inherited rule)**: no owner and no gate for tickets created mid-implement — decomposition quietly delegated to whoever is around, which is exactly the unsupervised judgment the gates exist to prevent.
- **Stub gradient** (full decomposition, but far tickets as title-plus-scope stubs, specified at pick-up): preserves the staleness insight, but adds new machinery (a stub state, an elaboration mode, elaboration bounds) and hands ticket-specification authority to implement sessions, weakening the author/implementer split. Full-upfront reuses reconcile and deviation machinery that already exists.

## Costs

- Late tickets will sometimes be written twice — drafted at shape, amended at reconcile after the tracer bullet lands. That rework is accepted, and the tracer-bullet ordering exists to make it happen at ticket 2 rather than ticket 6.
- Shape sessions get longer and front-load more thinking; a hurried author now has more surface to be wrong on, which the critic's coverage check partially offsets.

## Revisit if

- Bundles grow large enough (many tickets, long-lived) that reconcile sweeps become the dominant cost — though past ~20 active bundles the documented answer is GitHub issues anyway.
- Reconcile discipline demonstrably fails and stale tickets get executed as written — then the stub gradient's late-binding deserves a second look.
