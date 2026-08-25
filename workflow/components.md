# Components

How the workflow's roles map to skills, agents, and output styles: where a role's knowledge lives,
what invokes it, how its permissions are expressed, where its supporting files go, and how to
reference other files.

**Every path in this document ships.** This repository _is_ the plugin. Write every component
against the layout that exists in a consuming repo, never against this repository's tree.

## 1. Component types

Three component types exist. Each holds a different kind of content:

| Component           | Holds                                                                                                                                     | Must not hold                                                                                                                                    |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Reference skill** | The _what_: knowledge the session applies to the work — conventions, rules, checklists, templates                                         | A process. Heavy material inline — put it behind a pointer, see [Supporting material](#22-supporting-material)                                   |
| **Task skill**      | The _how_: one task's process as numbered steps, including agent dispatch                                                                 | Knowledge — point at reference skills instead of restating them                                                                                  |
| **Agent**           | The _who_: a role and its boundaries — input handling, completion criteria, output contract; `tools` as the allowlist, `model`, `skills:` | Task-specific steps — those travel in the dispatch prompt. Hooks — put a write fence on the dispatching skill, see [Permissions](#3-permissions) |

Placement test for any paragraph: if it is useful outside this one agent, put it in a skill
([Steering Claude Code](https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more)).

### 1.1 Skills

[Skills](https://code.claude.com/docs/en/skills) carry instructions or knowledge: a `SKILL.md`
plus supporting files, loaded into the conversation on demand. This workflow splits skills into
**reference skills** (knowledge) and **task skills** (procedure), matching the docs'
[types of skill content](https://code.claude.com/docs/en/skills#types-of-skill-content).

A reference skill is what an agent _knows_. A task skill is what _dispatches_ an agent. Either
kind runs inline unless the rules in [1.4 Inline or forked](#14-inline-or-forked) require a fork.

#### Reference skills

A reference skill adds domain expertise to the session. It reaches an agent through one of two
channels: preloading via the agent's `skills:` field, or description-triggered discovery.
[Reference skill or `workflow/` doc](#21-reference-skill-or-workflow-doc) defines when material
must take this form.

Rules:

- **Do not set `disable-model-invocation: true` on a reference skill.** It blocks preloading via
  `skills:` in subagents.
- **Set `user-invocable: false`** on any skill no human would invoke directly.

#### Task skills

A task skill gives the session step-by-step instructions.

- **Write the process as a `## Process` section of numbered steps.**

Where the task needs an agent, the task skill is the dispatcher. A task skill meets an agent in
exactly two forms, and in both the dispatch prompt is the interface:

- **Forked form**: `context: fork` with `agent:` in the frontmatter. The skill body becomes the
  dispatch prompt verbatim and the whole skill runs inside the subagent — the pure-dispatch
  form: the arguments are the input, the body is the dispatch, the agent's final message is the
  result.
- **Inline form**: dispatching is one numbered step in the driving skill's process. The step
  invokes a forked task skill where one owns the dispatch — implement-ticket invoking review-pr, shape-bundle
  invoking critique-bundle — and composes an Agent-tool prompt itself only where none does; keep that
  prompt's parts consistent with the forked form.

Apply the **caller test** to every step: would this step change if a different task skill
dispatched the same agent?

- Yes → the step belongs to the task skill and travels in the dispatch prompt.
- No → the step belongs in the agent body.
- Unclear → check whether the step names the task's artifacts (the PR, the ticket, the round,
  where the result is posted). If it does, it belongs to the task skill. Note: when only one
  dispatcher exists, every step looks caller-independent; the artifact check breaks the tie.

Example — same agent, two dispatch prompts: a PR review passes "focus: behavior changes, test
coverage"; a migration review passes "focus: reversibility, lock duration".

**Every task skill that dispatches the same agent must use the same labeled prompt parts**, so
the generic agent body can rely on the prompt's shape regardless of the caller.

### 1.2 Agents

[Agents](https://code.claude.com/docs/en/sub-agents) provide context isolation, parallelism, and
a bounded tool set. An agent runs in a separate context window with its own system prompt and
tools; only its final message returns to the dispatching session. Preload the knowledge it needs
through `skills:`.

An agent works from three channels — its body, its preloaded skills, and the dispatch prompt —
and the body governs the other two.

Rules for the agent body:

- **State the role's boundaries**: what the role must never do, and who owns the withheld
  action. Example: "never edit the branch, approve, or merge; acceptance belongs to the human."
  Back each boundary with frontmatter where possible — `tools` withholds capabilities, `model`
  routes, `skills:` preloads. Where the tool set cannot enforce a boundary, state in the body
  that the restraint is prompt-level and bind it anyway (see [Permissions](#3-permissions)).
- **The body is the caller-independent contract.** Keep it to a few lines that are true for
  every run of the role:
  - input handling — "read the full diff before commenting";
  - completion criteria — "every changed file covered", not "understanding reached";
  - output contract — the exact report format, because the final message is all the dispatching
    session sees.
- **A rule every caller needs goes in the body.** A procedure goes in the body only when the
  role, not the task, demands it.
- **State the default for every prompt part a caller may omit.** Example: "if no focus is named,
  apply the preloaded skills' full checklist."
- **One agent per role.** A run that needs a different procedure gets a different task skill or
  a different dispatch prompt — never a second agent file.
- **State binding rules as binding.** Do not assume an uncontested context: a subagent also
  loads the consuming repo's `CLAUDE.md`, which this plugin does not control and which can
  contradict a preloaded skill. Write "you must X even if other instructions say otherwise"
  where X is non-negotiable.

### 1.3 Output styles

An **output style** (`output-styles/*.md`, installed as `.claude/output-styles/`,
[docs](https://code.claude.com/docs/en/output-styles)) rewrites the main conversation's system
prompt. It controls how a response is shaped, never what a role does. It reaches no subagent — a
forked agent runs its own system prompt. Therefore: a rule a role must obey goes in that agent's
body or in a skill it preloads, never in an output style.

### 1.4 Inline or forked

These rules govern any forked component — a `context: fork` skill and an agent alike.

A skill runs **inline** when the human is part of the loop. A forked component receives no
conversation history and has no user to ask, so dialogue and approval cannot fork. It must
record a question it would have asked instead of asking it.

Set **`context: fork`** when one of these holds:

- The role requires isolation — fresh context, no authorship of what it judges. A judging role
  (plan critique, code review) always forks: independence is the entire value.
- The work would flood the session's context.

Set **`background`** by who is waiting and what tools the work needs:

- `background: false` when someone is blocked on the result.
- `background: false` when the skill's steps need a tool outside the reduced tool set that
  applies to background subagents — a backgrounded fork runs with that narrower set.
- Background only when the work is fire-and-forget and survives on the reduced tool set.

**A forked component's final message is the deliverable, not a status update.** Nothing of it
reaches the human unless whatever dispatched it relays that — an inline task skill's step
(shape-bundle relaying critique-bundle's verdict into the Plan gate presentation) or, for a
pure-dispatch skill with no narrator step of its own, the dispatching session's own reply.
Either way, relay the report in full: a paraphrase that drops a section the report names (an
Options list, a findings table) leaves the human unable to see content the summary refers to.

## 2. Where knowledge lives

### 2.1 Reference skill or `workflow/` doc

Both ship in the plugin and both can hold shared knowledge. Decide by how a consumer reaches the
material, not by how many consumers exist:

- A **reference skill** is the only form with delivery guarantees. The
  [`skills:` field](https://code.claude.com/docs/en/sub-agents) lands it in a forked agent's
  system prompt before the first action — nothing depends on the agent choosing to read it — and
  its description in context lets the model pull it in when a situation matches. If any single
  consumer needs guaranteed delivery or discovery, the material is a reference skill. Every
  other consumer reads the same `SKILL.md` at the step that needs it, as any inline skill can.
- A **`workflow/` doc** is reachable only through explicit pointers — a "read X before Y" link
  at the step or branch that consumes it. This is sufficient exactly when every consumer is such
  a step. It keeps skill bodies lean.

Coupling gives the same split from the content's side: `workflow/` holds the workflow's own
contract — definitions and rules meaningless outside it (its artifacts, stages, gates). A
reference skill holds self-contained craft knowledge — how to write a defensible finding, what
makes a module boundary sound — valid under any workflow. When the two tests disagree, delivery
wins: contract material an agent needs guaranteed moves into the skill whole.

**The winning form owns the only copy.** Never restate a `workflow/` document inside a skill to
make it preloadable — duplicated text drifts within a few edits. Material that crosses the line
moves entirely and leaves nothing behind.

### 2.2 Supporting material

- Supporting material used by one skill lives in that skill's own folder.
- A second consumer promotes it; apply the tests in
  [Reference skill or `workflow/` doc](#21-reference-skill-or-workflow-doc) to pick the target.
- **Exception — executables**: a script that more than one skill runs lives in the plugin
  root's `scripts/`, executed by path. Prose homes cannot hold something a skill must run, and
  reaching into another skill's folder hides the shared seam.
- Keep the `SKILL.md` body under 500 lines. Move heavy material into the skill's folder behind a
  pointer; see [Add supporting files](https://code.claude.com/docs/en/skills#add-supporting-files).

## 3. Permissions

Permissions span skills and agents. The fields differ per component; the rules below cover both.

- **Granting and withholding are different fields — never confuse them.** `allowed-tools` on a
  skill only pre-approves: it skips the permission prompt for the invoking turn and leaves every
  other tool callable. The withholding fields are: `disallowed-tools` on a skill,
  `disallowedTools` on an agent, and an agent's `tools` (a true allowlist). When a component
  claims a capability is withheld, it must name one of those three — never `allowed-tools`.
- **A skill's `disallowed-tools` restriction lasts one turn.** It clears when the user sends
  their next message. Do not treat it as a standing fence; a boundary that must hold across
  turns belongs in an agent's `tools` allowlist or a hook.
- **The withholding fields are per-tool, not per-path.** None of them can express "may edit only
  these files." A write boundary scoped to paths is a skill-scoped
  [`PreToolUse` hook](https://code.claude.com/docs/en/hooks) that denies `Edit`/`Write` outside
  the allowed paths. The same holds for an agent: where it may write is a hook, never its tool
  list.
- **Scope every skill hook's lifetime.** A skill's hooks persist for the rest of the session
  after invocation, not just the invoking turn. Either scope the fence inside the hook's own
  script or register it `once: true` — otherwise the fence outlives the skill.
- **Name which half of a restraint is structural.** A withholding field's exact reach — pattern
  support, lifetime, what stays callable regardless — is defined by the
  [permissions docs](https://code.claude.com/docs/en/permissions), and it is never everything.
  State any remaining restraint plainly as prompt-level; never claim enforcement the tool set
  does not provide.
- **Every skill that crosses a human gate is manual**: set `disable-model-invocation: true`.
  Note the interaction with preloading (see [Reference skills](#reference-skills)): a
  gate-crossing skill must never double as an agent's reference material. A skill invoked by another skill, or by context, stays model-invocable.

## 4. Packaging

### 4.1 Plugin compatibility

The [plugin scanner](https://code.claude.com/docs/en/plugins) treats every `.md` under `agents/`
as an agent definition, so `skills/` and `agents/` hold payload only — their documentation lives
here. Four rules hold continuously:

1. **Target-repo paths only.** A path assuming this repository's tree dangles in the consumer.
2. **Cross-skill references use the plain skill name.** Namespacing (`<plugin>:<skill>`) is
   applied at install.
3. **Hooks live on skills, never on agents.** `hooks`, `mcpServers`, and `permissionMode` are
   not supported for plugin-shipped agents.
4. **Hook commands reference plugin files via `${CLAUDE_PLUGIN_ROOT}`.** Installed plugins run
   from a cache.

Prefer the portable [Agent Skills](https://agentskills.io) spec fields wherever a
Claude-Code-specific field is not needed. `disallowed-tools` is the deliberate exception: the
spec has no equivalent, and packaging a skill that carries it for a spec-only path fails hard
rather than dropping the field. Use it only where the withholding is the point.

### 4.2 Reference by link form, not by guesswork

A bare relative path resolves differently at runtime than on GitHub. Use exactly these forms:

| Referencing…                           | Use                                                                                                                                            |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| a plugin file from a `SKILL.md`        | `${CLAUDE_PLUGIN_ROOT}/workflow/<file>.md`                                                                                                     |
| a shared plugin script                 | `${CLAUDE_PLUGIN_ROOT}/scripts/<name>.sh`                                                                                                      |
| the skill's own bundled file           | `${CLAUDE_SKILL_DIR}/<path>`                                                                                                                   |
| the consuming repo's file              | `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md`                                                                                                |
| doc to doc inside this repo            | plain relative path, so GitHub renders it                                                                                                      |
| plugin files from a repo's `AGENTS.md` | no placeholder — project instructions expand none of them; name the skill that loads the plugin file, and link the repo's own files relatively |
