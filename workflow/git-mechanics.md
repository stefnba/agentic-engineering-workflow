# Git mechanics

How the workflow uses git. These rules are identical in every consuming repo and are what the
`bundle-git` skill's scripts implement — changing them changes the scripts' behavior.

The settings they operate on are read from `${CLAUDE_PROJECT_DIR}/work/config.conf`:
`INTEGRATION_TARGET`, `MERGE_METHOD`, `WORKTREE_DIR`. `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md`
holds the conventions a human follows — commit messages, PR titles, the plain-git worktree rule —
and nothing a script reads.

## Branch naming

Fixed by the workflow, not configurable:

- Bundle branch: `bundle/<bundle-id>`
- Ticket branch: `ticket/<bundle-id>/<NN>` — a separate prefix from `bundle/` so it never collides
  with the bundle branch itself.

Status is derived by reconstructing these names, so every consumer has to agree byte for byte. A
repository that changed them would see a claimed ticket read as `todo`, which lets a dependent ticket
start early. `scripts/_config.sh` is the one definition every script uses.

**Branch strategy** is derived, not declared: a bundle with more than one ticket gets a bundle
branch; a single-ticket bundle's PR targets the integration target directly.

## Worktree base rule

A branch is cut from the branch its work will PR into — for bundle work the `bundle-git` skill
derives that target; outside a bundle it is the configured integration target.

**Bundle branches and worktrees go through the `bundle-git` skill.** It owns their creation and
cleanup, deriving every name from the bundle's shape and the settings above. Worktrees outside a
bundle follow the base rule directly.

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
