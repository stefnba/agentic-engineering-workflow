---
question: "How do the seven reference repositories (obra/superpowers, mattpocock/skills, google/elephant-goldfish-model, github/spec-kit, Fission-AI/OpenSpec, open-gsd/gsd-core, bmad-code-org/BMAD-METHOD) map an existing codebase and write a description of its architecture from the code, if they do at all?"
researched: "2026-11-28"
versions: "obra/superpowers main 22f0b46 (v7.0.2); mattpocock/skills main bbadaa6 (1.3.2); google/elephant-goldfish-model main 4693375 (v0.1.1); github/spec-kit main f201054 (v1.4.5); Fission-AI/OpenSpec main dff0188 (v2.2.0); open-gsd/gsd-core next e9c3e54 (v1.23.0); bmad-code-org/BMAD-METHOD main e435a22 (v6.12.4)"
---

# Mapping an existing codebase into an architecture description in seven agent-workflow repositories

## Answer

Two of the seven repositories ship a core step that writes a standing description of an existing codebase from its code: elephant-goldfish-model (EGM) and gsd-core. The other five write none, and three of them say so on purpose. The table gives each repository on each facet, at the commit in the front matter.

| Repository | What maps the code, and what it writes | How reading is split | Cites, and how they are checked | Check before saving | Kept current, and stamp |
| --- | --- | --- | --- | --- | --- |
| obra/superpowers | Nothing. `brainstorming` and `writing-plans` read code only for the planned change | No subagent reads the code | No cite rule | User review of plans | Dated filenames; no refresh |
| mattpocock/skills | Nothing standing. `improve-codebase-architecture` writes a review of friction as HTML in the temp directory | One fresh-context subagent, aimed at hot spots from `git log` | A **Files** field per card; no check | None; the user picks a candidate | A new timestamped file per run; date, no commit |
| EGM | `egm-bootstrap` writes a contract file per code directory and a root Blueprint | Root, then up to 5 subtree workers, then read-only scouts per ~1,500-line chunk | `[file:symbol_or_flag]` per entry; checked only by agent instruction | The orchestrator re-reads its own output; drift report optional | Re-run merges with existing files; no commit or date stamp |
| github/spec-kit (core) | Nothing; its guide advises against documenting the whole system first. Discovery is left to community extensions | None on the code | No cite rule | User reviews each command's output | Only a pointer block to the latest plan |
| Fission-AI/OpenSpec | Nothing, by design. `/opsx:explore` maps the area about to change | None | `file.ts:123` only in verify-change reports | Yes/no before any write | Nothing to keep; specs grow per change |
| open-gsd/gsd-core | `/gsd-map-codebase` writes seven documents to `.planning/codebase/`, among them `ARCHITECTURE.md`. `/gsd-docs-update` writes `docs/ARCHITECTURE.md` | Four parallel mappers by topic; sequential without an Agent tool | Backticked paths and `file:line`. The map's cites go unchecked; the docs-update verifier checks path existence and greps names | Map: files exist with over 20 lines, then a secret scan and a commit. Docs: verifier plus a two-round fix loop | A shell step stamps `last_mapped_commit`; a drift gate warns or remaps |
| BMAD-METHOD | Nothing since v6.11.0 retired `bmad-document-project`. `bmad-project-context` writes one verified block in `AGENTS.md`; `bmad-architecture` writes a spine of decisions | Parallel subagents by evidence type; no brief text ships | Project context: inline paths, path-checked by the agent. Spine: no code cites | Project context: the user approves the whole block. Spine: a lint script plus parallel reviewers | Block: "Verified <date> against <sha>", refreshed on request. Spine: dates only |

