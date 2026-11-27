# How the reference repositories describe a project, compared with `describe-project`

None of the seven reference repositories, and not our v1, has a skill that writes a standing project description with users, use cases, constraints and non-goals for both greenfield and brownfield work `[inferred]`. GSD comes closest: its `PROJECT.md` template covers most of our sections, but it commits the file without showing it and checks nothing beyond file size `[inferred]`. The ideas worth taking are spread out: reader checks from EGM, superpowers and BMAD, evidence rules for brownfield from EGM, OpenSpec and spec-kit, and template wording from GSD and BMAD.

Sources and method: shallow clones of the seven repositories at HEAD, read on 2026-11-26, plus our v1 read with `git show v1-final:<path>`. One research sub-agent per source read the files and reported with cites. Nothing from the clones was executed. Five cites, one each from GSD, BMAD, OpenSpec, EGM and superpowers, were re-checked by hand. Paths are relative to each repository. `[read]` marks a claim seen in a file by one of those agents. `[inferred]` marks a conclusion. Our skill is `skills/describe-project/SKILL.md` with `templates/PROJECT.md`.

| Source | Commit | Nearest pieces |
| --- | --- | --- |
| obra/superpowers | `22f0b46` | `skills/brainstorming/`, `builder-check-prompt.md` |
| mattpocock/skills | `6f7f783` | `setup-matt-pocock-skills`, `grilling`, `to-spec`, `teach/MISSION-FORMAT.md` |
| google/elephant-goldfish-model | `4693375` | `egm-bootstrap`, `egm-brainstorm`, `egm-draft`, `agents/comprehension.md` |
| github/spec-kit | `f201054` | `constitution`, `specify`, `clarify`, `extensions/assess` |
| Fission-AI/OpenSpec | `f1cd852`, tag `v0.23.0` | the removed `project.md`, `config.yaml` context, `openspec-onboard` |
| open-gsd/gsd-core | `26429a6` | `new-project`, `onboard`, `map-codebase`, `ingest-docs`, `templates/project.md` |
| bmad-code-org/BMAD-METHOD | `e435a22` | `bmad-project-context`, brief and PRD templates, `bmad-facilitate` |
| Our v1 | `v1-final` = `99cb269` | `setup`, `interview-me`, `glossary`, `scan-codebase` |

## Per-source notes

### obra/superpowers

No project-level doc. `brainstorming` works per piece of work and writes a dated design doc `[read: skills/brainstorming/SKILL.md:229-246]`.

- **Description is an absolute trigger:** "You MUST use this before any creative work", with no symptom phrases `[read: SKILL.md:1-4]`.
- **No template file.** The design doc is a content list: intent, goals, non-goals, anti-goals, constraints, approaches, what is left to the builder `[read: SKILL.md:234-239]`.
- **Anti-goals sit beside non-goals:** what counts as failure even if it technically works `[read: SKILL.md:136-137]`.
- **Interview rules:** "Never ask what the project or their context already answers" `[read: SKILL.md:49-50]`; ask only when the answer would change what gets built `[read: SKILL.md:101-102]`; say every default out loud `[read: SKILL.md:290]`.
- **Playback in chunks of 200 to 300 words.** Only what the user said is written as theirs; agent fills are marked as proposals `[read: SKILL.md:192-200]`.
- **Builder check.** A fresh sub-agent reads the doc as a builder who "will not be able to talk to" the author, and ranks the questions where a wrong guess would matter `[read: builder-check-prompt.md:6-23]`.
- **Three piles for the builder's questions:** answered already, minor and settled by the agent, and the user's to answer `[read: SKILL.md:256-262]`. Without a sub-agent, the agent reads the doc as the builder itself `[read: SKILL.md:263-267]`.
- **Left out:** a users section, use case IDs, a roadmap, glossary and decision records, any doc that persists across features `[read: SKILL.md]`. It commits the doc `[read: SKILL.md:246]`.

### mattpocock/skills

No skill writes what the project is. The setup skill writes configuration for other skills, not a description `[read: setup-matt-pocock-skills/SKILL.md:9-13]`.

