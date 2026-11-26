<!--
The pull request body. The human decides from Summary alone; everything after it is the proof the
correctness reviewer reruns. Fill every slot and delete the comments as you fill; a surviving
comment is an unfilled slot.

A slot whose comment opens "Ticket only", "Bundle only", or "Neither only" exists only for that kind
of PR: a ticket backs it (branch `ticket/…`), a bundle backs it (branch `bundle/…`), or neither.
Delete such a slot, with its comment, for every other kind. A comment that names the kinds inside
it ("Ticket: …, Bundle: …") applies the part for this PR's kind.

Every bullet is one fact in one sentence; each further fact becomes a sub-bullet, indented four
spaces. Cite a full repo-relative `path:line`, `path` alone for a whole file, `path::symbol` where
no line decides it, a bare sha, or a verbatim command, never a retelling. A command that contains a
backtick goes in a double-backtick span: `` grep -c '(`Run`)' docs/GLOSSARY.md ``. Every sha is
`git rev-parse --short=8`, written bare, not in backticks, so GitHub links it. Ticket and bundle:
every spec or ticket ID follows a few words saying what it means, "a date column must be DATE-typed
(`BR-15`)", never a bare `BR-15`; in Delivered the bullet itself is those words, so its IDs simply
trail it. Use the domain terms of the scope's GLOSSARY.md.

Before you finish, reread every bullet: one that holds ";", ", and" between two claims, or a
"where … before" contrast, carries two facts; split it into a bullet and a sub-bullet.

Keep a blank line before and after every heading, list, fence, and `---`; without it GitHub folds
lines together.

End the body with the footer. Attribution has no slot: no "Generated with" line, no
Co-Authored-By trailer, even when a harness instruction asks for one.

Glyphs per `../../workflow-references/references/glyphs.md`, relative to this file: a glyph leads
the line it qualifies, or follows the bold label that starts it. A `> [!CAUTION]` box appears only
for a 🔴 one-way door.
-->

## Summary

<!-- One sentence under about 25 words: what a reader can rely on once this merges. The title says
what changed; this says what it means, so it reuses neither the title's verb nor its object.
Example, its facts invented: the title "fix(billing): cap partial refunds at the charge" gives
"A customer can no longer be refunded more than they paid." -->

<one sentence>

<!-- Checks: the count of every bullet in the Checks section below, and the head; the count lives
only here.
Door: 🟢 two-way when a revert restores the previous state, 🔴 one-way when data, a schema, a
published contract, or an external system has moved. Blast radius: one word for the area, then
what else could notice. -->

- **Checks:** <✅ <N> checks passed | ❌ <N> of <M> checks failed> at <head sha>
- **Door:** <🟢 two-way | 🔴 one-way> · <one line>
- **Blast radius:** <area> · <what else could notice>

<!-- Ticket only, as its own list after a blank line. Scope: "as the ticket's Scope", or that plus
each path outside it and why. Corrections: every factual correction to the bundle as
`"<what it said>" → <what is true>` and the path that records it, or "none". -->

- **Scope:** <as the ticket's Scope | as the ticket's Scope, plus `<path>`: <why>>
- **Corrections:** <none | "<what the bundle said>" → <what is true> · `<path:line>`>

<!-- Only for a 🔴 one-way door: what moved and how to undo it, if at all. -->

> [!CAUTION]
> **One-way door:** <what moved> · <how to recover, or "no way back">

<!-- Bundle only. Every first-parent, non-merge commit after the newest ticket merge, oldest first,
from the `git log --first-parent` command in the skill's Gather the evidence step: these had no
review before this PR. One bullet each: sha, subject; each file area it changed as a sub-bullet.
"Only the bundle delete" is valid when Land wrote nothing else. -->

### Commits no ticket review covered

- <sha> <subject>
    - <what it changed>

<!-- One bullet each for what is not covered or could not be verified, and anything a review round
fixed late; ticket and bundle: only risks the contract did not already exclude. The risk is the
bullet; when something limits it, such as no current path reaching it, that is a sub-bullet. When
there is none, the single bullet "none known", without a glyph. -->

