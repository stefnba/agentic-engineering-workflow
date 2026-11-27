# Glossary handling in seven reference repositories

For the owner revising `skills/update-glossary/`: how the reference repositories record domain terms, and what our skill should take from them.

Only mattpocock/skills has a skill that maintains a repository-wide glossary. The other six have none for the projects they are installed into `[read]`. They keep terms inside one spec or PRD, check terminology at review time, or keep a glossary of their own product by hand. No repository asks the user to confirm each meaning, sorts incoming terms into new, same and conflict, or reports what it changed `[inferred]`. Those parts of our skill have no precedent to copy and none to avoid.

Sources and method: shallow clones of the seven repositories at HEAD, read on 2026-11-26 with `git ls-files`, `grep` and file reads; nothing from the clones was executed. Each repository was read by its own research sub-agent in a fresh context window. Issues were read through `gh`. Six cited lines, one per repository except superpowers, were re-checked against the clones. Paths are relative to each repository. `[read]` marks a claim seen in a file or issue. `[inferred]` marks a conclusion. Our v1 at tag `v1-final` was not read: the permission check of this session refused `git ls-tree v1-final`, and `AGENTS.md` allows reading the tags only when the owner asks.

## Summary

- **One repository has a glossary skill.** Pocock's `domain-modeling` writes a root `GLOSSARY.md` inline during a conversation, one term at a time `[read: skills/engineering/domain-modeling/SKILL.md:62]`.
- **Three keep terms per document.** Spec Kit has Key Entities per spec, BMAD has a Glossary section per PRD, and superpowers has prose in dated design docs `[read]`. BMAD needs a validation pass to keep the copies identical `[read: skills/method/bmad-ux/references/validate.md:35]`.
- **Three check terms only at review time.** EGM's naive reader flags undefined terms, Spec Kit's `analyze` flags terminology drift, and GSD's plan review flags contradicting term use `[read]`.
- **Every source that addresses synonyms says to pick one word.** Pocock, Spec Kit, OpenSpec, GSD and superpowers say so in their own words `[read]`.
- **A contrast with a neighbouring term is common.** Pocock's `_Avoid_` line, OpenSpec's "Not a build output." and GSD's "Contrast with a **prototype**" all play the role of our "Not a receipt" sentence `[read]`.

## Comparison

| Repository        | Glossary for the consuming project               | Entry shape                                     | Synonyms and conflicts                                       | User confirms a meaning                   | When terms are written           | Order                                    |
| ----------------- | ------------------------------------------------ | ----------------------------------------------- | ------------------------------------------------------------ | ----------------------------------------- | -------------------------------- | ---------------------------------------- |
| mattpocock/skills | Yes: root `GLOSSARY.md`, `GLOSSARY-MAP.md` in a monorepo | Bold term, one or two sentences, `_Avoid_` line | Pick one word, others under `_Avoid_`; a conflict is called out at once | Not stated; written "when a term is resolved" | Inline, "Don't batch these up"  | Subheadings, no alphabetical rule        |
| google/EGM        | No; a review persona flags undefined terms       | None                                            | Inconsistent terminology ranks as a Nit                      | No                                        | Never; review only               | None                                     |
| obra/superpowers  | No; meaning lives in dated design docs           | None                                            | One term per concept, for skill prose only                   | Through design approval                   | Batch, once per spec             | None                                     |
| github/spec-kit   | No; Key Entities per spec, `data-model.md`       | `**Entity**: what it represents`                | `clarify` normalizes to one term, `analyze` reports drift    | Per answer in `clarify`; not for entities | `specify`, `clarify`, `plan`     | None                                     |
| Fission-AI/OpenSpec | No; free-text `context` in `openspec/config.yaml` | Own docs: bold term, definition, "Not X."     | "One term per concept", for doc writers                      | No                                        | By hand                          | Topic groups, alphabetical within        |
| open-gsd/gsd-core | No; GSD's own contributor `CONTEXT.md`           | `### Term`, one paragraph, contrast             | No synonyms; plan review flags contradictions, advisory only | Maintainer owns wording                   | By hand in pull requests         | Topic groups                             |
| BMAD-METHOD       | No; a Glossary section per PRD, per-initiative `glossary.md` | Empty heading with a guidance comment | Consistency checked across documents                         | "Nothing was invented" in the PRD         | In the PRD pass, before features | None in the PRD                          |

