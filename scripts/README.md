# Bundle scripts

Deterministic git mechanics for bundle work, shared by the stage skills that run them and fronted
by the `bundle` skill. The rules they implement live in
[workflow/git-mechanics.md](../workflow/git-mechanics.md); changing those rules changes these
scripts.

Run every script from the repository root. Settings and their defaults come from
`work/config.conf`, which documents itself; an environment variable of the same name outranks the
file. `_config.sh` reads them, holds the branch names, and is sourced by the others rather than run
on its own.

| Script                               | Purpose                                                                         |
| ------------------------------------ | ------------------------------------------------------------------------------- |
| `bundle-status.sh`                   | List every bundle with its status.                                              |
| `bundle-status.sh <bundle-id>`       | One bundle plus the status of each of its tickets.                              |
| `ticket-status.sh <bundle-id> <NN>`  | Print one ticket's status, for scripts and gates.                               |
| `claim-ticket.sh <bundle-id> <NN>`   | Create the ticket's branch and worktree. Claiming is creating the branch.       |
| `pr-links.sh <bundle-id> <NN>`       | Print a ticket PR body's permalinks and target branch.                          |
| `complete-ticket.sh <pr> [sha]`      | Merge an accepted ticket PR per `TICKET_MERGE_METHOD`, remove its worktree.     |
| `land-bundle.sh start <bundle-id>`   | Open the land: a detached worktree on the integration target, bundle merged in. |
| `land-bundle.sh push <bundle-id>`    | Publish that worktree's tip on the integration target.                          |
| `land-bundle.sh cleanup <bundle-id>` | Delete the bundle's branches and remove its worktrees.                          |

Every status is computed from the remote branches and the ticket PRs' merge records on each call;
no script writes one. [git-mechanics.md](../workflow/git-mechanics.md) (Status is derived) holds
the semantics, including cancelling and the `unknown` state.

## Exit codes

Treat a non-zero exit as a stop, never as something to retry or work around.

**`claim-ticket.sh`** — `2` no such ticket · `3` a dependency is not `done` · `4` already claimed ·
`5` stale worktree in the way. A `4` means another session owns that ticket. A `3` names the status it
saw — `todo`, `doing`, or `unknown` when the forge could not be queried, which blocks the claim
exactly as an unfinished dependency does and needs the forge fixed rather than the ticket waited on.

**`pr-links.sh`** — `2` no such ticket · `3` the bundle is not on the integration target, so there is
no approved commit to pin to · `4` the forge is unreachable.

**`complete-ticket.sh`** — `2` the ticket branch is stale against its base: a sibling merged first, so
the reviewed diff was verified against a base that has moved. Merge the base in, re-verify, and get a
fresh Accept; the fix moves the head, which is why it cannot happen after the Accept it invalidates.

**`land-bundle.sh`** — `2` no such bundle · `3` a ticket is not `done` · `4` nothing to land, a
single-ticket bundle whose commits go to the session's own checkout · `5` a previous land left a
worktree · `6` the integration target moved · `7` a merge conflict, left in place for the human.

**`6` is a loop, not a failure.** `push` merged the moved target in and stopped rather than
publishing a state no check has run against. Re-run the canonical checks, then `push` again.

## Tests

`tests/run.sh` runs the scripts against a local `git daemon` with a stubbed `gh` — no network, and
nothing written outside a temp dir. It covers a ten-way claim race, the dependency gate, both bundle
shapes, listing, an unreachable forge, permalinks pinned past a branch amendment, the flags passed to
the merge, the staleness refusal, and a full land — gate, detached worktree, the moved-target loop,
the backlog union, and cleanup. Exits non-zero on failure.
