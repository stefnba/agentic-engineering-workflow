# Review angles for spec review and code review

For a reader designing spec-review and code-review skills: how the reference projects review a spec and review code. This file holds facts about those sources only.

Sources and method: skill, persona and prompt files read from nine public repositories through the GitHub API on 2026-11-26, plus Google's code review guide. A claim is read from the named file unless it carries "(inferred)". The section "Not found or not read" lists the gaps.

## Summary

The reference repositories ask different questions of a spec and of code. Their spec reviews ask whether a stranger can build the spec and whether it is the right, smallest thing (inferred). Their code reviews ask whether the code is what was asked and whether it is built correctly (inferred).

Claude Code's plugin and Codex's rubric cover only the second half of the code question. Pocock's set, the Claude Code plugin and the Codex rubric hold no spec review step.

## Comparison across the repositories

Each row names what the repository reviews and how. "None" means the files read hold no such step.

| Repository                                                | Spec or plan review                                                                                                                                                                            | Code review                                                                                     | Reviewer isolation                                              | Severity tags                                                               | Resolution and rounds                                                                           | Human decides                                       |
| --------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| EGM (`google/elephant-goldfish-model`)                    | Five stages, eight personas, four document standards (sibling file `knowledge-across-skills.md` counts ten persona files and five standards in the repository; the difference was not checked) | `egm-lite` diff review, five rubric items                                                       | Fresh sub-agent per persona; stops if the harness has none      | Blocker, Major, Nit; `egm-lite` uses P0 to P3                               | Author session classifies each finding; one re-audit per stage, or a loop capped at five rounds | A gate after every stage; which fixes to apply      |
| Pocock (`mattpocock/skills`)                              | None; the user is questioned before `to-spec` (inferred)                                                                                                                                       | Two parallel reviewers: Standards and Spec                                                      | Fresh sub-agent per axis                                        | None; hard violation or judgement call                                      | One fix pass by a fresh implementer; no re-review                                               | Seams before the spec; the final PR                 |
| Superpowers (`obra/superpowers`)                          | One "builder check" on the design; plan self-review by the author                                                                                                                              | One task reviewer with two verdicts; one whole-branch reviewer at the end                       | Fresh sub-agent given files, never session history              | Critical, Important, Minor                                                  | Up to five fix rounds per task with a scoped re-review; one fix wave after the final review     | Design, plan, and the controller's recorded rulings |
| Spec Kit (`github/spec-kit`)                              | `clarify`, `checklist`, `analyze` across spec, plan and tasks                                                                                                                                  | `converge` compares code to spec and appends tasks; no bug review                               | None stated; runs in the working session (inferred)             | Critical, High, Medium, Low                                                 | Read-only report; the user approves any edit                                                    | Whether to proceed with open checklist items        |
| OpenSpec (`Fission-AI/OpenSpec`)                          | Human reads proposal, spec deltas, tasks; a two-minute checklist                                                                                                                               | `verify`: completeness, correctness, coherence against the change                               | None stated (inferred)                                          | Critical, Warning, Suggestion                                               | Report only; does not block archiving                                                           | Everything; the review is the human's               |
| GSD (`open-gsd/gsd-core`)                                 | `gsd-plan-checker`, twelve-plus dimensions; optional cross-AI plan review                                                                                                                      | `gsd-code-reviewer` for bugs, security, quality, necessity; `gsd-verifier` for goal achievement | Separate agent per role; other vendors' CLIs as extra reviewers | Blocker, Warning, Info                                                      | Plan check loops up to three times; code fix loop capped at three; a disposition per finding    | Uncertain truths and the end-of-phase checkpoint    |
| BMAD (`bmad-code-org/BMAD-METHOD`)                        | Reviewer gate on the architecture; validation checks on tickets                                                                                                                                | Quick: one reviewer. Thorough: four lenses                                                      | Context-free sub-agent per lens                                 | Reviewers assign none; triage assigns high, medium, low, false, maybe-false | Triage verifies each finding, then routes it to patch, defer, or decision needed                | "Decision needed" items; apply all or walk through  |
| Claude Code plugin (`anthropics/claude-plugins-official`) | None                                                                                                                                                                                           | Four parallel agents: two for `CLAUDE.md` rules, two for bugs                                   | Sub-agents; given PR title and description                      | None; only validated issues survive                                         | One validation sub-agent per issue; unvalidated issues are dropped                              | Whether to post comments                            |
| Codex review (`openai/codex`)                             | None                                                                                                                                                                                           | One rubric: bugs the author would fix                                                           | Not stated in the rubric                                        | P0 to P3, a confidence score, an overall verdict                            | None in the rubric                                                                              | Not stated                                          |

