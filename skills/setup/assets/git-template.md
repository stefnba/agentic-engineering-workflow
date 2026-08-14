<!-- Scaffolded by the setup skill; this copy belongs to the repo — edit freely. Only the
declaration line's format is fixed: skills key on it and nothing else in this file, and it
must match `Branch strategy: (trunk|bundle-branch)` exactly — one line, no other wording. -->

# Git conventions

Branch strategy: bundle-branch

## Commit messages

Conventional Commits — `type(scope): subject`.

- Types, exactly these seven: feat, fix, refactor, docs, test, chore, ci.
- Subject imperative, lowercase after the colon, ≤ 72 characters.
- Body only when the why isn't obvious from the diff.
- One logical change per commit.

## PR conventions

- **Title**: same shape as a commit subject — `type(scope): summary`, imperative,
  ≤ 72 characters. Squash merge turns the title into the target branch's commit message,
  so this keeps history in one convention rather than two.
- **Merge method**: squash — one commit per PR on its target branch.

<!-- Repo-specific additions only (title format, labels, review requirements). The
workflow-mandated PR body sections stay owned by the implement skill — don't restate them
here. -->

## Worktrees

**Location**: `.claude/worktrees/`

**Always create with plain git** — no WorktreeCreate hooks. The worktree path mirrors the
branch name; `<base-branch>` is the branch the work will PR into.

```bash
git worktree add -b <branch> .claude/worktrees/<branch> <base-branch>
```

## Release promotion

<!-- How a merge to the default branch reaches users: auto-deploy on merge, promotion to a
production branch, tagged releases. Delete this section when merge and release coincide. -->
