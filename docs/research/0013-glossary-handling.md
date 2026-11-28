---
question: "How do the seven reference repositories record and maintain domain terms for the projects they are installed into, if they do at all?"
researched: "2026-11-28"
versions: "obra/superpowers 22f0b46, mattpocock/skills bbadaa6 (CHANGELOG 1.3.2 plus unreleased changesets), google/elephant-goldfish-model 4693375, github/spec-kit f201054 (CHANGELOG 1.4.5), Fission-AI/OpenSpec dff0188 (tag v2.2.0), open-gsd/gsd-core e9c3e54 (branch next), bmad-code-org/BMAD-METHOD e435a22"
---

# How seven agent-workflow repositories record a consuming project's domain terms

## Answer

Each row holds for the commit and commit date in its first cell. A cell that reads "not specified" means the shipped skill text says nothing on that facet.

| Repository | Glossary, and its writer | Where terms live | Entry shape | Synonyms and conflicts | User confirms | When written | Review-time check |
| --- | --- | --- | --- | --- | --- | --- | --- |
| superpowers 22f0b46 (2026-11-03) | None | Spec naming rules, copied into the plan's Global Constraints | Not specified | Not specified | Not specified | Not specified | None |
| mattpocock/skills bbadaa6 (2026-11-27) | `GLOSSARY.md`, written by `domain-modeling`, also by `improve-codebase-architecture` and through `grill-with-docs` and `triage` | Repo root; per-context files listed in a root `GLOSSARY-MAP.md` | Bold term, one or two sentences on what it is, `_Avoid_:` line; other terms bolded inside | One canonical term, others under `_Avoid_`; conflicts called out in conversation | Implicit: written once "resolved" in conversation, no approval step | Inline, "don't batch" | None |
| elephant-goldfish-model 4693375 (2026-11-25) | None | Inside each design doc, defined inline, in a local glossary or by link | Not specified | Not specified | Not specified | Not specified | Comprehension reviewer flags undefined project terms |
| spec-kit f201054 (2026-11-25) | No glossary file; `/speckit.clarify` asks term questions | One feature's `spec.md` and `data-model.md` | Key Entities: bold name, what it represents | Normalize across the spec, keep "formerly referred to as" once | Yes, one question at a time, five per session at most | Inline, after each answer | `/speckit.analyze` reports terminology drift, read-only |
| OpenSpec dff0188 (2026-11-28) | None | Free-text `context:` in `openspec/config.yaml` | Not specified | Not specified | Not specified | Not specified | None |
| gsd-core e9c3e54 (2026-11-28) | None for the consuming project | `PROJECT.md` in "the user's language"; a term defined in a phase `CONTEXT.md` decision | Not specified | Not specified | Not specified | Not specified | Plan-review convergence flags a defined term that contradicts between phase `CONTEXT.md` Decisions and `PLAN.md` |
| BMAD-METHOD e435a22 (2026-11-12) | PRD `## Glossary` and SRS `## Definitions`, filled through the PM agent and `bmad-facilitate`; an initiative `glossary.md` with no named writer | Planning documents; `{output_folder}/{active_initiative}/glossary.md` | PRD: noun defined once, with relationships and cardinality | Nouns used exactly as defined; no synonym rule; contradictions go to the user | Each item stays open until the user accepts it | Inline, "in the same pass" | Rubric, editorial and UX checks for consistent terms |

- **Only `mattpocock/skills` keeps a dedicated glossary file for the consuming project.** BMAD-METHOD keeps glossary sections inside planning documents. spec-kit settles terms per feature spec and nowhere project-wide. The other four keep no term list; gsd-core's plan review treats a term defined in a phase `CONTEXT.md` decision as the authority.
- **Where terms are recorded, the repositories agree on two points.** Terms are written inline as they are settled, and each term gets one meaning. No repository sets an order for entries; mattpocock groups terms under subheadings when clusters emerge.
- **They differ on confirmation and checking.** spec-kit and BMAD make the user accept each answer; mattpocock writes once a term is resolved in conversation. spec-kit, BMAD, elephant-goldfish-model and gsd-core check term use at review time. Inferred, from the review-check findings in each section: none of the seven checks a consuming project's code against its glossary.
- **No repository has a rule for renaming, retiring or dating a glossary entry.** spec-kit's clarify comes closest: it renames a term across one spec and keeps the old name once. Inferred, from the mattpocock format findings: the only way to retire a word there is to list it under `_Avoid_`.
- **Reported problems cluster in `mattpocock/skills`.** Its tracker holds about twenty threads on entry content, write timing, file location, staleness and scale, several still open. The other trackers hold a few rejected or stalled proposals, or nothing.
- **The evidence is strong for skill text at the pinned commits and moving for two repositories.** The mattpocock format changed on 2026-11-25 and has open fixes. BMAD's `dev` branch, outside this report's scope, already changes how its PRD glossary is written. The issue search was capped per query and sampled for gsd-core.

