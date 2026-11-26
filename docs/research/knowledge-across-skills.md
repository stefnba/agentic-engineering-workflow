# Sharing knowledge across skills in seven reference repositories

For a reader who wants facts only: where do the reference projects keep knowledge that several skills need, and what does a skills-only installer do to it? This report records what the repositories do and proposes nothing.

Sources and method: shallow clones of the seven repositories at HEAD, read on 2026-11-26 with `git ls-files`, `grep` and file reads. Issues were read through `gh`. Nothing from the clones was executed. One research sub-agent read mattpocock/skills and Elephant Goldfish Model (EGM) itself. It delegated the other five to further agents and re-checked one or two claims per repository. Paths are relative to each repository. `[read]` marks a claim seen in a file or issue by one of those agents. `[inferred]` marks a conclusion. Line numbers for the five delegated repositories were re-checked only in part.

## Summary

Two repositories keep shared knowledge intact under a skills-only install, and they do it in opposite ways `[inferred]`:

- **mattpocock/skills** uses almost no machinery. No file reference leaves a skill folder. A prompt-driven setup skill writes repository facts into `docs/agents/*.md` in the consuming repository.
- **OpenSpec** uses the most. It compiles each skill into a self-contained file and serves formats from a CLI.

Every repository that keeps shared files beside the skill folders forbids skills-only installs or breaks under them: EGM, superpowers, spec-kit and gsd-core `[read]`.

BMAD-METHOD version 7 takes a third route. A folder with its own `SKILL.md` that says never to invoke it carries the shared files, so a folder-copying installer takes it along `[read]`.

In all seven, the skill or schema that writes an artifact owns its format `[read]`.

## Comparison

All seven repositories exist at the URLs given in the task.

| Repository | Home of shared knowledge | How skills refer to each other | Artifact format owner | Drift prevention | Survives a skills-only install | Setup writes |
| --- | --- | --- | --- | --- | --- | --- |
| mattpocock/skills | `docs/agents/*.md` in the consuming repository; reference files inside the owning skill | "Call the Skill tool with" (20 lines); "tell the user to run" (6) | Inline template in the producing skill | Written conventions, one front matter check | Yes for files; thin wrappers need their target | An instruction-file block, three documents, tracker labels |
| google/elephant-goldfish-model | Plugin-root `resources/` and `agents/` | Relative links to a sibling `SKILL.md` (6) | The producing skill; rubrics at the plugin root | Single source, link and packaging tests | No: 30 shared files absent | Nothing; it has no setup step |
| obra/superpowers | One owning skill per shared file, reached by `../`; a bootstrap skill | `superpowers:<name>` (49), REQUIRED markers (10) | Inline in the producing skill | Convention, narrow shell tests | Rejected by policy | Nothing; it has no setup step |
| github/spec-kit | `.specify/` in the consuming repository | Placeholder tokens rendered per agent (49) | Template files served by script | One source for about 50 agents; parity tests | No; the request is out of scope | `.specify/**`, skills, hash manifests |
| Fission-AI/OpenSpec | CLI at run time; `openspec/config.yaml`; a router skill | Bare names, "if that skill is installed" (28) | CLI schema | Generator, byte-parity test, golden hashes | Yes for files; needs the CLI | `openspec/` tree, `config.yaml`, skills |
| open-gsd/gsd-core | `~/.claude/gsd-core/` workflows included by generated wrappers | Slash names (293), `Skill()` calls (56) | Templates plus CLI schema | Generated skills with a check mode, about 60 lints | No | `.planning/*`, `config.json`, `CLAUDE.md` |
| bmad-code-org/BMAD-METHOD | A module-record folder; `_bmad/config.toml`; an `AGENTS.md` block | "Invoke the `name` skill" (36) | Template in the owning skill or module record | None for prose; copies accepted | Yes; needs setup and `uv` | `_bmad/config.toml`, scripts |

## Per-repository notes

### mattpocock/skills

Commit `6f7f783`, plugin version 1.3.2. Read directly.

