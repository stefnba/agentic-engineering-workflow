<!-- The chat message the human triages from. Fill every slot inside the budget its comment
states and delete the comments as you fill. Themes in order: highest tier first, then the number
of lenses that raised it, then scanner rank. At most five themes. -->

## Scan: <scope>: <n> findings, <n> in the themes below

Full report with every finding verbatim: [<file name>](<scan file path>)

<!-- One block per theme. A theme is one finding, or several whose Where names the same file and
whose claims describe the same problem. Each ID links to its heading line in the scan file, as
`[DE1](<scan file path>:<line>)`, the line of its `### <ID>` heading. Why it matters and
Possible fix are taken from the findings, never invented; where several findings differ, keep the
strongest claim and say which ID it is from. Recommend is 🎯 pick now for a 🔺 theme and
📋 follow-up otherwise. -->

### 1. <tier glyph> <theme title: the problem in one line>

- **Raised by**: <lens> [<ID>](<scan file path>:<line>) · <lens> [<ID>](<scan file path>:<line>)
- **Where**: `<path:line>`
- **Why it matters**: <!-- one or two lines -->
- **Possible fix**: <!-- one line: a direction, never a design -->
- **Recommend**: <🎯 pick now | 📋 follow-up> <!-- for a demoted or dropped theme, one clause: what the spot-check found -->

<!-- One line: the findings not in a theme above, by tier count, with their IDs as plain text.
Omit when every finding is in a theme. -->

**Below the line**: <n> 🔸 and <n> 🔹 findings in the report: <IDs>.

For each theme, say 🎯 pick now, 📋 follow-up, or 🗑️ drop. Ask for any ID to see it in full. Anything you do not name stays in the report and nowhere else.
