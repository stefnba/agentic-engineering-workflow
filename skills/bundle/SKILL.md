---
name: bundle
description: Answer bundle and ticket state from git, or perform one state transition. Use when the user asks what bundles or tickets exist, what is in flight, whether a ticket is claimed or done, or asks to claim a ticket or merge an accepted ticket PR — even mid-conversation without naming the skill. Not a session driver; shaping, implementing, reviewing, and landing bundles have their own skills.
---

# Bundle

Route the request to one script, run it from the repository root, and report its output rather than
a paraphrase. The scripts' contract — settings, exit codes, tests — is
`${CLAUDE_PLUGIN_ROOT}/scripts/README.md`; read it before doing anything the table below doesn't
cover.

| Request                                       | Command                                                           |
| --------------------------------------------- | ----------------------------------------------------------------- |
| every bundle and its status (no argument too) | `${CLAUDE_PLUGIN_ROOT}/scripts/bundle-status.sh`                  |
| one bundle, with each ticket's status         | `${CLAUDE_PLUGIN_ROOT}/scripts/bundle-status.sh <bundle-id>`      |
| one ticket's status                           | `${CLAUDE_PLUGIN_ROOT}/scripts/ticket-status.sh <bundle-id> <NN>` |
| claim a ticket                                | `${CLAUDE_PLUGIN_ROOT}/scripts/claim-ticket.sh <bundle-id> <NN>`  |
| a ticket PR's permalinks and target branch    | `${CLAUDE_PLUGIN_ROOT}/scripts/pr-links.sh <bundle-id> <NN>`      |
| merge an accepted ticket PR                   | `${CLAUDE_PLUGIN_ROOT}/scripts/complete-ticket.sh <pr> <sha>`     |

Treat a non-zero exit as a stop and read its meaning in the README's exit codes — never retry or
work around one. What each status means, how to cancel a ticket, and why `unknown` is not `todo`:
`${CLAUDE_PLUGIN_ROOT}/workflow/git-mechanics.md`, Status is derived.

Landing is a judgment sequence, not a routing row — REQUIRED: use the `land` skill for it; run
`land-bundle.sh` only from there.
