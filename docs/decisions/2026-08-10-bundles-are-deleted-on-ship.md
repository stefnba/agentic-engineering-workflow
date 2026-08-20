---
status: accepted
date: 2026-08-10
areas: [docs]
---

# 0008 Shipped bundles are deleted, not archived — there is no `done/`

## Context

When a feature ships, its bundle (brief, spec, tickets) describes the system at a moment that is now past. The comfortable default is an archive folder; every project management instinct says keep the record.

## Decision

At ship, the spec is absorbed into the durable docs and the bundle is **deleted**. Git history is the archive. There is no `done/` directory. Cancellation is symmetric: backlog line pointing at the deletion SHA, then delete.

## Rejected

- **A `done/` archive**: N shipped feature docs about one subsystem are confidently-worded, mutually contradictory documentation that retrieval — especially agent retrieval — cannot disambiguate. That is worse than no documentation. This is the record most likely to be quietly reverted by someone who finds deletion uncomfortable; the discomfort is the point of writing it down.
- **Docs-as-system-only** (no feature docs at all; edit durable docs directly in the PR): zero staleness by construction, but you cannot describe a target state before it's true — which is the entire job of shaping.

## Costs

- Recovering a shipped bundle requires git archaeology (a SHA, `git log --follow`) instead of a browse.
- The absorption step at ship must actually happen, or the reasoning is lost with the bundle — reconcile discipline is load-bearing here.

## Revisit if

- Retrieval over git history becomes as reliable as retrieval over the working tree — the contradiction hazard would shrink, though absorption into durable docs would still be the better record.