## Notes on EGM

EGM's `egm-review` runs five review stages in order with eight persona files. Each stage controls what the reviewer sees.

| Stage                      | Persona files                                                                         | Standard                               | Reviewer is given                          |
| -------------------------- | ------------------------------------------------------------------------------------- | -------------------------------------- | ------------------------------------------ |
| 5 Initial zoom out         | `agents/zoom_out.md`, `agents/inventive_catalyst.md`                                  | `zoom-out-standard.md`                 | Full document and the context reading list |
| 6 Comprehension            | `agents/comprehension.md`                                                             | None, on purpose                       | The document alone                         |
| 7 Critic                   | `agents/design_critic.md`, `agents/structural.md`, `agents/style.md`                  | `feature-spec-standard.md`             | Feature part and context                   |
| 8 Intermediate zoom out    | `agents/zoom_out.md`                                                                  | `zoom-out-standard.md`                 | Full document, context, the stage 5 report |
| 9 Implementation readiness | `agents/implementation_readiness.md`, `agents/codebase_details.md`, `agents/style.md` | `implementation-readiness-standard.md` | Plan part and context                      |

The stage table is in `skills/egm-review/SKILL.md`. Standards are in `resources/document_standards/`.

What each angle checks:

- **Zoom out**: speculative features, premature optimisation, reinvented utilities, detail at the wrong altitude. The persona must search the code before accepting a new utility.
- **Comprehension**: the reviewer first paraphrases what the document proposes. A section it cannot paraphrase is a Blocker, and a wrong paraphrase is a finding. It flags project terms only, never general engineering terms.
- **Design critic**: unbacked assumptions, unmitigated risks, and gaps against the standard. The feature-spec standard requires rejected alternatives with concrete reasons, and stated risks and limits.
- **Implementation readiness**: the plan must leave the implementer no design decision. It must list exact file paths and specific test cases.
- **Codebase details**: statements about current code that the source contradicts, and references to files or functions that do not exist. Files the plan will create are not findings.
- **Structural and style**: heading hierarchy, template sections, filler, and claims that outrun their evidence.

How findings are handled:

- **Output**: each persona returns severity, affected scope and rationale. `agents/synthesizer.md` deduplicates and writes one report file. It may run two instances of a reviewer to raise recall.
- **Failed reviewers**: a reviewer that returns nothing counts as "not run", never as zero findings.
- **Resolution**: `skills/egm-resolve/SKILL.md` runs in the author's session. It labels each finding CONTEST, ESCALATE, PROPOSE FIX or DECLINE.
- **Limits on the author**: a contest must cite evidence the reviewer could read. A comprehension gap cannot be contested. The author cannot change a severity.
- **Rounds**: `egm-review` allows one re-audit per stage. `skills/egm-review-loop/SKILL.md` calls a document converged after two consecutive rounds without an open Blocker or Major, and caps at five rounds.
- **Human**: chooses per stage to proceed, edit, resolve with the agent, or pause. Chooses per finding in an interactive breakdown.

`skills/egm-lite/SKILL.md` is the small-change path, and it reviews both a checklist and a diff:

- **Spec review**: one fresh reviewer reads the checklist with four rubric items: scope and YAGNI, tagged unverified contracts, edge cases and failure modes, and a runnable test plan.
- **Gate**: it advises the spec review when the change touches two or more production files, concurrency, a public API, or an unverified assumption. Otherwise it calls direct execution reasonable.
- **Diff review**: one fresh reviewer gets the checklist, the change inventory and the full change content. It gets no conversation history and no author justification.
- **Diff rubric**: thread and state safety, boundary conditions, test coverage of new logic, deletable code, and leftover unverified tags checked against the checklist.
- **Contract**: findings only, tagged P0 to P3, or an explicit LGTM on zero findings. Style nitpicks are suppressed.

## Notes on Pocock's skills

Pocock's set has no spec-review skill; `to-spec` synthesises the conversation and confirms test seams with the user (`skills/engineering/to-spec/SKILL.md`). Review happens once, on code.

