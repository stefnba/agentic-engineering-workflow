---
name: bundle
description: Answer bundle and ticket state from git, or perform one state transition. Use when the user asks what bundles or tickets exist, what is in flight, whether a ticket is claimed or done, or asks to claim a ticket or merge an accepted ticket PR — even mid-conversation without naming the skill. Not a session driver; shaping, implementing, reviewing, and landing bundles have their own skills.
---

# Bundle

Route the request to one script, run it from the repository root, and report its output rather than
a paraphrase. The scripts' contract — settings, exit codes, tests — is
`${CLAUDE_PLUGIN_ROOT}/scripts/README.md`; read it before doing anything the table below doesn't
cover.

| Request                                                     | Command                                                                     |
| ----------------------------------------------------------- | --------------------------------------------------------------------------- |
| "what's in flight?", "which bundles exist?", bare `/bundle` | `${CLAUDE_PLUGIN_ROOT}/scripts/bundle-status.sh`                            |
| "where is bundle X?" — one bundle, every ticket's status    | `${CLAUDE_PLUGIN_ROOT}/scripts/bundle-status.sh <bundle-id>`                |
| "is ticket NN claimed?", "is it done?"                      | `${CLAUDE_PLUGIN_ROOT}/scripts/ticket-status.sh <bundle-id> <NN>`           |
| "claim ticket NN", "start on NN"                            | `${CLAUDE_PLUGIN_ROOT}/scripts/claim-ticket.sh <bundle-id> <NN>`            |
| "the permalinks / target branch for a ticket PR"            | `${CLAUDE_PLUGIN_ROOT}/scripts/pr-links.sh <bundle-id> <NN>`                |
| "merge the accepted ticket PR"                              | `${CLAUDE_PLUGIN_ROOT}/scripts/complete-ticket.sh <pr> <accepted-head-sha>` |

**`<NN>` is the two-digit ticket number** as the status listing prints it — `01` for a single-ticket
bundle, whose one file is `ticket.md`. A slug or unpadded number names a branch no status query
reconstructs, so the scripts refuse it as `no such ticket`.

Treat a non-zero exit as a stop, never something to retry or work around — its message states the
reason and the next action; report it as printed. What each status means, how to cancel a ticket,
and why `unknown` is not `todo`:
`${CLAUDE_PLUGIN_ROOT}/workflow/git-mechanics.md`, Status is derived.

Landing is a judgment sequence, not a routing row — REQUIRED: use the `land` skill for it; run
`land-bundle.sh` only from there.
