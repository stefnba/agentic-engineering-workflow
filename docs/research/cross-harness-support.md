# Cross-harness support in seven reference repositories

For a reader who wants facts only: what do the reference projects do so that one skill folder runs under both Claude Code and Codex? The report describes the repositories and gives no design advice.

Sources and method: shallow clones of the seven repositories at HEAD, read on 2026-11-26 by a research sub-agent with `git ls-files`, `grep` and file reads. Issues were read through `gh`. Nothing from the clones was executed and no harness was run. Paths are relative to each repository. `[read]` marks a claim seen in a file or issue. `[inferred]` marks a conclusion. Every statement about how a harness behaves is the cited repository's claim, not a test result.

## Summary

Five repositories keep one skill text for every harness: mattpocock/skills, superpowers, Elephant Goldfish Model (EGM), BMAD-METHOD version 7 and OpenSpec 2.0. They share these habits `[inferred]`, with two EGM exceptions `[read]`:

- Only `name` and `description` carry weight in front matter. EGM also sets `disable-model-invocation` in all 8 skills.
- Skill text names the action, not the tool.
- Harness-specific material sits in thin sidecar files outside the skill body.
- Bundled files resolve relative to the skill folder, with no harness variable. Every EGM skill names `${CLAUDE_PLUGIN_ROOT}` to reach plugin-root files.

Two repositories transform text per harness. spec-kit generates each harness's skills from placeholder templates. gsd-core authors in Claude Code vocabulary and converts at install with a 4,882-line converter `[read]`.

gsd-core's changelog records Codex installer bugs `[read]`. Eight Codex installer issues are open; they were read by title only.

## Comparison

All seven repositories exist at the URLs given in the task.

| Repository                     | Harnesses claimed                                              | Reaches Claude Code by                                                  | Reaches Codex by                                                                 | What differs per harness                                    | Tool names in skill text                          | Verification                                          |
| ------------------------------ | -------------------------------------------------------------- | ----------------------------------------------------------------------- | -------------------------------------------------------------------------------- | ----------------------------------------------------------- | ------------------------------------------------- | ----------------------------------------------------- |
| mattpocock/skills              | Claude Code, Codex, Copilot managed; others through skills.sh  | Official marketplace; `.claude-plugin/` with an explicit `skills` array | The same `.claude-plugin/` manifests; skills.sh                                  | One `agents/openai.yaml` per skill                          | None except "the Skill tool" (22 hits)            | CI parses front matter; dated manual install notes    |
| google/elephant-goldfish-model | Antigravity CLI, Claude Code, Codex verified; six more partial | `.claude-plugin/` with adapter agents                                   | `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json`               | Adapter agents, per-harness guides, `${CLAUDE_PLUGIN_ROOT}` | Three names side by side with a fallback          | Offline tests in CI; opt-in live tests; dated record  |
| obra/superpowers               | 16 install sections                                            | `.claude-plugin/` and a session-start hook                              | `.codex-plugin/plugin.json` with `hooks: {}`, `.agents/plugins/marketplace.json` | The bootstrap only; skills are shared verbatim              | Actions only; a mapping file per harness          | Per-harness plugin tests; an external eval repository |
| github/spec-kit                | About 50 integrations                                          | CLI writes `.claude/skills/speckit-*`                                   | CLI writes `.agents/skills/speckit-*`                                            | Generated per harness from one template                     | None; commands are placeholders                   | Offline tests per integration                         |
| Fission-AI/OpenSpec            | About 55 tool IDs                                              | CLI or skills.sh; a link from `.claude/skills`                          | CLI or skills.sh into `.agents/skills`                                           | Install path and command spelling only                      | Neutral after fixes                               | Offline tests, skills.sh parity test                  |
| open-gsd/gsd-core              | Claude Code source; ten or more conversion targets             | Own installer; a partial `.claude-plugin/`                              | Own installer converts to `~/.codex/skills` and agent TOML                       | Paths, invocation, agents, hooks, an adapter header         | Claude names in the source, translated at install | Offline tests; install smoke matrix                   |
| bmad-code-org/BMAD-METHOD      | Whatever the `skills` CLI supports                             | `npx skills add`                                                        | `npx skills add`                                                                 | Nothing in skill text                                       | None                                              | Static validator in CI; an eval skill                 |

## Per-repository notes

### mattpocock/skills

Commit `6f7f783`.