- **Stance:** "Explore, present what you found, confirm with the user, then write" `[read: setup/SKILL.md:15]`.
- **Questions lead with a recommended answer** that the user can accept in a word, and a section that exploring already settled is skipped `[read: setup/SKILL.md:34-36]`.
- **The user sees and edits a draft of every file** before it is written `[read: setup/SKILL.md:67-72]`.
- **`grilling` asks the frontier:** every decision whose prerequisites are settled, numbered, each with a recommendation `[read: grilling/SKILL.md:6-24]`. "Finding _facts_ is your job, never the user's", through "a sub-agent with a fresh context window" `[read: grilling/SKILL.md:28]`.
- **`teach/MISSION-FORMAT.md` is closest in spirit to `PROJECT.md`:** Why, Success looks like, Constraints, Out of scope, and a cap of one screen `[read: MISSION-FORMAT.md:8-22,31]`.
- **Constraints go to decision records** as "Constraints not visible in the code" `[read: domain-modeling/ADR-FORMAT.md:46]`.
- **Users and non-goals appear only per feature,** in `to-spec`'s user stories and Out of Scope `[read: to-spec/SKILL.md:31-69]`.
- **No verification.** A verify mode is ruled out on purpose `[read: .out-of-scope/setup-skill-verify-mode.md:3-11]`. The interview ends when the user confirms shared understanding `[read: grilling/SKILL.md:30]`.
- **Docs are created lazily:** "proceed silently" when they are missing `[read: setup-matt-pocock-skills/domain.md:11]`.
- **Wrappers name a harness tool:** "Call the Skill tool twice" `[read: grill-with-docs/SKILL.md:7]`.

### google/elephant-goldfish-model

No project-wide doc. `egm-bootstrap` writes per-directory README contracts, and `egm-draft` writes per-feature design docs `[read: skills/egm-bootstrap/SKILL.md:13; skills/egm-draft/references/design_doc.md:16-73]`.

- **Brownfield evidence rule:** every claim cites `[file:symbol_or_flag]`, and nothing is inferred "from file or directory names alone" `[read: egm-bootstrap/SKILL.md:74]`. A final re-read checks every claim and link `[read: SKILL.md:88-91]`.
- **Existing files are merged, never overwritten blindly,** keeping "valid developer notes" `[read: SKILL.md:76]`.
- **Greenfield brainstorm topics:** the problem, consumers, hard constraints, out-of-scope boundaries, today's workaround and success metrics `[read: egm-brainstorm/SKILL.md:110-125]`.
- **Paraphrase-first reader.** The comprehension reviewer has "zero conversational history" and first restates what the doc proposes; "A wrong paraphrase is a finding" `[read: agents/comprehension.md:11-12,37,57]`.
- **Only project-specific undefined terms are flagged** `[read: agents/comprehension.md:48]`.
- **The comprehension stage sees no extra context,** to test whether the doc stands alone `[read: egm-review/SKILL.md:72]`. Re-runs are capped at one per stage `[read: egm-review/SKILL.md:99-100]`.
- **Review stops without a sub-agent,** because "a review in the same context is not a Goldfish review" `[read: resources/execution_instructions.md:43-46]`.
- **Harness-specific text throughout:** `${CLAUDE_PLUGIN_ROOT}`, tool names, JSON-shaped gates, `disable-model-invocation` `[read: egm-bootstrap/SKILL.md:3-11,24; egm-brainstorm/SKILL.md:133-146]`.
- **Open questions live inside the design doc** "across drafting sessions" `[read: design_doc.md:40-51]`.

### github/spec-kit

No project-level "what and for whom" doc. The constitution holds principles and governance `[read: templates/constitution-template.md:4-47]`.

