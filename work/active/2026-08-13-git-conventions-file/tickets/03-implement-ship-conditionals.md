---
status: todo
depends_on: [01]
---

# 03 — Implement and ship follow the declared strategy

## Scope

`skills/implement/SKILL.md`: the Activate step reads `docs/agents/git.md` (missing or no
declaration = `trunk`, ID-2), branches per mode (BR-5, BR-6 incl. creating
`<bundle-id>/integration` per ID-3 when absent), syncs the integration branch from the
default branch per ID-9 (conflict = stop, human's call), and the Close-out step targets
the PR per mode; commit messages follow git.md's convention by pointer (no restating,
BR-8). `skills/ship/SKILL.md`: the resolve and land steps handle `bundle-branch` mode per
ID-7 — absorb/delete on the integration branch, land via a PR to the default branch
merged immediately (mechanical, not a review object; conflict = stop), green check on the
default branch unchanged; ship's own commits point to git.md's convention. Mode procedures live here as steps per
ID-6 — the workflow doc holds only the artifact pointer; neither skill defines the commit
vocabulary.

## Done when

- `grep "docs/agents/git.md" skills/implement/SKILL.md` and `grep "docs/agents/git.md"
  skills/ship/SKILL.md` both hit
- `grep "integration" skills/ship/SKILL.md` hits in the land step; `grep "integration"
  skills/implement/SKILL.md` hits in the Activate step
- `git diff --name-only` for this ticket's branch does not list `docs/agentic-workflow.md`
- `grep "feat" skills/implement/SKILL.md skills/ship/SKILL.md` returns nothing
- AC-4 passes

## Not in this ticket

Shape sequencing (→ 04). No behavior change for `trunk` repos beyond reading the file —
existing steps stay as the `trunk` path.
