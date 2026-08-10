---
name: decision
description: Write or supersede a decision record in docs/decisions/. Use when the user has made an architectural or design choice they want captured, says "document this decision" / "write this down" / "let's record why", asks why something was built a certain way, or is wrapping up a work item that involved a contested call. Also use when a new choice overturns an existing decision record.
argument-hint: '[the decision, or the number to supersede]'
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Decision records

`docs/decisions/NNNN-kebab-slug.md` holds choices that were **contested, consequential, and
non-obvious from the code**. All three conditions, not any one.

The test: if someone changed this next year without knowing the reasoning, would something break,
or would they waste a week rediscovering why? If no, it doesn't belong here.

Most work items produce zero decision records. A handful a year in a repo is healthy. Twenty means
the bar has slipped and the folder has become a log — at which point nobody reads any of it, and
the ones that mattered are lost among the ones that didn't.

## What goes elsewhere

- Conventions and style — `.agents/rules/general.md`
- Gotchas specific to one area of the code — that area's file in `.agents/rules/`
  (`api.md`, `web.md`, `domain.md`, `packages.md`)
- A record of what was built — the work item file in `work/done/`
- Anything the code already states plainly — nowhere

The `AGENTS.md` files scattered through the repo are **symlinks** into `.agents/rules/`, so a
single write there reaches Claude, Cursor and Codex at once. Always edit the `.agents/rules/`
file directly; writing through a symlink path works but hides which file you actually changed,
and the next reader can't tell the rule is shared.

## Interview before writing

Do not draft a decision record from inference. The section that gives these files their value is
**Rejected**, and a fabricated alternative is worse than an absent one: it invents a debate that
never happened, and future readers — human or agent — will treat it as settled history.

Before writing, establish from the user:

1. What alternatives were actually considered, and why each was set aside.
2. What this costs — every real decision has a downside, and one with no stated cost usually means
   the tradeoff hasn't been found yet.
3. Under what conditions it should be reconsidered.
   If the user can't name a rejected alternative, that's the signal it wasn't a decision — it was the
   default. Say so plainly and suggest the convention or area doc instead. Declining to write the
   file is the correct outcome more often than not.

## Numbering

List `docs/decisions/`, take the highest existing number, add one. Zero-pad to four digits.
Filename is the number plus a kebab-case slug of the decision itself:
`0003-rotate-refresh-tokens-on-use.md`.

While listing the directory, read the two most recent records. They are the style exemplar — match
their length, their level of detail, and how directly they state things. Written records drift
toward whatever the repo has actually settled on, and that's more accurate than the template
below. If the directory is empty, follow the template as written.

## Template

Keep it under a page. If it runs longer, the decision is probably several decisions.

Start from [template.md](template.md), shipped with this skill — each section carries its own guidance in place.

Title the file with the decision, not the subject area. `0003 Rotate refresh tokens on use` tells a
reader scanning the folder what was decided. `0003 Token handling` makes them open the file.

## Immutability

Accepted records are not edited. If the reasoning changes, write a new record and mark the old one in its frontmatter:

```yaml
status: superseded
superseded_by: "0009"
```

Change only those frontmatter lines in the old file — leave its body exactly as written, including the
parts that turned out to be wrong. The sequence of records is the reasoning history of the
codebase, and editing them in place destroys the only thing that made them worth keeping.

When superseding, the new record's Context should say briefly what changed since the original.

## After writing

Report the path and the one-line decision statement. Don't summarise the file back — the user just
answered every question in it.
