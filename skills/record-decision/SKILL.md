---
name: record-decision
description: Write or supersede a decision record for the repository. A decision record is a short, self-contained document stating one settled design, tooling, or process choice, the alternatives that lost, and what it costs. Use when the user says "document this decision", "write down why", asks why something was built a certain way, or overturns an existing record. It is not a session driver.
argument-hint: "[the decision to record, or the record to supersede]"
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Record decision

Write one decision that has already been made into `${CLAUDE_PROJECT_DIR}/docs/decisions/`. You are
recording a settled choice, not making one — if the decision is still open, stop and say so rather
than writing a record that invents it.

Not every choice earns a record. Before writing, check the decision against the **Decision records**
section of `${CLAUDE_PLUGIN_ROOT}/workflow/artifacts.md` — the bar, and where a choice that misses
it belongs instead; say plainly when it doesn't clear it.
Declining to write the file is the right outcome more often than not.

## Interview before drafting

Never draft a record from inference. `Rejected` is the section that gives the file its value, and an
invented alternative is worse than an absent one: it fabricates a debate that never happened, and
the next reader — human or agent — takes it for settled history.

Establish from the user, in their words:

1. Which alternatives were actually on the table, and what sank each one?
2. What this costs. Every real decision makes something worse; no stated cost usually means the
   tradeoff hasn't been found yet.
3. What would have to change for this to be reopened?

If the user can't name an alternative that lost, it was the default rather than a decision — say so
and route it to the owner the bar names.

## Write it

1. **Read the existing records** in `${CLAUDE_PROJECT_DIR}/docs/decisions/` — a decision that
   narrows or reverses one of them supersedes it, and you can't tell without looking.
2. **Draft from `${CLAUDE_SKILL_DIR}/templates/decision-record.md`.** File it as
   `docs/decisions/<YYYY-MM-DD>-<slug>.md`, with the slug naming the subject, not the verdict. The
   template's frontmatter is the metadata form even where an older record carries those fields in
   its body instead; immutability keeps those as they are rather than retrofitting them.
3. **Tag `areas:` by reusing a term already in use.** The records you just read carry the
   vocabulary and so do `${CLAUDE_PROJECT_DIR}/work/backlog.md`'s lines; there is no declared list —
   when unsure what makes a term usable, read the **Areas** section of
   `${CLAUDE_PLUGIN_ROOT}/workflow/artifacts.md`. Coin a new area only when nothing there fits, never as a near-synonym of a
   term that does.
4. **Confirm the draft with the user before writing.** A record is immutable once written, so a
   wrong claim costs a second record to correct. Show the whole draft — it is short by design.

## What makes it self-contained

The reader is someone hitting this decision months later with none of this conversation.

- **The H1 states the decision as a claim** — "Settings a script reads are not prose", not
  "Configuration approach".
- **Decision is present tense: what holds now.** Not what was proposed, discussed, or tried.
- **Name the concrete things it binds:** files, settings, commands. A record whose Decision could
  apply to any repository is too vague to enforce.
- **`Rejected`, `Costs`, and `Revisit if` are what let a reader who disagrees tell whether their
  objection was already weighed.** A record that only announces the outcome is worthless at the
  moment someone wants to reopen it.

## Superseding

Records are immutable — never edit a record's body to make history look current. A new decision goes
in a new record whose `supersedes` names what it replaces, and which may replace one part of an
earlier record rather than all of it; say which part. Its `Context` says briefly what changed since
the original.

The one permitted edit to an existing record is its `status` line, set to `superseded by <link>`, so
a reader landing on the old record is sent forward. Nothing else in it changes, including the parts
that turned out to be wrong.

## Reporting back

Name the file you wrote and the record it supersedes, if any. Don't restate the decision — the user
just answered every question in it.
