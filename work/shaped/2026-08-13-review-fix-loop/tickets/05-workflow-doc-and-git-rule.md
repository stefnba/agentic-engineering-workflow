---
status: todo
depends_on: [01, 02, 03, 04]
---

# 05 — Workflow doc, git conventions rule, one-home sweep

## Scope

`docs/agentic-workflow.md`: the Review stage row and the loop description name the four
states and PR-hosted findings in stage-level prose only (ID-12) — no schema, marker, or
budget. The forward-only-history rule (BR-14) lands in
`skills/setup/assets/git-template.md` and this repo's `docs/agents/git.md` — both files are
created by the 2026-08-13-git-conventions-file bundle, which ships before this bundle
implements (ID-13); if either path is absent at implement time, that is factual drift to
surface, not a file to create here. Last ticket, so it also runs the one-home sweep (AC-2, the
two enumeration strings) across everything 01–04 wrote. Ordered after 02/03/04 so the sweep
and the doc describe the finished state.

## Done when

- Each state name present individually: `grep -q` for `needs-review`, `fixes-pending`,
  `awaiting-accept`, and `needs-re-review` against `docs/agentic-workflow.md` — all four
  succeed; `grep -c "agentic:verdict" docs/agentic-workflow.md` → 0
- `grep -li "force-push" skills/setup/assets/git-template.md docs/agents/git.md` lists both
  files
- AC-2, AC-9, and AC-10 pass.

## Not in this ticket

Skill or agent edits (→ 02, 03, 04). No edits to decision 0015 and no restated strategy
content in the workflow doc (owned by the git-conventions bundle's split).
