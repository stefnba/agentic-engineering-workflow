---
name: record-decision
description: Write or supersede a decision record for the repository. A decision record is a short, self-contained document stating one settled design, tooling, or process choice, the alternatives that lost, and what it costs. Use when the user says "document this decision" or "write down why", overturns an existing record, or the land-bundle skill hands over a plan decision tagged for a record. Not for answering why something was built a certain way; the existing records answer that.
argument-hint: '[the decision to record, or the record to supersede]'
---

# Record a decision

Write one decision, that has already been made, into `<scope>/docs/decisions/`. You are recording a
settled choice, not making one — if the decision is still open, stop and say so rather than writing
a record that invents it. An open question belongs in the architecture doc as `Open: …`.

**Not every choice earns a record.** Write one only when all three hold:

- At least one real alternative was considered and lost. An alternative that gives wrong results
  or breaks a stated constraint was never viable and does not count.
- It binds work beyond the change that introduced it — later code, other members, or process.
- Someone could reasonably propose reversing it without knowing why it was made.

Otherwise say plainly where it belongs instead — declining to write the file is the right outcome
more often than not:

| The choice is…                                  | It belongs in                                                      |
| ----------------------------------------------- | ------------------------------------------------------------------ |
| A name, or one word over a synonym              | the scope's `GLOSSARY.md` (the `glossary` skill)                   |
| What a term or a value means                    | the scope's `GLOSSARY.md` (the `glossary` skill)                   |
| How a function computes its result              | that function's docstring and tests                                |
| A structural fact with no contested alternative | the scope's `ARCHITECTURE.md` (the `write-architecture-doc` skill) |
| A coding or process rule                        | the relevant `AGENTS.md` or conventions doc                        |
| Local to one change                             | the commit message body                                            |

## Path conventions

- `templates/` paths are relative to this skill's directory, the folder holding this file.
- `../writing/` is the sibling `writing` skill, in the same skills directory as this one.
- Every other path is relative to the repository root, `git rev-parse --show-toplevel`, not the
  current directory.

## Where it lives

**Put records in `<scope>/docs/decisions/`**, where the scope is the repository root in a
single-project repo and the member (`apps/<name>/`, `packages/<name>/`, …) the decision binds in a
monorepo. A decision that binds more than one member, or the repo's tooling or process, goes to the
root.

**When the repo already keeps decision records elsewhere (`adr/`, `doc/adr/`, …), use that location
and its file naming** (`0002-<slug>.md` after `0001-…`) for every record, member-specific or not.

**When the scope's `AGENTS.md` says where its records go, use that directory**, even when the
rule above would pick another; `setup-workflow` writes that line from the human's choice.

## Interview before drafting

Never draft a record from inference. `Rejected` is the section that gives the file its value, and an
invented alternative is worse than an absent one: it fabricates a debate that never happened, and
the next reader — human or agent — takes it for settled history.

Establish from the user, in their words:

1. Which alternatives were actually on the table, and what sank each one?
2. What this costs. Every real decision makes something worse; no stated cost usually means the
   tradeoff hasn't been found yet.
3. What would have to change for this to be reopened?

**A decision handed over from a plan at Land passes the same bar.** The plan's `Rejected` lines are
the interview: draft from them alone, and add no alternative the plan did not list. A tagged
decision that fails the bar gets no record; name the owner the table above gives it, and the
Land hand-back says so.

If the user can't name an alternative that lost, it was the default rather than a decision — say so
and route it to the owner the bar names.

## Write it

1. **Read the existing records** in the scope's `docs/decisions/`, and in the root's when the scope
   is a member — a decision that narrows or reverses one of them supersedes it, and you can't tell
   without looking.
2. **Draft from `templates/decision-record.md`, after reading `../writing/references/explain.md`**, the sibling `writing` skill's prose rules for a document that explains; where they disagree, the template wins. File it as
   `<scope>/docs/decisions/<YYYY-MM-DD>-<slug>.md`, with the slug naming the subject, not the verdict. The
   template's frontmatter is the metadata form even where an older record carries those fields in
   its body instead; immutability keeps those as they are rather than retrofitting them.
3. **Tag `areas:` by reusing a term an existing record already uses.** Where the repo defines
   commit scopes (see its `AGENTS.md` or contributing guide), use those. Otherwise use the member's
   name, or for a root record the repo-wide concern it binds (`ci`, `docs`, `tooling`). Never coin a
   near-synonym of a term already in use.
4. **Write the file directly; the uncommitted diff is the review.** Skip pasting the draft into
   chat — the human reads it in the working tree, where a diff is easier to review than a chat
   message. Until the commit, the file is still a draft: revise it in place on feedback.
   Immutability starts at the commit, not at the write.
5. **Link it from the scope's `ARCHITECTURE.md`**, when that file has a _Decisions_ section: add
   `YYYY-MM-DD · <H1 claim> · [record](decisions/<file>.md)`, replace any `Open: …` line the record
   settles, and for a supersede mark the old line _(superseded)_ with a link to the new one.

## What makes it self-contained

The reader is someone hitting this decision months later with none of this conversation.

- **The H1 states the decision as a claim** — "Settings a script reads are not prose", not
  "Configuration approach".
- **Decision is present tense: what holds now.** Not what was proposed, discussed, or tried.
- **Use the scope's `GLOSSARY.md` terms** for domain concepts, so the record reads the same as the
  architecture doc and the code.
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

The one permitted edit to an existing record is its frontmatter: `status` becomes `superseded`, or
`partially-superseded` when only a part falls, and `superseded_by` links the new record — naming
which part, for a partial — so a reader landing on the old record is sent forward. Nothing else in
it changes, including the parts that turned out to be wrong.

## Reporting back

Name the file you wrote and the record it supersedes, if any. Don't restate the decision — the user
just answered every question in it. Propose the commit and stop: commit only after the human has
read the record and said to.
