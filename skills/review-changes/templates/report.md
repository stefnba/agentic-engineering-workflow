<!--
The local review report, delivered in chat. Fill every slot and delete the comments as you fill; a
surviving comment is an unfilled slot.
-->

## Local Review: <branch name | working tree>

<!-- The baseline the reviewers diffed against, bare, and how it was chosen. -->

**Baseline:** <baseline sha> · <HEAD | merge-base with `<base ref>`>

**Judged against:** <the stated intent | ticket `<path>` | repository conventions only>

### Verdicts

<!-- Each reply's verdict, the first bullet under its `### Verdicts`, glyph included; a reply with
no such bullet is "⚠️ <Design | Correctness> reply incomplete". Last, the tree: "✅ Tree unchanged
during review", or "⚠️ Tree moved during review" when the fingerprint changed, since line references
may then be off. -->

- <design verdict>
- <correctness verdict>
- <tree state>

<!-- The design reviewer's reply, verbatim. -->

<!-- The correctness reviewer's reply, verbatim. -->
