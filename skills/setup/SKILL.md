---
name: setup
description: "Set up the agentic coding workflow inside your repo: install the workflow doc, scaffold the work/ and docs/ trees, and wire AGENTS.md."
disable-model-invocation: true
---

# Setup Agentic Coding Workflow

Scaffold the per-repo structure the workflow skills assume:

- the workflow doc (`docs/agentic-workflow.md`)
- the artifact trees (`work/`, `docs/decisions/`, `docs/research/`)
- the git conventions file (`docs/agents/git.md`), with the repo's chosen branch strategy
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
7. Root `GLOSSARY.md` — an existing domain-vocabulary artifact; scaffolding never overwrites it.
8. `docs/agents/git.md` — this skill's prior output too; if present, read its `Branch strategy:` line so step 2 can report the declaration instead of re-asking. If the line is missing or doesn't match a known value, treat the declaration as absent — there's nothing valid for step 2 to report.

### 2. Present findings and ask

Report what exists and what would be created, as a short list per write target. Flag conflicts instead of resolving them silently — an existing `docs/adr/` tree, a `work/` directory used for something else, an `AGENTS.md` with its own workflow section. For a monorepo, note that bundles can live per-package (`packages/<pkg>/work/`) and ask whether to scaffold root-only or per-package.

Then ask the branch-strategy question for `docs/agents/git.md` — unless the file already exists with a valid declaration: then report the declaration explore found and skip the question entirely; never solicit an answer you'd discard. If the file exists but step 1 found no valid `Branch strategy:` line (missing or malformed), ask the question as normal and note the file will be repaired — there's no existing answer to discard. Present both options; accepting the default needs no further input:

- **`bundle-branch` (recommended)** — the default branch only receives whole features, merged once per bundle, so a redirected or reverted bundle is one commit (decision 0016).
  Cost: integration drift accrues on a long-lived branch, and every open bundle adds one to keep in sync.
- **`trunk`** — per-ticket PRs land on the default branch as they pass review.
  Cost: a repo that deploys that branch's head on merge shows unfinished features unless user-visible wiring lands last, and abandoning a half-merged bundle means reverting individual commits out of shared history.

Example output — repo with no existing scaffolding (adapt the specifics to what step 1 actually found):

```text
Findings

This is a single-context repo with minimal structure:

- ❌ Not a git repository
- ❌ No AGENTS.md or CLAUDE.md
- ❌ No existing docs/agentic-workflow.md
- ❌ No work/, docs/decisions/, or docs/research/ directories
- ✅ Simple project structure: package.json with Hono, single TypeScript entry point

What I'll create

1. docs/agentic-workflow.md — canonical workflow doc (copy from template, not rewritten)
2. work/backlog.md — skeleton for issue tracking
3. work/shaped/ and work/active/ — work tracking directories (with .gitkeep)
4. docs/decisions/ and docs/research/ — decision records and research notes
5. docs/agents/git.md — git conventions, declaring the branch strategy chosen above
6. CLAUDE.md — new file with agents reference block (since neither AGENTS.md nor CLAUDE.md exists)

Ready to proceed?
```

### 3. Confirm

Show the exact file list to be written and any lines to be added to existing files. Wait for a yes. Nothing is written before this point.

### 4. Write

1. Copy `${CLAUDE_PLUGIN_ROOT}/docs/agentic-workflow.md` verbatim to `docs/agentic-workflow.md`. Don't rewrite its content — it's the canonical doc; local edits belong to the consuming repo afterward.

2. Copy `${CLAUDE_PLUGIN_ROOT}/skills/backlog/assets/template.md` verbatim to `work/backlog.md` — don't rewrite its header or sections. Also create empty `work/shaped/` and `work/active/` (with `.gitkeep` if the repo tracks empty dirs).

3. Create `docs/decisions/` and `docs/research/` if absent. If the repo already has `docs/adr/`, don't migrate it — note the coexistence and suggest to the human that content should be moved into `docs/decisions/`.

4. Copy `${CLAUDE_PLUGIN_ROOT}/skills/glossary/assets/template.md` verbatim to root `GLOSSARY.md` — skip this step entirely when one already exists; never overwrite it.

5. Copy `${CLAUDE_PLUGIN_ROOT}/skills/setup/assets/git-template.md` to `docs/agents/git.md` and set its declaration line to the strategy trunk|bundle-branch chosen in step 2. When one exists without a valid declaration, this write repairs it: overwrite with the template and the chosen strategy.

6. Add to the end of `AGENTS.md` (or `CLAUDE.md` if that's what the repo uses; never both) the exact block from [agents-reference.md](./references/agents-reference.md) — copy it verbatim, don't expand or rewrite it. If a section from a prior run exists, replace it rather than appending a duplicate.

### 5. Done

Tell the user setup is complete. They can edit the doc directly — it's their copy; re-running this skill only refreshes scaffolding, it won't overwrite an existing `docs/agentic-workflow.md` without asking.