- **No reference leaves a skill folder.** A `grep` for `../` in the promoted skills returns nothing `[read]`.
- **The setup skill writes the shared facts.** `docs/agents/issue-tracker.md`, `triage-labels.md`, `domain.md`, and an `## Agent skills` block in `CLAUDE.md` or `AGENTS.md` `[read: skills/engineering/setup-matt-pocock-skills/SKILL.md:69-116]`.
- **The seed files sit in the setup skill's own folder.** Five files, one per tracker type plus labels and domain `[read: SKILL.md:108-116]`.
- **Consumer skills never name `docs/agents/`.** They say the tracker "should have been provided to you" and rely on the instruction-file block `[read: skills/engineering/to-spec/SKILL.md:9]`.
- **A hardcoded path was a bug.** `wayfinder` once named `docs/agents/issue-tracker.md` and fell back to the wrong tracker elsewhere `[read: CHANGELOG.md:319-321]`.
- **The tracker document is a verb dictionary.** It defines what "publish to the issue tracker" and "fetch the relevant ticket" mean for that tracker `[read: issue-tracker-github.md]`.
- **Shared reference files live in one owning skill.** Other skills load that skill; the rules ban "deep `../other-skill/FILE.md` cross-references" `[read: .agents/invocation.md]`.
- **No skill can call a user-only skill.** A refactor that turned the setup pointer into a Skill-tool call broke six sites `[read: CHANGELOG.md:97-99]`.
- **Hard and soft dependence on setup are separated.** A hard dependency gets a one-line pointer; a soft one works without setup `[read: .agents/adr/0001-explicit-setup-pointer-only-for-hard-dependencies.md]`.
- **The producer owns each format.** Spec in `to-spec/SKILL.md:21-73`, ticket in `to-tickets/SKILL.md:69-103`, decision record in `domain-modeling/ADR-FORMAT.md`. Readers say only "read the spec" `[read]`.
- **Small duplication exists.** `GLOSSARY-FORMAT.md` sits in `domain-modeling/` and `teach/` and the two differ by about 20 lines `[read: diff]`.
- **Setup is re-runnable.** It updates the block in place. Seed changes do not reach existing repositories `[read: SKILL.md:25]`.

Breakages, all `[read]`:

