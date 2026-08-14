---
name: bundle-git
description: Create, inspect, or tear down a bundle's git surface — its branches and worktrees. The implement skill invokes it to open a ticket's branch and worktree, the ship skill to enumerate and then delete the bundle's branches after landing. Also invoke standalone whenever bundle git state needs eyes — an interrupted session left worktrees or branches behind, the user asks what branches or worktrees a bundle has or to clean them up, branch creation fails with "cannot lock ref", or a tree under .claude/worktrees/ is in doubt — even if the user doesn't say "bundle".
argument-hint: "<open|close|check> [bundle id] [ticket NN]"
---

# Bundle git surface

**Caretaker role**: every branch and worktree a bundle produces is created, judged, and
deleted here — the stage skills delegate so the create rules and the delete rules cannot
drift apart. This skill reads the strategy declaration in `docs/agents/git.md`; the
commit and PR conventions there are the callers' business, not this skill's.

## Derivation — names are computed, never invented

**Read `docs/agents/git.md`** and take two declarations: the `Branch strategy:` line — a
missing file or absent line means `trunk` — and the Worktrees `Location` — absent means
`.claude/worktrees/`; `<location>` below. **Resolve the bundle** with
`ls work/*/<bundle-id>*`. Everything else derives:

| Fact           | Derivation                                                                                                                          |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Default branch | `git symbolic-ref --short refs/remotes/origin/HEAD`, minus `origin/`                                                                |
| Bundle shape   | a directory with `tickets/` is a directory bundle; a single `.md` file is a single-file bundle                                      |
| Bundle branch  | `<bundle-id>/bundle` — exists only for a directory bundle under `bundle-branch`; cut from the default branch                        |
| Ticket branch  | `<bundle-id>/ticket/<NN-slug>`, `NN-slug` being the ticket filename minus `.md`; a single-file bundle gets one branch `<bundle-id>` |
| Base           | what a branch is cut from and PRs into: ticket branch → the bundle branch under `bundle-branch`, else the default branch            |
| Worktree       | `<location>/<branch>` — the path mirrors the branch name exactly                                                                    |

**Create with plain git** — `git.md`'s Worktrees section owns the no-hooks rule:

```bash
git worktree add -b <branch> <location>/<branch> <base>
```

Two rules guard the namespace:

**Never create a branch named bare `<bundle-id>` for a directory bundle.** Git forbids a
branch `x` beside `x/y`, so that single ref blocks the entire `<bundle-id>/*` namespace —
the fixed `/bundle` leaf exists precisely to keep the bare name free of refs.

**The bundle ID and ticket filenames freeze when the first branch is cut.** Branch and
worktree names derive from them, so a later rename orphans git state silently. Renaming
requires `close` first, then the rename, then a fresh `open`.

## Classify before touching anything

Every operation starts identically: **list the bundle's actual state** —
`git branch --list '<bundle-id>' '<bundle-id>/*'`, the same patterns against `-r`, and
`git worktree list` filtered to `<location>/<bundle-id>` — **and classify each branch
and tree**:

| Class      | Test                                                                   | Reaction             |
| ---------- | ---------------------------------------------------------------------- | -------------------- |
| `expected` | matches derivation; open PR or currently in flight                     | leave it             |
| `merged`   | branch fully merged into its base, PR closed                           | delete branch + tree |
| `dirty`    | worktree with uncommitted changes (`git status --porcelain` non-empty) | **halt**             |
| `unmerged` | commits its base lacks, and no open PR                                 | **halt**             |
| `poisoned` | a bare `<bundle-id>` branch beside a directory bundle                  | **halt**             |
| `orphan`   | branch or tree matching no existing bundle artifact                    | **halt**             |

**Heal only the `merged` class; halt and report every other anomaly** — name each item,
its class, and the one-line fix (a `poisoned` ref's fix is
`git branch -m <bundle-id> <intended-name>`; which name was intended is the human's
call). Deleting dirty or unmerged state to make a command succeed destroys the only copy
of a session's work.

## Operations

### open <bundle-id> [ticket NN] — implement's entry

1. **Derive and classify.** Sweep `merged` leftovers; halt on anything worse.
2. **Ensure the bundle branch** (directory bundle under `bundle-branch` only): create it
   in its worktree if absent; if present and behind the default branch, merge the
   default branch into it from its own worktree — drift is paid per ticket, not all at
   once at ship. A conflict in that merge is decision drift: stop and put it to the
   human.
3. **Create the ticket's branch and worktree** from its base. The branch must not exist
   yet — an existing one is `unmerged` or `orphan` state the classify step catches.
4. **Report the worktree path and the base branch** — the caller works in that path and
   its PR targets that base.

Done when: the ticket's worktree exists on a fresh branch and the report names path and
base.

### close <bundle-id> — ship's exit, after the bundle has landed

1. **Classify.** Every branch must be `merged` — the bundle branch into the default
   branch. Anything `dirty` or `unmerged` halts; at ship that is the human's to resolve,
   immediately.
2. **Tear down**: `git worktree remove` each of the bundle's trees, delete each branch
   locally and on the remote, `git worktree prune`. Skip what's already gone.

Done when: `git branch --list '<bundle-id>*'` — remotes included — is empty and
`<location>/<bundle-id>` does not exist. Merging PRs and deleting the bundle
directory are ship's steps, never this skill's.

### check [bundle-id] — read-only, safe anytime

**With an ID**: report the declared strategy, the derived branch map, and every actual
branch and worktree with its class — for each anomaly, the fix. **Without one**: sweep
all bundle namespaces — `git branch --list '*/bundle' '*/ticket/*'` plus every tree
under `<location>/` — and classify each against `work/`.

**Check never mutates.** Even an obviously safe sweep is reported as a suggested `open`
or `close`, not performed — that guarantee is what makes it safe to run mid-incident.
