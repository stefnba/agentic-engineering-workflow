# Writing an architecture doc from code in seven reference repositories and v1

No reference repository writes a single current-state architecture doc from code with a cite on every claim, so `write-architecture` fills a gap `[inferred]`. Two come close. GSD's `map-codebase` writes an `ARCHITECTURE.md` with path cites through parallel mappers. Elephant Goldfish Model (EGM) writes per-directory READMEs with `[file:symbol]` cites. The ideas worth taking are about keeping claims true: verify every cite before writing, record the commit the doc was built from, and keep each sub-agent's brief free of intent.

Sources and method: shallow clones at HEAD, read on 2026-11-26, one research sub-agent per source in a fresh context window; nothing from the clones was executed. Our v1 was read with `git show v1-final:<path>`. One claim per external source was re-checked by `grep` against the clone. Paths are relative to each repository. `[read]` marks a claim an agent saw in a file. `[inferred]` marks a conclusion.

| Source | Commit read |
| --- | --- |
| obra/superpowers | `22f0b46` |
| mattpocock/skills | `6f7f783` |
| google/elephant-goldfish-model | `4693375` |
| github/spec-kit | `f201054` |
| Fission-AI/OpenSpec | `f1cd852` |
| open-gsd/gsd-core | `26429a6` |
| bmad-code-org/BMAD-METHOD | `e435a22` (HEAD) and `e6cdc93` (tag v6.6.0) |
| This repository, v1 | tag `v1-final` |

## Per source

### obra/superpowers

- **No skill maps a codebase or writes an architecture doc.** Mentions of architecture are passing ones `[read: skills/writing-plans/SKILL.md:63]`.
- **brainstorming reads code before asking.** "Keep reading until you can explain how the relevant parts work today" `[read: skills/brainstorming/SKILL.md:42-50]`. The reading serves one change and is not stored `[inferred]`.
- **A fresh reader checks the finished document.** `builder-check-prompt.md` asks a fresh agent to report only the questions where a wrong guess would matter, ranked `[read: skills/brainstorming/builder-check-prompt.md:7-22]`.
- **Parallel agents get a scope, a goal, constraints and an expected output.** One agent per independent domain, no concurrency cap `[read: skills/dispatching-parallel-agents/SKILL.md:60-74]`.
- **The merge spot-checks agent output**, because "Agents can make systematic errors" `[read: skills/dispatching-parallel-agents/SKILL.md:167]`.
- **Exploration is listed as a reason not to split.** "You don't know what's broken yet" `[read: skills/dispatching-parallel-agents/SKILL.md:133]`.
- **Nothing cites code, and nothing is refreshed.** Specs are dated and never rewritten `[read: docs/superpowers/specs/2026-05-05-platform-neutral-prose-design.md:24]`.

### mattpocock/skills

- **No skill writes an architecture doc or maps current state** `[inferred from a listing of skills/]`.
- **`improve-codebase-architecture` reports friction, not shape.** It writes an HTML report of "deepening opportunities" to the OS temp folder, so nothing lands in the repository `[read: skills/engineering/improve-codebase-architecture/SKILL.md:9,39]`.
- **One sub-agent "with a fresh context window" explores "organically"** `[read: improve-codebase-architecture/SKILL.md:27]`. There is no split and no merge `[inferred]`.
- **A controlled vocabulary binds the output.** The skill must use `codebase-design`'s terms and not drift into "component, service, API, boundary" `[read: improve-codebase-architecture/SKILL.md:13]`.
- **ADRs are read first and not re-litigated** unless the friction is real `[read: improve-codebase-architecture/SKILL.md:56]`.
- **The ADR test has three parts:** hard to reverse, surprising, a real trade-off `[read: skills/engineering/domain-modeling/ADR-FORMAT.md:31-37]`.
- **`zoom-out`, an on-demand overview skill, was removed** because it "went unused in practice" `[read: CHANGELOG.md:350]`.
- **Claims carry a file list but no cites, and no step verifies them** `[inferred: none found]`.

### google/elephant-goldfish-model

