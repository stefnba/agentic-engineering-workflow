---
date: 2026-08-20
status: accepted
areas: [workflow, skills]
supersedes:
  [2026-08-10-bundle-status-lives-in-the-directory.md](./2026-08-10-bundle-status-lives-in-the-directory.md)
  entirely; the `candidates/ planned/ active/` directory list in
  [2026-08-10-work-items-live-at-the-repo-root.md](./2026-08-10-work-items-live-at-the-repo-root.md);
  the branch-strategy declaration in
  [2026-08-13-git-conventions-are-a-per-repo-file.md](./2026-08-13-git-conventions-are-a-per-repo-file.md);
  and [2026-08-14-bundle-branch-is-the-recommended-default.md](./2026-08-14-bundle-branch-is-the-recommended-default.md)
  entirely — its recommendation and its branch names alike
---

# Execution state is derived from git, never declared or stored

## Context

Three separate things were declarable: a bundle's status by which directory held it, a ticket's
status by its frontmatter, and the branch strategy by a line in a per-repo file. Each needed a write
to stay true, and every write could be skipped, lost in a merge, or land on a branch the reader
wasn't on — 0016 conceded the point itself, noting the default branch's copy of `work/` lags until
ship. A ticket that reads `todo` because its `doing` write never reached the reader is what lets a
dependent ticket start early.

## Decision

Nothing about a bundle's execution is written down. Every status is computed from remote refs and PR
merge records on each query.

- ticket `doing`: its branch exists on the remote. `done`: its PR merged into that ticket's target.
  `todo`: neither. Claiming a ticket _is_ creating its branch, so git serializes competing claims.
- bundle `shaped`: it exists under `work/bundles/` with no ticket claimed. `active`: at least one
  ticket is no longer `todo`. The bundle path never moves.
- Branch strategy derives from ticket count: more than one ticket gets a bundle branch, a
  single-ticket bundle's PR targets the integration target.
- Branch names are fixed by the workflow and kind-first: `bundle/<bundle-id>`,
  `ticket/<bundle-id>/<NN>`.
- A query that cannot reach the forge reports `unknown`, never `todo`.

## Rejected

- **Directory-as-status for bundles (0004)**: a `git mv` is atomic but it is still a write, on one
  branch, that the ticket needing it may not see.
- **Ticket status in frontmatter (0004)**: two writers — the merge and the file — for one fact, and
  the file is the one that can be wrong.
- **A declared branch strategy (0015, 0016)**: a declaration only relocates the problem; every
  script still has to agree with it, and a repo that loses the file gets a silent fallback.
- **Bundle-first branch names (0016)**: one namespace per bundle is convenient, but a stray branch
  named exactly `<bundle-id>` poisons the whole `<bundle-id>/*` namespace.

## Costs

- Every status query costs a fetch and a forge round trip; nothing answers offline.
- An unreachable forge makes status unknowable rather than merely stale, and `unknown` blocks a
  claim exactly as an unfinished dependency does.
- The branch names are now load-bearing byte for byte — a consumer that renamed them would see a
  claimed ticket read `todo`.
- Kind-first names give up the one-glob-per-bundle view 0016 chose bundle-first for.

## Revisit if

- Forge round trips dominate a session's latency badly enough that a cache earns its staleness.
- A repository needs a branch strategy the ticket count cannot express.
