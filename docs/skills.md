# Skills and subagents

How the roles in [agentic-workflow.md](agentic-workflow.md) become Claude Code skills and subagents: the conventions for building them, and the build plan for the ones that don't exist yet. What exists today is inventoried in the root [README.md](../README.md); per-skill configuration lives in each `SKILL.md`'s frontmatter — a table restating frontmatter is a derived view that goes stale invisibly.

## Placement and settings

A skill runs **inline** when the human is part of the loop — forked skills get no conversation history and no user, so dialogue and approval can't fork. A skill runs `context: fork` when the role requires isolation (fresh context, no authorship) or would flood the main context.

1. **Write boundaries need a hook.** `allowed-tools` is per-tool, not per-path — a rule like "shape edits only its bundle" is a skill-scoped PreToolUse hook blocking Edit/Write outside the allowed paths.
2. **Blocking follows who's waiting.** `critique` and `review` set `background: false` — the author and the human wait for findings. `audit` and `research` stay background — gathering is fire-and-forget.
3. **Every skill that crosses a human gate is manual** (`disable-model-invocation: true`); everything invoked by another skill or by context stays model-invocable.

## Subagents

Agents (`agents/*.md`, installed as `.claude/agents/`) own the _who_ — context, tool set, preloaded knowledge; skills own the _when_ — invocation, gates, inline vs. fork.

- **Knowledge arrives two ways, never restated in the agent's prompt:** reusable formats preload via the agent's `skills:` field (such skills are hidden from the `/` menu with `user-invocable: false`); everything else the agent reads from `docs/agentic-workflow.md` directly — the path resolves identically here and in a consuming repo. A prior `docs-rules` skill restated the workflow doc's rules for preload and drifted within a few edits; don't rebuild it.
- **Tool lists encode the role's power, hooks encode its boundaries.** Where an agent may write is a hook, not a tool list — tool lists can't express path scope.

## Plugin compatibility

This repo ships as a Claude Code plugin (decision 0001; mechanics in `docs/research/docs-read-2026-08-claude-code-plugins.md`). The plugin scanner treats every `.md` under `agents/` as an agent definition, so `skills/` and `agents/` hold payload only — their documentation lives here. Four rules hold for every skill and agent, continuously:

1. Target-repo paths only — a path assuming this repo's tree dangles in the consumer.
2. Cross-skill references by plain name; namespacing (`/agentic-coding:shape`) is applied at install.
3. Hooks live on skills, never on agents — plugin agents can't declare them.
4. Hook commands reference plugin files via `${CLAUDE_PLUGIN_ROOT}` — installed plugins run from a cache.

Where a Claude-Code-specific field isn't needed, prefer the portable [Agent Skills](https://agentskills.io) spec fields.

## Build plan

Each row is a mechanism commitment — invocation, context, agent — derived from the rules above; skill _content_ stays unspecified until shaping. When one is built, its row moves into frontmatter and the README inventory picks it up.

| Skill       | Stage     | Invocation                     | Context                                      | Notes                                                                                                                                                            |
| ----------- | --------- | ------------------------------ | -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `audit`     | Discover  | `/audit`, manual               | fork (background), `agent: researcher`       | Autonomous sweep; writes `docs/research/audit-*.md` + backlog lines. `disallowed-tools: AskUserQuestion`.                                                        |
| `research`  | Discover  | `/research <topic>`, manual    | fork (background), `agent: researcher`       | Needs WebSearch/WebFetch; writes `docs/research/*.md` + backlog line.                                                                                            |
| `pick`      | Discover  | `/pick`, manual                | inline                                       | Dialogue — human picks from the backlog; presents candidates neutrally, routes to interview or shape, ends with prune. `backlog` stays the artifact's caretaker. |
| `implement` | Implement | `/implement <id>/<nn>`, manual | inline                                       | The session's operating procedure: resolve → read → claim ticket → work → verify evidence → reconcile → PR. Scales to single-file bundles — one procedure.       |
| `review`    | Review    | `/review <pr>`, manual         | fork, `background: false`, `agent: reviewer` | Fork gives authorship isolation even when invoked from the implementer's session. Findings return to the human for the Accept gate.                              |
| `ship`      | Ship      | `/ship <id>`, manual           | inline                                       | Absorbs the spec into durable docs, deletes the bundle, merges. Durable-doc writes deserve main-session visibility.                                              |

| Agent           | Serves              | tools                                                | Notes                                                                                                                                                                                   |
| --------------- | ------------------- | ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `reviewer`      | `review`            | `Read, Grep, Glob, Bash`                             | Bash for `gh pr diff` and re-running checks. Preloads `evidence` (the evidence-block format `implement` produces); reads `docs/agentic-workflow.md` directly, same pattern as `critic`. |
| `researcher`    | `audit`, `research` | `Read, Grep, Glob, Write, Edit, WebSearch, WebFetch` | Write scope (`docs/research/` + backlog only) enforced by hook, not tool list.                                                                                                          |
| `ticket-runner` | parallel implement  | full, `isolation: worktree`                          | **Phase 2.** Worktree isolation per ticket is how ticket claiming scales past one agent.                                                                                                |