- **`egm-bootstrap` writes a README contract per code directory.** The user must invoke it; `disable-model-invocation: true` is set `[read: skills/egm-bootstrap/SKILL.md:1-6]`.
- **Three templates:**
  - Component Package, for a leaf: Overview, Interface, Invariants, Side Effects, Verification.
  - Root Blueprint: System Overview, Subdirectories and Boundaries, Global Invariants, Global Side Effects, System Verification.
  - Intermediate Blueprint: Overview, Subdirectories and Boundaries.

  `[read: skills/egm-bootstrap/references/templates.md:13-68]`
- **The scout prompt bans claims from names.** "Never infer RPC methods, routes, status enums, or invariants from file or directory names alone." Every entry cites `[file:symbol_or_flag]`, and an empty field returns `["None"]` `[read: SKILL.md:74]`.
- **A test enforces the ban.** A `refund_service/` holding one helper must not produce `RefundService` `[read: skills/egm-bootstrap/test_scenarios.yaml:50-68]`.
- **Work splits by subtree, at most five workers.** More than five directories triggers partitioning into three to five subtree roots `[read: SKILL.md:28,62-69]`.
- **Scouts read about 1,500-line chunks** cut at top-level definitions, at most five at a time. Each returns `{interface, invariants, side_effects}` as JSON `[read: SKILL.md:73,77]`.
- **Reading order is fixed:** contracts, schemas and manifests, then entry points, then the rest; tests ignored `[read: SKILL.md:77]`.
- **Imports and manifests are checked** before a dependency is attributed to local code `[read: SKILL.md:77]`.
- **A final pass re-reads every contract.** It confirms cites point at real symbols and relative links exist `[read: SKILL.md:88-91]`.
- **Existing READMEs are merged, never blindly overwritten.** Valid developer notes are kept. There is no approval step, only a gate above 15 directories `[read: SKILL.md:29,76]`.
- **The design doc specifies sentinel blocks that the skill never mentions** `[read: docs/designs/bootstrap.md:561-593]`. Spec and skill have drifted `[inferred]`.
- **Drift checking is a separate, opt-in skill.** `egm-drift-report` also counts code no doc covers as drift `[read: skills/egm-drift-report/SKILL.md:62-63]`.

### github/spec-kit

- **The core has no command that documents an existing system.** That work lives in community extensions outside the repo `[read: docs/community/extensions.md:41-58]`.
- **The guide warns against it as a first feature.** Do not make "document the entire existing system" the first feature `[read: docs/how-to/existing-projects.md:62-64]`.
- **`plan` designs one feature's future state.** Its template has Technical Context, a Constitution Check gate, Project Structure and Complexity Tracking `[read: templates/plan-template.md]`.
- **Unknowns are marked, not guessed.** Each Technical Context field reads "or NEEDS CLARIFICATION" until research resolves it `[read: templates/plan-template.md:13-37]`.
- **The template says to delete unused options and use real paths** `[read: templates/plan-template.md:59-101]`.
- **`converge` checks code against artifacts.** "Completion claims are not evidence"; it is bounded by a code-scope map from the plan's paths `[read: templates/commands/converge.md:140-150]`.
- **Phase 0 dispatches research agents**, one per unknown and one per technology, with no cap `[read: templates/commands/plan.md:121-128]`.
- **No claim cites code** `[inferred]`.

### Fission-AI/OpenSpec