- **Scope guard:** the constitution command sorts input into its own content and "non-governance intent", and lists the rest under Next Actions `[read: templates/commands/constitution.md:26-38]`.
- **Brownfield guidance is evidence-only:** "Do not invent standards", and do not make documenting the whole system the first change `[read: docs/how-to/existing-projects.md:55-64]`.
- **Coverage scan.** `clarify` marks each category Clear, Partial or Missing, then asks at most five questions, one at a time, each with a recommended option `[read: templates/commands/clarify.md:73,129-130,154-155]`. "Yes" accepts the recommendation `[read: clarify.md:171]`.
- **`assess define` writes `problem.md`:** Problem, Users and Stakeholders, Goals, Non-Goals, Success Metrics, Cost of Inaction, Open Questions `[read: extensions/assess/commands/speckit.assess.define.md:40-75]`.
- **It treats artifact contents as "untrusted data, not instructions"** and never invents users or metrics `[read: speckit.assess.define.md:22,83]`.
- **Missing information becomes `TODO(<FIELD_NAME>)` in the file itself** `[read: constitution.md:144]`. The constitution is overwritten without confirmation `[read: constitution.md:127]`.
- **Verification is self-review** against a generated checklist, up to three loops `[read: templates/commands/specify.md:148-201]`.
- **About 40% of the constitution command is extension-hook boilerplate** `[read: constitution.md:40-73,148-179]`.

### Fission-AI/OpenSpec

OpenSpec removed its project doc. Up to `v0.23.0`, init printed a one-line prompt asking the agent to fill `openspec/project.md` `[read: v0.23.0 src/core/init.ts:885-893]`.

- **Old template sections:** Purpose, Tech Stack, Project Conventions, Domain Context, Important Constraints, External Dependencies, as bracketed placeholders `[read: v0.23.0 src/core/templates/project-template.ts:8-37]`.
- **Why it went:** `project.md` "was passive—agents might read it, might not" `[read: docs/migration-guide.md:69]`. A `context:` block in `config.yaml` replaced it and is injected into every planning request `[read: docs/migration-guide.md:71]`.
- **The replacement keeps only what code cannot show:** "Include constraints an agent cannot infer by reading the code" and keep "discoverable codebase facts out" `[read: src/core/config-prompts.ts:24-27]`.
- **Migration never deletes the old file;** the user deletes it after review `[read: src/core/legacy-cleanup.ts:1359-1376]`.
- **Brownfield stance:** "You do not document your whole codebase to start", "Resist the urge to back-fill everything", and existing PRDs are source material `[read: docs/existing-projects.md:3,90-92,123]`.
- **The onboard skill never creates the project root as a side effect** when the agent chose the skill itself `[read: skills/openspec-onboard/SKILL.md:16-25]`.
- **Left out at project level:** users, use cases, non-goals, roadmap `[read: project-template.ts:8-37; config-prompts.ts:16-33]`. No reader check `[inferred]`.

### open-gsd/gsd-core

GSD also names its file `PROJECT.md`, and its template is the closest match to ours `[read: gsd-core/templates/project.md:8-76]`.

| Ours | GSD |
| --- | --- |
| Opening sentence | What This Is, plus Core Value: "The ONE thing that matters most" `[read: project.md:10-18]` |
| Users | No section; users sit in What This Is and Business Context `[read: project.md:12,24]` |
| Use cases `UC-n` | Validated and Active requirements without IDs; `CAT-NN` IDs live in `REQUIREMENTS.md` `[read: project.md:37-43; requirements.md:80]` |
| Constraints | `**[Type]**: [What] — [Why]`; "constraints without rationale get questioned" `[read: project.md:62,126]` |
| Non-goals | Out of Scope, each with a reason, "to prevent re-adding" `[read: project.md:47,112-115]` |
| Roadmap | A separate `ROADMAP.md` of phases `[read: workflows/new-project.md:1062-1100]` |
| Decision records | An inline Key Decisions table `[read: project.md:67-73]` |

