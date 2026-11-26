---
name: glossary
description: Caretaker for GLOSSARY.md, the repo's canonical domain vocabulary. Use whenever a conversation defines a domain term, disambiguates one word from another, renames a term, or settles on one word over a synonym — even when nobody says "glossary". Propose the exact entry and write only after the user confirms.
argument-hint: '[term to capture, or nothing to browse]'
---

# Glossary

`GLOSSARY.md` is a canonical domain vocabulary — one entry per term, each a
one-to-two-sentence definition of what the term _is_ (not what it does). Only terms specific to
the project's domain qualify. Known technical terms are excluded. The file holds
vocabulary only — no spec content, no scratch notes.

Entry form, grouped under topic headings as the file grows:

```markdown
- **Term** (`CodeName`): what the term is, in one or two sentences. _Avoid_: synonym, synonym.
```

The code name is the one implementation detail an entry carries — the type or key that
carries the term, so architecture docs and specs can use the term while code uses the name.
Omit it when no code carries the term yet. _Avoid_ lists only the words the user rejected — omit it
until one has been.

## Path conventions

- Every path is relative to the repository root, `git rev-parse --show-toplevel`, not the current
  directory.

## Where it lives

**Put the glossary at `<scope>/docs/GLOSSARY.md`**, where the `<scope>` is the repository root in a
single-project repo and the member (`apps/<name>/`, `packages/<name>/`, …) the term belongs to in a
monorepo. A term moves to the root glossary once a second member uses it; never duplicate a root
term in a member glossary — sharpen the root entry instead.

**When the repo already keeps a glossary elsewhere, use that location.**

**When the scope's `AGENTS.md` says where its terms go, use that file**, even when the rule above
would pick another; `setup-workflow` writes that line from the human's choice.

## Before any edit

**Read the target glossary in full.** Name the file you picked when you propose the entry, so a
wrong read is caught before it is written. Where no file exists, create
`<scope>/docs/GLOSSARY.md` (and `docs/`) on the first confirmed capture, as
`# <Project name> — Glossary` and that entry, taking the name from the scope's README title. An absent or empty glossary is normal; never nag about entries.

## Capture

Propose the exact entry — term, code name, definition, _Avoid_ list — and wait for the user to
confirm before writing anything. Never write an unconfirmed entry.

## Renames

The glossary is mutable, edited in place; history is git's. A rename edits the entry in place
and moves the old term into _Avoid_ — never delete and recreate. Then grep the scope's
`ARCHITECTURE.md` and name every line that still uses the old term, so the user can update it in
the same change.

Contrast: `<scope>/docs/decisions/` records are immutable-supersede, never edited.

## Boundary with `record-decision`

A naming or term choice is a glossary entry, not a decision record. A term choice that encodes a
contested architectural trade-off also gets a record: hand that part to the `record-decision`
skill.

## Reporting back

Show the lines that changed and nothing more. Don't print the whole glossary and don't
summarise its state.