- **It ships no Codex manifest.** Only `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` exist `[read: git ls-files]`.
- **Its decision record says Codex reads the Claude manifests.** Codex "falls back to `.claude-plugin/`" when no `.codex-plugin/` exists, checked by the maintainers on Codex 0.161.0 `[read: .agents/adr/0002-ship-as-a-claude-code-plugin.md:45-47]`.
- **Front matter uses five keys across 39 skills.** `name` 39, `description` 39, `disable-model-invocation` 24, `argument-hint` 4, `metadata` 1 `[read: counted]`.
- **Each skill carries a Codex sidecar.** 38 `agents/openai.yaml` files hold a display name, a short description and, for user-only skills, `policy.allow_implicit_invocation: false` `[read: skills/engineering/tdd/agents/openai.yaml]`.
- **A user-only skill needs both declarations kept in sync.** `[read: .agents/invocation.md:5-12]`
- **Sub-agents are prose.** "Spin up a subagent with a fresh context window"; no agent definition files exist `[read: skills/engineering/code-review/SKILL.md:11]`.
- **"Fresh context" is spelled out because of Codex**, which forks the parent conversation by default `[read: AGENTS.md]`.
- **Promoted skills use no harness variable.** `CLAUDE_PLUGIN_ROOT`, `CLAUDE_SKILL_DIR` and `$ARGUMENTS` each have 0 hits `[read: grep]`.
- **Questions go out as plain chat by policy.** `[read: .out-of-scope/native-question-tool.md]`
- **Harness-specific branches are out of scope by rule.** `[read: SCOPE.md]`

Reported breakages, all `[read]`:

