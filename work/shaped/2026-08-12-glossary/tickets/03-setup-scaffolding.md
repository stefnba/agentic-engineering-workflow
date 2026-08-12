---
status: todo
depends_on: [01]
---

# 03 — Setup scaffolds the glossary

## Scope

`skills/setup/SKILL.md` per BR-12: step 1 (Explore) gains a `GLOSSARY.md` existence check;
step 4 (Write) gains: copy `${CLAUDE_PLUGIN_ROOT}/skills/glossary/assets/template.md`
verbatim to root `GLOSSARY.md`, skipped when one exists. While in step 4, fix the stale
backlog-template path per ID-7: `skills/backlog/template.md` →
`skills/backlog/assets/template.md`. `skills/setup/references/agents-reference.md`: add the
one-line glossary pointer to the copied block per ID-1 tier 2 (a pointer to `GLOSSARY.md`
and the workflow doc's rule — not the rule itself).

## Done when

- `grep -q 'skills/glossary/assets/template.md' skills/setup/SKILL.md` passes
- `grep -q 'skills/backlog/assets/template.md' skills/setup/SKILL.md` passes
- `grep -q 'GLOSSARY.md' skills/setup/references/agents-reference.md` passes
- AC-6 holds by inspection

## Not in this ticket

The template's content (→ 01). This repo's own `GLOSSARY.md` (→ 05) — setup targets
consuming repos.
