# Git mechanics

How the workflow uses git. These rules are identical in every consuming repo and are what the
`bundle-git` skill's scripts implement — changing them changes the scripts' behavior.

The settings they operate on are read from `${CLAUDE_PROJECT_DIR}/work/config.conf`:
`INTEGRATION_TARGET`, `TICKET_MERGE_METHOD`, `WORKTREE_DIR`. `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md`
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

## Landing a bundle

Only a multi-ticket bundle has a land. A single-ticket bundle's PR already landed on the integration
target, so Ship's reconciliation and deletion commits go straight there.

**The land preserves each ticket's commits exactly as they reached the bundle branch** — one per
ticket under the default `TICKET_MERGE_METHOD=squash`, whatever that setting produces otherwise. Once Ship
deletes the bundle, those commits — their subjects, their PR back-references, and the permalinks in
those PR bodies — are the only bridge left from a shipped line of code to the ticket that approved
it. The land must not collapse or rewrite them:

- **Merge, never squash.** `git merge --no-ff`, or `gh pr merge --merge` if you choose to land
  through a pull request. Squashing replaces every ticket commit with one commit attributed to the
  bundle, so `git blame` stops at the bundle and no single ticket can be reverted or bisected
  afterwards.
- **Never rebase the bundle branch.** It reissues commits Ship already verified as a whole and that
  the ticket PRs' merge records point at, so what lands is a state no check ever ran against.
- **`--no-ff` even when a fast-forward is available.** The merge commit is the only surviving record
  that these commits were one approved outcome; a fast-forward erases that boundary in exactly the
  quiet cases.
- **When the integration target has moved, merge it into the bundle branch, re-run the Ship check,
  then land.** That is the only permitted reconciliation.

`TICKET_MERGE_METHOD` is named for its whole scope: ticket PRs, nothing else. The land is fixed, not
a setting — it is what makes [Artifacts](./artifacts.md)'s "no shipped-bundle archive; git history
preserves temporary artifacts" true. [Lifecycle](./lifecycle.md) sequences these rules as Ship steps
5–7.
