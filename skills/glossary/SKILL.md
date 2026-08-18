---
name: glossary
description: Caretaker for GLOSSARY.md, the repo's canonical domain vocabulary. Use whenever a conversation defines a domain term, disambiguates one word from another, renames a term, or settles on one word over a synonym — even when nobody says "glossary". Propose the exact entry and write only after the user confirms.
argument-hint: "[term to capture, or nothing to browse]"
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Glossary

`GLOSSARY.md` is a repo's canonical domain vocabulary — one entry per term, each a
one-to-two-sentence definition of what the term *is* (not what it does) plus an _Avoid_ list
of rejected synonyms. Only terms specific to the project's domain qualify: general
programming concepts (timeouts, error types, utility patterns) are excluded even when heavily
used. The file holds vocabulary only — no implementation details, no spec content, no scratch
notes.

## Before any edit

**Read the target glossary in full first** (see Routing below for which one). If it doesn't
exist yet, that's fine — never nag about a missing glossary. Create it only lazily, on the
first confirmed capture, from this skill's `assets/template.md`.

## Routing (monorepo)

A term specific to one workspace package's domain belongs in that domain's own
`GLOSSARY.md`, at the domain root. A cross-cutting term belongs in the root `GLOSSARY.md`,
which also carries a Domains section linking each sub-glossary and stating the relationships
between domains — no separate map file, and the section exists only when sub-glossaries do.
Infer which glossary a term belongs to from the topic; ask when it's unclear.

## Capture

Propose the exact entry — term, definition, _Avoid_ list — and wait for the user to confirm
before writing anything. Never write an unconfirmed entry.

## Renames

The glossary is mutable, edited in place; history is git's. A rename edits the entry in place
and moves the old term into _Avoid_ — never delete and recreate. (Contrast: `docs/decisions/`
records are immutable-supersede, never edited.)

## Boundary with `record-decision`

A naming or term choice is a glossary entry, not a decision record. A term choice that
encodes a contested architectural trade-off routes to the `record-decision` skill instead.

## Reporting back

Show the lines that changed and nothing more. Don't print the whole glossary and don't
summarise its state.
