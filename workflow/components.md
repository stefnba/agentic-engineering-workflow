# Components

How the workflow's roles become skills, agents, and the session's own voice: where a role's
knowledge lives, what invokes one, how its permissions are expressed, where its supporting files go,
and what it may reference.

**Every path here ships**. This repository _is_ the plugin, so a component written against this tree's
layout has to resolve identically in a consuming repo.

## Skills and agents

**[Skills](https://code.claude.com/docs/en/skills) carry instructions or knowledge** — a
`SKILL.md` plus supporting files, loaded into the conversation on demand. Matching the docs'
[types of skill content](https://code.claude.com/docs/en/skills#types-of-skill-content), this
workflow splits skills into **reference skills** (knowledge) and **task skills** (procedure).

**[Agents](https://code.claude.com/docs/en/sub-agents) provide context isolation, parallelism, and
a bounded tool set.** An agent runs in a separate context window with its own system prompt and
tools; only its final message returns to the dispatching session. Knowledge it needs is preloaded
through `skills:`.

The placement test: a paragraph useful outside this one agent belongs in a skill
([Steering Claude Code](https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more)).

### What goes where

| Component           | Holds                                                                                                                                     | Must not hold                                                                                                                 |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **Reference skill** | The _what_: knowledge the session applies to the work — conventions, rules, checklists, templates                                         | A process; heavy material inline — that goes behind a pointer, see Supporting material                                        |
| **Task skill**      | The _how_: one task's process as numbered steps, agent dispatch included                                                                  | Knowledge — it points at reference skills instead of restating them                                                           |
| **Agent**           | The _who_: a role and its boundaries — input handling, completion criteria, output contract; `tools` as the allowlist, `model`, `skills:` | Task-specific steps — those travel in the dispatch prompt; hooks — a write fence rides the dispatching skill, see Permissions |

### Skills

A reference skill is what an agent _knows_; a task skill is what _dispatches_ an agent. Either
runs inline unless the role demands a fork — Inline or forked below owns that split.

#### Reference skills

A reference skill adds domain expertise to the session.

It reaches an agent by preloading (`skills:`) or by description-triggered
discovery — Reference skill or `workflow/` doc below owns when material earns this form.

- **Avoid `disable-model-invocation: true`** — it blocks preloading in subagents.
- **Set `user-invocable: false`** where no human would invoke the skill directly.

#### Task skills

A task skill gives the session step-by-step instructions.

Where the task needs an agent, the task skill is the dispatcher.

- **The dispatch prompt is the interface.** The default form makes it deterministic:
  `context: fork` with `agent:` turns the skill body into the dispatch prompt verbatim. A skill
  that stays inline and delegates composes an Agent-tool prompt instead.
- **Every task skill dispatching the same agent uses the same labeled parts**, so the generic
  agent body can rely on the prompt's shape no matter who sent it.

### Agents

An agent works from three channels — its body, its preloaded skills, and the dispatch prompt —
and the body governs the other two.

- **The agent body is the caller-independent contract, and stays that lean**: how to treat input,
  what counts as done, and the output contract — the final message is all the dispatching session
  sees.
- **A rule every caller needs stays in the body**; a procedure belongs there only when the role,
  not the task, demands it.
- **The body states the default for any prompt part a caller may omit** — no focus named means
  apply the preloaded skills' full checklist.
- **One agent per role.** A run needing a different procedure gets a different task skill or
  dispatch prompt, never a second agent file.
- **State a binding rule as binding** rather than assuming an uncontested context — a subagent
  also loads the consuming repo's `CLAUDE.md`, which the plugin does not control and which can
  contradict a preloaded skill.

## Reference skill or `workflow/` doc

Both ship in the plugin and both can hold shared knowledge. What decides is how a consumer reaches
the material, not how many consumers there are:

- A **reference skill** is the only form with delivery guarantees: the
  [`skills:` field](https://code.claude.com/docs/en/sub-agents) lands it in a forked agent's system
  prompt before the first action — nothing depends on the agent choosing to read — and a
  description in context lets the model pull it in when a situation matches. One consumer needing
  either, guaranteed delivery or discovery, makes the material a reference skill; every other
  consumer reads the same `SKILL.md` at the step that needs it, as any inline skill can.
- A **`workflow/` doc** is reachable only through its pointers — a "read X before Y" link at the
  step or branch that consumes it. That is enough exactly when every consumer is such a step, and
  it keeps skill bodies lean.

Coupling gives the same split from the content's side. `workflow/` is the workflow's own contract:
definitions and rules that mean nothing outside it — its artifacts, stages, and gates. A reference
skill is self-contained craft knowledge — how to write a defensible finding, what makes a module
boundary sound — that would hold under any workflow. When the two tests disagree, delivery wins:
contract material an agent needs guaranteed moves into the skill whole.

**The winner owns the only copy.** A skill that restates a `workflow/` document so it can be
preloaded drifts within a few edits. Material that crosses the line moves and leaves nothing behind.

## Inline or forked

A skill runs **inline** when the human is part of the loop. A forked skill gets no conversation
history and no user, so dialogue and approval cannot fork — a forked component records a question
it would have asked instead of asking it.

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
  is a hook, never its tool list. A skill's hooks persist for the rest of the session after
  invocation, not just its turn — scope the fence in the hook's own script or register it
  `once: true`, or the fence outlives the skill.
- **Say which half is structural.** A withholding field's exact reach — pattern support, lifetime,
  what stays callable regardless — is the
  [permissions docs](https://code.claude.com/docs/en/permissions)' to define, and it is never
  everything. Whatever restraint remains is prompt-level, and the component states it plainly
  rather than claiming enforcement it does not have.
- **Every skill that crosses a human gate is manual** (`disable-model-invocation: true`). A skill
  invoked by another skill, or by context, stays model-invocable.

## Output styles own the voice, not the role

An **output style** (`output-styles/*.md`, installed as `.claude/output-styles/`,
[output styles docs](https://code.claude.com/docs/en/output-styles)) rewrites the main
conversation's system prompt: how a response is shaped, never what a role does. It reaches no
subagent — a forked agent runs its own system prompt — so a rule a role must obey
belongs in that agent or in a skill it preloads.

## Supporting material

One consumer keeps supporting material in that skill's own folder; a second consumer promotes it —
the tests in Reference skill or `workflow/` doc pick the target. Executables are the exception to
both targets: a script more than one skill runs lives in the plugin root's `scripts/`, executed by
path, because prose homes can't hold something a skill must run and reaching into another skill's
folder hides the shared seam. Keep the `SKILL.md` body itself as
lean as possible (under 500 lines). Heavy material goes in the skill's folder behind a pointer, see
[Add supporting files](https://code.claude.com/docs/en/skills#add-supporting-files).

## Reference by link form, not by guesswork

A bare relative path resolves differently at runtime than on GitHub:

- plugin file from a `SKILL.md` → `${CLAUDE_PLUGIN_ROOT}/workflow/<file>.md`
- a shared plugin script → `${CLAUDE_PLUGIN_ROOT}/scripts/<name>.sh`
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
[Agent Skills](https://agentskills.io) spec fields. `disallowed-tools` is the deliberate exception:
the spec has no equivalent, and packaging a skill that carries it fails hard rather than dropping
the field, so reach for it only where the withholding is the point.
