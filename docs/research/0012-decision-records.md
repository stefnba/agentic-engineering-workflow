---
question: "How do the seven reference repositories record decisions, if they record them at all: where decisions live, what gets recorded, in what format, and how records are changed and used later?"
researched: "2026-11-28"
versions: "obra/superpowers v7.0.2 (main 22f0b463, 2026-11-03); mattpocock/skills v1.3.2 (main bbadaa63, 2026-11-27); google/elephant-goldfish-model v0.1.1 (main 46933754, 2026-11-25); github/spec-kit v1.4.5 (main f2010547, 2026-11-25); Fission-AI/OpenSpec v2.2.0 (main dff0188, 2026-11-28); open-gsd/gsd-core v1.23.0 (next e9c3e54, 2026-11-28); bmad-code-org/BMAD-METHOD v6.12.4 (main e435a22, 2026-11-12, an unreleased v7 tree); MADR 4.0.0 (2024-09-17)"
---

# How seven agent-workflow repositories record decisions

## Answer

Read on each default branch on 2026-11-28, the seven repositories handle the facets as follows. "None" means no source for that facet turned up.

| Repository | Where decisions live | Bar for recording | Fields and status | Numbering and layout | How a record changes | Agent's choice vs user's | How later steps use them |
| --- | --- | --- | --- | --- | --- | --- | --- |
| obra/superpowers | Dated design doc, plan, and a temporary ledger of `Ruling:` lines | No bar for a lasting record; every execution-time ruling goes in the ledger | Ruling: what, why, cost if wrong; no status anywhere | Date and topic, no number | No mechanism shipped; the ledger is deleted at the end and git history takes over | Design doc marks the agent's calls "as your call"; final message lists "Rulings I made" | The plan names its spec; executors resolve conflicts against it; reviewers check spec compliance |
| mattpocock/skills | ADRs in `docs/adr/` (via `domain-modeling`); also spec sections and wayfinder decision tickets | Hard to reverse, surprising without context, and a real trade-off, all three | Title and one to three sentences; optional Status `proposed \| accepted \| deprecated \| superseded by ADR-NNNN` | `0001-slug.md`, highest number plus one; folder made lazily; one folder per context | Optional superseded status only; no procedure | Facts are the agent's, decisions the user's; no who-decided field | Most engineering skills read ADRs "in the area you're touching" and flag contradictions |
| google/elephant-goldfish-model | Design docs in `docs/designs/<feature>.md`, chiefly "Alternatives Considered" | Any choice with more than one defensible answer goes to the user; plans leave zero choices open | Author, Status `Draft \| Proposed \| In Review \| Approved`, Date; a reason per rejected alternative | Feature name, no number; registered in an index | Edited in place; no supersede; a dropped design is marked "Not planned" | The agent may not pick or rank; rejections read "Rejected by author:" | Draft reads earlier alternatives from disk; reviews skip accepted decisions; a drift report checks designs against code |
| github/spec-kit | `research.md`, the spec's Clarifications, the plan's Complexity Tracking, the constitution; ADRs only through community extensions | Every open unknown and technology choice; clarify asks at most 5 questions that change the implementation | `research.md`: Decision, Rationale, Alternatives, no status; constitution: Version, Ratified, Last Amended | Per-feature folder, no IDs; one constitution | Clarify replaces text in place; the constitution is amended with a version bump; retention is left to the team | User answers in Clarifications, agent defaults in Assumptions; `research.md` unmarked | Plan gates on the constitution; tasks and implement read `research.md`; analyze makes constitution conflicts critical |
| Fission-AI/OpenSpec | `## Decisions` in each change's optional `design.md`; the archive as history | "Key technical choices", and a `design.md` only for cross-cutting, risky or ambiguous changes | Free prose, no status; stable `### D1` IDs proposed but not merged | Unnumbered; change folder moves to a dated archive folder | Edited in place while the change is active; no supersede | Separated only in conversation; `design.md` unmarked | Apply reads `design.md`; verify warns when code breaks a decision; no step reads the archive |
| open-gsd/gsd-core | `D-NN` bullets in each phase's `CONTEXT.md`; a Key Decisions table in `PROJECT.md`; it ingests the user's ADRs | "Gray areas" the user cares about that would change the result | `D-NN` text, optional tags and reversibility; `PROJECT.md` Outcome Good, Revisit or Pending | `D-NN` per phase file, starting at `D-01` | "Update it" rewrites `CONTEXT.md`, with no rule for existing IDs | A "Claude's Discretion" section; `--auto` picks are unmarked in `CONTEXT.md` | Planner cites `D-NN`; a blocking plan gate and a warn-only verify gate check coverage |
| bmad-code-org/BMAD-METHOD (main, unreleased) | A `decision-record` template run by `bmad-facilitate`; one-paragraph `adr-<slug>.md`; `AD-n` blocks in the architecture spine | The same three-part test as mattpocock, plus "not already recorded" | Template: sections through Status `proposed \| accepted \| rejected \| deprecated \| superseded`, with who and when; `adr-*.md` has no status | `adr-<slug>.md` beside the code or in `docs/decisions/`; `AD-n` never renumbered | A new record supersedes, the old changes only its status; spine rules amended in place | ADRs written only on the user's approval; `[ADOPTED]` and `[ASSUMPTION]` tags | Research lists ADRs by title; a child spine treats the parent's `AD`s as binding; code review names no ADRs |

- **Where they agree.** Five of the seven keep decisions as sections inside a feature artifact: superpowers, elephant-goldfish-model, spec-kit, OpenSpec and gsd-core. Only mattpocock/skills and unreleased BMAD ship a standalone ADR file. Inferred from the "where" findings under each repository.
- **Where they split on change.** Only mattpocock's optional `superseded by ADR-NNNN` status and BMAD's unreleased template link an old record to its replacement. BMAD's template is the only one with a supersede rule. Everything else is edited in place or overwritten, with git as the history. Inferred from the "change" and "fields and status" findings.
- **Agent versus user.** Every repository addresses it, in different places. Only BMAD's template asks "who decided and when"; the others mark it by section, tag or conversation.
- **Own practice differs from what ships.** gsd-core keeps 112 ADRs of its own with issue-number names, five statuses and symmetric supersede links, far beyond what it ships. mattpocock and superpowers amend their own records with dated updates or strike-throughs.
- **Reported problems.** They cluster in mattpocock/skills, where ADRs ship: lifecycle, numbering races, piled-up amendments, over-recording, and agents recording their own recommendation as the user's decision. All were still open on 2026-11-28 except #1145, which its reporter closed. gsd-core's reports are gate and parser bugs. elephant-goldfish-model reviewers re-flag settled decisions. superpowers and OpenSpec declined native ADRs in core, and spec-kit pointed a question on superseded specs to an extension.
- **Published ADR sources.** Nygard (2011-11-15) defines five parts, four statuses, sequential numbers never reused, and keeping a reversed record marked superseded. MADR 4.0.0 (2024-09-17) keeps that core, adds options, drivers, confirmation and optional front matter, and widens the bar to "any (important) decision". The Henderson collection drops numbers and advises immutability, then reports that editable records worked better.
- **Evidence strength.** The repository facts come from file reads, which are strong. They describe default branches that run ahead of the named releases, and BMAD's ADR features exist in no release. The issue findings rest on keyword searches and on triage replies that are often AI-generated, so they are weaker.

## How do obra/superpowers and mattpocock/skills handle each facet?

### obra/superpowers

**Where decisions live**

