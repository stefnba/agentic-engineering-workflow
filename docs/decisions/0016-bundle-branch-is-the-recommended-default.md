---
status: accepted
date: 2026-08-14
areas: [docs, skills]
---

# 0016 Bundle-branch replaces trunk as the recommended default

## Context

0015 made the branch strategy a per-repo declaration with trunk recommended, and one day of
dogfooding trunk produced the counter-case: two bundles interleaved on main, and redirecting
the half-merged review-fix-loop bundle took two reverts, one conflicting. Branch and worktree
names had no convention, and Claude Code's `--worktree` defaults can express neither
convention names nor ticket-from-bundle basing — its own docs point to direct
`git worktree add`. 0015's framework stands; this record flips the recommendation and pins
the names.

## Decision

Bundle-branch is the recommended default strategy; trunk remains selectable per repo.

- Names are bundle-first, verbatim from existing artifacts: `<bundle-id>/bundle` is the
  integration branch, cut from the default branch; `<bundle-id>/ticket/<NN-slug>` is a
  ticket branch, cut from the bundle branch, its PR targeting the bundle branch.
- The bundle merges to the default branch once, at ship — squash, one revertable commit
  per bundle.
- Worktrees are one per branch at `.claude/worktrees/<branch>` — path mirrors branch
  name — created with plain `git worktree add -b`, never `WorktreeCreate` hooks; the main
  checkout stays on the default branch, never a work surface.
- The implement and ship skills own naming and cleanup; `docs/agents/git.md` stays
  minimal — declaration line, worktree location and base rule, commit and PR conventions.
- Ticket naming and worktrees apply under trunk too — tickets then cut from and PR into
  the default branch; only the bundle branch disappears.

## Rejected

- Trunk as recommended default (the incumbent, 0015): mid-bundle redirection — routine in
  agent-driven work — is multi-revert surgery entangled with main; the deploy-exposure cost
  0015 named never went away.
- Kind-first names (`bundle/<id>`, `ticket/<id>/<NN>`): collision-immune with one-glob
  kind-wide views, but the working unit is the bundle — bundle-first gives one namespace
  per bundle, which every routine operation actually wants.
- A `WorktreeCreate` hook enforcing the names: works, but replaces worktree creation
  globally, silently disables `.worktreeinclude`, and rides undocumented slash-name
  support; direct git yields identical trees.
- One shared bundle worktree, tickets switching inside: unexecutable by an agent session
  that can't see its siblings; interrupted uncommitted state ambushes the next one.
- A sibling `../<repo>.worktrees/` container: the gitignored `.claude/worktrees/` already
  hides trees from other checkouts; outside paths add an entry-approval prompt for
  portability nothing needs.

## Costs

- Late integration becomes the default cost — 0015's warning realized: drift accrues on
  the bundle branch, conflicts defer to ship, every open bundle is one more branch to sync.
- A stray branch named exactly `<bundle-id>` blocks the whole `<bundle-id>/*` namespace
  with a cryptic git error — the natural mistake is the poisonous one; kind-first was
  structurally immune.
- One squash commit per bundle makes revert all-or-nothing — keeping one good ticket of a
  bad bundle is surgery again, just relocated.
- 1+N fresh checkouts per bundle, each needing environment setup; date-prefixed branch
  names defeat prefix tab completion.

## Revisit if

- Bundle merges routinely conflict at ship when tickets ran in parallel — the
  late-integration failure realized — pushing back toward trunk or continuous syncing.
- Consuming repos keep declaring trunk anyway — the recommendation is wrong even where the
  mechanics aren't.
- Stray `<bundle-id>` branches poison the namespace in practice more than rarely —
  kind-first trades that failure away.
- Claude Code's `--worktree` learns custom branch names and base branches natively, making
  the skills' direct git commands redundant.