## superpowers, mattpocock/skills and elephant-goldfish-model

### obra/superpowers

- No skill writes a glossary or term list. No skill matched "glossary" or "ubiquitous"; hits for "vocabulary" and "terminology" concern the harness or skill writing (tested 2026-11-28: `grep -rniE "glossary|ubiquitous|vocabulary|domain (term|language|model)|terminolog|naming" skills agents commands`).
- Brainstorming says only to "Match their vocabulary; never use process jargon" ([brainstorming/SKILL.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b46/skills/brainstorming/SKILL.md)).
- Project-wide "naming and copy rules" in a spec are copied verbatim into the plan's Global Constraints ([writing-plans/SKILL.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b46/skills/writing-plans/SKILL.md)).

### mattpocock/skills

Writers and location:

- `domain-modeling` builds the glossary. Setup's template says it is "reached via `/grill-with-docs` and `/improve-codebase-architecture`" and creates the files lazily ([domain-modeling/SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/domain-modeling/SKILL.md); [setup-matt-pocock-skills/domain.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/setup-matt-pocock-skills/domain.md)).
- `grill-with-docs` only routes: "Call the Skill tool twice, for \"grilling\" and \"domain-modeling\"" ([grill-with-docs/SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/grill-with-docs/SKILL.md)).
- `improve-codebase-architecture` adds a term when it names a module after a concept not in `GLOSSARY.md` ([improve-codebase-architecture/SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/improve-codebase-architecture/SKILL.md)).
- `triage` calls grilling and `domain-modeling`, "updating `GLOSSARY.md`/ADRs inline as decisions land" ([triage/SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/triage/SKILL.md)).
- Setup writes a single-context layout, one root `GLOSSARY.md`, "without asking". It offers a root `GLOSSARY-MAP.md` pointing to per-context files only on monorepo signals ([setup-matt-pocock-skills/SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/setup-matt-pocock-skills/SKILL.md)).
- The map lists the contexts and a `## Relationships` list between them, such as Ordering emitting `OrderPlaced` events for Fulfillment ([GLOSSARY-FORMAT.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/domain-modeling/GLOSSARY-FORMAT.md)).

Entry shape and ordering, all from [GLOSSARY-FORMAT.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/domain-modeling/GLOSSARY-FORMAT.md):

- A file holds a context heading, a short description and a `## Language` section.
- An entry is a bold term, a definition, then `_Avoid_:` synonyms. The example: "**Invoice**: / A request for payment for an **Order**, sent to its **Customer** after delivery. / _Avoid_: Bill, payment request".
- Definitions are "One or two sentences max. Define what it IS, not what it does."
- "Bold other glossary terms inside a definition", and the sentence says how the two relate.
- Only terms specific to the project belong; general programming concepts do not.
- Terms are grouped "under subheadings when natural clusters emerge", otherwise kept flat. No ordering rule exists.

Synonyms, conflicts, confirmation and timing, all from [domain-modeling/SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/domain-modeling/SKILL.md) unless cited otherwise:

