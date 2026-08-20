---
name: bundle-git
description: Claim a ticket, report bundle and ticket status, and merge an accepted ticket PR. Deterministic git mechanics behind the agentic workflow's Shape, Implement, Review, and Land stages — not a session driver.
---

# bundle-git

Deterministic git mechanics for bundle work.

- `${CLAUDE_PROJECT_DIR}/work/config.conf` — the settings these scripts run with.
- `${CLAUDE_PLUGIN_ROOT}/workflow/git-mechanics.md` — the claim and bundle-branch procedures these
  scripts implement.
- `${CLAUDE_PLUGIN_ROOT}/workflow/artifacts.md` — why status is derived rather than stored.

Run every script from the repository root, invoked as `${CLAUDE_SKILL_DIR}/scripts/<name>.sh`.
Settings and their defaults come from `${CLAUDE_PROJECT_DIR}/work/config.conf`, which documents
itself; an environment variable of the same name outranks the file.
`${CLAUDE_SKILL_DIR}/scripts/_config.sh` reads them, holds the branch names, and is sourced by the
others rather than run on its own.

| Script                                       | Purpose                                                                         |
| -------------------------------------------- | ------------------------------------------------------------------------------- |
| `scripts/bundle-status.sh`                   | List every bundle with its status.                                              |
| `scripts/bundle-status.sh <bundle-id>`       | One bundle plus the status of each of its tickets.                              |
| `scripts/ticket-status.sh <bundle-id> <NN>`  | Print one ticket's status, for scripts and gates.                               |
| `scripts/claim-ticket.sh <bundle-id> <NN>`   | Create the ticket's branch and worktree. Claiming is creating the branch.       |
| `scripts/pr-links.sh <bundle-id> <NN>`       | Print a ticket PR body's permalinks and target branch.                          |
| `scripts/complete-ticket.sh <pr> [sha]`      | Merge an accepted ticket PR per `TICKET_MERGE_METHOD`, remove its worktree.     |
| `scripts/land-bundle.sh start <bundle-id>`   | Open the land: a detached worktree on the integration target, bundle merged in. |
| `scripts/land-bundle.sh push <bundle-id>`    | Publish that worktree's tip on the integration target.                          |
| `scripts/land-bundle.sh cleanup <bundle-id>` | Delete the bundle's branches and remove its worktrees.                          |

```console
$ ${CLAUDE_SKILL_DIR}/scripts/bundle-status.sh
active   2026-08-17-add-invites
shaped   2026-08-17-add-2fa

$ ${CLAUDE_SKILL_DIR}/scripts/bundle-status.sh 2026-08-17-add-invites
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

## Permalinks outlive the bundle

`pr-links.sh` pins both links to the commit that published the bundle on the integration target,
which is the approved state and not the amended copy a ticket branch carries. It also outlives the
branches: `TICKET_MERGE_METHOD=squash` means a ticket branch's own commits never reach the bundle
branch, so a link pinned to one rests on the forge retaining the pull request, while the publish
commit sits in the integration target's first-parent history. Neither is obvious from a prompt,
which is why the rule has one definition here rather than being restated where it is used.
`${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md` (PR handoff contract) owns why the PR needs the links
at all.

## Tests

`tests/run.sh` runs the scripts against a local `git daemon` with a stubbed `gh` — no network, and
nothing written outside a temp dir. It covers a ten-way claim race, the dependency gate, both bundle
shapes, listing, an unreachable forge, permalinks pinned past a branch amendment, the flags passed to
the merge, the staleness refusal, and a full land — gate, detached worktree, the moved-target loop, the backlog union, and cleanup. Exits
non-zero on failure.

The land rules themselves are not a setting these scripts may reinterpret —
`${CLAUDE_PLUGIN_ROOT}/workflow/git-mechanics.md` owns them, and the `land` skill sequences the three
verbs with the judgment steps in between.

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
