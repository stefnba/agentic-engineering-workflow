---
question: "How do the seven reference repositories make one skill folder usable under more than one agent harness, in particular Claude Code and Codex, and what problems do they report with it, if any?"
researched: "2026-11-28"
versions: "obra/superpowers v7.0.2; mattpocock/skills v1.3.2 (main bbadaa6); google/elephant-goldfish-model v0.1.1 (main 4693375); github/spec-kit v1.4.5 (main f201054); Fission-AI/OpenSpec v2.2.0; open-gsd/gsd-core v1.23.0 (next e9c3e54, plugin branch 2869610); bmad-code-org/BMAD-METHOD v6.12.4 and main e435a22 (v7 preview); vercel-labs/skills 1.9.1 (OpenSpec pins 1.8.1); openai/codex rust-v0.172.0"
---

# How seven skill repositories serve Claude Code and Codex from one source

## Answer

The table gives each repository's mechanism per facet, read on 2026-11-28. Every cell rests on a finding in the repository's section below.

| Repository, version read | Harnesses claimed | Claude Code route | Codex route | What differs per harness | Tool names in skill text | `SKILL.md` front matter | Bundled files |
| --- | --- | --- | --- | --- | --- | --- | --- |
| superpowers v7.0.2 (`main` is the tag, 2026-11-03) | About 16, Codex App and CLI among them | Plugin in `.claude-plugin/` from the official Claude marketplace; a SessionStart hook injects the bootstrap | `.codex-plugin/plugin.json` with `"hooks": {}` plus `.agents/plugins/marketplace.json`, synced to a fork that feeds OpenAI's marketplace; no hook | Manifest, bootstrap delivery, one tool-mapping reference per harness, `agents/openai.yaml` added when the Codex package is built | Actions, not tools; a per-harness reference maps them | `name`, `description` | Paths relative to the skill folder; scripts called through their interpreter |
| mattpocock/skills v1.3.2 (`main` 19 commits ahead, 2026-11-27) | Claude Code, Codex, Copilot, Gemini CLI, others through the Skills CLI | Official Claude marketplace | The repository's own `.claude-plugin/` manifests, which Codex reads when no `.codex-plugin/` exists | An `agents/openai.yaml` beside each `SKILL.md`; nothing generated | Neutral, except "call the Skill tool" in 11 skills | `name`, `description`, `disable-model-invocation`, `argument-hint`, `metadata` | Relative links inside the skill folder; no links across skills |
| elephant-goldfish-model v0.1.1 (`main` 64 commits ahead, 2026-11-25) | Antigravity, Claude Code and Codex tested end to end; ChatGPT, Cowork and others; Cursor, OpenCode, Copilot, Windsurf experimental | `.claude-plugin/` plugin and marketplace, with Claude-only agent adapters | `.codex-plugin/plugin.json` plus `.agents/plugins/marketplace.json`; no subagents shipped | Manifests, thin adapters, a Codex guide, one release ZIP per vendor | "Spawn a subagent", with an inline map to `invoke_subagent`, `Agent` and `spawn_agent` | `name`, `description`, `license`, `disable-model-invocation` | `../../` from the skill, `${CLAUDE_PLUGIN_ROOT}` on Claude Code, a root derived from the `SKILL.md` path on Codex; whole-plugin installs only |
| spec-kit v1.4.5 (`main` a few commits later, 2026-11-25) | About 48 integrations | `specify` generator writes `.claude/skills/speckit-<name>/` | The same generator writes `.agents/skills/speckit-<name>/` | A separate generated copy per harness: invocation prefix, extra Claude front matter, hook config file, dispatch flags | Neutral; placeholders filled at install | `name`, `description`, `compatibility`, `metadata`; Claude copies add `user-invocable`, `disable-model-invocation`, `argument-hint` | Shared scripts in `.specify/`, paths rewritten to the project root at install |
| OpenSpec v2.2.0 (2026-11-24) | 30+ tools | Generator writes one shared copy to `.agents/skills/` and links it into `.claude/skills/`, through Vercel's `skills` package; global by default | Reads the shared `.agents/skills/` copy directly | Only how skills name each other: `$name` for Codex, `/name` elsewhere, the bare name in the shared copy | Neutral, after reported failures | `name`, `description`, `allowed-tools`, `license`, `compatibility`, `metadata`; the same for both | `references/` relative to the skill; skills call the `openspec` CLI, not bundled scripts |
| gsd-core v1.23.0 (`next` matches it for changelog, 2026-11-23) | About 17 runtimes | npm installer, or a Claude plugin from a prebuilt `plugin` branch | npm installer converts files; Codex agents become TOML | A converter rewrites paths, tool names and front matter per runtime | Claude Code names in source; tables and regexes convert them, and Codex gets a mapping header | Source: `name`, `description`, `argument-hint`, `allowed-tools`; Codex copy: `name`, `description`, `metadata.short-description` | Absolute `@~/.claude/gsd-core/...` includes, rewritten per runtime; on the plugin route a hook links that path to the plugin cache |
| BMAD-METHOD v6.12.4 (2026-10-14); `main` is the v7 preview (2026-11-12) | 48 platforms in v6.12.4; "any tool that supports skills" on `main` | v6.12.4: npm installer copies to `.claude/skills`, plus a Claude marketplace file; `main`: the Skills CLI | v6.12.4: npm installer copies to `.agents/skills`; `main`: the Skills CLI | None for these two: the same bytes, a different folder | Capabilities, not tools, with inline fallbacks | `name`, `description` | `{skill-root}` and `{project-root}` placeholders that the model resolves at run time |

