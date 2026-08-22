---
name: land
description: Land an accepted bundle — absorb what the durable docs still need, reconcile the backlog, delete the bundle, land it on the integration target, and leave that target green. Invoke with the bundle ID once every ticket is done.
argument-hint: "[bundle id]"
disable-model-invocation: true
---

# Land one bundle

**You are the closer.** Every ticket in this bundle already passed the human's Accept gate, so there
is no fourth approval here — `${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md` (Human authority) says so
explicitly. What remains is: move what the durable docs still need out of the bundle, delete it, land
it, leave the integration target green.

`${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md` owns Land's steps and
`${CLAUDE_PLUGIN_ROOT}/workflow/git-mechanics.md` owns the land rules. This skill doesn't restate
them — it sequences them and says which script runs where.

You run **inline, in the human's session**, from the repository root. Surface anything surprising the
moment you hit it, not in a report at the end.

## Boundaries

- **Land's own commits carry no behavior change.** Documentation, backlog, and bundle files only. A
  change that would alter behavior is not Land work: stop and hand it back to the Plan gate as a new
  bundle, however small it looks.
- **A merge conflict is the human's**, with one exception the script already handles: a conflict in
  `work/backlog.md` is resolved by keeping both sides, which `land-bundle.sh` does itself. Anything
  else leaves the conflict in place and exits `7`. Surface it with the path and stop — a land is
  exactly where a guessed resolution is most expensive.
- **Never rebase, never squash, never force.** The ticket commits are the only bridge left from a
  landed line of code back to the ticket that approved it once the bundle is gone.
- **Deletion is the default; absorption is the exception that must justify itself.** Most of a spec
  routes nowhere — reconcile already absorbed it, or it was dead on delivery.

## Process

### 1. Resolve the bundle and open the land

Resolve `$ARGUMENTS` against `${CLAUDE_PROJECT_DIR}/work/bundles/`. No match, or two matching — ask,
don't guess.

Then run, from the repository root:

```text
${CLAUDE_PLUGIN_ROOT}/scripts/land-bundle.sh start <bundle-id>
```

It gates the whole stage: every ticket `done` from its PR record, no stale land worktree, then a
detached worktree on the integration target with the bundle branch merged in. **Every step below
happens in the worktree it prints** — that tree is where the checks run and what gets published.

Read a non-zero exit as a stop, not as something to work around: its message states the reason and
the next action — report it, and leave anything it says is in the way to the human. One code routes
instead of stopping: `4` means a single-ticket bundle with no branch to land, so steps 2–4 commit in
this checkout and push.

### 2. Absorb what the durable docs still need

Walk the spec section by section. The bundle dies two steps from here and no durable doc may reference a
bundle, so anything worth keeping moves **now** or is lost:

- target state no colocated `README.md` yet states → that README
- a decision that would be expensive to relitigate → the `record-decision` skill
- a term this work coined, renamed, or disambiguated → the `glossary` skill

Per-ticket reconcile should have caught most of this; this pass catches what only became true once
every ticket had landed.

**Done when** grepping the bundle ID across the repository outside `work/` returns nothing.

### 3. Reconcile the backlog

Unfinished scope, deferred ideas, and anything you noticed while landing → the `backlog` skill, one
line each. New work starts as a backlog line, never as commits here.

**Then retire what this bundle made true**, through that skill's prune scoped to this bundle: lines
whose work now exists, and lines the previous step absorbed into a durable doc. The picked line is
already gone — `shape` deleted it when it published — so what's left here is every _other_ line this
work overtook.

### 4. Delete the bundle

`git rm -r` the bundle directory. Git history is the archive — no `done/`, no tombstone, no copy
under another name (`${CLAUDE_PLUGIN_ROOT}/workflow/artifacts.md`).

Commit steps 2–4 following `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md`.

### 5. Re-verify, then land

Run the repository's canonical checks **in the land worktree** — full suite, lint, typecheck,
whatever CI runs. This state carries your commits and the bundle merge, so no CI run has seen it.
Red means stop and report; nothing is pushed yet, so abandoning costs a directory.

Green, then:

```text
${CLAUDE_PLUGIN_ROOT}/scripts/land-bundle.sh push <bundle-id>
```

**Exit `6` is not a failure — it is the loop.** The integration target moved while you were working,
so `push` merged it in and stopped. Go back to the top of this step, re-run the canonical checks
against the new state, and run `push` again. Repeat until it exits `0`. Never push past a `6`: the
merged state is one no check has run against, which is the whole reason the script refuses to
publish it for you.

### 6. Remove the leftovers

```text
${CLAUDE_PLUGIN_ROOT}/scripts/land-bundle.sh cleanup <bundle-id>
```

Ticket branches, the bundle branch, every worktree — Land's own last, and from the repository root.
Branches a forge already deleted on merge are skipped, not treated as an error.

### 7. Hand back

**Query the end state before reporting it.** `cleanup` exiting `0` proves it ran, not that nothing
survived it — a branch the forge already removed and a branch it refused to remove both leave that
exit code, and `git worktree remove` deletes the leaf it was given while its parent directories
stay. Run these from the repository root and report what they return, not what you expected:

```text
. ${CLAUDE_PLUGIN_ROOT}/scripts/_config.sh   # for $WORKTREE_DIR
git fetch --prune origin && git ls-remote --heads origin       # ticket and bundle branches
git worktree list                                              # every registered worktree
find "$WORKTREE_DIR" -mindepth 1                               # directories git no longer tracks
ls work/bundles/                                               # the bundle itself
```

Then fill every slot — an empty one says `none`, because a missing line reads as forgotten:

```text
Landed     <bundle-id> on <target> at <sha>
Absorbed   <what moved, into which doc>
Backlog    +<lines added>  −<lines retired>
Removed    branches ✅  worktrees ✅  bundle ✅
Surfaced   <what you hit and handed back rather than resolved>
```

A ✅ is the query's answer, so it is yours to withhold: replace any that is not clean with what is
still there and why, and route it through the `backlog` skill when it is a gap rather than a one-off.
`${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md`'s Land Done-when is what these queries test.
