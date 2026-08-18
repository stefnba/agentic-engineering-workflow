---
name: setup
description: Install the agentic coding workflow into a repository — check prerequisites, then write work/config.conf, docs/conventions/git.md, and the AGENTS.md pointer. Run once per repo, before any bundle work.
---

# setup

> **Placeholder.** The interview and the file writes are not implemented yet; do the steps by hand
> for now. Tracked in `work/backlog.md`.

Installs the workflow into a consuming repo. Read
[`${CLAUDE_SKILL_DIR}/references/prerequisites.md`](references/prerequisites.md) first and stop if
anything is missing — a repo without a forge CLI cannot derive ticket status at all.

What a run writes:

| Path                      | From                                        | Contents                                              |
| ------------------------- | ------------------------------------------- | ----------------------------------------------------- |
| `work/config.conf`        | `${CLAUDE_SKILL_DIR}/templates/config.conf` | the settings the scripts read                         |
| `docs/conventions/git.md` | the interview                               | commit and PR conventions a human follows             |
| `AGENTS.md`               | appended                                    | one pointer line naming the workflow                  |
| `.gitignore`              | appended                                    | the `WORKTREE_DIR` value, so worktrees stay untracked |

Two rules the writes must honour:

- **`work/config.conf` is committed, not ignored.** A clone without it falls back to the defaults
  in the template — which silently lands work on `main` when the integration target is `dev`.
- **The `.gitignore` entry has to match `WORKTREE_DIR`.** They are one decision written twice; a
  non-default `WORKTREE_DIR` with the default ignore line leaves worktrees staged for commit.

`${CLAUDE_PLUGIN_ROOT}/workflow/git-mechanics.md` owns what the settings mean and why branch names
are not among them.
