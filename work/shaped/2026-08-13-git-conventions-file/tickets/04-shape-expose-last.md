---
status: todo
depends_on: [01]
---

# 04 — Shape sequences feature tickets expose-last

## Scope

`skills/shape/SKILL.md`, two steps: the ticket-writing step gains — alongside the existing
expand → migrate → contract rule for wide refactors — feature bundles ordered
internals-first with user-visible wiring in the final ticket (BR-7), pointing to the
workflow doc's git.md paragraph for why, one sentence of instruction, no restated
rationale (BR-8); the commit-and-push step gains a `docs/agents/git.md` pointer for its
bundle-commit messages (BR-3 — shape commits too).

## Done when

- `grep -i "expose-last" skills/shape/SKILL.md` hits in the ticket-writing step
- `grep "docs/agents/git.md" skills/shape/SKILL.md` hits in the commit-and-push step
- The added text contains a pointer to `docs/agentic-workflow.md` and no deployment
  rationale of its own
- AC-5 passes

## Not in this ticket

Anything outside those two steps of the shape skill.
