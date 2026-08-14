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

**Find where ship's commits land**: invoke the `bundle-git` skill — `check <bundle-id>` —
for the declared strategy and the bundle's branch map (a halt-worthy anomaly in its report
stops ship here), then list open PRs on those branches. One open, accepted PR —
work on its branch and merge it at the land step. Everything already merged — absorb and
delete on the default branch under `trunk` (single-file bundles are always this case);
under `bundle-branch`, on the bundle branch from check's map, where the ticket PRs
landed. An open
PR that hasn't been reviewed — stop; ship comes after Accept, and review is not yours to
skip.

**Confirm every ticket's frontmatter says `status: done` — read on the branch ship works
on, just found above; the default branch's copy lags until ship lands** (single-file
bundle: its own `status`). A ticket still `todo` or `doing` means ship is premature — stop
and report which; ship fires once per bundle, after its last PR passed the Accept gate.

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

**Under `bundle-branch` — except for a single-file bundle, which has no bundle branch
to land — then land the bundle branch**: open a PR from it to
the default branch and merge it immediately. That PR is mechanical, not a review object —
every ticket PR already passed the Accept gate individually; the PR form exists to satisfy
protected-branch rules a direct push would violate. A merge conflict in that landing stops
ship — surface it to the human immediately; resolving it is theirs.

**Then check out the default branch, pull, and run the repo's checks** — full suite,
lint, typecheck, whatever the repo's CI runs. Done when: every check passes
on the default branch. A red default branch is this session's to surface immediately — tell
the human what broke before touching anything else.

**Then invoke the `bundle-git` skill — `close <bundle-id>` — to tear down the bundle's
branches and worktrees.** It deletes only fully merged state; a halt on anything dirty
or unmerged is the human's to resolve — surface it immediately, don't force the
deletion.

**Route follow-ups noticed while shipping to the backlog skill** — the bundle's work ends
at ship; new work starts as a backlog line, not as commits here.
