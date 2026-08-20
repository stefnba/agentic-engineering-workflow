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

**Land gets a detached worktree on the integration target** — the only worktree cut for a stage
rather than for a pull request. It checks out the commit `origin/<integration-target>` points at,
at `$WORKTREE_DIR/land/<bundle-id>`, merges the bundle branch in, and works there; Land removes it
with the rest of the leftovers.

Detached is forced, not stylistic: the session's own checkout already holds the integration target,
and git gives a branch to one worktree at a time. So Land commits onto a nameless line of history,
and `git push origin HEAD:<integration-target>` is what gives that line a name — once, at the end,
after the checks passed.

Three reasons it is neither the session's own checkout nor the bundle branch:

- **An abandoned land costs a directory.** Nothing is named until the push, so a canonical check that
  fails leaves a scratch tree to delete rather than a half-landed integration target in the human's
  working directory.
- **Every script here reads `work/bundles/<id>/` from the tree it runs in.** A session that switched
  its own checkout would derive branch strategy and dependency gates from a different copy of the
  bundle than the one it believes it has.
- **Landing on the bundle branch inverts the merge and manufactures conflicts.** It would have to
  merge the moved integration target back into a branch that just deleted the bundle, so a bundle
  republished mid-execution collides modify/delete, and a backlog line appended by any other session
  collides on content. Merging the bundle into the target instead has neither collision, because
  nothing has to travel backwards.

A single-ticket bundle has no bundle branch, so Land's commits go to the session's own checkout.

## Ticket-branch currency

**A ticket branch is merged only when its base is an ancestor of the accepted head.** A sibling
ticket that merged first moves the base out from under the reviewed diff, and the two states can
merge with no text conflict and still be broken — what was verified is not what would land.

The cure is to merge the base into the ticket branch, re-verify, and review again. That moves the
head, which is why it cannot happen after Accept: an Accept applies to an exact head SHA and the
merge enforces it. **So currency is a precondition of Accept, not a repair afterwards.** A branch
found stale at merge time goes back for a fix round and a fresh Accept.

Only siblings with no edge between them can go stale. `depends_on` already serializes a dependent
ticket behind its dependency's merge, so that one is current by construction.

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

## Backlog merges

`work/backlog.md` is written from several branches at once by design — a Shape session appends a
Critic candidate on the integration target while Land drains leftovers in its own worktree — and both
writes land at the end of the file, which git reports as a conflict.

**Resolve it by keeping both sides, always.** The backlog is an append-mostly list of independent
lines; there is no judgment call to make and no side that wins. This is the one merge conflict in the
workflow that an agent may resolve without asking, and the only one — every other conflict stops and
goes to the human.

Land applies this itself, per merge and per path: `land-bundle.sh` unions the two sides of
`work/backlog.md` from git's own merge stages and commits, leaving any other conflicted path alone.
It is deliberately not a `.gitattributes` entry — that would change merge behaviour for every person
and tool in a consuming repository, for a file most of them never touch, to fix a conflict only this
workflow creates.

## Landing a bundle

Only a multi-ticket bundle has a branch to land. A single-ticket bundle's PR already landed on the
integration target, so Land's reconciliation and deletion commits go straight there — the stage runs
either way.

**The land preserves each ticket's commits exactly as they reached the bundle branch** — one per
ticket when `TICKET_MERGE_METHOD` squashes, whatever that setting produces otherwise. Once Land
deletes the bundle, those commits — their subjects, their PR back-references, and the permalinks in
those PR bodies — are the only bridge left from a landed line of code to the ticket that approved
it. The land must not collapse or rewrite them:

- **Merge, never squash.** `git merge --no-ff` of the bundle branch into Land's worktree. Squashing
  replaces every ticket commit with one commit attributed to the bundle, so `git blame` stops at the
  bundle and no single ticket can be reverted or bisected afterwards.
- **Never rebase the bundle branch.** It reissues commits Land already verified as a whole and that
  the ticket PRs' merge records point at, so what lands is a state no check ever ran against.
- **`--no-ff` even when a fast-forward is available.** The merge commit is the only surviving record
  that these commits were one approved outcome; a fast-forward erases that boundary in exactly the
  quiet cases.
- **The bundle comes to the target, never the reverse.** Land merges `bundle/<bundle-id>` into its
  detached checkout of the integration target and publishes that. The target is never merged into
  the bundle branch.
- **When the target moves before the push, merge it in, re-run the canonical checks, then push
  again.** That is the only permitted reconciliation, and the re-run is not optional — the merged
  state is one no check has run against.

`TICKET_MERGE_METHOD` is named for its whole scope: ticket PRs, nothing else. The land is fixed, not
a setting — it is what makes [Artifacts](./artifacts.md)'s "no landed-bundle archive; git history
preserves temporary artifacts" true. [Lifecycle](./lifecycle.md) sequences these rules as Land's
reconcile, re-verify, and land steps.
