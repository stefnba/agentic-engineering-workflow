---
status: todo
depends_on: []
---

# 01 — Glossary caretaker skill

## Scope

Rewrite `skills/glossary/SKILL.md` — currently a misfiled 9-line stub — into the caretaker
per ID-2 and BR-9: frontmatter with a detecting description (trigger symptoms per AC-3),
`argument-hint`, `allowed-tools: Read, Write, Edit, Glob, Grep`, and **no**
`disable-model-invocation` (the stub has it; caretakers are model-invocable per
docs/skills.md rule 3). Body: read the target glossary in full first; propose the exact
entry and wait for confirmation (BR-9); create `GLOSSARY.md` lazily from
`assets/template.md` when absent; entry format and exclusions per BR-1/BR-2/BR-4; monorepo
routing per BR-3 (root vs domain glossary — infer from the topic, ask if unclear); the
`decision` boundary line, glossary side (BR-10); report only changed lines (imitate
`skills/backlog/SKILL.md`'s reporting section). Create `skills/glossary/assets/template.md`
as a bare scaffold per ID-3 (header + entry-format hint + commented Domains-section guidance
per AC-7; slot guidance in comment syntax per
`skills/writing-for-agents/references/skill-mechanics.md`). Add the `.claude/skills/glossary`
symlink (CLAUDE.md rule) and a `glossary` row to README.md's supporting-skills table.

## Done when

- `test -L .claude/skills/glossary` passes
- `! grep -q 'disable-model-invocation' skills/glossary/SKILL.md` passes
- `test -f skills/glossary/assets/template.md` passes
- `grep -q 'glossary' README.md` passes
- AC-1, AC-3, AC-9, AC-7 (caretaker+template half), AC-4 (glossary half) hold by inspection

## Not in this ticket

Workflow-doc artifact entry (→ 02), setup scaffolding (→ 03), `decision`'s side of the
boundary (→ 04), the dogfooded root `GLOSSARY.md` (→ 05). The README row names the skill
`glossary` only — the string `GLOSSARY.md` must not appear in README.md yet; ticket 05's
done-when greps for it.