- **No skill writes an architecture doc.** `openspec-explore` may "map existing architecture", but the map stays in the conversation `[read: skills/openspec-explore/SKILL.md:78-82]`.
- **Specs hold behaviour, never structure.** "If the implementation can change without changing externally visible behavior, it likely does not belong" `[read: schemas/spec-driven/schema.yaml:57-72]`.
- **Structure appears only in a per-change `design.md`**, which describes a proposal, not current state `[read: schemas/spec-driven/templates/design.md]`.
- **Back-filling is discouraged.** Specs written for unchanged code "go stale, because nothing forces them to track reality" `[read: docs/existing-projects.md:123]`.
- **`project.md` was retired** because agents read the passive file unreliably. Context is now injected into each artifact instruction `[read: docs/migration-guide.md:69]`.
- **Sync never invents a missing requirement.** It refuses a MODIFIED delta on a spec that does not exist `[read: skills/openspec-sync-specs/SKILL.md:110-114]`.
- **Sync keeps content the delta does not mention** `[read: skills/openspec-sync-specs/SKILL.md:116-128]`.
- **Verify never scores a skipped check as passing** `[read: skills/openspec-verify-change/SKILL.md:178]`.
- **Conflicts are settled by code evidence** `[read: skills/openspec-bulk-archive-change/SKILL.md:123-136]`.
- **No parallel sub-agents.** Delegation, when used, is synchronous `[read: skills/openspec-archive-change/SKILL.md:153]`.

### open-gsd/gsd-core

- **`map-codebase` writes seven docs into `.planning/codebase/`**: STACK, INTEGRATIONS, ARCHITECTURE, STRUCTURE, CONVENTIONS, TESTING and CONCERNS `[read: agents/gsd-codebase-mapper.md:198-802]`.
- **Its ARCHITECTURE template is the closest to ours.** Sections include System Overview, Component Responsibilities (Component, Responsibility, File), Layers, Data Flow with a Primary Request Path, Key Abstractions, Entry Points and Cross-Cutting Concerns `[read: agents/gsd-codebase-mapper.md:338-461]`.
- **Every finding needs a file path.** "No exceptions"; request-path steps cite `file:line` `[read: agents/gsd-codebase-mapper.md:396-398,830]`.
- **It is told to prescribe.** "Be prescriptive, not descriptive", and it has Anti-Patterns and CONCERNS sections `[read: agents/gsd-codebase-mapper.md:79]`.
- **Four mappers split by focus, not by directory:** tech, arch, quality and concerns `[read: gsd-core/workflows/map-codebase.md:160-278]`.
- **Mappers write the files and return about ten lines.** The stated reason is fresh context per domain and "no context transfer back to orchestrator" `[read: workflows/map-codebase.md:17-21]`.
- **Verification is mechanical.** Each file must exist and exceed 20 lines; cites are never checked `[read: workflows/map-codebase.md:354-366]`.
- **A shell step stamps the commit the map was built from.** "A shell step cannot be skipped by a confident agent" `[read: workflows/map-codebase.md:371-391]`.
- **A drift gate diffs HEAD against that stamp** after each phase. It warns by default and never blocks `[read: execute-phase/steps/codebase-drift-gate.md:23]`.
- **Existing docs get a choice**: refresh, update chosen docs, or skip `[read: workflows/map-codebase.md:89-129]`.
- **Secrets are kept out three ways:** a forbidden-files list, ".env: note existence only", and a regex scan before commit `[read: agents/gsd-codebase-mapper.md:117-119,804-824; workflows/map-codebase.md:405-438]`.
- **Templates sit in two places and differ.** Six of seven exist only inline in the agent; `templates/codebase/` holds older versions of two `[read: ls templates/codebase/]`.
- **Without sub-agents the four passes run in sequence** `[read: workflows/map-codebase.md:319-351]`.

### bmad-code-org/BMAD-METHOD

