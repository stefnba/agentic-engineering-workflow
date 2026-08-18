---
name: bundle-git
description: Claim a ticket, report bundle and ticket status, and merge an accepted ticket PR. Deterministic git mechanics behind the agentic workflow's Shape, Implement, Review, and Ship stages — not a session driver.
---

# bundle-git

Deterministic git mechanics for bundle work.

- `${CLAUDE_PROJECT_DIR}/work/config.conf` — the settings these scripts run with.
- `${CLAUDE_PLUGIN_ROOT}/workflow/git-mechanics.md` — the claim and bundle-branch procedures these
  scripts implement.
- `${CLAUDE_PLUGIN_ROOT}/workflow/artifacts.md` — why status is derived rather than stored.

Run every script from the repository root, invoked as `${CLAUDE_SKILL_DIR}/scripts/<name>.sh`.
Settings come from `work/config.conf` (`INTEGRATION_TARGET`, `TICKET_MERGE_METHOD`, `WORKTREE_DIR`); the
defaults are `main`, `squash`, and `.claude/worktrees`, and an environment variable of the same name
outranks the file. `scripts/_config.sh` holds them plus the branch names and is sourced by the
others, never run on its own.

`TICKET_MERGE_METHOD` covers ticket PRs and nothing else. No script lands a finished bundle branch on
the integration target yet; that is a Ship step whose method is fixed, not configurable — see
"Landing a bundle" in `${CLAUDE_PLUGIN_ROOT}/workflow/git-mechanics.md`.

| Script                                      | Purpose                                                                     |
| ------------------------------------------- | --------------------------------------------------------------------------- |
| `scripts/bundle-status.sh`                  | List every bundle with its status.                                          |
| `scripts/bundle-status.sh <bundle-id>`      | One bundle plus the status of each of its tickets.                          |
| `scripts/ticket-status.sh <bundle-id> <NN>` | Print one ticket's status, for scripts and gates.                           |
| `scripts/claim-ticket.sh <bundle-id> <NN>`  | Create the ticket's branch and worktree. Claiming is creating the branch.   |
| `scripts/complete-ticket.sh <pr> [sha]`     | Merge an accepted ticket PR per `TICKET_MERGE_METHOD`, remove its worktree. |

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
