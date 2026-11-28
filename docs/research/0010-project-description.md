---
question: "How do seven reference repositories produce and maintain a standing description of a project (its problem, users, use cases, constraints, non-goals and roadmap), for a new project and for an existing codebase, if they do at all?"
researched: "2026-11-28"
versions: "obra/superpowers v7.0.2 (main 22f0b46); mattpocock/skills v1.3.2 (main bbadaa6, 2026-11-27); google/elephant-goldfish-model v0.1.1 (main 4693375, 2026-11-25); github/spec-kit v1.4.5 (main f2010547); Fission-AI/OpenSpec v2.2.0 (main dff0188f); open-gsd/gsd-core v1.23.0 (next e9c3e54, 2026-11-28); bmad-code-org/BMAD-METHOD v6.12.4 and main e435a22 (6.13.0-next, unreleased)"
---

# How the reference repositories write and maintain a standing project description

## Answer

- Only gsd-core writes a standing description that covers problem, users, non-goals and roadmap. `/gsd:new-project` writes `.planning/PROJECT.md` beside `REQUIREMENTS.md` and `ROADMAP.md`, and gsd-core alone updates it inside its delivery loop.
- The others keep no standing description, or a narrower standing file. spec-kit keeps principles, OpenSpec keeps constraints, mattpocock/skills keeps a glossary and rejected requests, and EGM keeps architecture contracts. superpowers keeps only dated per-topic designs. BMAD writes a PRD or brief per initiative, plus an agent-rules block in `AGENTS.md`.
- BMAD's answer depends on the ref. The v6.12.4 release ships standalone `bmad-prd` and `bmad-product-brief` skills. The unreleased `main` retires them for PM and Analyst agents over a shared `bmad-facilitate` engine.

The table compares the repositories at the refs in the front matter.

| Repository | Standing artifact and writer | Sections | Facts from | Before saving | Kept current |
| --- | --- | --- | --- | --- | --- |
| superpowers | None; `brainstorming` writes a dated design per topic | Design covers intent, goals, non-goals, constraints, approaches | Reads the project, then asks one question at a time | Fresh-subagent builder check for project-sized designs, then user approval | Not kept; a new spec per topic |
| mattpocock/skills | Spread: `GLOSSARY.md` (`domain-modeling`), `.out-of-scope/` (`triage`), `docs/agents/` (`setup-matt-pocock-skills`) | Glossary: short context description, `## Language`; out-of-scope: why, prior requests | Numbered rounds of questions; subagents find facts; user claims checked against code | Setup shows every draft; glossary terms written as resolved | Inline during other skills' sessions |
| elephant-goldfish-model | None for intent; `egm-bootstrap` writes per-directory contracts and a root Blueprint | Root: System Overview, Subdirectories & System Boundaries, Global Invariants, Global Side Effects, System Verification | Code only, through read-only scouts | Agent re-reads each file; user gate only past 15 directories; never commits | Rerun bootstrap, which merges; optional drift report |
| spec-kit | `.specify/memory/constitution.md` by `/speckit.constitution` | Core Principles, two free sections, Governance, version line | User input, then README, docs and prior constitution | Self-check, overwrite, then a Sync Impact Report | Rerun when principles change; semantic version bump |
| OpenSpec | `context:` in `openspec/config.yaml`, scaffolded empty; `project.md` dropped in v1.0.0 | None; free text up to 50 KB | Written by hand or by an agent | Router: edit only after the user approves the wording | Hand edits; injected into planning requests |
| gsd-core | `.planning/PROJECT.md` by `/gsd:new-project`; `/gsd:onboard` for existing code | What This Is, Core Value, Requirements (Validated, Active, Out of Scope), Context, Constraints, Key Decisions, Evolution | One freeform question, then option prompts; a codebase map; ingested docs | "Ready?" gate before writing, no draft review | Phase transitions and a milestone review |
| BMAD-METHOD | No whole-project file; a PRD or brief per initiative; `AGENTS.md` block by `bmad-project-context` | PRD: Vision, Users and journeys, Non-goals, MVP scope and more; brief: Problem, Solution, Who it serves, Scope and more | Reads inputs, invites a brain dump, then coaches or asks one batch | Draft grown in view; reviewer subagents; waits for the user's read | Update intent on request; context block refreshed against a SHA |