## Per-repository notes

### mattpocock/skills

Commit `6f7f783`.

- **`domain-modeling` owns the glossary and the decision records together** `[read: skills/engineering/domain-modeling/SKILL.md:1-74]`. Its docs admit the decision-record half clashes with house styles `[read: docs/engineering/domain-modeling.md:67]`.
- **The description:** "Build and sharpen a project's domain model. Use when discussing codebase terminology, writing or editing a GLOSSARY.md, or recording or editing an ADR." `[read: SKILL.md:3]`. The triggers were widened in #848, which also dropped an "another skill needs…" clause as the caller's job `[read: CHANGELOG.md:81]`.
- **Reading the glossary is not this skill.** The skill opens by saying so `[read: SKILL.md:8]`.
- **The entry shape**, verified in the clone `[read: skills/engineering/domain-modeling/GLOSSARY-FORMAT.md:16-18]`:

  ```markdown
  **Invoice**:
  A request for payment for an **Order**, sent to its **Customer** after delivery.
  _Avoid_: Bill, payment request
  ```

- **The format rules** `[read: GLOSSARY-FORMAT.md:27-31]`:
  - Pick one word and list the others under `_Avoid_`.
  - Define what the term is, not what it does, in one or two sentences.
  - Bold other glossary terms inside a definition.
  - Only project-specific terms, not general programming concepts.
  - Group under subheadings when clusters emerge.
