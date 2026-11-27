# How the reference repositories and v1 record decisions

None of the seven reference repositories ships a dedicated skill that records one decision as one numbered file. mattpocock/skills comes closest, with an ADR format inside its `domain-modeling` skill. Our v1 had the direct equivalent and shows how it failed in use: 29 records in 18 days, and 14 of them superseded in whole or in part. For our `record-decision`, the sources mostly confirm the design: a strict bar, Proposed versus Accepted, and append-only records. They add a sharper bar test, honesty rules for missing reasons and alternatives, and a path from Proposed to Accepted that our skill lacks.

Sources and method: shallow clones at HEAD, read on 2026-11-26, with nothing executed. One fresh-context sub-agent read each source. obra/superpowers `22f0b46`, mattpocock/skills `6f7f783`, google/elephant-goldfish-model `4693375`, github/spec-kit `f201054`, Fission-AI/OpenSpec `f1cd852`, open-gsd/gsd-core `26429a6`, bmad-code-org/BMAD-METHOD `e435a22`. v1 was read at tag `v1-final` (`99cb269`) with `git show` and `git grep`. Our skill is `skills/record-decision/SKILL.md` with `templates/decision.md`. Paths are relative to each repository. `[read]` marks a claim an agent saw in a file. `[inferred]` marks a conclusion. Two claims were re-checked by hand: the v1 status counts, and the mattpocock and BMAD bar wording.

## Per-source findings

### obra/superpowers

No decision-record skill exists, and "ADR" and "supersede" appear in no skill `[read: grep over skills/]`.

- **Decisions live in the brainstorming design doc.** Its Approaches part holds the options, their trade-offs, the human's pick and why `[read: skills/brainstorming/SKILL.md:219-222]`. Docs are dated, not numbered: `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` `[read: :245-248]`.
- **Agent calls are kept apart from user agreement.** "Any choice you make goes in the design as your call" `[read: :128-129]`. "Approval covers what you showed them" `[read: :293]`.
- **Execution rulings are one line each**: what was decided, why, and "what it costs if wrong" `[read: skills/executing-plans/SKILL.md:32-37]`. The final message lists every ruling, then the ledger is deleted `[read: skills/subagent-driven-development/references/final-review.md:34-47]`.
- **There is no bar.** Rulings say "Record every decision" `[read: skills/executing-plans/SKILL.md:34]`. Spec status values are free text, such as "Proposed", "Draft" and "approved by Jesse (in-session)" `[read: docs/superpowers/specs/*.md headers]`.
- **Readers respect earlier decisions.** Code review stops when feedback conflicts with the human's prior decisions `[read: skills/receiving-code-review/SKILL.md:82-84]`.

### mattpocock/skills

ADRs are one subsection of `domain-modeling`, "Offer ADRs sparingly" `[read: skills/engineering/domain-modeling/SKILL.md:66-74]`, with the format in `ADR-FORMAT.md`.

