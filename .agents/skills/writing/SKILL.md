---
name: writing
description: Use before writing, editing, or reviewing any Markdown document — a SKILL.md, an AGENTS.md or CLAUDE.md, a runbook, a prompt file, a README, an ARCHITECTURE.md, a decision record, a doc under docs/ — including a line added to one while doing other work, and when the user says "document this" or "write up". Also use when a reader says a doc is too long or hard to follow, or an agent ignores, skips, or never triggers on a document. Not for commit messages, PR bodies, code comments, or docstrings.
---

<!-- Maintainers: tests/explain-baseline.md holds the prompts, failures and decisions behind each rule of the explain branch; rerun its prompts after changing a line. -->

# Writing

**Ask of the document: does it tell the reader what to do, or how something is?** A document that steers — a skill, an instructions file, a runbook, a prompt, a how-to someone follows step by step — steers whoever reads it; a person follows a runbook as well as an agent does. A document that explains — an architecture doc, a stage or component explainer, a decision record, a README, a report — explains to an agent as much as to a person.

**Read `references/steer.md` before writing, editing or reviewing a document that steers.** It holds every rule for that kind.

**Read `references/explain.md` before writing, editing or reviewing a document that explains.** It holds every rule for that kind.

**Open your reply with the kind you judged the document to be**, so the human sees the choice and can overrule it.

**Write a document that does both under the kind most of its lines are.**

**Name the lines of the other kind in your reply**; whether to move them is the human's call.

## Path conventions

- `references/` paths are relative to this skill's directory, the folder holding this file.
