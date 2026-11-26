<!--
The Accept gate message. The human decides from it alone. Fill every slot inside its budget and
delete the comments as you fill; a surviving comment is an unfilled slot. Lead with plain words,
IDs in parentheses.

Glyphs per `../../workflow-references/references/glyphs.md`, relative to this file.
-->

## Accept gate: ticket <NN> of `<bundle-reference>`

PR [#<pr>](url) at <head sha, git rev-parse --short=8, bare> · round <N> · <✅ Ready for human review | ⚖️ Human escalation required | 🛑 Stopped after round 3>

**Delivered** <one sentence: what is true once this merges>

### Rounds

<!-- One row per review round, each cell the reviewer's verdict, the first bullet of its Summary
with its glyph, or "design not rerun"; counts stay out of the table. -->

| Round | Design    | Correctness |
| ----- | --------- | ----------- |
| 1     | <verdict> | <verdict>   |

<!-- Across every fix response, one count per non-zero disposition, in this order: "✅ <N> adopted",
"✅ <N> fixed", "↩️ <N> rejected", "↩️ <N> rebutted", "⚖️ <N> escalated", "❓ <N> carried to you",
"✅ <N> change you asked for", "✅ <N> also fixed". Pluralize each noun. -->

**Dispositions:** <count> · <count>

<!-- One bullet per escalation, from the last review's box and its Earlier section: the decision as
a question, then the item, the outcomes that would settle it, and each side's position, one sentence
each. Omit when none. -->

**Escalations:**

- ⚖️ **Your call: <the decision as a question>**
    - **Item:** <title> (`<ID>`)
    - **Either settles it:** <outcome A>, or <outcome B>
    - **Reviewer:** <the reviewer's position>
    - **Author:** <your position>

<!-- Every design question carried to you, from the design reviews' Questions for you: title and
ID, then the question and what a yes would change. Omit when none. -->

**Questions for you:**

- ❓ <title> (`<ID>`)
    - <the question>
    - <the approved part a yes would change>

### You are accepting

<!-- One bullet per open concern and residual risk, with what accepting it costs; then the door
and blast radius from the PR body. A blocker still open after round 3 is listed here with what its
fix rounds showed. -->

- ⚠️ <concern>. Cost: <what accepting it means>
- <🟢 | 🔴> <door>, <blast radius>

**Reconciled** <paths, or none>

<!-- In your own session: the count, offered through the `backlog` skill after this message. As a
sub-agent: the lines themselves, proposed only. -->

**Backlog offers** <N lines, offered after this message | the lines, one per line | none>

### Your call

<!-- The `workflow-manager` skill's `complete`: the absolute path of that skill's
`scripts/branch.sh`, the PR number, and the head the last round judged, never the PR's current
head. For a stopped loop, replace the command with the three moves: direct one more round, return
the ticket to Shape, or abandon it. -->

```bash
<workflow-manager dir>/scripts/branch.sh complete <pr> <head sha>
```
