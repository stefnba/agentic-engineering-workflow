---
status: todo
depends_on: [01]
---

# 04 — Fix skill

## Scope

New `skills/fix/SKILL.md` — a plain skill, run like `implement` (no `context: fork`, no
dedicated agent; it edits code on the branch, ID-6). Entered on `fixes-pending` state or
explicitly via `/fix <PR> [F<id> ...]` (ID-6). Cap check at entry: refuse a fourth round,
report the loop state (BR-9). Work the verdict block's findings per BR-6 — mechanical
blockers fixed, nits batchable, untargeted concerns/nits reported `deferred`, decision
blockers escalated; escalation rulings must be recorded in the bundle or a decision record
before a later round treats them as fixable (BR-7). Push only a branch that re-verifies green
(the ticket's affected done-when lines plus the repo's checks); copy the verdict's `backlog`
list into `work/backlog.md`; post the fix-round report per ID-3. Dispatch: branch-first
resolution per ID-7 for the zero-arg form; on any state other than `fixes-pending` (including
no PR found), the no-op of BR-11 reporting the state and pointing at `/review`; inferred-mode
echo and next-command close-out per BR-10/BR-11; malformed-block stop per BR-12. Point at
`skills/review/references/protocol.md` for every definition (BR-15).

## Done when

- `skills/fix/SKILL.md` exists; `grep -l "references/protocol.md" skills/fix/SKILL.md` lists
  the file; `grep -c "fourth" skills/fix/SKILL.md` ≥ 1
- AC-5 and the fix half of AC-6 pass.

## Not in this ticket

The review side and reviewer agent (→ 02); implement's ticket-mode dispatch (→ 03); the
workflow doc (→ 05). No new forked agent — fix runs in the invoking session, same posture as
implement.
