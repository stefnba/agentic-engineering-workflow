---
status: todo
depends_on: [01]
---

# 02 — Hook migration and dogfood switch

## Scope

With `--plugin-dir .` confirmed working (ticket 01), finish the migration: flip `shape`'s hook command in `skills/shape/SKILL.md` from `${CLAUDE_PROJECT_DIR}` to `${CLAUDE_PLUGIN_ROOT}`. Remove the now-redundant `.claude/skills/*` symlinks and `.claude/agents/critic.md` symlink (and the now-empty `.claude/skills`/`.claude/agents` directories, if nothing else uses them).

Rewrite `skills/README.md` § "Exercising skills in this repo" to describe `--plugin-dir .` — using the invocation form ticket 01 actually observed, not an assumption — and update its Status section to note the manifest exists. Update `CLAUDE.md`, `AGENTS.md`, and `docs/agentic-workflow.md`, which currently describe or link to the symlink pattern / `agents/README.md`, to point at `skills/README.md` instead. Remove the hook-migration line from `docs/work/backlog.md`.

## Done when

- `skills/shape/SKILL.md`'s hook `command` reads `${CLAUDE_PLUGIN_ROOT}/skills/shape/scripts/write-boundary.sh`.
- Under `claude --plugin-dir .`, invoking `shape` and attempting an `Edit`/`Write` outside `docs/work/candidates/` or `docs/work/planned/` is denied, with `write-boundary.sh`'s exact denial string visible in the transcript — confirms the migration didn't silently disable the write boundary.
- `.claude/skills/*` and `.claude/agents/critic.md` no longer exist in the tree.
- `skills/README.md` § "Exercising skills in this repo" and its Status section are updated; no remaining reference to the symlink pattern as the current mechanism.
- `CLAUDE.md`, `AGENTS.md`, and `docs/agentic-workflow.md` no longer reference the symlink pattern or link to `agents/README.md`.
- `docs/work/backlog.md` no longer contains the "shape's write-boundary hook uses `${CLAUDE_PROJECT_DIR}`..." line.

## Not in this ticket

`write-boundary.sh`'s internal logic (its own `CLAUDE_PROJECT_DIR` use, for the _edited file's_ relative path, is unrelated and correct as-is). Marketplace/`.claude-plugin/marketplace.json`, versioning policy, or any `.claude/settings.json` auto-install wiring, or `skills/README.md`'s workflow table Invocation column — all deferred per `design.md` § Non-goals.