- **"It is a glossary and nothing else."** No implementation detail `[read: SKILL.md:64]`. The most-reported failure is a glossary that "turns into a running spec" `[read: docs/engineering/domain-modeling.md:44]`.
- **Conflicts are raised at once.** A term that conflicts with the glossary gets "Which is it?" `[read: SKILL.md:46]`. When code contradicts the user, the skill asks which is right `[read: SKILL.md:58]`.
- **The `teach` variant adds three rules.** "Add a term only when the user understands it", "Flag ambiguities explicitly", and update in place without stale entries `[read: skills/productivity/teach/GLOSSARY-FORMAT.md:29-35]`.
- **Skills that only read get rules in `docs/agents/domain.md`.** Read the glossary before exploring, proceed silently if it is missing, and note a missing term for `domain-modeling` instead of inventing one `[read: skills/engineering/setup-matt-pocock-skills/domain.md:5-11, 41-45]`.
- **`CONTEXT.md` became `GLOSSARY.md` in 1.3.0** (#1120), because "the file is a glossary and nothing else" `[read: CHANGELOG.md:75-77; docs/engineering/domain-modeling.md:57-58]`. Issue #1232 then found a pointer file still naming `CONTEXT.md`, which created a second file `[read]`.
- **No batch scan from code exists.** One user reported more than 50 questions when scaffolding a glossary for an existing repository `[read: docs/engineering/domain-modeling.md:63-64]`.
- **Not found:** an alphabetical rule, a confirmation step per meaning, a final report of changes.

### google/elephant-goldfish-model

Commit `4693375`. No glossary skill, file or template `[read]`.

- **The nearest concept is the Comprehension Goldfish.** A "Naive Reader persona … flagging undefined terms, acronyms, and comprehension gaps" `[read: agents/comprehension.md:3]`, run as stage 6 of `egm-review` `[read: skills/egm-review/SKILL.md:72]`.
- **It flags only project terms.** "Flag a term only when it is specific to this project … Do not flag general engineering terms." `[read: agents/comprehension.md:48]`
- **It scans the whole document before flagging a gap** `[read: agents/comprehension.md:40]`.
- **A gap is not argued.** "Do not contest a comprehension gap." `[read: skills/egm-resolve/SKILL.md:77-78]`
- **Inconsistent terminology ranks as a Nit** `[read: docs/designs/synthesizer.md:74-75]`. Synonym checks cover only repeated words placed near each other `[read: agents/style.md:47]`.
- **Not found:** a persistent term store, confirmation of meanings, an entry format.

### obra/superpowers

Commit `22f0b46`. No glossary skill, file or term mechanism `[read: grep over the clone]`.

- **Meaning lives in the brainstorming design doc**, as prose, saved and committed per topic `[read: skills/brainstorming/SKILL.md:229-248]`.
- **The conversation keeps the user's words.** "Match their vocabulary; never use process jargon." `[read: skills/brainstorming/SKILL.md:107]`
- **A guess is offered as a proposal.** Ask only when the answer changes what gets built; otherwise state the call for the user to correct `[read: skills/brainstorming/SKILL.md:99-103]`.
- **Plans copy naming rules verbatim** from the spec into a Global Constraints section that reviewers check `[read: skills/writing-plans/SKILL.md:70-75; skills/subagent-driven-development/task-reviewer-prompt.md:196]`.
- **"Choose one term and use it throughout"** applies to skill prose, not the project domain `[read: skills/writing-skills/references/anthropic-best-practices.md:580-595]`.

### github/spec-kit

Commit `f201054`. No glossary file, template or command in core `[read]`.

- **Key Entities is an optional spec section**: `- **[Entity 1]**: [What it represents, key attributes without implementation]` `[read: templates/spec-template.md:101-104]`. `specify` fills it from the feature description with "reasonable defaults" and no confirmation `[read: templates/commands/specify.md:137, 143]`.
- **`clarify` scans for terminology.** Its category lists "Canonical glossary terms" and "Avoided synonyms / deprecated terms" `[read: templates/commands/clarify.md:113-115]`.
- **`clarify` asks one question at a time, at most five,** each with a `**Suggested:**` answer the user accepts with "yes" `[read: clarify.md:130, 141, 168-171]`.
- **A conflict is normalized in the spec**, keeping `(formerly referred to as "X")` once `[read: clarify.md:194]`.
- **`analyze` is read-only** and reports "Terminology drift (same concept named differently across files)" as MEDIUM `[read: templates/commands/analyze.md:58, 159, 172]`. It applies no fix without the user `[read: analyze.md:222]`.
- **The gap is filled by extensions.** #5147 keeps canonical per-domain specs, and #5563 saves "accepted terminology … shared across features" `[read]`.

### Fission-AI/OpenSpec

Commit `f1cd852`. No glossary for consuming projects `[read]`. Issue #1980 lists "a glossary" among the knowledge teams keep beyond specs, with no design yet `[read]`.

- **The nearest concept is the `context` field** in `openspec/config.yaml`, injected into every artifact instruction, capped at 50 KB `[read: src/core/project-config.ts:41-46, 256]`.
- **Its init comments keep code facts out:** "Include constraints an agent cannot infer by reading the code." `[read: src/core/config-prompts.ts:26-27]`
- **Readers must not copy it.** "`context` and `rules` are constraints for YOU, not content for the file" `[read: src/core/templates/workflows/continue-change.ts:139-141]`.
- **It replaced a passive file.** `project.md` "was passive—agents might read it, might not" `[read: docs/migration-guide.md:69]`.
- **OpenSpec's own glossary** opens with why it exists: "OpenSpec reuses words that mean something else in git, CI, and agent tooling." Rows carry contrasts such as "Not a build output." `[read: docs-lab/reference/glossary.md:5-11]`. The published version groups by topic and sorts within groups `[read: docs/glossary.md:5]`.
- **Its doc-writing skill says** "One term per concept, the glossary's term if the tree has one" `[read: .agents/skills/write-openspec-docs/writing.md:188]`.

### open-gsd/gsd-core

Commit `26429a6`. No glossary for consuming projects `[read]`.

- **GSD's own glossary is the root `CONTEXT.md`**, for contributors, with `### Term` entries of one paragraph `[read: CONTEXT.md:9]`. Some contrast a neighbour: "Contrast with a **prototype**" `[read: CONTEXT.md:699-700]`.
- **Authoring rules:** one paragraph, "Do not add synonyms; pick one name and use it everywhere", and the maintainer owns final wording `[read: docs/contributor-standards.md:31-35, 51]`.
- **Readers are told not to invent words.** A missing concept is noted for `/grill-with-docs` `[read: docs/agents/domain.md:24-26]`.
- **Plan review flags contradicting term use**, advisory only `[read: gsd-core/workflows/plan-review-convergence.md:303, 317]`. It does not flag "a wording-only difference that asserts the same thing" `[read: plan-review-convergence.md:313]`.
- **Paths and issue numbers inside entries rotted.** Issue #2387 found dead references in the 1007-line file, and a lint script now checks them `[read: scripts/check-glossary-refs.cjs:9-29]`.
- **The file mixes registers**: glossary, predicates and an append-only session log `[read: CONTEXT.md:3-6, 1124]`.

### bmad-code-org/BMAD-METHOD

Commit `e435a22`. No project glossary skill and no repository-wide glossary file `[read]`.

- **The PRD template has a `## Glossary` section**, filled before features: "Each domain noun defined once, with its relationships to other terms and its cardinality where relevant. A new noun in Features joins the glossary in the same pass." `[read: skills/method/bmad-agent-pm/assets/template-prd.md:7, 44]`
- **Consumers use terms as defined.** "Domain nouns are used exactly as the glossary defines them." `[read: template-prd.md:23]`
- **The PRD is done when** "the user remembers making every decision in it, and nothing was invented to fill a section" `[read: template-prd.md:25]`.
- **`bmad-project-context` asks what a domain term means** but writes no term section `[read: skills/method/bmad-project-context/SKILL.md:59; references/template.md:3-10]`.
- **Its interview rules:**
  - "Never ask what a scan could answer" and "Ask recall questions, not review lists" `[read: SKILL.md:61-62]`.
  - Batches of "at most eight" `[read: SKILL.md:65]`.
  - "When the repo contradicts the user, show the evidence and ask. Never write the claim as given, never drop it silently." `[read: SKILL.md:66]`
  - "The user approves every write" and "Never commit." `[read: SKILL.md:10, 76]`
- **Copies need a consistency check.** The UX validation demands "Glossary identical across spines, ticket, and sources" `[read: validate.md:35]`.

## Recommendations for `update-glossary`

All recommendations are `[inferred]`. Each fits our constraints unless it says otherwise: one text for both harnesses, front matter with `name` and `description` only, no tool names, and nothing read from outside the skill folder.

### Adopt

- **Record only project-specific terms.** Add a filter before the sort: a general programming concept is skipped and reported as skipped.
  - Source: Pocock `GLOSSARY-FORMAT.md:30`, EGM `agents/comprehension.md:48`.
- **Say in a guardrail that the glossary holds meanings and nothing else.** No implementation detail, paths or issue numbers.
  - Source: Pocock `SKILL.md:64` and its most-reported failure; GSD #2387, where references in entries rotted.
- **Record the rejected word of a synonym conflict in the entry.** Our "Not …" sentence covers a confusable term. A second word for the same thing needs its own form, such as "Not *bill*, which we no longer use."
  - Source: Pocock `_Avoid_`, Spec Kit `(formerly referred to as "X")`.
- **Bold another glossary term when a definition mentions it.** It costs one rule and shows how terms relate.
  - Source: Pocock `GLOSSARY-FORMAT.md:29`.
- **Define a wording-only difference as same, not conflict.** This sharpens our "Same" bucket.
  - Source: GSD `plan-review-convergence.md:313`.
- **Show the evidence in a conflict question.** Quote the existing entry and where the other sense was used; never write it as given, never drop it silently.
  - Source: BMAD `bmad-project-context/SKILL.md:66`, Pocock `SKILL.md:46, 58`.
- **Let the user accept a proposed meaning with one word.** Our numbered question already proposes a meaning; say that "yes" accepts it.
  - Source: Spec Kit `clarify.md:168-171`.

### Consider

- **A cap on questions per run, with the rest reported as pending.** It helps a brownfield hand-over of many terms. Spec Kit caps at five and BMAD batches eight; Pocock reports 50 questions with no cap.
  - Source: Spec Kit `clarify.md:130`, BMAD `SKILL.md:65`, Pocock `docs/engineering/domain-modeling.md:63-64`.
- **A purpose line at the top of the template.** Something like "Words this project uses in its own sense", which tells a reader why the file exists.
  - Source: OpenSpec `docs-lab/reference/glossary.md:5`.
- **Reader rules for the skills that read the glossary**, held by those skills rather than by `update-glossary`. Use terms exactly as defined, do not copy entries into artifacts, and hand a missing term to `update-glossary` instead of inventing one.
  - Source: BMAD `template-prd.md:23`, OpenSpec `continue-change.ts:139-141`, Pocock `domain.md:41-45`, GSD `domain.md:24-26`.
- **A fresh-context check that feeds this skill.** A spec review in a fresh context window lists undefined project terms and hands them over. It belongs in the review skill.
  - Source: EGM Comprehension Goldfish, Spec Kit `analyze`.
- **Closed value sets as entries.** A status list spelled out differently in different places could have one entry that names its values.
  - Source: Spec Kit #4106.

### Avoid

- **Terms kept per spec, PRD or initiative.** They drift between documents and need a validation pass to stay identical. Our single `docs/GLOSSARY.md` avoids that.
  - Source: BMAD `validate.md:35`, Spec Kit #5147 and #5563, superpowers design docs.
- **Meanings drafted from code or a description without the user.** It contradicts our core rule.
  - Source: Spec Kit `specify.md:137, 143`.
- **Topic groups instead of alphabetical order.** A group needs judgement on each insert, and our callers add terms one at a time.
  - Source: Pocock `GLOSSARY-FORMAT.md:31`, OpenSpec `docs/glossary.md:5`, GSD `CONTEXT.md`.
- **A glossary file that also holds other content.** GSD's `CONTEXT.md` mixes glossary, predicates and a session log, and its name clashes with the phase `CONTEXT.md`.
  - Source: GSD `CONTEXT.md:3-6, 1124`; Pocock's rename to `GLOSSARY.md`.
- **Glossary and decision records in one skill.** Our separate `record-decision` already avoids it.
  - Source: Pocock `docs/engineering/domain-modeling.md:67`.
- **Ranking a terminology conflict as a nit.** One word in two senses must be settled, which is why our skill asks.
  - Source: EGM `docs/designs/synthesizer.md:74-75`.
- **A glossary path named in more than one file.** A pointer that names an old path creates a second glossary.
  - Source: Pocock #1232.
- **Mechanisms our constraints rule out:** a "Call the Skill tool" wrapper and `disable-model-invocation` (Pocock), terms injected by a CLI (OpenSpec), lint scripts (GSD), resolver hooks under `_bmad/custom/` (BMAD).

## Not read

- **Our v1 at `v1-final`:** `skills/glossary`, its root `GLOSSARY.md` and the decision `docs/decisions/2026-08-12-glossary-lives-at-the-repo-root.md`. Reading the tag needs the owner's go-ahead.
- **BMAD's own docs glossary** at `glossary/index.md`, which its style guide describes but which is not in the tree at this commit `[read: docs/_STYLE_GUIDE.md:264]`.
