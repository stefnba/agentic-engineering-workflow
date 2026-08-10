# Skills and subagents

How the roles in [agentic-workflow.md](agentic-workflow.md) map onto Claude Code skills and subagents. The workflow doc owns the process and stays tool-agnostic; this file owns the Claude Code realization: the conventions every skill and subagent in this system follows, and the build plan for the ones that don't exist yet. When a question is about sequence, gates, or approval, the workflow doc wins.

Which skills and agents exist right now is inventory, and lives in the root [README.md](../README.md). Per-skill configuration — invocation, inline vs. fork, which agent a fork runs in, blocking behavior — is deliberately **not** tabled here for existing skills: each `SKILL.md`'s frontmatter and each agent definition encode it directly, and a table restating frontmatter is a hand-maintained derived view that goes stale invisibly. This file carries only what the artifacts can't: the rules that produce those settings.

## The rule that decides every placement

A skill runs **inline** when the human is part of the loop — forked skills get no conversation history and no user, so dialogue and approval can't fork. A skill runs `context: fork` when the role requires isolation (fresh context, no authorship) or would flood the main context. The process rules map onto mechanisms almost 1:1.

## Settings that carry process rules

1. **"No write access during shaping" needs a hook.** `allowed-tools` is per-tool, not per-path — the write boundary (shape edits only its bundle; researcher edits only research/ + backlog) is a skill-scoped `hooks` entry (PreToolUse) blocking Edit/Write outside the allowed paths. This is the load-bearing rule; enforce it structurally.
2. **Blocking semantics follow who's waiting.** `critique` and `review` set `background: false` — the author and the human wait for findings. `audit` and `research` stay background — gathering is fire-and-forget.
3. **The manual/model-invoked split falls out of the gates.** Every skill that crosses a human gate is manual (`disable-model-invocation: true`); everything invoked by another skill or by context (critique, backlog, decision, the reference layer) stays model-invocable.

## Reference layer

Background knowledge, hidden from the `/` menu (`user-invocable: false`), preloaded into subagents via their `skills:` field so the full content is in their context at startup:

- `evidence` — the evidence-block format `implement` produces and `reviewer` checks.

Rules that live in `docs/docs-structure.md` itself (ID glob resolution, README-over-spec precedence, spec/ticket format, the freeze rule) are not duplicated into a skill for preload — a forked agent that needs them reads `docs/docs-structure.md` directly with its `Read` tool, per the one-copy rule. A prior version of this repo carried a `docs-rules` skill that restated those rules for preload; it drifted from `docs-structure.md` within a few edits, so it was cut in favor of a direct read.

## Subagents

The subagents forked skills run in. In a consuming repo these land in `.claude/agents/*.md`; here they live under `agents/` as reference material, like everything else in this repo. Skills own the _when_ (invocation, gates, inline vs. fork); agents own the _who_ — the context, tool set, and preloaded knowledge a forked skill runs with.

Two conventions across all of them:

- **Knowledge arrives via `skills:` preload for reusable formats** (`evidence`), **or a direct `Read` of the authority doc for everything else** (`docs/docs-structure.md`) — never restated in the agent's system prompt, so the one-copy rule holds for agents too.
- **Tool lists encode the role's power, hooks encode its boundaries.** What an agent may touch at all is the `tools` list; _where_ it may write within those tools is a hook. Don't try to express path scope in tool lists — it can't.

## Plugin compatibility

This repo ships as a Claude Code plugin (decision 0001; mechanics in `docs/research/docs-read-2026-08-claude-code-plugins.md`). It is also why no documentation file may live inside `skills/` or `agents/`: the plugin scanner treats every `.md` under `agents/` as an agent definition, so those trees hold payload only and their documentation lives here. Four rules hold for every skill and agent, continuously — not as a packaging step at the end:

