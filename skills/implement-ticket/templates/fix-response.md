<!--
The author's reply to one review round, posted as one PR comment. Fill every slot and delete the
comments as you fill; a surviving comment is an unfilled slot.

Every bullet is one fact in one sentence; each further fact becomes a sub-bullet, indented four
spaces. Before you finish, reread every bullet: one that holds ";", ", and" between two claims, or
a "where … before" contrast, carries two facts; split it into a bullet and a sub-bullet.

Cite a full repo-relative `path:line`, `path` alone for a whole file, `path::symbol` where no line
decides it, a bare sha, or a verbatim command, never a retelling.

Names a human can read: every ID follows its title, copied from the review that raised it, in
parentheses: "Date-type row missing from the error table (`R1-F2`)", never a bare `R1-F2`. Every
spec or ticket ID likewise follows a few words saying what it means.

Glyphs per `../../workflow-references/references/glyphs.md`, relative to this file: a glyph leads
the line it qualifies; section headings carry none.
-->

## Fix Response: Round <N>

<!-- In the header, N is the review round this answers. The commit is the new head after the
fixes, `git rev-parse --short=8`, bare, not in backticks, so GitHub links it. -->

**Commit:** <sha>

### Summary

<!-- One bullet per non-zero count, in this order: "✅ <N> adopted", "✅ <N> fixed", "↩️ <N>
rejected", "↩️ <N> rebutted", "⚖️ <N> escalated", "❓ <N> carried to you", "✅ <N> change you
asked for", "✅ <N> also fixed". Last, the checks, counting every bullet under Checks: "✅ <N>
checks passed" or "❌ <N> of <M> checks failed". Pluralize each noun. -->

- <count>
- <count>
- <checks>

<!-- One bullet per alternative, question, and finding ID new in the round, and per earlier ID the
review marks still open; an ID the review marked escalated or closed gets none. Alternatives first, then
questions, then findings, each group in ID order. The skeleton below shows the bullet shapes, not
their order. Each bullet: glyph, title, ID, disposition word; its evidence as sub-bullets, one fact
each, ending in its pointer.
- ✅ adopted (alternative): the shape the code has now, and the ticket's Autonomy clause that
  allowed it.
- ↩️ rejected (alternative): the line, case, or ID that shows it costs more than it saves.
- ✅ fixed (finding): the commit, then what now holds and where.
- ↩️ rebutted (finding): the passing case, line, or ID that settles it, convincing to someone
  reading only the bundle and the code: it cites what settles the claim, not the intent behind it.
- ⚖️ escalated: a Reviewer and an Author sub-bullet, one sentence each, with each side's evidence
  nested under it. For a finding, the Reviewer line is its required outcome, verbatim.
- ❓ carried to you (question): nothing more; the hand-back puts it to the human.
For a suspected finding or alternative, the first sub-bullet says what confirming it showed. -->

### Responses

- ✅ <title> (`<ID>`) <adopted | fixed>
    - <evidence> · <pointer>
- ↩️ <title> (`<ID>`) <rejected | rebutted>
    - <evidence> · <pointer>
- ⚖️ <title> (`<ID>`) escalated
    - **Reviewer:** <the reviewer's position>
        - <evidence> · <pointer>
    - **Author:** <the author's position>
        - <evidence> · <pointer>
- ❓ <title> (`<ID>`) carried to you

<!-- Only when the human asked for a change since the last round; omit otherwise. One bullet per
change, IDs H1, H2, … in the order asked: ✅, what changed in at most eight words, the ID,
"done"; the evidence as sub-bullets. -->

### Changes you asked for

- ✅ <title> (`H<N>`) done
    - <evidence> · <pointer>

<!-- Only when you fixed something no ID of this round asked for, such as a backlog candidate or a
residual risk the review listed; omit otherwise. A response bullet answers its own ID only, so this
work goes here. One bullet each: ✅, what changed in at most eight words, then the review section
that listed it; the evidence as sub-bullets. -->

### Also fixed

- ✅ <what changed> · <Backlog candidates | Residual risk>
    - <evidence> · <pointer>

<!-- Every check rerun at the new head, one bullet each: glyph, the command verbatim, an arrow, the
result. ✅ when the result is the expected one, including a pre-change run that fails as the PR
claims; ❌ otherwise. A check run at another commit names it first ("at <sha>:"). -->

### Checks

- <✅|❌> `<command>` → <result>