- **Where they agree.** Inferred: no repository resolves a line or symbol cite against the code by script, from the EGM, gsd-core and BMAD findings below. EGM's symbol cites and BMAD's path checks are agent instructions. gsd-core's verifier checks that a path exists and greps for a function name.
- **Where they differ.** OpenSpec, spec-kit core and BMAD advise against generated codebase descriptions; BMAD calls its retired output "Large, unverified, stale on arrival". gsd-core instead builds planning and drift gating on its seven generated maps. EGM spreads its output over one file per directory.
- **Commit stamps.** Only gsd-core writes the code state by script; it argues that an agent can rewrite dates without redoing the work. BMAD's block records a sha, and EGM records none.
- **Community spec-kit extensions.** Several write code-derived descriptions. Inferred, from the extension findings: only `blueprint-index` checks cites by script, and only it stamps sections with a git object hash. `codebase-memory-context` records `source_commit` but was not seen to compare it.
- **Reported problems.** Most reports concern gsd-core, BMAD and EGM:
  - gsd-core: stale maps that read as fresh.
  - EGM: content invented from file names (#109).
  - BMAD: low-value generated context (PR #2689).
  - EGM: areas missed by fixed filters (#300).
  - Cost: unbounded fan-out (BMAD #3194, EGM #350) and repeated context loads (gsd-core D#655).
  - No report found describes a generated architecture document whose cites do not match the code.
- **How firm this is.** Inferred: three answers date fast, from the dating findings below. BMAD `dev` retires `bmad-architecture` for v7. gsd-core `next` is ahead of v1.23.0. arch, a spec-kit catalog entry, retired its code-to-architecture command after the catalog version. Issue coverage is thin: REST search was rate-limited, and several items rest on titles only.

## How do obra/superpowers and mattpocock/skills map an existing codebase and write a description of its architecture, on each facet in Constraints, or do they not?

### mattpocock/skills at bbadaa6

- `improve-codebase-architecture` is user-invoked (`disable-model-invocation: true`) and reviews friction rather than describing the codebase ([SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/improve-codebase-architecture/SKILL.md)).
- It writes one file outside the repository: "write to `<tmpdir>/architecture-review-<timestamp>.html` so each run gets a fresh file" (same file).
- Each card holds **Files**, **Problem**, **Solution**, **Benefits**, a before/after diagram and a recommendation strength (same file). The report header holds "Repo name, date, and a compact legend" ([HTML-REPORT.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/improve-codebase-architecture/HTML-REPORT.md)).
- The main agent picks the scope from the user, or else will "walk back a good stretch of the commit history (`git log --oneline`) to find the codebase's hot spots" ([SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/improve-codebase-architecture/SKILL.md)).
- It then sends one subagent: "spawn a sub-agent with a fresh context window to walk the codebase … note where you experience friction". The brief is a list of friction questions, not a split by area (same file).
- The fresh-context rule was added because some harnesses fork the conversation by default, naming Codex ([CHANGELOG.md, PR #1341, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/CHANGELOG.md)).
- The **Files** field reads "which files/modules are involved". No step checks it ([SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/engineering/improve-codebase-architecture/SKILL.md)).
- After writing, the skill asks "Which of these would you like to explore?" with no review step (same file).
- Issue #1437, closed 2026-11-25, asked for a configurable destination; its body says "nothing links an old report back to the code state it described". The owner kept the temp default: "I keep the skills free of config options like an env var or flag" (tested 2026-11-28: `gh api --method GET repos/mattpocock/skills/issues/1437`).
- `zoom-out`, which asked for "a map of all the relevant modules and callers" in chat, was removed on 2026-06-17 in `e112a6b` because it "went unused in practice" (tested 2026-11-28: `git log --diff-filter=D -- '*zoom-out*'`; [CHANGELOG.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/CHANGELOG.md)).
- The in-progress `chief-of-staff` skill ties claims about code to a commit: "When a claim concerns code, cite the commit it was true at, with its repo" ([chief-of-staff/SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa6/skills/in-progress/chief-of-staff/SKILL.md)).

### obra/superpowers at 22f0b46

- `brainstorming` reads the project "until you can explain how the relevant parts work today and what this change would touch". It writes a design for new work to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` ([brainstorming/SKILL.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b46/skills/brainstorming/SKILL.md)).
- `writing-plans` maps only the files of the planned change: "map out which files will be created or modified". It ends with "Please review the plan" ([writing-plans/SKILL.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b46/skills/writing-plans/SKILL.md)).
- `dispatching-parallel-agents` splits work by independent problem, not by code area ([dispatching-parallel-agents/SKILL.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b46/skills/dispatching-parallel-agents/SKILL.md)).
- No file matched codebase-mapping terms beyond these (grep of `skills/`, `README.md`, `AGENTS.md` and `docs/`, run 2026-11-28).
- Specs and plans carry a date in the filename, and nothing refreshes them ([brainstorming/SKILL.md](https://github.com/obra/superpowers/blob/22f0b46/skills/brainstorming/SKILL.md), [writing-plans/SKILL.md](https://github.com/obra/superpowers/blob/22f0b46/skills/writing-plans/SKILL.md), 22f0b46).

## How do google/elephant-goldfish-model and github/spec-kit (including its extensions or presets catalog in the repository) do this, on each facet, or do they not?

### elephant-goldfish-model at 4693375

- `egm-bootstrap` writes contract files across a directory tree. It writes leaf "Peanuts" with `Overview`, `Interface`, `Invariants`, `Side Effects` and `Verification`, and parent "Hay" indexes ([SKILL.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/skills/egm-bootstrap/SKILL.md); [references/templates.md](https://github.com/google/elephant-goldfish-model/blob/4693375/skills/egm-bootstrap/references/templates.md)).
- The root Blueprint has `System Overview`, `Subdirectories & System Boundaries`, `Global Invariants`, `Global Side Effects` and `System Verification` ([references/templates.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/skills/egm-bootstrap/references/templates.md)).
- The file name defaults to `README.md`, "or e.g. `\"EGM.md\"` when preserving human-written READMEs". The skill never commits ([SKILL.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/skills/egm-bootstrap/SKILL.md)).
- Discovery is breadth-first and prunes hidden, vendor, build, ignored and test-only directories against a fixed list of source extensions (same file).
- Trees of 5 or fewer pruned directories run inline. Larger trees are partitioned into 3 to 5 subtrees, one worker each, at most 5 in parallel (same file).
- The worker brief is one line: `"Run egm-bootstrap with path=[path], is_worker=true, sub_tree_root=[partition_root], target_filename=[target_filename]."` Workers return JSON in which only `path` and `summary` are required (same file; [worker-return.schema.json](https://github.com/google/elephant-goldfish-model/blob/4693375/skills/egm-bootstrap/references/worker-return.schema.json)).
- Read-only `goldfish-explorer` scouts read one chunk of about 1,500 lines each, cut at top-level definitions, at most 5 at a time ([SKILL.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/skills/egm-bootstrap/SKILL.md)).
- The scout brief: "Never infer RPC methods, routes, status enums, or invariants from file or directory names alone; cite exact `[file:symbol_or_flag]` for every entry" (same file).
- Work runs bottom-up, and each parent's scout brief carries its children's merged interfaces (same file).
- Trees over 15 directories need user approval before the run (same file).
- When subagents are unavailable, "`egm-bootstrap` runs scout steps inline". Subagents are spawned with each harness's own tool, listed as "Claude Code: `Agent`; Codex: `spawn_agent`" ([execution_instructions.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/resources/execution_instructions.md)).
- Before attributing RPCs or schemas locally, a scout must "Verify build-manifest deps and `import` / `#include`" ([SKILL.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/skills/egm-bootstrap/SKILL.md)).
- On a re-run, existing contracts are read, "never blindly overwrite", and merged "with code-verified scout output" (same file).
- No template has a field for commit, date or version. A grep for `sentinel|EGM_BLUEPRINT` matched only the design doc, not the skill (tested 2026-11-28: `grep -rn -i -E "sentinel|EGM_BLUEPRINT" skills docs agents resources README.md`).
- The design doc, dated 2026-06-29 and marked Current, still describes a 50,000-byte per-directory cap, a 300-line per-file limit and sentinel markers. The current skill says "No per-directory or per-file byte cap" ([docs/designs/bootstrap.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/docs/designs/bootstrap.md)).

### spec-kit core at f201054

- The existing-project guide advises: "Do not make \"document the entire existing system\" your first feature unless that inventory is itself the intended deliverable" ([docs/how-to/existing-projects.md, f201054](https://github.com/github/spec-kit/blob/f201054/docs/how-to/existing-projects.md)).
- The same guide sends readers to the catalog: "Community extensions for architecture discovery and brownfield bootstrapping are listed in the [extension catalog]".
- The guide says to "review the result before moving to the next step" after each command.
- `/speckit-constitution` reads the repository's "README, architecture decisions, contribution guide, and CI configuration as evidence" and writes `/memory/constitution.md` (same guide; [templates/commands/constitution.md, f201054](https://github.com/github/spec-kit/blob/f201054/templates/commands/constitution.md)).
- `plan` Phase 0 dispatches research agents to unknowns and technology choices, not to the codebase ([templates/commands/plan.md, f201054](https://github.com/github/spec-kit/blob/f201054/templates/commands/plan.md)).
- The bundled `agent-context` extension only keeps a managed block that "points at the most recent plan path" ([speckit.agent-context.update.md, f201054](https://github.com/github/spec-kit/blob/f201054/extensions/agent-context/commands/speckit.agent-context.update.md)).
- No entry in the core extension catalog maps architecture (tested 2026-11-28: a Python filter over `extensions/catalog.json`).

## How do Fission-AI/OpenSpec and open-gsd/gsd-core do this, on each facet, or do they not?

### OpenSpec at dff0188

- "You do not document your whole codebase to start. You write specs only for what you're about to change." ([docs/existing-projects.md, dff0188](https://github.com/Fission-AI/OpenSpec/blob/dff0188/docs/existing-projects.md)).
- `/opsx:explore` will "Map existing architecture relevant to the discussion". The AI investigates in the main conversation, with no subagent named in the explore section ([src/core/templates/workflows/explore.ts, dff0188](https://github.com/Fission-AI/OpenSpec/blob/dff0188/src/core/templates/workflows/explore.ts)).
- Before any write, explore must "ask a direct yes/no question, and wait for the user's confirmation" (same file).
- Code references in `file.ts:123` form appear only in the verify-change report, which checks a change against the code ([verify-change.ts, dff0188](https://github.com/Fission-AI/OpenSpec/blob/dff0188/src/core/templates/workflows/verify-change.ts)).
- The specs directory "starts nearly empty and accumulates", and "Each archived change merges its delta in" ([docs/existing-projects.md, dff0188](https://github.com/Fission-AI/OpenSpec/blob/dff0188/docs/existing-projects.md)).

### gsd-core at e9c3e54: what maps, and how reading is split

- `/gsd-map-codebase` produces `STACK.md`, `ARCHITECTURE.md`, `CONVENTIONS.md`, `CONCERNS.md`, `STRUCTURE.md`, `TESTING.md` and `INTEGRATIONS.md` in `.planning/codebase/` ([docs/features/codebase-mapping.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/docs/features/codebase-mapping.md)).
- The maps are written for later agents. `/gsd:plan-phase` "loads relevant codebase docs when creating implementation plans", and the mapper is told "Be prescriptive, not descriptive" ([agents/gsd-codebase-mapper.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/agents/gsd-codebase-mapper.md)).
- The workflow will "Spawn 4 parallel gsd-codebase-mapper agents", one per focus: tech, arch, quality and concerns ([gsd-core/workflows/map-codebase.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/map-codebase.md)).
- The arch brief asks for `ARCHITECTURE.md` and `STRUCTURE.md`, sets the date stamps to `{date}` and scopes by optional paths. It ends "Explore thoroughly. Write documents directly using templates. Return confirmation only." (same file).
- The orchestrator gets back "Just file paths and line counts. NOT document contents." (same file).
- Without an Agent tool, named as "Antigravity, Codex", the four passes run one after another in the current context (same file). The researchers did not test this claim about Codex.
- `--fast` runs `scan.md`, which spawns one mapper for one focus with the brief `"Scan this codebase with focus: {focus}. Write results to {codebase_dir}/. Produce only: {document_list}"`. It has no stamp, verify or commit step ([gsd-core/workflows/scan.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/scan.md)).
- `--query` runs `gsd-intel-updater`, which writes five JSON files to `.planning/intel/`. It runs `gsd_run intel validate`, which warns when entry paths are missing on disk, and then `intel snapshot` ([agents/gsd-intel-updater.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/agents/gsd-intel-updater.md); [src/intel.cts](https://github.com/open-gsd/gsd-core/blob/e9c3e54/src/intel.cts)).
- `/gsd-docs-update` writes `docs/ARCHITECTURE.md` through a `gsd-doc-writer` subagent "that explores the codebase directly". Its template requires key abstractions "with a one-line description and file path" ([commands/gsd/docs-update.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/commands/gsd/docs-update.md); [agents/gsd-doc-writer.md](https://github.com/open-gsd/gsd-core/blob/e9c3e54/agents/gsd-doc-writer.md)).
- Inferred: the two architecture documents have different templates and audiences, and neither refers to the other. This rests on the mapper and doc-writer findings above and a grep for `codebase/` in the doc-writer and docs-update files, which found nothing.

### gsd-core at e9c3e54: cites and checks on the map

- The mapper's rules include "**ALWAYS INCLUDE FILE PATHS.** Every finding needs a file path in backticks." Its data-flow steps carry `` (`[file:line]`) `` ([agents/gsd-codebase-mapper.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/agents/gsd-codebase-mapper.md)).
- The map's `verify_output` step checks only "All 7 documents exist" and "No empty documents (each should have >20 lines)" ([map-codebase.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/map-codebase.md)).
- After verification come `stamp_codebase_map`, a secret-pattern grep that pauses for the user on a match, and a commit, `docs: map existing codebase`. The closing message offers "Edit any document before proceeding", after the commit (same file).

## How does bmad-code-org/BMAD-METHOD do this, on each facet, or does it not?

- v6.11.0 (2026-08-09) replaced `bmad-document-project` and `bmad-generate-project-context` with `bmad-project-context`: "no generated overview, source-tree, or deep-dive pages and no `project-context.md`, just one verified block in `AGENTS.md`" ([CHANGELOG.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/CHANGELOG.md)).
- The same entry says "The deeper 'explain this system and its rationale' altitude is a separate capability still to come."
- The project's reason: the retired skill's docs were "Large, unverified, stale on arrival: the kind of context that makes agents worse" ([theory-of-project-context.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/docs/existing-codebases/theory-of-project-context.md)).
- At v6.10.0 the retired skill had three scan levels: Quick, Deep, and Exhaustive ("reading all source files"). Its templates covered an index, an overview, a source tree and deep dives (tested 2026-11-28: `git show v6.10.0:src/bmm-skills/1-analysis/bmad-document-project/workflows/full-scan-instructions.md`).

### bmad-project-context

- It writes one block between `<!-- bmad:context -->` markers in the root `AGENTS.md` ([references/template.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-project-context/references/template.md)).
- "Repo overviews, directory trees, and tech-stack lists never enter" ([set-and-maintain-project-context.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/docs/existing-codebases/set-and-maintain-project-context.md)).
- The split rule: "Fan out with parallel subagents against what the sections need — executable config and CI …, tracked source for conventions and boundaries, targeted history for constraints" ([SKILL.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-project-context/SKILL.md)).
- No per-subagent prompt, template or return format ships in the skill's `references/` or `assets/`.
- Verification: "Path-check every claim naming a file. For every claim the block will make about what a command does, read the target or script that runs it and verify the claim." (same file).
- Cites are inline backticked paths, for example "`src/lib/money.ts`", with no line or symbol ([references/template.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-project-context/references/template.md)).
- Before saving: "**Show the complete block before writing it**", with a ledger of what happens to each existing instruction, and "Never commit." ([SKILL.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-project-context/SKILL.md)).
- The block carries `<!-- Verified 2026-08-08 against a1b2c3d. … -->`, and "Refresh diffs from that SHA" ([references/template.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-project-context/references/template.md)).
- Refresh will "re-verify every path and every caveat, and run `git log --diff-filter=DR --name-only` since the recorded SHA" ([SKILL.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-project-context/SKILL.md)). It "fires only when you name it" ([CHANGELOG.md v6.11.0](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/CHANGELOG.md)).

### bmad-architecture

- It writes an "architecture spine", "a consistency contract that fixes only the **invariants**". For brownfield code it will "read enough of the real code … to ratify the conventions already there" ([SKILL.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-architecture/SKILL.md)).
- It verifies named technologies on the web, not code cites (same file).
- The spine's frontmatter has `status` and `created`/`updated` dates, and no commit ([spine-template.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-architecture/assets/spine-template.md)).
- An update resumes "from its `.memlog.md` (the authority on what was decided)" ([SKILL.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-architecture/SKILL.md)).
- The brownfield sweep has no defined split or budget. Issue #3194 (opened 2026-11-13) reports "the brownfield investigation has no scope or budget" and three parallel "very thorough" subagents. On its status, see the dating section ([issue #3194](https://github.com/bmad-code-org/BMAD-METHOD/issues/3194); tested 2026-11-28: `gh issue view 3194`).

## What problems with mapping an existing codebase or with the resulting architecture or codebase documents (wrong or stale content, missed areas, cost, context size, cites that do not match code) are reported in the seven repositories' issues and discussions, if any?

All searches ran on 2026-11-28 through `gh api graphql` search, ranked by relevance, because REST search returned `HTTP 403: API rate limit exceeded`.

### Stale content (gsd-core)

- #3418 (2026-08-13) found that `last_mapped_commit` was never written, so drift was measured against the empty tree. PR #4124 fixed it, merged 2026-09-09 into `next` (tested 2026-11-28: `gh api graphql` on `pullRequest(number:4124){mergedAt baseRefName}`).
- #2279 (2026-07-15) found that Update runs left every date stamp at the previous run's date. PR #2550 fixed it ([#2279](https://github.com/open-gsd/gsd-core/issues/2279)).
- #4886 (2026-09-20) found that drift counted added files only, so "a commit that edits a hundred existing files ... produces `elements: []`". It was closed as superseded by epic #5056 ([#4886](https://github.com/open-gsd/gsd-core/issues/4886)).
- #1592 (2026-06-22) reported that the planner built plans against whatever `STRUCTURE.md` was on disk. PR #1595 added a `plan:pre` drift check ([#1592](https://github.com/open-gsd/gsd-core/issues/1592)).
- #6690 (2026-11-26, open) reports that onboarding reads a map as complete although the source tree "had gone from 1,188 files to 2,836" ([#6690](https://github.com/open-gsd/gsd-core/issues/6690)).
- #6236 (2026-11-16, open) reports that a file added at the repository root shows under "New directories" ([#6236](https://github.com/open-gsd/gsd-core/issues/6236)).

### Invented content and missed areas

- EGM PR #109 (merged 2026-10-28) says bootstrap "produces README contracts with RPC methods, tables, and invariants inferred from directory or file names. It also cut off large source files at 300 lines". It added the `[file:symbol_or_flag]` rule ([#109](https://github.com/google/elephant-goldfish-model/pull/109)).
- EGM #300 (2026-11-04, open) reports that a fixed extension list prunes some languages, so "the result may appear complete while omitting entire components" ([#300](https://github.com/google/elephant-goldfish-model/issues/300)).
- EGM #567 (2026-11-27, open) reports that scouts "can misclassify language-specific visibility and include generated output in module contracts" ([#567](https://github.com/google/elephant-goldfish-model/issues/567)).
- EGM PR #443 (opened 2026-11-14, closed unmerged 2026-11-21) ran bootstrap on EGM itself. The closing comment says "the generated READMEs add substantial maintenance overhead" ([#443](https://github.com/google/elephant-goldfish-model/pull/443)).
- BMAD PR #2689 (2026-08-06, closed unmerged) reported a field trial of the first `bmad-project-context` on a C++/Qt codebase: "~61% of emitted context was metadata and repeated summaries" ([#2689](https://github.com/bmad-code-org/BMAD-METHOD/pull/2689)).
- BMAD PR #2698 (merged 2026-08-09 into `main`) narrowed the skill to "a small verified block inside the repo's `AGENTS.md`" ([#2698](https://github.com/bmad-code-org/BMAD-METHOD/pull/2698)).

### Cost and context size

- gsd-core discussion #655 (2026-06-04) reports 47M tokens over 12 hours: "Each stage's input includes all prior output" ([D#655](https://github.com/open-gsd/gsd-core/discussions/655)).
- EGM PR #350 (2026-11-07) says bootstrap "requests unbounded parallel execution". It was closed in favour of PR #359, which limits workers and scouts ([#350](https://github.com/google/elephant-goldfish-model/pull/350)).
- obra/superpowers #1951 (2026-07-08) reports that grep-based exploration in `write-plan` costs "50k–200k+ tokens" ([#1951](https://github.com/obra/superpowers/issues/1951)).
- In BMAD #3194, a run scoped to one endpoint "used up a 5-hour Claude Code plan quota in about 8 minutes" ([#3194](https://github.com/bmad-code-org/BMAD-METHOD/issues/3194)).

### Cites and the value of generated docs

- obra/superpowers #2178 (2026-08-19, open) reports that the `writing-plans` template "teaches line-number citations, which go stale by construction". One plan had 11 stale cites, "roughly 30 lines past the symbol they named". This concerns plans, not architecture docs ([#2178](https://github.com/obra/superpowers/issues/2178)).
- mattpocock/skills discussion #1247 (2026-10-10) ran a blind A/B test on a 20k-line Go service, 2 runs per arm, and "found no gain in report quality" from the skill. Its author calls it "a data point, not a bug report" ([D#1247](https://github.com/mattpocock/skills/discussions/1247)).
- OpenSpec #724 (2026-02-18, open) asks to reverse-engineer specs from code ([#724](https://github.com/Fission-AI/OpenSpec/issues/724)).
- Requests for a brownfield step in spec-kit (#806, PR #1102, #1436) were answered with a community extension, not a core command ([#1436](https://github.com/github/spec-kit/issues/1436)).
- No issue in any of the seven repositories reports generated architecture-doc cites that do not match the code.

## How do the community spec-kit extensions and presets listed in spec-kit's catalogs at f201054 that map an existing codebase (such as `arch`, `brownfield`, `brownkit`, `blueprint-index`, `repoindex`, `discovery`, preset `codebase-memory-context`, and the `egm` port) do this, on each facet in Constraints, or do they not?

Each repository below was shallow-cloned on 2026-11-28 and read at its default branch. The catalogs hold 205 extensions and 44 presets (tested 2026-11-28: `gh api --method GET "repos/github/spec-kit/contents/{extensions,presets}/catalog.community.json?ref=f201054"`).

- **egm** (catalog 0.9.1; ksachdeva/spec-kit-extensions 39cefff) ports EGM from a submodule: "The source of truth for EGM behavior is the Git submodule". Its bootstrap command writes per-directory READMEs (`docs/egm-upstream-porting.md`; `extensions/egm/commands/speckit.egm.bootstrap.md`).
- egm spawns workers "in parallel without artificial concurrency limits", where upstream EGM at 4693375 caps them at 5 (same command file).
- egm's root must "explicitly read every single created or modified contract file". A grep found no commit stamp (tested 2026-11-28: `grep -n -i -E "commit|sha|stale|last.?verified|HEAD"`).
- **blueprint-index** (catalog 0.2.0; ogil109/spec-kit-blueprint 43c3329, manifest 0.3.0) writes one map at `.specify/memory/blueprint.md`. A single agent pass emits facts, and "the renderer writes" (`templates/section-anatomy.md`; `config-template.yml`).
- In blueprint-index, "Every bullet cites at least one anchor that exists". The render script "machine-validates every claim … all violations listed, nothing written" (`templates/section-anatomy.md`; `commands/speckit.blueprint-index.init.md`).
- blueprint-index sections carry `sha=` from `git rev-parse --verify --quiet "HEAD:$1"`, and "Never hand-write the `sha=` value". A "deterministic … (no LLM)" CI gate blocks on drift and dangling sections (`scripts/bash/lib/common-git.sh`; `remap.md`; README).
- **codebase-memory-context** (preset 1.1.0; philo-x 2aa0211) writes `.specify/memory/codebase.md` from one agent and an eight-area inspection table. It grades claims Verified, Corroborated, Inferred or Unknown (`commands/speckit.codebase-memory.md`).
- Before writing, codebase-memory-context must "Audit cited paths and bounded negative claims". Its frontmatter carries `source_commit` (same file; `templates/codebase-context-template.md`).
- **brownkit** (catalog 1.2.0; MaksimShevtsov/BrownKit 80c543f) writes an evidence tree and role reports, including `evidence/reports/architect-report.md` (`commands/report.md`).
- brownkit requires file paths "and line ranges where applicable" (`commands/scan.md`). Its `validate_evidence.py` checks structure and does not resolve those cites, per the researcher's reading of its source.
- **arch** at tag v1.2.2 had `full-reverse`, which wrote 4+1 views and `.specify/memory/architecture.md` "from observable repository facts" (tested 2026-11-28: `gh api --method GET "repos/bigsmartben/spec-kit-arch/contents/commands/speckit.arch.full-reverse.md?ref=v1.2.2"`).
- arch HEAD 841bc9b (v3.0.1, 2026-07-26) retired that command: it "no longer derives or updates Architecture from repository evidence" (`commands/speckit.arch.reverse.md`).
- **repoindex** 1.0.0 (3ddcbc1, no commit since 2026-03-23) saves its architecture command's output to `.github/speckit/repo_index/architecture.md` (`commands/architecture.md`).
- **brownfield**, **discovery** and **arch-governance** write something narrower. brownfield writes a spec-kit bootstrap and validation, discovery one interface contract, and arch-governance is "a read-only citation validator" (each repository's `extension.yml`, `commands/discovery.md` or `README.md` at HEAD).

## In open-gsd/gsd-core at e9c3e54, does `gsd-doc-verifier` check line numbers and symbols or only file existence, what do `scan.md`, `gsd-intel-updater` and the `stamp-codebase-map` step do, and which drift-gate fixes from epic #5056 are on `next`? (added after confirmation)

### gsd-doc-verifier

- File paths are checked for existence only: "check if the file exists using the Read or Glob tool. Mark as PASS if exists" ([agents/gsd-doc-verifier.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/agents/gsd-doc-verifier.md)).
- Function claims are a name grep in `src/`, `lib/` and `bin/`, accepting "`function <name>`, `const <name> =`, `<name>(`, or `export.*<name>`" (same file).
- Commands are checked for existence and never run (same file).
- The `line` in each failure is the doc's line, not the code's (same file).
- Inferred, from the path regex in the same file: the `:line` part of a `src/foo.ts:120` cite is never checked.
- Failing docs go back to the writer "max 2 iterations", and the loop halts on regression ([docs-update/detail/elaboration.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/docs-update/detail/elaboration.md)).

### Stamp

- `stamp-codebase-map` "writes `last_mapped_commit: <HEAD sha>` and `last_mapped_at: <date>` into the YAML frontmatter of each `.planning/codebase/*.md` that exists" ([map-codebase.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/map-codebase.md)).
- The workflow gives the reason: "A shell step cannot be skipped by a confident agent" (same file).
- The design doc adds that the stamp "is the one marker that cannot be satisfied by a date-only rewrite, which is exactly why it is not the agent's to write" ([codebase-drift-gate-design.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/docs/explanation/codebase-drift-gate-design.md)).
- The verb (`cmdStampCodebaseMap`) never creates missing documents and never blocks. `--files` narrows it, because stamping unrefreshed files "would claim a currency they do not have" ([src/verify.cts, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/src/verify.cts)).
- Inferred, from the `scan.md` step list against the map-codebase steps: a `--fast` scan leaves the old stamp beside fresh content.

### Drift gate

- The gate "diffs the repository's HEAD against the commit `.planning/codebase/STRUCTURE.md` was last mapped at" with `git diff --name-status`, excluding `.planning/` ([src/gate-codebase-drift.cts, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/src/gate-codebase-drift.cts); [design doc](https://github.com/open-gsd/gsd-core/blob/e9c3e54/docs/explanation/codebase-drift-gate-design.md)).
- It reads all seven documents and counts additions where the map is silent, plus modified or deleted files under mapped paths ([src/drift.cts, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/src/drift.cts)).
- It acts once the count passes `workflow.drift_threshold` (default 3). `workflow.drift_action` sets `warn` or `auto-remap` ([src/gate-codebase-drift.cts, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/src/gate-codebase-drift.cts)).
- Auto-remap rewrites the affected paths, then runs `stamp-codebase-map --files STRUCTURE.md,ARCHITECTURE.md` ([execute-phase/steps/codebase-drift-gate.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/execute-phase/steps/codebase-drift-gate.md)).
- Epic #5056 Phase 5, PR #5137 "detectDrift sees the whole change set", merged 2026-09-30 and is on `next` (tested 2026-11-28: `gh pr view 5137 -R open-gsd/gsd-core --json state,mergedAt,baseRefName,mergeCommit`; `gh api --method GET repos/open-gsd/gsd-core/compare/a2c43db270...e9c3e54` gave `behind_by=0`).
- PR #4124, the #3418 fix, is also on `next` (tested 2026-11-28: `gh pr view 4124` and the same compare).
- #6690 is not fixed at e9c3e54: `MapReadiness` is still `'none' | 'fast' | 'complete'` and has no reference to `last_mapped` (tested 2026-11-28: `grep -n "last_mapped\|stale\|codebase-drift" src/onboard-projection.cts`).
- #6625 is not fixed: `verify_output` still reads "note which agents may have failed" ([map-codebase.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/map-codebase.md); [#6625](https://github.com/open-gsd/gsd-core/issues/6625)).
- Inferred, from the gate reading only diff names and path mentions: the gate measures structural change since the stamp, not whether the content was right when written.

## How are the results checked before saving in bmad-code-org/BMAD-METHOD's `bmad-architecture` (its `finalize_reviewers` in `customize.toml`) and in google/elephant-goldfish-model's `egm-bootstrap` (`resources/execution_instructions.md`, `skills/egm-bootstrap/TEST.md`, `egm-drift-report`)? (added after confirmation)

### bmad-architecture at e435a22

- The gate starts with `uv run {skill-root}/scripts/lint_spine.py`. The script catches placeholders, duplicate `AD` IDs, missing Binds/Prevents/Rule and unpinned Stack versions, and checks no code paths ([reviewer-gate.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-architecture/references/reviewer-gate.md); [lint_spine.py](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-architecture/scripts/lint_spine.py)).
- A rubric walker then checks a good-spine list, including that the spine "ratifies rather than contradicts a brownfield codebase" ([reviewer-gate.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-architecture/references/reviewer-gate.md)).
- `finalize_reviewers` ships two prompts. One checks that decisions were "web-researched or reality-checked rather than asserted from training data". The other tries to "construct two units one level down that each obey every AD to the letter yet still build incompatibly" ([customize.toml, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-architecture/customize.toml)).
- Each reviewer runs as a parallel subagent, writes to `reviews/review-{lens}.md` and returns "ONLY a compact summary". "An inline self-check does not count: the independent context is the point" ([reviewer-gate.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-architecture/references/reviewer-gate.md)).
- At Finalize the author will "apply the clear fixes rather than handing over a list" (same file).
- Headless runs skip "only the human picking from the menu — never the reviewers themselves" ([headless.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-architecture/references/headless.md)).
- Inferred, from the reviewer and linter findings above: no reviewer checks claims about existing code against that code.

### egm-bootstrap at 4693375

- The final step: "Re-read **every** created or modified contract file". It verifies that sections "cite verified `[file:symbol_or_flag]` entries (or `None`)" and that every relative link exists ([SKILL.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/skills/egm-bootstrap/SKILL.md)).
- The skill does not say how a cite is verified (same file).
- The user is then offered "(Recommended) Yes, run drift report on modified contracts" or "No, skip drift review" (same file).
- `egm-drift-report` processes documents "sequentially" in one context and reports only differences to `{YYYY-MM-DD}_DRIFT_REPORT.md` ([egm-drift-report/SKILL.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/skills/egm-drift-report/SKILL.md)).
- `TEST.md` lists manual scenarios and a pointer to `pytest tests/unit`; none of them checks cites ([TEST.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/skills/egm-bootstrap/TEST.md)).
- Scenario `bootstrap_code_grounding` asserts the cite shape with a regex and forbids names inferred from the directory ([test_scenarios.yaml, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/skills/egm-bootstrap/test_scenarios.yaml)).
- Nothing outside Markdown parses or resolves `[file:symbol]` cites, apart from that scenario's regex (tested 2026-11-28: `grep -rn -E 'symbol_or_flag|file:symbol' . --exclude-dir=.git | grep -v '\.md:'`).
- Inferred, from the final step and the drift-report findings: the final check runs in the orchestrator's own context, so no fresh-context agent checks the written files.

### Dating and contradictions

- On BMAD `dev` (`76887e8`, 2026-11-28) no `bmad-architecture/` paths remain; `bmad-agent-architect` and `bmad-facilitate` are listed instead (tested 2026-11-28: `git ls-tree -r --name-only origin/dev | grep -E 'bmad-architecture/|bmad-facilitate/|bmad-agent-architect/'`).
- `main` has no commits to the skill after e435a22 (tested 2026-11-28: `git log --oneline e435a22..origin/main -- skills/method/bmad-architecture`).
- Researchers disagree on how #3194 closed. One recorded "closed as COMPLETED on 2026-11-27" (`gh issue view 3194`). Two others read the closing comment, which says the issue was "superseded in v7 on `dev`" and that Finalize gates there "scale by `Quick` / `Standard` / `Thorough` depth tiers" ([#3194](https://github.com/bmad-code-org/BMAD-METHOD/issues/3194)). The closing comment is closer to the fact.
- The BMAD v6.11.0 notes promised forwarding shims "until the v7 cut". Commit 636f8e27 has since removed them (tested 2026-11-28: `git log --diff-filter=D -- '*document-project*'`).
- The EGM limit on workers and scouts landed on 2026-11-20: commit `8e2a5ed` (#359) carries that date (tested 2026-11-28: `git log --oneline -8 -- skills/egm-bootstrap`), and PR #359 was opened 2026-11-08 and merged 2026-11-20 (tested 2026-11-28: `gh api graphql` on `pullRequest(number:359){createdAt mergedAt}`).
- The spec-kit catalog lags its entries' repositories: arch 1.2.2 against v3.0.x at HEAD, and blueprint-index 0.2.0 against manifest 0.3.0, which has breaking changes in its CHANGELOG (read in the clones, 2026-11-28).

## Open questions

- **gsd-core `plan:pre` drift check.** `docs/CONFIGURATION.md` says the gate also runs warn-only at `plan:pre`, added in v1.6.0. The gate code header at e9c3e54 names only `execute:wave:post`, and whether `plan:pre` still runs was not checked.
- **gsd-core docs-update scope.** Whether `/gsd-docs-update` and its verifier ever run on `.planning/codebase/*.md` was not checked. If they do, the map's cites are checked after all.
- **Issue coverage.** REST search was rate-limited on 2026-11-28, so no search sorted newest-first was possible. Recent low-relevance issues may be missing. Bodies were not read for EGM #324 and #359, and mattpocock #1394. gsd-core #6755 (closed 2026-11-27) reports that rows and safety properties in gsd-core's own `docs/ARCHITECTURE.md` disagree with the hook sources; whether that file was generated by `/gsd-docs-update` was not checked.
- **Unread checks.** obra/superpowers `skills/brainstorming/builder-check-prompt.md` was not read. The spec-kit entries `improve`, `onboard`, `contextforge-mcp` and `architecture-guard` were not opened, so further code mappers or cite checks there are unknown.
- **codebase-memory-context stamp.** It was not found how the preset fills `source_commit`, or whether a refresh compares it.
- **BMAD v7.** Whether `bmad-facilitate` on `dev` keeps a reviewer list, the two default prompts or the linter is unknown.

## Method

- The user confirmed the brief.
- Researcher 1 covered obra/superpowers and mattpocock/skills (`sq1-superpowers-mattpocock.md`).
- Researcher 2 covered elephant-goldfish-model and spec-kit core (`sq2-goldfish-speckit.md`).
- Researcher 3 covered OpenSpec and gsd-core (`sq3-openspec-gsd.md`).
- Researcher 4 covered BMAD-METHOD (`sq4-bmad.md`).
- Researcher 5 covered reported problems in all seven repositories (`sq5-issues.md`).
- Researcher 6 covered the spec-kit community extensions and presets (`sq6-speckit-extensions.md`).
- Researcher 7 covered the gsd-core verifier, scan, intel updater, stamp and drift gate (`sq7-gsd-verify-drift.md`).
- Researcher 8 covered the check steps in `bmad-architecture` and `egm-bootstrap` (`sq8-check-steps.md`).
- Sub-questions 6, 7 and 8 were added after confirmation.
- Repositories were cloned read-only into temporary folders and deleted afterwards; nothing was run from the clones.
- REST search hit its rate limit. Researcher 5 used GraphQL search, researchers 2, 3 and 8 used `gh issue list --search`, and researchers 1 and 3 could not run `gh search issues`.
- Open pull requests and branches other than the default were not covered, except BMAD `dev` where noted.
- A checker re-read the cited files at the named commits, the cited issues and PRs, and the seven release pages on 2026-11-28, and reran the issue search for mismatched cites (no new match). It corrected the OpenSpec quote, the #443 attribution, the #359 merge date, and the blueprint-index anchor-rule source, and noted #6755 in Open questions. It did not reopen brownkit `validate_evidence.py`, the brownfield, discovery and arch-governance repositories, or the arch v1.2.2 tag.