- **Where they agree.** Codex gets skills in `.agents/skills` or a plugin's `skills/` folder, and Claude Code gets `.claude/skills` or a plugin. The exceptions are gsd-core's Codex install and BMAD v6.12.4's global Codex install, which use `~/.codex/skills`; Codex still reads that folder but marks it deprecated. Codex's own code confirms the `.agents/skills` scan and a fallback to `.claude-plugin/` manifests ([Codex `host_roots.rs`, rust-v0.172.0](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/ext/skills/src/host_roots.rs); [Codex `protocol.rs`, rust-v0.172.0](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/exec-server-protocol/src/protocol.rs)). Six of seven aim for tool-neutral skill text; gsd-core writes Claude Code's names and converts them. All seven use `name` and `description`.
- **Where they differ.** Inferred: three ways of delivery exist, from the sections on each repository. Four repositories ship one folder with the same skill text for every harness (superpowers, mattpocock/skills, elephant-goldfish-model, BMAD); superpowers adds an `agents/openai.yaml` to each skill when it builds the Codex package. OpenSpec generates one shared copy. spec-kit and gsd-core generate a copy per harness. Bundled-file resolution has no common form: relative to the skill folder, relative to the plugin root, relative to the project root, or an absolute home path.
- **Invocation control does not carry across.** Claude Code reads `disable-model-invocation` in `SKILL.md`; Codex reads `policy.allow_implicit_invocation` in `agents/openai.yaml` ([mattpocock `.agents/invocation.md`](https://github.com/mattpocock/skills/blob/main/.agents/invocation.md)). mattpocock/skills keeps the two files in step by hand.
- **Reported problems.** All seven report cross-harness problems; none reports zero. The kinds, with one example each:
  - Claude-only tool names in skill text ([OpenSpec CHANGELOG, PR #1464](https://github.com/Fission-AI/OpenSpec/blob/main/CHANGELOG.md), [mattpocock #1393](https://github.com/mattpocock/skills/issues/1393))
  - one harness reading another harness's files, or seeing a skill twice ([superpowers RELEASE-NOTES v6.1.1](https://github.com/obra/superpowers/blob/v7.0.2/RELEASE-NOTES.md), [OpenSpec #2180](https://github.com/Fission-AI/OpenSpec/issues/2180))
  - bundled files and roots that resolve wrongly ([BMAD #3179](https://github.com/bmad-code-org/BMAD-METHOD/issues/3179), [superpowers #2040](https://github.com/obra/superpowers/issues/2040))
  - invocation metadata that drifts between the two files ([mattpocock #1431](https://github.com/mattpocock/skills/issues/1431))
  - Codex's subagent contract ([mattpocock #1257](https://github.com/mattpocock/skills/issues/1257), [elephant-goldfish-model #237](https://github.com/google/elephant-goldfish-model/issues/237))
  - generators and installers that damage files ([gsd-core #5199](https://github.com/open-gsd/gsd-core/issues/5199), [spec-kit #5002](https://github.com/github/spec-kit/issues/5002))
- **Installers in between add their own failures.** The Skills CLI keeps the real copy in `.agents/skills` and gives Claude Code a symlink. That link has gone missing in reports filed from March to July 2026, two of them still open ([vercel-labs/skills #1045](https://github.com/vercel-labs/skills/issues/1045), [#1355](https://github.com/vercel-labs/skills/issues/1355)). Codex plugin caches drop symlinks, per mattpocock's ADR ([ADR 0002, 2026-10-07](https://github.com/mattpocock/skills/blob/main/.agents/adr/0002-ship-as-a-claude-code-plugin.md)).
- **How strong the evidence is.** Mechanisms rest on repository code and docs read on 2026-11-28, and the Codex loader on its source at rust-v0.172.0. Problem reports are thinner. Several issues were read by title only, the GitHub search hit its rate limit, pull requests were not searched apart from issues, and many reports were filed by AI agents. Claude Code's own docs were not checked, so its folders rest on what the repositories and the Skills CLI say.

## How `obra/superpowers` reaches each harness

Read at v7.0.2, which is also the `main` head, commit `22f0b46` dated 2026-11-03 (tested 2026-11-28: `git log -1` and `git rev-list -n1 v7.0.2`).

**Harnesses**

- The README has install sections for about 16 harnesses, among them Claude Code, Codex App and Codex CLI (tested 2026-11-28: `sed -n 5,30p README.md`, v7.0.2).
- The root holds one manifest folder per harness: `.claude-plugin`, `.codex-plugin`, `.cursor-plugin` and others (tested 2026-11-28: `ls -a`).

**Claude Code**

- Install goes through the official Claude marketplace, `/plugin install superpowers@claude-plugins-official` (tested 2026-11-28: `grep -A14 '^### Claude Code' README.md`, v7.0.2).
- `.claude-plugin/plugin.json` holds metadata only, and Claude Code finds `skills/` and `hooks/hooks.json` by convention ([porting doc, v7.0.2](https://github.com/obra/superpowers/blob/v7.0.2/docs/porting-to-a-new-harness.md)).
- `hooks/hooks.json` registers a SessionStart hook that runs `"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd" session-start` (tested 2026-11-28: `cat hooks/hooks.json`).

**Codex**

- The README points Codex App and CLI users to the official Codex plugin marketplace ([README, v7.0.2](https://github.com/obra/superpowers/blob/v7.0.2/README.md)).
- `.codex-plugin/plugin.json` declares `"skills": "./skills/"`, `"hooks": {}` and an `interface` block (tested 2026-11-28: `cat .codex-plugin/plugin.json`).
- The `{}` stops Codex from falling back to the Claude hook file; an absent field or `[]` falls back again ([RELEASE-NOTES v6.1.1, 2026-07-02](https://github.com/obra/superpowers/blob/v7.0.2/RELEASE-NOTES.md)).
- Codex lost its SessionStart hook in v6.1.0 because Codex triggers skills on its own ([RELEASE-NOTES v6.1.0, 2026-06-30](https://github.com/obra/superpowers/blob/v7.0.2/RELEASE-NOTES.md)).
- Codex marketplaces need `.agents/plugins/marketplace.json`, which v6.1.0 added ([RELEASE-NOTES v6.1.0](https://github.com/obra/superpowers/blob/v7.0.2/RELEASE-NOTES.md)).
- `scripts/sync-to-codex-plugin.sh` copies the plugin files into the fork `prime-radiant-inc/openai-codex-plugins` and leaves out the other harnesses' folders and `CLAUDE.md` (tested 2026-11-28: `sed -n 45,70p scripts/sync-to-codex-plugin.sh`).

**What differs per harness**

- The porting doc names three parts: `skills/` shared verbatim, a tool-mapping file per harness, and a bootstrap per harness ([porting doc Part 1, v7.0.2](https://github.com/obra/superpowers/blob/v7.0.2/docs/porting-to-a-new-harness.md)).
- One hook script detects Cursor, Claude Code, Copilot and Muse by environment variable and shapes its output for each (tested 2026-11-28: `grep -n 'CURSOR\|COPILOT\|CLAUDE_PLUGIN_ROOT\|additional' hooks/session-start`).
- The Codex package script copies an `agents/openai.yaml` into each skill; no such file exists under `skills/` in the source (tested 2026-11-28: `grep -n 'openai.yaml' scripts/package-codex-plugin.sh`; `find skills -name '*.yaml' -o -name '*.yml'`, no output).

**Tool names**

- The porting doc rule is "Skills name actions, not tools", with no edits to skill bodies per harness ([porting doc, v7.0.2](https://github.com/obra/superpowers/blob/v7.0.2/docs/porting-to-a-new-harness.md)).
- v6.0.0 rewrote Claude Code wording such as "use the Task tool" into actions such as "dispatch a subagent" ([RELEASE-NOTES v6.0.0, 2026-06-16](https://github.com/obra/superpowers/blob/v7.0.2/RELEASE-NOTES.md)).
- The bootstrap skill tells the model to read `references/<harness>-tools.md` for its harness (tested 2026-11-28: `grep -A12 'Platform Adaptation' skills/using-superpowers/SKILL.md`).
- A grep for `TodoWrite`, `Task tool`, `Agent tool`, `Skill tool`, `spawn_agent` and `AskUserQuestion` matched only the reference files and one script, never a `SKILL.md` body (tested 2026-11-28: `grep -rnoE … skills`).
- The project's docs disagree. `claude-code-tools.md` says skills speak Claude Code's vocabulary; the porting doc says they never name a tool (tested 2026-11-28: `cat skills/using-superpowers/references/claude-code-tools.md`; [porting doc, v7.0.2](https://github.com/obra/superpowers/blob/v7.0.2/docs/porting-to-a-new-harness.md)).

**Front matter and bundled files**

- All 15 skills use only `name` and `description` (tested 2026-11-28: `awk` over each front matter block).
- Skill prose calls bundled scripts by skill-relative path through an interpreter, such as `bash scripts/sdd-workspace` (tested 2026-11-28: `grep -rnE 'bash scripts/|node \./' skills`).
- The authoring rule gives the reason: some plugin packagers strip executable bits (`skills/writing-skills/SKILL.md:161`, v7.0.2).
- No environment variable appears in `skills/`; `${CLAUDE_PLUGIN_ROOT}` appears only in `hooks/hooks.json` (tested 2026-11-28: `grep -rnE 'CLAUDE_PLUGIN_ROOT|PLUGIN_ROOT|SKILL_DIR' skills`, no matches).

## How `mattpocock/skills` and `google/elephant-goldfish-model` reach each harness

### mattpocock/skills

Read at `main` `bbadaa6` (2026-11-27), 19 commits past v1.3.2 (2026-10-29) (tested 2026-11-28: `gh api --method GET repos/mattpocock/skills/compare/v1.3.2...main -q .ahead_by`).

- The README has install blocks for Claude Code, Codex, Copilot and Gemini CLI, and `npx skills@latest add mattpocock/skills -a <agent>` for other agents ([README, main](https://github.com/mattpocock/skills/blob/main/README.md)).
- Claude Code installs from `claude-plugins-official`; every other managed route uses the repository's `.claude-plugin/marketplace.json` and `plugin.json` ([.agents/install-block.md, main](https://github.com/mattpocock/skills/blob/main/.agents/install-block.md)).
- Codex installs with `codex plugin marketplace add mattpocock/skills` and `codex plugin add mattpocock-skills@mattpocock` (same file).
- The repository has no `.codex-plugin/` folder (tested 2026-11-28: `ls .codex-plugin`, "No such file or directory").
- ADR 0002, updated 2026-10-07, says Codex falls back to `.claude-plugin/` and accepts a `skills` array, and that Codex still drops symlinks ([ADR 0002](https://github.com/mattpocock/skills/blob/main/.agents/adr/0002-ship-as-a-claude-code-plugin.md)). The original ADR, from the v1.2 era, deferred a Codex plugin because arrays were rejected then.
- `.claude-plugin/plugin.json` lists 27 skill folders in a `skills` array, at `main` and at v1.3.2 (tested 2026-11-28: `gh api --method GET repos/mattpocock/skills/contents/.claude-plugin/plugin.json?ref=v1.3.2`, 27 `"./skills` lines).
- A user-only skill sets `disable-model-invocation: true` for Claude Code and `policy.allow_implicit_invocation: false` in `agents/openai.yaml` for Codex, kept in sync by hand ([.agents/invocation.md, main](https://github.com/mattpocock/skills/blob/main/.agents/invocation.md)).
- Every promoted skill has an `agents/openai.yaml` (tested 2026-11-28: `find skills/engineering skills/productivity -name openai.yaml | wc -l`, 27 of 27).
- PR #551 added this metadata "without generated copies" ([CHANGELOG.md, main](https://github.com/mattpocock/skills/blob/main/CHANGELOG.md)).
- Front matter across the 27 skills: `name` 27, `description` 27, `disable-model-invocation` 16, `argument-hint` 2, `metadata` 1 (tested 2026-11-28: `awk` over the front matter blocks).
- Skills are harness-neutral text by policy, and a native question tool is out of scope ([.out-of-scope/native-question-tool.md](https://github.com/mattpocock/skills/blob/main/.out-of-scope/native-question-tool.md)). PR #781 dropped Claude Code's tool and agent-type names from subagent dispatch ([CHANGELOG.md, main](https://github.com/mattpocock/skills/blob/main/CHANGELOG.md)).
- The exception: skill dependencies are written as "call the Skill tool" with the skill's name ([.agents/invocation.md](https://github.com/mattpocock/skills/blob/main/.agents/invocation.md)), found in 11 skills (tested 2026-11-28: `grep -rnoE 'Skill tool' skills/engineering skills/productivity`).
- Bundled files are relative Markdown links inside the skill folder, and links across skill folders are banned ([skills/engineering/tdd/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/tdd/SKILL.md); [.agents/invocation.md](https://github.com/mattpocock/skills/blob/main/.agents/invocation.md)).

### google/elephant-goldfish-model

Read at `main` `4693375` (2026-11-25), 64 commits past v0.1.1 (2026-11-06) (tested 2026-11-28: `gh api … compare/v0.1.1...main -q .ahead_by`).

- `docs/harnesses.md` claims ChatGPT, Codex, Antigravity, Claude Code, Claude Cowork, omp and Muse, and says Antigravity CLI, Claude Code and Codex pass automated install and workflow fixtures ([docs/harnesses.md, main](https://github.com/google/elephant-goldfish-model/blob/main/docs/harnesses.md)). v0.1.1 added experimental Cursor, OpenCode and Copilot adapters ([release v0.1.1](https://github.com/google/elephant-goldfish-model/releases/tag/v0.1.1)).
- The same page says no harness gets a fork of the skill text.
- Claude Code uses `.claude-plugin/plugin.json` and `marketplace.json`, whose `agents` field lists ten Claude-only adapters. Codex uses `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json`, and ships no subagents ([docs/harnesses.md](https://github.com/google/elephant-goldfish-model/blob/main/docs/harnesses.md); [.codex-plugin/plugin.json](https://github.com/google/elephant-goldfish-model/blob/main/.codex-plugin/plugin.json); [.claude-plugin/plugin.json](https://github.com/google/elephant-goldfish-model/blob/main/.claude-plugin/plugin.json)).
- Both Codex files also exist at the v0.1.1 tag (tested 2026-11-28: `gh api --method GET repos/google/elephant-goldfish-model/contents/<path>?ref=v0.1.1`).
- A Claude adapter sets Claude's read-only tools and `omitClaudeMd: true`, and its body tells Claude to read the shared persona at `${CLAUDE_PLUGIN_ROOT}/agents/...` ([docs/harnesses.md](https://github.com/google/elephant-goldfish-model/blob/main/docs/harnesses.md)).
- The packager builds one ZIP with the Claude manifest and adapters and one with the Codex manifest ([scripts/pack_plugin.py, main](https://github.com/google/elephant-goldfish-model/blob/main/scripts/pack_plugin.py); [docs/releases.md](https://github.com/google/elephant-goldfish-model/blob/main/docs/releases.md)).
- Skill text says "spawn a subagent" and maps it inline: Antigravity `invoke_subagent`, Claude Code `Agent`, Codex `spawn_agent` ([resources/execution_instructions.md, main](https://github.com/google/elephant-goldfish-model/blob/main/resources/execution_instructions.md)). The map appears in four skills (tested 2026-11-28: grep for `spawn_agent|invoke_subagent` in `skills/`).
- Each skill opens with a branch: in Codex read `../../docs/codex.md`, in Claude Code read `${CLAUDE_PLUGIN_ROOT}/docs/claude.md` ([skills/egm-review/SKILL.md, main](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-review/SKILL.md)).
- All eight skills use `name`, `description`, `license` and `disable-model-invocation`; one skill has an `agents/openai.yaml` with display fields only (tested 2026-11-28: `awk` over the front matter; `ls skills/*/agents`).
- Bundled files sit two folders above each skill. The instructions give three ways to reach them: `../../`, `${CLAUDE_PLUGIN_ROOT}`, and a `~/.gemini/config/plugins/egm/` fallback ([resources/execution_instructions.md](https://github.com/google/elephant-goldfish-model/blob/main/resources/execution_instructions.md)).
- On Codex, the agent takes its discovered `SKILL.md` path and goes three folders up, assuming no cache location ([docs/codex.md, main](https://github.com/google/elephant-goldfish-model/blob/main/docs/codex.md)).
- Installers that copy `skills/` alone break the plugin, because skills read `agents/` and `resources/` at run time ([docs/harnesses.md](https://github.com/google/elephant-goldfish-model/blob/main/docs/harnesses.md)).

## How `github/spec-kit` reaches each harness

Read at `main` `f201054` (2026-11-25), a few commits after v1.4.5 (published 2026-11-25); the CHANGELOG's newest entry is v1.4.5.

- There is one integration module per harness, about 48 (tested 2026-11-28: `ls src/specify_cli/integrations`).
- The repository has no plugin or marketplace manifest (tested 2026-11-28: `find . -name plugin.json -o -name marketplace.json -o -name .claude-plugin -o -name .codex`, no output).
- Claude Code skills go to `.claude/skills/speckit-<name>/SKILL.md`, hooks to `.claude/settings.json` ([claude/__init__.py, main](https://github.com/github/spec-kit/blob/main/src/specify_cli/integrations/claude/__init__.py)).
- Codex skills go to `.agents/skills/speckit-<name>/SKILL.md`, hooks to `.codex/config.toml`; Codex commands are deprecated ([codex/__init__.py, main](https://github.com/github/spec-kit/blob/main/src/specify_cli/integrations/codex/__init__.py)).
- In dev mode Codex skills are written as files, not symlinks (`dev_no_symlink = True`; "fix: write Codex dev skills as files (#2988)", [CHANGELOG.md](https://github.com/github/spec-kit/blob/main/CHANGELOG.md)).
- The invocation prefix is `$` for Codex and ZCode, `/skill:` for Kimi and `/` for the rest ([_invocation_style.py, main](https://github.com/github/spec-kit/blob/main/src/specify_cli/_invocation_style.py)).
- Several integrations can be installed in one project, for team portability, with one default ([docs/integrations/cli.md, main](https://github.com/github/spec-kit/blob/main/docs/integrations/cli.md)).
- Non-interactive dispatch is `claude -p` with `--effort` for Claude and `codex exec` with `-c` settings for Codex ([claude/__init__.py](https://github.com/github/spec-kit/blob/main/src/specify_cli/integrations/claude/__init__.py); [codex/__init__.py](https://github.com/github/spec-kit/blob/main/src/specify_cli/integrations/codex/__init__.py)).
- Command templates name no harness tool (tested 2026-11-28: `grep -n -E "\b(TodoWrite|AskUserQuestion|WebFetch|Bash tool|Read tool|apply_patch|update_plan|shell tool)\b" templates/commands/*.md`, no matches).
- At install, `process_template` fills `{SCRIPT}`, `{ARGS}`, `__AGENT__` and `__SPECKIT_COMMAND_<NAME>__`, and rewrites `scripts/` to `.specify/scripts/` ([base.py, main](https://github.com/github/spec-kit/blob/main/src/specify_cli/integrations/base.py)).
- Every generated skill gets `name`, `description`, `compatibility` and `metadata`, following agentskills.io ([agents.py `build_skill_frontmatter`, main](https://github.com/github/spec-kit/blob/main/src/specify_cli/agents.py)).
- Claude copies also get `user-invocable`, `disable-model-invocation` and `argument-hint`; Codex copies get none ([claude/__init__.py `post_process_skill_content`](https://github.com/github/spec-kit/blob/main/src/specify_cli/integrations/claude/__init__.py); [base.py](https://github.com/github/spec-kit/blob/main/src/specify_cli/integrations/base.py)).
- Shared scripts, templates and memory live once in `.specify/`, and template paths are rewritten to project-root paths ([agents.py `rewrite_project_relative_paths`](https://github.com/github/spec-kit/blob/main/src/specify_cli/agents.py)).
- Open requests ask for an official Claude Code plugin ([#5584, 2026-11-26](https://github.com/github/spec-kit/issues/5584)) and for skills published under `.agents/skills` for `npx skills add` ([#5483, 2026-11-18](https://github.com/github/spec-kit/issues/5483)).

## How `Fission-AI/OpenSpec` and `open-gsd/gsd-core` reach each harness

### OpenSpec

Read at the default branch `dff0188` (2026-11-28, `package.json` 2.2.0) and the v2.2.0 tag (2026-11-24).

- The README claims 30+ tools and gives `/openspec-propose` for most and `$openspec-propose` for Codex ([README.md](https://github.com/Fission-AI/OpenSpec/blob/main/README.md)).
- The `openspec` CLI generates the files. A committed `skills/` folder also serves `npx skills add Fission-AI/OpenSpec`, generated from the same templates and held in step by a parity test ([skills/README.md](https://github.com/Fission-AI/OpenSpec/blob/main/skills/README.md)).
- The repository root has no plugin or marketplace manifest (root listing in the clone, 2026-11-28).
- Since 2.0, skills are written once to `.agents/skills/`, and Claude Code and other tools get a link in their own `skills/` folder ([CHANGELOG 2.0.0](https://github.com/Fission-AI/OpenSpec/blob/main/CHANGELOG.md)).
- 2.0 also stopped writing command files ([CHANGELOG 2.0.0](https://github.com/Fission-AI/OpenSpec/blob/main/CHANGELOG.md)).
- Since 2.1, install is global by default and needs Git and access to GitHub ([CHANGELOG 2.1.0](https://github.com/Fission-AI/OpenSpec/blob/main/CHANGELOG.md)).
- Codex is skills-only, and Codex skills moved from `.codex/skills` to `.agents/skills` ([CHANGELOG.md](https://github.com/Fission-AI/OpenSpec/blob/main/CHANGELOG.md)).
- Per tool only skill cross-references change: `$name` for Codex, the bare name in the shared copy (`src/utils/command-references.ts`, read in the clone).
- Only the Eve agent gets front matter stripped of `allowed-tools`; Claude Code and Codex get the same front matter (`src/core/skill-installer.ts`).
- `.agents/skills/` has one writer, and `.agents/skills/.openspec-target` lists the tools set up in the project ([docs/supported-tools.md](https://github.com/Fission-AI/OpenSpec/blob/main/docs/supported-tools.md); `src/core/shared-skill-target.ts`).
- A grep of `skills/` for `AskUserQuestion`, `TodoWrite`, `Task tool`, `request_user_input` and `update_plan` found nothing (tested 2026-11-28: `grep -rhoE … skills`).
- The one Claude-style name left is `allowed-tools: Bash(openspec:*)`, which only pre-approves; other tools ignore it (`src/core/shared/allowed-tools.ts`).
- `skills/openspec-propose/SKILL.md` uses `name`, `description`, `allowed-tools`, `license`, `compatibility` and `metadata` (read in the clone).
- The router skill reads `references/where-things-stand.md` relative to its folder, and skills call the `openspec` CLI on `PATH` (`skills/openspec/SKILL.md`).
- `docs/supported-tools.md` still describes per-tool command files and the retired `delivery` setting, against the 2.0 changelog. A code comment in `command-references.ts` sides with the changelog.

### gsd-core

Read at `next` `e9c3e54` (2026-11-28, `package.json` 1.23.0). Its CHANGELOG has an empty `[Unreleased]` above 1.23.0 (2026-11-23).

- The install guide has flags for 17 runtimes, `--claude` and `--codex` among them (tested 2026-11-28: `grep -o -E "\-\-(claude|…)\b" docs/how-to/install-on-your-runtime.md | sort -u`).
- Sources are written in Claude Code's front matter format, and the installer transforms them for each runtime ([install-on-your-runtime.md, next](https://github.com/open-gsd/gsd-core/blob/next/docs/how-to/install-on-your-runtime.md)). The README says not to copy files directly ([README.md, next](https://github.com/open-gsd/gsd-core/blob/next/README.md)).
- `npx @opengsd/gsd-core@latest --claude --global` writes to `~/.claude/` and registers hooks on several events ([install-on-your-runtime.md](https://github.com/open-gsd/gsd-core/blob/next/docs/how-to/install-on-your-runtime.md)).
- The Claude plugin path uses `.claude-plugin/plugin.json` with `"skills": "./skills/"`, from a marketplace entry that points at a prebuilt `plugin` branch (read in the clone).
- On that path skills are namespaced `/gsd-core:gsd-<command>`, install-time config does not apply, and the statusline is not registered ([install-on-your-runtime.md](https://github.com/open-gsd/gsd-core/blob/next/docs/how-to/install-on-your-runtime.md)).
- For Codex, the guide says skills land in `~/.codex/skills/gsd-*/SKILL.md` and agents become `~/.codex/agents/gsd-*.toml`, with Codex CLI 0.130.0 as the floor and 0.137.0 for hooks (same guide).
- Issue #4086 says the opposite about the skill folder: "Codex installs skills to ~/.agents/skills". It was closed 2026-09-05 by PR #4311 ([#4086](https://github.com/open-gsd/gsd-core/issues/4086)). Which one the 1.23.0 installer writes was not checked.
- No Codex plugin manifest is in the root (root listing in the clone).
- The rewriting lives in one module of 4,939 lines ([ADR 1508, Accepted 2026-06-20](https://github.com/open-gsd/gsd-core/blob/next/docs/adr/1508-runtime-artifact-conversion-module.md); tested: `wc -l src/runtime-artifact-conversion.cts`).
- For Codex the converter turns slash commands into skill mentions, rewrites `.claude` paths to `.codex`, and calls `gsd-tools` by absolute path (`convertClaudeToCodexMarkdown`, line 2217, read in the clone).
- Codex skills get new front matter, `name`, `description` and `metadata.short-description`, and lose `allowed-tools` and `argument-hint` (around line 2395).
- Source skills list Claude tools, for example `allowed-tools: [Read, Write, Bash, Glob, Grep, Agent, AskUserQuestion, WebFetch, mcp__context7__*]` (`skills/gsd-plan-phase/SKILL.md`).
- Other runtimes get tool names through lookup tables and regexes, such as `TodoWrite(` to `add_tasks(` (lines 130–336 and 1499–1779).
- Codex gets a prepended adapter block that maps `AskUserQuestion` to `request_user_input` and `Task()` to `spawn_agent`, with a text fallback (`getCodexSkillAdapterHeader`, line 2253).
- Source skills include bundled files as `@~/.claude/gsd-core/workflows/...`, and the installer rewrites the prefix per runtime and scope (`skills/gsd-plan-phase/SKILL.md` lines 38–39).
- A code comment says relative `@` paths resolve against the importing file, so no static include can prefer a local copy and fall back to the global one. The installer writes a two-step instruction instead (lines 596–606).

## How `bmad-code-org/BMAD-METHOD` reaches each harness

Read at v6.12.4 (2026-10-14), the latest release, and at `main` `e435a22` (2026-11-12), the v7 preview alpha. No v7 release existed on 2026-11-28 (tested: `gh release list -R bmad-code-org/BMAD-METHOD -L 3`).

- The README says v6.12 is stable and installed by npm, and v7 on `main` is a preview whose install path changes often ([README, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/README.md)).
- On `main`, each module installs with `npx skills add bmad-code-org/BMAD-METHOD/skills/<module> --skill '*'`, which asks which tools to install to (same README).
- v6.12.4 lists 48 platforms (tested 2026-11-28: `git show v6.12.4:tools/installer/ide/platform-codes.yaml | grep -cE "^  [a-z]"`). Claude Code maps to `.claude/skills` and `~/.claude/skills`; Codex maps to `.agents/skills` and `~/.codex/skills`; both are `preferred`.
- The platform file says paths were checked against each tool's docs as of 2026-04-25 ([platform-codes.yaml, v6.12.4](https://github.com/bmad-code-org/BMAD-METHOD/blob/v6.12.4/tools/installer/ide/platform-codes.yaml)).
- v6.12.4 also ships `.claude-plugin/marketplace.json` with one plugin of 28 skill folders and no Codex manifest ([marketplace.json, v6.12.4](https://github.com/bmad-code-org/BMAD-METHOD/blob/v6.12.4/.claude-plugin/marketplace.json); tested 2026-11-28: `git ls-tree -r --name-only v6.12.4 | grep -iE "plugin|marketplace"`).
- `main` has no plugin manifest or root `package.json` (tested 2026-11-28: `find . -name ".claude-plugin" -o -name ".codex*" -o -name "plugin.json" -o -name "package.json"`, only `./docs-site/package.json`).
- The installer copies `SKILL.md` folders verbatim, with no front matter change ([_config-driven.js, v6.12.4](https://github.com/bmad-code-org/BMAD-METHOD/blob/v6.12.4/tools/installer/ide/_config-driven.js)).
- Some platforms, such as Copilot, also get generated pointer files; the Claude Code and Codex entries hold only folder keys ([platform-codes.yaml, v6.12.4](https://github.com/bmad-code-org/BMAD-METHOD/blob/v6.12.4/tools/installer/ide/platform-codes.yaml)).
- A grep of `main` skills found no Claude tool names; harness names appear only in Toolsmith and eval files (tested 2026-11-28: `grep -rniE "claude code|codex|Bash tool|Task tool|subagent|AskUserQuestion|TodoWrite|CLAUDE_PLUGIN|…" skills`).
- Skill text names capabilities with a fallback, such as running lenses inline when subagents are unavailable ([bmad-toolsmith/modes/review.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/toolsmith/bmad-toolsmith/modes/review.md)).
- All 33 `SKILL.md` files on `main` use only `name` and `description` (tested 2026-11-28: `grep -rhoE "^[a-z_-]+:" --include=SKILL.md skills | sort | uniq -c`).
- The stub tells the model to replace `{project-root}` with the nearest folder holding `_bmad/` and `{skill-root}` with the skill's absolute path. It then runs `render_skill.py` through `uv` ([bmad-build/SKILL.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/method/bmad-build/SKILL.md)).
- In v6.12.4, `{project-root}` meant the project root, without the walk-up ([bmad-build/SKILL.md, v6.12.4](https://github.com/bmad-code-org/BMAD-METHOD/blob/v6.12.4/src/bmm-skills/ship/bmad-build/SKILL.md)).
- The validator says the agent fills both placeholders at run time ([tools/skill-validator.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/tools/skill-validator.md)). PR #2988 (merged 2026-09-29) added rule PATH-06, which rejects a script call without `{skill-root}` (tested 2026-11-28: `gh pr view 2988`).
- The v7 eval harness runs skills under both `codex exec` with `.agents/skills` and `claude -p` with `.claude/skills` ([bmad-eval/references/harness.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/toolsmith/bmad-eval/references/harness.md)).

## Cross-harness problems reported across the seven

All issues below were read with `gh issue view` or GraphQL on 2026-11-28, unless marked as read by title. A resolution counts only when a closing pull request or maintainer comment shows it.

**Tool names that only Claude Code has**

- superpowers: Claude Code guidance in skill bodies misled Codex agents; closed 2026-07-13, with the reply that version 6 fixed it ([#1883](https://github.com/obra/superpowers/issues/1883)).
- superpowers: the session-start banner names the `Skill` tool even in Copilot output, where the tool is `skill`; open ([#2729, 2026-11-22](https://github.com/obra/superpowers/issues/2729)).
- mattpocock: Codex does not expose a Skill tool. #1393 was closed as not planned 2026-11-25: the maintainer changes skills only after a real-session failure, and says harnesses without the tool generally map it ([#1393](https://github.com/mattpocock/skills/issues/1393)). The matching request #1123 is open ([#1123](https://github.com/mattpocock/skills/issues/1123)).
- OpenSpec: a generated skill, in both the Claude and Codex copies, told the agent to use the `Task` and `Skill` tools to invoke a sync skill that v1.3.1 did not ship; the report is about the missing skill, not the tool names; closed 2026-09-29 by PR #1977 ([#1975](https://github.com/Fission-AI/OpenSpec/issues/1975)).
- OpenSpec: skills named `AskUserQuestion` (#1464) and `TodoWrite` (#1403), and agents without those tools errored or stalled; both now neutral ([CHANGELOG.md](https://github.com/Fission-AI/OpenSpec/blob/main/CHANGELOG.md)).

**One harness reading another's files, or a skill seen twice**

- superpowers: with no `hooks` field, Codex loaded the Claude `hooks/hooks.json`, trust prompt included; fixed in v6.1.1 with `"hooks": {}` ([RELEASE-NOTES v6.1.1](https://github.com/obra/superpowers/blob/v7.0.2/RELEASE-NOTES.md)).
- superpowers: Antigravity fell back to the Gemini extension and rejected the copied Claude hook file; fixed in v7.0.1 with its own manifest ([RELEASE-NOTES v7.0.1](https://github.com/obra/superpowers/blob/v7.0.2/RELEASE-NOTES.md)).
- OpenSpec: Pi found every skill twice, in `.pi/skills/` and `.agents/skills/`; closed 2026-11-16 by the 2.0 single copy ([#2180](https://github.com/Fission-AI/OpenSpec/issues/2180)).
- OpenSpec: with `.agents/skills` linked to `.claude/skills`, each `update` flipped skill references between two forms; closed by PR #2223 ([#2232](https://github.com/Fission-AI/OpenSpec/issues/2232)).
- OpenSpec: the vendor-neutral target's skills could be rewritten with Codex syntax, because both share `.agents/skills` (PR #1522, [CHANGELOG.md](https://github.com/Fission-AI/OpenSpec/blob/main/CHANGELOG.md)).
- BMAD: Codex truncated skill descriptions past its 2% context budget, with 133 visible `SKILL.md` files across `.agents/skills` and `.codex/skills`; closed 2026-04-29 ([#2343](https://github.com/bmad-code-org/BMAD-METHOD/issues/2343)).
- spec-kit: with Claude as default and Codex second, `specify extension update` deletes the extension's skills from Codex; open ([#5002, 2026-10-17](https://github.com/github/spec-kit/issues/5002)).

**Bundled files and roots that resolve wrongly**

- superpowers: the Codex marketplace cache delivered helper scripts as mode `0644`, so direct calls failed; fixed in v6.4.1 by calling scripts through their interpreter ([#2040](https://github.com/obra/superpowers/issues/2040); [RELEASE-NOTES v6.4.1](https://github.com/obra/superpowers/blob/v7.0.2/RELEASE-NOTES.md)).
- superpowers: helper scripts that call sibling scripts still fail that way at v7.0.2, against the v6.4.1 note; open ([#2723, 2026-11-21](https://github.com/obra/superpowers/issues/2723)).
- spec-kit: extension skill references were rewritten relative to the project root, so agents that resolve from the `SKILL.md` folder did not find them; follow-up #5366 copies resources beside the skill, closed 2026-11-18 ([#5363](https://github.com/github/spec-kit/issues/5363); [#5366](https://github.com/github/spec-kit/issues/5366)).
- elephant-goldfish-model: under omp, `skill://` reads reject `..`, so plugin-root files look absent; open ([#455, 2026-11-16](https://github.com/google/elephant-goldfish-model/issues/455)).
- BMAD: a Codex audit of v6.12.0 found that nested working folders gave the wrong `{project-root}`, because Codex scans `.agents/skills` from the working folder upward; the audit's items were fixed across several PRs, among them #2966 and #2988, without the comments saying which one fixed this item ([#2915](https://github.com/bmad-code-org/BMAD-METHOD/issues/2915)).
- BMAD: headless Codex agents misderived `{project-root}` or `{skill-root}` in 13 of 121 measured runs, and 9 of those did no work; all 47 runs that passed `$PWD` got paths right. Closed 2026-11-27 after #3279 merged to `dev` ([#3179](https://github.com/bmad-code-org/BMAD-METHOD/issues/3179)).
- gsd-core: Codex installs kept `@~/.claude/gsd-core/` includes, reading the Claude copy on dual-runtime machines and nothing on Codex-only ones ([CHANGELOG.md, next](https://github.com/open-gsd/gsd-core/blob/next/CHANGELOG.md)).

**Front matter that one harness reads differently**

- mattpocock: a skill with no `agents/openai.yaml` could be auto-invoked by Codex although its Claude front matter marks it user-only; closed 2026-11-25 ([#1431](https://github.com/mattpocock/skills/issues/1431)).
- mattpocock: `allow_implicit_invocation: false` hid a skill from Codex's model-visible list, so only an explicit `$name` worked; PR #766 dropped it ([CHANGELOG.md](https://github.com/mattpocock/skills/blob/main/CHANGELOG.md)).
- mattpocock: OpenCode v2 ignores both invocation fields; open ([#1079](https://github.com/mattpocock/skills/issues/1079)).
- BMAD: Codex skipped a template `SKILL.md` whose unquoted `name: { … }` parsed as a YAML map; closed 2026-04-13 ([#2232](https://github.com/bmad-code-org/BMAD-METHOD/issues/2232)).
- spec-kit: one renderer skipped per-harness post-processing, so Claude extension skills lost `argument-hint` and `user-invocable`; closed 2026-11-17 by PR #5449 ([#5448](https://github.com/github/spec-kit/issues/5448)).

**Codex's subagent contract**

- mattpocock: on Codex, `fork_turns` defaults to a full-history fork, so reviewers inherited the conversation; closed as "the harness's business" ([#1257](https://github.com/mattpocock/skills/issues/1257)). PR #1341 later made skills ask for a fresh context ([CHANGELOG.md](https://github.com/mattpocock/skills/blob/main/CHANGELOG.md)).
- elephant-goldfish-model: Codex supplies project and user `AGENTS.md` to reviewers even with `fork_turns: "none"`; open ([#237, 2026-10-30](https://github.com/google/elephant-goldfish-model/issues/237)).
- BMAD: Codex's `spawn_agent` requires an explicit user request for subagents, which conflicts with skills that need them; closed 2026-08-29 in a sweep ([#2451](https://github.com/bmad-code-org/BMAD-METHOD/issues/2451)).
- superpowers: the Codex reference describes `spawn_agent` parameters that one Codex desktop session lacks; open, and limited by the filer to that environment ([#2260](https://github.com/obra/superpowers/issues/2260)).
- gsd-core: the generated Codex adapter used an obsolete `wait(ids)`/`fork_context` contract; closed 2026-08-06 by PR #3104 ([#3004](https://github.com/open-gsd/gsd-core/issues/3004)).

**Generators, installers and marketplaces that damage files**

- gsd-core: `--codex --uninstall` deleted user tables in `~/.codex/config.toml`; closed 2026-11-26 by PR #5395 ([#5199](https://github.com/open-gsd/gsd-core/issues/5199)).
- gsd-core: agents with a YAML block list in `tools:` were installed with one mangled entry for Copilot and Codex; and Codex `.compact.md` alternates overwrote their canonical agents until 1.23.0 ([CHANGELOG.md, next](https://github.com/open-gsd/gsd-core/blob/next/CHANGELOG.md)).
- spec-kit: generated Codex skills tell the user to run hooks with `/`, against the `$` note in the same skill; open ([#4954, 2026-10-13](https://github.com/github/spec-kit/issues/4954)).
- superpowers: the ChatGPT marketplace importer rejects the Codex marketplace entry's relative `"url": "./"`; open ([#2559, 2026-10-20](https://github.com/obra/superpowers/issues/2559)).
- elephant-goldfish-model: the packager built a Codex ZIP whose manifest pointed at a missing skill folder; closed 2026-11-23 by PR #512 ([#509](https://github.com/google/elephant-goldfish-model/issues/509)).

**Limits on these reports**

- Many reports say an AI agent filed or triaged them, for example superpowers #2583 and triage comments in gsd-core and mattpocock ([#2583](https://github.com/obra/superpowers/issues/2583)). Some came from reading source, not from a failing session ([mattpocock #1393](https://github.com/mattpocock/skills/issues/1393)).
- BMAD's fixes for #3179 landed on `dev` after v6.12.4 ([#3179](https://github.com/bmad-code-org/BMAD-METHOD/issues/3179)); whether a release carries them was not tested.
- Codex behaviour in these reports is tied to Codex versions, such as CLI 0.162.1 in mattpocock #1257 and 0.166.0 in elephant-goldfish-model #237 ([docs/harnesses.md](https://github.com/google/elephant-goldfish-model/blob/main/docs/harnesses.md)).

## Where the Skills CLI places a skill for Claude Code and Codex

The `skills` npm package comes from `vercel-labs/skills`, latest 1.9.1, published 2026-11-27 (tested 2026-11-28: `npm view skills repository homepage description`; `npm view skills --json`). It had three releases in November 2026 (tested: `gh api --method GET repos/vercel-labs/skills/releases`).

- Its agent table gives Claude Code `.claude/skills` and `~/.claude/skills`, the latter under `CLAUDE_CONFIG_DIR` when set ([`src/agents.ts`, v1.9.1](https://github.com/vercel-labs/skills/blob/v1.9.1/src/agents.ts)).
- Codex gets `.agents/skills` and `~/.agents/skills`, and any agent with `.agents/skills` counts as universal (same file).
- The default mode copies the skill into the canonical `.agents/skills/<name>` and symlinks other agents' folders to it; `--copy` gives each agent its own copy ([`src/installer.ts`, v1.9.1](https://github.com/vercel-labs/skills/blob/v1.9.1/src/installer.ts)).
- Universal agents read the canonical folder with no link of their own (same file). The docs say choosing Claude Code adds links under `.claude/skills/` ([`docs/commands.md`, v1.9.1](https://github.com/vercel-labs/skills/blob/v1.9.1/docs/commands.md)).
- When a symlink fails, the CLI copies instead; on Windows the link is a junction (`src/installer.ts`).
- The copy replaces symlinks with their targets and skips links that leave the skill folder; it keeps file modes (`copyDirectory`, `src/installer.ts`).
- It leaves out `metadata.json` and the `.git`, `__pycache__` and `__pypackages__` folders ([`src/skill-hash.ts`, v1.9.1](https://github.com/vercel-labs/skills/blob/v1.9.1/src/skill-hash.ts)).
- Only Eve copies have `SKILL.md` rewritten; Claude Code and Codex copies are not (`src/installer.ts`). `--rename` rewrites the `name` field ([`docs/commands.md`](https://github.com/vercel-labs/skills/blob/v1.9.1/docs/commands.md)).
- `.codex/skills` is now only a legacy folder the CLI searches in source repositories (`src/agents.ts`).
- Pointers to it: mattpocock/skills uses it for agents other than its main ones ([README](https://github.com/mattpocock/skills#readme)); BMAD `main` installs every module with it ([README](https://github.com/bmad-code-org/BMAD-METHOD#readme)); OpenSpec's `skills/README.md` names it, and OpenSpec's installer imports the package. No reference was found in OpenSpec's root README (tested 2026-11-28: `grep -i "skills add\|skills@\|vercel\|skills.sh"`, no output).

Reports in the CLI's tracker:

- Claude Code cannot see skills installed only in `.agents`; open ([#1045, 2026-05-01](https://github.com/vercel-labs/skills/issues/1045)).
- A global install with `-a claude-code` made no `~/.claude/skills` link; open ([#851, 2026-04-03](https://github.com/vercel-labs/skills/issues/851)).
- The same problem at project scope was fixed in v1.5.26; closed 2026-11-05 ([#1355](https://github.com/vercel-labs/skills/issues/1355)). Titles of further closed reports of this kind run from March to July 2026 (#481, #1385, #1412, #1579, read by title).
- Codex listed skills twice because installs went to both `~/.codex/skills` and `~/.agents/skills`; fixed in v1.7.2 (2026-10-09) ([#1056](https://github.com/vercel-labs/skills/issues/1056); tested: `gh release view v1.7.2 -R vercel-labs/skills`).
- Run inside Claude Code, the CLI failed to detect it and wrote copies into other agents' folders; closed 2026-11-27 ([#2845](https://github.com/vercel-labs/skills/issues/2845)).
- A skill folder that is also a Claude Code plugin loses `plugin.json` and hooks on install; open ([#2609, 2026-10-28](https://github.com/vercel-labs/skills/issues/2609)).

## How Codex loads a plugin from a repository

Read from `openai/codex` at `rust-v0.172.0`, the latest non-prerelease, published 2026-11-24 (tested 2026-11-28: `gh api --method GET repos/openai/codex/releases/latest`). Prereleases `0.174.0-alpha.*` up to 2026-11-27 were not read.

- Codex first accepts a root `plugin.json` only if its `$schema` is an Agent Plugins schema ([`plugin_namespace.rs`, rust-v0.172.0](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/utils/plugins/src/plugin_namespace.rs)).
- It then tries `.codex-plugin/plugin.json`, `.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json`, and the first regular file wins ([`protocol.rs`](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/exec-server-protocol/src/protocol.rs); [`plugin_namespace.rs`](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/utils/plugins/src/plugin_namespace.rs)).
- A symlinked manifest ends the lookup with no manifest (`plugin_namespace.rs`).
- A unit test loads a plugin that has only `.claude-plugin/plugin.json` ([`manifest.rs`, test `plugin_manifest_uses_alternate_discoverable_path`](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/core-plugins/src/manifest.rs)).
- Marketplaces are looked up in `.agents/plugins/marketplace.json`, `.agents/plugins/api_marketplace.json`, `.claude-plugin/marketplace.json`, then `.cursor-plugin/marketplace.json` ([`marketplace.rs`](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/core-plugins/src/marketplace.rs)).
- The bundle-archive path rejects a bundle only when it has no `.codex-plugin/plugin.json` and `load_plugin_manifest` finds no manifest; its error message names only Codex and Agent Plugin manifests, and whether that lookup includes `.claude-plugin/` here was not traced ([`plugin_bundle_archive.rs`](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/core-plugins/src/plugin_bundle_archive.rs)). Several store and sync files also join `.codex-plugin/plugin.json` directly.
- With no `hooks` field, Codex loads `hooks/hooks.json` from the plugin root; with one, it uses only the field ([`loader.rs`](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/core-plugins/src/loader.rs)). The docs say the same ([Codex docs, Hooks, fetched 2026-11-28](https://developers.openai.com/codex/hooks)).
- The `hooks` field takes a path, a list of paths, an inline object or a list of objects; an empty list maps to no field ([`manifest.rs`](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/core-plugins/src/manifest.rs)).
- Inferred: `"hooks": {}` parses as an empty inline object, which the loader skips, so the default file never loads. This rests on the serde attributes in `manifest.rs` and `hook_config.rs` and the loader branch; no test covers `{}`.
- Inferred: a plugin that Codex reads through `.claude-plugin/plugin.json` and that ships a Claude `hooks/hooks.json` gets that file loaded, unless the Claude manifest sets `hooks`. This rests on the lookup order and the default-hooks branch.
- Hooks are on by default and the plugin-hooks flag is removed ([`features/src/lib.rs`](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/features/src/lib.rs)).
- The build docs say plugins with lifecycle hooks are not eligible for the public plugin directory ([Codex docs, Build plugins, fetched 2026-11-28](https://developers.openai.com/codex/plugins/build)).
- With no `skills` field, Codex uses `<plugin root>/skills/`; a manifest value replaces it ([`loader.rs`](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/core-plugins/src/loader.rs)).
- Outside plugins, Codex scans `.agents/skills` in each folder from the working folder up to the project root, then `$HOME/.agents/skills` ([`host_roots.rs`](https://github.com/openai/codex/blob/rust-v0.172.0/codex-rs/ext/skills/src/host_roots.rs); [Codex docs, Skills](https://developers.openai.com/codex/skills)).
- The code still reads `$CODEX_HOME/skills`, marked deprecated, and a project config folder's `skills/`; the docs list neither (`host_roots.rs`).
- The docs now prefer a root `plugin.json` in the Agent Plugins format and call `.codex-plugin/plugin.json` a compatibility fallback. They say Codex accepts "Claude-compatible manifests" and name `.claude-plugin/marketplace.json` as legacy-compatible ([Codex docs, Build plugins](https://developers.openai.com/codex/plugins/build)).
- Plugin hook commands receive `PLUGIN_ROOT` and `PLUGIN_DATA` ([Codex docs, Hooks](https://developers.openai.com/codex/hooks)).

## How gsd-core plugin installs resolve their includes, and how OpenSpec links into `.claude/skills/`

**gsd-core on the Claude plugin route**, read at the `plugin` branch `2869610` (2026-11-23):

- The `plugin` branch is the release tree plus compiled `.cjs` files, built by the release workflow ([`scripts/publish-plugin-ref.cjs`, next](https://github.com/open-gsd/gsd-core/blob/next/scripts/publish-plugin-ref.cjs)).
- Its 72 skills keep the `@~/.claude/gsd-core/...` includes unchanged (tested 2026-11-28: `grep -rho '@[^ ]*gsd-core[^ ]*' skills` and `ls skills | wc -l` on the plugin branch).
- Before a fix, those includes resolved to nothing on plugin installs, because files land in `~/.claude/plugins/cache/...`; closed 2026-06-14 ([#997](https://github.com/open-gsd/gsd-core/issues/997)).
- The fix is a SessionStart hook that creates `~/.claude/gsd-core/` and links five subfolders to the plugin cache, using junctions on Windows ([`hooks/gsd-ensure-canonical-path.js`, next](https://github.com/open-gsd/gsd-core/blob/next/hooks/gsd-ensure-canonical-path.js)).
- The hook's header gives the reason: `@` includes expand `~` but not environment variables, so `${CLAUDE_PLUGIN_ROOT}` cannot be used in them (same file).
- The hook runs first in the SessionStart list, as `node "${CLAUDE_PLUGIN_ROOT}/hooks/gsd-ensure-canonical-path.js"` ([`hooks/hooks.json`, next](https://github.com/open-gsd/gsd-core/blob/next/hooks/hooks.json)).
- The hooks need `node` on `PATH`, which some standalone Claude Code builds lack, and `gsd-tools` must be on `PATH` ([install-on-your-runtime.md](https://github.com/open-gsd/gsd-core/blob/next/docs/how-to/install-on-your-runtime.md)).
- The npm installer rewrites the includes for Codex to `@~/.codex/gsd-core/` ([`bin/install.js`, next, lines 1006–1012](https://github.com/open-gsd/gsd-core/blob/next/bin/install.js)).
- A plugin update from 1.18 to 1.19 left the runtime unbuilt and every command failing; the prebuilt branch fixed it, closed 2026-11-16 ([#5796](https://github.com/open-gsd/gsd-core/issues/5796)).

**OpenSpec's `.claude/skills/` entries**, read at v2.2.0:

- OpenSpec writes skill files to a temporary folder and calls `installSkills` from the `skills` package, pinned at 1.8.1 ([`src/core/skill-installer.ts`, v2.2.0](https://github.com/Fission-AI/OpenSpec/blob/v2.2.0/src/core/skill-installer.ts); [`package.json`, v2.2.0](https://github.com/Fission-AI/OpenSpec/blob/v2.2.0/package.json)).
- The mode is `copy` at project scope on Windows and `auto` otherwise, because Git cannot carry a junction to a teammate (`skill-installer.ts`).
- `skills@1.8.1` makes a relative symlink, or a junction with an absolute target on Windows (tested 2026-11-28: `grep -rn junction package/dist` in the unpacked tarball, `dist/_chunks/remove.mjs` lines 2789–2790).
- After a global install, OpenSpec reads each copy back and reports an agent that did not install; project scope skips this check (`skill-installer.ts`).
- The 2.0.0 changelog promises a plain copy where a link can't be made; 2.1.0 handed placement to Vercel's installer ([CHANGELOG, v2.2.0](https://github.com/Fission-AI/OpenSpec/blob/v2.2.0/CHANGELOG.md)).
- Committed links check out on Windows as small text files unless `core.symlinks` is on, and `openspec update` then replaces them with copies ([CHANGELOG 2.0.0](https://github.com/Fission-AI/OpenSpec/blob/v2.2.0/CHANGELOG.md)).

## Open questions

- **Does Claude Code read `.agents/skills`?** The Skills CLI docs, BMAD's docs table and issue reporters say it reads only `.claude/skills`. Claude Code's own docs were not checked. If it does read `.agents/skills`, the link step in OpenSpec and the Skills CLI matters less.
- **How does each harness tell the model a skill's folder?** No source was found. superpowers, elephant-goldfish-model and BMAD all depend on the model knowing it.
- **Does `${CLAUDE_PLUGIN_ROOT}` expand in skill text?** elephant-goldfish-model relies on it in `SKILL.md`; gsd-core says it does not expand in `@` includes. Neither claim was checked against Claude Code's docs.
- **Does `"hooks": {}` load no hooks?** The answer rests on reading Codex's code; no test covers it.
- **Do all Codex install routes accept `.claude-plugin/` alone?** The store paths check `.codex-plugin/plugin.json` directly, the bundle-archive path also accepts whatever `load_plugin_manifest` finds, and which routes call them was not traced. mattpocock/skills relies on the fallback.
- **Does elephant-goldfish-model's root `plugin.json` declare the Agent Plugins schema?** If it does, Codex reads it before `.codex-plugin/plugin.json`. The file was not read for `$schema`.
- **Which folder does gsd-core 1.23.0 write Codex skills to?** The install guide says `~/.codex/skills`; issue #4086 says `~/.agents/skills`.
- **Do the problem lists miss newer reports?** The GitHub search hit its rate limit, pull requests were not searched apart from issues, and several issues were read by title only.

## Method

- Confirmed by user: no (the owner delegated the check to the orchestrating session, which read the brief and changed nothing).
- Researcher 1 (notes-1) covered `obra/superpowers`; researcher 2 (notes-2) `mattpocock/skills` and `google/elephant-goldfish-model`; researcher 3 (notes-3) `github/spec-kit`; researcher 4 (notes-4) `Fission-AI/OpenSpec` and `open-gsd/gsd-core`; researcher 5 (notes-5) `bmad-code-org/BMAD-METHOD`; researcher 6 (notes-6) the problems reported across all seven.
- Sub-questions 7 to 9 were added after confirmation. Researcher 7 (notes-7) covered the Skills CLI, researcher 8 (notes-8) the Codex plugin loader, and researcher 9 (notes-9) the gsd-core plugin includes and OpenSpec's links.
- Repositories were shallow-cloned read-only and deleted; GitHub was queried with `gh` and npm with `npm view`. No skill, installer or CLI was run, and no generated `SKILL.md` from a real install was read.
- Source check, 2026-11-28, by a separate session: every release in `versions` matched the latest on GitHub, npm and the Codex releases API. All Answer sources, all cited issues by title and state, and the changelogs, release notes and Codex files behind the findings were reopened; findings from clones (counts, greps, line numbers) and the Codex and Claude docs pages were not rechecked. Narrowed the "ship one folder unchanged" and "keep two files in step" Answer bullets, the March-to-November dating of the Skills CLI link reports (filed March to July), OpenSpec #1975 (about a missing skill, so the Answer now cites PR #1464 instead), BMAD #2915's fixing PRs, spec-kit's `$` prefix (also ZCode) and the Codex bundle-archive check. elephant-goldfish-model's root `plugin.json` has no `$schema` at `main` or v0.1.1, which bears on the open question about it.
