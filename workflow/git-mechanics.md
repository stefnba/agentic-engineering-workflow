# Git mechanics

How the workflow uses git. These rules are identical in every consuming repo and are what the
plugin's `scripts/` implement — changing them changes the scripts' behavior. The scripts' own
interface contract (invocation, exit codes, tests) is `scripts/README.md`; the `bundle-state` skill routes
conversational requests to them.

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

**Branch strategy is uniform: every bundle gets a bundle branch**, whatever its ticket count. A
single-ticket bundle's PR merges into `bundle/<bundle-id>` like any other, and Land carries the
result to the integration target. The uniformity is the point, not a convenience: no ticket PR
targets the integration target, so a moving target can never stale a reviewed diff, and the only
merge into it is the land, re-verified in Land's worktree first. Planning commits — a published
bundle, a backlog line — still write to the target directly; they carry no behavior change.

## Status is derived

Every bundle and ticket status is computed from the remote branches and the ticket PRs' merge
records at the moment it is asked for; nothing stores one:

- ticket `done`: its PR is merged into the bundle branch.
- ticket `doing`: its ticket branch exists on the remote — claiming is creating that branch (see
  Claiming a ticket below), so `doing` needs no record of its own. It stays `doing` through
  Implement, Review, fixes, and human review.
- ticket `todo`: neither.
- bundle `shaped`: the bundle exists under `work/bundles/` on the integration target with no ticket
  claimed; `active`: at least one ticket is no longer `todo`.

To cancel a ticket, delete its remote branch and remove its worktree; it reads as `todo` again.
Nothing is written after a merge, so a human who merges a ticket PR directly leaves exactly the
state a skill script would. A query that cannot reach the forge reports `unknown` rather than
guessing — never read that as `todo`.

## Abandoning a bundle

**A bundle can be abandoned at any point, whatever mix of `done`, `doing`, and `todo` its tickets
are in — nothing it holds has ever reached the integration target.** Ticket-branch currency
(above) is what makes a single ticket's PR safe to merge into the bundle branch; the bundle
branch itself only ever reaches the target through Land. So abandoning is symmetric with cancelling
a ticket, just wider: delete every ticket branch and worktree, then the bundle branch, then the
published `work/bundles/<bundle-id>` directory as its own commit on the integration target — the
same kind of direct planning commit Shape's publish and Land's delete already are, never a revert
of the publish commit.

This is not `land-bundle.sh cleanup`, which runs only after a land and deliberately keeps a ticket
branch whose PR isn't merged yet, because that branch is a live claim someone still owns. Abandoning
discards exactly that in-flight work on purpose, so it deletes every ticket branch regardless of
status. **A bundle already landed refuses instead of re-running as an abandon:** `abandon-bundle.sh`
looks for the exact `chore(land): land bundle <bundle-id>` commit `land-bundle.sh start` writes when
it merges the bundle branch in — the only signal that is true precisely when a land happened. Neither
the bundle branch's ancestry nor `work/bundles/<bundle-id>`'s presence on the target can substitute:
a branch nothing has merged into yet is trivially "an ancestor" of the target too, since it was cut
from it and never diverged, and the directory is absent from the target both after a land and before
the bundle was ever published — abandoning that second case is exactly what this script is for. A
bundle already landed belongs to cleanup instead.

## Ticket PR permalinks

**A ticket PR's permalinks pin to the commit that published the bundle on the integration
target** — the approved state, not the amended copy a ticket branch carries. That commit also
outlives the branches: `TICKET_MERGE_METHOD=squash` means a ticket branch's own commits never reach
the bundle branch, so a link pinned to one rests on the forge retaining the pull request, while the
publish commit sits in the integration target's first-parent history.

## Worktree base rule

A branch is cut from the branch its work will PR into — for bundle work that is the bundle branch
(Branch naming above); outside a bundle it is the configured integration target.

**Bundle branches and worktrees go through the bundle scripts.** They own their creation and
cleanup, deriving every name from the bundle ID and the settings above. Worktrees outside a
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
  its own checkout would derive the ticket set and dependency gates from a different copy of the
  bundle than the one it believes it has.
- **Landing on the bundle branch inverts the merge and manufactures conflicts.** It would have to
  merge the moved integration target back into a branch that just deleted the bundle, so a bundle
  republished mid-execution collides modify/delete, and a backlog line appended by any other session
  collides on content. Merging the bundle into the target instead has neither collision, because
  nothing has to travel backwards.

## Ticket-branch currency

**A ticket branch is merged only when its base is an ancestor of the accepted head.** A sibling
ticket that merged first moves the base out from under the reviewed diff, and the two states can
merge with no text conflict and still be broken — what was verified is not what would land.

The cure is to merge the base into the ticket branch, re-verify, and review again. That moves the
head, which is why it cannot happen after Accept: an Accept applies to an exact head SHA and the
merge enforces it. **So currency is a precondition of Accept, not a repair afterwards.** A branch
found stale at merge time goes back for a fix round and a fresh Accept.

**That merge can conflict — the moved base and this branch's own changes can touch the same
lines.** It stops and goes to the human, the same as every conflict but the one in
`work/backlog.md` (Backlog merges below) — a session guessing its way through someone else's
diverging change is exactly the risk that exception was written not to take anywhere else.

**The accepted SHA is always named, never resolved from whatever the branch currently points at.**
`complete-ticket.sh` requires it and passes it to the forge as `--match-head-commit`, so the merge
fails outright if the head moved since — including a commit pushed straight to the branch, outside
Review, that a "just take the current head" resolve would otherwise wave through unreviewed.

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

## Bundle-branch writes

**Content reaches a bundle branch only through an accepted ticket PR.** Nothing else ever writes to
it — not even Land, which merges the branch into a detached worktree on the integration target
rather than committing on it (see Landing a bundle below). Land enforces this structurally: a
first-parent commit on the branch that matches no merged ticket PR's record refuses the land, so a
direct push is caught before it can reach the target.

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
preserves temporary artifacts" true.
