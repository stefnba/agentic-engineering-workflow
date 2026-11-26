<!-- Fill every slot; delete these comments as you fill. -->

# Branches and worktrees

Branches and worktrees the workflow skills create. Written by the `setup-workflow` skill; edit by hand or rerun that skill. Branches for work outside the workflow follow `docs/conventions/git.md`.

## Branches

- Target branch: `{{TARGET_BRANCH}}`
<!-- The branch finished work lands on. Example: main -->
- Feature branch: `feature/<number>-<slug>`, cut from the target branch
- Ticket branch: `task/<number>-<slug>`, cut from its feature branch
- Small item branch: `task/<number>-<slug>`, cut from the target branch

`<number>` is the number of the work item. `<slug>` is two to four words of its title in lowercase kebab-case.

## Worktrees

- Worktree path: `.worktrees/<number>-<slug>`, relative to the repository root

**Create and remove worktrees with plain `git worktree` commands.** `.gitignore` holds `/.worktrees/`, so the worktrees stay untracked; its leading slash anchors the pattern to the repository root, not the filesystem root.