- Codex "does not expose that tool": the Skill tool, the one tool the skills name (#1393 closed, #1123 open).
- A skill without the sidecar stayed model-invocable on Codex (#1431).
- `disable-model-invocation` blocks a skill's own Skill-tool call on Claude Code (#1052) and hides skills from the router (#740).
- Review sub-agents inherited the parent conversation on Codex (#1257); the "fresh context window" wording is the fix.
- A bare `code-review` name resolves to a Claude Code built-in (#1215). The maintainers refuse to rename `[read: .out-of-scope/harness-name-collisions.md]`.
- Codex drops symlinks when it copies a plugin into its cache `[read: decision record 0002]`.

Not read: `docs/` pages, how #1393 was closed, five listed issues.

### google/elephant-goldfish-model

Commit `4693375`.

- **It ships one manifest set per harness.** Root `plugin.json`, `.claude-plugin/`, `.codex-plugin/`, `.agents/plugins/marketplace.json`, `.cursor-plugin/`, `.plugin/` `[read: git ls-files]`.
- **The Codex manifest is thin.** `"skills": "./skills/"`, an interface block, no agents and no hooks `[read: .codex-plugin/plugin.json]`.
- **It does not support skills-only installers.** They "break EGM" because skills read `agents/` and `resources/` at the plugin root `[read: docs/harnesses.md:24]`.
- **Every skill names `${CLAUDE_PLUGIN_ROOT}`.** 10 hits across the 8 skills `[read: git grep -c]`.
- **Plugin-root paths need three branches.** A relative `../../resources/…`, the Claude variable, and a fixed path for harnesses that inject a skill without its path `[read: resources/execution_instructions.md, "Plugin-Root Resource Paths"]`.
- **Persona text is shared; restrictions live in adapters.** `.claude-plugin/agents/*.md` add `tools` and `model` and point at the shared persona. Codex gets no agent files `[read: docs/harnesses.md, "Manifests"]`.
- **Tool names appear as a three-way hint.** "your harness's subagent tool (Antigravity: `invoke_subagent`; Claude Code: `Agent`; Codex: `spawn_agent`)" `[read: skills/egm-brainstorm/SKILL.md:30]`.
- **Every capability has a stated fallback.** No named personas: a general-purpose sub-agent reads the file. No sub-agent tool: the review stops `[read: resources/execution_instructions.md, "Subagent Delegation"]`.
- **It tests real sessions.** `EGM_CLAUDE_LIVE=1` and `EGM_CODEX_LIVE=1` switch on integration tests, and `TESTING.md` keeps a dated record per harness `[read]`.
- **All 8 skills set `disable-model-invocation`; none sets the Codex policy.** `[read: counted]`

Reported breakages, all `[read]`:

- Codex chose EGM skills from plain prompts despite the Claude flag `[read: docs/verification/skill-discovery-316.md]`. The missing policy block as the cause is `[inferred]`.
- Under omp the agent could not reach plugin-root files and reported them as not shipped (#455).
- Codex and Antigravity inject `AGENTS.md` into fresh reviewers (#237).
- Claude Code rejected unknown manifest keys (#274).

Not read: integration test bodies, scenario files, Cursor, Copilot and OpenCode guides.

### obra/superpowers

Commit `22f0b46`.

- **The rule is written down.** "Skills name actions, not tools" `[read: docs/porting-to-a-new-harness.md:59]`.
- **Front matter is `name` and `description` only, in all 15 skills.** `[read: counted]`
- **It ships manifests for both harnesses in one tree.** `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`, plus eight more harness folders `[read: git ls-files]`.
- **The Codex manifest sets `"hooks": {}` on purpose.** Without it Codex auto-discovered the Claude hook file `[read: RELEASE-NOTES.md:290]`.
- **Codex gets no hook.** "Codex reliably triggers skills on its own" `[read: RELEASE-NOTES.md:309]`.
- **Claude Code and Cursor each get a hook file.** One script picks its output shape from environment variables `[read: hooks/hooks.json, hooks/hooks-cursor.json, hooks/session-start:76-88]`.
- **A mapping file per harness sits inside the bootstrap skill.** `skills/using-superpowers/references/{claude-code,codex,gemini,…}-tools.md` `[read]`.
- **Sub-agents are prompt files inside the skill folder.** Named agents were removed `[read: RELEASE-NOTES.md:484]`.
- **Neutral wording was a migration.** Skills were first written in Claude tool names `[read: docs/superpowers/specs/2026-05-05-platform-neutral-prose-design.md]`.
- **The sync script mirrors the tree into OpenAI's plugin repository.** It is for the official listing; the Codex manifest itself is committed here `[read: scripts/sync-to-codex-plugin.sh header]`.

Reported breakages, all `[read]`:

- Codex could not install until `.agents/plugins/marketplace.json` existed `[read: RELEASE-NOTES.md:308]`.
- The Codex package lost executable bits, so every script call failed (#2040).
- Claude Code wording misled Codex agents (#1883).
- Claude Code 2.1.233 removed `TodoWrite` on current models (#2177).

Not read: the external eval repository, eight harness folders, most of the porting guide.

### github/spec-kit

Commit `f201054`.

- **It ships no plugin manifest.** Its own CLI writes skills into each harness's folder `[read: git ls-files, README.md:80-82]`.
- **One template per command is rendered per harness.** The CLI replaces `{SCRIPT}`, `$ARGUMENTS` and `__SPECKIT_COMMAND_<NAME>__` `[read: src/specify_cli/integrations/base.py:1205-1223]`.
- **Invocation syntax comes from a table.** `$speckit-<name>` for Codex, `/speckit-<name>` for most others `[read: src/specify_cli/_invocation_style.py:11-49]`.
- **Claude-only keys are injected after generation.** `user-invocable`, `disable-model-invocation`, `argument-hint` `[read: src/specify_cli/integrations/claude/__init__.py]`.
- **`context: fork` was tried and withdrawn** after long sessions froze `[read: same file, comment citing #2511 and #3185]`.
- **Templates name no tools.** `TodoWrite`, `AskUserQuestion`, `subagent` and `CLAUDE_` have 0 hits in `templates/` `[read: grep]`.

Reported breakages: Codex skills show `/speckit-…` where `$speckit-…` is needed (#4954 open, #3451) `[read]`. The Codex integration once rewrote an existing `config.toml` `[read: CHANGELOG.md:649]`.

No test drives a real agent session `[inferred from the file list]`. Not read: integration internals, test bodies.

### Fission-AI/OpenSpec

Commit `f1cd852`.

- **Since 2.0 one copy serves every harness.** Skills go to `.agents/skills/`; Claude Code gets a link per skill in `.claude/skills/`; Windows gets copies `[read: docs-lab/reference/supported-tools.md, CHANGELOG.md:100-103]`.
- **Generated front matter is the same for every tool.** `name`, `description`, `allowed-tools`, `license`, `compatibility`, `metadata` `[read: skills/openspec-apply-change/SKILL.md:1-10]`.
- **`allowed-tools` stays because ignoring it is harmless.** It "only pre-approves" `[read: src/core/shared/allowed-tools.ts]`.
- **Neutral wording was a fix.** "Ask the user to select one" and "use a todo list" replaced tool names `[read: skills/openspec-apply-change/SKILL.md:36]`.

Reported breakages, all `[read]`:

- Generated Codex skills named `AskUserQuestion`, `TodoWrite` and `Task`, none callable in Codex (#1103).
- Agents without the question tool "errored or stalled on the instruction" `[read: CHANGELOG.md:844]`.
- Only 7 of 28 tools register the `/opsx:<id>` command form the text told users to type `[read: CHANGELOG.md:795]`.

No test drives a real agent session `[inferred]`. Not read: workflow templates beyond grep, `README.md`, test bodies.

### open-gsd/gsd-core

Commit `a30fe54`.

- **Claude Code is the authoring format.** The docs say not to copy source files directly to another runtime `[read: docs/how-to/install-on-your-runtime.md]`.
- **Claude names fill the source.** `AskUserQuestion` has 289 hits in `gsd-core/workflows`, and `~/.claude` has 159 `[read: grep]`.
- **The converter rewrites for Codex.** Paths, `/gsd-x` to `$gsd-x`, and a `<codex_skill_adapter>` header on every skill `[read: src/runtime-artifact-conversion.cts:2185-2378]`.
- **Agents ship twice.** 65 Markdown files for Claude; generated TOML files for Codex `[read: docs/how-to/install-on-your-runtime.md:170]`.
- **Hook coverage differs.** Seven event types on Claude Code, `SessionStart` only on Codex `[read: same document]`.

Reported breakages, all `[read: CHANGELOG.md]`: Codex installs kept `~/.claude` includes (line 640), shipped a hook that could never fire (737), and pinned `claude-*` model IDs that Codex rejects (1236). Eight Codex installer issues are open; they were read by title only.

Not read: the installer (15,969 lines), the TOML generator, test bodies.

### bmad-code-org/BMAD-METHOD

Commit `e435a22`, the version 7 preview.

- **Distribution is `npx skills add`, one command per module.** No plugin manifest and no `agents/openai.yaml` exist `[read: README.md:37-50, git ls-files]`.
- **Front matter is `name` and `description` only, in all 33 skills.** A validator requires valid YAML and `name` equal to the directory `[read: tools/skill-validator.md]`.
- **Paths use two placeholders defined in prose.** `{skill-root}` is "this skill's own folder", and the agent binds it at run time `[read: skills/core-tools/bmad/SKILL.md:9]`.
- **Script calls must use `{skill-root}`** because the working directory is the project `[read: tools/skill-validator.md, PATH-06]`.
- **Sub-agents are optional in prose.** "Use them … if you can", with a file fallback `[read: skills/method/bmad-code-review/workflow.md:15]`.
- **An eval skill works on any CLI.** It detects a skill load with a canary token `[read: skills/toolsmith/bmad-eval/references/harness.md]`.
- **Policy: no automated tests for model output in CI.** `[read: AGENTS.md]`

Reported breakages, all `[read]`: Codex wants an explicit user request before it spawns sub-agents (#2451). Codex truncated descriptions past a context budget (#2343). Codex skipped a skill with invalid YAML (#2232).

Not read: the 6.12 installer branch, validator and eval script bodies.

## What could not be settled

- **Whether Codex needs its own manifest.** mattpocock ships none and reports that Codex reads `.claude-plugin/`. superpowers reports that Codex found nothing without `.agents/plugins/marketplace.json`. The two accounts differ by date or Codex version; neither was tested here.
- **How Codex treats unknown front matter keys.** No repository states it. The mattpocock and EGM evidence shows only that `disable-model-invocation` alone does not stop Codex.
- **Codex invocation syntax.** spec-kit, OpenSpec and gsd-core state `$name`; EGM says to use the skill picker.
- **Claude Code is not a fixed target either.** Two repositories report `TodoWrite` removed or gated by model `[read: superpowers #2177, OpenSpec #643 by title]`.

## Shared practices

Each line states what the repositories do. The grouping across repositories is `[inferred]`; the evidence in each line is `[read]`.

- **Front matter.** superpowers and BMAD use `name` and `description` and nothing else. Codex skipped a BMAD skill over invalid YAML.
- **User-only skills.** mattpocock declares user-only twice: `disable-model-invocation` plus the `agents/openai.yaml` policy. A flagged skill cannot be called by another skill (mattpocock #1052, #740).
- **Tool names.** OpenSpec, superpowers and mattpocock each report a breakage caused by a tool name in skill text.
- **Questions to the user.** mattpocock, OpenSpec and EGM treat a structured question tool as optional.
- **Invocation spelling.** Hard-coded `/name` broke Codex output in spec-kit and OpenSpec.
- **Files outside the skill folder.** EGM skills read plugin-root files through a harness variable. EGM writes three path branches for plugin-root files (`resources/execution_instructions.md`). EGM does not support skills-only installers (`docs/harnesses.md:24`).
- **Packaging losses on Codex.** The superpowers Codex package lost executable bits (#2040). mattpocock's decision record 0002 states that Codex drops symlinks when it copies a plugin into its cache.
- **Sub-agents.** mattpocock and BMAD ask for a sub-agent in prose. superpowers keeps prompt files inside the skill folder. EGM and BMAD state a fallback.
- **Agent definition files.** mattpocock ships none. EGM ships Claude adapter agents and none for Codex. superpowers removed its named agents. gsd-core ships Markdown agents for Claude and generated TOML for Codex.
- **Hooks.** Four repositories ship none. superpowers gives Codex no hook, and gsd-core shipped a Codex hook that could never fire.
- **Manifests.** superpowers and EGM ship the four manifest files for the two harnesses.
- **Session tests.** Only EGM, superpowers and BMAD test real sessions.
