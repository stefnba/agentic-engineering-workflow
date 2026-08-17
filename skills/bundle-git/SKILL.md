---
name: bundle-git
description: Claim a ticket, report bundle and ticket status, and merge an accepted ticket PR. Deterministic git mechanics behind the agentic workflow's Shape, Implement, Review, and Ship stages — not a session driver.
---

# bundle-git

Deterministic git mechanics for bundle work.

- `${CLAUDE_PROJECT_DIR}/docs/agents/git.md` — this repository's branch strategy and conventions,
  which these scripts follow. Read it for the integration target and branch names.
- `${CLAUDE_PLUGIN_ROOT}/docs/artifacts.md` — why status is derived rather than stored.

Run every script from the repository root, invoked as `${CLAUDE_SKILL_DIR}/scripts/<name>.sh`. Set
`INTEGRATION_TARGET` if the target is not `main`.

| Script | Purpose |
| --- | --- |
| `scripts/bundle-status.sh` | List every bundle with its status. |
| `scripts/bundle-status.sh <bundle-id>` | One bundle plus the status of each of its tickets. |
| `scripts/ticket-status.sh <bundle-id> <NN>` | Print one ticket's status, for scripts and gates. |
| `scripts/claim-ticket.sh <bundle-id> <NN>` | Create the ticket's branch and worktree. Claiming is creating the branch. |
| `scripts/complete-ticket.sh <pr> [sha]` | Squash-merge an accepted PR and remove its worktree. |

```console
$ scripts/bundle-status.sh
active   2026-08-17-add-invites
shaped   2026-08-17-add-2fa

$ scripts/bundle-status.sh 2026-08-17-add-invites
active   2026-08-17-add-invites
  done     01-persistence
  doing    02-api
  todo     03-ui
```

## Status is derived

- ticket `done` — its PR is merged into that ticket's target branch.
- ticket `doing` — its branch exists on the remote.
- ticket `todo` — neither.
- bundle `active` — at least one ticket is no longer `todo`; `shaped` — none is.

Nothing writes status. A human merging the PR in the web UI leaves the same state as
`complete-ticket.sh`. To cancel a ticket, delete its remote branch and remove its worktree; it reads
as `todo` again. A status query that cannot reach the forge reports `unknown` rather than guessing —
never read that as `todo`.

## Tests

`tests/run.sh` runs the scripts against a local `git daemon` with a stubbed `gh` — no network, and
nothing written outside a temp dir. It covers a ten-way claim race, the dependency gate, both bundle
shapes, listing, an unreachable forge, and the flags passed to the merge. Exits non-zero on failure.

## Exit codes from `claim-ticket.sh`

`2` no such ticket · `3` blocked by an unfinished dependency · `4` already claimed · `5` stale
worktree in the way. Treat a non-zero exit as a stop, never as something to retry or work around: a
`4` means another session owns that ticket.
