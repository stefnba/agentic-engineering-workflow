---
status: todo
depends_on: [01]
---

# 02 — Setup: git.md template, strategy question, pointer

## Scope

Three files in `skills/setup/`: a new asset `assets/git-template.md` (bare scaffold per
ID-4/ID-5 — declaration line, Conventional Commits types and brevity rules, PR-conventions
and release-promotion slots as HTML-comment guidance); `SKILL.md` explore/ask/write steps
extended per BR-1/BR-2 (detect an existing `docs/agents/git.md` at explore; ask the
two-option strategy question with costs and the `trunk` default — skipped with the
existing declaration reported when the file is already present, per BR-2's re-run rule;
scaffold from the asset at write, never overwrite); `references/agents-reference.md` block gains the pointer line
naming the read trigger (before any git operation), per ID-6.

## Done when

- `grep "^Branch strategy: " skills/setup/assets/git-template.md` hits
- `grep "feat" skills/setup/assets/git-template.md` hits; `grep -rl "feat," skills/ docs/
  --include="*.md" | grep -v -e git-template -e "docs/agents/git.md"` returns nothing
  (type list owned by the template; instances exempt per BR-8)
- `grep "docs/agents/git.md" skills/setup/SKILL.md` hits in explore, ask, and write steps
- `grep "docs/agents/git.md" skills/setup/references/agents-reference.md` hits
- AC-2 and AC-3 pass

## Not in this ticket

implement/ship conditionals (→ 03), this repo's instantiated git.md (→ 05).
