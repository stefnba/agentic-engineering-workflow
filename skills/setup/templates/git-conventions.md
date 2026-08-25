# Git conventions

This repository's git conventions: rules that apply to any git work.

## Commit messages

Conventional Commits — `type(scope): subject`.

- Standard commits use one of these seven types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`.
- Four paths have reserved types — a commit touching one uses that type, scopeless, and touches nothing else:
  - `bundle` — bundle artifacts under `work/bundles/<bundle-id>/`. One exception to "touches nothing else": the publish commit also carries its `work/backlog.md` edit, so the lines a bundle covers retire atomically with it
  - `decision` — adding or superseding a record in `docs/decisions/`
  - `backlog` — `work/backlog.md`
  - `research` — research reports under `docs/research/`
- Scope names the one component the change is about — ripple in other components (call sites, links updated because it changed) adds no scope. Omit it only when several components change as peers with no single subject.
- Subject imperative, lowercase after the colon, ≤ 72 characters.
- Body only when the why isn't obvious from the diff.
- One logical change per commit.

## PR conventions

**Title**: same shape as a commit subject — `type(scope): summary`, imperative, ≤ 72 characters.

## Worktrees

**Always create worktrees with plain git** — never a WorktreeCreate hook, for any worktree: a hook
replaces creation globally and silently disables `.worktreeinclude`.
