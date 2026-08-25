---
date: 2026-08-25
status: accepted
areas: [workflow]
supersedes:
superseded_by:
---

# Bundle artifacts stay committed files; the forge gets no issue mirror

## Context

GitHub sub-issues went GA, making bundle-as-parent-issue with tickets-as-sub-issues
viable, prompting a reassessment of
[tickets-are-files-not-issues](./2026-08-10-tickets-are-files-not-issues.md) at bundle
scope. That record stands; this one widens it to the whole bundle substrate and rules on
the new alternatives.

## Decision

The complete bundle — spec, plan, tickets — lives only as committed files under
`work/bundles/`, published and revised by planning commits on the integration target.
No forge issue represents a bundle or ticket, not even as a non-authoritative index.

- Plan-gate approval pins to a publish commit; permalinks cite exact bytes.
- Ticket worktrees carry the bundle for free — agent reads stay local and offline.
- `depends_on` stays a DAG in the versioned file the claim script gates on.

## Rejected

- **Full move to GitHub issues** (parent = bundle, sub-issues = tickets, labels for
  metadata): issue bodies are mutable under a stable URL, so approval pinning breaks;
  artifact reads become unpinned network calls; labels are stored status, ruled out by
  [derived-execution-state](./2026-08-20-derived-execution-state.md); sub-issues are a
  tree and cannot hold the `depends_on` DAG. Claiming gains nothing — branch creation
  remains the claim either way.
- **Hybrid links-only issue index** (files authoritative, issues carry only permalinks
  for UI visibility): nobody needs the forge UI today, so it is a script, a config key,
  and a re-pin step on every repeated Plan gate for nothing. The pre-shaped fallback if
  visibility demand appears.
- **Planning ref off the integration target** (`refs/bundles/<id>`): removes planning
  commits from target history but breaks the mechanism that puts the bundle in every
  ticket worktree, and permalink reachability then hangs on a deletable side ref.

## Costs

- No forge UI for in-flight work; state comes only from the `bundle-state` scripts.
- No native work-item↔PR back-links; the PR-body permalinks are one-directional.
- Planning commits stay in integration-target history, and the workflow cannot run
  where direct pushes to the target are forbidden.

## Revisit if

- The 2026-08-10 conditions trigger: >~3 concurrent agents, teams sharing an ID space,
  or collaborators who don't clone the repo.
- Someone actually needs forge visibility — the links-only index is the shaped answer.
- Forge issues gain immutable, citable revision pinning.
