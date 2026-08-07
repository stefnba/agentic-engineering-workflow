---
name: backlog
description: Read and maintain docs/work/backlog.md — add items, mark them done, promote them to work items, or list what's pending for an area. Use this whenever the user mentions something to handle later, notices a bug they're not fixing right now, says "add to backlog" / "we should eventually" / "remind me to" / "note that down", reports finishing a backlog item, or asks what's outstanding for a given area of the codebase. Use it even when they don't say the word "backlog".
argument-hint: '[what to add, complete, or look up]'
allowed-tools: Read, Edit, Glob, Grep, Bash(ls *)
---

# Backlog

## Tag vocabulary, computed just now

Every workspace package in the repo, resolved fresh each time this skill runs:

!`ls -1 apps/*/package.json packages/*/package.json`

Each directory name above is a valid tag — `apps/api/package.json` means `[api]`, and so on. This
list is generated, not written down, so it cannot drift from the tree.

Some tags own no directory and therefore can't appear above; those are declared in
`docs/work/backlog.md`'s header. Read them from there.

`docs/work/backlog.md` is the single list of unshaped ideas for this repo. Unshaped is the point:
an entry is a pointer to a conversation we'll have later, not the conversation itself. Items
graduate out of it into `docs/work/planned/<slug>.md` once they're worth planning.

Work items are features, bugs, refactors, and migrations alike — the backlog doesn't distinguish,
and neither does `active/`.

The value of the file is that it can be read top to bottom in under a minute. Every extra word
costs a little of that. Optimise for scannability over completeness — the codebase holds the
detail, this file holds the reminder.

## Always read the file first

Read `docs/work/backlog.md` in full before any edit. Two reasons: its header declares the valid
tag vocabulary, and near-duplicate entries are common — if something similar is already there,
sharpen the existing line instead of adding a second one.

Before adding, glance at `docs/work/planned/` and `docs/work/active/` too. If a work file there
already covers the thing, the backlog is the wrong home for it — say so, and offer to add it to
that file's Plan or Open questions instead. A backlog line shadowing a live work item is the
duplicated state this whole structure exists to avoid, and it's worse than a missing line
because the two copies drift and neither is obviously stale.

## Tags

Use the list at the top of this file, plus whatever the backlog header declares. Nothing else.

The list is generated per invocation rather than written down because a hardcoded vocabulary goes
stale the moment a package is added, and a stale list is worse than none — it looks authoritative,
so nobody rechecks it. It resolves `package.json` files rather than directories so the answer is
"the workspace packages" and not "whatever folders exist": `packages/` also holds a `README.md`
and an `AGENTS.md` that are not areas.

**Don't infer the vocabulary from tags already used in the file.** Usage is a subset of what's
valid — if nobody has filed a `duckdb` item yet, looking at prior use finds nothing and invites
a plausible-sounding substitute like `[db]` or `[sql]`. Synonyms are the specific failure this
vocabulary prevents: once `[db]`, `[database]` and `[duckdb]` coexist, every grep silently
misses most of the matching items, and nothing about the file looks wrong.

If an item genuinely fits no directory and isn't infra or workflow, ask rather than coining
something. In practice that combination usually means the item is scoped wrong — it's really
two items, or a work item — not that the vocabulary has a gap.

Multiple tags are fine when an item genuinely spans areas: `- [core][client] ...`. Two is
usually the honest maximum; if you're reaching for three, the item is probably a work item, not
a backlog line.

## Entry format

One line, imperative, under about twelve words:

```text
- [tag] short imperative phrase
```

Sub-bullets are allowed only when the line is meaningless without them, and never more than two.
They capture constraints or evidence, not implementation plans.

Write the problem, not your proposed solution. The solution is what the planning conversation is
for, and a solution written now will be stale or wrong by the time it's read.

**Good:**

```text
- [server] no transaction support — repository ops can't run atomically
- [api] bulk-op contract makes the client send server-owned scope fields
- [core][client] list endpoints each hand-split searchParams into filters/pagination
- [ui] date-range filters can't map to contract keys like startDate/endDate
```

**Too much:**

```text
- [auth] Implement refresh token rotation
  - Add a `token_families` table with columns id, user_id, created_at
  - On refresh, issue a new token and mark the old one used
  - If a used token is presented again, invalidate the whole family
  - Consider a 10s grace window for in-flight requests
```

That's a plan. Say so, and offer to create `docs/work/planned/auth-refresh.md` instead.

**Too vague:**

```text
- [ui] improve components
- [server] performance
```

An entry that won't mean anything in three weeks is worse than no entry, because it occupies a
line and creates a small obligation to work out what it meant. Ask for one concrete detail rather
than writing a placeholder.

## Operations

**Add** — append at the end of the **ranked** list, immediately above the `## Trigger-gated`
section if the file has one. Never append inside Trigger-gated: everything there is waiting on an
event rather than a priority, so a normal item filed under that heading quietly contradicts both
the heading and the order-is-priority rule, and nothing about the file looks wrong afterwards.

Order carries priority, so an item's position is the user's call, not yours: only place something
higher when they say it's urgent, and never reshuffle the list to make room.

**Complete** — delete the line. Git holds the history; a `## Done` section grows without bound and
nobody reads it. If the work produced a choice worth keeping, mention it and offer to invoke the
`decision` skill — that's where reasoning belongs, not here.

**Promote** — delete the line from the backlog and offer to create `docs/work/planned/<slug>.md`.
Promotion lands in `planned/`, not `active/`: the item now has somewhere to hold a plan but
nobody has started it, and `active/` is reserved for work actually in flight. The item lives in
exactly one place either way — duplicated state between backlog and work files is the failure
mode this structure exists to avoid.

**Look up** — grep by tag and show matching lines verbatim. Don't reformat or summarise them.

## Leave everything else alone

Only touch the lines the user asked about. Do not reword, reorder, re-tag, deduplicate, or
otherwise tidy entries you weren't asked to change, even when an entry is clearly poorly worded.
The user wrote it that way and may be relying on the exact phrasing to recall the context. If
something looks wrong, mention it and let them decide.

## Reporting back

Show the lines that changed and nothing more:

```text
+ [server] no transaction support — repository ops can't run atomically
- [ui] date-range filters can't map to contract keys like startDate/endDate   (completed)
```

Don't print the full backlog, don't summarise its state, and don't suggest what to work on next
unless asked. The file is right there.
