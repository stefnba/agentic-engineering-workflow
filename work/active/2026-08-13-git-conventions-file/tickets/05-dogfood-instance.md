---
status: todo
depends_on: [02]
---

# 05 — Dogfood: this repo's git.md and AGENTS.md pointer

## Scope

Instantiate `docs/agents/git.md` for this repo from `skills/setup/assets/git-template.md`:
`Branch strategy: trunk`, Conventional Commits adopted as-is (BR-9 — this switches the
repo's commit style from plain imperative; deliberate, confirmed at shaping), release
promotion slot removed (no deployment here). Add the pointer line to `AGENTS.md`'s
orientation. No `.claude/` symlink — the file is not a skill.

## Done when

- `grep "^Branch strategy: trunk" docs/agents/git.md` hits
- `grep "docs/agents/git.md" AGENTS.md` hits
- No unfilled HTML-comment slot guidance survives in `docs/agents/git.md`
- AC-6 passes

## Not in this ticket

Rewriting any existing AGENTS.md content; retro-fitting old commit messages.