- **Two axes**: `skills/engineering/code-review/SKILL.md` runs a Standards reviewer and a Spec reviewer in parallel, each in a fresh context.
- **Standards reviewer is given**: the diff command, the repository's standards files, and a baseline of twelve Fowler code smells pasted in full. The repository's documented rule overrides the baseline, and smells are always judgement calls.
- **Spec reviewer is given**: the diff command and the spec. It reports missing or partial requirements, behaviour nobody asked for, and requirements implemented wrongly. Each finding quotes the spec line.
- **No spec, no Spec review**: the skill reports "no spec available" instead of inferring requirements.
- **Output**: two blocks, each under 400 words, never merged or re-ranked. The stated reason is that a passing axis would hide a failing one.
- **Resolution**: `skills/engineering/implement-spec/SKILL.md` runs the review once on the integration branch. One fresh implementer fixes all findings.
- **Author-side rules**: `skills/engineering/tdd/SKILL.md` names three test anti-patterns: implementation-coupled, tautological, and tests written in bulk before code. It defers refactoring to the review stage.
- **Human**: `skills/engineering/pr/SKILL.md` makes the PR body state evidence, whether the merge is a one-way door, and its blast radius.

## Notes on the other five repositories

**Superpowers.** Paths are under `skills/`.

- **Spec**: `brainstorming/builder-check-prompt.md` gives a fresh agent only the design document. It returns ranked questions where a wrong guess would matter. A small change skips the check.
- **Sorting**: the author sorts the questions into answered already, minor, and the human's.
- **Plan**: `writing-plans/SKILL.md` has the author check spec coverage, type consistency, and five untested failure modes. No sub-agent reviews the plan.
- **Task review**: `subagent-driven-development/task-reviewer-prompt.md` gives one reviewer the task brief, binding constraints, the implementer's report and a diff file. It returns a spec verdict (missing, extra, misunderstood), then a quality verdict.
- **Distrust**: the reviewer treats the implementer's report and rationales as unverified claims.
- **Budget**: the reviewer reads the diff once, leaves the diff only for a named risk, and does not re-run the suite.
- **Final review**: `requesting-code-review/code-reviewer.md` adds architecture, security and production readiness. It lists every behaviour the reviewer set aside.
- **Rounds**: `subagent-driven-development/references/fix-loop.md` allows five fix rounds per task. The re-review judges only the listed findings and the fix diff.

**Spec Kit.** Paths are under `templates/commands/`.

- **`clarify.md`**: scans the spec against a taxonomy and asks at most five questions.
- **`checklist.md`**: writes checks on the requirements themselves, tagged completeness, clarity and consistency.
- **`analyze.md`**: runs six read-only passes over spec, plan and tasks: duplication, ambiguity, underspecification, constitution conflicts, coverage gaps, inconsistency. It caps output at 50 findings.
- **`converge.md`**: compares the code to the spec after implementation and appends unmet work as tasks.

**OpenSpec.**

- **`docs/reviewing-changes.md`**: tells the human to ask three questions: right problem, "done" defined testably, sane tasks. It names missing scenarios as the most valuable catch.
- **`skills/openspec-verify-change/SKILL.md`**: checks code against the change in three dimensions. A skipped check is reported as not verified, never as passing.

**GSD.** The default branch is `next`.

- **`agents/gsd-plan-checker.md`**: works backward from the phase goal. Dimensions include requirement coverage, task completeness, dependencies, scope size, scope reduction, and compliance with `CLAUDE.md`. Scope reduction is always a blocker.
- **`agents/gsd-code-reviewer.md`**: covers bugs, security, quality and "necessity", meaning guards against states that cannot occur. Performance is out of scope. It has three depths.
- **`agents/gsd-verifier.md`**: assumes the goal was missed until the code proves otherwise. It does not trust the executor's summary.
- **`docs/features/code-review-pipeline.md`**: describes depth escalation by path prefix and a recorded disposition per finding.

**BMAD.** Paths are under `skills/method/`.

- **Lenses**: `bmad-code-review/customize.toml` defines them. Quick is one reviewer for acceptance criteria, agent rules and bugs.
- **Thorough**: four lenses. A blind hunter gets the diff only. An edge-case hunter traces every branch. A verification-gap reviewer names regressions no test would catch. An intent auditor compares the diff with the verbatim intent.
- **Claims check**: the edge-case hunter reads commit messages only after its trace, then tries to falsify each claim (`bmad-code-review/references/claims-check.md`).
- **Triage**: `bmad-code-review/step-03-triage.md` verifies every finding against the code, discards the lens's severity, and deduplicates by root cause.
- **Spec side**: `bmad-architecture/references/reviewer-gate.md` runs a lint script first, then parallel reviewers scaled to the stakes.

