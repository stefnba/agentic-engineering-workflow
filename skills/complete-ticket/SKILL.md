---
name: complete-ticket
description: Merge one accepted ticket PR and remove its worktree. Invoke with the PR number and the head SHA you accepted, after reviewing the PR yourself — invoking this skill is the Accept.
argument-hint: "[pr] [accepted-head-sha]"
disable-model-invocation: true
---

# Complete one ticket

**This merge is the ticket's last write.** `done` is derived from the merged PR — no status is
written anywhere, before or after. The human invoking this skill _is_ the Accept: never run the
merge on your own judgment that the PR looks ready.

## Process

### 1. Pin the accepted head

Both arguments come from the human. **With no SHA given, resolve the current head**
(`gh pr view <pr> --json headRefOid`), show it, and confirm it is the state they reviewed before
using it — the SHA pins the merge to what was accepted, so a head that moved since must go back
through review, not through a fresh resolve.

### 2. Merge

Run from the repository root:

```text
${CLAUDE_PLUGIN_ROOT}/scripts/complete-ticket.sh <pr> <accepted-head-sha>
```

Treat a non-zero exit as a stop, never something to retry or work around — its message states the
reason and the next action; report it as printed. Exit `2` (stale against its base) goes back to
the ticket's own session: the base merged in, re-verified, another review round.

### 3. Report and stop

Report the script's output, then stop. The next ticket is a fresh tab and the human's dispatch.
