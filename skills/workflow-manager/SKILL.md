---
name: workflow-manager
description: Use when the user asks for the status of work bundles or tickets, which work folder a piece of work or a backlog line belongs to, to cut, claim, or abandon a bundle or ticket branch, or to merge an accepted ticket PR — even mid-conversation without naming the skill. Not for shaping, implementing, or landing a bundle.
---

# Workflow manager

Read `references/git-mechanics.md` before cutting, claiming, landing, or abandoning.

## Path conventions

- `references/` and `scripts/` paths are relative to this skill's directory, the folder holding
  this file.
- Every other path is relative to the repository root, `git rev-parse --show-toplevel`, not the
  current directory.

## Terms

- **Workflow** — the regime as a whole: backlog, bundles, and the branches that carry them.
- **Bundle**, or work bundle — one approved outcome and its artifacts: a spec, a plan, a spike, or
  tickets, as the work requires. Its `brief.md` is the one page the human judges it from at the
  Plan gate. Lives in `work/bundles/<bundle-id>/` on the bundle's own branch, never on the
  integration target.
- **Ticket** — one approved slice of a bundle: one fresh agent session, one PR into the bundle
  branch.
- **Backlog** — `work/backlog.md`, one line per candidate work nobody has picked.
- **Member** — a workspace member: a directory the repository's workspace declaration names, or
  that the human names as one at setup.
- **Scope** — where a piece of work or a durable doc belongs: a member, or the root. A single
  project has one scope, the root.
- **Work folder** — a scope's `work/` directory, holding `backlog.md` and `bundles/`. A scope has
  one exactly when `work/bundles/` exists there, and then it owns that scope's work; setup creates
  it, nothing else does. The root always has one. Not a git worktree, which is a checkout under
  the worktree directory.
- **Bundle reference** — a bundle's path relative to its work folder: `<bundle-id>` for the root,
  `<member>/<bundle-id>` for a member, such as `apps/billing/2026-09-24-invoicing`. Every command
  and branch name takes the reference, never the bare id.
- **Integration target** — the branch a scope's bundles are cut from and land on; each scope may
  name its own.
- **Worktree directory** — where git worktrees are created, relative to the root.

## Values

**The worktree directory is fixed per repository**, under the **Worktrees** heading of
`docs/conventions/git.md`; the scripts read it themselves. A missing line is only a stderr warning
in the listing; `cut`, `claim`, and `abandon` stop on it.

```markdown
- **Worktree directory**: `.worktrees`
```

**The integration target is set per scope**, in the `## Agentic engineering workflow` section of
an `AGENTS.md`. No script reads it: you resolve it and pass it to `cut` and `check-land`.

```markdown
- **Integration target**: `main`
```

### Resolve and check the integration target

1. **Resolve it from the bundle reference.** A member reference, `<member>/<bundle-id>`, takes the
   line in `<member>/AGENTS.md`; a member whose `AGENTS.md` has no such line, and a root
   reference, take the line in the root `AGENTS.md`. Neither file holding one means setup has not
   run: say so and stop, rather than guessing a target or falling back to the default branch.
2. **Check it is on the remote**: `git ls-remote --heads origin <target>` prints one line. Empty
   output is a stop: report the file and line you read.
3. **Name it to the human** with the file it came from, such as "`app/root-cause-analysis`, from
   `apps/root_cause_analysis/AGENTS.md`". The scripts refuse a branch the remote lacks but accept
   any branch it has, so the human is the only check against an existing but wrong one; a bundle
   cut from the wrong branch lands there.

**Done when** you hold one branch that exists on the remote, and the human has seen it with its
source.

## Which work folder

**Existence decides**: a member with a work folder owns its work; one without uses the root. A
piece of work — a bundle, a backlog line, or a scan file — goes to the narrowest work folder whose scope contains
what the work is about:

- inside one member that has a work folder → that member's;
- spanning a member and the shared package it motivates → the member's, matching this
  repository's branch rule; the package commit still lands first inside it;
- inside a member without a work folder, spanning several members as peers, or touching workspace
  tooling → the root's.

Never create a work folder from here, and never write `<member>/work/` for a member that has none;
that is a setup decision. When the human asks for a bundle in such a member, say the root folder
will hold it and why, and offer `setup-workflow`.

## Bundle state

Run `scripts/bundles.sh` for every work folder and bundle, or `scripts/bundles.sh <reference>` for
one bundle and its tickets, and report the output rather than a paraphrase. Status is derived from
the remote and the forge; nothing is stored:

| Status    | Derived from                                                           |
| --------- | ---------------------------------------------------------------------- |
| `draft`   | no `bundle/<reference>` branch on the remote yet                       |
| `active`  | the bundle branch exists on the remote                                 |
| `landed`  | a merged PR from the bundle branch, into any base                      |
| `unknown` | the remote or the forge could not be queried; never read it as `draft` |

Run it from any checkout, the main one included: an active bundle's tickets are read from its
branch, not from a folder in the working tree. A landed bundle's folder is gone with its branch, so
it is listed only while a checkout still holds it. A ticket is `todo`, `doing` (a
`ticket/<reference>/<NN>` branch exists on the remote), or `done` (that branch's PR into the bundle
branch is merged).

A non-zero exit is a stop, never something to retry or work around; report its message as printed.

## Names and markers

Fixed by the workflow, not by the repository's own branch rule, so a status can be derived by
reconstructing them:

- Bundle branch: `bundle/<bundle-reference>`, cut from the integration target at shaping time, with
  the bundle's folder committed on it: `bundle/2026-09-24-invoicing` for a root bundle,
  `bundle/apps/billing/2026-09-24-invoicing` for a member's.
- Ticket branch: `ticket/<bundle-reference>/<NN>`, cut from the bundle branch, PR into the bundle
  branch; `<NN>` is the two-digit ticket number.
- Content reaches a bundle branch only through a merged ticket PR; a single-ticket bundle still gets
  its ticket branch and PR. Ticket PRs merge by squash.
- The one other write is a `bundle:` planning commit touching only the bundle's own folder and its
  work folder's `backlog.md`.

## Transitions

Cut, claim, complete, and abandon are `scripts/branch.sh` subcommands. Run the script rather than the git
commands; it checks the precondition and exits 2 with a one-line reason when one fails. Report the
reason and stop; the human decides what to do about it. Run them from the main checkout, never from
inside a worktree; the script refuses.

| Request                                  | Precondition                                                                                          | Recipe                                                 |
| ---------------------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| shape-bundle needs a branch for a bundle | bundle `draft`; the target resolved and checked as above                                              | `branch.sh cut <reference> <target>`                   |
| "claim ticket NN", "start ticket NN"     | bundle `active`; every `depends_on` ticket `done`; ticket `todo`                                      | `branch.sh claim <reference> <NN>`                     |
| "merge PR N at SHA", "complete ticket"   | the human named the PR and the accepted head SHA in this conversation                                 | `branch.sh complete <pr> <sha>`                        |
| "land bundle X"                          | every ticket `done`; the repository's canonical checks pass; the human said land in this conversation | the `land-bundle` skill                                |
| "abandon bundle X", "drop it"            | not `unknown`; the human approved the printed deletion list in this conversation                      | `branch.sh abandon <reference>`, then with `--execute` |

**Complete, land, and abandon are human gates.** Run one only on an explicit instruction naming the
PR or the bundle in this conversation, never because a status or a review looks finished. Complete
takes the head SHA the last review round judged from the human; never substitute the PR's current
head, which would merge an unreviewed push as if it were accepted. Abandon runs as a dry run first: show
the human the printed list, and pass `--execute` only after they approve it.
