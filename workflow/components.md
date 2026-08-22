# Components

How the workflow's roles become skills, agents, and the session's own voice: what invokes one, how
its permissions are expressed, where its supporting files go, and what it may reference. [Lifecycle](./lifecycle.md)
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

**Knowledge arrives two ways, and neither is restatement in the agent's prompt.** What an agent
needs on every invocation lives in a skill and preloads through its `skills:` field, landing in the
system prompt before the agent's first action — so nothing depends on it choosing to read. What only
some runs need stays in `workflow/` and is read at the branch that needs it: the information
hierarchy's branching test, applied to knowledge placement.

**Preloading moves a document, never copies one.** A skill that restates a `workflow/` document so
it can be preloaded drifts within a few edits — a prior `docs-rules` skill did exactly that; don't
rebuild it. Material that crosses the always-needed line moves into `skills/<name>/SKILL.md` and
leaves nothing behind. `finding-rules` is the worked example: `critic` and `reviewer` preload it,
and `workflow/` holds no second copy.

**Only a forked agent preloads.** An inline skill has no `skills:` field and no system prompt of its
own, so its session reads that same file from `${CLAUDE_PLUGIN_ROOT}/skills/<name>/SKILL.md` at the
step that needs it — `implement` does exactly this in a fix round. Preloading is a fork
optimization; the placement rule is what both share.

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

- **The granting field and the withholding field are different fields.** A skill's `allowed-tools`
  only pre-approves: it skips the permission prompt for the invoking turn and leaves every other
  tool callable. What removes a tool from the pool is `disallowed-tools` on a skill,
  `disallowedTools` on an agent, and an agent's `tools`, which is a true allowlist. A component
  claiming a capability is withheld names one of those three, never `allowed-tools`.
- **A write boundary needs a hook.** All of them are per-tool, not per-path. Path scope like "shape
  edits only its bundle" is a skill-scoped `PreToolUse` hook denying `Edit`/`Write` outside the
  allowed paths. The same holds for an agent: where it may write is a hook, never its tool list.
- **Say which half is structural.** A withholding field reaches only the tools it names, and on a
  skill only until the next user message; a tool added later, an MCP tool, and `EndConversation`
  stay callable regardless. That residue is prompt-level and the component states it plainly rather
  than claiming enforcement it does not have.
- **Every skill that crosses a human gate is manual** (`disable-model-invocation: true`). A skill
  invoked by another skill, or by context, stays model-invocable.

## Output styles own the voice, not the role

An **output style** (`output-styles/*.md`, installed as `.claude/output-styles/`) rewrites the main
conversation's system prompt: how a response is shaped, never what a role does. It reaches no
subagent — a forked Critic or Reviewer runs its own system prompt — so a rule a role must obey
belongs in that agent or in a skill it preloads. Two fields decide the rest:
`keep-coding-instructions: true`, or the built-in engineering instructions are dropped along with
the default voice; and `force-for-plugin`, which would apply the style whenever the plugin is
enabled and override the human's own `outputStyle` — left off, so selecting it stays their call.

The plugin ships one, [`crisp`](../output-styles/crisp.md); a repo selects it
by name with `outputStyle` in `.claude/settings.json`.

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
[Agent Skills](https://agentskills.io) spec fields. `disallowed-tools` is the deliberate exception:
the spec has no equivalent, and packaging a skill that carries it fails hard rather than dropping
the field, so reach for it only where the withholding is the point.
