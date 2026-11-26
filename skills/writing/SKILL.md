---
name: writing
description: Use before writing, editing, or reviewing any Markdown document — a SKILL.md, an AGENTS.md or CLAUDE.md, a runbook, a prompt file, a README, an ARCHITECTURE.md, a decision record, a doc under docs/ — including a line added to one while doing other work, and when the user says "document this" or "write up". Also use when a reader says a doc is too long or hard to follow, or an agent ignores, skips, or never triggers on a document. Not for commit messages, PR bodies, code comments, or docstrings.
---

# Writing

**Ask of the document: does it tell the reader what to do, or how something is?** A document that steers — a skill, an instructions file, a runbook, a prompt, a how-to someone follows step by step — steers whoever reads it; a person follows a runbook as well as an agent does. A document that explains — an architecture doc, a stage or component explainer, a decision record, a README, a report — explains to an agent as much as to a person.

**Read `references/steer.md` before writing, editing or reviewing a document that steers.**

**Read `references/explain.md` before writing, editing or reviewing a document that explains.**

**Open your reply with the kind you judged the document to be**, so the human sees the choice and can overrule it.

**When a document does both, apply the rules of the kind most of its lines belong to.**

**Name the lines of the other kind in your reply**; whether to move them is the human's call.

## Rules for both kinds

**Name the members of a set, or point at where they live, and leave the count out.** This holds for any set that can gain or lose a member, such as files, functions, steps, options, rules or sections. Write "the files in `guides/`", not "the four files in `guides/`". A list or table shows its own length, and a count is wrong after the next addition.

**Keep a count that is the evidence for a claim, with how it was counted beside it**: "every skill sets `name` (15 of 15, counted with grep)".

## Path conventions

- `references/` paths are relative to this skill's directory, the folder holding this file.