- A wrapper installed alone does nothing: `grill-me` is 7 lines that call `grilling` (#1012).
- Setup cannot see `triage` on the plugin channel and skips `triage-labels.md` (#812).
- The agent never read `docs/agents/domain.md` (#1376).
- Setup writes the block to `CLAUDE.md` when it exists, so Codex gets nothing (#558).

Not found: a config file, a CLI, a hook, a link or parity check. Not read: `docs/` pages, `skills/in-progress/`, `skills/misc/`.

### google/elephant-goldfish-model

Commit `4693375`, plugin version 0.1.1. Read directly.

- **Shared rules live at the plugin root.** `resources/execution_instructions.md`, five rubrics in `resources/document_standards/`, ten personas in `agents/` `[read]`.
- **One sentence addresses them three ways.** A relative link, `${CLAUDE_PLUGIN_ROOT}`, and a fixed path under `~/.gemini/` `[read: skills/egm-review/SKILL.md:21]`.
- **Each skill names the sections it must read.** The shared file scopes its sections by skill name `[read: skills/egm-bootstrap/SKILL.md:24]`.
- **Skills restate the shared rules as an inline fallback** for the case where the file cannot be read `[read: skills/egm-review/SKILL.md:21-23]`.
- **The shared file replaced measured duplication.** Seven skill bodies fell from 100,400 to 59,587 bytes (#371) `[read]`.
- **Skills link to a sibling `SKILL.md` and run it "in-thread".** All eight are user-only, so the Skill tool cannot reach them `[read: skills/egm-review/SKILL.md:73; mechanism inferred]`.
- **Repository facts are discovered at run time.** `egm-bootstrap` maps manifest files to a test command `[read: skills/egm-bootstrap/SKILL.md:36-41]`.
- **Tests guard the single source.** Link integrity, packaging contents and a 24,000-byte cap per skill `[read: tests/unit/test_link_integrity.py:57, test_packaging.py:38]`.
- **A skills-only install was measured.** All seven skill files arrived and "all 30 shared files" were absent. The maintainers decline to copy shared content into each skill (#150, open) `[read]`.
- **A full plugin install can break too.** Under omp the agent said the shared file was not shipped and skipped its rules (#455) `[read]`.

Not found: a setup step, a router skill, a config file, ticket or decision-record formats. Not read: four skill bodies beyond grep, most design documents.

### obra/superpowers

Commit `22f0b46`, plugin version 7.0.2. Read by a delegated agent.

- **It has no setup step and no config file.** The test command is "whatever the repo uses" `[read: skills/test-driven-development/SKILL.md:187-188]`.
- **The user's instruction file is the override channel.** `[read: skills/writing-plans/SKILL.md:17]`
- **A bootstrap skill carries the workflow map.** A session-start hook injects it on Claude Code; Codex finds it by description `[read: hooks/hooks.json:5-9, RELEASE-NOTES.md:309]`.
- **Shared files sit in one owning skill and siblings reach them by `../`.** `executing-plans` runs scripts from `../subagent-driven-development/scripts/` `[read: skills/executing-plans/SKILL.md:126,238,245]`.
- **Skill-only installs are unwanted by policy.** Without the bootstrap the skills are "dead weight" `[read: AGENTS.md:82,93]`.
- **Two executor skills share at least five passages.** `[read: skills/executing-plans/SKILL.md:144, skills/subagent-driven-development/SKILL.md:130]`
- **Past drift was fixed by merging.** The reviewer persona "drifted independently" `[read: RELEASE-NOTES.md:479]`.
- **A parser script is a second format definition.** It required the word "Task" in plan headings and broke on other plans `[read: RELEASE-NOTES.md:46]`.

Not found: a shared directory, a link checker, issues about skills-only installs. Not read: most skill bodies beyond grep, most tests.

### github/spec-kit

Commit `f201054`. Read by a delegated agent.

- **Shared material lives in `.specify/` in the consuming repository.** Scripts, five templates, the constitution and state `[read: scripts/bash/common.sh:513-525]`.
- **Most commands read the constitution.** `[read: templates/commands/plan.md:64]`
- **Scripts hand template content to the agent as JSON.** `[read: templates/commands/specify.md:12-14,99-101]`
- **Commands name each other through placeholder tokens.** 49 `__SPECKIT_COMMAND_<NAME>__` tokens in `templates/` `[read]`.
- **One hook block appears 26 times with no include mechanism.** A text test pins its clauses `[read: tests/test_command_template_hooks.py:1-70]`.
- **A skills.sh install is out of scope.** The request is open and labelled `triage-out-of-scope` (#5483) `[read]`.
- **Setup is hash-aware.** `specify init` overwrites only files whose hash still matches its manifest `[read: src/specify_cli/shared_infra.py:506-556]`.

Not found: a router skill, decision-record or glossary templates. Not read: most of `docs/`, most tests.

### Fission-AI/OpenSpec

Commit `f1cd852`. Read by a delegated agent.

- **The CLI serves formats and rules at run time.** `openspec instructions <artifact> --change <name> --json` returns `context`, `rules`, `template` and `instruction` `[read: skills/openspec-propose/SKILL.md:107-118]`.
- **Repository facts live in `openspec/config.yaml`.** `[read: src/core/project-config.ts:34-95]`
- **A router skill holds the workflow map** and "no workflow steps of its own" `[read: skills/openspec/SKILL.md:33-46, src/core/templates/workflows/router.ts:5]`.
- **Skills are self-contained.** A `grep` for `../` or `CLAUDE_PLUGIN_ROOT` in `skills/` returns nothing `[read]`.
- **Cross-references are conditional.** "If that skill is installed" fixed a recurring partial-install bug class (#1975, #1734) `[read]`.
- **A parity test compares committed skills with generator output.** They must match byte for byte `[read: test/core/templates/skillssh-parity.test.ts]`.
- **It removed its own setup-written document.** `openspec/AGENTS.md` left in 1.9.0 (#1689) `[read]`.
- **`npx skills add` is supported on purpose.** The CLI and `openspec/` folder do not arrive with the skills `[read: skills/README.md]`.

Not found: hooks, required-skill markers. Not read: update and migration sources, most skill bodies.

### open-gsd/gsd-core

Commit `a30fe54`. Read by a delegated agent.

- **72 thin skills include shared workflow files by absolute path.** 123 `@~/.claude/gsd-core/…` includes in 58 skills `[read: skills/gsd-plan-phase/SKILL.md:38; count re-checked]`.
- **A CLI serves repository facts as JSON.** `gsd_run` appears on 1,090 lines of the workflows `[read]`.
- **`PLAN.md` has three format sources.** A template, a restatement in `agents/gsd-planner.md:305-443`, and a CLI rule `[read]`.
- **Skills are generated from commands**, with a check mode in the lint run `[read: package.json:155,164]`.
- **Even the Claude plugin install broke.** It never created `~/.claude/gsd-core/`, so includes resolved to nothing (#997) `[read]`.
- **A Codex install left 237 includes unrewritten** (#4667) `[read]`.

Not found: any mention of `npx skills`. Not read: the installer, source bodies, tests. Issues of the predecessor repository were not searched.

### bmad-code-org/BMAD-METHOD

Commit `e435a22`, the version 7 preview. Read by a delegated agent. The stable 6.12 branch was not read.

- **A module-record folder carries shared files.** `bmod-<code>/` has a `SKILL.md` whose description must read "Required bmod metadata. Never invoke this skill." `[read: tools/skill-validator.md:150]`.
- **Repository facts go into a managed `AGENTS.md` block.** A skill keeps it between `<!-- bmad:context -->` markers `[read: skills/method/bmad-project-context/SKILL.md:3,9]`.
- **Config is read through a script, never parsed by a skill.** `_bmad/scripts/resolve_config.py --key …` `[read]`.
- **A rule forbids any file path into another skill.** An LLM prompt checks it, not code `[read: tools/skill-validator.md:215-227]`.
- **Dependencies are declared as data.** `required_skills` in each `bmod.toml`; setup reports unmet ones `[read]`.
- **Duplication is accepted.** `references/deletion-check.md` is byte-identical in three skills `[read: equal md5 sums]`. Two other near-copies already differ `[read]`.
- **The README says what to include.** A single-skill pick must add `bmad` and each module record `[read: README.md:50]`.
- **Updated skills against stale project scripts fail silently** and leave placeholders in 29 files (#3209) `[read]`.

Not found: a plugin manifest, hooks, a sync script. Not read: `docs/`, script bodies.

## Mechanisms observed

The mechanisms the repositories use to share knowledge, sorted by name. The users and breakages are `[read]`.

| Mechanism | Used by | Survives a skills-only install | Known cost or breakage |
| --- | --- | --- | --- |
| A config file plus a CLI that serves instructions | OpenSpec, gsd-core, BMAD, spec-kit | No; the runtime does not arrive | Version coupling; silent failure (BMAD #3209) |
| A file inside one owning skill, loaded by invoking that skill | mattpocock | Yes, if the owning skill is installed | Wrappers fail alone (#1012) |
| A folder with a `SKILL.md` as the shared container | BMAD, OpenSpec router | Yes | The user must include it |
| A plugin-root shared directory | EGM, gsd-core | No | All shared files lost (EGM #150) |
| A sibling skill's file by `../` path | superpowers, EGM | Only when siblings are installed together | Partial installs; confined reads (EGM #455) |
| Accepted duplication | BMAD, EGM fallbacks, spec-kit | Yes | Copies drift; BMAD's already differ |
| Discover at run time, share nothing | superpowers, EGM bootstrap | Yes | Each skill repeats its detection |
| Documents written by a setup skill, reached through the instruction file | mattpocock, BMAD, spec-kit | Yes | The pointer is soft (#1376, #558) |
| Single source, a generator and a parity check | OpenSpec, gsd-core, spec-kit | Only if the output is self-contained | A build step and committed generated files |
| The user's instruction file, with no setup | superpowers | Yes | A skill cannot rely on any fact being there |

## Cross-repository observations

- **mattpocock/skills uses two mechanisms in the table.** They are a file inside one owning skill and documents written by a setup skill. It has no generator and no parity test `[read]`.
- **Three repositories write repository facts into the consuming repository through a setup step.** They are mattpocock, BMAD and spec-kit `[read]`.
- **Restated formats drifted** in gsd-core, superpowers and BMAD `[inferred]`.
- **The user-only flag caused two mattpocock issues.** #812 and #740 both come from it `[inferred]`.
- **No prose-driven setup migrates old repositories.** mattpocock's answer is to ask the skill to verify in words `[inferred]`.
