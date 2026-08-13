---
status: todo
depends_on: []
---

# 01 — Workflow doc: strategy definitions and the git.md artifact

## Scope

`docs/agentic-workflow.md` gains, in its artifacts section, a `docs/agents/git.md`
paragraph that owns everything BR-8 assigns to the workflow doc: both strategy definitions
(`trunk`, `bundle-branch` per BR-5/BR-6 incl. the single-file exemption), the declaration
format and `trunk` fallback (ID-1, ID-2), the integration-branch naming (ID-3), and the
expose-last rationale (BR-7). Enabling work: every other ticket points at this text. Keep
it generic — no reference to this repo's decision records; the doc is copied verbatim into
consuming repos.

## Done when

- `grep -c "bundle-branch" docs/agentic-workflow.md` ≥ 1 and `grep "Branch strategy:"
  docs/agentic-workflow.md` shows the literal declaration format of AC-1
- `grep -i "expose-last" docs/agentic-workflow.md` hits within the git.md paragraph
- `grep -i "trunk" docs/agentic-workflow.md` hits the missing-file fallback sentence
- AC-1 passes (its nowhere-else clause is vacuously true at this ticket; it holds again at
  bundle level once 02–04 land their pointer-only references)

## Not in this ticket

Skill edits (→ 02, 03, 04), the template asset (→ 02), this repo's own git.md (→ 05).
