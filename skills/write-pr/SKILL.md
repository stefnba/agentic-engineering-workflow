---
name: write-pr
description: Use when a branch needs a pull request opened, or an open PR's body brought up to date with a new head — "open a PR", "create a pull request", "push and open a PR", "write the PR description", "update the PR body", after a fix round moves the head, even when asked together with the commit — and for the PR the implement-ticket skill opens for a ticket. Takes an optional base branch and an optional ticket reference. Not for reviewing a PR, and not for merging one.
argument-hint: '[base branch] [bundle reference NN]'
---

# Write PR

Open a pull request, or refresh an open one, whose title follows the repository's conventions and
whose body a human reads in a minute and a reviewer can rerun.

## Path conventions

- `templates/` paths are relative to this skill's directory, the folder holding this file.
- Every other path is relative to the repository root, `git rev-parse --show-toplevel`, not the
  current directory.

## Process

### 1. Resolve the branch, the base, and the ticket

After `git fetch -q origin`, a token of the argument that `git rev-parse --verify origin/<token>`
resolves is the base; a
remaining `<bundle-reference> <NN>` pair is the ticket.

Read the current branch with `git branch --show-current`. Confirm it has an upstream,
`git rev-parse --abbrev-ref @{upstream}` resolves, and `git status -sb` shows no `ahead`; otherwise
`git push -u origin HEAD` first, since the body describes a head the forge holds.

The base is the argument, or, when the branch is `ticket/<bundle-reference>/<NN>`,
`bundle/<bundle-reference>`. Otherwise it is an integration target, resolved and checked with the
`workflow-manager` skill's Resolve and check the integration target steps: for
`bundle/<bundle-reference>`, the one that reference takes; for any other branch, the one of the
scope its changes belong to, by that skill's Which work folder rule. Name an integration target
base to the human before opening the PR, and ask for the base when the branch is that target
itself.

A ticket backs the PR when the branch is `ticket/<bundle-reference>/<NN>` or the argument names one.
Read that ticket from the bundle folder in this checkout, with the spec its frontmatter points to.
A bundle backs the PR when the branch is `bundle/<bundle-reference>`; read the bundle's spec from
the parent commit the template's bundle footer comment computes, since Land has deleted the folder at the head.

An open PR for the branch, `gh pr view --json number,url -q .url`, means this run refreshes its body.

**Done when** the branch is on the forge and you hold the base, whether a ticket or a bundle backs
the PR, and whether a PR is already open.

### 2. Write the title

**Follow `docs/conventions/git.md`, PR conventions.**

**Done when** the title is one line within that section's rules.

### 3. Gather the evidence and fill the body

**Use the check results already in this session when they were produced at the branch's head**;
otherwise run the checks the Checks comment of `templates/pr-body.md` names and record each result.
The same holds for the Before result: when none is in context, run its command at the merge base
in a detached worktree and record what it showed:

```bash
base=$(git merge-base HEAD origin/<base>) && git worktree add --detach <worktree dir>/pr-before $base
```

`<worktree dir>` is the value in `docs/conventions/git.md`, Worktrees; remove the worktree with
`git worktree remove --force` once recorded.

**For a bundle-backed PR, compute the Commits sections from the forge and the history**, and
recompute both on every refresh, since a sync after Land moves the head:

```bash
gh pr list --base bundle/<bundle-reference> --state merged --json number,title,mergeCommit
git log --first-parent --reverse --format='%H %h' origin/<base>..HEAD
git log --first-parent --no-merges --format='%h %s' <newest ticket merge sha>..HEAD
```

**List the Commits section in the order the second command prints**, keeping only the commits whose
full sha is a listed `mergeCommit`, since a ticket PR lands as one squash commit; PR numbers do not
give the merge order. The last of them is the newest ticket merge, and every commit the third
command prints reached the branch after it with no ticket review. `git show --name-only --format= <sha>` per commit tells which Reconciled
lines carry that sha as their origin.

**Copy `templates/pr-body.md` to a temporary file outside the repository and fill it** for this
PR's kind: ticket, bundle, or neither. Its first comment carries the filling rules.

**Done when** no comment survives and every result in Checks was produced at the branch's head.

### 4. Open or refresh

```bash
gh pr create --base <base> --title "<title>" --body-file <file>
```

A bundle-backed PR adds `--label bundle` and a ticket-backed PR `--label ticket`, so each kind can
be filtered across the repository; `gh label create <name>` first fails harmlessly when the label
exists. For an open PR,
`gh pr edit <number> --body-file <file>`, and `--title` when the delivered outcome changed. A body
assembled inline mangles fences and lists; always pass the file.

**Done when** `gh pr view --json body` shows the filled body ending on its footer with no surviving
comment, and you have reported the PR's URL and base.

## Checklist

- [ ] The head on the Summary's Checks line equals `git rev-parse --short=8 HEAD`.
- [ ] A ticket-backed or bundle-backed PR's footer links are `gh browse --commit=` permalinks, not
      branch links.
- [ ] A bundle-backed PR's Commits sections were computed at the current head, and every Reconciled
      line names its origin.
- [ ] The body ends with the footer: no "Generated with" line, no Co-Authored-By trailer.
