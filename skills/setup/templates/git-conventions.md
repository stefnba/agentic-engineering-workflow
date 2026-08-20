# Git conventions

This repository's git conventions: rules that apply to any git work.

## Commit messages

Conventional Commits — `type(scope): subject`.

- Types, exactly these eight: feat, fix, refactor, docs, test, chore, ci, bundle.
- `bundle` is reserved for commits on workflow artifacts under `work/` — scopeless, and never mixed with a change to anything else.
- Subject imperative, lowercase after the colon, ≤ 72 characters.
- Body only when the why isn't obvious from the diff.
- One logical change per commit.

## PR conventions

**Title**: same shape as a commit subject — `type(scope): summary`, imperative, ≤ 72 characters.

## Worktrees

**Always create worktrees with plain git** — never a WorktreeCreate hook, for any worktree: a hook
replaces creation globally and silently disables `.worktreeinclude`.
