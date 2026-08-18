---
date: 2026-08-18
status: accepted
supersedes: the `work/config.conf` key list in
  [2026-08-18-script-read-settings.md](./2026-08-18-script-read-settings.md), which named the merge
  setting `MERGE_METHOD` as though it covered every merge the workflow performs
---

# How a bundle lands is workflow machinery, not a repository setting

## Decision

Two different merges happen, and only one of them is configurable.

- **A ticket PR** merges into its target — the bundle branch in a multi-ticket bundle, the
  integration target in a single-ticket one — using `TICKET_MERGE_METHOD` in `work/config.conf`,
  default `squash`. Renamed from `MERGE_METHOD`, which read as if it governed both.
- **The land** — a finished bundle branch onto the integration target, at Ship — is fixed:
  `git merge --no-ff`, never a squash, never a rebase, and `--no-ff` even when a fast-forward is
  available. When the integration target has moved, merge it into the bundle branch and re-run the
  Ship check before landing; that is the only permitted reconciliation. `workflow/git-mechanics.md`
  owns the rules, `workflow/lifecycle.md` sequences them as Ship steps 5–7.

The invariant the land protects: **it preserves each ticket's commits exactly as they reached the
bundle branch.**

## Consequences

- Ship deletes the bundle directory, so after Ship those per-ticket commits — their subjects, their
  PR back-references, and the permalinks in those PR bodies — are the only bridge from a shipped line
  of code back to the ticket that approved it. Squashing the land breaks `git blame` at the bundle
  instead of the ticket, and removes per-ticket revert and bisect. That is what "git history preserves
  the work record; there is no shipped-bundle archive" rests on, so it cannot be a knob a repository
  turns off by accident.
- Merge history is a strict superset of squash history: `git bisect --first-parent` reproduces the
  squash-land view on demand, while nothing reconstructs ticket granularity from a squashed land.
  Accepted cost: bisect can descend into ticket commits that were green against an older base.
- **Rejected — a `LAND_METHOD` setting.** It would let a repository silently break the invariant
  above. A setting is right for a preference and wrong for a load-bearing guarantee.
- **Rejected — rebase-then-fast-forward.** It reissues commits Ship already verified as a whole and
  that the ticket PRs' merge records point at, so what lands is a state no check ever ran against.
- **Rejected — declaring `trunk`** as the escape hatch for repositories that forbid merge commits.
  That option no longer exists: branch strategy is derived from ticket count, per
  [2026-08-18-script-read-settings.md](./2026-08-18-script-read-settings.md). Such a repository
  declares a different integration target instead — the same escape hatch a protected default branch
  already uses. `skills/setup/references/prerequisites.md` now states the requirement.
- The invariant is written so it does not assume `TICKET_MERGE_METHOD=squash`. Under the default that
  is one commit per ticket; under `merge` or `rebase` it is whatever those produce, and the land
  preserves that too.
- No script implements the land yet — `bundle-git` has no Ship-side script at all, tracked in
  `work/backlog.md`. Until one exists, `workflow/git-mechanics.md` is the only control, and
  `TICKET_MERGE_METHOD` deliberately does not reach it.
- Confirmed by an independent review pass before implementation, which also established that the land
  method touches no derived state: `ticket-status.sh` keys `done` off each ticket PR's merge record
  against its own target, which survives branch deletion and any land method.