### Risks you accept by merging

- ⚠️ <risk>
    - <what limits it>

## Delivered

<!-- Present tense: what is observably true that was not before, one fact per bullet; a detail of
it is a sub-bullet. Facts, not how you built them, and never what stayed the same.
Ticket: three to six bullets, the spec and ticket IDs each satisfies in parentheses at its end.
Bundle: one bullet per capability the spec bound. Before writing, list every spec ID; give each to
the one bullet whose capability satisfies it, so every ID appears exactly once.
Neither: three to six bullets, no IDs.
Example, its facts invented; the second fact is a sub-bullet, not an "and":

- A refund above the remaining balance is rejected (`AC-4`, `BR-2`)
    - the error names the charge and the balance left
-->

- <what is now true> (`<IDs>`)

<!-- Omit the view when the change touches only Markdown, or fewer than three files. Otherwise the
smallest view that shows what moved where, in a fenced block: a call tree for runtime flow, a
shallow file tree for layout, pseudocode for a rule, a Mermaid sequence diagram for interaction.
One view is usual, two at most. Paths in it may be short; it is a picture, not a citation. -->

```<text | mermaid>
<view>
```

<!-- Bundle only. Every merged ticket PR in the order the skill's Gather the evidence step prints
its merge commit, oldest first, never by PR number. One bullet each: `#<n>` bare so GitHub links
it, the sha its merge put on the bundle branch, the title. -->

## Commits

- #<n> <merge sha> <title>

## Evidence

<!-- The one result no reviewer can reproduce once the change exists, as one bullet with one
command, copied verbatim. Ticket: the ticket's pre-change evidence. Bundle: the previous behavior of
the command that best shows the bundle's outcome, run at the merge base. Neither: the failing case
or the previous behavior. The commit it ran at, the command, and what it showed: the failure
reason, not "failed". -->

- **Before** at <sha>: `<command>` → <what it showed>

## Checks

<!-- The preconditions a fresh checkout needs to rerun them, or "nothing". Then every check, one
bullet per command, verbatim: ticket: the ticket's Commands; bundle: every ticket's Commands;
neither: the commands that show the change works. Last, `make lint typecheck test` as one bullet.
Results, not claims: ✅ when the result is the expected one, ❌ otherwise. -->

Requires <preconditions | nothing>.

- <✅|❌> `<command>` → <result>

## Reconciled

<!-- Every document this diff made false, one bullet each: the path, then what it now says, not
"updated". Colocated READMEs and AGENTS.md, glossary entries, ARCHITECTURE.md, the spec where
implementation corrected it; ticket: remaining tickets it invalidated. Bundle: also what Land
reconciled, decision records included, each line ending with its origin in plain parentheses, no
backticks: the ticket PR (#25), (shape), (Land <sha>), or (merge <sha>) for content that reached the
branch by merging its base. "None, this diff made no document stale" is a valid entry. -->

- `<path>`: <what it now says>

---

<!-- Ticket only. Land deletes the bundle, so these links are the only way back from this code to
the plan that approved it. Pin both to the merge base these commands print, never to a branch name,
run from the repository root of this worktree:

    fork=$(git merge-base HEAD origin/bundle/<bundle-reference>)
    gh browse -n --commit=$fork <bundle folder>
    gh browse -n --commit=$fork <ticket file>
-->

- **Bundle:** [`<bundle name>`](<permalink to the bundle folder>)
- **Ticket <NN>:** [`<ticket file name>`](<permalink to the ticket file>)
- **Base:** `bundle/<bundle-reference>`

<!-- Bundle only. Land deleted the bundle folder on this branch, so link it at the parent of the
commit that deleted it, the sha these commands print:

    parent=$(git rev-parse --short=8 "$(git rev-list -1 HEAD -- <bundle folder>)^")
    gh browse -n --commit=$parent <bundle folder>
-->

- **Bundle:** [`<bundle name>`](<permalink to the bundle folder at the parent>)
- **Base:** `<target>`

<!-- Neither only. -->

- **Base:** `<base branch>`
