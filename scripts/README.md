# Bundle scripts

Deterministic git mechanics for bundle work, shared by the stage skills that run them and fronted
by the `bundle-state` skill. The rules they implement live in
[workflow/git-mechanics.md](../workflow/git-mechanics.md); changing those rules changes these
scripts.

Every script anchors itself on the top level of the checkout it is invoked in — a subdirectory is
fine, a directory outside a git work tree is a loud error — and reads that checkout's `work/` tree,
which is why `pr-links.sh` works from a ticket worktree and `publish-bundle.sh` publishes the
shaping session's bytes. Settings and their defaults come from `work/config.conf`, which documents
itself; an environment variable of the same name outranks the file. `_config.sh` anchors, reads
them, holds the branch names, and is sourced by the others rather than run on its own.

| Script                               | Purpose                                                                         |
| ------------------------------------ | ------------------------------------------------------------------------------- |
| `bundle-status.sh`                   | List every bundle with its status.                                              |
| `bundle-status.sh <bundle-id>`       | One bundle plus the status of each of its tickets.                              |
| `ticket-status.sh <bundle-id> <NN>`  | Print one ticket's status, for scripts and gates.                               |
| `publish-bundle.sh <bundle-id>`      | Publish or revise the working tree's approved bundle to the integration target. |
| `claim-ticket.sh <bundle-id> <NN>`   | Create the ticket's branch and worktree. Claiming is creating the branch.       |
| `pr-links.sh <bundle-id> <NN>`       | Print a ticket PR body's permalinks and target branch.                          |
| `complete-ticket.sh <pr> <sha>`      | Merge an accepted ticket PR per `TICKET_MERGE_METHOD`, remove its worktree.     |
| `land-bundle.sh start <bundle-id>`   | Open the land: a detached worktree on the integration target, bundle merged in. |
| `land-bundle.sh push <bundle-id>`    | Publish that worktree's tip on the integration target.                          |
| `land-bundle.sh cleanup <bundle-id>` | Delete the bundle's branches and remove its worktrees.                          |
| `abandon-bundle.sh <bundle-id>`      | Delete every ticket and bundle branch and worktree for an abandoned bundle.     |

Every status is computed from the remote branches and the ticket PRs' merge records on each call;
no script writes one. [git-mechanics.md](../workflow/git-mechanics.md) (Status is derived) holds
the semantics, including cancelling and the `unknown` state.

`write-boundary.sh` is the one non-bundle script here: the PreToolUse hook every skill with a
write boundary registers, its allowlist and deny reason passed as arguments — see its header and
[workflow/components.md](../workflow/components.md) (Permissions). It lives here because more than
one skill runs it.

## Exit codes

Treat a non-zero exit as a stop, never as something to retry or work around; the script's stderr
states the reason and the next action, so nothing else needs a mapping. The numbers are contract
only for scripts and tests that branch on them:

- `_config.sh`, sourced by every script
  - `1` outside a git work tree, a malformed `work/config.conf` line, or an unsupported `TICKET_MERGE_METHOD`
- `publish-bundle.sh`
  - `2` no such bundle in the working tree, or an id that is not a bundle directory name
  - `3` bundle moved on the target mid-session
  - `4` local target has commits origin lacks (rerun with `--allow-diverged` to publish anyway)
  - `5` stale publish worktree
  - `6` push retries exhausted
- `claim-ticket.sh`
  - `2` no such ticket
  - `3` dependency not `done`
  - `4` already claimed
  - `5` stale worktree
  - `6` malformed `depends_on`
  - `7` bundle not published on the target, or a stale bundle branch carrying its own commits
  - `8` a bundle revision and an earlier ticket PR both amended the same file
- `pr-links.sh`
  - `2` no such ticket
  - `3` bundle not published
  - `4` forge unreachable
- `complete-ticket.sh`
  - `2` stale against its base
  - `64` missing the accepted head SHA
- `land-bundle.sh`
  - `1` cleanup could not verify a branch against the forge: the unverified branches and worktrees stay; a fully unreachable forge stops earlier, at the fetch, with git's own exit
  - `2` no such bundle, `push` before `start`, or `cleanup` from inside a worktree
  - `3` a ticket not `done`, or its PR record unqueryable
  - `4` no bundle branch (never claimed, or already cleaned up)
  - `5` leftover land worktree
  - `6` target moved: not a failure but a loop; re-run the canonical checks, then `push` again
  - `7` merge conflict, left for the human
  - `8` a bundle-branch commit matches no merged ticket PR
  - `9` cleanup on an unlanded bundle branch; nothing is deleted
- `abandon-bundle.sh`
  - `1` a branch refused to delete
  - `2` no such bundle, or run from inside a worktree
  - `9` already landed; use `land-bundle.sh cleanup` instead

## Tests

`tests/run.sh` runs the scripts against a local `git daemon` with a stubbed `gh` — no network, and
nothing written outside a temp dir. It covers every script in this directory: claiming and its
races, the dependency gate, both bundle shapes, the claim-time revision sync, publishing and
revising, listing and permalinks, merging and its refusals, landing and cleanup, abandoning,
config reading, and the write boundary — each with its refusal paths, not just its happy one.

The cases are the run's own section headings, one per behavior it pins; `grep '^echo "== '
tests/run.sh` prints them. Read those rather than a list here, which would drift the first time a
case is added. Exits non-zero on failure.
