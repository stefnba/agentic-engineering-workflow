<!-- Append everything below this comment to the AGENTS.md of each member that keeps anything of
its own (a work folder, a glossary, decision records, or an existing architecture doc), creating
the file under a `# <scope name>` heading when absent and replacing an existing workflow section
on a re-run. Every member section carries a Work and a Decisions line, and a Glossary line unless
dropped below: each item offers one line per placement, own, root, or elsewhere; keep the line the
Scopes decision picked, fill its `<path>`, a path from the repository root, when it has one, and
delete the others. Keep the Architecture line only when this member has `docs/ARCHITECTURE.md`,
and the Integration target line only when this member's target differs from the root's, filling
`<branch>`.
Drop the Glossary or Architecture line when the file already points at that path outside this
section. Delete every comment when copying and close the kept lines up into one list. -->

## Agentic engineering workflow

<!-- Work: keep one. -->

- **Work** — this member has its own work folder, `work/backlog.md` and `work/bundles/`; bundles and backlog items about this member live here.
- **Work** — work about this member goes to the root work folder, `work/` at the repository root.

<!-- Integration target: keep only when this member's bundles land on a branch other than the
root's. -->

- **Integration target**: `<branch>` — this member's bundles are cut from it and land on it, instead of the root's.

<!-- Glossary: keep one; the third takes the path of a glossary the repository keeps elsewhere. -->

- **Glossary** — this member keeps its own `docs/GLOSSARY.md`; read it before naming a domain concept, and add this member's terms there.
- **Glossary** — terms for this member go to the root glossary, `docs/GLOSSARY.md` at the repository root; read it before naming a domain concept.
- **Glossary** — terms for this member go to `<path>` at the repository root, the repository's glossary; read it before naming a domain concept.

<!-- Decisions: keep one; the third takes the path of a record directory the repository keeps elsewhere. -->

- **Decisions** — records that bind only this member live in `docs/decisions/`.
- **Decisions** — records about this member go to the root `docs/decisions/`.
- **Decisions** — records about this member go to `<path>` at the repository root, the repository's record directory.

<!-- Architecture: keep only when docs/ARCHITECTURE.md exists here. -->

- **Architecture** — `docs/ARCHITECTURE.md` describes this member; read it before adding a component, changing a boundary, or changing dependency direction.

Invoke the `workflow-manager` skill when it is unclear whether a piece of work belongs here or at the root, the `backlog` skill for backlog items, the `glossary` skill for terms, and the `record-decision` skill for a decision.
