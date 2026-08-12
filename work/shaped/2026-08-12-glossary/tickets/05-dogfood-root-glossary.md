---
status: todo
depends_on: [01, 02]
---

# 05 — Dogfood: this repo's root GLOSSARY.md

## Scope

Create root `GLOSSARY.md` from `skills/glossary/assets/template.md` per BR-13: near-empty —
seed at most five terms, each verified unowned first (grep `docs/` and `AGENTS.md`; a term
another doc defines stays there). Candidates surfaced during shaping: *caretaker skill*,
*dogfooding*, *drift*. No Domains section — single context. Artifact terms (bundle, spec,
ticket, backlog) stay in the workflow doc per spec §7. Update `AGENTS.md`'s "Conventions
this repo applies to itself" with a glossary bullet, and README.md's "the one convention
this repo does apply to itself" sentence — it's two conventions now.

## Done when

- `test -f GLOSSARY.md` passes
- `grep -q 'GLOSSARY' AGENTS.md` passes
- `grep -q 'GLOSSARY.md' README.md` passes (ticket 01's table row deliberately avoids the
  string, so this line only goes green with this ticket's edit)
- AC-8 holds by inspection

## Not in this ticket

Trimming or moving any definition out of `docs/agentic-workflow.md` (spec §7). Backlog-line
cleanup for the promoted item (the "[docs] no home for domain language / glossary" line) —
that happens at bundle commit, via the `backlog` skill.
