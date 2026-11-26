---
name: land-bundle
description: Use when the human asks to land, ship, or finish a work bundle whose tickets have all merged — "land bundle X", "ship the bundle", "the last ticket merged, what now" — and to clean up after its bundle PR has merged. Takes a bundle reference. Not for merging one ticket's PR, and not for abandoning an unfinished bundle.
argument-hint: '[bundle reference]'
---

# Land bundle

Land one accepted bundle: fold what it settled into the durable docs, delete it, and open the PR
that takes its branch into the integration target; once the human has merged that PR, remove what
is left. Land holds no gate of its own — every ticket was accepted at its merge — so its own
commits touch docs, the backlog, and the bundle folder only, and they reach the branch with no
review of their own: the human reviews them at the bundle PR, which lists them under its section
`Commits no ticket review covered`.

`<target>` is the integration target the check-the-integration-target step resolves, and
`<worktree dir>` the worktree directory in `docs/conventions/git.md`; `<reference>` is the bundle reference, `<bundle-id>` or
`<member>/<bundle-id>`, and `<work folder>` its work folder, `work` or `<member>/work`.

## Path conventions

- `scripts/` paths are the `workflow-manager` skill's: load that skill by name before the first
  step to find its directory.
- Every other path is relative to the repository root, `git rev-parse --show-toplevel`, not the
  current directory.

## Guardrails

- **Land only on the human's instruction naming this bundle in this conversation**, never because
  every ticket reads `done`.
- **Change no behavior.** A land step that would need a code change is not Land work: stop and hand
  it back to the human, who takes it to `sweep-bundle` or shapes it as a new bundle.
- **Stop for the human on every merge conflict except one**: in a `work/backlog.md`, keep both
  sides.
- **Never force-push.** A rejected push means someone else pushed first; fetch and stop.

## Process

### 1. Check the integration target

**When the bundle PR has already merged, go to the clean-up step**; the target no longer matters.
This prints its number then:

```bash
gh pr list --head bundle/<reference> --state merged --json number -q '.[].number'
```

**Resolve and check the integration target the bundle's reference takes**, following the
`workflow-manager` skill's Resolve and check the integration target steps, and name it to the human
with its source before any other step. Every later `<target>` is this branch: `check-land` counts
from it, the bundle branch merges it in, and the bundle PR targets it.

**When a bundle PR is already open, its base must be this target.** This prints the base:

```bash
gh pr list --head bundle/<reference> --state open --json baseRefName -q '.[].baseRefName'
```

A different base is a stop: name both branches, because the `AGENTS.md` line or the PR is wrong
and only the human knows which.

**Done when** the human has seen the target and its source, it exists on the remote, and no open
bundle PR has another base.

### 2. Check the bundle is ready

**When review findings on the bundle's own files are still open, ask about a sweep before the
readiness checks.** Findings are open when this conversation, or a ticket PR's review thread, names
a defect in what the bundle shipped that no merged ticket fixed. List them and ask the human to
choose: a sweep ticket through the `sweep-bundle` skill, after which Land waits for that ticket to
be `done`, or backlog lines through the `backlog` skill.

Work in the bundle branch's worktree, `<worktree dir>/bundle/<reference>`. When it is missing, add
it from the main checkout: `git worktree add <worktree dir>/bundle/<reference> bundle/<reference>`.

**When an earlier land run already committed on the bundle branch, resume** at the first step whose
Done when does not hold, and skip the two checks below: `check-land` would name Land's own
commits, and `bundles.sh` needs the bundle folder the delete step removes.

From the bundle worktree, run `scripts/bundles.sh <reference>`. A ticket not `done` is a stop: name
it. A spike bundle has no tickets.

Then run `scripts/branch.sh check-land <reference> <target>`. Exit 2 names a commit that reached
the bundle branch without a ticket PR; stop and report it. When it names many commits nobody
recognizes, suspect the target first: they are what the target lacks.

A non-zero exit from either script is a stop: report its message as printed.

