# Git conventions

This repository's git conventions: rules that apply to any git work.

## Commit messages

Conventional Commits — `type(scope): subject`.

- Types, exactly these seven: feat, fix, refactor, docs, test, chore, ci.
- Subject imperative, lowercase after the colon, ≤ 72 characters.
- Body only when the why isn't obvious from the diff.
- One logical change per commit.

## PR conventions

**Title**: same shape as a commit subject — `type(scope): summary`, imperative, ≤ 72 characters.
Squash merge turns the title into the target branch's commit message, so this keeps history in one
convention rather than two.

## Worktrees

**Always create worktrees with plain git** — never a WorktreeCreate hook, for any worktree: a hook
replaces creation globally and silently disables `.worktreeinclude`.
