# Components

How the workflow's roles become skills and agents: what invokes one, how its permissions are
expressed, where its supporting files go, and what it may reference. [Lifecycle](./lifecycle.md)
owns what each role does and which gate it sits in front of; this document owns only how one is
packaged.

Every path here ships. This repository _is_ the plugin, so a component written against this tree's
layout has to resolve identically in a consuming repo.

## Skills own when, agents own who

- An **agent** (`agents/*.md`, installed as `.claude/agents/`) owns the _who_: context, tool set,
  preloaded knowledge, and the role's judgment.
- A **skill** (`skills/<name>/SKILL.md`) owns the _when_: what invokes it, which gate it sits in
  front of, and whether it runs inline or forks.

A role that needs both gets both, and the skill stays thin: `critique` resolves the bundle and hands
it over; every judgment lives in `critic`.

**Knowledge arrives two ways, and neither is restatement in the agent's prompt.** A reusable format
preloads through the agent's `skills:` field. Everything else the agent reads from `workflow/`
itself. A skill that restates a `workflow/` document so it can be preloaded drifts within a few
edits — a prior `docs-rules` skill did exactly that; don't rebuild it.

## Inline or forked

A skill runs **inline** when the human is part of the loop. A forked skill gets no conversation
history and no user, so dialogue and approval cannot fork — that is why `shape`, `implement`, and
`land` are inline, and why a forked component records a question it would have asked instead of
asking it.

A skill runs **`context: fork`** when the role requires isolation — fresh context, no authorship of
what it judges — or when its work would flood the session's context. `critique` and `review` fork
because independence is the entire value.

**Blocking follows who is waiting.** `background: false` where someone is blocked on the result;
background only where the work is fire-and-forget.

## Permissions

- **A write boundary needs a hook.** Tool lists — a skill's `allowed-tools`, an agent's `tools` —
  are per-tool, not per-path. Path scope like "shape edits only its bundle" is a skill-scoped
  `PreToolUse` hook denying `Edit`/`Write` outside the allowed paths. The same holds for an agent:
  where it may write is a hook, never its tool list.
- **Say which half is structural.** A tool list withholds a capability outright; anything it cannot
  express is prompt-level and the component states that plainly rather than claiming enforcement it
  does not have.
- **Every skill that crosses a human gate is manual** (`disable-model-invocation: true`). A skill
  invoked by another skill, or by context, stays model-invocable.

## Supporting material

One consumer keeps it in that skill's own folder; two or more promote it to `workflow/`.

## Reference by link form, not by guesswork

A bare relative path resolves differently at runtime than on GitHub:

- plugin file from a `SKILL.md` → `${CLAUDE_PLUGIN_ROOT}/workflow/<file>.md`
- the skill's own bundled file → `${CLAUDE_SKILL_DIR}/<path>`
- the consuming repo's file → `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md`
- doc to doc inside the repo → plain relative, so GitHub renders it
- a consuming repo's `AGENTS.md` → no placeholder at all; project instructions expand none of them,
  so name the skill that loads the plugin file and link the repo's own files relatively

## Plugin compatibility

The plugin scanner treats every `.md` under `agents/` as an agent definition, so `skills/` and
`agents/` hold payload only — their documentation lives here. Four rules hold continuously:

1. **Target-repo paths only** — a path assuming this repository's tree dangles in the consumer.
2. **Cross-skill references by plain name**; namespacing (`agentic-workflow:shape`) is applied at
   install.
3. **Hooks live on skills, never on agents** — plugin agents cannot declare them.
4. **Hook commands reference plugin files via `${CLAUDE_PLUGIN_ROOT}`** — installed plugins run from
   a cache.

Where a Claude-Code-specific field isn't needed, prefer the portable
[Agent Skills](https://agentskills.io) spec fields.