- **BMAD retired its brownfield documenter.** `document-project` and `generate-project-context` gave way to `bmad-project-context`; `create-architecture` became `bmad-architecture` `[read: skills/method/bmod-method/retired.toml; CHANGELOG.md:81,199]`.
- **v6 `document-project` produced many files** from one 1108-line instruction file: an index, a source tree, an overview and per-part architecture docs `[read: v6.6.0 full-scan-instructions.md:538-563]`.
- **v6 batched by subfolder without sub-agents.** Read, write findings, then "PURGE detailed findings from context" `[read: v6.6.0 full-scan-instructions.md:297]`.
- **HEAD excludes what v6 produced.** "Repo overviews, directory trees, stack lists — Derived fresh, more accurately; stored copies rot" `[read: skills/method/bmad-project-context/references/best-practices.md:28]`.
- **A size rule backs it.** Every line "is charged every session" `[read: best-practices.md:9]`.
- **HEAD records provenance.** A comment "Verified <date> against <sha>" sits inside the managed block `[read: bmad-project-context/references/template.md:3-18]`.
- **Refresh diffs from that SHA** `[read: bmad-project-context/SKILL.md:91]`.
- **Every claim naming a file is path-checked** `[read: bmad-project-context/SKILL.md:53]`.
- **A ledger records each existing line's fate**: retain, rewrite, relocate, automate or delete `[read: bmad-project-context/SKILL.md:39]`.
- **`bmad-deep-recon` splits by layout area from `git ls-tree`**, not from the ask `[read: skills/core-tools/bmad-deep-recon/references/codebase.md:5]`.
- **Its sub-agents get only the question, not the intent** `[read: bmad-deep-recon/references/codebase.md:23]`.
- **Fresh verifier agents re-check claims** "so the researcher's reading cannot become yours" `[read: bmad-deep-recon/references/codebase-verifier.md:3]`.
- **Its cites pin a line and commit**: `path:line (symbol) @ sha` `[read: bmad-deep-recon/references/codebase-analyzer.md:5-7]`.
- **`bmad-architecture` writes a spine of decisions for planning**, with `AD-n` rules, not current state `[read: skills/method/bmad-architecture/SKILL.md:9,17]`.
- **"Explain this system" is still a planned capability** `[read: CHANGELOG.md:81]`.

### This repository, v1

- **No v1 skill wrote an architecture doc from code** `[inferred from git grep]`.
- **`scan-codebase` returned improvement findings inline**, never to a file, and refused doc drift `[read: v1-final:skills/scan-codebase/SKILL.md:3; agents/scanner.md:21]`.
- **Its scanner verified every hit.** "A finding you didn't check is noise wearing a `file:line`" `[read: v1-final:agents/scanner.md:35-36]`.
- **It read decision records first** and did not re-report settled friction `[read: v1-final:agents/scanner.md:30-32]`.
- **An empty report was valid**, and padding was rejected `[read: v1-final:agents/scanner.md:45-46]`.
- **Behaviour was split over three files** with Claude-only front matter: the skill, `agents/scanner.md` and a preloaded `code-design` `[read: v1-final:skills/scan-codebase/SKILL.md:4-8; agents/scanner.md:4-7]`.
- **Decision 0009 rejected a central architecture doc.** A subsystem's target state lived in a colocated `README.md`; a central doc "is never in the diff of the change that falsifies it" `[read: v1-final:docs/decisions/2026-08-10-system-docs-are-colocated.md:15,19]`.
- **0009 named its own cost**: "no single place to read the whole architecture" `[read: 2026-08-10-system-docs-are-colocated.md:24]`.
- **0009 named when to revisit it**: when tooling surfaces central-doc staleness in review `[read: 2026-08-10-system-docs-are-colocated.md:29]`.
- **v1 docs held target state**, which v2 rejects for `ARCHITECTURE.md` `[read: v1-final:workflow/artifacts.md:23]`.

## Comparison

| Source | Closest equivalent | Output | Current state only | Cite form | Split over sub-agents | Truth check | Existing doc |
| --- | --- | --- | --- | --- | --- | --- | --- |
| superpowers | brainstorming recon | None stored | Not applicable | None | Per domain, no cap | Fresh-reader check | Not applicable |
| mattpocock/skills | `improve-codebase-architecture` | HTML report in temp | No; friction | File list | One explorer | None | Not applicable |
| EGM | `egm-bootstrap` | README per directory | Yes, plus invariants | `[file:symbol]` | Subtrees, ≤5 workers, ≤5 scouts each | Final re-read of cites and links | Merged, notes kept |
| spec-kit | `plan` | Per-feature plan | No; planned | None | Per unknown, no cap | NEEDS CLARIFICATION, gates | Not applicable |
| OpenSpec | `explore`, living specs | Behaviour specs | Specs yes, design no | None | None | Code settles conflicts | Delta merge |
| GSD | `map-codebase` | Seven docs, one `ARCHITECTURE.md` | Claimed, but prescriptive | `file:line` | Four by focus | File exists, >20 lines | Refresh, update or skip |
| BMAD | v6 `document-project`; HEAD `deep-recon` | v6 many files; HEAD none | v6 mixed | HEAD `path:line (symbol) @ sha` | v6 none; HEAD per layout area | HEAD fresh verifiers | HEAD ledger per line |
| v1 | `scan-codebase` | Inline findings | No; findings | `path:line` | One fork | Verify every hit | Not applicable |
| Ours | `write-architecture` | One `docs/ARCHITECTURE.md` | Yes | `[path:symbol]` | Per subsystem, ≤5 | Drop uncitable claims | Approval of each change |