**Done when** the bundle is `active`, every ticket is `done`, and `check-land` exits 0.

### 3. Fold the bundle into the durable docs

Read the whole bundle, then, in the bundle worktree:

1. Hand every plan decision tagged `(decision record at Land)` to the `record-decision` skill;
   it applies its own bar, so a tagged decision may come back routed to a doc instead of a record.
2. Update what the bundle made true that no ticket's PR owned — its plan's Reconciliation targets
   that name no slice, and knowledge that only holds now that every ticket has merged — through
   the `write-architecture-doc` and `glossary` skills, including any _(planned)_ mark in
   `ARCHITECTURE.md` the bundle built.
3. For a spike, route each result to the owner its Where the answer lands section names.
4. Through the `backlog` skill, retire the lines the bundle's work made true, and add the work it
   left unfinished or discovered.

Commit each with the type and scope `docs/conventions/git.md` gives it.

**Done when** nothing in the bundle that must outlive it exists only in the bundle.

### 4. Delete the bundle

```bash
git rm -rq <work folder>/bundles/<bundle-id> && git commit -m "bundle: land bundle <bundle-id>"
```

Record this commit's parent — `git rev-parse HEAD~1` — as the last commit that holds the bundle.

**Done when** the bundle folder is gone in its own commit.

### 5. Bring in the target and re-verify

```bash
git fetch -q origin <target> && git merge --no-edit origin/<target>
make lint typecheck test
```

The merge is a no-op when the bundle branch already contains the target. A failing check is a
stop: report it, because fixing it is code, not Land work. Push with
`git push origin bundle/<reference>`.

**Done when** the bundle branch contains the current target, the checks pass on it, and it is
pushed.

### 6. Open the bundle PR

Create the `bundle` label when the forge has none: `gh label create bundle` fails harmlessly when
it exists.

**Run the `write-pr` skill with base `<target>`** from the bundle worktree; it recognizes the
bundle branch, labels the PR, and links the bundle at the parent of the commit that deleted it.

**Write the squash commit's body from the PR you just opened**, filling this skeleton and deleting
its comments as you fill; never hand back the PR body as the commit body, since GitHub rewraps it
at 72 columns and breaks its tables. Wrap every line at 72 columns except the `Bundle:` line.

```text
<!-- The PR's Summary sentence, verbatim, without the bullets under it. -->
<Summary sentence>

<!-- One bullet per top-level bullet of the PR's Delivered section, in its order, without its
requirement IDs and without its sub-bullets. A wrapped bullet continues indented two spaces. -->
- <what is now true>

Tickets:
<!-- One line per entry of the PR's Commits section, in its order: the PR number and title, without
the merge sha, which never reaches the target. -->
- #<n> <title>

<!-- The URL of the footer's Bundle link. -->
Bundle: <permalink>
```

**Hand back the PR and the commits its section `Commits no ticket review covered` lists.**

**Tell the human to merge it by squash with that body**, in two forms: this command, and the body
alone, to paste into GitHub's merge box. Take the head sha from
`gh pr view <n> --json headRefOid -q .headRefOid`; with it, GitHub refuses the merge after a later
push.

```bash
gh pr merge <n> --squash --match-head-commit <head sha> --body "$(cat <<'EOF'
<the body>
EOF
)"
```

**Done when** the PR is open, the body has one bullet per top-level Delivered bullet and one
`Tickets:` line per `Commits` entry, no placeholder or comment is left, and the human has both
forms. Stop there.

### 7. Clean up after the merge

Confirm the bundle PR merged with the `gh pr list` command in the check-the-integration-target
step; when it prints nothing, stop — the bundle is not landed. From the main checkout, run
`scripts/branch.sh abandon <reference>`. Its first line must read `<reference> is landed`; anything
else is a stop, because abandon on an unlanded bundle deletes its work. Show the human the printed
list, and on their approval run it again with `--execute`: it removes the leftover bundle and
ticket worktrees and branches.

**Done when** the script reports nothing left to remove, or the human declined.
