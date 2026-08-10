---
status: todo
depends_on: []
---

# 01 — Manifest and `--plugin-dir` load

## Scope

Add `.claude-plugin/plugin.json` at the repo root per `spec.md` § Target state — `name`, `version`, `description`, `author`, `repository` only; no explicit `skills`/`agents` fields, the default directory scans cover them.

Fix what's actually in the way of clean validation: delete `agents/README.md` and fold its content into `skills/README.md` (skills own the _when_, agents own the _who_ — it's already the natural home), removing `skills/README.md`'s own now-dangling references to `agents/README.md` (its intro line and Status section) rather than leaving them pointing at a deleted file. Write `docs/decisions/0002-*.md` recording the colocation exception, in decision 0001's shape (Context / Decision / Rejected / Costs / Revisit if — the "Revisit if" should name the CLI-scanner behavior this depends on, so a future fix upstream has somewhere to register). Add a one-line pointer to that decision from `docs/docs-structure.md` § Durable system docs — not a restated paragraph.

Then actually load the repo as a plugin — `claude --plugin-dir .` — and confirm the component inventory and a real skill invocation both work. Record what invocation form Claude Code actually resolves to (bare `/shape`, or a namespaced form) as a **new resolved line in `spec.md` § Open questions** — not just the PR description, since `work/backlog.md` already flags evidence-handoff-via-PR as an unsettled convention, and ticket 02 has no other in-repo source of truth for this fact.

This is the tracer bullet: it validates the riskiest assumption (that this repo's existing `skills/`/`agents/` layout, once `agents/README.md` is out of the way, actually loads correctly as a plugin) before ticket 02 removes the fallback (`.claude/skills` symlinks) that's covering for it today.

## Done when

- `.claude-plugin/plugin.json` matches `spec.md` § Target state.
- `agents/README.md` no longer exists; `skills/README.md` carries its content and the colocation-exception rationale, with no remaining links to `agents/README.md` anywhere in the file.
- `docs/decisions/0002-*.md` exists with Context / Decision / Rejected / Costs / Revisit if sections; `docs/docs-structure.md` § Durable system docs links to it in one line.
- `claude plugin validate . --strict` exits 0.
- `claude --plugin-dir . plugin list` shows `agentic-coding` with `Status: ✔ loaded`.
- `claude --plugin-dir . plugin details agentic-coding` shows 7 skills (`backlog`, `critique`, `decision`, `docs-rules`, `handoff`, `interview`, `shape`) and exactly 1 agent (`critic`) — no phantom `README` component.
- A real interactive `claude --plugin-dir .` session invokes `shape` and the transcript shows it actually running, not erroring; the observed invocation form is added as a new resolved line in `spec.md` § Open questions.

## Not in this ticket

Changing the hook command, removing the `.claude/skills`/`.claude/agents` symlinks, rewriting `skills/README.md` § "Exercising skills in this repo" or its Status section, or touching `CLAUDE.md`/`AGENTS.md`/`docs/agentic-workflow.md`/`work/backlog.md` — all of that is ticket 02, and depends on this one confirming `--plugin-dir .` actually works.