1. Target-repo paths only — a path assuming this repo's tree dangles in the consumer.
2. Cross-skill references by plain name; namespacing (`/agentic-coding:shape`) is applied at install.
3. Hooks live on skills, never on agents — plugin agents can't declare them.
4. Hook commands reference plugin files via `${CLAUDE_PLUGIN_ROOT}` — installed plugins run from a cache.

Where a Claude-Code-specific field isn't needed, prefer the portable [Agent Skills](https://agentskills.io) spec fields as a free hedge.

## Exercising skills in this repo

Claude Code loads skills from `.claude/skills/`, not `skills/` — this repo keeps them at the repo root because they're reference material meant to be copied elsewhere, not consumed here (see the top-level README). To invoke one for real inside this repo anyway, `.claude/skills/<name>` is a symlink to `../../skills/<name>`, one per skill directory (the pattern Claude Code documents for skill entries). Add the symlink when a skill is added; nothing else to configure. The same applies to `.claude/agents/<name>.md` → `../../agents/<name>.md`.

## Build plan

The unbuilt pieces. Each row is a mechanism commitment — invocation, context, agent — derived from the placement rule and settings rules above; skill _content_ is deliberately unspecified here (see work item 0001). When one of these is built, its row moves out of this table and into frontmatter, and the root README inventory picks it up.

| Skill       | Stage     | Role   | Invocation                     | Context                                      | Notes                                                                                                                                                                                                                                         |
| ----------- | --------- | ------ | ------------------------------ | -------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `audit`     | Discover  | gather | `/audit`, manual               | fork (background), `agent: researcher`       | Autonomous sweep; writes `research/audit-*.md` + backlog lines. `disallowed-tools: AskUserQuestion`.                                                                                                                                          |
| `research`  | Discover  | gather | `/research <topic>`, manual    | fork (background), `agent: researcher`       | Needs WebSearch/WebFetch; writes `research/*.md` + backlog line.                                                                                                                                                                              |
| `pick`      | Discover  | pick   | `/pick`, manual                | inline                                       | Dialogue — human picks from the backlog. Presents candidates neutrally, routes to interview or shape, ends with prune. Boundary with `backlog`: pick is a pipeline entry point (choose, route, prune); `backlog` is the artifact's caretaker. |
| `implement` | Implement | —      | `/implement <id>/<nn>`, manual | inline                                       | The session's operating procedure: resolve → read → claim → work → verify evidence → reconcile → PR. Also handles the bundle-less light path, branching on "no ticket exists" — one procedure, artifact-scaled.                               |
| `review`    | Review    | —      | `/review <pr>`, manual         | fork, `background: false`, `agent: reviewer` | Fork gives authorship isolation even when invoked from the implementer's session. Findings return to the human for the Accept gate. One reviewer for now; the standards/requirements split is a backlog optimization.                         |
| `ship`      | Ship      | —      | `/ship <id>`, manual           | inline                                       | Absorbs the spec into durable docs, deletes the bundle, merges. Durable-doc writes deserve main-session visibility.                                                                                                                           |

A `—` in Role is deliberate: only stages containing multiple contexts (Discover's gather/pick, Shape's author/critic) earn distinct role vocabulary — a stage with one context needs no second name.

| Agent           | Serves              | tools                                                | Notes                                                                                                                                                      |
| --------------- | ------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `reviewer`      | `review`            | `Read, Grep, Glob, Bash`                             | Bash for `gh pr diff` and re-running checks. `skills: [evidence]`; reads `docs/docs-structure.md` directly for procedural rules, same pattern as `critic`. |
| `researcher`    | `audit`, `research` | `Read, Grep, Glob, Write, Edit, WebSearch, WebFetch` | Write scope (research/ + backlog only) enforced by hook, not tool list.                                                                                    |
| `ticket-runner` | parallel implement  | full, `isolation: worktree`                          | **Phase 2.** Worktree isolation per ticket is how the claiming protocol scales past one agent.                                                             |

The supporting skills (`backlog`, `decision`, `handoff`) exist today but need reconciliation with docs-structure (see the backlog).
