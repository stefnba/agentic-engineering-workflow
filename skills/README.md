# Skills — the mechanism layer

How the roles in [docs/agentic-workflow.md](../docs/agentic-workflow.md) map onto Claude Code skills and subagents. The workflow doc owns the process and stays tool-agnostic; this file owns the Claude Code realization. When a question is about sequence, gates, or approval, the workflow doc wins.

The subagents these skills fork into are documented in [agents/README.md](../agents/README.md) — skills own the _when_, agents own the _who_.

## The rule that decides every placement

A skill runs **inline** when the human is part of the loop — forked skills get no conversation history and no user, so dialogue and approval can't fork. A skill runs `context: fork` when the role requires isolation (fresh context, no authorship) or would flood the main context. The process rules map onto mechanisms almost 1:1.

## Workflow skills

| Skill       | Stage     | Role   | Invocation                             | Context                                      | Notes                                                                                                                                                                                                                 |
| ----------- | --------- | ------ | -------------------------------------- | -------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `audit`     | Discover  | gather | `/audit`, manual                       | fork (background), `agent: researcher`       | Autonomous sweep; writes `research/audit-*.md` + backlog lines. `disallowed-tools: AskUserQuestion`.                                                                                                                  |
| `research`  | Discover  | gather | `/research <topic>`, manual            | fork (background), `agent: researcher`       | Needs WebSearch/WebFetch; writes `research/*.md` + backlog line.                                                                                                                                                      |
| `pick`      | Discover  | pick   | `/pick`, manual                        | inline                                       | Dialogue — human picks from the backlog. Presents candidates neutrally, routes to interview or shape, ends with prune.                                                                                                |
| `interview` | Discover  | pick   | `/interview`, manual                   | inline                                       | The user is the data source. Allocates the ID (`work/next-id`) and creates `candidates/<id>-<slug>/brief.md`.                                                                                                         |
| `shape`     | Shape     | author | `/shape <id>`, manual                  | inline                                       | Judgment questions go to the human mid-flow. Write boundary enforced by a skill-scoped hook (below). Invokes `critique` before exit.                                                                                  |
| `critique`  | Shape     | critic | model-invocable (triggered by `shape`) | fork, `background: false`, `agent: critic`   | Fork = no conversation history = the fresh-context rule enforced mechanically. Author waits for findings.                                                                                                             |
| `implement` | Implement | —      | `/implement <id>/<nn>`, manual         | inline                                       | The session's operating procedure: resolve → read → claim → work → verify evidence → reconcile → PR. Also handles the bundle-less light path, branching on "no ticket exists" — one procedure, artifact-scaled.       |
| `review`    | Review    | —      | `/review <pr>`, manual                 | fork, `background: false`, `agent: reviewer` | Fork gives authorship isolation even when invoked from the implementer's session. Findings return to the human for the Accept gate. One reviewer for now; the standards/requirements split is a backlog optimization. |
| `ship`      | Ship      | —      | `/ship <id>`, manual                   | inline                                       | Absorbs the design into durable docs, deletes the bundle, merges. Durable-doc writes deserve main-session visibility.                                                                                                 |

A `—` in Role is deliberate: only stages containing multiple contexts (Discover's gather/pick, Shape's author/critic) earn distinct role vocabulary — a stage with one context needs no second name.

## Supporting skills

Not stage-bound — they serve any session:

| Skill      | Invocation                                     | Purpose                                                                                                                                                                          |
| ---------- | ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `backlog`  | model-invocable — triggers on "note that down" | CRUD on `docs/work/backlog.md`: add, complete, promote, look up. Named for the artifact it manages, not a direction — `to-backlog` would undersell three of its four operations. |
| `decision` | model-invocable at wrap-ups                    | Write or supersede records in `docs/decisions/`.                                                                                                                                 |
| `handoff`  | `/handoff`, manual                             | Compact a dying session into a handoff file outside the repo — the unplanned-break mechanism from the workflow doc's Sessions and handoffs section.                              |

The boundary with the workflow table: `pick` is a pipeline entry point (choose, route, prune); `backlog` is the artifact's caretaker. The pick ritual belongs to the workflow; the file's upkeep doesn't.

## Reference layer

Background knowledge, hidden from the `/` menu (`user-invocable: false`), preloaded into subagents via their `skills:` field so the full content is in their context at startup:

- `docs-rules` — the procedural distillate of docs-structure: ID glob resolution, README-over-design precedence, target-state phrasing, ticket format, the freeze rule. Workflow skills link here instead of restating — the one-copy rule applied to skills themselves.
- `evidence` — the evidence-block format `implement` produces and `reviewer` checks.

## Settings that carry process rules

1. **"No write access during shaping" needs a hook.** `allowed-tools` is per-tool, not per-path — the write boundary (shape edits only its bundle; researcher edits only research/ + backlog) is a skill-scoped `hooks` entry (PreToolUse) blocking Edit/Write outside the allowed paths. This is the load-bearing rule; enforce it structurally.
2. **Blocking semantics follow who's waiting.** `critique` and `review` set `background: false` — the author and the human wait for findings. `audit` and `research` stay background — gathering is fire-and-forget.
3. **The manual/model-invoked split falls out of the gates.** Every skill that crosses a human gate is manual (`disable-model-invocation: true`); everything invoked by another skill or by context (critique, backlog, decision, the reference layer) stays model-invocable.

## Exercising skills in this repo

Claude Code loads skills from `.claude/skills/`, not `skills/` — this repo keeps them at the repo root because they're reference material meant to be copied elsewhere, not consumed here (see the top-level README). To invoke one for real inside this repo anyway, `.claude/skills/<name>` is a symlink to `../../skills/<name>`, one per skill directory (the pattern Claude Code documents for skill entries). Add the symlink when a skill is added; nothing else to configure. The same applies to `.claude/agents/<name>.md` → `../../agents/<name>.md` once subagents exist.

## Plugin compatibility

This repo ships as a Claude Code plugin (decision 0001; mechanics in `docs/research/docs-read-2026-08-claude-code-plugins.md`). Four rules hold for every skill and agent, continuously — not as a packaging step at the end:

1. Target-repo paths only — a path assuming this repo's tree dangles in the consumer.
2. Cross-skill references by plain name; namespacing (`/agentic-coding:shape`) is applied at install.
3. Hooks live on skills, never on agents — plugin agents can't declare them.
4. Hook commands reference plugin files via `${CLAUDE_PLUGIN_ROOT}` — installed plugins run from a cache.

Where a Claude-Code-specific field isn't needed, prefer the portable [Agent Skills](https://agentskills.io) spec fields as a free hedge.

## Status

The reference layer has `docs-rules`. `interview` and `critique` (with the `critic` subagent) exist. `shape` doesn't yet — this file is the build plan, paired with [agents/README.md](../agents/README.md) for the subagents. The supporting skills (`backlog`, `decision`, `handoff`) exist today but need reconciliation with docs-structure (see the backlog). Build one workflow skill end-to-end first, using the workflow itself.
