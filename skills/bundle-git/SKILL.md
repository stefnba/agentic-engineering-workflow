---
name: bundle-git
description: Create, inspect, or tear down a bundle's git surface — its branches and worktrees. The implement skill invokes it to open a ticket's branch and worktree, the ship skill to enumerate and then delete the bundle's branches after landing. Also invoke standalone whenever bundle git state needs eyes — an interrupted session left worktrees or branches behind, the user asks what branches or worktrees a bundle has or to clean them up, branch creation fails with "cannot lock ref", or a tree under .claude/worktrees/ is in doubt — even if the user doesn't say "bundle".
argument-hint: "<open|close|check> [bundle id] [ticket NN]"
---

# Bundle git surface

**Caretaker role**: every branch and worktree a bundle produces is created, judged, and
deleted here — the stage skills delegate so the create rules and the delete rules cannot
drift apart. The commit and PR conventions in `docs/agents/git.md` are the callers'
business, not this skill's.

## Startup — every invocation, before any operation

1. **Read the declarations** in `docs/agents/git.md`: the `Branch strategy:` line — a
   missing file or absent line means `trunk` — and the Worktrees `Location`, called
   `<location>` below — absent means `.claude/worktrees/`.
2. **Resolve the bundle** with `ls work/*/<bundle-id>*`. Two matches: stop and ask. No
   match is normal for `close` and `check` — the bundle directory dies at ship before
   its branches do — so derive the shape from the refs instead: `<bundle-id>/*` refs
   mean a directory bundle, a bare `<bundle-id>` ref a single-file one. No match at
   `open`: stop and ask — open needs the ticket file to exist.
3. **Derive the expected surface** from the derivation table below.
4. **List the actual state**: `git branch --list '<bundle-id>' '<bundle-id>/*'`, the
   same patterns against `-r`, and `git worktree list` filtered to
   `<location>/<bundle-id>`.
5. **Classify each ticket branch with its tree** per the classification table below. The
   bundle branch is judged by the operation steps, not the table — between ships it
   always carries commits with no PR, which is its normal state, not an anomaly.

Done when: every existing branch and tree carries a class, and the operation knows which
expected pieces are absent.

### Derivation table

| Fact           | Derivation                                                                                                                          |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Default branch | `git symbolic-ref --short refs/remotes/origin/HEAD`, minus `origin/`                                                                |
| Bundle shape   | a directory with `tickets/` is a directory bundle; a single `.md` file is a single-file bundle                                      |
| Bundle branch  | `<bundle-id>/bundle` — exists only for a directory bundle under `bundle-branch`; cut from the default branch                        |
| Ticket branch  | `<bundle-id>/ticket/<NN-slug>`, `NN-slug` being the ticket filename minus `.md`; a single-file bundle gets one branch `<bundle-id>` |
| Base           | what a branch is cut from and PRs into: ticket branch → the bundle branch under `bundle-branch`, else the default branch            |
| Worktree       | `<location>/<branch>` — the path mirrors the branch name exactly                                                                    |

### Namespace guards

**Never create a branch named bare `<bundle-id>` for a directory bundle.** Git forbids a
branch `x` beside `x/y`, so that single ref blocks the entire `<bundle-id>/*` namespace —
the fixed `/bundle` leaf exists precisely to keep the bare name free of refs.

**The bundle ID and ticket filenames freeze when the first branch is cut.** Branch and
worktree names derive from them, so a later rename orphans git state silently. Renaming
requires `close` first, then the rename, then a fresh `open`.

### Classification table

| Class       | Test                                                                                                                                                                | `open` reacts                                                                                                                      | `close` reacts |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | -------------- |
| `merged`    | its PR into its base is merged — check `gh pr list --head <branch> --state merged`; squash landing leaves no merge ancestry, so `git branch --merged` cannot see it | sweep: remove tree, `git branch -D` — `-d` refuses squash-landed branches for the same ancestry reason; the PR check is the safety | sweep          |
| `open-pr`   | an open PR on the branch                                                                                                                                            | leave it                                                                                                                           | **halt**       |
| `in-flight` | uncommitted changes, or commits with no PR                                                                                                                          | leave a sibling ticket's — parallel tickets run in sibling worktrees; **halt** on this ticket's own                                | **halt**       |
| `poisoned`  | a bare `<bundle-id>` ref beside a directory bundle                                                                                                                  | **halt**                                                                                                                           | **halt**       |
| `orphan`    | no matching ticket file though the bundle dir exists                                                                                                                | **halt**                                                                                                                           | **halt**       |

`check` reacts to nothing — it only reports (see Exit).

## Operations

### open <bundle-id> [ticket NN] — implement's entry

**Every branch and worktree this operation creates uses this plain-git command** —
`git.md`'s Worktrees section owns the no-hooks rule:

```bash
git worktree add -b <branch> <location>/<branch> <base>
```

1. **Sweep and guard**: delete `merged` leftovers; halt per the table — this ticket's
   own prior state belongs to an interrupted session: surface it, don't rebuild over it.
2. **Ensure the bundle branch** — directory bundle under `bundle-branch` only. Create it
   in its worktree if absent; halt if its worktree is dirty; if it has fallen behind the
   default branch, merge the default branch into it from its own worktree — drift is
   paid per ticket, not all at once at ship. A conflict in that merge is decision drift:
   stop and put it to the human.
3. **Create the ticket's branch and worktree** from its base, with the command above.

Done when: the ticket's worktree exists on a fresh branch.

### close <bundle-id> — ship's exit, after the bundle has landed

1. **Verify everything is `merged`** — every ticket branch's PR into its base, and the
   bundle branch's landing PR into the default branch, checked via `gh` per the
   classification table, never via ancestry — squash merges leave none. Anything else
   halts; at ship that is the human's to resolve, immediately.
2. **Tear down**: `git worktree remove` each of the bundle's trees, delete each branch
   locally and on the remote, `git worktree prune`. Skip what's already gone.

Done when: `git branch --list '<bundle-id>*'` — remotes included — is empty and
`<location>/<bundle-id>` does not exist. Merging PRs and deleting the bundle directory
are ship's steps, never this skill's.

### check [bundle-id] — read-only, safe anytime

**With an ID**: inspect that one bundle. **Without one**: sweep all bundle namespaces —
`git branch --list '*/bundle' '*/ticket/*'`, bare date-slug refs (single-file bundles:
`git branch --list '20??-??-??-*'`), plus every tree under `<location>/` — and classify
each against `work/`.

**Check never mutates.** Even an obviously safe sweep is reported as a suggested `open`
or `close`, not performed — that guarantee is what makes it safe to run mid-incident.

## Exit — every invocation ends in a report

- **`open` succeeded**: the worktree path and the base branch — the caller works in that
  path and its PR targets that base.
- **`close` succeeded**: confirmation that the branch list and `<location>/<bundle-id>`
  are empty.
- **`check`**: the declared strategy, the derived branch map, and every actual branch
  and worktree with its class — for each anomaly, the one-line fix. A whole namespace
  whose bundle directory is gone gets the fix `close <bundle-id>`.
- **Any halt**: each item, its class, and the one-line fix, then stop — a `poisoned`
  ref's fix is `git branch -m <bundle-id> <intended-name>`, which name was intended
  being the human's call. Deleting dirty or unmerged state to make a command succeed
  destroys the only copy of a session's work.
