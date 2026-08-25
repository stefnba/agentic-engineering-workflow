---
name: abandon-bundle
description: Abandon a bundle that will never land — discard every ticket branch and worktree, the bundle branch, and the published bundle directory. Invoke with the bundle ID once the human has decided not to finish it, whatever tickets are done, doing, or todo.
argument-hint: "[bundle id]"
disable-model-invocation: true
---

# Abandon one bundle

**The human invoking this skill is the decision.** Nothing here infers that a bundle should be
dropped — it only executes a choice already made. Read
`${CLAUDE_PLUGIN_ROOT}/workflow/git-mechanics.md` (Abandoning a bundle) first; this skill sequences
its rule, it doesn't restate it.

You run **inline, in the human's own session**, in the main checkout, on the integration target
— the same checkout Shape publishes from.

## Boundaries

- **Nothing here has ever reached the target.** Every ticket PR merges only into the bundle branch,
  never the integration target, until Land — so abandoning is safe at any point and never needs a
  merge or a revert on the integration target itself.
- **Show the state before discarding it.** The human names the bundle; you show what abandoning it
  actually throws away before you throw it away.
- **This is not `land-bundle.sh cleanup`.** Cleanup runs after a land and refuses to touch a branch
  that isn't merged yet, because that branch is live work someone still owns. Abandon is the
  opposite case: it deletes every ticket branch regardless of status, because discarding in-flight
  work is the point.
- **The bundle directory's removal is a real commit, never a silent disappearance or a rewrite of
  the publish commit.** Land deletes a bundle with a `bundle` commit when it ships; abandon deletes
  one with a `bundle` commit when it doesn't. Same mechanism, opposite ending — never a revert of
  Shape's publish commit, which stays in history as what was approved.

## Process

### 1. Resolve the bundle and show what's at stake

Resolve `$ARGUMENTS` against `${CLAUDE_PROJECT_DIR}/work/bundles/`. No match, or two matching — ask,
don't guess.

Run and show the human, before anything else:

```text
${CLAUDE_PLUGIN_ROOT}/scripts/bundle-status.sh <bundle-id>
```

This is the confirmation — a real, per-ticket state listing, not a generic prompt. If a ticket reads
`done`, its accepted work exists only on the bundle branch and is about to be discarded; say so
plainly before continuing.

### 2. Delete the branches and worktrees

```text
${CLAUDE_PLUGIN_ROOT}/scripts/abandon-bundle.sh <bundle-id>
```

Read a non-zero exit as a stop, not as something to work around: its message states the reason and
the next action. Exit `9` means this bundle already landed — it is `land-bundle.sh cleanup`'s job,
not this one; report it and stop rather than forcing the delete.

### 3. Delete the published bundle and commit it

From the main checkout's root, on the integration target:

```text
git rm -r work/bundles/<bundle-id>
```

Commit and push directly, per `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md` — the reserved
`bundle` commit type, scopeless, touching only this directory. This is a planning commit, the same
kind Shape's publish already is: committed directly to the target, never through a PR.

### 4. Hand back

Report what `abandon-bundle.sh` printed, the commit that removed the bundle directory, and any
ticket that was `done` before step 2 — the work it carried is gone with the branch, not archived
anywhere else. Then stop.
