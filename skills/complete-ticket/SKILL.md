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

Both arguments come from the human, and the SHA is required — the head the last Reviewer round's
final summary was tied to, never resolved here. **Never substitute `gh pr view`'s current head for
it.** That would treat whatever commit is sitting on the branch — including one pushed straight to
it, outside Review — as if it had been reviewed, which is exactly the gap requiring the SHA closes.
If the human doesn't have it to hand, point them at the last round's summary; the script itself now
refuses to run without it.

### 2. Merge

Run:

```text
${CLAUDE_PLUGIN_ROOT}/scripts/complete-ticket.sh <pr> <accepted-head-sha>
```

Treat a non-zero exit as a stop, never something to retry or work around — its message states the
reason and the next action; report it as printed. Exit `2` (stale against its base) goes back to
the ticket's own session: the base merged in, re-verified, another review round.

### 3. Report and stop

Report the script's output, then stop. The next ticket is a fresh tab and the human's dispatch.
