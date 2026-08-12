---
status: todo
depends_on: [02]
---

# 04 — Challenge pointers in dialogue skills, decision boundary

## Scope

Per BR-11 and ID-1 tier 3 — pointers, never restated rules. `skills/interview-me/SKILL.md`:
while grilling, challenge terms that conflict with `GLOSSARY.md` (both readings, per BR-7),
propose canonical terms for fuzzy language, and offer `glossary` capture when a term
resolves. `skills/shape/SKILL.md` step 2: read the glossaries of the domains the change
touches. `skills/shape/spec-template.md`: sharpen the existing "One name per concept" rule
(the "project glossary, where one exists" sentence) to name `GLOSSARY.md`, including its
_Avoid_ lists. `agents/critic.md`: one attack line — flag spec/ticket terms that conflict
with or bypass the glossary. `skills/decision/SKILL.md` "What goes elsewhere": the boundary
line, decision side (BR-10) — a naming/term choice belongs in `GLOSSARY.md` unless it
encodes a contested trade-off. Note: `agents/critic.md` and `skills/critique/SKILL.md` carry
uncommitted local modifications — build on the working-tree state, not HEAD.

## Done when

- `grep -q 'GLOSSARY.md' skills/interview-me/SKILL.md` passes
- `grep -q 'GLOSSARY' skills/shape/SKILL.md` passes
- `grep -q 'GLOSSARY.md' agents/critic.md` passes
- `grep -qi 'glossar' skills/decision/SKILL.md` passes
- AC-5 and AC-4 (decision half) hold by inspection

## Not in this ticket

`critique`'s SKILL.md body (the critic agent owns the attack surface; the forked skill only
resolves the bundle). The `review` skill (out of scope, spec §7). The `glossary` skill's own
boundary line (→ 01).
