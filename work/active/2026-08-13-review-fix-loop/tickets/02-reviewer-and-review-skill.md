---
status: done
depends_on: [01]
---

# 02 — Reviewer agent and review skill on the protocol

## Scope

Rewrite the delivery half of `agents/reviewer.md` and `skills/review/SKILL.md` onto the
protocol reference. Reviewer agent: post findings as one PR review via `gh api` (verdict
block + line-anchored comments per ID-2/ID-5, budgets per BR-4, mirror rule per ID-8 — the
never-approve instruction stays); retire the Claim/Evidence/Break report format (ID-10);
scoped re-review per BR-8 (verify claimed fixes, delta-only new findings under never-reused
IDs, late-blocker exception with stated reason); pre-existing defects into the verdict
block's `backlog` list per BR-2; chat return per ID-10. Review skill: zero-arg PR resolution
per BR-10/ID-7, the state-mapped review modes of BR-10 (full review, scoped re-review, or
no-op) with the inferred-mode echo, idempotent no-op on an already-reviewed head (BR-11),
malformed-block stop per BR-12 (absent marker = `needs-review`, never an error),
next-command close-out. Both point at
`skills/review/references/protocol.md` for every definition (BR-15).

## Done when

- `grep -c "Claim:" agents/reviewer.md` → 0
- `grep -l "references/protocol.md" agents/reviewer.md skills/review/SKILL.md` lists both
  files
- AC-3, AC-7, the reviewer-agent half of AC-8, and the review-skill half of AC-6 pass.

## Not in this ticket

The implement skill's fix mode and dispatch (→ 03); the workflow doc (→ 04).