## Recommendations for `write-architecture`

### Adopt

- **Check every cite before writing the file.** Open each `[path:symbol]` and drop or report any that does not resolve, then check links exist.
  - Reason: our rule "drop a claim you cannot cite" trusts the sub-agent's cite; GSD shows path cites going unchecked.
  - Source: EGM `SKILL.md:88-91`; superpowers spot check; GSD as the counter-example.
- **Record the commit the doc was built from**, as one line in `docs/ARCHITECTURE.md`.
  - Reason: an update can then list the cited files changed since that commit, which gives the "no longer matches the code" trigger something to test. A line in the file needs no front matter or script.
  - Source: BMAD `template.md:3-18` and `SKILL.md:91`; GSD stamp and drift gate.
- **Give each part's fresh context window a self-contained brief without the caller's intent**: the part's paths, read-only, the read order, the skip list and the return shape.
  - Reason: a window that knows what is being built reads intent into code. `extract.md` now says only "returns its claims with cites".
  - Source: BMAD deep-recon `codebase.md:23`; superpowers `dispatching-parallel-agents/SKILL.md:60-64`.
- **State the return shape in prose in `references/extract.md`**: the part, its claims each with a cite, candidate decisions, candidate terms, and unconfirmed claims.
  - Reason: a fixed shape makes the merge mechanical, and prose works under both harnesses.
  - Source: EGM `worker-return.schema.json`; GSD's compact returns.
- **Name the ban on claims from names in the extraction rules**, with an example: no route, status value or rule from a file or folder name.
  - Reason: `extract.md` already says it; EGM adds the example of a folder named after a service that holds one helper, which makes the rule concrete.
  - Source: EGM `SKILL.md:74`, `test_scenarios.yaml:50-68`.
- **Read existing decision records and `docs/GLOSSARY.md` before extracting.** Skip candidate decisions already recorded, and use glossary terms in the Parts table.
  - Reason: re-proposing a settled decision wastes the owner's review; matching terms keeps the knowledge files consistent.
  - Source: v1 `agents/scanner.md:30-32`; mattpocock `improve-codebase-architecture/SKILL.md:56`.
- **Filter candidate decisions by the record-decision test** before returning them: hard to reverse, affects more than one feature, a real alternative existed.
  - Reason: the caller hands them to `record-decision`, which applies the same test; filtering early keeps the report short.
  - Source: mattpocock `ADR-FORMAT.md:31-37`; `docs/workflow-design.md`, "Keeping agents restrained".
- **Never quote secrets.** Note that `.env` and credential files exist; never copy their values.
  - Reason: the doc is committed and read by every agent.
  - Source: GSD `gsd-codebase-mapper.md:117-119,804-824`.
- **Report parts that were not read as not read**, never as empty.
  - Reason: a failed or skipped window looks the same as a part with nothing to say.
  - Source: OpenSpec `openspec-verify-change/SKILL.md:178`; EGM marks a failed subtree.

### Consider

- **A fresh-reader check after writing.** A fresh context window reads only `docs/ARCHITECTURE.md` and reports what it would have to guess.
  - Fit: plain prose, both harnesses. It matches the fresh-context check `docs-init` already plans.
  - Source: superpowers `builder-check-prompt.md`.
