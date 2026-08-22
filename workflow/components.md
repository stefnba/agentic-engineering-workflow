# Components

How the workflow's roles become skills, agents, and the session's own voice: what invokes one, how
its permissions are expressed, where its supporting files go, and what it may reference.

**Every path here ships**. This repository _is_ the plugin, so a component written against this tree's
layout has to resolve identically in a consuming repo.

## Core principle

**Skills are about knowledge. Agents are about context isolation, parallelism and specifying tool
set. If they need knowledge, agents preload skills.** The placement test: a paragraph useful outside
this one agent belongs in a skill.

For more info, see [Steering Claude Code](https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more).

## What goes where

| Layer               | Contains                                                                                                         | Sizing                                                                                                                                 |
| ------------------- | ---------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **Reference skill** | Domain knowledge: rules, checklists, templates                                                                   | Lean body; heavy material behind a pointer in the skill's folder — Supporting material owns why                                        |
| **Action skill**    | The _when_: what invokes it, which gate it sits in front of, inline or fork — and the procedure around them      | Thin: obtain the input, dispatch, handle the result — restating no knowledge                                                           |
| **Agent**           | The _who_: role and boundaries, process shape, completion criteria, output contract, `tools`, `model`, `skills:` | Generic, one per role: a run needing a different procedure gets a different action skill or dispatch prompt, never a second agent file |

### Reference skills

A reference skill's frontmatter follows from its consumers
([skill fields](https://code.claude.com/docs/en/skills)): never `disable-model-invocation: true`,
which also blocks preloading, and `user-invocable: false` where no human would invoke it directly.
Verify each new preload once — a test run of the agent should name the rules it was given; one that
can't hasn't loaded them.

### Action skills

An action skill orchestrates one task: obtain the input, tell the agent what this run needs, handle
the result. The test for where a step belongs: would it change if a different action skill
dispatched the same agent? Then it lives in the action skill and travels in the dispatch prompt.

The dispatch prompt is the real interface between an action skill and its agent. Keep its parts
consistent across callers, so the generic agent body can rely on them.

### Agents

The agent body is the caller-independent contract: how to treat input, what counts as done at each
step, and the output contract — stated once, because the final message is all the dispatching
session sees. A step every caller needs stays in the body.

## Reference skill or `workflow/` doc

Both ship in the plugin and both can hold shared knowledge. What decides is how a consumer reaches
the material, not how many consumers there are:

- A **reference skill** is the only form with delivery guarantees: the
  [`skills:` field](https://code.claude.com/docs/en/sub-agents) lands it in a forked agent's system
  prompt before the first action — nothing depends on the agent choosing to read — and a
  description in context lets the model pull it in when a situation matches. One consumer needing
  either, guaranteed delivery or discovery, makes the material a reference skill.
- A **`workflow/` doc** is reachable only through its pointers — a "read X before Y" link at the
  step or branch that consumes it. That is enough exactly when every consumer is such a step, and
  it keeps skill bodies lean.

Coupling gives the same split from the content's side. `workflow/` is the workflow's own contract:
definitions and rules that mean nothing outside it — its artifacts, stages, and gates. A reference
skill is self-contained craft knowledge — how to write a defensible finding, what makes a module
boundary sound — that would hold under any workflow. When the two tests disagree, delivery wins:
contract material an agent needs guaranteed moves into the skill whole.

Mixed consumers follow the first rule: one agent needing the material before its first action makes
it a reference skill; a consumer that needs it only at one step reads the same `SKILL.md` at that
step, as any inline skill can.

**The winner owns the only copy.** A skill that restates a `workflow/` document so it can be
preloaded drifts within a few edits. Material that crosses the line moves and leaves nothing behind.

## Inline or forked

A skill runs **inline** when the human is part of the loop. A forked skill gets no conversation
history and no user, so dialogue and approval cannot fork.

A skill runs **`context: fork`** when the role requires isolation — fresh context, no authorship of
what it judges — or when its work would flood the session's context. A judging role — a plan
critique, a code review — forks because independence is the entire value.

**Blocking follows who is waiting.** `background: false` where someone is blocked on the result;
background only where the work is fire-and-forget.

## Permissions

- **The granting field and the withholding field are different fields.** A skill's `allowed-tools`
  only pre-approves: it skips the permission prompt for the invoking turn and leaves every other
  tool callable. What removes a tool from the pool is `disallowed-tools` on a skill,
  `disallowedTools` on an agent, and an agent's `tools`, which is a true allowlist. A component
  claiming a capability is withheld names one of those three, never `allowed-tools`.
- **A write boundary needs a hook.** All of them are per-tool, not per-path. Path scope like "this
  skill edits only the artifact it owns" is a skill-scoped
  [`PreToolUse` hook](https://code.claude.com/docs/en/hooks)
  denying `Edit`/`Write` outside the allowed paths. The same holds for an agent: where it may write
  is a hook, never its tool list.
- **Say which half is structural.** A withholding field reaches only the tools it names, and on a
  skill only until the next user message; a tool added later, an MCP tool, and `EndConversation`
  stay callable regardless. That residue is prompt-level and the component states it plainly rather
  than claiming enforcement it does not have.
- **Every skill that crosses a human gate is manual** (`disable-model-invocation: true`). A skill
  invoked by another skill, or by context, stays model-invocable.

## Output styles own the voice, not the role

An **output style** (`output-styles/*.md`, installed as `.claude/output-styles/`,
see [docs](https://code.claude.com/docs/en/output-styles)) rewrites the main
conversation's system prompt: how a response is shaped, never what a role does. It reaches no
subagent — a forked agent runs its own system prompt — so a rule a role must obey
belongs in that agent or in a skill it preloads.

## Supporting material

Keep the `SKILL.md` body itself as lean as possible (under 500 lines). Heavy material goes in
the skill's folder behind a pointer, see [Add supporting files](https://code.claude.com/docs/en/skills#add-supporting-files).

## Reference by link form, not by guesswork

A bare relative path resolves differently at runtime than on GitHub:

- plugin file from a `SKILL.md` → `${CLAUDE_PLUGIN_ROOT}/workflow/<file>.md`
- the skill's own bundled file → `${CLAUDE_SKILL_DIR}/<path>`
- the consuming repo's file → `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md`
- doc to doc inside the repo → plain relative, so GitHub renders it
- a consuming repo's `AGENTS.md` → no placeholder at all; project instructions expand none of them,
  so name the skill that loads the plugin file and link the repo's own files relatively

## Plugin compatibility

The [plugin scanner](https://code.claude.com/docs/en/plugins) treats every `.md` under `agents/` as
an agent definition, so `skills/` and `agents/` hold payload only — their documentation lives here.
Four rules hold continuously:

1. **Target-repo paths only** — a path assuming this repository's tree dangles in the consumer.
2. **Cross-skill references by plain name**; namespacing (`<plugin>:<skill>`) is applied at
   install.
3. **Hooks live on skills, never on agents** — plugin agents cannot declare them.
4. **Hook commands reference plugin files via `${CLAUDE_PLUGIN_ROOT}`** — installed plugins run from
   a cache.

Where a Claude-Code-specific field isn't needed, prefer the portable
[Agent Skills](https://agentskills.io) spec fields.
