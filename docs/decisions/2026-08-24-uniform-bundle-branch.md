---
date: 2026-08-24
status: accepted
areas: [workflow, skills]
supersedes: "[2026-08-20-branch-strategy-from-the-branch](2026-08-20-branch-strategy-from-the-branch.md)
  entirely — there is no derivation left for its two arms to order; the single-ticket clauses of
  [2026-08-18-fixed-bundle-land](2026-08-18-fixed-bundle-land.md) (a ticket PR merging into the
  integration target) and [2026-08-20-land-worktree](2026-08-20-land-worktree.md) (Land committing
  in the session's own checkout); everything else in those records stands"
---

# Every bundle gets a bundle branch, single-ticket bundles included

## Context

A single-ticket bundle's PR targeted the integration target directly, so any unrelated commit
landing there staled the branch and forced a review round that re-judged an unchanged diff —
observed in plugin testing, where a workspace-config commit on main cost a full second round. The
direct path also landed without the check-gated land worktree (`land-bundle.sh` exit `4` committed
straight to the session's checkout). An independent judge run reached the same pick as a quarantined
2026-08-21 draft: delete the path rather than cheapen its symptoms.

## Decision

Branch strategy is uniform. Every ticket PR merges into `bundle/<bundle-id>`; implementation
content reaches the integration target only through Land's merge, re-verified in Land's worktree
before the push. Planning commits — a published bundle, a backlog line — still write to the target
directly and carry no behavior change.

- `ticket_base()` is a constant mapping to `bundle/<bundle-id>`; nothing reads the ticket count or
  the remote to pick a base.
- `land-bundle.sh` exit `4` now means "no bundle branch to land" and is a stop — the route that
  committed a single-ticket land in the session's checkout is gone.
- Ticket staleness has exactly one cause left, a sibling merging first; the cure stays a fix round
  and a fresh Accept per [2026-08-20-ticket-branch-currency](2026-08-20-ticket-branch-currency.md).

## Rejected

- **Keep the direct path plus a verdict-transfer rule for target drift** (drafted earlier today,
  never committed): converges the review loop but keeps a path onto the target whose only guard is
  a diff-identity heuristic, and leaves the unchecked exit-`4` landing untouched.
- **A mergeability check alone before Accept:** catches textual conflicts only; the silent semantic
  break is the case that matters.
- **Extending verdict transfer to stale siblings:** spends the trust relaxation exactly where
  interaction risk is correlated — tickets shaped together.

## Costs

- A one-ticket change now takes one more step: its PR merges to the bundle branch, and reaching the
  target requires the Land pass (which already ran for single-ticket bundles — but now carries the
  merge, worktree, and push loop).
- The target's first-parent history shows one Land merge per bundle instead of a direct ticket
  merge; the ticket PR no longer appears as a PR onto the target.
- In-flight single-ticket bundles from before this change have merged PRs whose base is the
  target; the status derivation reads their tickets as not `done`. Land them before upgrading, or
  finish them by hand.
- `TICKET_MERGE_METHOD` narrows to `squash | merge`. Land now refuses any first-parent commit on
  the bundle branch that matches no ticket PR's merge record, and a rebase merge records only the
  tip of the commits it adds — the rest would read as unrecorded and the bundle could never land.
  `_config.sh` refuses the setting outright rather than letting a done bundle discover it at Land.

## Revisit if

- The per-bundle Land pass proves too heavy for the one-ticket case in practice — the pressure that
  would argue for a forge-native merge queue instead.
- A forge gains target-side checks the workflow can rely on (required merge-queue verification on
  the integration target), which would guard a direct path structurally rather than by rule.
