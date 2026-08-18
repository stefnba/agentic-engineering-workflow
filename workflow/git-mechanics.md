# Git mechanics

How the workflow uses git. These rules are identical in every consuming repo and are what the
`bundle-git` skill's scripts implement — changing them changes the scripts' behavior.

The *values* they operate on are declared by the consuming repo in
`${CLAUDE_PROJECT_DIR}/docs/conventions/git.md`: branch strategy, integration target, branch names,
worktree location and creation, commit and PR conventions. Read that file for what a repository
declares; read this one for the procedure the workflow runs on top of it.

## Worktree base rule

A branch is cut from the branch its work will PR into — for bundle work the `bundle-git` skill
derives that target; outside a bundle it is the configured integration target.

**Bundle branches and worktrees go through the `bundle-git` skill.** It owns their creation, sync, and
cleanup, deriving every name from the strategy and location the consuming repo declares. Worktrees
outside a bundle follow the base rule directly.

## Claiming a ticket

**Claiming a ticket is creating its branch.** Push the ticket branch to the remote at the head of the
branch its PR will merge into, and read the push's porcelain status flag as the verdict: `*` means
this push created the branch, so the claim is yours; anything else — `=` (already at that commit) or
a plain fast-forward — means another session claimed it first, so stop. Never force-push a claim.

## Bundle-branch creation

**Race-safe by construction, not by locking.** Fetch first: if the bundle branch already exists,
branch the ticket off it directly. If not, create it from the integration target and push it. If that
push is rejected because the ref now exists — another ticket's claim won the race — fetch it and
branch off that instead of failing.
