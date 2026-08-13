---
status: done
depends_on: []
---

# 01 — Workflow doc: strategy definitions and the git.md artifact

## Scope

`docs/agentic-workflow.md` gains, in its artifacts section, a one-sentence
`docs/agents/git.md` entry per ID-6 — the file and its four content areas, nothing more —
plus a layout-tree line. Mode tokens, procedures, fallback, and the declaration format
deliberately do not live here (amended at implement: they belong to the skills and the
template). Keep it generic — no reference to this repo's decision records; the doc is
copied verbatim into consuming repos.

## Done when

- `grep -c "agents/git.md" docs/agentic-workflow.md` ≥ 2 (the artifact entry and the
  layout-tree line)
- `grep "branch strategy" docs/agentic-workflow.md` hits the entry's content list
- `grep -c "bundle-branch" docs/agentic-workflow.md` returns 0 and `grep "Branch
  strategy: (trunk|bundle-branch)" docs/agentic-workflow.md` returns nothing (owned by
  skills and template, AC-1)
- AC-1 passes

## Not in this ticket

Skill edits (→ 02, 03, 04), the template asset (→ 02), this repo's own git.md (→ 05).