- Where they agree: an agent reads what exists before it asks, and the user supplies intent. Inferred: no repository forbids inferring purpose or users from code, from the evidence-rule findings in the superpowers, spec-kit and gsd-core/BMAD sections. gsd-core does infer shipped capabilities from a codebase map.
- Where they differ: strict evidence rules attach to files that describe code. Examples are EGM's `[file:symbol]` citations, BMAD's path checks with a recorded SHA, and gsd-core's file paths per mapper finding. Intent documents get attribution rules instead: superpowers marks the agent's own calls, BMAD tags `[ASSUMPTION: ...]`, spec-kit writes `TODO(<FIELD>)`.
- Reported problems: missing or broken paths for an existing codebase, files that grow, drift from code, and overlap with README or `AGENTS.md`. Also reported: overwritten user content, and renames that leave an old file unread. Two closed issues report a planning document inventing content: a BMAD PRD that invented a phased roadmap (#1693), and a mattpocock `MISSION.md` that invented the learner's goal (#961).
- Maintainer responses split between fix PRs, declines that restate the file's scope, and stale-bot closures (spec-kit). Most of the Discussions threads read have no maintainer reply.
- Evidence is thin in three places. BMAD `main` is unreleased. gsd-core's ingest-docs path to `PROJECT.md` has open confirmed bugs. mattpocock's `chief-of-staff` wiki is unshipped.

## superpowers, mattpocock/skills and elephant-goldfish-model

**Which skill writes a standing description**

- No skill in the three trees writes users, use cases or a roadmap. No file is named PROJECT, VISION, BRIEF, PRD or CONSTITUTION (tested 2026-11-28: tree listings and a grep of `skills/`, `agents/` and `resources/` for those terms).
- superpowers' only design writer, `brainstorming`, writes `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` and commits it ([superpowers brainstorming SKILL.md, v7.0.2](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md)).
- mattpocock's `setup-matt-pocock-skills` writes `docs/agents/issue-tracker.md`, `docs/agents/domain.md`, `docs/agents/triage-labels.md` and an `## Agent skills` block in `CLAUDE.md` or `AGENTS.md` ([mattpocock setup SKILL.md, main 2026-11-27](https://github.com/mattpocock/skills/blob/main/skills/engineering/setup-matt-pocock-skills/SKILL.md)).
- mattpocock's `domain-modeling` writes `GLOSSARY.md` (or `GLOSSARY-MAP.md` with per-context glossaries) and `docs/adr/NNNN-*.md` ([mattpocock domain-modeling SKILL.md, main](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md)).
- mattpocock's `triage` writes one `.out-of-scope/<concept>.md` per rejected concept and groups repeat requests under it ([mattpocock triage OUT-OF-SCOPE.md, main](https://github.com/mattpocock/skills/blob/main/skills/engineering/triage/OUT-OF-SCOPE.md)).
- EGM's `egm-bootstrap` writes `README.md` contracts with Interface, Invariants and Side Effects across a directory tree. It can write `EGM.md` instead to keep human READMEs ([EGM egm-bootstrap SKILL.md, main 2026-11-25](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-bootstrap/SKILL.md)).
- EGM's review standard expects goals in the root `README.md` or `context.md`, but no EGM skill writes `context.md` ([EGM zoom-out-standard.md, main](https://github.com/google/elephant-goldfish-model/blob/main/resources/document_standards/zoom-out-standard.md)).

**Template and sections**

- superpowers' design lists topics, not headings: intent and the why; goals, non-goals and anti-goals; constraints; approaches; decided parts of the how; what is left to the builder ([brainstorming SKILL.md, v7.0.2](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md)).
- mattpocock's glossary template has `# {Context Name}`, a one- or two-sentence description, and `## Language` ([GLOSSARY-FORMAT.md, main](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/GLOSSARY-FORMAT.md)). The skill keeps implementation details out of it ([domain-modeling SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md)).
- A `.out-of-scope/` file has `# <Concept>`, `## Why this is out of scope` and `## Prior requests` ([OUT-OF-SCOPE.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/triage/OUT-OF-SCOPE.md)).
- EGM's root Blueprint template has `## System Overview`, an optional `## Local Interface & Invariants`, `## Subdirectories & System Boundaries`, `## Global Invariants`, `## Global Side Effects` and `## System Verification` ([egm-bootstrap references/templates.md, main](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-bootstrap/references/templates.md)).
- Inferred: EGM's root template has no section for problem, users, use cases or roadmap, from the template finding above.

**Gathering facts**

- superpowers reads an existing project before its first message and asks one question at a time. Its topic list is territory, not a script of questions ([brainstorming SKILL.md](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md)).
- mattpocock's `grilling` asks the whole frontier in one numbered round, with a recommended answer each. It sends subagents to find facts ([grilling SKILL.md, main](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md)). It moved from one question at a time to rounds in PR #593, and kept an opt-out ([mattpocock CHANGELOG.md](https://github.com/mattpocock/skills/blob/main/CHANGELOG.md)).
- mattpocock sets no cap on questions ([.out-of-scope/question-limits.md](https://github.com/mattpocock/skills/blob/main/.out-of-scope/question-limits.md)).
- mattpocock's `domain-modeling` checks the user's statements against the code and surfaces contradictions ([domain-modeling SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md)).
- mattpocock's setup explores, presents its findings, then confirms one section at a time. It offers to `git mv` a legacy file to its `GLOSSARY` name ([setup SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/setup-matt-pocock-skills/SKILL.md)).
- EGM's bootstrap reads code only, through read-only scouts, and skips tests. It reads an existing target file, never overwrites it blindly, and merges code-verified output while keeping valid developer notes ([egm-bootstrap SKILL.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-bootstrap/SKILL.md)).

**Evidence rules**

- EGM's scouts must cite `[file:symbol_or_flag]` for every entry, must not infer from file or directory names, and write `["None"]` when the code shows nothing. A failed scout leaves a marked placeholder ([egm-bootstrap SKILL.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-bootstrap/SKILL.md)).
- superpowers writes any choice the agent makes into the design as the agent's call, never as something the user agreed to ([brainstorming SKILL.md](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md)).
- mattpocock's `docs/agents/domain.md` tells skills to proceed silently when its files are missing ([domain.md, main](https://github.com/mattpocock/skills/blob/main/skills/engineering/setup-matt-pocock-skills/domain.md)).

**Check before saving**

- superpowers runs a fresh-subagent builder check on project-sized designs, then needs the user's approval ([brainstorming SKILL.md](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md)).
- mattpocock's setup shows a draft of every file and lets the user edit before writing. It updates an existing `## Agent skills` block in place ([setup SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/setup-matt-pocock-skills/SKILL.md)).
- mattpocock's `domain-modeling` writes each glossary term the moment it is resolved, without batching ([domain-modeling SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md)).
- EGM pauses for approval when discovery finds more than 15 subdirectories. It re-reads every written contract for citations, Markdown and links, and leaves commits to the human ([egm-bootstrap SKILL.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-bootstrap/SKILL.md)).

**Keeping it current**

- mattpocock's setup is rerun only to switch trackers or restart; users edit `docs/agents/*.md` directly ([setup SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/setup-matt-pocock-skills/SKILL.md)). The glossary is created lazily, when there is something to write ([domain-modeling SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md)).
- EGM's `egm-drift-report` compares each design doc or README with code and appends differences to `{YYYY-MM-DD}_DRIFT_REPORT.md`. Code no document references counts as drift ([egm-drift-report SKILL.md, main](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-drift-report/SKILL.md)). The user decides whether to change the document or the code ([EGM README](https://github.com/google/elephant-goldfish-model/blob/main/README.md)).
- Both EGM skills set `disable-model-invocation: true`, so only the user starts them ([egm-bootstrap SKILL.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-bootstrap/SKILL.md), [egm-drift-report SKILL.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-drift-report/SKILL.md)).

**Limits and dates**

- mattpocock renamed `CONTEXT.md`/`CONTEXT-MAP.md` to `GLOSSARY.md`/`GLOSSARY-MAP.md` in PR #1120, after which the skills looked only for the new names. PR #1228 (merged 2026-10-27) made setup detect a legacy `CONTEXT.md` or `CONTEXT-MAP.md` and offer to `git mv` it ([mattpocock CHANGELOG.md](https://github.com/mattpocock/skills/blob/main/CHANGELOG.md)).
- EGM's bootstrap design doc, status "Current" and dated 2026-06-29, promises sentinel-marked blocks that keep human README text byte for byte ([EGM docs/designs/bootstrap.md](https://github.com/google/elephant-goldfish-model/blob/main/docs/designs/bootstrap.md)). The shipped skill and templates never mention sentinels (tested 2026-11-28: `grep -c -i sentinel skills/egm-bootstrap/SKILL.md skills/egm-bootstrap/references/templates.md` returned `0` and `0`).
- EGM `main` changed egm-bootstrap after v0.1.1 (2026-11-06), in #359 (2026-11-20) and #369 (2026-11-23) (tested 2026-11-28: `git log -- skills/egm-bootstrap`).

## spec-kit and OpenSpec

**Which command writes a standing description**

- spec-kit's `/speckit.constitution` (`/speckit-constitution` in skills mode) writes only `.specify/memory/constitution.md` ([spec-kit templates/commands/constitution.md, main f2010547](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/constitution.md)). The CLI describes it as project governing principles and development guidelines ([src/specify_cli/__init__.py](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/src/specify_cli/__init__.py)).
- `specify init` copies the constitution template only when no file exists, and preserves an existing one ([src/specify_cli/command_init.py, main](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/src/specify_cli/command_init.py)).
- spec-kit says other homes, such as product documentation, design records or an issue tracker, hold enduring product knowledge ([docs/how-to/persisting-specs.md, main](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/docs/how-to/persisting-specs.md)).
- spec-kit's opt-in `assess` extension writes a `problem.md` with users, goals and non-goals, but per idea under `.specify/assessments/<slug>/` ([docs/guides/assessment.md, main](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/docs/guides/assessment.md)).
- spec-kit's roadmap file is hand-written and per epic, at `specs/<epic-slug>/roadmap.md` or a top-level `ROADMAP.md` ([docs/how-to/spec-of-specs.md, main](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/docs/how-to/spec-of-specs.md)).
- OpenSpec's `openspec init` writes `openspec/config.yaml` with an empty `context` unless `--language` is given, and leaves an existing config alone ([OpenSpec src/core/init.ts, main dff0188f](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/src/core/init.ts)).
- No OpenSpec workflow drafts the context; the router skill tells the agent to add a short line under `context` ([src/core/templates/workflows/router.ts, main](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/src/core/templates/workflows/router.ts)).
- OpenSpec v1.0.0 (2026-01-26) stopped generating `project.md` ([OpenSpec CHANGELOG.md, 1.0.0](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/CHANGELOG.md)). Up to v0.x, `init` generated it from a template ([project-template.ts, v0.15.0](https://github.com/Fission-AI/OpenSpec/blob/v0.15.0/src/core/templates/project-template.ts)).

**Template and sections**

- The constitution template has `# [PROJECT_NAME] Constitution`, `## Core Principles` with `### [PRINCIPLE_1_NAME]` to `### [PRINCIPLE_5_NAME]`, `## [SECTION_2_NAME]`, `## [SECTION_3_NAME]`, `## Governance`, and a Version / Ratified / Last Amended line ([templates/constitution-template.md, main](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/constitution-template.md)).
- Since 2026-08-10 the template resolves at command time through presets, extensions and project overrides (commit `16cfab77`, #3984; [constitution.md](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/constitution.md)).
- OpenSpec's scaffold comments say to add only constraints an agent cannot infer from the code, and to keep general documentation and discoverable codebase facts out ([src/core/config-prompts.ts, main](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/src/core/config-prompts.ts)).
- OpenSpec caps `context` at 50 KB ([src/core/project-config.ts, main](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/src/core/project-config.ts)).
- The legacy `project.md` template had Purpose, Tech Stack, Project Conventions, Domain Context, Important Constraints and External Dependencies ([project-template.ts, v0.15.0](https://github.com/Fission-AI/OpenSpec/blob/v0.15.0/src/core/templates/project-template.ts)).

**Gathering facts**

- The constitution command uses values from user input first, then infers from the README, docs and prior constitution versions. It asks when an instruction may not be constitution content ([constitution.md, main](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/constitution.md)).
- spec-kit's existing-projects guide asks for principles already true or explicitly agreed. It says `init` does not infer specifications for existing behaviour ([docs/how-to/existing-projects.md, main](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/docs/how-to/existing-projects.md)).
- OpenSpec's existing-codebase guide says to write specs only for what is about to change, and to treat existing docs as source material, not specs to convert ([OpenSpec docs/existing-projects.md, main](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/docs/existing-projects.md)).

**Evidence rules**

- spec-kit's guide names the README, architecture decisions, contribution guide and CI config as evidence, and warns against inventing standards to fill the template ([existing-projects.md, main](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/docs/how-to/existing-projects.md)).
- The constitution command writes missing critical values as `TODO(<FIELD_NAME>): explanation` and must justify any bracket token it leaves ([constitution.md, main](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/constitution.md)).
- Since 2026-07-22 the command extracts feature or build requests as deferred intents instead of running them (commit `8c816fac`, #3646; [constitution.md](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/constitution.md)).
- OpenSpec PR #1995 (merged 2026-09-29) added the keep-discoverable-facts-out rule, because the old config led agents to repeat tech stack and domain facts ([OpenSpec PR #1995](https://github.com/Fission-AI/OpenSpec/pull/1995)).
- Inferred: an agent running `/speckit-constitution` sees the instruction to infer from repository context, but not the how-to's rule against inventing, from the constitution.md and existing-projects.md findings.

**Check before saving**

- The constitution command self-checks placeholders, the version line, ISO dates and testable principles, then overwrites the file ([constitution.md, main](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/constitution.md)).
- Its Sync Impact Report is temporary material for human review, to be removed before commit; this wording dates from 2026-09-09 (commit `00a47de4`, #4431; [constitution.md](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/constitution.md)).
- OpenSpec's router edits `config.yaml` only after the user approves the wording ([router.ts, main](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/src/core/templates/workflows/router.ts)). Its explore skill must ask a yes/no question and wait before writing it (#1716, [CHANGELOG.md](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/CHANGELOG.md)).

**Keeping it current**

- Rerunning the constitution command amends the file, sets `LAST_AMENDED_DATE` and bumps a MAJOR, MINOR or PATCH version ([constitution.md, main](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/constitution.md)). spec-kit advises amending only when governing principles or constraints change ([persisting-specs.md](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/docs/how-to/persisting-specs.md)).
- `/speckit.analyze` treats conflicts with the constitution as CRITICAL ([templates/commands/analyze.md, main](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/analyze.md)).
- PR #3790 (merged 2026-07-28) removed template propagation from the command; dependent templates read the constitution at runtime ([spec-kit PR #3790](https://github.com/github/spec-kit/pull/3790)).
- OpenSpec injects `context` into every planning request. It dropped `project.md` because agents might not read a passive file ([docs/migration-guide.md, main](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/docs/migration-guide.md)).
- For a legacy `project.md`, OpenSpec prints a pasteable migration prompt and never copies or deletes the file (PR #1999, merged 2026-09-29; [legacy-cleanup.ts, main](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/src/core/legacy-cleanup.ts), [PR #1999](https://github.com/Fission-AI/OpenSpec/pull/1999)).

**Limits and dates**

- OpenSpec's own `config.yaml` lists its tech stack, which its current scaffold advises against ([openspec/config.yaml, main](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/openspec/config.yaml)).
- OpenSpec has both `docs/` and `docs-lab/` on `main`; closed issue #2059 says the README sends readers to the legacy `docs/` tree (tested 2026-11-28: `gh issue list -R Fission-AI/OpenSpec --search 'project context sort:created-desc'`). The quotes from `docs/` may come from that legacy tree; the code quotes are current.
- Open OpenSpec issue #1966 (2026-09-23) asks for a reference file on writing config ([OpenSpec #1966](https://github.com/Fission-AI/OpenSpec/issues/1966)). Open issue #2032 (2026-10-02) reports agents changing things without asking what they are for and who uses them ([OpenSpec #2032](https://github.com/Fission-AI/OpenSpec/issues/2032)).

## gsd-core and BMAD-METHOD

**Which command writes a standing description**

- `/gsd:new-project` writes `.planning/PROJECT.md`, `REQUIREMENTS.md`, `ROADMAP.md` and `STATE.md`, with optional `.planning/research/` ([gsd-core commands/gsd/new-project.md, next e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/commands/gsd/new-project.md)). Its template calls PROJECT.md the living project context document ([gsd-core/templates/project.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/templates/project.md)).
- `/gsd:onboard` chains codebase map, docs ingest, project initialization and an onboarding summary. It does not overwrite existing planning files without a gate ([commands/gsd/onboard.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/commands/gsd/onboard.md)).
- `/gsd:map-codebase` runs parallel mapper agents that write STACK, INTEGRATIONS, ARCHITECTURE, STRUCTURE, CONVENTIONS, TESTING and CONCERNS files to `.planning/codebase/` ([commands/gsd/map-codebase.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/commands/gsd/map-codebase.md)).
- `/gsd:ingest-docs` can produce PROJECT.md from existing ADR, PRD, SPEC and DOC files ([gsd-core/workflows/ingest-docs.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/ingest-docs.md)).
- BMAD `main` routes all document work through `bmad-facilitate` ([BMAD bmad-agent-pm/SKILL.md, main e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/method/bmad-agent-pm/SKILL.md)). It writes `<type>-<slug>/<type>-<slug>.md` under `output_folder`, inside `initiative-<slug>/` when one is active ([BMAD CHANGELOG.md, Unreleased](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/CHANGELOG.md)).
- BMAD `main` lists `bmad-product-brief`, `bmad-prd`, `bmad-bmm-document-project` and `bmad-bmm-generate-project-context` as removed (tested 2026-11-28: read `skills/method/bmod-method/retired.toml`).
- At v6.12.4, `bmad-prd` wrote `prd.md` into a run folder `prd-{project_name}-{date}` under `{planning_artifacts}/prds` ([BMAD bmad-prd/customize.toml, v6.12.4](https://github.com/bmad-code-org/BMAD-METHOD/blob/v6.12.4/src/bmm-skills/plan/bmad-prd/customize.toml)).
- Since v6.11.0 (2026-08-09), `bmad-project-context` writes one verified block in `AGENTS.md`, with no generated overview pages and no `project-context.md`. The changelog says a capability to explain the system and its rationale is still to come ([BMAD CHANGELOG.md, v6.11.0](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/CHANGELOG.md)).
- Inferred: BMAD's PRD or brief sits between a standing description and a per-feature spec, because it is written per product or initiative in its own folder, from the output-path findings above.

**Template and sections**

- The PROJECT.md template has `## What This Is`, `## Core Value`, an optional `## Business Context`, `## Requirements` with Validated, Active and Out of Scope, `## Context`, `## Constraints`, `## Key Decisions`, and a "Last updated" footer ([templates/project.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/templates/project.md)).
- The template asks for reasons on Out of Scope entries and on constraints, and treats Active requirements as hypotheses until shipped ([templates/project.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/templates/project.md)).
- `new-project` adds an `## Evolution` section saying the file evolves at phase transitions and milestones ([gsd-core/workflows/new-project.md, step 4](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/new-project.md)).
- ROADMAP.md has Overview, Phases, Phase Details and Progress ([templates/roadmap.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/templates/roadmap.md)). REQUIREMENTS.md has v1, v2, Out of Scope and Traceability ([templates/requirements.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/templates/requirements.md)).
- BMAD `main`'s PRD template (version 1.1.0) includes Document purpose, Vision, Users and journeys, Glossary, Features and requirements, Non-goals, MVP scope, Success metrics, Quality and constraints, Change boundary, Decisions and Open questions. Its `facilitation_order` marks most later sections optional ([template-prd.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/method/bmad-agent-pm/assets/template-prd.md)).
- BMAD `main`'s brief template has Executive summary, Problem, Solution, What makes it different, Who it serves, Success criteria, Scope, The ask and Vision, with `paced: true` ([template-brief.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/method/bmad-agent-analyst/assets/template-brief.md)).
- The `bmad-project-context` block sits between `<!-- bmad:context -->` markers. It carries a "Verified <date> against <sha>" line and sections for policy, locations, running and verifying, conventions and pitfalls ([references/template.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/method/bmad-project-context/references/template.md)).

**Gathering facts**

- `new-project` opens with the freeform question "What do you want to build?", then follows up with option prompts ([new-project.md, step 3](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/new-project.md)).
- Its questioning guide keeps a background checklist: what, why, who for, and what done looks like. It offers 2 to 4 options and lists checklist walking and canned questions as anti-patterns ([gsd-core/references/questioning.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/references/questioning.md)).
- `--auto` mode skips questioning and synthesizes PROJECT.md from a referenced idea document ([commands/gsd/new-project.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/commands/gsd/new-project.md)).
- On detecting existing code, `new-project` offers to map the codebase first ([new-project/steps/codebase-map-offer.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/new-project/steps/codebase-map-offer.md)). It then reads `ARCHITECTURE.md` and `STACK.md` and lists what the code already does as the initial Validated set, marked "— existing" ([new-project.md, step 4](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/new-project.md)).
- `ingest-docs` asks one at a time only for fields the documents cannot supply. It resolves conflicts by the default precedence ADR, SPEC, PRD, DOC ([ingest-docs.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/ingest-docs.md)).
- BMAD's `bmad-facilitate` reads every input before asking and invites a brain dump. It then coaches one question at a time, at most two things per message, or asks one batch of up to three on the fast path ([bmad-facilitate/SKILL.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/core-tools/bmad-facilitate/SKILL.md)).
- `bmad-project-context` scans with parallel subagents and asks only what no scan reaches, in batches of at most eight. On a new project the interview is the whole content ([bmad-project-context/SKILL.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/method/bmad-project-context/SKILL.md)).
- Inferred: a BMAD PRD for an existing product comes from documents and interview, not a code scan, because the code-reading skills feed `AGENTS.md` or answer questions, from the facilitate and project-context findings.

**Evidence rules**

- gsd-core's mapper requires a file path on every finding, forbids guessing, and forbids reading `.env` or credential files because its output is committed ([agents/gsd-codebase-mapper.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/agents/gsd-codebase-mapper.md)).
- PROJECT.md's brownfield step infers Validated requirements from the code, then presents the inferred state to the user ([templates/project.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/templates/project.md)).
- `bmad-project-context` path-checks every file claim and verifies every command claim against its script. It shows the evidence when the repository contradicts the user, and writes unbuilt commands as TODOs ([bmad-project-context/SKILL.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/method/bmad-project-context/SKILL.md)).
- BMAD keeps anything derivable from source out of the block: `pnpm test` stays out, a slow suite goes in ([BMAD CHANGELOG.md, v6.11.0](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/CHANGELOG.md)).
- `bmad-facilitate` puts nothing in as the user's that they did not say or accept, logs each unconfirmed inference as an assumption, and rates a misattributed claim high in review ([bmad-facilitate/SKILL.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/core-tools/bmad-facilitate/SKILL.md)).

**Check before saving**

- BMAD's Finalize runs a memlog audit with `check_ids.py`, per-input reconciliation subagents, a rubric walker and a fresh reader, triage and polish. It then names the three least certain decisions and waits for the user before `status: final` ([bmad-facilitate/SKILL.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/core-tools/bmad-facilitate/SKILL.md)). v6.12.4's `bmad-prd` had the same shape ([bmad-prd/SKILL.md, v6.12.4](https://github.com/bmad-code-org/BMAD-METHOD/blob/v6.12.4/src/bmm-skills/plan/bmad-prd/SKILL.md)).
- `bmad-project-context` shows the complete block and a ledger before any write, and never commits ([bmad-project-context/SKILL.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/method/bmad-project-context/SKILL.md)).
- `ingest-docs` asks for approval of the discovered document set. It exits without writing PROJECT.md when blockers exist ([ingest-docs.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/ingest-docs.md)).
- gsd-core's health check requires `## What This Is`, `## Core Value` and `## Requirements` in PROJECT.md (tested 2026-11-28: read `src/health-diagnostic-rules/root-existence.cts`).

**Keeping it current**

- At each phase transition, `evolve_project` reads the phase summaries. It moves requirements to Validated or Out of Scope, adds emerging ones to Active, logs decisions, rechecks "What This Is" and rewrites the footer ([gsd-core/workflows/transition.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/transition.md)).
- At milestone completion, a full review covers every section, including whether Out of Scope reasons still hold ([complete-milestone/steps/project-md-evolution-review.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/complete-milestone/steps/project-md-evolution-review.md)).
- `/gsd:map-codebase` has `status`, `diff` and `refresh` modes ([commands/gsd/map-codebase.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/commands/gsd/map-codebase.md)).
- BMAD's Update intent reads the document, its memlog and the original inputs, and surfaces conflicts with earlier decisions before applying. It offers Create for a fundamental change ([bmad-facilitate/SKILL.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/core-tools/bmad-facilitate/SKILL.md)).
- `bmad-project-context` refresh re-verifies every path and caveat against `git log` since the recorded SHA; an audit must end the same size or smaller ([bmad-project-context/SKILL.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/method/bmad-project-context/SKILL.md)).
- Inferred: gsd-core is the only repository that updates its standing description as part of its delivery loop; BMAD updates on request, from the transition, milestone and Update findings.

**Limits and dates**

- BMAD `main` carries `version = "6.13.0-next"`; the latest release is v6.12.4 of 2026-10-14 (tested 2026-11-28: `grep version skills/method/bmod-method/bmod.toml`, `gh release list -R bmad-code-org/BMAD-METHOD -L 3`).
- The PROJECT.md template's milestone list includes a Business Context check, which the `## Evolution` text that `new-project` writes omits ([templates/project.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/templates/project.md), [new-project.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/new-project.md)).

## Reported problems and maintainer responses

**Existing-codebase path**

- spec-kit requests for a brownfield constitution command, brownfield docs and PRD import were closed not planned: [#586](https://github.com/github/spec-kit/issues/586) (2025-09-25), [#1173](https://github.com/github/spec-kit/issues/1173) (closed 2026-10-12), [#1527](https://github.com/github/spec-kit/issues/1527) (closed 2026-08-20). A stale bot closed them without a maintainer reply ([spec-kit #2219](https://github.com/github/spec-kit/issues/2219)).
- mattpocock #101 (2026-04-29) asked how to get `CONTEXT.md` for old codebases. The answer was to run `/grill-with-docs` and compose existing skills ([skills #101](https://github.com/mattpocock/skills/issues/101)). #930 (2026-08-22) reported the lazy glossary staying nearly empty on a large codebase. It was declined, as no new skill proposals are taken ([skills #930](https://github.com/mattpocock/skills/issues/930)).
- gsd-core #1990 (2026-07-03) reported no entry point for an existing repository. PR #1994 (merged 2026-07-07) added `/gsd:onboard` (tested 2026-11-28: GraphQL `closedByPullRequestsReferences`; [gsd-core #1990](https://github.com/open-gsd/gsd-core/issues/1990)).
- gsd-core #6690 and #6691 (2026-11-26, open, approved) report onboarding calling a stale map complete, and counting existing docs by filename ([gsd-core #6690](https://github.com/open-gsd/gsd-core/issues/6690), [#6691](https://github.com/open-gsd/gsd-core/issues/6691)).
- EGM #373 (2026-11-09) reported a README with no brownfield path; PR #374 (merged 2026-11-10, after v0.1.1) added a quickstart (tested 2026-11-28: GraphQL; [EGM #373](https://github.com/google/elephant-goldfish-model/issues/373)).
- superpowers #739 (2026-03-15) asked about brownfield use; the maintainer said he uses it on brownfield projects fine ([superpowers #739](https://github.com/obra/superpowers/issues/739)).

**Growth**

- spec-kit #4431 (2026-09-03) reported each run prepending another Sync Impact Report. The maintainer called it review-only material; PR #4432 (merged 2026-09-09) clarified the wording (tested 2026-11-28: GraphQL; [spec-kit #4431](https://github.com/github/spec-kit/issues/4431)).
- spec-kit #3950 (2026-08-03) reported composed presets producing a constitution over 1200 lines; PR #3984 (merged 2026-08-10) fixed it (tested 2026-11-28: GraphQL; [spec-kit #3950](https://github.com/github/spec-kit/issues/3950)).
- spec-kit #1950 (2026-03-24) reported an agent ignoring a big constitution. It closed with the advice that a constitution only grows too big if module or phase rules go into it ([spec-kit #1950](https://github.com/github/spec-kit/issues/1950)).
- mattpocock #190 (2026-05-14) reported `CONTEXT.md` growing large; the answer was a prompt to make it concise ([skills #190](https://github.com/mattpocock/skills/issues/190)). #130 (open) reports the glossary used as a plan and churning; the owner labelled it a design call ([skills #130](https://github.com/mattpocock/skills/issues/130)).

**Drift and duplication**

- OpenSpec #331 (2025-11-23) reported `project.md` drifting because archive never updated it. The maintainer closed it on 2026-04-11 with no comment or PR (tested 2026-11-28: `gh api repos/Fission-AI/OpenSpec/issues/331/timeline`; [OpenSpec #331](https://github.com/Fission-AI/OpenSpec/issues/331)).
- mattpocock #827 (2026-08-09) reported nothing revisiting glossary prose after code changes. It was declined, since the glossary already excludes implementation details ([skills #827](https://github.com/mattpocock/skills/issues/827)).
- spec-kit #2219 (2026-04-14) reported the agent acting from recall of the constitution; a stale bot closed it ([spec-kit #2219](https://github.com/github/spec-kit/issues/2219)).
- gsd-core's codebase-drift gate never fired because no mapped commit was recorded (#3418, closed 2026-09-09). It also ignored modified and deleted files (#4886, closed 2026-09-27) ([gsd-core #3418](https://github.com/open-gsd/gsd-core/issues/3418), [#4886](https://github.com/open-gsd/gsd-core/issues/4886)).
- BMAD #3044 (2026-10-05) reported a finished brief staying `status: draft`. It closed on 2026-11-27 as superseded by v7 on `dev`, which is unreleased ([BMAD #3044](https://github.com/bmad-code-org/BMAD-METHOD/issues/3044)).

**Overwrites and renames**

- spec-kit #507 (2025-09-23) reported `init` overwriting an existing constitution; a stale bot closed it ([spec-kit #507](https://github.com/github/spec-kit/issues/507)). Inferred: `main` no longer overwrites, from the `command_init.py` finding in the spec-kit and OpenSpec section.
- gsd-core #2308 (2026-07-15) reported `new-milestone --ws` rewriting the shared PROJECT.md. PR #2338 (merged 2026-07-17) fixed it (tested 2026-11-28: GraphQL timeline; [gsd-core #2308](https://github.com/open-gsd/gsd-core/issues/2308)).
- OpenSpec #1982 (2026-09-25) reported upgrades keeping `project.md` but no longer reading it; PR #1999 added the migration prompt ([OpenSpec #1982](https://github.com/Fission-AI/OpenSpec/issues/1982)).
- mattpocock #1153 (2026-10-02) reported the v1.3 rename splitting the glossary mid-project. PR #1228 (merged 2026-10-27) added the legacy-name lookup ([skills #1153](https://github.com/mattpocock/skills/issues/1153), [#1176](https://github.com/mattpocock/skills/issues/1176)).

**Declined new artifacts**

- superpowers declined a writing-prd skill: the spec is the durable artifact ([superpowers #1579](https://github.com/obra/superpowers/issues/1579), 2026-05-19). It also closed a constitution-pattern proposal as not based on field experience ([superpowers #1643](https://github.com/obra/superpowers/issues/1643), 2026-05-31).
- OpenSpec's maintainer reported that the steering file usually makes minimal difference to the agent ([OpenSpec #234 comment, 2025-10-23](https://github.com/Fission-AI/OpenSpec/issues/234)).

**Gaps in this search**

- A search for "hallucinat" with `gh issue list --search` matches nothing, because GitHub search does not match word prefixes. `gh search issues` for "hallucination" and "invented" in all seven trackers finds these reports of a planning document inventing content (tested 2026-11-28):
  - BMAD #1693 (2026-02-17): `bmad-bmm-create-prd` invented a three-phase roadmap and moved a stated core requirement to a "Phase 2". It closed as completed on 2026-04-13 after a contributor's change ([BMAD #1693](https://github.com/bmad-code-org/BMAD-METHOD/issues/1693)).
  - mattpocock #961 (2026-08-26): in a headless run, `teach` wrote an invented `## Why` into `MISSION.md`. The owner declined it on 2026-10-07, since `/teach` is interactive by design ([skills #961](https://github.com/mattpocock/skills/issues/961)).
  - mattpocock #1375, in the Issue bodies section, reports glossary entries with invented synonyms.

## Issue bodies and Discussions

**gsd-core issues**

- #4751: a bracket migration left old phase references in PROJECT.md prose. PR #6702 fixed it on `next` on 2026-11-26, after v1.23.0, so no release has it yet (tested 2026-11-28: issue timeline query, `gh release list -R open-gsd/gsd-core`; [gsd-core #4751](https://github.com/open-gsd/gsd-core/issues/4751)).
- #5195: in workstream mode, `/gsd-complete-milestone` rewrote and committed the shared PROJECT.md. PR #5631 fixed it on 2026-10-22 (tested 2026-11-28: timeline query; [gsd-core #5195](https://github.com/open-gsd/gsd-core/issues/5195)).
- #6620 (open, approved): no guidance covers a feasibility question during `new-project` questioning whose answer would change scope ([gsd-core #6620](https://github.com/open-gsd/gsd-core/issues/6620)).
- #6623 (open, approved): the research dimensions and setup questions assume a software project ([gsd-core #6623](https://github.com/open-gsd/gsd-core/issues/6623)).
- #6693 (open, confirmed bug): `ingest-docs` treats navigation links as blocking cycles, so it exits without writing PROJECT.md ([gsd-core #6693](https://github.com/open-gsd/gsd-core/issues/6693)).
- #6696 (open, confirmed bug): `ingest-docs` passes the roadmapper an undefined mode. Nothing tells it how to write PROJECT.md from ingested docs or how to treat a largely built codebase ([gsd-core #6696](https://github.com/open-gsd/gsd-core/issues/6696)).
- #6708 (open, confirmed bug): `new-project` still offers phase counts the roadmapper no longer applies. Line 499 still reads "5-8 phases" (tested 2026-11-28: `gh api "repos/open-gsd/gsd-core/contents/gsd-core/workflows/new-project.md?ref=next"`, grep; [gsd-core #6708](https://github.com/open-gsd/gsd-core/issues/6708)).
- The maintainer account answered each of these with comments marked as generated by AI during triage ([gsd-core #6693](https://github.com/open-gsd/gsd-core/issues/6693), [#6620](https://github.com/open-gsd/gsd-core/issues/6620)).

**Other repositories' issues**

- OpenSpec #800 (2026-03-04, open, no comments): README.md and `config.yaml` both hold purpose, stack and architecture, and fall out of sync. The reporter proposes a `context_source: README.md` key ([OpenSpec #800](https://github.com/Fission-AI/OpenSpec/issues/800)).
- BMAD #2743 (2026-08-15): code review loaded `project-context.md` twice; a collaborator closed it as resolved. At v6.12.4, `persistent_facts = []` (tested 2026-11-28: `gh api ".../src/bmm-skills/ship/bmad-code-review/customize.toml?ref=v6.12.4"`; [BMAD #2743](https://github.com/bmad-code-org/BMAD-METHOD/issues/2743)).
- mattpocock #1375 (2026-11-02, open): on v1.3.1, `domain-modeling` copied an existing glossary's style instead of opening `GLOSSARY-FORMAT.md`. The entries it wrote described behaviour and invented synonyms ([skills #1375](https://github.com/mattpocock/skills/issues/1375)). The owner's brief asks the skill to read the format first; `main` has not changed (tested 2026-11-28: `gh api .../domain-modeling/SKILL.md`, grep).
- OpenSpec #2155 and #2201 and BMAD #3018 concern per-change specs or migration, not a project description ([OpenSpec #2155](https://github.com/Fission-AI/OpenSpec/issues/2155), [#2201](https://github.com/Fission-AI/OpenSpec/issues/2201), [BMAD #3018](https://github.com/bmad-code-org/BMAD-METHOD/issues/3018)).

**Discussions**

- obra/superpowers has Discussions disabled; the other six have them on (tested 2026-11-28: `gh api repos/<r> --jq '[.has_discussions,.default_branch]'`).
- spec-kit #2476 (2026-05-07): the constitution duplicates agent context files. A collaborator replied on 2026-07-06 that spec-kit detached agent context files and all commands now reference the constitution ([spec-kit discussion #2476](https://github.com/github/spec-kit/discussions/2476)).
- OpenSpec #314 (2025-11-18) asked why `project.md` is needed beside `AGENTS.md`; only a community answer exists ([OpenSpec discussion #314](https://github.com/Fission-AI/OpenSpec/discussions/314)).
- OpenSpec #2070 (2026-10-11): short prompts yield specs whose gaps get filled with plausible hallucinations. The poster proposes a human-written anchor problem statement; no maintainer replied ([OpenSpec discussion #2070](https://github.com/Fission-AI/OpenSpec/discussions/2070)).
- BMAD #46 (2025-05-14): after the MVP, agents lose the initial plan and act as if starting a new project ([BMAD discussion #46](https://github.com/bmad-code-org/BMAD-METHOD/discussions/46)). BMAD #1838 (2026-03-06) asks whether to keep one PRD or start one per milestone ([BMAD discussion #1838](https://github.com/bmad-code-org/BMAD-METHOD/discussions/1838)). Neither has a maintainer reply.
- mattpocock #1382 (2026-11-04): no stated path for adopting the skills on a repository with existing, contradictory docs ([skills discussion #1382](https://github.com/mattpocock/skills/discussions/1382)). #1322 (2026-10-23): a fresh `grill-with-docs` session on a grown project already uses 40% of the context window ([skills discussion #1322](https://github.com/mattpocock/skills/discussions/1322)). Only community replies.
- EGM #429 (2026-11-12): `egm-bootstrap` on existing code writes READMEs but no design baseline ([EGM discussion #429](https://github.com/google/elephant-goldfish-model/discussions/429)). EGM #563 (2026-11-24, unanswered): repeated agent passes made a design doc unreadable to its human author ([EGM discussion #563](https://github.com/google/elephant-goldfish-model/discussions/563)).
- gsd-core #2542 (2026-07-22): `.planning/` files conflict between developers when committed, and leave the repository when not ([gsd-core discussion #2542](https://github.com/open-gsd/gsd-core/discussions/2542)).

## BMAD and gsd-core files the first round did not reach

**BMAD agents and evidence rules**

- At `main`, the Analyst's SKILL.md hands create, update and validate to `bmad-facilitate` ([bmad-agent-analyst/SKILL.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/method/bmad-agent-analyst/SKILL.md)). The PO's SKILL.md only prints its workflow from a script ([bmad-agent-po/SKILL.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/method/bmad-agent-po/SKILL.md)).
- `bmad-agent-po` does not exist at v6.12.4 (tested 2026-11-28: `gh api repos/bmad-code-org/BMAD-METHOD/git/trees/v6.12.4?recursive=1 --jq '.tree[].path' | grep -i 'agent-po\|product-owner'` printed nothing).
- The PO's spec reference writes an unaddressed domain implication as an `Open question:` line and never invents the answer. It lists pre-existing project docs as companions and never edits them ([bmad-agent-po/references/spec.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/method/bmad-agent-po/references/spec.md)).
- `bmad-facilitate` asks only what only the user knows and finds other facts through web-research subagents. A yes to a group of recommendations accepts nothing ([bmad-facilitate/SKILL.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/core-tools/bmad-facilitate/SKILL.md)).
- The planning guidance tags each unconfirmed inference `[ASSUMPTION: ...]` and skips the fresh reader at hobby stakes. Names, owners and dates come from the user, never the environment ([guidance-planning.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/core-tools/bmad-facilitate/references/guidance-planning.md)).
- The planning rubric rates Decision-ready, Earned, Testable, Honest scope and Usable downstream as strong, adequate, thin or broken ([rubric-planning.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/core-tools/bmad-facilitate/references/rubric-planning.md)).
- The project-context best practices, identical at `main` and v6.12.4, set these rules for an existing repository ([best-practices.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/method/bmad-project-context/references/best-practices.md); tested 2026-11-28: `diff` of both copies was empty):
  - Policy comes from a human or an enforcing config, never inference.
  - A pitfall needs observed behaviour; a surprising scan finding becomes a question.
  - Versions come from project files, never the session's environment.
  - Repo overviews, directory trees and stack lists stay out, because stored copies rot.
  - Aspirational state stays out; intent belongs in specs.

**BMAD template comments**

- The `main` brief template asks for numbered premises the user can agree or disagree with before drafting. It says only the user knows who the product is for and why now, and forbids inventing a moat, market size, quote or metric ([template-brief.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/method/bmad-agent-analyst/assets/template-brief.md)).
- Each brief section carries a "Done when" test. Problem is done when the user can name someone who has it and its cost. Who it serves rejects "everyone" ([template-brief.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/method/bmad-agent-analyst/assets/template-brief.md)).
- The `main` PRD template says only the user knows who it is for, what is out and what success looks like. It is done when the user remembers making every decision and nothing was invented ([template-prd.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/method/bmad-agent-pm/assets/template-prd.md)).
- The PRD sets about 3,000 words at program or initiative altitude, and says to revisit it after each epic lands ([template-prd.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/method/bmad-agent-pm/assets/template-prd.md)).
- The PRD's Change boundary section applies when the work changes an existing product. It records what stays, what changes, what is added and what must not change ([template-prd.md, main](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/method/bmad-agent-pm/assets/template-prd.md)).
- The v6.12.4 PRD template had an Assumptions Index surfacing every `[ASSUMPTION]` for confirmation ([prd-template.md, v6.12.4](https://github.com/bmad-code-org/BMAD-METHOD/blob/v6.12.4/src/bmm-skills/plan/bmad-prd/assets/prd-template.md)).

**gsd-core requirements approval**

- After the "Ready to create PROJECT.md?" gate, `new-project` synthesizes PROJECT.md and commits it with no step that shows the draft. In auto mode there is no gate at all ([gsd-core/workflows/new-project.md, next](https://github.com/open-gsd/gsd-core/blob/next/gsd-core/workflows/new-project.md)).
- Requirements come from per-category multi-select scoping, a gap question and a cross-check against the Core Value ([new-project.md, next](https://github.com/open-gsd/gsd-core/blob/next/gsd-core/workflows/new-project.md)).
- The approval step shows every requirement, not counts, and asks "Does this capture what you're building? (yes / adjust)". "adjust" returns to scoping; auto mode skips the gate ([new-project.md, next](https://github.com/open-gsd/gsd-core/blob/next/gsd-core/workflows/new-project.md)).
- `next` is 111 commits ahead of v1.23.0, and the compare lists no changed `new-project` file (tested 2026-11-28: `gh api repos/open-gsd/gsd-core/compare/v1.23.0...next --jq '[.ahead_by, ([.files[].filename]|map(select(test("new-project"))))]'` returned `[111,[]]`).

## mattpocock, elephant-goldfish-model and superpowers files the first round did not reach

**mattpocock `chief-of-staff`**

- The skill sits in `skills/in-progress/`, is not shipped in the plugin, and sets `disable-model-invocation: true` ([PR #1304](https://github.com/mattpocock/skills/pull/1304); tested 2026-11-28: `gh api repos/mattpocock/skills/contents/skills/in-progress/chief-of-staff/SKILL.md`).
- It keeps a wiki: `index.md` lists every page, and each page covers a decision, recurring problem, subsystem or user preference, with no fixed sections ([chief-of-staff SKILL.md, main](https://github.com/mattpocock/skills/blob/main/skills/in-progress/chief-of-staff/SKILL.md)).
- It dates every claim, cites code claims to a commit, never writes a bare "currently", and supersedes old claims without editing them. It reasons that a wiki cannot keep up with the code ([chief-of-staff SKILL.md, main](https://github.com/mattpocock/skills/blob/main/skills/in-progress/chief-of-staff/SKILL.md)).
- The user agrees only the wiki's location before the first write; no step shows page content first ([chief-of-staff SKILL.md, main](https://github.com/mattpocock/skills/blob/main/skills/in-progress/chief-of-staff/SKILL.md)).
- A delegated lint pass looks for contradictions, orphan pages, missing links and overtaken claims ([chief-of-staff SKILL.md, main](https://github.com/mattpocock/skills/blob/main/skills/in-progress/chief-of-staff/SKILL.md)).
- Open PR #1369 would add a `destination.md` page with Destination, Fog of war and Out of scope (tested 2026-11-28: `gh pr view 1369 -R mattpocock/skills --json body,files`).

**EGM bootstrap tests**

- `test_scenarios.yaml` asserts `[file:symbol_or_flag]` citations and `None` for absent invariants, and forbids inferring RPCs from a directory name. It also requires the safety gate to state the worker cap ([egm-bootstrap test_scenarios.yaml, main](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-bootstrap/test_scenarios.yaml)).
- Neither `TEST.md` nor `test_scenarios.yaml` mentions drift ([TEST.md, main](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-bootstrap/TEST.md), [test_scenarios.yaml](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-bootstrap/test_scenarios.yaml)). Drift review is an optional gate at the end of bootstrap ([egm-bootstrap SKILL.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-bootstrap/SKILL.md)).
- The unit suite checks only the scenario files' structure, not model output (tested 2026-11-28: `gh api repos/google/elephant-goldfish-model/contents/tests/unit/test_scenario_coverage.py`).
- Open PR #246 would add scenarios requiring a failed scout to leave a visible incomplete marker (tested 2026-11-28: `gh pr diff 246 -R google/elephant-goldfish-model`).

**superpowers builder check**

- The prompt casts a fresh subagent as a builder who cannot talk to the author. It reports only ranked questions where a wrong guess would matter, and skips what the document leaves to the builder ([builder-check-prompt.md, v7.0.2](https://github.com/obra/superpowers/blob/main/skills/brainstorming/builder-check-prompt.md)).
- The check runs for project-sized work, not small changes. Its questions are sorted into answered, minor (the agent's marked call) and the user's, asked in one round ([brainstorming SKILL.md, v7.0.2](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md)).
- The prompt has not changed since v7.0.0 (2026-10-10) (tested 2026-11-28: `gh api 'repos/obra/superpowers/commits?path=skills/brainstorming/builder-check-prompt.md'`).
- Inferred: the prompt names no per-feature content, though superpowers applies it only to per-topic designs, from the prompt and SKILL.md findings.

## Open questions

- Whether BMAD's next release ships the `main` layout (PM and Analyst over `bmad-facilitate`, `bmad-agent-po`) as read. `main` is unreleased and last changed 2026-11-12. Forwarding shims for `bmad-prd` and `bmad-product-brief` on `main` were not confirmed.
- Whether gsd-core's ingest-docs path writes PROJECT.md at all for an indexed doc set until #6693 and #6696 are fixed. Only the triage diagnoses were read.
- Whether any runner executes EGM's `test_scenarios.yaml` against a model. Only structural unit checks and an opt-in live harness were found.
- Whether `egm-drift-report` reads the bootstrap contracts' `[file:symbol]` citations mechanically. Its SKILL.md describes manual reading only.
- Whether OpenSpec's `docs/` quotes still reflect published guidance, given closed issue #2059 calls that tree legacy.
- Discussions searches listed only the first 15 hits per term. Most spec-kit and BMAD threads were judged by title only.

## Method

- The owner confirmed the brief in the coordinating session.
- Researcher 1 covered superpowers, mattpocock/skills and EGM from clones of `main`. Its issue searches hit a GitHub rate limit (`HTTP 403`), so researcher 4 covered all seven issue trackers.
- Researcher 2 covered spec-kit and OpenSpec, and researcher 3 covered gsd-core and BMAD, from shallow clones and `gh`.
- Researcher 4 searched issues and pull requests across all seven repositories.
- Sub-questions 5 to 7 were added after confirmation and ran in a second round. Researcher 5 read issue bodies and Discussions, researcher 6 the unread BMAD and gsd-core files, and researcher 7 the unread mattpocock, EGM and superpowers files.
- Every live check was a read-only `gh` command or a read of a temporary clone; nothing was installed or run against a model. Changelogs were not read to place fixes in releases.
- A checker reopened the cited sources for the Answer, the table, the mattpocock rename, the spec-kit stale-bot closures, the gsd-core ingest-docs bugs, sampled Discussions and every release in `versions`; all releases were current. It replaced the nothing-found hallucination claim, narrowed the Discussions claim, the rename finding and the superpowers table cell. It did not recheck most findings in the spec-kit and OpenSpec, BMAD template, EGM test and superpowers builder-check sections beyond spot checks.
