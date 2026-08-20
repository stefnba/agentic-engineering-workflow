---
name: glossary
description: Caretaker for GLOSSARY.md, the repo's canonical domain vocabulary. Use whenever a conversation defines a domain term, disambiguates one word from another, renames a term, or settles on one word over a synonym — even when nobody says "glossary". Propose the exact entry and write only after the user confirms.
argument-hint: "[term to capture, or nothing to browse]"
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Glossary

`GLOSSARY.md` is a repo's canonical domain vocabulary — one entry per term, each a
one-to-two-sentence definition of what the term _is_ (not what it does) plus an _Avoid_ list
of rejected synonyms. Only terms specific to the project's domain qualify: general
programming concepts (timeouts, error types, utility patterns) are excluded even when heavily
used. The file holds vocabulary only — no implementation details, no spec content, no scratch
notes.

## Before any edit

**Read the target glossary in full first** (see Routing below for which one). The root
`GLOSSARY.md` normally exists (created by `setup` skill); an empty one is the steady state for a
repo that hasn't earned a term yet, so never nag about entries. Where no file exists — a domain
glossary, or a root one in a repo that skipped `setup` — create it on the first confirmed capture,
as a `# Glossary` heading and that entry in the form above. Nothing else goes in it: a heading with
no entry under it is a file worth not creating yet.

## Routing (monorepo)

The **Monorepos** section of `${CLAUDE_PLUGIN_ROOT}/workflow/artifacts.md` owns which glossary a
term belongs in, and what the root's `Domains` section holds. Read it before capturing anything in
a repo that has more than one `GLOSSARY.md`, or is about to.

What that leaves to you: infer the target from the term's subject and say which file you picked
when you propose the entry, so a wrong read is caught before it is written. Never create a domain
glossary for a term the root already covers — sharpen the root entry instead.

## Capture

Propose the exact entry — term, definition, _Avoid_ list — and wait for the user to confirm
before writing anything. Never write an unconfirmed entry.

## Renames

The glossary is mutable, edited in place; history is git's. A rename edits the entry in place
and moves the old term into _Avoid_ — never delete and recreate. (Contrast:
`${CLAUDE_PROJECT_DIR}/docs/decisions/` records are immutable-supersede, never edited.)

## Boundary with `record-decision`

A naming or term choice is a glossary entry, not a decision record. A term choice that
encodes a contested architectural trade-off routes to the `record-decision` skill instead.

## Reporting back

Show the lines that changed and nothing more. Don't print the whole glossary and don't
summarise its state.
