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

Treat a non-zero exit as a stop, never as something to retry or work around; the script's stderr
states the reason and the next action, so nothing else needs a mapping. The numbers are contract
only for scripts and tests that branch on them:

- `claim-ticket.sh` — `2` no such ticket · `3` dependency not `done` · `4` already claimed ·
  `5` stale worktree
- `pr-links.sh` — `2` no such ticket · `3` bundle not published · `4` forge unreachable
- `complete-ticket.sh` — `2` stale against its base
- `land-bundle.sh` — `2` no such bundle · `3` a ticket not `done` · `4` nothing to land
  (single-ticket bundle) · `5` leftover land worktree · `6` target moved: not a failure but a loop —
  re-run the canonical checks, then `push` again · `7` merge conflict, left for the human

## Tests

`tests/run.sh` runs the scripts against a local `git daemon` with a stubbed `gh` — no network, and
nothing written outside a temp dir. It covers a ten-way claim race, the dependency gate, both bundle
shapes, listing, an unreachable forge, permalinks pinned past a branch amendment, the flags passed to
the merge, the staleness refusal, and a full land — gate, detached worktree, the moved-target loop,
the backlog union, and cleanup. Exits non-zero on failure.
