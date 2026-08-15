---
status: todo
depends_on: []
---

# 01 — Protocol reference

## Scope

Create `skills/review/references/protocol.md` — the one home (BR-15, ID-1) for the loop's
contracts: both marker literals and the locate-by-marker/highest-round rule (ID-4), the
verdict and fix-round YAML contracts exactly per ID-2/ID-3 (including the status vocabulary
with its tier restrictions, and the verdict block's optional `backlog` list with its
landing rule from BR-2), the tier and class vocabularies with their routing
(BR-2, BR-3), the four-state SHA derivation (BR-5), both output budgets (BR-4), the
3-fix-round cap (BR-9, ID-9), and the account rules (BR-13, ID-8). Pure enabling work: every
other ticket points here instead of restating.

## Done when

- `grep -c "agentic:verdict" skills/review/references/protocol.md` ≥ 1 and
  `grep -c "agentic:fix-round" skills/review/references/protocol.md` ≥ 1
- `grep -c "blocker | concern | nit" skills/review/references/protocol.md` ≥ 1 and
  `grep -c "mechanical | decision" skills/review/references/protocol.md` ≥ 1
- Each state name present individually: `grep -q` for `needs-review`, `fixes-pending`,
  `awaiting-accept`, and `needs-re-review` against
  `skills/review/references/protocol.md` — all four succeed
- AC-1, AC-4, and the protocol-reference half of AC-8 pass.

## Not in this ticket

Any edit to the skills, the reviewer agent, or the workflow doc (→ 02, 03, 04, 05). The
`.claude/skills/review` symlink already covers the new file — no symlink work.
