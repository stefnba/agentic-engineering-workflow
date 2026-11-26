<!-- Fill every slot; delete these comments as you fill. Findings in rank order, at most five
written out. A finding that needs more than its four lines is two findings, or its evidence is not
distilled yet. -->

## <Lens>: <n> findings (<n> high, <n> medium, <n> low)

Covered: <!-- the hot spots read first, then what else was read, at most 2 lines -->
Skipped: <!-- what in scope was not read and why, one line; drop the line when nothing was skipped -->

<!-- One block per finding. The claim states what is wrong, not what to do. The tier carries its
glyph: 🔺 HIGH, 🔸 MEDIUM, 🔹 LOW. Example, its facts invented:

### DE1 🔺 HIGH: `InvalidArtifactNameError` is declared in the store port module, but the rule that raises it lives in `artifacts.py`

- Where: `apps/example_app/example/core/run/store.py:63`
- Evidence: `artifacts.py:9` imports the error from `store.py` for no other reason; the other run errors live in `errors.py`
- Why it matters: the name rule depends on the port it should sit beneath, and a reader looks for its error in the wrong file
- Possible fix: fails Placement of types and helpers; place the error with the rule that raises it
-->

### <P><rank> <tier glyph> <TIER>: <claim>

- Where: `<path:line>`
- Evidence: <!-- at most 2 lines: what you read or ran, and what it showed; the other path:line when it spans files, the grep result behind a count or an exclusive, the quoted line behind a claim about a document -->
- Why it matters: <!-- one line: what it breaks, slows, or risks -->
- Possible fix: <!-- one line: the guard, test, or document it fails, then a direction; never an interface or a design -->

<!-- Omit the section when every finding is written out above. One line per further finding, in
rank order, IDs continuing from the last block. -->

**Also seen**

- <P><rank> <tier glyph> <TIER>: <claim> (`<path:line>`)

<!-- Omit the section when there is nothing to list. One line per document, naming the caretaker:
`docs/GLOSSARY.md` for the glossary skill, `docs/ARCHITECTURE.md` or a README for
write-architecture-doc. -->

**Docs that lag the code**

- `<path>`: <what the code does that the document no longer describes>, for <caretaker>
