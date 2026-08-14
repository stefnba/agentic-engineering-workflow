---
name: ship
description: Ship an accepted bundle — absorb what the durable docs still need from the spec, delete the bundle, merge, and confirm main green. Invoke with the bundle ID once review has approved the bundle's last PR.
argument-hint: "[bundle id]"
disable-model-invocation: true
---

# Ship one bundle

**Closer role**: the change was accepted at review — there is no new approval gate here.
What remains is mechanical: move what the durable docs still need out of the bundle, delete
it, land everything, leave main green. Stage definitions and the bundle-reference rules live
in [docs/agentic-workflow.md](../../docs/agentic-workflow.md); this skill doesn't restate
them. This runs inline, in the human's session — surface anything surprising as you go, not
in a report at the end.

## Process

### 1. Resolve the bundle and confirm it's ready

**Resolve the bundle** with `ls work/*/$ARGUMENTS*`. A single `.md` file is the whole
bundle; a directory holds `spec.md` and `tickets/`. No match or two bundles matching — ask,
don't guess.

**Confirm every ticket's frontmatter says `status: done`** (single-file bundle: its own
`status`). A ticket still `todo` or `doing` means ship is premature — stop and report which;
ship fires once per bundle, after its last PR passed the Accept gate.

**Find where ship's commits land**: read `docs/agents/git.md` for the branch strategy — a
missing file or absent declaration line means `trunk` — and list open PRs on the bundle's
branches (`<bundle-id>/NN-<slug>`, single-file: `<bundle-id>`). One open, accepted PR —
work on its branch and merge it at the land step. Everything already merged — absorb and
delete on the default branch under `trunk` (single-file bundles are always this case);
under `bundle-branch`, on `<bundle-id>/integration`, where the ticket PRs landed. An open
PR that hasn't been reviewed — stop; ship comes after Accept, and review is not yours to
skip.

### 2. Absorb

**Walk the spec section by section and route what a durable doc still needs** — the bundle
dies at the delete step, and a durable doc never references a bundle, so anything worth
keeping must move into a doc now:

- Target state no colocated README yet states → that README. Per-ticket reconcile should
  have caught most of this; ship's pass catches what slipped.
- A decision that would be expensive to relitigate → the decision skill.
- A term the work coined or renamed → the glossary skill.
- Out-of-scope items and follow-ups worth keeping → the backlog skill, one line each.

Most spec content routes nowhere — already absorbed by reconcile, or dead on delivery.
Deletion is the default; absorption is the exception that must justify itself.

Done when: grepping the bundle ID across the repo outside `work/` returns nothing — no
README, code comment, or doc references the bundle.

### 3. Delete the bundle

**`git rm -r` the bundle.** Git history keeps it — no `done/` directory, no archive copy,
no tombstone file.

### 4. Land and confirm main green

**Commit, push, and merge the PR** (no merge step when working directly on the default
branch — just push); ship's own commits follow the commit convention in
`docs/agents/git.md`.

**Under `bundle-branch` — except for a single-file bundle, which has no integration branch
to land — then land the integration branch**: open a PR from `<bundle-id>/integration` to
the default branch and merge it immediately. That PR is mechanical, not a review object —
every ticket PR already passed the Accept gate individually; the PR form exists to satisfy
protected-branch rules a direct push would violate. A merge conflict in that landing stops
ship — surface it to the human immediately; resolving it is theirs.

**Then check out the default branch, pull, and run the repo's checks** — full suite,
lint, typecheck, whatever the repo's CI runs. Done when: every check passes
on the default branch. A red default branch is this session's to surface immediately — tell
the human what broke before touching anything else.

**Then clean up merged trees and branches** per the naming in `docs/agents/git.md`:
`git worktree remove` the bundle's worktree and any of its ticket worktrees still present,
delete the bundle's branches locally and on the remote, then `git worktree prune`. Skip
what's already gone — ticket-level cleanup normally happened at each ticket merge.

**Route follow-ups noticed while shipping to the backlog skill** — the bundle's work ends
at ship; new work starts as a backlog line, not as commits here.