- With several words for one concept, the agent picks one and lists the others under `_Avoid_` ([GLOSSARY-FORMAT.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/domain-modeling/GLOSSARY-FORMAT.md)).
- A term that conflicts with the glossary is called out "immediately". An overloaded word gets a proposed canonical term: "do you mean the Customer or the User?"
- When the user says how something works, the agent checks whether the code agrees and surfaces a contradiction.
- The glossary is "totally devoid of implementation details" and is not "a spec, a scratch pad, or a repository for implementation decisions".
- "When a term is resolved, update `GLOSSARY.md` right there. Don't batch these up." No step asks the user to approve the entry text. The docs page says the same: it writes a term "at the moment you settle it" ([docs/engineering/domain-modeling.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/docs/engineering/domain-modeling.md)).
- `grilling`, which `grill-with-docs` pairs with it, works "in **rounds**" and waits for answers before the next round ([grilling/SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/productivity/grilling/SKILL.md)).
- In a multi-context repo the agent infers the context of the topic and asks "If unclear" ([GLOSSARY-FORMAT.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/domain-modeling/GLOSSARY-FORMAT.md)).
- No rule covers updating, removing or renaming an entry, or the same word defined differently in two context glossaries (tested 2026-11-28 by reading SKILL.md and GLOSSARY-FORMAT.md in full at bbadaa6).

How other skills find and use the glossary:

