---
status: todo
depends_on: [01]
---

# 04 — Shape sequences feature tickets expose-last

## Scope

`skills/shape/SKILL.md`, two steps: the ticket-writing step gains — alongside the existing
expand → migrate → contract rule for wide refactors — feature bundles ordered
internals-first with user-visible wiring in the final ticket (BR-7), owning its
one-sentence rationale per ID-6 (amended at implement: the workflow doc no longer carries
it); the commit-and-push step gains a `docs/agents/git.md` pointer for its bundle-commit
messages (BR-3 — shape commits too).

## Done when

- `grep -i "expose-last" skills/shape/SKILL.md` hits in the ticket-writing step with a
  one-sentence rationale
- `grep "docs/agents/git.md" skills/shape/SKILL.md` hits in the commit-and-push step
- AC-5 passes

## Not in this ticket

Anything outside those two steps of the shape skill.