- **Descriptions say what, not when:** "Initialize a new project with deep context gathering and PROJECT.md" `[read: skills/gsd-new-project/SKILL.md:3]`.
- **The interview is "dream extraction, not requirements gathering"** `[read: references/questioning.md:3]`. A checklist of what, why, who and done runs in the background `[read: questioning.md:120-131]`.
- **Named interview anti-patterns** include checklist walking and canned "What's out of scope?" questions `[read: questioning.md:149-160]`.
- **Brownfield infers Validated requirements from the codebase map** `[read: new-project.md:226-232]`. The workflow does not ask the user to confirm that list `[inferred: new-project.md:226-251]`.
- **Doc ingest has a precedence rule,** ADR > SPEC > PRD > DOC, and writes nothing on a contradiction `[read: commands/gsd/ingest-docs.md:26; workflows/ingest-docs.md:238-246]`.
- **"Approval to classify documents is not approval to write,"** and an ambiguous answer is never approval `[read: ingest-docs.md:269,293]`.
- **PROJECT.md is written and committed without showing it** `[inferred: new-project.md:293-300]`. `--auto` skips every gate `[read: new-project.md:1102]`.
- **Verification is mechanical:** files exist, none under 20 lines, a secret scan `[read: map-codebase.md:354-366,405-438]`.
- **Harness tools and per-runtime patches:** `AskUserQuestion`, named agent types, a Codex orchestrator rule `[read: new-project.md:9-14; ingest-docs.md:223]`.

### bmad-code-org/BMAD-METHOD

BMAD retired its product brief, PRD, document-project and project-context generators `[read: skills/method/bmod-method/retired.toml:11,30,35,57]`. `bmad-project-context` replaces two of them and writes agent rules, not a product description `[read: help/project-context.md:29,51]`.

- **Project-context steps:** assess, ask what the user brings, discover and verify, interview the gaps, show, then write `[read: bmad-project-context/SKILL.md:35-87]`.
- **Its guardrails:** "No writes until step 5!", "Never ask what a scan could answer", "Never commit." `[read: SKILL.md:33,61,76]`. Questions come in batches of at most eight, and a batch that yields nothing new means write `[read: SKILL.md:65]`.
- **When the repo contradicts the user, it shows the evidence and asks** `[read: SKILL.md:66]`.
- **It excludes overviews, directory trees and "Aspirational state"** `[read: references/best-practices.md:28,34]`.
- **Brief and PRD are templates fed to `bmad-facilitate`.** Each section comment ends with a "Done when" test, such as Users being done when the user could find that person `[read: bmad-agent-analyst/assets/template-brief.md:33-51,45]`.
- **The brief rejects "Everyone" as a user** `[read: template-brief.md:45]`. PRD non-goals "stop invention below" `[read: bmad-agent-pm/assets/template-prd.md:19]`.
- **PRD IDs:** `UJ-N` journeys, `FR-N` requirements, `RULE-N`, `SM-N`, `OQ-N`, global and stable `[read: template-prd.md:23,33-104]`. About 12 more sections are conditional `[read: template-prd.md]`.
- **Facilitation rules:** "Nothing goes in as the user's that they did not say or accept", and a group yes "accepts nothing" `[read: core-tools/bmad-facilitate/SKILL.md:70]`.
- **Finalize runs a fresh reader "given only the document"** and names "the three decisions you are least confident about" `[read: bmad-facilitate/SKILL.md:74,85-92]`.
- **Brownfield advice:** no up-front documentation pass, because the build skill investigates the code each run `[read: help/existing-codebase.md:3]`.
- **Runtime scripts and extra front matter:** `uv run`, TOML customization, `facilitation_order` `[read: bmad-project-context/SKILL.md:22; template-brief.md:1-16]`.

### Our v1

v1 had no project or product doc and no skill for one `[read: v1-final:workflow/artifacts.md:21-29]`. A `git log -G` search found no commit adding one `[inferred]`.