- Setup writes `docs/agents/domain.md` and adds a "Domain docs" pointer to `CLAUDE.md`, or to `AGENTS.md` when there is no `CLAUDE.md` ([setup-matt-pocock-skills/SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/setup-matt-pocock-skills/SKILL.md)).
- The template tells skills to read the root `GLOSSARY.md`, or the map and each relevant context file. If the files are missing, skills "proceed silently". They must not "drift to synonyms the glossary explicitly avoids", and a missing concept is to be noted "for `/domain-modeling`" ([domain.md template, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/setup-matt-pocock-skills/domain.md)).
- No skill outside setup names `docs/agents/domain.md`. `tdd`, `diagnosing-bugs`, `to-spec`, `to-tickets`, `pr` and `wait-what` name `GLOSSARY.md` or "the project's domain glossary" directly (tested 2026-11-28: `grep -rn -i -E 'docs/agents/domain|GLOSSARY-MAP|glossary' skills`).
- The sources disagree on whether skills read the pointer. The docs page at bbadaa6 says the skills "already read" `docs/agents/domain.md` ([docs/engineering/domain-modeling.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/docs/engineering/domain-modeling.md)). A triage comment from the maintainer account on 2026-11-25, marked as AI-generated, says `domain-modeling` "hardcodes GLOSSARY.md at the root and never mentions docs/agents/domain.md" ([issue #1376](https://github.com/mattpocock/skills/issues/1376)). The comment is newer and matches the grep above.
- `code-review` does not mention the glossary ([code-review/SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/code-review/SKILL.md)).

What the head contains and how recent it is:

- PR #1485, which added the bolded-terms rule, merged 2026-11-25. Its merge commit is an ancestor of bbadaa6 (tested 2026-11-28: `gh api --method GET repos/mattpocock/skills/compare/6f7f7831a625f040a8e06a0e7954826b87ce775a...bbadaa6` gave `ahead`, `3`, `0`).
- The change sits in `.changeset/glossary-bold-terms.md` and not yet in CHANGELOG.md, whose top entry is 1.3.2 ([changeset, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/.changeset/glossary-bold-terms.md)).
- PR #1476, "read GLOSSARY-FORMAT.md before the first glossary entry", is open, so its wording is not at the head (tested 2026-11-28: `gh pr view 1476 --repo mattpocock/skills --json state,mergeCommit,mergedAt,title,body`).
- Release 1.3.0 renamed `CONTEXT.md`/`CONTEXT-MAP.md` to `GLOSSARY.md`/`GLOSSARY-MAP.md` in PR #1120, and "the skills only look for `GLOSSARY.md`/`GLOSSARY-MAP.md` going forward" ([CHANGELOG.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/CHANGELOG.md)). The rename commit d80fa0f was committed 2026-09-17 and authored 2026-08-15 (tested 2026-11-28: `git log -1 --format='%ad %cd' d80fa0f`). A source that names `CONTEXT.md` predates it.
- The earlier `ubiquitous-language` skill was replaced by `domain-modeling`, "which builds and maintains the whole domain model rather than dumping a glossary from one conversation" ([CHANGELOG.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/CHANGELOG.md)).

### google/elephant-goldfish-model

- No skill writes a glossary. The design-doc template has no terms section ([egm-draft/references/design_doc.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/skills/egm-draft/references/design_doc.md)).
- The read-only Comprehension reviewer checks that each project-specific term is defined "inline, in an earlier section, or in a local glossary" or linked. It flags a term "only when it is specific to this project, team, or design and is not defined", after scanning the whole document ([agents/comprehension.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/agents/comprehension.md)).
- The Style agent checks "terminology constraints" when a style standard is supplied ([agents/style.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/agents/style.md)).

## spec-kit and OpenSpec

### github/spec-kit

- The installed templates hold no glossary file. Term words matched only `clarify.md` and `analyze.md`; the nearest other section is Key Entities in `spec-template.md` and `specify.md` (tested 2026-11-28: `ls templates templates/commands` and `grep -rniE` for `glossary|terminolog|ubiquitous|vocabular|synonym` in `templates/`).
- `/speckit.clarify` rates a "Terminology & Consistency" category, "Canonical glossary terms" and "Avoided synonyms / deprecated terms", as Clear, Partial or Missing. A Partial or Missing category becomes a candidate question ([clarify.md, f201054](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/clarify.md)).
- On a conflict, clarify normalizes the term across the spec and keeps the old name once, as "(formerly referred to as \"X\")". Its validation checks that one canonical term is used across updated sections (same file).
- Clarify asks "EXACTLY ONE question at a time", five per session at most, each with a recommended option. A question is asked only when it would materially affect the design, so terminology competes with other categories for the slots (same file).
- After each accepted answer, clarify records it under `## Clarifications` and updates the spec at once: "Save the spec file AFTER each integration". It writes only the feature's own spec (same file).
- The spec template has an optional Key Entities list of "**[Entity 1]**: [What it represents, key attributes without implementation]" ([spec-template.md, f201054](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/spec-template.md)). `/speckit.plan` extracts entities into `data-model.md` ([plan.md, f201054](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/plan.md)).
- No ordering rule for terms. Clarify says only "do not reorder unrelated sections" ([clarify.md, f201054](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/clarify.md)).
- `/speckit.analyze` is "STRICTLY READ-ONLY". It reports "Terminology drift (same concept named differently across files)" at MEDIUM severity ([analyze.md, f201054](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/analyze.md)).
- The clarify and analyze terminology lines both arrived in c7b61f4 on 2025-09-22. Both are still present at f201054 after edits in 2026-09 and 2026-11 (tested 2026-11-28: `git log -S"Terminology drift"`, `git log -S"Canonical glossary terms"` and `git log -1` on each file).
- Inferred, from the clarify and template findings: a term settled in one feature's spec does not carry to the next feature, and no artifact lists terms across the project.

The community preset "Closed Vocabulary Check" (`closed-vocabulary`, v1.0.1) is opt-in and outside core:

- The catalog lists it, created 2026-08-19, as a pass "that flags closed sets of values enumerated more than once with different members" (tested 2026-11-28: `gh api --method GET "repos/github/spec-kit/contents/presets/catalog.community.json?ref=f201054"`).
- It appends one pass to `/speckit.analyze` that "only adds findings" ([preset.yml, v1.0.1](https://github.com/yunusdim/spec-kit-preset-closed-vocabulary/blob/main/preset.yml); [commands/speckit.analyze.md, v1.0.1](https://github.com/yunusdim/spec-kit-preset-closed-vocabulary/blob/main/commands/speckit.analyze.md)).
- A closed set is "a named set of admissible values enumerated in prose", such as an order status that "is one of" listed values. Sets are grouped by name, and a finding gives the difference in both directions (same command file).
- The pass is a warning that "never blocks and never fails a run", because only a human can tell a defect from two sets that share a name (same command file).
- Its README states the limit: "It cannot tell whether a set that every declaration agrees on is the right set" ([README.md, v1.0.1](https://github.com/yunusdim/spec-kit-preset-closed-vocabulary/blob/main/README.md)).
- Inferred, from the findings above: the preset checks value sets, not term definitions or synonyms, and reads or writes no term list.
- The preset repository was last pushed 2026-08-18, while spec-kit has released through 1.4.5 on 2026-11-25 (tested 2026-11-28: `gh api --method GET repos/yunusdim/spec-kit-preset-closed-vocabulary`).

Term entries in the spec-kit CHANGELOG at f201054 (tested 2026-11-28: CHANGELOG fetched with `gh api` and grepped for `glossar|terminolog|vocabular|naming|\bterms?\b|domain lang|ubiquitous|lexic`, then `consisten|synonym|definition|drift|ambigu`):

- No entry matches `glossar` or `terminolog`.
- The only "vocabular" match is in `[1.0.0] - 2026-08-21`: "Add Closed Vocabulary Check preset to community catalog (#4201)".
- The "naming" matches concern the tool itself, such as branch naming and agent skill naming.

### Fission-AI/OpenSpec

- No skill or schema text mentions a glossary, terminology or domain terms. The only hits were a code comment, OpenSpec's own docs glossary and a translation tip (tested 2026-11-28: grep of `src/`, `schemas/`, `docs/` and `README.md` for `glossary|terminolog|ubiquitous|vocabular|domain term|synonym|domain language|key entities|jargon`).
- `docs/glossary.md` defines "Every OpenSpec term", the tool's own vocabulary, not the user's ([docs/glossary.md, dff0188](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/docs/glossary.md)).
- The nearest home for domain terms is the optional free-text `context:` in `openspec/config.yaml`, "injected into all artifact instructions" and capped at 50 KB ([src/core/project-config.ts, dff0188](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/src/core/project-config.ts)). No skill writes terms into it ([docs/customization.md, dff0188](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/docs/customization.md)).
- `openspec-verify-change` checks "pattern consistency" and has no terminology check ([src/core/templates/workflows/verify-change.ts, dff0188](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/src/core/templates/workflows/verify-change.ts); tested 2026-11-28: grep for `terminolog`, no match).

Term entries in the OpenSpec CHANGELOG at dff0188 (tested 2026-11-28: same fetch and greps as for spec-kit; release dates from `gh api --method GET repos/Fission-AI/OpenSpec/releases/tags/<tag>`):

- No entry matches `glossar` or `terminolog`.
- 1.13.1 (released 2026-09-17, PR #1864) stops archive "adding a second copy of an existing requirement under a name that differs only in case or spacing".
- 1.14.2 (released 2026-10-15, PR #2083) fixes verify, where "an implementation written in different vocabulary read as a clean removal".
- Inferred, from the two entries above: both treat names as requirement identifiers and define no term.

## gsd-core and BMAD-METHOD

### open-gsd/gsd-core

- No shipped step writes a glossary for the consuming project (tested 2026-11-28: `grep -rniE 'glossary|ubiquitous|domain term|terminolog|vocabular' agents commands gsd-core capabilities skills hooks src bin`).
- Its only glossary is the root `CONTEXT.md` of its own repository, whose entries describe gsd-core modules such as "Milestone Module" ([CONTEXT.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/CONTEXT.md)). The installed planner still points at it: "(Glossary: `tracer bullet` vs `prototype` in `CONTEXT.md` ...)" ([agents/gsd-planner.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/agents/gsd-planner.md)).
- The `<phase>-CONTEXT.md` that `/gsd:discuss-phase` writes is a decisions file, with sections that "emerge from what was actually discussed" ([gsd-core/templates/context.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/templates/context.md)).
- The plan-review convergence workflow pairs facts across artifacts by judgment. One pair is "Glossary / domain term": phase `CONTEXT.md` `Decisions` against the term's use in `PLAN.md`, with `CONTEXT.md` as the authority. It flags a pair only when both sides name the same defined term and contradict ([gsd-core/workflows/plan-review-convergence.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/plan-review-convergence.md)).
- The PROJECT.md template says "Use the user's language and framing" ([gsd-core/templates/project.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/templates/project.md)). The doc writer takes "project-specific terminology" from the project's own skills ([agents/gsd-doc-writer.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/agents/gsd-doc-writer.md)).

### bmad-code-org/BMAD-METHOD

Glossary sections in planning documents:

- The PRD template, under the PM agent `bmad-agent-pm`, puts `glossary` third in its `facilitation_order`, before features. Its rule: "Each domain noun defined once, with its relationships to other terms and its cardinality where relevant. A new noun in Features joins the glossary in the same pass." It also says "Domain nouns are used exactly as the glossary defines them." ([template-prd.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-agent-pm/assets/template-prd.md)).
- The SRS template has `## Definitions` for "Terms, acronyms and abbreviations" ([template-srs.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-agent-pm/assets/template-srs.md)).
- Neither template names fields, an order or a grouping for entries, and no file has a rule for synonyms, aliases or renamed terms. Searched for "synonym", "alias", "vocabulary", "same term" and "domain noun" in the PO, PM, architect and facilitate skills (tested 2026-11-28).

The initiative `glossary.md`:

- The PO workflow's tree shows `glossary.md` beside the initiative ticket and its `.memlog.md`, without naming a writer ([bmad-agent-po/workflow.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-agent-po/workflow.md)). A migration keeps it in place ([migration-2.toml, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmod-method/migration-2.toml)).
- The ticket template types companions "by content (glossary, design, architecture, prd)", written or adopted by the SPEC step ([ticket-template.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-agent-po/assets/ticket-template.md)). "Spec-authored companions sit beside the ticket, named for their content; SPEC may edit them on update" ([references/spec.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-agent-po/references/spec.md)).
- Inferred, from the three findings above: the PO's SPEC step probably writes `glossary.md`. No file says so, and none defines its shape (tested 2026-11-28: every hit of `grep -ril glossary . --exclude-dir=.git` read).

Confirmation and timing, from [bmad-facilitate/SKILL.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/core-tools/bmad-facilitate/SKILL.md) unless cited otherwise:

- The coaching path writes "each section ... into the document as its answers land", with no per-section confirmation step.
- The fast path drafts the whole document, logs each default as an assumption, then offers a walkthrough one section at a time.
- On every path, an item stays open "until the user accepts that item: a yes to a group ... accepts nothing".
- Unconfirmed inferences are tagged `[ASSUMPTION: ...]` until accepted ([guidance-planning.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/core-tools/bmad-facilitate/references/guidance-planning.md)).
- A contradiction between inputs, or between an input and the user, "goes to the user before you draft".
- `bmad-project-context` asks the user "what a domain term means", and "the user approves every write" ([bmad-project-context/SKILL.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-project-context/SKILL.md)). Its AGENTS.md block template has no terms section ([references/template.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-project-context/references/template.md)).

Review-time checks:

- The planning rubric scores "Usable downstream: consistent terms, ids resolve" ([rubric-planning.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/core-tools/bmad-facilitate/references/rubric-planning.md)).
- The editorial review asks for the "same word for same concept throughout" ([editorial-common.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/core-tools/bmad-review/references/editorial-common.md)).
- UX validation checks "Glossary identical across spines, ticket, and sources" ([bmad-ux/references/validate.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-ux/references/validate.md)).
- PO tickets use "the project's vocabulary, no invented terms", and the agent offers the user a rewrite where their text breaks this ([references/ticket.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-agent-po/references/ticket.md)).

What dates the BMAD answer:

- The cited paths date from a restructure, 3cf35b6 on 2026-11-11 (tested 2026-11-28: `git log -3` on the PRD template and PO workflow).
- `main` is the default branch and e435a22 its head. PR #3238 merged into `dev` on 2026-11-20, not into `main` (tested 2026-11-28: `gh api --method GET repos/bmad-code-org/BMAD-METHOD --jq .default_branch` and `gh pr view 3238 --json baseRefName,mergedAt`).
- On `dev`, #3238 replaces the two paths with three modes. `step-by-step` confirms each section's text, and `freeform` has "no per-section approval gates". A glossary becomes a `built:` section "drafted last from the others" (tested 2026-11-28: `gh pr view 3238 --json body`; `git show FETCH_HEAD:skills/core-tools/bmad-facilitate/SKILL.md` at `dev` head 76887e81).
- The default mode is reported two ways. #3238's body says step-by-step, and `dev`'s SKILL.md at 76887e81 says `freeform` (same commands).
- `dev`'s PRD template moved to `skills/method/bmod-method/doc-templates/` and has a `shared-nouns-and-seams` section and no "glossary" line. `dev`'s PO tree still lists `glossary.md` (tested 2026-11-28: `git show FETCH_HEAD:<path>`).

## Problems reported in issues, pull requests and discussions

All searches ran through GraphQL on 2026-11-28 for glossary, terminology, "ubiquitous language", vocabulary, "domain terms", CONTEXT.md, "domain language", synonym, jargon and naming drift, in issues, pull requests and discussions.

### mattpocock/skills

Entry content and how agents follow the rules:

- #1375, open since 2026-11-02: the agent copied an existing glossary's style instead of opening the format file. It wrote "entries describing behaviour", an enumeration mirroring a code union, and "`_Avoid_` lines with invented synonyms" ([#1375](https://github.com/mattpocock/skills/issues/1375)). Open PR #1476 is the fix and says "existing glossaries are not the format" ([#1476](https://github.com/mattpocock/skills/pull/1476)).
- #1396, closed 2026-11-25: on about 100 terms "Most definitions in the resulting glossary stood alone", after an earlier Relationships section and "Show relationships" rule were removed in e7df78b and e3b90b5. PR #1485 resolved it ([#1396](https://github.com/mattpocock/skills/issues/1396)).
- The docs page admits that models "often load `grilling` and skip" `domain-modeling` when told to load both ([docs/engineering/domain-modeling.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/docs/engineering/domain-modeling.md)). Open issue #556 reports the same for `wayfinder` ([#556](https://github.com/mattpocock/skills/issues/556)).

Write timing:

- #130, open since 2026-05-04 with label `ready-for-human`: under Codex with GPT 5.5 the glossary "gets used as a plan and churns mid-round". A 2026-08-18 comment reports terms "written as canonical, then rewritten after later questions changed the model" ([#130](https://github.com/mattpocock/skills/issues/130)).
- In #130 the maintainer advised on 2026-05-12 asking `/grill-with-docs` to make the file "more concise and remove any implementation details", and called hardening the guidelines "reasonable". Contributors proposed "curate, don't append" and writing at the end of a confirmed round (same issue).
- An AI-generated triage comment from the maintainer account, 2026-10-06, says the inline rule "pulls against the round-based `grilling` flow" and leaves the wording as a design call (same issue).

File identity and location:

- The 1.3.0 rename left existing repos without a migration path, so "the glossary silently splits" (#1153, closed 2026-10-07 as a duplicate of #1176). The setup fix, PR #1228, opened 2026-10-08 and merged 2026-10-27 ([#1153](https://github.com/mattpocock/skills/issues/1153), [#1176](https://github.com/mattpocock/skills/issues/1176)).
- #1376, open since 2026-11-02: `domain-modeling` never read the pointer and offered to create a glossary. With the glossary at `docs/GLOSSARY.md`, its lazy-create rule "would start a second" one, per a 2026-11-09 comment ([#1376](https://github.com/mattpocock/skills/issues/1376)). The triage reply is in the mattpocock section above.

Staleness and scale:

- #827, closed 2026-10-06: "The glossary only ever grows", and nothing notices when code changes invalidate an entry. The AI-generated triage reply closed it as already covered by the no-implementation-details rule and the check against code ([#827](https://github.com/mattpocock/skills/issues/827)).
- #321, closed 2026-10-06: a context file "over 1000 lines". The answer: split clusters "into separate contexts and list them in a root `GLOSSARY-MAP.md`" ([#321](https://github.com/mattpocock/skills/issues/321)). Discussion #1203 asks how to handle the same word with different meanings across those domains and has community answers only ([D1203](https://github.com/mattpocock/skills/discussions/1203)).
- #717, open since 2026-08-01: the skill raised a naming collision as an open question that an earlier issue had already settled ([#717](https://github.com/mattpocock/skills/issues/717)).
- Discussion #275 asks how to keep terms in two languages from drifting; a community reply adds the translation in parentheses after the term ([D275](https://github.com/mattpocock/skills/discussions/275)).

How to read the maintainer replies:

- Several closures cite the bar "I only change skills in response to a failure seen in a real session" (#962, #1015, #1267, #1332). A closure on that bar does not judge the problem absent ([#1332](https://github.com/mattpocock/skills/issues/1332)).
- The replies in #1376, #1396, #827, #1246 and #1232 begin "*This was generated by AI during triage.*"; the 2026-05-12 reply in #130 does not (tested 2026-11-28: issues read with `gh issue view`).

### The other six repositories

- **spec-kit:** issue #4106 (2026-08-13) asked `/speckit.analyze` to flag closed vocabularies. The maintainer asked for a preset first and on 2026-09-17 kept it "an opt-in preset", calling core inclusion "a separate decision" ([#4106](https://github.com/github/spec-kit/issues/4106)). Core PR #4160 is open and was marked stale on 2026-11-17, to close "in 30 days unless there is a substantive update" ([#4160](https://github.com/github/spec-kit/pull/4160)). Both 2026-09-17 comments are labelled "Drafted for @mnriem by GitHub Copilot" (tested 2026-11-28: `gh issue view 4106` and `gh pr view 4160 --comments`).
- **spec-kit:** discussion #576 "Nomenclature" (2025-09-25) asks to share team vocabulary "in a nomenclature.md or such" and has no replies ([D576](https://github.com/github/spec-kit/discussions/576)).
- **OpenSpec:** open exploration #1980 (2026-09-25) names "a glossary" among project knowledge without a home. Its one reply, on 2026-11-21, is about constraints ([#1980](https://github.com/Fission-AI/OpenSpec/issues/1980)).
- **superpowers:** PR #1113, a `.claude/context.md` skill for domain knowledge, cited Claude using "wrong terminology" and repeating it in the next subagent. It closed 2026-09-26 for adding a convention "without a problem you've hit or any evaluation" ([#1113](https://github.com/obra/superpowers/pull/1113)).
- **elephant-goldfish-model:** design PR #228, which included "a repository explainer with a glossary", closed unmerged 2026-11-21 so a handwritten explainer could be tried first ([#228](https://github.com/google/elephant-goldfish-model/pull/228)). No report of a term problem was found.
- **gsd-core and BMAD-METHOD:** no thread about a consuming project's domain terms was found. Their glossary hits concern their own vocabulary or docs, such as gsd-core #3604 on its own `CONTEXT.md` gate ([#3604](https://github.com/open-gsd/gsd-core/issues/3604)) and BMAD PR #1303 on its docs glossary ([#1303](https://github.com/bmad-code-org/BMAD-METHOD/pull/1303)).

## Open questions

- **Who writes BMAD's initiative `glossary.md`, and in what shape.** No file at e435a22 says. A writer or format elsewhere would fill most of the BMAD row's blanks.
- **Whether mattpocock skills follow the `docs/agents/domain.md` pointer in practice.** This was not tested. Only the report in #1376 exists.
- **Whether BMAD's `dev` changes reach `main`, and with which default mode.** That would change BMAD's timing and confirmation cells. A later `dev` commit that sets the default to `freeform` was not traced.
- **Whether the issue search missed threads.** Results were capped at 8 to 15 per query. gsd-core's large result sets were sampled, not read in full. Unopened threads include mattpocock #1352, #1383, #1482 and #1498, spec-kit discussions #992, #2476 and #5241, and OpenSpec #1997.
- **Whether the closed-vocabulary preset still composes on spec-kit 1.4.x.** It was not installed or run.
- **Whether a CHANGELOG entry describes domain terms in other words.** The CHANGELOG search was by keyword only.

## Method

- The user confirmed the brief. Sub-questions 5 to 7 were added after confirmation. Their findings are merged into the sections on the repositories they concern: 5 into mattpocock/skills, 6 into BMAD-METHOD, 7 into spec-kit and OpenSpec.
- Researcher 1 (notes-1) read superpowers, mattpocock/skills and elephant-goldfish-model from shallow clones.
- Researcher 2 (notes-2) read spec-kit and OpenSpec from shallow clones. Its issue search hit the REST rate limit.
- Researcher 3 (notes-3) read gsd-core and BMAD-METHOD from shallow clones.
- Researcher 4 (notes-4) searched issues, pull requests and discussions in all seven repositories through GraphQL, after REST search was rate-limited.
- Researcher 5 (notes-5) read mattpocock/skills at bbadaa6 in full and checked PR ancestry with `gh api`.
- Researcher 6 (notes-6) read BMAD-METHOD at e435a22 and, beyond the brief's default-branch scope, the `dev` branch at 76887e81.
- Researcher 7 (notes-7) read the closed-vocabulary preset and both CHANGELOGs through `gh api`.
- All checks were read-only. Clones went into temporary folders, nothing was run from them, and they were deleted afterwards.
- A source check on 2026-11-28 reread the cited skill files at the pinned commits, the cited issues and PRs, the branch heads and latest releases (all unchanged), and reran GraphQL searches for gsd-core, BMAD-METHOD and elephant-goldfish-model. It added gsd-core's plan-review term check, which the grep in that section matches, to the table, the Answer and the gsd-core findings; narrowed the renaming-rule bullet, the spec-kit grep result and the d80fa0f date; and corrected PR #1228's merge date to 2026-10-27. All sections were checked.
