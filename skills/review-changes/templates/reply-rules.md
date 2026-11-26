# Review reply rules

Both reply templates in this folder, `design-reply.md` and `correctness-reply.md`, follow these
rules; read them before filling either.

**Every bullet is one fact in one sentence.** Each further fact becomes a sub-bullet, indented four
spaces. Before you finish, reread every bullet: one that holds ";", ", and" between two claims, or a
"where … before" contrast, carries two facts; split it into a bullet and a sub-bullet.

**Evidence is a pointer, never a retelling:** a full repo-relative `path:line`, `path` alone for a
whole file, `path::symbol` where no line decides it, `lines <N>–<M>` for more lines of the file
the item's location line names, a bare sha, or a verbatim command. A command that contains a
backtick goes in a double-backtick span: ``grep -c '(`Run`)' docs/GLOSSARY.md``.

**Every sha is `git rev-parse --short=8`, written bare, not in backticks,** so GitHub links it.

**Every item has a short title, and its ID follows in parentheses:** `<prefix>A<N>` for an
alternative, `<prefix>Q<N>` for a question, `<prefix>F<N>` for a finding, with the prefix your
prompt names, numbered from 1 in this round. Wherever an earlier ID appears, its title from the
round that raised it appears with it.

**Every spec or ticket ID follows a few words saying what it means:** "a date column must be
DATE-typed (`BR-15`)", never a bare `BR-15`.

**A glyph leads the line it qualifies, or follows the bold label that starts it;** section headings
carry none. A `> [!IMPORTANT]` box appears only for an escalation, because it means the human must
decide; keep its bare `>` line, without which GitHub joins the lines.
