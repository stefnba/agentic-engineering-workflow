---
date: 2026-08-20
status: accepted
areas: [workflow, skills]
supersedes: the reconciliation direction in
  [2026-08-18-fixed-bundle-land.md](./2026-08-18-fixed-bundle-land.md), which had Land merge the
  integration target into the bundle branch
---

# Land works in a detached worktree on the integration target

## Context

`workflow/bundle.md` said nothing is ever edited on the bundle branch, so it gets no worktree — while
`workflow/lifecycle.md` had Land reconcile, drain, delete, merge and re-verify there, the last of
those requiring a tree on disk. Nothing named who holds one, and no script did.

A first pass answered "a worktree on the bundle branch". Reproducing the sequence against real git
showed that answer manufactures two conflicts, both at the step where the moved integration target is
merged back into the bundle branch:

- a bundle republished mid-execution collides `CONFLICT (modify/delete)` against Land's deletion
  commit;
- a backlog line appended by any other session collides `CONFLICT (content)` against Land's drain
  commit.

A control run with the target moving outside `work/bundles/` merges clean, so the conflicts are
caused by the merge direction, not by Land's own commits.

## Decision

Land checks out the commit `origin/<integration-target>` points at, detached, at
`$WORKTREE_DIR/land/<bundle-id>`; merges `bundle/<bundle-id>` **into** it; reconciles, drains,
deletes and re-verifies there; and publishes with `git push origin HEAD:<integration-target>`.

- **The bundle comes to the target, never the reverse.** Both conflicts above disappear, because
  nothing has to travel backwards into a branch that just deleted the bundle. Verified with both
  hazards present at once: clean merge, clean push.
- **Detached is forced, not stylistic.** The session's own checkout already holds the integration
  target, and `git worktree add <path> main` fails with `'main' is already used by worktree`.
- **Nothing is named until the push.** A canonical check that fails leaves a directory to delete;
  the session's checkout and the remote target are both untouched.
- One merge commit on the target instead of two. First-parent history stays linear, ticket commits
  survive, and `git blame` still reaches the ticket that approved a line.
- A single-ticket bundle has no bundle branch, so Land's commits go to the session's own checkout.

## Rejected

- **A worktree on the bundle branch.** The original answer. Rejected on the reproduction above.
- **Switch the session's own checkout to the bundle branch.** All `bundle-git` scripts read
  `work/bundles/<id>/` from the tree they run in, so branch strategy and the dependency gate would
  derive from a different copy of the bundle than the one the session believes it has.
- **Do Land in the session's own checkout of the integration target.** Same merge direction, no
  worktree, but a check that fails leaves a half-landed target in the human's working directory,
  recoverable only by `git reset --hard`. This is the cost the detached worktree buys off, and the
  reason the earlier draft rejected "Land on the integration target" was this — it did not separate
  the merge direction from where the tree lives.
- **Plumbing with no checkout** (`git commit-tree`, `git push`). Cannot run canonical checks, which
  need a tree on disk.

## Costs

- **A failed land leaves a worktree behind.** `land-bundle.sh start` refuses on one, exit `5`, the
  way `claim-ticket.sh` already refuses a stale ticket worktree.
- **The publish can lose a race.** Another session pushing first gets `! [rejected]
  (non-fast-forward)`. `land-bundle.sh push` merges the target in and exits `6` rather than pushing,
  forcing the canonical checks to re-run against a state no check has seen. That loop is the price of
  not gating on branch protection, which `skills/setup/references/prerequisites.md` routes protected
  repositories away from.
- **Land's own commits sit outside the bundle merge**, as first-parent commits on the target, rather
  than arriving inside it. The old step 4 rationale — deleting on the bundle branch "so the land
  carries a bundle-free state onto the integration target" — no longer applies and was rewritten.
- `WORKTREE_DIR` now holds two kinds of worktree: ticket worktrees mirroring a branch name, and one
  land worktree under `land/` that mirrors nothing.
- Removing the worktree last and from outside it is an ordering constraint that reads like a
  footnote and is load-bearing; `land-bundle.sh cleanup` refuses to run from inside it.

## Revisit if

- Canonical checks become runnable against a remote ref without a working tree — plumbing then wins
  on every axis.
- Land needs to write something a ticket PR could have written instead, which would mean the
  invariant is what's wrong, not the worktree.