- **The bar has three tests, all required**: hard to reverse, "Surprising without context", and a real trade-off `[read: ADR-FORMAT.md:29-37]`.
- **A list of what qualifies makes the bar concrete** `[read: ADR-FORMAT.md:39-47]`. It covers architectural shape, integration patterns, lock-in technology, boundaries, deliberate deviations, constraints not visible in code, and non-obvious rejections.
- **The skill offers and does not write by default.** A refusal names the failed test `[read: docs/engineering/domain-modeling.md:39,79]`. "most sessions produce none" `[read: docs/engineering/grill-with-docs.md:39]`.
- **The template is minimal**: a title and one to three sentences. Status, options and consequences are optional `[read: ADR-FORMAT.md:9-23]`. Records live in `docs/adr/NNNN-slug.md`, numbered from the highest existing one `[read: ADR-FORMAT.md:3,27]`.
- **Nothing ties status to the user.** The status enum has no owner `[read: ADR-FORMAT.md:17-23]`.
- **The repository's own records ignore the format.** `.agents/adr/0002` amends itself with three dated "Update" sections and has no status `[read: .agents/adr/0002-*.md:7-53]`.
- **Readers flag conflicts.** Consumer skills read ADRs in the area they touch and write "Contradicts ADR-0007" instead of overriding `[read: skills/engineering/setup-matt-pocock-skills/domain.md:47-51]`.
- **Users asked to split ADRs out of the domain skill** (issue #557, open) `[read: docs/engineering/domain-modeling.md:66-67]`. Naming another skill in prose "does not reliably cause it to load" `[read: CHANGELOG.md:85-87]`.

### google/elephant-goldfish-model (EGM)

No decision records exist. Decisions live in a feature design doc with an Alternatives section, written by `egm-draft` `[read: skills/egm-draft/references/design_doc.md:89-100]`.

- **The author decides.** For a choice with "more than one defensible answer", the agent shows up to three options with the conditions under which each fails, and does not rank them. Mechanical choices with one answer the agent makes itself `[read: skills/egm-draft/SKILL.md:63-71]`.
- **Rejections are attributed**: "Rejected by author: [technical rationale]", never an invented authority `[read: skills/egm-draft/SKILL.md:209-213]`.
- **The hand-over is re-read from the file**, because drafting "often runs in a new session" `[read: skills/egm-draft/SKILL.md:203-206]`.
- **Contradictions go to the user.** On finalize, draft compares the brief with the doc and lets the user settle each contradiction; it never quietly aligns `[read: skills/egm-draft/SKILL.md:257-275]`.
- **Status is a template enum** (Draft, Proposed, In Review, Approved). Real docs drifted to free text such as "Implemented by merged #137" `[read: docs/designs/*.md:3-4]`.
- **Harness-specific front matter.** Skills carry `disable-model-invocation` and `license` and name `ask_question` `[read: skills/egm-draft/SKILL.md:1-10,76-80]`.

### github/spec-kit

Core spec-kit has no ADR command. ADRs exist only as a community extension that needs an external CLI `[read: extensions/catalog.community.json:57-88]`.

- **The constitution is one living, versioned file**, overwritten in place. MAJOR, MINOR and PATCH bumps depend on whether a principle is removed, added or reworded `[read: templates/commands/constitution.md:100-104,127]`.
- **A Sync Impact Report** at the top lists the version change, the changed sections and deferred TODOs, and is removed before commit `[read: constitution.md:112-119]`.
- **Unknown facts become `TODO(<FIELD_NAME>): explanation`**, not guesses `[read: constitution.md:144]`.
- **`research.md` entries have three bullets**: Decision, Rationale, Alternatives considered. They have no ID, no status and no bar beyond "NEEDS CLARIFICATION" items `[read: templates/commands/plan.md:114-135]`.
- **Complexity Tracking justifies each deviation** against a rejected simpler alternative `[read: templates/plan-template.md:106-112]`.
- **Values may be inferred "from existing repo context"** with no marker `[read: constitution.md:98]`.

### Fission-AI/OpenSpec

There is no decision store. The nearest thing is the Decisions section of a per-change `design.md` `[read: schemas/spec-driven/schema.yaml:164-197]`.

- **The bar decides whether a design doc is written at all**, not whether one decision qualifies. The triggers are a cross-cutting change, a new dependency, or migration complexity `[read: schema.yaml:171-175]`.
- **Open questions are "not decisions you skipped".** One that would change the approach goes to the user now `[read: schema.yaml:183-188]`.
- **Restating is forbidden**: "point to them instead" `[read: schema.yaml:190-195]`.
- **Capture is offered, never automatic.** Explore asks "Capture it in design.md?", and answers to design questions "are never consent to write" `[read: skills/openspec-explore/SKILL.md:14,186-196]`.
- **No ID, no status, no supersede.** Designs are edited in place and archived per change, never promoted to a project-level store `[read: docs/concepts.md:311-314,545-557]`. Rationale ends up scattered across dated archive folders `[inferred]`.
- **Verify checks the code against recorded decisions** and warns "Design decision not followed" `[read: skills/openspec-verify-change/SKILL.md:146-153]`.

### open-gsd/gsd-core (GSD)

Decisions spread across three planning files: a PROJECT.md Key Decisions table, a per-phase CONTEXT.md `<decisions>` block, and a discussion log `[read: gsd-core/templates/project.md:67-73; workflows/discuss-phase/templates/context.md:55-87]`.

- **Key Decisions is a table with no ID or status.** Its columns are Decision, Rationale and Outcome (Good, Revisit, Pending). Outcomes are reviewed when a phase ends `[read: templates/project.md:67-73; workflows/transition.md:253-255]`.
- **Phase decisions are numbered D-01, D-02**, restarting in every phase `[inferred from template]`. Planners treat them as "NON-NEGOTIABLE" and must cite the ID `[read: agents/gsd-planner.md:28,59]`.
- **Reversibility is rated** reversible, costly or one-way. "When unsure, rate it `reversible`", to avoid "checkpoint fatigue" `[read: references/planner-reversibility.md:25-28]`.
- **Decisions found in code carry evidence.** Each gets a confidence rating and what happens if it is wrong `[read: workflows/discuss-phase-assumptions.md:32-33,324]`. Under `--auto`, unclear items still become locked decisions without the user `[read: :407-410,458]`.
- **Contributor ADRs** in `docs/adr/` use Accepted, Proposed, Superseded, Retired and Legacy. Supersede links must exist on both records, and amendments append a dated section `[read: docs/adr/README.md; docs/contributor-standards.md:107-126]`.
- **Local next-number counting collided**: 0010 exists twice and 0011 three times, so names moved to issue numbers `[read: docs/adr/README.md; CONTRIBUTING.md:83-100]`.

### bmad-code-org/BMAD-METHOD

There is no first-party record-decision skill. Decisions appear in four places:

- **Architecture spine.** `bmad-architecture` writes numbered `AD-n` blocks with Binds, Prevents and Rule fields. Its bar is "could they choose incompatibly?", plus non-obvious and a real trade-off `[read: skills/method/bmad-architecture/SKILL.md:13; assets/spine-template.md:33-39]`. Updates amend a Rule in place `[read: SKILL.md:87]`.
- **Generic ADR template.** Its statuses are proposed, accepted, rejected, deprecated and superseded, plus who decided and when; "The user must pick" `[read: skills/method/bmod-method/doc-templates/template-decision-record.md:33]`. It asks the agent to "advocate for every option not chosen" and to think of the person who inherits the decision `[read: :42,48]`. A superseded record "is not rewritten beyond its status" `[read: :25]`.
- **Retrospective and recon proposals.** They use the same three tests as mattpocock and skip anything an existing ADR records `[read: skills/method/bmad-retrospective/references/acceptance-verdict.md:23]`. When no source gives the reason, "the record says so" `[read: :23]`. Recon shows decisions found in history with the commit as evidence `[read: skills/core-tools/bmad-deep-recon/references/codebase.md:31]`.
- **A toolsmith sample skill** named `decision-record`. Its triggers match ours almost word for word, and it shows the draft and waits before writing `[read: skills/toolsmith/bmad-toolsmith/shapes/plain-skill/assets/sample-skill/SKILL.md:3,16-20]`.
- **Machinery around the spine**: `lint_spine.py`, a memlog and `uv` `[read: SKILL.md:39-40; scripts/lint_spine.py:13-16]`.

### Our v1 (`v1-final`)

v1 had a direct equivalent, `skills/record-decision/` with `templates/decision-record.md`, and 29 real records in `docs/decisions/`.

- **The bar was "contested, consequential, and not obvious from the code"**, with "twenty a year means the bar slipped" `[read: v1-final:workflow/artifacts.md:150-153]`. It lived in a workflow doc, not in the skill.
- **Interview before drafting.** "Never draft a record from inference", and an invented alternative "fabricates a debate that never happened" `[read: v1-final:skills/record-decision/SKILL.md:20-34]`.
- **The template** used YAML front matter (`date`, `status`, `areas`, `supersedes`, `superseded_by`). Its sections were Context, Decision, Rejected, Costs and Revisit if `[read: v1-final:skills/record-decision/templates/decision-record.md:1-67]`. Every record was born `accepted`; no Proposed status existed `[read]`.
- **Partial supersession was allowed**, recorded in front matter `[read: v1-final:skills/record-decision/SKILL.md:67-77]`.

How the records turned out:

- **Volume broke the bar.** 29 records from 2026-08-08 to 08-25 `[read: git ls-tree]`, far past the skill's own alarm of twenty a year `[inferred]`.
- **Half were overturned.** 15 accepted, 10 partially superseded, 4 superseded `[read: counted with git show and grep on status lines]`.
- **`superseded_by` grew into prose of up to 8 lines**, so what still holds takes a chain to trace `[read: v1-final:docs/decisions/2026-08-20-land-worktree.md:3-11]`.
- **Records doubled in length**, from about 250–400 words early to 450–750 later `[read]`.
- **Two ID schemes ran side by side.** Date-slug file names, plus hand-numbered H1s that stopped on 08-18 `[read: v1-final:docs/decisions/2026-08-10-decisions-not-adr.md:7]`.
- **Format drift could not be repaired**, because records were immutable `[read: v1-final:work/backlog.md:29-33]`.

`2026-08-10-decisions-not-adr.md` widened the folder to any decision, not only architecture. Its reason: process and tooling decisions are the ones most often left unrecorded `[read: :11-28]`. It named the cost: the junk-drawer risk "must now be held by discipline instead". The history above shows that discipline failing `[inferred]`.

## Comparison

| Source | Where decisions live | ID | Bar for a record | Statuses | Who accepts | Supersede or amend |
| --- | --- | --- | --- | --- | --- | --- |
| Ours | `docs/decisions/NNNN-slug.md` | `D-NNNN` | Hard to reverse, more than one feature, real alternative | Accepted, Proposed, Superseded by | The user, in the conversation | New record; old Status line changes |
| superpowers | Dated design doc; rulings ledger | None | None; "record every decision" for rulings | Free text | Human approves the doc | None |
| mattpocock | `docs/adr/NNNN-slug.md` in `domain-modeling` | `ADR-NNNN` | Hard to reverse, surprising, real trade-off | Optional enum | Not stated | Enum only; own records amend in place |
| EGM | Feature design doc | None | More than one defensible answer | Enum, drifted | The author picks | None |
| spec-kit | Constitution; `research.md` | Semver on the constitution | None for research | None | Maintainers, not recorded | Overwrite in place |
| OpenSpec | Per-change `design.md` | None | Per document, not per decision | None | Consent to write only | Edit in place; archive |
| GSD | PROJECT.md table; phase CONTEXT.md | `D-01`, per phase | "Constrain future work" | Outcome markers | User in discussion; `--auto` locks without | Later phase overrides |
| BMAD | Spine `AD-n`; `adr-*.md` | `AD-n`; none for ADRs | Three tests, as mattpocock | Five values plus who | The user must pick | ADR: new record; spine: amend |
| v1 | `docs/decisions/YYYY-MM-DD-slug.md` | Date, briefly a number | Contested, consequential, not obvious | accepted, (partially-)superseded | Implied by interview and commit | New record; front matter on old |

## Recommendations

Each item gives what to do, why, and the source. Items marked "other skills" belong in the skills that read records, not in `record-decision`.

### Adopt

- **Add "surprising without context" to the bar.**
  - Why: mattpocock, BMAD and v1 converge on it independently. It is the test that stops records nobody would ever look for.
  - Source: `mattpocock ADR-FORMAT.md:29-37`; `BMAD acceptance-verdict.md:23`; `v1 workflow/artifacts.md:150-153`.
  - Open: whether it replaces "affects more than one feature" or joins it is the owner's call, since `docs/workflow-design.md` holds the bar as Assumed.
- **Give a short list of what qualifies.**
  - Why: it makes the bar concrete in a few lines.
  - Source: mattpocock `ADR-FORMAT.md:39-47`.
- **Name the failed test when the bar fails.**
  - Why: the user can disagree with a named test.
  - Source: mattpocock `docs/engineering/domain-modeling.md:79`.
- **Never invent an alternative or a reason; say so when none was given.**
  - Why: v1 and BMAD both found that an invented reason is later read as the team's. It also protects our "real alternative" test.
  - Source: v1 `SKILL.md:20-34`; BMAD `acceptance-verdict.md:23`.
- **Add a path from Proposed to Accepted.**
  - Why: the guardrail lets an existing record change only to Superseded, so a Proposed record can never become Accepted. A Status-line edit after the user accepts would do it.
  - Source: gap found by the v1 agent `[inferred]`; GSD requires a dated ratification `[read: docs/adr/README.md]`.
- **Accept only what the user saw as written.**
  - Why: it closes the gap where the user agreed to a summary and the record says more.
  - Source: superpowers `skills/brainstorming/SKILL.md:293`.
- **Make Consequences name the concrete cost of change and what would reopen the decision.**
  - Why: v1's "Revisit if", superpowers' "cost if wrong" and GSD's reversibility rating all ask for it. One line covers it.
  - Source: v1 template; superpowers `executing-plans/SKILL.md:35`; GSD `planner-reversibility.md`.
- **Cite the evidence for a decision found in code**, such as the file or the commit.
  - Why: a Proposed record from code must be checkable before the user accepts it.
  - Source: BMAD `codebase.md:31`; GSD `discuss-phase-assumptions.md:32-33`.
- **Ask the user before superseding.** When a new decision contradicts an Accepted record, the user decides; never align quietly.
  - Why: step 2 finds the overlap but the skill does not say who settles it.
  - Source: EGM `skills/egm-draft/SKILL.md:257-275`.
- **State the expected outcome: declining is normal.**
  - Why: v1's records broke its own volume alarm within weeks. The reason belongs in the skill.
  - Source: v1 `SKILL.md:18`; GSD `planner-reversibility.md:25-28`; mattpocock `grill-with-docs.md:39`.

### Consider

- **Record a durable rejection when it passes the bar.**
  - Why: mattpocock counts non-obvious rejections as qualifying, and they stop agents re-suggesting a lost option. Our skill writes no record on rejection.
  - Against: v1 recorded only durable choices, never mere rejections `[read: v1-final:workflow/artifacts.md:96-98]`.
- **Allow partial supersession in one line**, such as `Superseded in part by D-0009 (retry policy)`.
  - Why: v1 needed it 10 times. Its front-matter prose grew to 8 lines.
  - Source: v1 `SKILL.md:67-77`.
- **Add a soft length limit**, about one page.
  - Why: v1's records doubled in length.
  - Source: BMAD `template-decision-record.md:18`; v1 record lengths.
- **List every Proposed record in the report**, so the user can accept or reject them in one pass.
  - Why: superpowers' "Rulings I made" list does this for rulings.
  - Source: superpowers `final-review.md:34-47`.
- **Guard against number collisions across parallel branches.**
  - Why: GSD hit duplicate numbers with local next-number counting. Our sessions run in parallel worktrees `[inferred]`.
  - Source: GSD `docs/adr/README.md`.
- **Have each alternative state when it would win or fail.**
  - Why: it shows the dissenter their case was weighed.
  - Source: EGM `SKILL.md:63-71`; BMAD `template-decision-record.md:42`.
- **Other skills: read Accepted records and flag a conflict** as "Contradicts D-NNNN" instead of overriding.
  - Source: mattpocock `domain.md:47-51`; OpenSpec `verify-change/SKILL.md:146-153`; superpowers `receiving-code-review/SKILL.md:82-84`.
- **Other skills: pass a hand-over as content in a file, and re-read it.**
  - Why: naming a skill in prose does not reliably load it. A file survives a new session.
  - Source: mattpocock `CHANGELOG.md:85-87`; EGM `SKILL.md:203-206`.

### Avoid

- **A bar per document, or no bar.**
  - Why: OpenSpec gates whole docs, and superpowers rulings and spec-kit research record everything. Either lets routine choices through.
  - Source: OpenSpec `schema.yaml:171-175`; superpowers `executing-plans/SKILL.md:34`; spec-kit `plan.md:116-128`.
- **Locking decisions the user never accepted.**
  - Why: GSD `--auto` and spec-kit's inferred constitution values both do it. It breaks our Accepted rule.
  - Source: GSD `discuss-phase-assumptions.md:407-410`; spec-kit `constitution.md:98`.
- **Editing a decision in place.**
  - Why: the reason for the old choice is lost. Seen in OpenSpec designs, the BMAD spine and mattpocock's own ADR.
  - Source: OpenSpec `concepts.md:311-314`; BMAD `SKILL.md:87`; mattpocock `.agents/adr/0002`.
  - Note: GSD's dated amendment section keeps the trace. It is still a body edit, against our rule.
- **Free-text statuses.**
  - Why: they drifted in superpowers and EGM.
- **YAML front matter, an `areas:` taxonomy and date-slug names on records.**
  - Why: in v1 they drifted, could not be fixed, and ran beside a second ID scheme.
  - Source: v1 template; v1 `work/backlog.md:29-33`.
- **IDs that restart per phase or per document.**
  - Why: `D-01` in two phases names two decisions.
  - Source: GSD context template.
- **Lint scripts, a CLI or a memlog** to enforce the lifecycle.
  - Why: they break our no-scripts constraint.
  - Source: BMAD `lint_spine.py`; GSD ADR checks; OpenSpec CLI.
- **Harness-specific front matter and tool names.**
  - Why: they break under Codex.
  - Source: EGM `disable-model-invocation`, `ask_question`; v1 `allowed-tools`, `${CLAUDE_PLUGIN_ROOT}`.
- **Bundling decision records into a glossary or domain skill.**
  - Why: mattpocock's users ask for the split, and our separate skill already has it.
  - Source: mattpocock issue #557.
- **Banning the agent from recommending.**
  - Why: EGM forbids it, but our Proposed status exists for agent suggestions.
  - Source: EGM `SKILL.md:63-71`.
