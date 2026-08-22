---
name: recap
description: Report this conversation back to the human — its subject, what it settled, what is still open. Use when the user asks where things stand, what has been covered or decided so far, what is still open, what they were working on, or says "catch me up", "remind me", "where were we", "summarize this session" — including after a long gap, a switch back to an old tab, or a context compaction. Not for writing a resumable document for a fresh agent, which is `handoff`, and not for repository, bundle, or ticket state, which `bundle-git` derives.
disallowed-tools: Agent, Artifact, Bash, CronCreate, CronDelete, CronList, Edit, EnterWorktree, ExitWorktree, Glob, Grep, LSP, ListAgents, ListMcpResourcesTool, Monitor, NotebookEdit, PowerShell, PushNotification, Read, ReadMcpResourceTool, RemoteTrigger, ReportFindings, ScheduleWakeup, SendMessage, SendUserFile, ShareOnboardingGuide, Skill, TaskCreate, TaskGet, TaskList, TaskOutput, TaskStop, TaskUpdate, TodoWrite, ToolSearch, WaitForMcpServers, WebFetch, WebSearch, Workflow, Write
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

**Part of that is structural, and the rest is on you.** The `disallowed-tools` field above names
every built-in tool that reads, writes, runs, searches, or dispatches, and removes each one from the
pool while this skill is active. The four built-ins left available — `AskUserQuestion`,
`EnterPlanMode`, `ExitPlanMode`, `EndConversation` — do none of those things.

**The field reaches no further than the names in it.** A tool added to the platform since this list
was written, a tool an MCP server supplies, and every turn after this one — the restriction clears
at the next user message — stay callable. Hold to the boundary there anyway: the withholding is the
point of the skill, not a side effect of a field.

## What the report says

**One message, in the shape below, with nothing around it.** Fill every part; the comments are fill
guidance and never reach the human. Keep the blank lines — heading, blank, content, blank.

```markdown
Here's the recap:

## Subject

<!-- One sentence. Example:
auth-token refactor: hand-rolled session cookie → signed tokens. -->

<what this session is about>

## Discussed

<!--
What came up and what was suggested. Compress hardest here — this is the part that runs long.

Maximum of 3-5 bullets.


Example:
- three storage options for the signing key
- whether existing sessions need a migration
- logging verification failures at warn level
-->

- <item>

## Settled

<!--
What the conversation decided or completed, kept apart from what it only floated. From what the
conversation says was settled, never from what the repository would show.

Maximum of 3-5 bullets.

Example:
- key goes in the existing secrets file, not a new one
- existing sessions expire rather than migrate
- nothing written yet
-->

- <item>

## Open

<!--

Threads with no resolution yet.

Maximum of 3-5 bullets.

Example:
- log level for verification failures
- refresh window — 24 hours or 7 days

-->

- <item>

## Gate

<the due gate, marked as possibly moved since>

<!-- Only under the condition in Gates below; delete the heading with it otherwise. Example:
Plan gate due: the bundle draft was called complete. May have moved since. -->
```

**Bullets and fragments, not prose.** One bullet per item, a line or so each; drop articles and
linking verbs before you drop items. `Subject` is one sentence and `Gate` one line — everything else
is a list. A long session comes back as a scannable report, never as paragraphs.

**Say a part is empty rather than dropping it**: a heading over "nothing settled yet" reports; a
missing heading reads as forgotten. `Gate` is the only part that disappears when it does not apply.

## Gates

**Name the due gate only when this conversation established it**, and mark it as possibly moved
since — a gate can be passed in another session, and this one would not know.

**Say nothing about gates when the conversation did not establish gate state.** Inferring one from
the kind of work in the session is a guess presented as a report.

**Naming a gate is the whole of it.** Propose no action, offer to take none, and never present a
recap as satisfying a gate. The three gates are the human's alone
(`${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md`, Human authority).

## Report honestly

**Frame it as recollection, not as checked fact.** The report carries no banner saying so, so the
hedging has to live in the lines themselves — say which parts you are unsure of rather than
levelling everything to the same confidence. Nothing here has been verified, and a long session's
recall drifts.

**Say so when the earliest thing you can see is a summary** rather than the conversation's own
start: what came before it is compacted, and the recap covers only what survived.

**Recap a session with no repository work in it just the same** — a discussion, a question answered,
an idea turned over. Subject, digest, settled, open. There being no branch, bundle, or ticket in the
session is not a reason to report less.

**Point at `handoff` when the human wants this kept.** A recap persists nothing, by design; writing
the session down is that skill's job.