- **`setup` writes nothing before the human says yes,** and lists every write with its template in a table `[read: v1-final:skills/setup/SKILL.md:11-27]`.
- **Each report has one fixed shape** with worked examples for the success and the stop case `[read: setup/SKILL.md:46-99]`. Most `setup` commits refined report shape and confirmation `[read: git log v1-final -- skills/setup]`.
- **"Confirm the decisions, not the file bodies"** `[read: setup/SKILL.md:163]`.
- **`interview-me` asks frontier rounds with a recommendation each,** and "Facts the repo can answer are yours to find" `[read: v1-final:skills/interview-me/SKILL.md:32-46]`. It has named endings: Settled, Too small, Spike `[read: interview-me/SKILL.md:52-63]`.
- **`glossary` triggers on behaviour,** "even when nobody says 'glossary'", and never writes an unconfirmed entry `[read: v1-final:skills/glossary/SKILL.md:3,20-56]`.
- **Claude-only front matter and variables:** `allowed-tools`, `model`, `context: fork`, `${CLAUDE_*}` `[read: setup/SKILL.md:4-6; scan-codebase/SKILL.md:5-8]`.
- **Layered authority:** six workflow docs and a table of nine conflict rules `[read: v1-final:workflow/artifacts.md:6-61]`, the kind of growth our `AGENTS.md` names as why version 1 became too complex `[read: AGENTS.md; inferred]`.
- **A forked report reached the human only through the dispatcher,** so v1 required "relay in full" `[read: commit d9ff065]`.

## Comparison

| Source | Project-level doc | Users | Use case IDs | Non-goals | Constraints | Roadmap | Brownfield source | User confirms before write | Reader check |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Ours | `docs/PROJECT.md` | Section | `UC-n` | Section | Section, "Assumed:" | Optional Now/Next/Later | Code and docs, then interview | Yes, summary | Fresh context window |
| superpowers | No; per-work design doc | In playback only | No | With anti-goals | Yes | No | Reads code first | Yes, chunked playback | Fresh builder |
| mattpocock | No; mission and spec per feature | Per feature | No | Per feature | In decision records | No | Explores first | Yes, draft shown | None, by policy |
| EGM | No; per-directory contracts | Target user only | No | Per feature | Per feature | No | Code, cited per claim | Readiness gate | Paraphrase-first reader |
| spec-kit | Constitution, governance only | Per feature | Per feature (`FR-`, `SC-`) | Per idea | Constitution section | No | Evidence-only guidance | No; overwrites | Self-review checklist |
| OpenSpec | Removed; `config.yaml` context | No | No | Per change | Only what code cannot show | No | Existing docs as source | Only at migration | None |
| GSD | `PROJECT.md` | Inside What This Is | `CAT-NN` in `REQUIREMENTS.md` | With reasons | With reasons | Separate file | Codebase map, doc ingest | No for `PROJECT.md` | File size only |
| BMAD | Retired; PRD template | Section, "Everyone" rejected | `UJ-N`, `FR-N` | Section | Rules with thresholds | MVP scope | No pass; build investigates | Yes, block shown | Fresh reader |
| v1 | None | No | No | Per feature | Per feature | No | None for intent | Yes | None |

Three patterns stand out `[inferred]`:

- **Only GSD keeps a standing project doc,** and it is the one with the weakest confirmation and checks.
- **Every source with a reader check runs it per document in a fresh context.** None asks the reader the three questions ours does; EGM's paraphrase and superpowers' ranked questions are the nearest.
- **The brownfield sources agree on restraint:** cite evidence, do not back-fill, and ask only what code cannot answer.

## Recommendations

Each item gives the change, the reason and the source. Items marked "belongs in `interview-user`" affect our skill only through what it hands over.

### Adopt

- **Add a reason to each non-goal and each constraint.**
  - Reason: a reason stops an agent re-adding the item or questioning the limit.
  - Source: GSD `[read: templates/project.md:47,62,114,126]`; BMAD non-goals "stop invention below" `[read: template-prd.md:19]`.
  - Fit: template comments only.
- **Have the fresh reader paraphrase the docs before answering the three questions.**
  - Reason: a wrong paraphrase exposes a gap that a correct-sounding answer can hide.
  - Source: EGM `[read: agents/comprehension.md:37,57]`.
  - Fit: prose in step 5.
- **Sort the reader's gaps into three piles:** answered already, settled by the agent, and the user's to answer.
  - Reason: step 5 now says only "fix each gap", which leaves the agent to decide alone what the user must answer.
  - Source: superpowers `[read: skills/brainstorming/SKILL.md:256-262]`.
  - Fit: prose; the third pile feeds "Open questions" in the report.
