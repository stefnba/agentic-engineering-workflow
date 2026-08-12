# Skills and subagents

How the roles in [agentic-workflow.md](agentic-workflow.md) become Claude Code skills and subagents: the conventions for building them. What exists today is inventoried in the root [README.md](../README.md); per-skill configuration lives in each `SKILL.md`'s frontmatter — a table restating frontmatter is a derived view that goes stale invisibly. Before shaping or building a skill that doesn't exist yet, read [work/skills-build-plan.md](../work/skills-build-plan.md) — it pins each unbuilt skill's invocation, context, and agent.

## Placement and settings

A skill runs **inline** when the human is part of the loop — forked skills get no conversation history and no user, so dialogue and approval can't fork. A skill runs `context: fork` when the role requires isolation (fresh context, no authorship) or would flood the main context.

1. **Write boundaries need a hook.** Tool lists (a skill's `allowed-tools`, an agent's `tools`) encode a role's power, but they are per-tool, not per-path — path scope like "shape edits only its bundle" is a skill-scoped PreToolUse hook blocking Edit/Write outside the allowed paths. The same holds for agents: where one may write is a hook, never its tool list.
2. **Blocking follows who's waiting.** `critique` and `review` set `background: false` — the author and the human wait for findings. `audit` and `research` stay background — gathering is fire-and-forget.
3. **Every skill that crosses a human gate is manual** (`disable-model-invocation: true`); everything invoked by another skill or by context stays model-invocable.

## Subagents

Agents (`agents/*.md`, installed as `.claude/agents/`) own the _who_ — context, tool set, preloaded knowledge; skills own the _when_ — invocation, gates, inline vs. fork.

**Knowledge arrives two ways, never restated in the agent's prompt:** reusable formats preload via the agent's `skills:` field (such skills are hidden from the `/` menu with `user-invocable: false`); everything else the agent reads from `docs/agentic-workflow.md` directly — the path resolves identically here and in a consuming repo. A prior `docs-rules` skill restated the workflow doc's rules for preload and drifted within a few edits; don't rebuild it.

## Plugin compatibility

This repo ships as a Claude Code plugin (decision 0001; mechanics in `docs/research/docs-read-2026-08-claude-code-plugins.md`). The plugin scanner treats every `.md` under `agents/` as an agent definition, so `skills/` and `agents/` hold payload only — their documentation lives here. Four rules hold for every skill and agent, continuously:

1. Target-repo paths only — a path assuming this repo's tree dangles in the consumer.
2. Cross-skill references by plain name; namespacing (`/agentic-coding:shape`) is applied at install.
3. Hooks live on skills, never on agents — plugin agents can't declare them.
4. Hook commands reference plugin files via `${CLAUDE_PLUGIN_ROOT}` — installed plugins run from a cache.

Where a Claude-Code-specific field isn't needed, prefer the portable [Agent Skills](https://agentskills.io) spec fields.
