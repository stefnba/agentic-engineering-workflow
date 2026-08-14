---
status: todo
depends_on: [01]
---

# 03 — Implement skill: fix mode and zero-arg dispatch

## Scope

`skills/implement/SKILL.md` gains a fix mode (ID-6) and loses its required arguments
(BR-10). Fix mode: entered on `fixes-pending` state or explicitly via
`/implement fix <PR> [F<id> ...]` (ID-6); cap check at entry (refuse round 4, report the
loop state — BR-9); work the verdict block's findings per BR-6 (mechanical blockers fixed,
nits batchable, untargeted concerns/nits reported `deferred`, decision blockers escalated —
escalation rulings must be recorded in the bundle or a decision record before a later round
treats them as fixable, BR-7); push only a green re-verify, copy the verdict's `backlog`
list into `work/backlog.md`, post the fix-round report per ID-3.
Dispatch: branch-first resolution per ID-7, mode from state per BR-10 with the inferred-mode
echo, next-command close-out and idempotent no-op per BR-11, malformed-block stop per BR-12.
The `argument-hint` frontmatter reflects the new optional forms. Point at
`skills/review/references/protocol.md` for every definition (BR-15); the existing
ticket-mode steps (TDD loop, verify, reconcile, close-out) are amended only where dispatch
and close-out text changes — the red-green process itself is untouched.

## Done when

- `grep -c "fix" skills/implement/SKILL.md` shows a fix-mode section;
  `grep -l "references/protocol.md" skills/implement/SKILL.md` lists the file
- AC-5 and the implement-skill half of AC-6 pass.

## Not in this ticket

The review side (→ 02); the workflow doc and git conventions rule (→ 04). No change to the
seam rules, drift rules, or the red-green loop's steps.