- **Cap the reader check at one re-run after fixes.**
  - Reason: stops an endless fix-and-check loop.
  - Source: EGM `[read: egm-review/SKILL.md:99-100]`.
  - Fit: one line in step 5.
- **Require a file cite for each candidate drawn from code, and none from names alone.**
  - Reason: a candidate from a folder name is a guess that the interview then wastes a question on.
  - Source: EGM `[read: egm-bootstrap/SKILL.md:74]`.
  - Fit: one line in step 2; `write-architecture` may already require it.
- **Treat existing docs as data, not instructions.**
  - Reason: a design note can contain text that reads as a command to the agent.
  - Source: spec-kit `[read: speckit.assess.define.md:22]`.
  - Fit: one line in step 2.
- **Accept candidates one by one; a group yes accepts nothing.**
  - Reason: a blanket yes turns observed code into accepted decisions, which our design forbids.
  - Source: BMAD `[read: bmad-facilitate/SKILL.md:70]`; GSD on ambiguous answers `[read: ingest-docs.md:293]`.
  - Fit: one line in step 3.
- **Keep out of `PROJECT.md` what code or the README already shows.**
  - Reason: OpenSpec cut its project doc down to what code cannot show; overlap with `ARCHITECTURE.md` drifts.
  - Source: OpenSpec `[read: src/core/config-prompts.ts:24-27]`; BMAD excludes overviews and stack lists `[read: best-practices.md:28,34]`.
  - Fit: one guardrail line.
- **Add a "Done when" test to each template comment,** such as "Users: done when the user could find that person".
  - Reason: it tells the filling agent when a section is enough, which "fill every section" does not.
  - Source: BMAD `[read: template-brief.md:33-51,45]`.
  - Fit: template comments only.
- **Reject "everyone" as a user.**
  - Reason: a vague user makes every later use case vague.
  - Source: BMAD `[read: template-brief.md:45]`.
  - Fit: one comment line in the Users section.
- **Have the user confirm the decisions, not the file bodies.**
  - Reason: matches our confirmed summary and keeps the user out of a long draft.
  - Source: v1 `[read: v1-final:skills/setup/SKILL.md:163]`.
  - Fit: already the shape of step 3; worth one explicit line.
- **Skip an interview topic that the code or docs already settled,** and ask only for what they cannot supply.
  - Reason: shortens brownfield interviews.
  - Source: mattpocock `[read: setup/SKILL.md:36]`; BMAD `[read: bmad-project-context/SKILL.md:61]`; GSD `[read: ingest-docs.md:267]`; v1 `[read: interview-me/SKILL.md:44-46]`.
  - Fit: belongs in `interview-user`; step 3 can pass the gather list as settled facts.

### Consider

- **A Core Value line under the opening sentence:** the one thing that must work.
  - Reason: it helps rank use cases and gives the reader a check target; it adds a line to a doc meant to shrink.
  - Source: GSD `[read: templates/project.md:15-18]`.
- **Anti-goals beside non-goals:** what counts as failure even if the project works.
  - Reason: catches a class of drift non-goals miss; may overlap Constraints.
  - Source: superpowers `[read: SKILL.md:136-137]`.
- **A tag on each `UC-n` for existing or planned behaviour.**
  - Reason: brownfield runs mix both, and a reader cannot tell them apart; a tag avoids new sections.
  - Source: GSD's Validated and Active split `[read: new-project.md:228-247]`.
- **Name the least-confident points in the report.**
  - Reason: points the user's review at the riskiest lines of the diff.
  - Source: BMAD `[read: bmad-facilitate/SKILL.md:90]`.
- **A length cap on `PROJECT.md`,** such as one screen.
  - Reason: OpenSpec found a passive doc goes unread; a short one is cheaper to load every time.
  - Source: mattpocock `[read: MISSION-FORMAT.md:31]`; OpenSpec `[read: docs/migration-guide.md:69]`.