- No ADR skill, template or folder exists (tested 2026-11-28: `grep -rIil -E 'decision|ADR|rationale|supersed'` and `ls skills` in a clone of `main`).
- `brainstorming` writes a design doc holding "the parts of the how they decided, as they decided them", saved to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` ([skills/brainstorming/SKILL.md, v7.0.2](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md)).
- `writing-plans` says "A plan is the set of decisions the implementer cannot make alone", saved to `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md` ([skills/writing-plans/SKILL.md, v7.0.2](https://github.com/obra/superpowers/blob/main/skills/writing-plans/SKILL.md)).
- During execution, the agent's decisions go into a ledger at `.superpowers/sdd/<plan-basename>/progress.md`, in a git-ignored folder ([skills/executing-plans/SKILL.md, v7.0.2](https://github.com/obra/superpowers/blob/main/skills/executing-plans/SKILL.md); [skills/subagent-driven-development/SKILL.md](https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/SKILL.md)).

**Bar, fields and status**

- The ledger rule is unconditional: "Record every decision in the ledger as `Ruling: <what you decided> — <why> — <what it costs if wrong>`" ([executing-plans/SKILL.md](https://github.com/obra/superpowers/blob/main/skills/executing-plans/SKILL.md)).
- The design doc is prose: "intent and the why; goals, non-goals, anti-goals; constraints; approaches; the parts of the how they decided ...; what's left to the builder" ([brainstorming/SKILL.md](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md)).
- No artifact carries a status field. Approval is a gate in the conversation: "Nothing gets built until your human partner approves the design doc" ([brainstorming/SKILL.md](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md)).

**Change**

- The ledger is deleted at the end: "delete this plan's workspace directory — the git history is the record now" ([executing-plans/SKILL.md](https://github.com/obra/superpowers/blob/main/skills/executing-plans/SKILL.md)).
- No supersede mechanism ships. In the repository's own spec, an old decision is struck through and followed by "**Superseded by the cost iterations below**" ([docs/superpowers/specs/2026-06-09-sdd-task-scoped-review-dispatch-design.md, line 31](https://github.com/obra/superpowers/blob/main/docs/superpowers/specs/2026-06-09-sdd-task-scoped-review-dispatch-design.md)).

**Agent's choice versus user's**

- For a minor question in the builder check: "Settle it yourself and mark it in the document as your call", then hand over "a short list of the calls you made" ([brainstorming/SKILL.md](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md)).
- At the end, every `Ruling:` line goes into the final message under "Rulings I made": "That list is the only place the decisions you took on your human partner's behalf reach them" ([subagent-driven-development/references/final-review.md](https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/references/final-review.md)).

**Later steps**

- The plan header names its spec, and "executors read both" ([writing-plans/SKILL.md](https://github.com/obra/superpowers/blob/main/skills/writing-plans/SKILL.md)).
- "the spec is the authority the plan argues from, and conflicts inside the plan resolve against it" ([executing-plans/SKILL.md](https://github.com/obra/superpowers/blob/main/skills/executing-plans/SKILL.md)).
- The task reviewer gives a spec-compliance verdict ([subagent-driven-development/SKILL.md](https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/SKILL.md)).
- Inferred: no instruction tells a later, unrelated feature to read earlier specs, from the three findings above and none found.

**Own practice**

- `docs/superpowers/specs/` holds 23 dated design docs from 2026-01-22 to 2026-10-06, many with a "## Decisions" section (tested 2026-11-28: `ls docs/superpowers`; [2026-10-05-brainstorming-rebuild-design.md](https://github.com/obra/superpowers/blob/main/docs/superpowers/specs/2026-10-05-brainstorming-rebuild-design.md)).

### mattpocock/skills

**Where decisions live**

- The ADR format ships as `ADR-FORMAT.md` in the `domain-modeling` skill: "ADRs live in `docs/adr/` and use sequential numbering" ([skills/engineering/domain-modeling/ADR-FORMAT.md, main 2026-11-27](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/ADR-FORMAT.md)).
- `grill-with-docs` calls `grilling` and `domain-modeling` and "also creates docs (ADR's and glossary) as we go"; only the user can start it ([skills/engineering/grill-with-docs/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/grill-with-docs/SKILL.md)).
- The `to-spec` template has "## Implementation Decisions" and "## Testing Decisions" sections ([skills/engineering/to-spec/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/to-spec/SKILL.md)).
- `wayfinder` keeps decisions as tracker issues: "a decision lives in exactly one place, its ticket" ([skills/engineering/wayfinder/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/wayfinder/SKILL.md)).

**Bar**

- "All three of these must be true: 1. **Hard to reverse** ... 2. **Surprising without context** ... 3. **The result of a real trade-off**" ([ADR-FORMAT.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/ADR-FORMAT.md)).
- The agent is told to "Offer ADRs sparingly" ([domain-modeling/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md)).
- `improve-codebase-architecture` offers an ADR when the user rejects a candidate "with a load-bearing reason", so later reviews "don't re-suggest it" ([skills/engineering/improve-codebase-architecture/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/improve-codebase-architecture/SKILL.md)).

**Fields and status**

- The template is a heading plus "{1-3 sentences: what's the context, what did we decide, and why.}" ([ADR-FORMAT.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/ADR-FORMAT.md)).
- Optional sections are Status (`proposed | accepted | deprecated | superseded by ADR-NNNN`), Considered Options and Consequences ([ADR-FORMAT.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/ADR-FORMAT.md)).

**Numbering and layout**

- "Scan `docs/adr/` for the highest existing number and increment by one", and create the folder "lazily" ([ADR-FORMAT.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/ADR-FORMAT.md)).
- A multi-context repository keeps system-wide ADRs in root `docs/adr/` and others in `src/<context>/docs/adr/` ([domain-modeling/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md)).

**Change**

- The only shipped mechanism is the optional `superseded by ADR-NNNN` status, "useful when decisions are revisited" ([ADR-FORMAT.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/ADR-FORMAT.md)).
- The repository's own ADR 0002 is amended in place with sections such as "Update, 2026-08-05", which says an earlier path "is superseded" ([.agents/adr/0002-ship-as-a-claude-code-plugin.md](https://github.com/mattpocock/skills/blob/main/.agents/adr/0002-ship-as-a-claude-code-plugin.md)).
- The repository keeps its own ADRs in `.agents/adr/`, not the shipped `docs/adr/`, and they carry no Status (tested 2026-11-28: `ls .agents/adr`).

**Agent's choice versus user's**

- `grilling` says: "Finding _facts_ is your job, never the user's. ... The _decisions_ are the user's: put each to them and wait." ([skills/productivity/grilling/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md)).
- The same skill says "Word each question so "yes" accepts your recommended answer" ([grilling/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md)).
- The ADR format has no field for who decided ([ADR-FORMAT.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/ADR-FORMAT.md)).

**Later steps**

- Setup seeds the rule "read ADRs that touch the area you're about to work in" ([skills/engineering/setup-matt-pocock-skills/domain.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/setup-matt-pocock-skills/domain.md)).
- On a conflict: "surface it explicitly rather than silently overriding: > _Contradicts ADR-0007 (event-sourced orders), but worth reopening because…_" ([domain.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/setup-matt-pocock-skills/domain.md)).
- `to-spec`, `to-tickets`, `tdd`, `diagnosing-bugs` and `improve-codebase-architecture` tell the agent to respect or check ADRs (tested 2026-11-28: `grep -rIn -i '\badr' skills/engineering`).
- `implement` and `code-review` do not mention ADRs (same grep; [skills/engineering/code-review/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/code-review/SKILL.md)).

## How do google/elephant-goldfish-model and github/spec-kit handle each facet?

### google/elephant-goldfish-model

Neither repository has an ADR template, decision log or supersede mechanism (tested 2026-11-28: `grep -rniE "\bADR\b|decision record|supersed|decisions?\.md|decision log"` over clones of both).

**Where decisions live**

- "Designs live in `docs/designs/`" ([docs/getting_started.md, main 2026-11-25](https://github.com/google/elephant-goldfish-model/blob/main/docs/getting_started.md)).
- The design doc template's "Alternatives Considered" gives each alternative a "Reason for Rejection" ([skills/egm-draft/references/design_doc.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-draft/references/design_doc.md)).

**Bar**

- Rule 13: a decision with "more than one defensible answer" goes to the author as options; "Decide mechanical choices with one defensible answer ... yourself" ([skills/egm-draft/SKILL.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-draft/SKILL.md)).
- "The plan must leave **zero design or architectural choices to the implementer**" ([resources/document_standards/implementation-readiness-standard.md](https://github.com/google/elephant-goldfish-model/blob/main/resources/document_standards/implementation-readiness-standard.md)).

**Fields, status and layout**

- The template header has "**Status:** [Draft | Proposed | In Review | Approved]" with Author and Date ([design_doc.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-draft/references/design_doc.md)).
- The repository's own index uses statuses outside that set, such as "Not planned" and "Implemented" ([docs/designs/README.md](https://github.com/google/elephant-goldfish-model/blob/main/docs/designs/README.md)).
- Draft writes `<DESIGN_DIR>/<FEATURE>.md` and registers it in `SITEMAP.md`, else `README.md`, with Link, Date, Author, Components and Description ([egm-draft/SKILL.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-draft/SKILL.md)).

**Change**

- A dropped design stays with a note: "The proposal below is historical; `/egm-ask` is not an available skill" ([docs/designs/ask.md](https://github.com/google/elephant-goldfish-model/blob/main/docs/designs/ask.md)).
- `egm-drift-report` compares each design doc with the code, reports divergences and changes no files ([skills/egm-drift-report/SKILL.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-drift-report/SKILL.md)).

**Agent's choice versus user's**

- "Do not rank the options, mark a default, or pick one", even when the author says "just pick one" ([egm-draft/SKILL.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-draft/SKILL.md)).
- "Document author decisions as `Rejected by author: [technical rationale]`" ([egm-draft/SKILL.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-draft/SKILL.md)).
- "A saved design or resolved report alone does not establish approval" ([getting_started.md](https://github.com/google/elephant-goldfish-model/blob/main/docs/getting_started.md)).
- `egm-resolve` escalates a claim that rests on "a team convention or a verbal decision", and says "\"This was intentional\" is not evidence" ([skills/egm-resolve/SKILL.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-resolve/SKILL.md)).

**Later steps**

- Draft reads rejected alternatives from the brief's "Alternatives Weighed" section: "Do not rely on memory: drafting often runs in a new session" ([egm-draft/SKILL.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-draft/SKILL.md)).
- Lite reviews "skip re-flagging pre-review exclusions and accepted `CONTEST` rationales" ([skills/egm-lite/SKILL.md](https://github.com/google/elephant-goldfish-model/blob/main/skills/egm-lite/SKILL.md)).

### github/spec-kit

**Where decisions live**

- `/speckit.plan` writes `research.md` entries as "Decision: [what was chosen] - Rationale: [why chosen] - Alternatives considered: [what else evaluated]" ([templates/commands/plan.md, main 2026-11-25](https://github.com/github/spec-kit/blob/main/templates/commands/plan.md)).
- `/speckit.clarify` records answers "directly in the spec file" ([templates/commands/clarify.md](https://github.com/github/spec-kit/blob/main/templates/commands/clarify.md)).
- The plan has a Complexity Tracking table with "Simpler Alternative Rejected Because" ([templates/plan-template.md](https://github.com/github/spec-kit/blob/main/templates/plan-template.md)).
- The constitution holds project-wide principles ([templates/constitution-template.md](https://github.com/github/spec-kit/blob/main/templates/constitution-template.md)).
- The bundled `assess` extension writes a go or kill verdict to `.specify/assessments/<slug>/decision.md` ([extensions/assess/commands/speckit.assess.decide.md](https://github.com/github/spec-kit/blob/main/extensions/assess/commands/speckit.assess.decide.md)).
- ADRs come only from the community extension `adrkit`, which core maintainers do not review ([docs/community/extensions.md](https://github.com/github/spec-kit/blob/main/docs/community/extensions.md); [extensions/README.md](https://github.com/github/spec-kit/blob/main/extensions/README.md)).

**Bar**

- `research.md` covers every `NEEDS CLARIFICATION` unknown and every technology choice ([plan.md](https://github.com/github/spec-kit/blob/main/templates/commands/plan.md)).
- Clarify skips a question whose answer "would not materially change implementation or validation strategy", with a "Maximum of 5 total questions" ([clarify.md](https://github.com/github/spec-kit/blob/main/templates/commands/clarify.md)).

**Fields, status and layout**

- `research.md` entries carry no status (inferred from the plan.md format above).
- The constitution footer carries "**Version**", "**Ratified**" and "**Last Amended**" ([constitution-template.md](https://github.com/github/spec-kit/blob/main/templates/constitution-template.md)).
- Clarifications are `- Q: <question> → A: <final answer>` bullets under `### Session YYYY-MM-DD` ([clarify.md](https://github.com/github/spec-kit/blob/main/templates/commands/clarify.md)).
- `research.md` sits in the feature folder, and the constitution at `/memory/constitution.md` ([plan-template.md](https://github.com/github/spec-kit/blob/main/templates/plan-template.md); [plan.md](https://github.com/github/spec-kit/blob/main/templates/commands/plan.md)).

**Change**

- Clarify replaces contradicted text: "leave no obsolete contradictory text" ([clarify.md](https://github.com/github/spec-kit/blob/main/templates/commands/clarify.md)).
- The constitution is amended with a semantic-version bump and a temporary Sync Impact Report that is "expected to be removed before the amended constitution file is committed" ([templates/commands/constitution.md](https://github.com/github/spec-kit/blob/main/templates/commands/constitution.md)).
- What survives after delivery is left to the team, from four persistence models: "None is the default, and none is required by Spec Kit." ([docs/how-to/persisting-specs.md](https://github.com/github/spec-kit/blob/main/docs/how-to/persisting-specs.md)).
- The persistence models arrived in 1.2.0 (2026-10-13), and the constitution-only model in 1.3.3 (2026-11-09) ([CHANGELOG.md](https://github.com/github/spec-kit/blob/main/CHANGELOG.md)).

**Agent's choice versus user's**

- Specify says "Use reasonable defaults ... (document assumptions in Assumptions section)" ([templates/commands/specify.md](https://github.com/github/spec-kit/blob/main/templates/commands/specify.md)).
- Inferred: the location tells whose choice it was, user answers in Clarifications and agent defaults in Assumptions, while `research.md` carries no marker, from the clarify, specify and plan findings.

**Later steps**

- Plan reads the constitution, fills a Constitution Check and gives an "ERROR if violations unjustified" ([plan.md](https://github.com/github/spec-kit/blob/main/templates/commands/plan.md)).
- Implement reads "research.md for technical decisions and constraints" ([templates/commands/implement.md](https://github.com/github/spec-kit/blob/main/templates/commands/implement.md)).
- Analyze: "Constitution conflicts are automatically CRITICAL" ([templates/commands/analyze.md](https://github.com/github/spec-kit/blob/main/templates/commands/analyze.md)).

## How do Fission-AI/OpenSpec and open-gsd/gsd-core handle each facet?

### Fission-AI/OpenSpec

**Where decisions live and the bar**

- The `design.md` template has "## Decisions ... Key design decisions with rationale and alternatives considered" ([schemas/spec-driven/templates/design.md, main 2026-11-28](https://github.com/Fission-AI/OpenSpec/blob/main/schemas/spec-driven/templates/design.md)).
- `design.md` is written only for a cross-cutting change, a new dependency or data model, security, performance or migration risk, or ambiguity ([schemas/spec-driven/schema.yaml](https://github.com/Fission-AI/OpenSpec/blob/main/schemas/spec-driven/schema.yaml)).
- "Archived changes become your project's decision history" ([skills/openspec-onboard/SKILL.md](https://github.com/Fission-AI/OpenSpec/blob/main/skills/openspec-onboard/SKILL.md)).
- ADRs exist only in a community schema, `intent-driven`, which "writes qualifying long-lived decisions as immutable, supersedable ADRs" ([docs/customization.md](https://github.com/Fission-AI/OpenSpec/blob/main/docs/customization.md)).

**Fields, layout and change**

- Decisions are free prose, as in `### Decision: Context over Redux` with "because:" bullets ([docs/concepts.md](https://github.com/Fission-AI/OpenSpec/blob/main/docs/concepts.md)).
- On archive, a change moves to `archive/<target-name>/`, with today's date prepended ([skills/openspec-onboard/SKILL.md](https://github.com/Fission-AI/OpenSpec/blob/main/skills/openspec-onboard/SKILL.md)).
- `openspec-update-change` revises a change "to fold new decisions into it" ([skills/openspec-update-change/SKILL.md](https://github.com/Fission-AI/OpenSpec/blob/main/skills/openspec-update-change/SKILL.md)).
- Inferred: no shipped format keeps an old decision beside its replacement, from the absence of any supersede field in the templates read.

**Agent's choice versus user's**

- Explore: "Track decisions in the conversation, not in files. Separate confirmed decisions from proposed defaults and unresolved questions. Silence is not acceptance." ([skills/openspec-explore/SKILL.md](https://github.com/Fission-AI/OpenSpec/blob/main/skills/openspec-explore/SKILL.md)).
- `ff-change` leans the other way: "prefer making reasonable decisions to keep momentum" ([skills/openspec-ff-change/SKILL.md](https://github.com/Fission-AI/OpenSpec/blob/main/skills/openspec-ff-change/SKILL.md)).
- Inferred: a decision in `design.md` may be the agent's own with nothing marking it so, from the two findings above and the template.

**Later steps**

- Verify extracts decisions and adds "WARNING: \"Design decision not followed: <decision>\"" ([skills/openspec-verify-change/SKILL.md](https://github.com/Fission-AI/OpenSpec/blob/main/skills/openspec-verify-change/SKILL.md)).
- On archive only delta specs merge into the main specs; `design.md` stays in the archive ([docs/concepts.md](https://github.com/Fission-AI/OpenSpec/blob/main/docs/concepts.md)).
- Inferred: no step reads archived `design.md` files when a new change is planned, from the propose, apply and verify skills grepped.

**Own practice**

- Its own slice specs split "## Locked Decisions (roadmap, owner-directed — not relitigated here)" from "## Decisions This Spec Makes (autonomous, recorded in the changelog)" ([openspec/work/.../personal-worksets/spec.md](https://github.com/Fission-AI/OpenSpec/blob/main/openspec/work/simplify-context-and-workspace-model/slices/personal-worksets/spec.md)).

### open-gsd/gsd-core

**Where decisions live and the bar**

- The phase template "captures implementation decisions for a phase" in `.planning/phases/XX-name/{phase_num}-CONTEXT.md` ([gsd-core/templates/context.md, next 2026-11-28](https://github.com/open-gsd/gsd-core/blob/next/gsd-core/templates/context.md)).
- `PROJECT.md` has a Key Decisions table: "Decisions that constrain future work" ([gsd-core/templates/project.md](https://github.com/open-gsd/gsd-core/blob/next/gsd-core/templates/project.md)).
- "Gray areas are **implementation decisions the user cares about** — things that could go multiple ways and would change the result." ([gsd-core/workflows/discuss-phase.md](https://github.com/open-gsd/gsd-core/blob/next/gsd-core/workflows/discuss-phase.md)).
- `/gsd:plan-phase --ingest` parses the user's ADRs into a phase `CONTEXT.md` ([adr-ingest-express-path.md](https://github.com/open-gsd/gsd-core/blob/next/gsd-core/workflows/plan-phase/steps/adr-ingest-express-path.md)). No ADR-writing command ships (folder listing of `commands/gsd/`).

**Fields, status and layout**

- A decision is `- **D-01:** [Decision or preference captured] — **Reversibility:** [one-way] — [rationale: ...]` ([discuss-phase/templates/context.md, next e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/discuss-phase/templates/context.md)).
- Tags `informational`, `folded` and `deferred` make a decision non-trackable ([src/decisions.cts](https://github.com/open-gsd/gsd-core/blob/e9c3e54/src/decisions.cts)).
- The parser accepts "numeric (D-42), alphanumeric (D-INFRA-01), and phase-prefixed (D4-01 ...) IDs" ([src/decisions.cts](https://github.com/open-gsd/gsd-core/blob/e9c3e54/src/decisions.cts)).
- `PROJECT.md` rows have Decision, Rationale and Outcome, which is Good, Revisit or Pending ([templates/project.md](https://github.com/open-gsd/gsd-core/blob/next/gsd-core/templates/project.md)).
- Ingest refuses `superseded`, `rejected` and `deprecated` ADRs, warns on `proposed`, and treats a missing status as `accepted` ([adr-ingest-express-path.md](https://github.com/open-gsd/gsd-core/blob/next/gsd-core/workflows/plan-phase/steps/adr-ingest-express-path.md)).

The change, agent-versus-user and later-step facets are covered under the sub-question on `--auto`, "Update it" and the coverage gates.

**Own practice**

- The repository keeps 112 ADRs in `docs/adr/`, besides its `README.md` (tested 2026-11-28: `gh api repos/open-gsd/gsd-core/contents/docs/adr?ref=next`, counting entries other than `README.md`).
- They are named `docs/adr/<issue#>-<kebab-slug>.md`, because locally computed numbers collided: "`0010-*` exists twice and `0011-*` exists three times" ([docs/adr/README.md](https://github.com/open-gsd/gsd-core/blob/next/docs/adr/README.md)).
- "ADRs are append-only. Amendments extend existing ADRs with a dated section rather than replacing them." ([docs/adr/README.md](https://github.com/open-gsd/gsd-core/blob/next/docs/adr/README.md)).
- Statuses are Accepted, Proposed, Superseded, Retired and Legacy. "If A declares either relation toward B, **B must record the reciprocal.**" ([docs/adr/README.md](https://github.com/open-gsd/gsd-core/blob/next/docs/adr/README.md)).
- A CI script, `scripts/gen-adr-index.cjs`, enforces the index; amendment back-links are "not yet enforced" ([docs/adr/README.md](https://github.com/open-gsd/gsd-core/blob/next/docs/adr/README.md)).
- ADR-4962 went from Proposed (PR #6795) to accepted (PR #6823) on 2026-11-27, after v1.23.0 ([PR #6795](https://github.com/open-gsd/gsd-core/pull/6795); [PR #6823](https://github.com/open-gsd/gsd-core/pull/6823)).

## How does bmad-code-org/BMAD-METHOD handle each facet?

**Which tree this describes**

- `main` is 273 commits ahead of v6.12.4 (tested 2026-11-28: `gh api --method GET repos/bmad-code-org/BMAD-METHOD/compare/v6.12.4...main --jq '.ahead_by, .behind_by'`, which returned `273`, `13`).
- v6.12.4 has no `decision-record` template and no `bmad-facilitate` skill (tested 2026-11-28: `grep -rliE '\bADR\b|decision record|decision-log|supersede'` and `ls src/core-skills` in a v6.12.4 clone).
- The changelog lists the ADR proposal features as unreleased ([CHANGELOG.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/CHANGELOG.md)).

**Where decisions live**

- The `decision-record` template is for "Recording any decision: context, options, choice and consequences", run by `bmad-facilitate` ([template-decision-record.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmod-method/doc-templates/template-decision-record.md)).
- Codebase research "proposes a decision record (ADR) for each decision the historians found in a commit or pull request that no listed ADR covers" ([bmad-deep-recon/references/codebase.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/core-tools/bmad-deep-recon/references/codebase.md)).
- The retrospective proposes ADRs from a plan's `<frozen-after-approval>` block, Design Notes or Implementation Notes ([bmad-retrospective/references/acceptance-verdict.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-retrospective/references/acceptance-verdict.md)).
- The architecture skill records decisions as `AD-n` blocks in a spine, and "rationale lives in the memlog" ([bmad-architecture/SKILL.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-architecture/SKILL.md)).

**Bar**

- The retrospective proposes an ADR "when it is hard to reverse, surprising without context, and the result of a real trade-off, and no `adr-*.md` file or decisions-folder record in the repository already records it" ([acceptance-verdict.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-retrospective/references/acceptance-verdict.md)).
- The template's own bar is "Any decision worth recording" ([bmod-core-tools/help/facilitate.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/core-tools/bmod-core-tools/help/facilitate.md)).

**Fields and status**

- The template's order is `[context, decision-drivers?, options-considered, decision, consequences, confirmation?, links?, status]` ([template-decision-record.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmod-method/doc-templates/template-decision-record.md)).
- "The user must pick exactly one of: proposed, accepted, rejected, deprecated, superseded. Superseded names the record that replaces this one. Then who decided and when." (same file).
- The document also carries its own `status: draft`, which only Close changes to `final` ([bmad-facilitate/SKILL.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/core-tools/bmad-facilitate/SKILL.md)).
- A one-paragraph ADR is "one file, `adr-<decision-slug>.md`, its name and title stating the decision, its body one paragraph (context, decision, why)", with no status ([acceptance-verdict.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-retrospective/references/acceptance-verdict.md)).
- Spine blocks are `### AD-1 — {decision}` with **Binds**, **Prevents** and **Rule** ([spine-template.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-architecture/assets/spine-template.md)).

**Numbering and layout**

- An `adr-<decision-slug>.md` goes "beside the code it governs, or in the repository's decisions folder (else `docs/decisions/`) for a system-wide one" ([bmod-method/help/preparing-a-repo-for-agents.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmod-method/help/preparing-a-repo-for-agents.md)).
- A facilitated document lands in `{output_folder}/{active_initiative}/<id>-<slug>/` ([bmod-core-tools/help/help.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/core-tools/bmod-core-tools/help/help.md)).
- Spine IDs are a "stable ascending id (never reused/renumbered)" ([spine-template.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-architecture/assets/spine-template.md)).

**Change**

- "A changed decision gets a new record that supersedes this one; this one is not rewritten beyond its status." ([template-decision-record.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmod-method/doc-templates/template-decision-record.md)).
- Update mode will "Surface conflicts with prior decisions before applying", and offers Create for a fundamental change ([bmad-facilitate/SKILL.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/core-tools/bmad-facilitate/SKILL.md)).
- The spine is amended in place: "amend a Rule in place, add the next `AD-n` for a new decision, never renumber or reuse a retired ID" ([bmad-architecture/SKILL.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-architecture/SKILL.md)).

**Agent's choice versus user's**

- "Ask the user about each in interactive runs and write only the approved ones; a headless run only proposes" ([acceptance-verdict.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-retrospective/references/acceptance-verdict.md)).
- When no source gives a reason, "the record says so, since a reason the retrospective supplies is later read as the team's" (same file).
- `bmad-facilitate` logs "each unconfirmed inference as an `assumption`", and "a yes to a group, such as \"your recommendations\", accepts nothing" ([bmad-facilitate/SKILL.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/core-tools/bmad-facilitate/SKILL.md)).
- Build plans split a human-owned `<frozen-after-approval>` block from agent-owned, append-only Implementation Notes ([bmad-build/plan-template.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-build/plan-template.md)).
- The spine tags a decision `[ADOPTED]` "when the user or existing reality already settled it", and the fast path drafts with `[ASSUMPTION]` tags ([bmad-architecture/SKILL.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-architecture/SKILL.md)).

**Later steps**

- Research lists ADRs by title "and open[s] one only when the ask names or continues it, since a document in context gets repeated whether or not it still holds" ([codebase.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/core-tools/bmad-deep-recon/references/codebase.md)).
- A child spine treats a parent's `AD`s as "**binding, read-only** constraints", and a contradiction is "a **conflict to surface**, not a local override" ([bmad-architecture/SKILL.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-architecture/SKILL.md)).
- `AGENTS.md` "should make agents aware the records exist and when to consult them, without copying their content" ([preparing-a-repo-for-agents.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmod-method/help/preparing-a-repo-for-agents.md)).
- `bmad-build` loads architecture documents and earlier plans, and names no `adr-*.md` files ([bmad-build/step-01-clarify-and-route.md, main@e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-build/step-01-clarify-and-route.md); grep of `skills/method/bmad-build/` for `adr`).

**Own practice and dating**

- The repository keeps no ADRs of its own (tested 2026-11-28: `find . -iname '*adr*' -o -iname '*decision*'` in a `main` clone, which found only a plan doc and the template).
- PR #3210, merged 2026-11-17, removed the shared `_bmad/scripts/memlog.py` and moved each skill's state into its document ([BMAD-METHOD PR #3210](https://github.com/bmad-code-org/BMAD-METHOD/pull/3210)).
- On `dev`, the template is at version 1.3.0 against 1.1.0 on `main`, and makes every section required (tested 2026-11-28: `gh api --method GET ".../contents/skills/method/bmod-method/doc-templates/template-decision-record.md?ref=dev"`, diffed with `main`).
- Inferred: the memlog-based findings above describe `main` at 2026-11-12, before #3210, and may not hold on `dev`, from the two findings above.

## What problems with recording, finding, changing or following decisions are reported in the issues and discussions of the seven repositories, if any?

Searches ran through GraphQL by relevance on 11 terms; the next sub-question adds a newest-first pass. Most triage replies on mattpocock/skills and gsd-core say they were "generated by AI during triage" ([mattpocock/skills #1371](https://github.com/mattpocock/skills/issues/1371); [gsd-core #6710](https://github.com/open-gsd/gsd-core/issues/6710)).

**Core declines native ADRs**

- superpowers #754 closed not planned (2026-08-19). A collaborator said the design doc already holds "decisions and rationale", and an ADR "would fit well as a standalone plugin" ([superpowers #754](https://github.com/obra/superpowers/issues/754)).
- OpenSpec #557 closed not planned (2026-08-06). Its conclusion, from a non-maintainer, lists the open questions: "immutable/superseding MADR records versus mutable deltas, ADR status and acceptance, cross-change ownership, concurrent numbering, and context/retrieval behavior" ([OpenSpec #557](https://github.com/Fission-AI/OpenSpec/issues/557)).
- A spec-kit collaborator answered a question on superseded specs with "I highly recommend creating an extension" ([spec-kit discussion #1818, 2026-03-13](https://github.com/github/spec-kit/discussions/1818)).
- A BMAD maintainer said "the architecture was never meant to be a long term artifact" ([BMAD #1980, 2026-04-29](https://github.com/bmad-code-org/BMAD-METHOD/issues/1980)).

**ADR lifecycle in mattpocock/skills, all open on 2026-11-28**

- #299: "ADRs for planned work read as if they were in force", because no consuming skill filters on Status ([skills #299, 2026-10-06](https://github.com/mattpocock/skills/issues/299)).
- #822: a reporter counted "11 of 72" ADRs "superseded or rejected — and still sitting in `docs/adr/`" ([skills #822, 2026-08-09](https://github.com/mattpocock/skills/issues/822)).
- #1114: amendment blocks piled up, "5 of my 20 ADRs ended up with 6 of these blocks", while the original text "still stated the old decision" ([skills #1114, 2026-09-23](https://github.com/mattpocock/skills/issues/1114)).
- #799: "four branches open at once each scanned `docs/adr/` and took the same next number" ([skills #799](https://github.com/mattpocock/skills/issues/799)).
- #1089: a reporter had 70 ADRs; the owner answered that high effort "can incentivise the model to simply produce more tokens, i.e. write more files" ([skills #1089, 2026-09-18](https://github.com/mattpocock/skills/issues/1089)).
- `ADR-FORMAT.md` has not changed since 2026-08-19 (tested 2026-11-28: `gh api --method GET repos/mattpocock/skills/commits -f path=skills/engineering/domain-modeling/ADR-FORMAT.md -f per_page=5`).
- Two users in discussion #1409 disagree: one edits a single decisions section in place, the other keeps records and filters the agent's reading by status ([skills discussion #1409, 2026-11-17 and 2026-11-18](https://github.com/mattpocock/skills/discussions/1409)). Neither is a maintainer.

**The agent's choice recorded as the user's**

- mattpocock #1145: "It documents what it recommended anyway. Only to later cite it as a decision" ([skills #1145](https://github.com/mattpocock/skills/issues/1145)).
- gsd-core #5438: the researcher agent "can self-resolve its own questions to bypass the gate" ([gsd-core #5438, 2026-10-16](https://github.com/open-gsd/gsd-core/issues/5438)). Fix PR #5466 "requires a cited D-NN decision, not a self-written (RESOLVED) marker" ([gsd-core #5466](https://github.com/open-gsd/gsd-core/pull/5466)).

**Decisions lost or not followed**

- superpowers #2253, open: "Finish deletes the only record of deferred findings" ([superpowers #2253](https://github.com/obra/superpowers/issues/2253)).
- mattpocock #341, open: resolved grilling answers do not survive through PRD, issues and implementation ([skills #341, 2026-06-17](https://github.com/mattpocock/skills/issues/341)).
- OpenSpec #738: decisions made in explore "would be 'lost'" in a fresh context ([OpenSpec #738](https://github.com/Fission-AI/OpenSpec/issues/738)).
- spec-kit discussion #1619 reports "weak constitution adherence"; the collaborator answered that "your agent and the model used is most definitely the driver" ([spec-kit discussion #1619, 2026-02-23](https://github.com/github/spec-kit/discussions/1619)).
- BMAD #2863 closed not planned: "Static markdown prompts alone cannot reliably enforce session-end memory writes across hosts", with enforcement through hooks explored for v7 ([BMAD #2863, 2026-11-28](https://github.com/bmad-code-org/BMAD-METHOD/issues/2863)).

## Which decision-related reports in the seven repositories' issues, pull requests and discussions does a newest-first search since each latest release find, what did obra/superpowers PR #880 give as its reason, and which of the open fixes found earlier have merged?

The search was `created:>=<latest release date> sort:created-desc decision OR ADR OR rationale OR supersede OR ignored OR contradicts`, once for issues and PRs and once for discussions (tested 2026-11-28: `gh api graphql`).

**Reports since each release**

| Repository | Window starts | Decision reports found |
| --- | --- | --- |
| obra/superpowers | 2026-11-03 | None among 18 results |
| mattpocock/skills | 2026-10-29 | #1475, #1424, #1407, #1442, #1430, #1371, #1347, discussion #1409 |
| google/elephant-goldfish-model | 2026-11-06 | #408, PR #410, PR #462, #502 and PR #515 |
| github/spec-kit | 2026-11-25 | None among 5 results |
| Fission-AI/OpenSpec | 2026-11-24 | None among 5 results and one discussion |
| open-gsd/gsd-core | 2026-11-23 | #6710, #6701, #6700, #6695, #6617, #6592, #6587, #6619, #6709 |
| bmad-code-org/BMAD-METHOD | 2026-10-14 | PR #3210, discussion #3236 |

- mattpocock #1475: "a single yes can accept multiple independent decisions", open with no maintainer comment ([skills #1475, 2026-11-25](https://github.com/mattpocock/skills/issues/1475)).
- mattpocock #1424: the "yes accepts" wording removes real alternatives; triage calls it "a design call for Matt" ([skills #1424, 2026-11-25](https://github.com/mattpocock/skills/issues/1424)).
- mattpocock #1407: "the map records things the user never decided as decisions" ([skills #1407, 2026-11-09](https://github.com/mattpocock/skills/issues/1407)).
- mattpocock #1371 closed not planned: triage called it "the model not following the skill rather than a gap in it" ([skills #1371, 2026-11-25](https://github.com/mattpocock/skills/issues/1371)).
- elephant-goldfish-model #408: a zero-context reviewer "tends to flag things already settled by earlier decisions" ([egm #408, 2026-11-10](https://github.com/google/elephant-goldfish-model/issues/408)).
- On PR #410, a collaborator asked to "try one review with a short, explicit list of settled decisions and compare it with a clean-context run" ([egm PR #410, 2026-11-21](https://github.com/google/elephant-goldfish-model/pull/410)).
- gsd-core #6700: the matcher does not count `D-08a` as citing `D-08`, because "the citation test is a whole-token `\bD-08\b`" ([gsd-core #6700, 2026-11-27](https://github.com/open-gsd/gsd-core/issues/6700)).
- gsd-core #6695: "only an ADR with status Accepted can be locked", approved as an enhancement ([gsd-core #6695, 2026-11-27](https://github.com/open-gsd/gsd-core/issues/6695)).
- The spec-kit and OpenSpec windows were three to four days long, so "none found" covers little.

**Superpowers PR #880**

- PR #880 proposed `using-memory` and `record-memory` skills under `docs/superpowers/memory/`, and was closed unmerged on 2026-05-05 (tested 2026-11-28: `gh api graphql` `pullRequest(number:880)`, which returned `"state": "CLOSED", "mergedAt": null`).
- It rejected spec and plan docs, commits and always-loaded files as memory stores, because they "make retrieval too expensive", lose history, or "cause context rot" ([superpowers PR #880, 2026-03-22](https://github.com/obra/superpowers/pull/880)).
- The maintainer's reason: "enough people have enough divergent opinions about them that I'm not going to force mine onto every superpowers user" ([superpowers PR #880, 2026-05-05](https://github.com/obra/superpowers/pull/880)).

**State of the open fixes**

- Of the items found earlier, only BMAD PR #3210 merged, on 2026-11-17. Every listed mattpocock and gsd-core item stays open except mattpocock #1145. OpenSpec #2167, PR #2134, and egm #408 and PR #410 also stay open (tested 2026-11-28: `gh api graphql` with `issueOrPullRequest(number:N)`).
- mattpocock #1145 shows "completed", but the reporter closed it and no PR did (same query, ClosedEvent `closer: null`).
- OpenSpec PR #2113 closed unmerged on 2026-10-29, and BMAD #2863 closed not planned on 2026-11-28 (same query).

## In open-gsd/gsd-core, how do `--auto` mode and the discuss-phase "Update it" path mark or change `D-NN` decisions, and how do the decision-coverage gates match a decision; in Fission-AI/OpenSpec, what do the open changes for `### D1` decision IDs propose?

### gsd-core

**`--auto` and assumptions mode**

- In `--auto`, discuss-phase takes the recommended option "**without using AskUserQuestion**" and logs `[auto] [Area] — Q: "[question text]" → Selected: "[chosen option]" (recommended default)` ([discuss-phase/modes/auto.md, next e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/discuss-phase/modes/auto.md)).
- The `CONTEXT.md` template has no per-decision field for who decided; the only grouping is `### Claude's Discretion`, for "Areas where user said "you decide"" ([discuss-phase/templates/context.md, next e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/discuss-phase/templates/context.md)).
- `DISCUSSION-LOG.md` is "**Audit trail only.** Do not use as input to planning, research, or execution agents." ([discuss-phase/templates/discussion-log.md, next e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/discuss-phase/templates/discussion-log.md)).
- In assumptions mode "each assumption becomes a locked decision", and auto picks are listed in an "Auto-Resolved" section of the log ([discuss-phase-assumptions.md, next e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/discuss-phase-assumptions.md)).
- Inferred: an agent reading only `CONTEXT.md` cannot tell an auto-picked `D-NN` from a user-made one, from the three findings above.
- The planner treats "locked decisions" as "NON-NEGOTIABLE", and decides Discretion areas itself ([agents/gsd-planner.md](https://github.com/open-gsd/gsd-core/blob/next/agents/gsd-planner.md)).

**"Update it"**

- "Update it" loads the existing context and continues to analysis; `--auto` selects it automatically ([discuss-phase.md, next e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/discuss-phase.md)).
- `write_context` says "Create CONTEXT.md" and mentions no existing decisions or IDs (same file).
- No workflow or mode file mentions renumbering or existing decisions (tested 2026-11-28: `grep -rn 'D-NN\|renumber\|existing decision' gsd-core/workflows/discuss-phase*.md gsd-core/workflows/discuss-phase/modes/*.md`, no matches).
- Inferred, not tested: an update may write a fresh `D-01` sequence, so a plan citing `D-NN` could point at a different decision, from the findings above and the ID matcher below.

**The coverage gates**

- One matcher serves both gates: a whole-word ID match first, then the first six normalised words of the decision text ([src/decision-coverage-support.cts, next e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/src/decision-coverage-support.cts)).
- The plan gate blocks: "A miss surfaces the missing decision by id and refuses to mark the phase planned." ([docs/explanation/decision-coverage-gates.md, next e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/docs/explanation/decision-coverage-gates.md)).
- The verify gate searches plans, summaries, modified files and the phase's commit messages, and is "Always `blocking:false`" ([src/gate-decision-coverage-verify.cts, next e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/src/gate-decision-coverage-verify.cts)).
- A decision is exempt if it sits under the Discretion heading or carries one of the three non-trackable tags ([src/decisions.cts, next e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/src/decisions.cts)).
- A `one-way` decision gets a `checkpoint:decision` before the task that implements it ([CHANGELOG.md, next e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/CHANGELOG.md)).
- The parser was reworked several times because "the coverage gate passed vacuously" (#1665, #1386, #1343) ([CHANGELOG.md, next e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/CHANGELOG.md)).
- Inferred: coverage means a mention, not proof of implementation, from the matcher and the surfaces searched.

### OpenSpec `### D1` proposals

The brief calls these changes open; two of the three are not.

- PR #2113 proposed stable IDs "such as `D1`, `D2`, and `D3`", linked as `[D1](./design.md#d1)`, and closed unmerged on 2026-10-29 (tested 2026-11-28: `gh pr view 2113 -R Fission-AI/OpenSpec --json closedAt,mergedAt`).
- A maintainer objected on 2026-10-28: "This is probably too verbose for most folks." and "We're also worried agents will invent alternatives that weren't considered." ([OpenSpec PR #2113](https://github.com/Fission-AI/OpenSpec/pull/2113)).
- Issue #2167, open, proposes "**Decisions are a `### D1` heading plus one or two sentences.**" with no Rationale or Alternatives fields (tested 2026-11-28: `gh issue view 2167 -R Fission-AI/OpenSpec`).
- #2167 refuses duplicate IDs, "which catches two parallel changes picking the same number", and reports that "agents kept IDs in 264 of 265 runs" (same command).
- #2134 is a draft PR marked "Reference only ... This PR will not be merged or reworked." (tested 2026-11-28: `gh pr view 2134 -R Fission-AI/OpenSpec --json state,isDraft`).
- Its beta rule: "Keep a decision's ID when you reword or reorder it, never reuse a removed one, and list an alternative only if someone raised it." (tested 2026-11-28: `gh api --method GET "repos/Fission-AI/OpenSpec/contents/skills/openspec-beta/references/decisions.md?ref=claude/openspec-skills-overhaul-1e6c68"`).
- The CLI side, PR #1979, is open and unmerged (tested 2026-11-28: `gh pr view 1979 -R Fission-AI/OpenSpec --json state,mergedAt`).
- Inferred: no stable decision ID format has shipped in OpenSpec as of 2026-11-28, from the state findings above.

## How do mattpocock/skills `prototype` and `to-questionnaire`, obra/superpowers `finishing-a-development-branch` and BMAD-METHOD `bmad-code-review` record or read decisions, and what do MADR's ADR-0006 and ADR-0009 define for naming and links between records?

**The four skills**

- `prototype` rule 6: "Capture the answer too (the verdict and the question it settled) in the issue or a commit." It names no ADR ([skills/engineering/prototype/SKILL.md, main 2026-11-27](https://github.com/mattpocock/skills/blob/main/skills/engineering/prototype/SKILL.md)).
- Rule 6 dates from 2026-07-10 (tested 2026-11-28: `gh api --method GET "repos/mattpocock/skills/commits?path=skills/engineering/prototype/SKILL.md"`).
- `to-questionnaire` writes only the blank questionnaire to `to-questionnaire-<slug>.md` and stores no answers ([skills/productivity/to-questionnaire/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/productivity/to-questionnaire/SKILL.md)).
- `finishing-a-development-branch` writes no file and gives no commit-message rules; a PR follows "the repo's PR template and conventions if present" ([skills/finishing-a-development-branch/SKILL.md, main 2026-11-03](https://github.com/obra/superpowers/blob/main/skills/finishing-a-development-branch/SKILL.md)).
- `bmad-code-review` names no ADRs, decision records or spine (tested 2026-11-28: `grep -rniE 'adr|decision|architect|spine|conflict|contradict' skills/method/bmad-code-review`).
- It reaches them only through the plan's `context:` list, cited ticket files, or `persistent_facts` added by customization ([step-01-gather-context.md, main 2026-11-12](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/method/bmad-code-review/step-01-gather-context.md); [customize.toml](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/method/bmad-code-review/customize.toml)).
- A choice that needs the human's intent goes to `decision_needed`: "Do not guess and patch" ([step-04-route.md](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/method/bmad-code-review/step-04-route.md)).

**MADR ADR-0006 and ADR-0009 at 4.0.0**

- ADR-0006 is about options inside one record, not file names: "Chosen option: 'Repeat all option names if they occur'" ([docs/decisions/0006-use-names-as-identifier.md, 4.0.0](https://github.com/adr/madr/blob/4.0.0/docs/decisions/0006-use-names-as-identifier.md)).
- Before commit #78 (2022-09-28), ADR-0006 named the opposite option as chosen (tested 2026-11-28: `git -C madr show 01c769f`).
- ADR-0009 puts links to other ADRs in "More Information" as free Markdown links, accepting that "parsing gets harder" ([docs/decisions/0009-support-links-between-adrs-inside-an-adrs.md, 4.0.0](https://github.com/adr/madr/blob/4.0.0/docs/decisions/0009-support-links-between-adrs-inside-an-adrs.md)).
- Inferred: MADR 4.0.0 gives links between records no typed fields such as supersedes, from ADR-0009 and the template's "Links to other decisions ... might appear here as well" ([template/adr-template.md, 4.0.0](https://github.com/adr/madr/blob/4.0.0/template/adr-template.md)).

## What do published ADR sources (Michael Nygard's 2011 post, MADR, adr.github.io and the templates it lists) define for the bar, fields, statuses, numbering, layout and superseding, and where do they agree or differ?

**Michael Nygard, 2011-11-15**

- The bar is architecturally significant decisions, "those that affect the structure, non-functional characteristics, dependencies, interfaces, or construction techniques" ([Nygard, 2011-11-15](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions)).
- The parts are title, context, decision, status and consequences, with "All consequences ... not just the "positive" ones" ([Nygard](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions)).
- A decision is "proposed" until stakeholders agree, then "accepted", and later may be "deprecated" or "superseded" with a reference to its replacement ([Nygard](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions)).
- "ADRs will be numbered sequentially and monotonically. Numbers will not be reused.", in `doc/arch/adr-NNN.md` ([Nygard](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions)).
- "If a decision is reversed, we will keep the old one around, but mark it as superseded." ([Nygard](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions)).

**MADR 4.0.0, 2024-09-17**

- 4.0.0 is still the latest release (tested 2026-11-28: `gh api --method GET repos/adr/madr/releases/latest`).
- The bar: "any (important) decision should be captured in a structured way" ([MADR docs/index.md, 4.0.0](https://github.com/adr/madr/blob/4.0.0/docs/index.md)).
- Optional front matter holds `status` (`proposed | rejected | accepted | deprecated | … | superseded by ADR-0123`), `date`, `decision-makers`, `consulted` and `informed` (tested 2026-11-28: `gh api --method GET "repos/adr/madr/contents/template/adr-template.md?ref=4.0.0"`).
- The full template adds Decision Drivers, Considered Options, Confirmation and Pros and Cons; the minimal one keeps Context, Considered Options and Decision Outcome (same command, and the same for `adr-template-minimal.md`).
- Files go to `docs/decisions/NNNN-title-with-dashes.md`, "where `NNNN` indicates the next number in sequence" ([MADR docs/index.md, 4.0.0](https://github.com/adr/madr/blob/4.0.0/docs/index.md)).
- With category subfolders, "numbers of ADRs are no longer unique throughout the repository" (same file).
- Open upstream issues ask how to record updates to an ADR (#238) and whether status values are case-sensitive (#228) ([adr/madr #238, 2026-10-22](https://github.com/adr/madr/issues/238); [adr/madr #228, 2026-07-16](https://github.com/adr/madr/issues/228)).

**adr.github.io and the Henderson collection**

- adr.github.io defines an ADR as capturing "a single AD and its rationale", and covers no statuses, numbering or superseding ([adr.github.io, footer © 2026](https://adr.github.io/)).
- Its templates page lists MADR, Nygard, Y-statement, the cards42 card and the ISO/IEC/IEEE 42010 template ([adr.github.io/adr-templates, updated 2026-11-02](https://adr.github.io/adr-templates/)).
- Zimmermann's significance test, linked from it, gives seven criteria, such as "has a cross-cutting nature" ([Zimmermann, 2020-09-24](https://www.ozimmer.ch/practices/2020/09/24/ASRTestECSADecisions.html)).
- Henderson names files with "a present tense imperative verb phrase", such as `choose-database.md`, with no number ([index.md, en-001, main 2026-11-21](https://github.com/architecture-decision-record/architecture-decision-record/blob/main/locales/en-001/index.md)).
- It advises "Immutable: Don't alter existing information in an ADR", then reports "In practice, mutability has worked better for our teams", adding date-stamped notes (same file).

**Where they agree and differ**

- Inferred: every source holds one decision per record, from the Nygard, adr.github.io and Henderson findings.
- Inferred: Nygard and MADR number records, and Henderson does not, from the numbering findings.
- Inferred: only MADR gives a field for the people involved, from the front matter finding and the other templates read.
- Inferred: on editing, Nygard keeps reversed records, MADR's `date` ("when the decision was last updated") assumes edits, and Henderson advises immutability but edits in practice, from the findings above.

## Open questions

- Whether BMAD's `dev` branch still has spine `AD-n` blocks, memlog-based rationale and the `[ADOPTED]` tags after #3210 and #3264. `dev`'s `bmad-architecture` and `bmad-facilitate` were not read, and the BMAD row describes `main` at 2026-11-12.
- Whether the facts read on default branches are in the named releases. Nobody diffed OpenSpec `main` against v2.2.0, gsd-core `next` against v1.23.0, or mattpocock `main` against v1.3.2.
- Whether gsd-core keeps `D-NN` IDs stable when "Update it" rewrites `CONTEXT.md`. No source states it, and it was not tested.
- Whether OpenSpec PR #1979 parses `### D1` decision headings, or only requirement IDs. Its diff was not read.
- What the third-party ADR extensions hold: spec-kit's `adrkit` and `spec-kit-deliberate`, and OpenSpec's `intent-driven` schema. They sit outside the seven repositories and were not read.
- Reports worded without the search terms, such as "settled", "agreed" or "spec", were not searched for.

## Method

- The owner did not confirm the brief and delegated the check to the orchestrating session, which changed nothing.
- Notes 1 covered obra/superpowers and mattpocock/skills from clones.
- Notes 2 covered google/elephant-goldfish-model and github/spec-kit from clones.
- Notes 3 covered Fission-AI/OpenSpec and open-gsd/gsd-core from clones.
- Notes 4 covered BMAD-METHOD on `main`, the v6.12.4 tag and `dev`.
- Notes 5 searched the seven issue trackers and discussions by relevance through GraphQL, after the REST search hit its rate limit.
- Notes 6 covered Nygard, MADR, adr.github.io and the Henderson collection.
- Notes 7, 8 and 9 answer sub-questions 7, 8 and 9, which were added after confirmation.
- Every check was read-only: `gh` API calls and shallow `git clone`s of public repositories.
- A checker, on 2026-11-28, reread the sources behind the Answer and the table, the issue states and quotes it cites, and each tool's latest release, which matched `versions`. It narrowed the supersede-link, gsd-core ADR count, open-issues and spec-kit claims and the #754 speaker. It did not reach the sub-questions on `--auto`, OpenSpec `### D1`, the four skills and MADR ADR-0006 and ADR-0009 beyond the Answer's use of them.
