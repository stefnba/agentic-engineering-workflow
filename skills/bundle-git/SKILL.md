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
Settings and their defaults come from `${CLAUDE_PROJECT_DIR}/work/config.conf`, which documents itself; an environment
variable of the same name outranks the file. `scripts/_config.sh` reads them, holds the branch names,
and is sourced by the others rather than run on its own.

No script lands a finished bundle branch on the integration target yet — that Ship step is
unimplemented, and its rules are not a setting these scripts may reinterpret.

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

Every status above is computed from the remote branches and the ticket PRs' merge records on each
call; no script writes one. `${CLAUDE_PLUGIN_ROOT}/workflow/artifacts.md` defines what each state
means.

To cancel a ticket, delete its remote branch and remove its worktree; it reads as `todo` again. A
query that cannot reach the forge reports `unknown` rather than guessing — never read that as `todo`.

## Tests

`tests/run.sh` runs the scripts against a local `git daemon` with a stubbed `gh` — no network, and
nothing written outside a temp dir. It covers a ten-way claim race, the dependency gate, both bundle
shapes, listing, an unreachable forge, and the flags passed to the merge. Exits non-zero on failure.

## Exit codes from `claim-ticket.sh`

`2` no such ticket · `3` blocked by an unfinished dependency · `4` already claimed · `5` stale
worktree in the way. Treat a non-zero exit as a stop, never as something to retry or work around: a
`4` means another session owns that ticket.