- **A default precedence for conflicting docs:** decision record over spec over other docs.
  - Reason: cuts questions when docs disagree; our step 2 already lists both sources, so a default only orders them.
  - Source: GSD `[read: commands/gsd/ingest-docs.md:26]`.
- **Route side requests to the report as next steps.**
  - Reason: keeps a run on `PROJECT.md` when the user raises feature work mid-interview.
  - Source: spec-kit `[read: constitution.md:26-38]`.
- **Interview topics: today's workaround, success measure, prior art.**
  - Reason: they sharpen the problem statement; each adds a question.
  - Source: EGM `[read: egm-brainstorm/SKILL.md:124-125]`; superpowers `[read: SKILL.md:135,138]`; spec-kit's Cost of Inaction `[read: speckit.assess.define.md:68-70]`.
- **A worked report example for the case with no code and no docs.**
  - Reason: v1 found report shape was where iteration went, and our step 1 example shows only brownfield.
  - Source: v1 `[read: v1-final:skills/setup/SKILL.md:46-99; git log v1-final -- skills/setup]`.

### Avoid

- **Harness tool names, environment variables and extra front matter.**
  - Reason: they break Codex and our two-field rule.
  - Source: EGM `[read: execution_instructions.md:36-37]`, GSD `[read: commands/gsd/new-project.md:4-12]`, BMAD `[read: template-brief.md:1-16]`, v1 `[read: setup/SKILL.md:4-6]`.
- **Files read from outside the skill folder.**
  - Reason: breaks under a skills-only install, as `knowledge-across-skills.md` reports.
  - Source: EGM `[read: execution_instructions.md:9-12]`, GSD `[read: new-project.md:42-48]`, v1 `[read: setup/SKILL.md:14]`.
- **Open questions or `TODO` markers inside `PROJECT.md`.**
  - Reason: our design keeps open points in the report so the doc holds only what is settled or assumed.
  - Source: spec-kit `[read: constitution.md:144]`, EGM `[read: design_doc.md:40-51]`, BMAD `OQ-N` `[read: template-prd.md]`.
- **An inline decisions table.**
  - Reason: duplicates `record-decision` and lets the two drift.
  - Source: GSD `[read: templates/project.md:67-73]`.
- **Writing or committing without showing the user, and an auto mode that skips gates.**
  - Reason: conflicts with our confirm-first and uncommitted-diff guardrails.
  - Source: GSD `[read: new-project.md:295-300,1102]`, spec-kit `[read: constitution.md:127]`, superpowers `[read: SKILL.md:246]`.
- **A placeholder template filled by one prompt with no interview or check.**
  - Reason: OpenSpec dropped exactly this as unreliable.
  - Source: OpenSpec `[read: v0.23.0 project-template.ts:10-37; docs/migration-guide.md:69]`.
- **Conventions, tech stack and git workflow in the project doc.**
  - Reason: they belong in `ARCHITECTURE.md` or `docs/conventions/`.
  - Source: OpenSpec's old template `[read: v0.23.0 project-template.ts:16-28]`.
- **A PRD's breadth:** a dozen conditional sections, Given/When/Then per use case, exhaustive user stories.
  - Reason: `PROJECT.md` is meant to shrink to about half a page, per `docs/workflow-design.md`.
  - Source: BMAD `[read: template-prd.md]`, EGM `[read: design_doc.md:53-73]`, mattpocock `[read: to-spec/SKILL.md:41]`.
- **Descriptions without triggers, or with an absolute trigger.**
  - Reason: "Use when invoked by name" never fires on its own; "You MUST use this before any creative work" fires on everything.
  - Source: BMAD `[read: bmad-project-context/SKILL.md:3]`, superpowers `[read: SKILL.md:3]`.
- **Dropping the reader check.**
  - Reason: mattpocock and v1 have none, and GSD checks only file size; our check is the one way to test that a fresh agent can tell settled from open `[inferred]`.
  - Source: mattpocock `[read: setup-skill-verify-mode.md:3-11]`, GSD `[read: map-codebase.md:354-366]`.
