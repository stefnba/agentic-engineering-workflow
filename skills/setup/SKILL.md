---
name: setup
description: "Set up the agentic coding workflow inside your repo: install the workflow doc, scaffold the work/ and docs/ trees, and wire AGENTS.md."
disable-model-invocation: true
---

# Setup Agentic Coding Workflow

Scaffold the per-repo structure the workflow skills assume:

- the workflow doc (`docs/agentic-workflow.md`)
- the artifact trees (`work/`, `docs/decisions/`, `docs/research/`)
- a pointer in the repo's agent instructions.

This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write.

## Follow this process

### 1. Explore

Look at the current repo to understand its starting state. Read whatever exists; don't assume:

1. `git remote -v` — is this a GitHub repo? (PR permalinks and the ticket-claiming protocol assume one.)
2. `AGENTS.md` and `CLAUDE.md` at the repo root — does either exist? Does one already reference `docs/agentic-workflow.md`?
3. `docs/agentic-workflow.md` — this skill's prior output; if present, this is a re-run.
4. `work/` — `backlog.md`, `shaped/`, `active/`, or remnants of another issue-tracking convention.
5. `docs/decisions/` — an existing decision-record tree.
6. Monorepo signals — a `pnpm-workspace.yaml`, a `workspaces` field in `package.json`, or a populated `packages/*` with its own `src/`. Their absence means single-context, which is most repos.

### 2. Present findings and ask

Report what exists and what would be created, as a short list per write target. Flag conflicts instead of resolving them silently — an existing `docs/adr/` tree, a `work/` directory used for something else, an `AGENTS.md` with its own workflow section. For a monorepo, note that bundles can live per-package (`packages/<pkg>/work/`) and ask whether to scaffold root-only or per-package.

### 3. Confirm

Show the exact file list to be written and any lines to be added to existing files. Wait for a yes. Nothing is written before this point.

#### 4. Write

1. Copy `${CLAUDE_PLUGIN_ROOT}/docs/agentic-workflow.md` to `docs/agentic-workflow.md`. Don't rewrite its content — it's the canonical doc; local edits belong to the consuming repo afterward.
2. Create `work/backlog.md` (skeleton from the `backlog` skill's template), plus empty `work/shaped/` and `work/active/` (with `.gitkeep` if the repo tracks empty dirs).
3. Create `docs/decisions/` and `docs/research/` if absent. If the repo already has `docs/adr/`, don't migrate it — note the coexistence and suggest to the human that content should be moved into `docs/decisions/`.
4. Add to the end of `AGENTS.md` (or `CLAUDE.md` if that's what the repo uses; never both) this short section on [Agents Reference](./references/agents-reference.md). If a section from a prior run exists, replace it rather than appending a duplicate.

#### 5. Done

Tell the user setup is complete. They can edit the doc directly — it's their copy; re-running this skill only refreshes scaffolding, it won't overwrite an existing `docs/agentic-workflow.md` without asking.
