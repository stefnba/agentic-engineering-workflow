---
name: backlog
description: Read and maintain work/backlog.md — add items, mark them done, promote them to work items, or list what's pending for an area. Use this whenever the user mentions something to handle later, notices a bug they're not fixing right now, says "add to backlog" / "we should eventually" / "remind me to" / "note that down", reports finishing a backlog item, or asks what's outstanding for a given area of the codebase. Use it even when they don't say the word "backlog".
argument-hint: "[what to add, complete, or look up]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(find *), Bash(true)
---

# Backlog

`work/backlog.md` is the single list of unshaped ideas for this repo — features, bugs, refactors,
and migrations alike. An entry is a pointer to a conversation we'll have later, not the
conversation itself; items graduate out when the human picks one and `shape` turns it into a
bundle under `work/shaped/`. The file's value is that it reads top to bottom in under a minute —
the codebase holds the detail, this file holds the reminder.

## Tag vocabulary, computed just now

Every workspace package in the repo, resolved fresh each time this skill runs:

!`find . -maxdepth 3 -name package.json -not -path '*/node_modules/*' 2>/dev/null || true`

Each directory name above is a valid tag — `./apps/api/package.json` means `[api]`, whatever
layout the repo uses. The root `./package.json` is the repo itself, not an area — never a tag.
Tags that own no directory are declared in `work/backlog.md`'s header; if nothing beyond the
root file shows up, the header declares the whole vocabulary.

**Use only tags from this list plus the header — never coin one, and never infer the vocabulary
from tags already used in the file.** `references/entry-format.md` covers why, and what to do
when an item seems to fit no tag.

## Before any edit

**Read `work/backlog.md` in full first.** Its header declares the hand-declared tags, and
near-duplicate entries are common — sharpen an existing line rather than adding a second. If the
file doesn't exist, create it from this skill's `assets/template.md` (fill the tag header, drop
the template's comments), then continue.

**Glance at `work/shaped/` and `work/active/` too**, where they exist. If a work file there
already covers the thing, the backlog is the wrong home — say so and offer to record it in that
work item instead. A backlog line shadowing a live work item is duplicated state: the two copies
drift and neither is obviously stale.

## Operations

**Add** — read `references/entry-format.md` before writing the line; it defines the line shape,
tag discipline, and the boundary between too much and too vague. Append at the end of the
general list, immediately above the `## Trigger-gated` section if the file has one — everything
under that heading waits on an event, so a normal item filed there quietly contradicts the
heading. Position carries no priority: append, never insert or reshuffle.

**Complete** — delete the line. Git holds the history; a `## Done` section grows without bound
and nobody reads it. If the work produced a choice worth keeping, offer to invoke the
`decision` skill — that's where reasoning belongs, not here.

**Promote** — delete the line and offer to run `shape` on it, which creates the bundle under
`work/shaped/` (nothing lands in `work/` until shape commits a complete bundle — decision 0013).
Either way the item lives in exactly one place — duplicated state between backlog and work files
is the failure mode this structure exists to avoid.

**Look up** — grep by tag and show matching lines verbatim. Don't reformat or summarise them.

## Leave everything else alone

Only touch the lines the user asked about. Do not reword, reorder, re-tag, deduplicate, or
otherwise tidy entries you weren't asked to change, even when an entry is clearly poorly
worded — the user may be relying on the exact phrasing to recall the context. If something
looks wrong, mention it and let them decide.

## Reporting back

Show the lines that changed and nothing more:

```text
+ [server] no transaction support — repository ops can't run atomically
- [ui] date-range filters can't map to contract keys like startDate/endDate   (completed)
```

Don't print the full backlog, don't summarise its state, and don't suggest what to work on next
unless asked. The file is right there.
