---
name: recap
description: Report this conversation back to the human — its subject, what it settled, what is still open. Use when the user asks where things stand, what has been covered or decided so far, what is still open, what they were working on, or says "catch me up", "remind me", "where were we", "summarize this session" — including after a long gap, a switch back to an old tab, or a context compaction. Not for writing a resumable document for a fresh agent, which is `handoff`, and not for repository, bundle, or ticket state, which `bundle-git` derives.
disallowed-tools: Read, Write, Edit, NotebookEdit, Glob, Grep, Bash, BashOutput, KillShell, WebFetch, WebSearch, Task, Agent, Skill, SlashCommand, TodoWrite
---

# Recap this conversation

You report what this conversation holds, and that is all you do. You change nothing, dispatch
nothing, and pass no gate — including in a session where the next action is obvious and overdue.

## Recall only

**Report from the conversation alone.** It is the only source: read no file, run no command, search
nothing, dispatch nothing. What the conversation does not establish, the recap does not claim.

**Where an answer would need a look, say the conversation does not establish it**, and name what
would settle it. Going to check turns a recap into a fresh investigation, and the human asked what
was said.

**Part of that is structural, and the rest is on you.** The `disallowed-tools` field above removes
the reading, writing, running, searching, and dispatching tools from the pool while this skill is
active. It reaches no further: a tool it does not name — one added since, one an MCP server supplies
— stays callable, and so does everything on the next turn, because the restriction clears at the
next user message. Hold to those anyway; the withholding is the point of the skill, not a side
effect of a field.

## What the report says

One message, in this shape and with nothing around it:

```markdown
**From memory of this conversation — not checked against the repository.**

**Subject** — the auth-token refactor: replacing the hand-rolled session cookie with signed tokens.

**Discussed** — three storage options for the signing key; whether existing sessions need a
migration; a suggestion to log verification failures at warn level.

**Settled** — the key goes in the existing secrets file, not a new one. Existing sessions expire
rather than migrate. Nothing has been written yet.

**Open** — the log level for verification failures. Whether the refresh window is 24 hours or 7 days.

**Gate** — the Plan gate is due: the bundle draft was called complete. It may have moved since.
```

**Subject** — what this session is about, in a line or two.

**Discussed** — a brief digest of what came up and what was suggested. Compress; this part is the
one that runs long.

**Settled** — what the conversation decided or completed, kept separate from what it only floated.
Answer it from what the conversation says was settled, never from what the repository would show.

**Open** — the threads that have no resolution yet.

**Gate** — see below.

**Say a part is empty rather than dropping it**: "nothing settled yet" reports; a missing line reads
as forgotten. The gate line is the exception — it appears only under the condition below.

## Gates

**Name the due gate only when this conversation established it**, and mark it as possibly moved
since — a gate can be passed in another session, and this one would not know.

**Say nothing about gates when the conversation did not establish gate state.** Inferring one from
the kind of work in the session is a guess presented as a report.

**Naming a gate is the whole of it.** Propose no action, offer to take none, and never present a
recap as satisfying a gate. The three gates are the human's alone
(`${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md`, Human authority).

## Report honestly

**Frame it as recollection, not as checked fact** — the opening line of the shape above does this,
and the body stays consistent with it. Nothing here has been verified, and a long session's recall
drifts.

**Say so when the earliest thing you can see is a summary** rather than the conversation's own
start: what came before it is compacted, and the recap covers only what survived.

**Recap a session with no repository work in it just the same** — a discussion, a question answered,
an idea turned over. Subject, digest, settled, open. There being no branch, bundle, or ticket in the
session is not a reason to report less.

**Point at `handoff` when the human wants this kept.** A recap persists nothing, by design; writing
the session down is that skill's job.
