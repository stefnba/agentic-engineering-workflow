<!-- Scaffolded by the setup skill; this copy belongs to the repo — edit freely. Two lines have fixed formats that skills key on, nothing else in this file: the declaration line, matching `Branch strategy: (trunk|bundle-branch)` exactly — one line, no other wording — and the Worktrees section's `**Location**:` line. -->

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

**Location**: `.claude/worktrees/` — the path under it mirrors the branch name.

**Base rule**: a branch is cut from the branch its work will PR into — for bundle work the `bundle-git` skill derives that target; outside a bundle it is the default branch (unless an optional Release promotion section below says otherwise).

**Always create with plain git** — never a WorktreeCreate hook, for any worktree: a hook replaces creation globally and silently disables `.worktreeinclude`.

**Bundle branches and worktrees go through the `bundle-git` skill** — it owns their creation, sync, and cleanup, deriving every name from the strategy and location declared here. Worktrees outside a bundle follow the rules above directly.

## Release promotion

<!-- How a merge to the default branch reaches users: auto-deploy on merge, promotion to a
production branch, tagged releases. Delete this section when merge and release coincide. -->