## Claude Code and Codex

**Claude Code plugin.** The file is `plugins/code-review/commands/code-review.md` in `anthropics/claude-plugins-official`.

- **Agents**: two check `CLAUDE.md` compliance, one scans the diff alone for obvious bugs, one looks for logic and security problems in changed code.
- **Bar**: flag only code that will not compile, will give wrong results for any input, or breaks a quotable rule. Style, input-dependent issues and pre-existing issues are excluded.
- **Validation**: a separate sub-agent validates each issue; the rest are dropped.
- **Gap**: it has no check against a spec. The agents get the PR title and description as intent.

**Codex.** The file is `codex-rs/prompts/templates/review/rubric.md` in `openai/codex`.

- **Bar**: flag an issue only if the change introduced it, it is discrete, and the author would fix it. It must not rest on unstated assumptions. Speculation about other code needs the affected code identified.
- **Output**: JSON findings with a P0 to P3 tag and a confidence score, then a verdict that the patch is correct or incorrect. Zero findings is preferred over weak findings.
- **Rules**: findings may cite the applicable `AGENTS.md` lines.
- **Gap**: it has no check against a spec.

## What human teams check

Google's guide (`google/eng-practices`, `review/reviewer/looking-for.md`) lists design, functionality, complexity, tests, naming, comments, style, consistency and documentation. It asks the reviewer to read every line in context. `review/reviewer/standard.md` sets the bar: approve a change that improves overall code health, even if it is not perfect. `review/reviewer/comments.md` marks optional points with a "Nit:" prefix.

For design review, "Design Docs at Google" (industrialempathy.com) structures a design document as context and scope, goals and non-goals, the design, alternatives considered, and cross-cutting concerns. Only its headings were read. EGM's feature-spec standard asks for the same sections.

## Reported weaknesses

Each weakness below is reported by a source file. The third column records what a named source does about it.

| Weakness                              | Where reported                                                                                                                                                                                      | What a source does about it                                                                                         |
| ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Findings never run out                | Pocock `docs/engineering/code-review.md`: reruns always find new issues. EGM `egm-review-loop`: a zero-finding round is rare                                                                        | EGM `egm-review-loop` stops after two rounds with no open Blocker or Major, and caps at five rounds                 |
| Forced findings                       | BMAD's adversarial lens demands a minimum count                                                                                                                                                     | BMAD's triage verifies every finding afterwards                                                                     |
| False positives                       | Pocock docs: a sub-agent finding is a hypothesis and may cite the wrong location                                                                                                                    | Claude Code validates each issue; BMAD triage verifies each finding; Codex needs the affected code identified       |
| Reviewer shares the author's context  | Pocock docs: `implement` reviews inside the authoring session                                                                                                                                       | EGM gives each persona a fresh sub-agent and stops if the harness has none; Superpowers passes files, never history |
| Author's rationale sways the reviewer | Superpowers task-reviewer prompt                                                                                                                                                                    | Superpowers' reviewer treats rationales as unverified claims; BMAD reads commit messages only after the trace       |
| No check against the spec             | Claude Code plugin and Codex rubric have none; EGM's five stages review documents only                                                                                                              | Pocock runs a Spec axis; Superpowers gives a spec verdict; OpenSpec runs `verify`; BMAD runs an intent auditor      |
| Token cost                            | Superpowers design note `docs/superpowers/specs/2026-06-09-sdd-task-scoped-review-dispatch-design.md`: quality reviewers cost four to eight times spec reviewers; a hardened version doubled tokens | Superpowers uses one task reviewer, hands it the diff as a file, and tells it not to re-run the suite               |
| Runaway fan-out                       | Pocock docs: review sub-agents re-invoked the skill, one report above 50 agents                                                                                                                     | Superpowers and BMAD tell the reviewer not to spawn sub-agents                                                      |
| Slow reviews                          | BMAD `bmod-method/help/review-choices.md`: thorough review can take half an hour                                                                                                                    | BMAD offers a quick depth with one reviewer                                                                         |

## Angles found for spec or plan review

Each row is a review angle the sources apply to a spec or a plan.

