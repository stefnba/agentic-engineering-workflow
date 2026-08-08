---
name: docs-rules
description: Procedural rules distilled from docs/docs-structure.md — ID resolution, README-over-design precedence, target-state phrasing, ticket format, the freeze rule. Reference material preloaded into workflow subagents; not an action to invoke directly.
user-invocable: false
---

# docs-rules

Distilled from [docs/docs-structure.md](../../docs/docs-structure.md), which stays authoritative — this file states the same rules without the reasoning behind them. When something isn't covered here, read that doc instead of guessing.

## Resolve IDs, never hardcode or remember them

A feature's parent directory (`candidates/`, `planned/`, `active/`) _is_ its status, and status changes as work moves. Never hardcode a path and never assume the status from an earlier session — re-resolve every time:

```bash
ls docs/work/*/<id>-*
```

In repo markdown, reference a feature by ID in prose (`0042`), not as a markdown link — a link is a literal relative path and 404s on the next `git mv`. In PR descriptions, use a GitHub permalink instead.

## Colocated README beats design.md

When a colocated `README.md` and a feature's `design.md` disagree, the README wins: it describes what the system _is_; the design describes what someone _intended_. Read the colocated README before trusting a design doc's claims about existing code.

## design.md is target-state, not a diff

Write `design.md` in present tense, describing the system as it will exist — "the retry scheduler reads from `billing_events`" — never "add a retry scheduler." Delta phrasing is only true before work starts; an agent picking up ticket 4 of 7 can't tell which deltas already landed.

Headings are fixed across every design doc, so tickets can deep-link to them:

```markdown
## Problem

## Target state

## Non-goals

## Open questions

## Acceptance criteria
```

Open questions must be empty before implementation starts. A question that appears mid-implementation gets added here, not decided unilaterally.

## Ticket format

```markdown
---
status: todo # todo | doing | done
depends_on: [01]
---

# NN — Title

## Scope

## Done when

## Not in this ticket
```

Slice by what must be true when the PR merges, not by file or layer. Every ticket needs a machine-checkable done condition — if you can't write the check, the ticket isn't specified yet. Don't duplicate the design's reasoning here; link to it.

## The freeze rule

`brief.md` is written during interview, before any design exists. It freezes the moment `design.md` exists: from then on, `brief.md` is the record of what was asked, `design.md` is what's being done about it, and when they disagree, `design.md` wins. Never edit a frozen brief.
