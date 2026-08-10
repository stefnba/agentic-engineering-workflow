---
name: docs-rules
description: Procedural rules distilled from docs/docs-structure.md — ID resolution, README-over-spec precedence, target-state phrasing, ticket format, backlog line format, the freeze rule. Reference material preloaded into workflow subagents; not an action to invoke directly.
user-invocable: false
---

# docs-rules

Distilled from `docs/docs-structure.md`, which stays authoritative — this file states the same rules without the reasoning behind them. When something isn't covered here, read that doc instead of guessing.

## Resolve IDs, never hardcode or remember them

A feature's parent directory (`candidates/`, `planned/`, `active/`) _is_ its status, and status changes as work moves. Never hardcode a path and never assume the status from an earlier session — re-resolve every time:

```bash
ls work/*/<id>-*
```

In repo markdown, reference a feature by ID in prose (`0042`), not as a markdown link — a link is a literal relative path and 404s on the next `git mv`. In PR descriptions, use a GitHub permalink instead.

## Colocated README beats spec.md

When a colocated `README.md` and a feature's `spec.md` disagree, the README wins: it describes what the system _is_; the spec describes what someone _intended_. Read the colocated README before trusting a spec's claims about existing code.

## spec.md is target-state, not a diff

Write `spec.md` in present tense, describing the system as it will exist — "the retry scheduler reads from `billing_events`" — never "add a retry scheduler." Delta phrasing is only true before work starts; an agent picking up ticket 4 of 7 can't tell which deltas already landed.

Headings are fixed across every spec, so tickets can deep-link to them:

```markdown
## Problem

## Target state

## Non-goals

## Open questions

## Acceptance criteria
```

Open questions resolves in place, it doesn't empty out. Every line needs `[resolved] <question>? → <answer>` before implementation starts; unresolved lines block. Evidence questions (cite the file) the agent resolves itself; judgment questions only the human resolves. A question that appears mid-implementation gets added unresolved — never decided unilaterally.

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

Slice by what must be true when the PR merges, not by file or layer. Every ticket needs a machine-checkable done condition — if you can't write the check, the ticket isn't specified yet. Don't duplicate the spec's reasoning here; link to it.

## Backlog lines

`work/backlog.md` is the single, unsorted collection point for unshaped ideas — order carries no meaning, and nothing bypasses it (audit findings, research follow-ups, and ship-time leftovers all land here as lines).

```text
- [tag] short imperative phrase
```

- One line, imperative, under about twelve words. Write the **problem, not your proposed solution** — the solution belongs to shaping and will be stale by the time it's read.
- Tags come from the vocabulary the backlog's header declares (plus workspace packages where they exist). Never coin a synonym: once `[db]` and `[database]` coexist, every grep silently misses half the matches.
- Append at the end of a section; never reshuffle the list.
- Sub-bullets only when the line is meaningless without them, at most two, carrying constraints or evidence — pointers to `docs/research/` files are fine (those paths never move).
- Completed lines are deleted, not archived — git holds the history.

## The freeze rule

`brief.md` is written during interview, before any spec exists. It freezes the moment `spec.md` exists: from then on, `brief.md` is the record of what was asked, `spec.md` is what's being done about it, and when they disagree, `spec.md` wins. Never edit a frozen brief.