| Angle                                                  | What it checks or catches                                                                         | Used by                                                                                              |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Comprehension: paraphrase the spec from the text alone | Parts that do not connect, undefined project terms, knowledge the author assumed                  | EGM stage 6; Superpowers builder check                                                               |
| Buildability: list where a builder would have to guess | Vague or untestable requirements, design decisions left to the implementer                        | EGM stage 9; Superpowers builder check; Spec Kit `analyze` and `clarify`; OpenSpec; GSD plan checker |
| Scope and simplicity                                   | Wrong problem, scope creep, speculative features, reinventing existing code                       | EGM stages 5 and 8; `egm-lite`; OpenSpec; GSD plan checker                                           |
| Risk and failure modes                                 | Missing edge cases, error paths, migrations, security implications, unexamined alternatives       | EGM stage 7; `egm-lite`; Spec Kit `clarify`; Superpowers plan self-review                            |
| Grounding and coverage                                 | False statements about current code, non-existent references, requirements with no ticket or test | EGM `codebase_details`; Spec Kit `analyze`; GSD plan checker; BMAD validation checks                 |
| Prose style and document structure                     | Heading hierarchy, template sections, filler, claims that outrun their evidence                   | EGM `structural` and `style` personas, stages 7 and 9                                                |
| Inventive problem-solving                              | Not recorded in the files read                                                                    | EGM `inventive_catalyst` persona, stage 5                                                            |

EGM stage 6 gives its reviewer the document alone, with no context and no standard.

`egm-lite` runs scope, failure modes and test plan as one rubric for one reviewer. No file read compares one reviewer holding several angles with EGM's separate personas.

## Angles found for code review

Each row is a review angle the sources apply to code.

| Angle                                          | What it checks or catches                                                                          | Used by                                                                                                  |
| ---------------------------------------------- | -------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| Spec compliance: missing, extra, misunderstood | The wrong thing built well; scope creep; a requirement claimed but not implemented                 | Pocock Spec axis; Superpowers; BMAD intent auditor; OpenSpec `verify`; Spec Kit `converge`; GSD verifier |
| Correctness in the diff                        | Boundary errors, unhandled error paths, races, call-site mismatches, regressions from deleted code | `egm-lite`; BMAD edge-case hunter; Claude Code; Codex; GSD                                               |
| Tests prove behaviour                          | New logic without a test, tests that assert nothing or restate the code, weakened assertions       | `egm-lite`; BMAD verification-gap lens; Superpowers; Pocock `tdd` on the author side                     |
| Repository rules                               | Breaches of documented standards and agent instruction files                                       | Pocock Standards axis; Claude Code; Codex; BMAD quick lens                                               |
| Simplicity and necessity                       | Abstractions nobody asked for, impossible-state guards, duplication                                | `egm-lite`; Pocock smell baseline; GSD necessity; Google's guide                                         |
| Security and irreversible operations           | Security problems in the change                                                                    | GSD code reviewer; Superpowers final review; Claude Code logic and security agent                        |

## Where the sources differ

- **Rounds**: one pass (Superpowers builder check), one re-audit (EGM stages), or a loop to two clean rounds (EGM review loop).
- **Who triages**: the author session with its context (EGM), or a fresh validator per finding (Claude Code).
- **Severity**: three tiers from the reviewer (EGM, Superpowers), or none from the reviewer and a grade at triage (BMAD).
- **Ticket review split**: one reviewer with two verdicts (Superpowers) or two reviewers (Pocock). Only Superpowers publishes cost and quality numbers, from its own evals.
- **Reading beyond the diff**: forbidden (Claude Code's first bug agent) or allowed per named risk (Superpowers).
- **Duplicate reviewers**: EGM and Claude Code run two instances for recall. The gain is not quantified in any file read.
- **Skipping spec review**: `egm-lite` advises it when the change touches two or more production files, concurrency, a public API, or an unverified assumption. Superpowers skips the builder check for a small change. OpenSpec gives right-sizing advice; its content is not recorded here.

## Not found or not read

- **URLs**: all seven reference repositories resolve. Claude Code's plugin has moved from `anthropics/claude-code` to `anthropics/claude-plugins-official`.
- **Claude Code built-in review**: no public prompt was found for the built-in command, only for the plugin.
- **Codex**: only the rubric file was read, not the documentation of the review feature.
- **False-positive rates**: no repository publishes one.
- **Read in part**: Spec Kit `clarify.md` and `checklist.md`, OpenSpec's verify skill, GSD's three agent files, BMAD's edge-case and verification-gap prompts.
- **Not read**: EGM `egm-drift-report`, `egm-brainstorm` and `docs/designs/lite.md`; GSD workflow files; BMAD `bmad-review` and `step-05-present.md`; Superpowers `receiving-code-review`.
- **Superpowers history**: its tree holds no spec or plan reviewer prompt. Whether earlier versions had one was not checked.