- **A list of what does not belong**: directory trees, stack lists, restatements of one file, plans, anti-patterns.
  - Fit: `extract.md` covers restatement already; a short list in the template comment would cover the rest.
  - Source: BMAD `best-practices.md:28`; GSD `templates/codebase/architecture.md`.
- **Count code that no part covers as a gap.** List source directories outside every part.
  - Fit: cheap, and it shows coverage the subsystem split might miss.
  - Source: EGM `egm-drift-report/SKILL.md:62-63`.
- **Split an oversized part by top-level definitions** instead of by subfolder when one folder holds most of the code.
  - Fit: our "more than about 50 source files" rule assumes nested folders.
  - Source: EGM `SKILL.md:73,77`.
- **A dependency kind per row in "Data and external systems"**: in-process, local stand-in, owned remote, true external.
  - Fit: tells a later `implement` what it can run locally; costs one column.
  - Source: mattpocock `DEEPENING.md:9-25`.
- **A line in `AGENTS.md` that points at `docs/ARCHITECTURE.md`.**
  - Fit: OpenSpec retired its passive context file because agents skipped it. The pointer belongs to `setup` or `describe-project`, not here, since this skill writes only `ARCHITECTURE.md`.
  - Source: OpenSpec `docs/migration-guide.md:69`.
- **Supersede v1's decision 0009 with a record of why one root doc now wins.**
  - Fit: 0009 named the condition to revisit, staleness surfaced in review; cites plus a recorded commit meet it in part `[inferred]`.
  - Source: v1 `2026-08-10-system-docs-are-colocated.md:29`.

### Avoid

- **Prescriptive sections such as Anti-Patterns, Concerns or "use X pattern".**
  - Reason: they mix guidance into a current-state doc; improvement findings belong elsewhere, as v1 kept them.
  - Source: GSD `gsd-codebase-mapper.md:79`; v1 `scan-codebase`.
- **Splitting by focus area instead of by subsystem.**
  - Reason: GSD's split fits seven docs. We write one, and a split by subsystem gives each Parts row one owner `[inferred]`.
  - Source: GSD `workflows/map-codebase.md:160-278`.
- **Sub-agents that write the file directly.**
  - Reason: the parent must check cites and merge; GSD's direct writes leave only a size check.
  - Source: GSD `workflows/map-codebase.md:354-366`.
- **`path:line` cites.**
  - Reason: they break on every edit above the line. `[path:symbol]` with one recorded commit is sturdier.
  - Source: v1 `scan-report.md:14`; GSD; BMAD deep-recon.
- **Per-directory docs, many output files or a generated folder.**
  - Reason: each file is one more thing to drift; BMAD retired v6's many outputs, and our design keeps one root doc.
  - Source: EGM; BMAD v6 `full-scan-instructions.md`; GSD `.planning/codebase/`.
- **Decisions or plans inside the architecture doc.**
  - Reason: decisions go to `record-decision`, and plans to `docs/PROJECT.md` or the tracker.
  - Source: BMAD `bmad-architecture` `AD-n`; spec-kit Structure Decision.
- **Recursive self-invocation with internal flags.**
  - Reason: a worker that reruns the same skill with `is_worker` is harder to follow than a plain brief to a fresh context window.
  - Source: EGM `SKILL.md:67-69`.
- **Harness mechanics in skill text**: tool names, agent types, `allowed-tools`, `disable-model-invocation`, plugin-root variables, shared `agents/` or `resources/` folders, a CLI.
  - Reason: they break the rules in `AGENTS.md`; every reference except mattpocock/skills uses some of them.
  - Source: EGM `SKILL.md:10-11,24`; GSD command front matter; OpenSpec `SKILL.md:4-9`; v1 `scan-codebase` front matter.
- **A behaviour spec kept separate from the skill.**
  - Reason: EGM's design doc specifies sentinel blocks the skill never implements. Keep each rule in the skill.
  - Source: EGM `docs/designs/bootstrap.md:561-593`.
