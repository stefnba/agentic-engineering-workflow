---
question: "What do published sources advise a repository's architecture document should contain and leave out, so that it orients both coding agents and human engineers, and which documentation practices do they report as reducing common coding-agent failure modes?"
researched: "2026-11-28"
versions: "Claude Code docs as read 2026-11-28 (behaviour notes cite v2.1.211 to v2.1.304); Codex AGENTS.md guide, Cursor rules docs and GitHub Copilot docs as read 2026-11-28, undated; arc42 docs as read 2026-11-28; Gloaguen et al. arXiv 2602.11988 v1 to v3"
---

# What a repository architecture document should contain for coding agents and engineers

## Answer

- **Content, as human sources advise it.** Keep the document short and limited to the big picture: the problem, coarse modules and how they relate, boundaries, invariants and cross-cutting concerns. Leave out per-module detail and anything that changes often. matklad (2021-02-06), arc42 and C4 (both as read 2026-11-28) and Google's style guide agree on a small default that grows only when a reader needs more. The one developer survey (fielded 2012–13) ranks components and interfaces first, then the big picture, then a mapping to the code. See "Human-oriented sources" and "Developer surveys and where decisions belong".
- **Content, as agent sources advise it.** Write down only what an agent cannot find in the code. That means decisions made outside the repository, non-standard practices, gotchas, legacy areas not to copy, and commands that check the work (Anthropic best practices, read 2026-11-28; Gloaguen et al. v3, 2026-09-29; Osmani, 2026-09-14). The one controlled study finds that repository overviews in context files do not help agents and that context files raise cost. That study measures always-loaded context files, not an architecture document read on demand; no source measures the latter. See "Agent vendors and studies".
- **Where human and agent guidance split.** They split on three points, and the evidence is thin on each.
  - Overviews: agents.md, GitHub and Claude Code's memory page still recommend an overview or project layout, while Anthropic's best-practices page and Gloaguen v3 say overviews do not help agents.
  - Upkeep: matklad (2021) advises revisiting twice a year. Google, arc42 and the 2026 agent studies advise updating in the same change and checking references in CI.
  - Links: matklad advises naming code without linking it. Cursor advises referencing files, and the sampled docs show name drift, not broken links.
- **Length.** No source gives a limit for an architecture document; matklad says only "short". The nine sampled open-source docs run from 860 to 5,050 words, most near 1,500–1,700. Limits exist only for always-loaded agent files: under 200 lines (Claude Code), 32 KiB combined (Codex), 2 pages (Copilot onboarding prompt) and 500 lines (Cursor rules). Gloaguen v3 finds no link between context-file length and success. See "Real architecture docs" and "Agent vendors and studies".
- **Upkeep.** What goes stale is the inventory of names: directories, crates, paths and commands. Coding agents sometimes follow stale text and, in the one study, never repaired it (Mehtiyev et al., 2026-11-06). Sources report two kinds of measure that work: removing rot-prone content, and adding an automated check. No source tests ownership or review dates. See "Why architecture docs go stale".
- **Placement and decisions.** Only the project-root instruction file reliably survives Claude Code's compaction; a document read on demand does not. No source states what belongs in AGENTS.md versus ARCHITECTURE.md. arc42 leaves it to the author whether decisions sit inline or in separate records, and sources on decision records advise recording only significant ones. See "Splitting instruction files from the architecture doc" and "Developer surveys and where decisions belong".

Sources report practices for most failure modes in the brief. Most of that evidence is vendor experience or anecdote:

| Failure mode | Reported as reducing it | Reported as making it worse | Evidence |
| --- | --- | --- | --- |
| Greenfield gives nothing to anchor on | A first session that sets up the environment, feature list, start script and first commit (Anthropic); a top-level map of domains and layers enforced by linters and structural tests (OpenAI); a walking skeleton linking the main components end to end (Cockburn) | Agents copy existing patterns, even poor ones (OpenAI); old and new approaches side by side give contradictory precedent (Osmani) | Vendor experience and practitioner advice; only practitioner material ties walking skeletons to agents |
| Decisions nobody made; unclear what is settled | Decision records with a status that says what binds (Davidson); decision logs checked into the repository (OpenAI); explicit invariants (matklad); writing down only what the code does not show (Anthropic) | Agents apply an obsolete accepted record rigidly (Davidson); agents follow unneeded requirements (Gloaguen); contradictory instructions get resolved arbitrarily (Claude Code) | Anecdote, plus one study showing agents follow context-file instructions |
| Too much output: fragmented work items, too many records | Record only significant decisions (arc42, Tran et al.); git history as the changelog instead of amendments, and each rule stated once (Davidson) | LLM-generated context files raise cost by about 20–23%, developer-written ones by up to 19%, with no significant change in success (Gloaguen) | No source on fragmented work items |
| References rot | Short, stable content and names instead of links (matklad); docs changed in the same change as code (Google); CI checks for vanished references (Tan et al., Treude and Baltes); a doc-gardening agent and knowledge-base linters (OpenAI); Claude Code's prompt audit | A monolithic manual (OpenAI); agent PRs that skip doc updates (De Michele and Tantithamthavorn) | Two studies of human docs; 2026 studies of agent files; checkers have false positives |
| Agent code hard to understand; duplication; comprehension debt | Document why as well as what (Storey); state what a change should do before writing it (Osmani); a DRY, modular approach (GitClear); recurring cleanup tasks (OpenAI); naming legacy areas not to copy (Anthropic) | None reported for documentation | Split: GitClear and Huang et al. report more duplication; Borg et al. find no maintainability penalty |
| Long sessions degrade; wrong task size | The smallest set of high-signal tokens, retrieval on demand and notes outside the context (Anthropic); one feature per session (Anthropic); a map, not a manual (OpenAI); facts that must persist kept in the root instruction file, near the top (Claude Code, Sanity) | Longer input and even one distractor lower performance (Chroma) | One measurement on 2025 models; the rest is vendor advice |
| False "done"; no provenance for claims | A check the agent can run (Anthropic, agents.md); a JSON feature list with every feature failing at first, plus end-to-end tests (Anthropic); a memo in which every claim cites a file or issue (Osmani) | Clean output and passing tests create false confidence (Osmani) | Vendor experience and opinion; one practitioner source on provenance |

## Human-oriented sources on architecture documents

**matklad's ARCHITECTURE.md post** ([matklad, "ARCHITECTURE.md", 2021-02-06](https://matklad.github.io/2021/02/06/ARCHITECTURE.md.html)):

- Start with a bird's-eye view of the problem, then a codemap of coarse modules and how they relate, then a section on cross-cutting concerns.
- Name important files, modules and types, but do not link them, because links go stale. Readers find the names with symbol search.
- State architectural invariants explicitly, especially ones expressed as an absence, and point out boundaries between layers.
- Leave out how each module works; that belongs in inline docs or separate documents. Include only what is unlikely to change often.
- Keep it short, because every recurring contributor reads it. The post's scope is projects of roughly 10k–200k lines.
- Do not try to keep it in sync with the code; revisit it a couple of times a year.
- The reason given: finding where to change the code takes far longer than writing the patch.
- The post predates common coding agents and addresses human contributors only.

**arc42 and C4:**

- arc42 has 12 sections, from Introduction and Goals through Architecture Decisions, Risks and Technical Debt, to Glossary ([arc42 docs, as fetched 2026-11-28](https://docs.arc42.org/home/)).
- arc42 tags its tips with about 60 keywords, among them "lean", "essential" and "thorough" (same source). Inferred: its sections work as a menu to trim.
- arc42 advises describing only what stakeholders need, and offers a one-page canvas as the minimal form ([arc42.org/documentation, fetched 2026-11-28](https://arc42.org/documentation/)).
- arc42 advises keeping the docs in git beside the code, reviewed through pull requests, and says low-effort documentation is what stays current (same source).
- Gernot Starke, an arc42 co-founder, advises clarifying who needs what, starting small, and splitting large systems' docs. His examples run to 17 pages (a data migration) and 43 pages (a CRM system) ([Starke, "Diät für Architekturdokumentation", 2026-07-18](https://speakerdeck.com/gernotstarke/diat-fur-architekturdokumentation-ein-ernahrungsplan)).
- C4 says context and container diagrams are enough for most teams, and to draw only the levels that add value ([c4model.com/diagrams, fetched 2026-11-28](https://c4model.com/diagrams)).

**Diátaxis, Google and docs-as-code:**

- Diátaxis separates explanation, which answers why and weighs alternatives, and says documentation already has other places for reference and how-to content ([diataxis.fr/explanation, undated](https://diataxis.fr/explanation/)).
- Google's style guide prefers a small set of fresh, accurate docs over a large set in disrepair ([Google documentation best practices, fetched 2026-11-28](https://google.github.io/styleguide/docguide/best_practices.html)).
- Google advises changing docs in the same change as the code, deleting dead docs by default, and linking to existing guides rather than rewriting them (same source).
- Google keeps shipped design docs as decision records, not as half-correct docs (same source).
- Write the Docs describes docs-as-code as docs following the code workflow, where merges can be blocked without docs ([Write the Docs, "Docs as Code", undated](https://www.writethedocs.org/guide/docs-as-code/)).

**Where these sources disagree, and what limits them:**

- matklad (2021) advises against syncing with the code. Google and arc42 (both fetched 2026-11-28) advise updating docs in the same change and reviewing them in pull requests.
- No human-oriented source opened mentions coding agents, apart from one slide in Starke 2026 predicting that LLMs know arc42.
- None of these sources addresses a greenfield repository whose architecture is intended but not yet built.
- Inferred: every human source sets a small default and grows only on a reader's need; none advises filling a full template. This rests on matklad, arc42's tags and canvas, C4's diagram advice, Starke and Google.

## Agent vendors and studies

**What helps an agent:**

- Anthropic advises writing down only what Claude cannot find by reading the repository, or would rediscover every session ([Claude Code docs, Best practices, read 2026-11-28](https://code.claude.com/docs/en/best-practices)).
- Its examples of what the code lacks: a decision made in a meeting, a deploy process in one person's head, an environment variable the tests need (same page).
- Its example file holds only commands, conventions and gotchas, such as a live legacy directory whose patterns should not be copied (same page).
- Anthropic says an agent with nothing to run that shows the work is done stops when the work looks done (same page).
- Instructions work best when concrete enough to verify, such as naming the directory that holds API handlers ([Claude Code docs, memory, read 2026-11-28](https://code.claude.com/docs/en/memory)).
- agents.md lists overview, build and test commands, code style, testing and security as popular sections, and PR guidelines and deployment steps as optional extras. It says agents run listed checks and fix failures before finishing ([agents.md, read 2026-11-28](https://agents.md/)).
- agents.md says README files are for humans and AGENTS.md adds the context agents need (same source).
- GitHub's onboarding prompt for Copilot instructions asks for a summary of what the repository does, how to build and validate changes, and the paths to main project files ([GitHub Docs, read 2026-11-28](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions)).
- Gloaguen et al. find that agents follow context-file instructions well. uv was used 1.6 times per task when the file named it, under 0.01 times when it did not ([arXiv 2602.11988 v3, 2026-09-29](https://arxiv.org/html/2602.11988)).
- Gloaguen et al. find context files useful for specifying non-standard coding practices ([arXiv 2602.11988 v3](https://arxiv.org/abs/2602.11988v3)).

**What does not help, or hurts:**

- Gloaguen et al. find context files do not generally improve task success ([arXiv 2602.11988 v3, 2026-09-29](https://arxiv.org/html/2602.11988)).
  - LLM-generated files raised cost by about 20% on SWE-bench and 23% on CTXbench; developer-written files by up to 19%.
  - Success changed by about -0.5% and -2% for LLM-generated files and +2.4% for developer-written files. None of these changes is significant.
- The same paper finds repository overviews unhelpful: they did not get agents to the relevant files sooner, and no single content category significantly improved accuracy (same source).
- With the README and docs removed, LLM-generated context files helped by about 2.7%, which the authors read as redundancy with existing documentation; Claude Code was left out of this ablation ([arXiv 2602.11988 v3 HTML, Appendix B](https://arxiv.org/html/2602.11988v3)).
- The authors advise that context files hold only instructions beyond what the codebase and README already provide (same source).
- Developer-written files significantly outperform LLM-generated ones on CTXbench (p = 0.038) ([arXiv 2602.11988 v3](https://arxiv.org/html/2602.11988)).
- Anthropic's "What you can stop doing" table lists describing architecture and file layout in CLAUDE.md as old advice, because Claude reads the repository itself ([Claude Code docs, Best practices, read 2026-11-28](https://code.claude.com/docs/en/best-practices)).
- The same table drops capitals and emphasis, which make Claude over-apply a rule, and loop-until-done lines, which cause over-work (same page).
- Context files guide but do not enforce; a rule that must hold belongs in a hook or deny rule ([Claude Code docs, memory](https://code.claude.com/docs/en/memory)).

**Size:**

- Claude Code targets under 200 lines per CLAUDE.md, saying longer files cost context and reduce adherence. Imports do not reduce that cost ([Claude Code docs, memory](https://code.claude.com/docs/en/memory)).
- Codex stops adding files once their combined size reaches `project_doc_max_bytes`, 32 KiB by default ([Codex docs, AGENTS.md, undated, read 2026-11-28](https://learn.chatgpt.com/docs/agent-configuration/agents-md)).
- GitHub's onboarding prompt caps instructions at 2 pages ([GitHub Docs](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions)).
- Cursor advises keeping rules under 500 lines ([Cursor docs, Rules, undated, read 2026-11-28](https://cursor.com/docs/context/rules)).
- Gloaguen et al. find no clear dependency between success or cost and context-file length ([arXiv 2602.11988 v3](https://arxiv.org/html/2602.11988)). Anthropic's adherence claim and this finding measure different things.
- Real files run long: mean lengths are 310 lines for Copilot instructions, 287 for CLAUDE.md and 142 for AGENTS.md ([Mohsenimofidi et al., arXiv 2510.21413 v4, 2026-02-05](https://arxiv.org/html/2510.21413v4)).

**Where these sources disagree, and how they date:**

- Claude Code's memory page still lists project layout and project architecture as CLAUDE.md content ([memory, read 2026-11-28](https://code.claude.com/docs/en/memory)). The best-practices page on the same site, read the same day, moves architecture descriptions to old advice. The date of that change is unknown.
- Gloaguen v1 (2026-02-12) said context files tend to reduce task success compared with no repository context ([arXiv 2602.11988 v1](https://arxiv.org/abs/2602.11988v1)). v3 (2026-09-29) says they do not generally improve it. v2 is dated 2026-06-23.
- Lulla et al. found an AGENTS.md cut median runtime by about 28.64% and output tokens by about 16.58%, with comparable completion, across 10 repositories and 124 PRs ([arXiv 2601.20404 v2, 2026-03-30](https://arxiv.org/abs/2601.20404)). Gloaguen et al. found higher cost on benchmark tasks; the setups differ.
- Gloaguen's models are Sonnet-4.5, GPT-5.2, GPT-5.1 mini and Qwen3-30B-coder; results may not hold for later models ([arXiv 2602.11988 v3](https://arxiv.org/html/2602.11988)).
- Inferred: the vendors and Gloaguen et al. separate two kinds of content. Agents follow instructions they cannot derive from the code, while descriptions of what they can read add cost without gains. This rests on the Anthropic best-practices findings and the Gloaguen overview and ablation findings. It is measured for always-loaded files only.

## Real architecture docs in open-source repositories

Nine docs were sampled on 2026-11-28 with `gh api --method GET repos/<repo>/contents/<path>`, last-change dates with `gh api --method GET "repos/<repo>/commits?path=<path>"`, and sizes with `wc -lw`:

| Repository and path | Lines / words | Last change | Notable content |
| --- | --- | --- | --- |
| [rust-analyzer `docs/book/src/contributing/architecture.md`](https://github.com/rust-lang/rust-analyzer/blob/master/docs/book/src/contributing/architecture.md) | 517 / 4,014 | 2026-09-01 | Bird's-eye view, entry points by file, code map per crate with "Architecture Invariant" lines, API boundaries, cross-cutting concerns |
| [esbuild `docs/architecture.md`](https://github.com/evanw/esbuild/blob/main/docs/architecture.md) | 579 / 5,050 | 2020-08-11 | Design principles, pipeline phases, relative code links, PNG diagrams, the most "why" lines in the sample |
| [helix `docs/architecture.md`](https://github.com/helix-editor/helix/blob/master/docs/architecture.md) | 128 / 860 | 2025-07-26 | Crate table with one-line roles; sends API detail to `cargo doc` |
| [typst `docs/dev/architecture.md`](https://github.com/typst/typst/blob/main/docs/dev/architecture.md) | 198 / 1,553 | 2026-07-27 | Directory list with roles, then the compilation pipeline; no links or diagrams |
| [jj `docs/technical/architecture.md`](https://github.com/jj-vcs/jj/blob/main/docs/technical/architecture.md) | 236 / 1,613 | 2026-08-11 | Data model, library and UI split, one subsection per type; no code links |
| [tauri `ARCHITECTURE.md`](https://github.com/tauri-apps/tauri/blob/dev/ARCHITECTURE.md) (root) | 193 / 1,542 | 2026-09-29 | Major components, a "What Tauri is NOT" section, workflows; the most code links |
| [wasmtime `docs/contributing-architecture.md`](https://github.com/bytecodealliance/wasmtime/blob/main/docs/contributing-architecture.md) | 518 / 4,652 | 2025-09-08 | Concepts and runtime walk-through; no links; sends readers to code comments |
| [oxc `ARCHITECTURE.md`](https://github.com/oxc-project/oxc/blob/main/ARCHITECTURE.md) (root) | 393 / 1,656 | 2026-11-13 | ASCII layer diagram, principles, quality attributes, technical constraints, design decisions, future considerations |
| [sanity `ARCHITECTURE.md`](https://github.com/sanity-io/sanity/blob/main/ARCHITECTURE.md) (root) | 369 / 1,585 | 2026-08-19 | Directory tree, package dependency graph, data flow, entry points; written for developers and AI agents |

- All nine name directories, crates or packages and key types in backticks (tested 2026-11-28 with `grep -c`).
- Only rust-analyzer states invariants explicitly; only tauri has a non-goals section; only oxc has a design-decisions section (tested 2026-11-28 with `grep -c` and the heading lists).
- Sanity's doc has no invariants and no "why" lines (grep count 0, tested 2026-11-28).
- Three of the nine sit at the repository root (tauri, oxc, sanity); the rest live under `docs/`.
- A search for a root `ARCHITECTURE.md` in 18 other large repositories, from ruff to openai/codex, found none (tested 2026-11-28 with `gh api --method GET repos/<repo>/commits?path=ARCHITECTURE.md`).

**Currency** (tested 2026-11-28 by checking the names in each doc against `gh api --method GET repos/<repo>/contents/<path>`):

- rust-analyzer names `crates/rustc-dependencies` and `crates/flycheck`, neither of which exists. It spells `hir-ty` as `hir_ty`, and omits six current crates, among them `edition`, `syntax-bridge` and `test-utils`.
- typst names every crate except `typst-bundle`. Its recent commits to the file are list fixes, such as adding `typst-html` (2025-06-02) and fixing a path (2025-12-10).
- esbuild has not changed since 2020-08-11, yet the code files it links still exist. Its pipeline prose was not checked.
- matklad advises keeping the doc short, yet his own example, rust-analyzer, now runs to 4,014 words.
- Inferred: the sampled docs fall into two families. One follows matklad: overview, codemap, invariants, few links (rust-analyzer, and partly helix, typst, jj, wasmtime). The other uses template sections or a reference-style inventory (oxc, sanity). This rests on the section lists.
- Inferred: what drifted is the inventory of names, not the design prose, and links did not rot in esbuild. This rests on two docs and checks of names only.

## Why architecture docs go stale, and what keeps them true

**Causes:**

- Developers do not notice when a code change makes a doc obsolete, and nothing fails when it does ([Tan, Wagner, Treude, arXiv 2212.01479v1, Dec 2022](https://ar5iv.labs.arxiv.org/html/2212.01479)).
- In the same study, 82.3% of top-1000 GitHub projects had an outdated code reference in README or wiki pages at some point, and 28.9% at study time (same source).
- References outdated at study time had been outdated for about 4.7 years on average (same source).
- Code is checked continuously by compilers, tests and CI, while docs are updated by hand and often incompletely ([Treude and Baltes, arXiv 2606.09090v1, 2026-06-08](https://arxiv.org/html/2606.09090)).
- Nygard writes that large documents are never kept up to date, while small, modular ones have a chance ([Nygard, "Documenting Architecture Decisions", 2011-11-15](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)).
- Developers in the Fraunhofer survey named outdated documentation as the top problem (25 coded answers), then wrong granularity (19) and implementation out of sync (17) ([Fraunhofer IESE survey, §4.3](https://www.iese.fraunhofer.de/content/dam/iese/dokumente/alte-dateien/study_software_architecture_documentation_for_developers_survey-en-fraunhofer_iese.pdf)).

**Agents and stale docs:**

- Coding agents followed stale instructions relevant to the task, sometimes even when correct information was available elsewhere, and none repaired the instruction file ([Mehtiyev et al., "When Instruction Files Go Stale", arXiv 2611.09802, 2026-11-06](https://arxiv.org/abs/2611.09802)).
  - The study ran 22 tasks in stale, corrected and removed versions, 732 runs in all.
  - For Claude Sonnet 5.5, a stale test command added about two tool calls per run, roughly a third more. The other two stale instructions showed no detectable difference.
  - Correcting the instruction stopped operations on obsolete paths; removing it prevented most of them.
- 63.2% of agent-written PRs change code without updating any documentation, 77.5% for refactoring ([De Michele and Tantithamthavorn, arXiv 2610.27381, 2026-10-19, accepted at APSEC 2026](https://arxiv.org/abs/2610.27381)). The study has no human baseline.
- In the same study, files changed without a doc update were re-documented within 90 days at half the rate of others, 24% against 48% (same source).
- Half of 155 AGENTS.md files were never changed after creation ([Mohsenimofidi et al., arXiv 2510.21413 v4](https://arxiv.org/html/2510.21413v4)).

**Practices reported as working:**

- matklad advises recording only what rarely changes, since a shorter doc is less likely to be invalidated ([matklad, 2021-02-06](https://matklad.github.io/2021/02/06/ARCHITECTURE.md.html)).
- Martraire's advice, as Hilton summarises it, is to document only long-lived, widely needed knowledge, with "don't" as the default ([Hilton, 2021-05-18](https://hilton.org.uk/blog/martraire-documentation-principles)).
- Nygard advises small decision records in the repository, one or two pages each, superseded rather than edited ([Nygard, 2011-11-15](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)).
- A GitHub Actions tool scans for outdated code references on every pull request ([Tan, Wagner, Treude, arXiv 2307.04291, 2023-07-10](https://arxiv.org/abs/2307.04291)).
  - When the authors reported 19 outdated references across 15 projects, 5 were fixed and 4 were called false positives ([Tan et al., 2022](https://ar5iv.labs.arxiv.org/html/2212.01479)).
- The same kind of checker found at least one stale reference in 82 of 356 repositories with CLAUDE.md or AGENTS.md files (23.0%); per reference, 1.42% in CLAUDE.md and 1.04% in AGENTS.md were stale. Of 50 flags reviewed by one annotator, 64% were genuine, 24% false positives and 12% ambiguous ([Treude and Baltes, 2026-06-08](https://arxiv.org/html/2606.09090)).
- Treude and Baltes recommend a `git grep` check in CI for vanished references and review alongside refactors, and propose alerts when related code changes without a matching file update as future work (same source).
- Claude Code's `/doctor prompt-audit` flags references to missing files or commands, and files that contradict each other ([Claude Code docs, memory](https://code.claude.com/docs/en/memory)).

**Limits:**

- matklad's twice-yearly revisit (2021) addresses a human-facing doc with little that can rot. The 2026 studies call for per-change review and CI checks, and concern agent instruction files that hold commands and paths.
- No source tests ownership, review dates or docs-as-code review as ways to keep architecture docs accurate.
- No source studies architecture documents read by agents; the 2026 studies cover CLAUDE.md, AGENTS.md, READMEs and wikis.
- Inferred: a stale reference costs more when agents read the doc, since agents trust stale text and agent PRs skip doc updates. This rests on Mehtiyev et al. and De Michele and Tantithamthavorn.

## Documentation practices against each failure mode

Findings below are those the table in the Answer rests on and no earlier section states.

**Greenfield gives nothing to anchor on:**

- OpenAI reports that Codex replicates patterns already in the repository, even uneven or poor ones ([OpenAI, Harness engineering, 2026-02-11](https://openai.com/index/harness-engineering/)).
- OpenAI uses an architecture document as a top-level map of domains and package layering, enforced by custom linters and structural tests (same source).
- Anthropic's long-running harness gives the first session its own prompt to set up a feature list, an `init.sh`, a progress file and a first commit ([Anthropic, Effective harnesses for long-running agents, 2025-11-26](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)). The evidence is Anthropic's own experiments.
- Cockburn defines a walking skeleton as a tiny end-to-end implementation that links the main architectural components ([Code Climate post quoting Cockburn's wiki, 2014-03-20](https://codeclimate.com/blog/kickstart-your-next-project-with-a-walking-skeleton)). This is a secondary source. Only practitioner material ties it to agents, such as a [vibe-engineering guide's walking-skeleton chapter](https://vibe-engineering-guide.pages.dev/part-vi-practical-vibe-coding-workflows-the-stuff-youll-actually-use-daily/17-vibe-coding-for-greenfield-projects/17-4-building-the-walking-skeleton) (undated) and [Van Eyck, "Agentic Coding in 2026" slides](https://jovaneyck.github.io/presentations/agentic-coding/agentic-coding-in-2026.html).
- Osmani writes that when old and new approaches coexist, the agent sees contradictory precedent. He prefers finishing one route end to end ([Osmani, "Brownfield Agentic Engineering", 2026-09-14](https://addyosmani.com/blog/brownfield-agentic-engineering/)).

**Decisions nobody made:**

- Davidson reports that decision records with a status tell agents what binds: accepted records bind, proposed ones are context, superseded ones are history ([Davidson, "Coding agents love decision records", O'Reilly Radar, 2026-10-02](https://oreilly.com/radar/coding-agents-love-decision-records/)). The evidence is his own work.
- Davidson also reports agents applying an accepted record rigidly after it went out of date. He advises telling agents to stop and discuss when a task conflicts with one (same source).
- OpenAI checks execution plans with progress and decision logs into the repository ([OpenAI, 2026-02-11](https://openai.com/index/harness-engineering/)).
- Claude Code's docs say Claude may pick one of two contradictory instructions arbitrarily ([Claude Code docs, memory](https://code.claude.com/docs/en/memory)).

**Too much output:**

- Davidson advises using git history as the changelog rather than amendment logs inside records, and stating each rule once with cross-references ([Davidson, 2026-10-02](https://oreilly.com/radar/coding-agents-love-decision-records/)).
- No source was found on fragmented work items.

**References rot:**

- OpenAI reports that a monolithic instruction manual rots and agents cannot tell which parts still hold ([OpenAI, 2026-02-11](https://openai.com/index/harness-engineering/)).
- OpenAI keeps AGENTS.md as a table of contents, runs a recurring doc-gardening agent that opens fix-up PRs, and uses linters and CI jobs to check the knowledge base (same source).
- Cursor advises referencing files instead of copying their contents, so they do not go stale as code changes ([Cursor docs, Rules](https://cursor.com/docs/context/rules)).
- About 10% of links in source-code comments across 25,925 repositories are dead, and links are rarely updated when their targets change ([Hata, Treude, Kula, Ishio, "9.6 Million Links in Source Code Comments", ICSE 2019](https://arxiv.org/abs/1901.07440)). The study predates coding agents.

**Agent code hard to understand:**

- GitClear reports copy/pasted lines rising from 8.3% to 12.3%, and moved lines falling from 25% (2021) to under 10% (2024), across 211 million changed lines ([GitClear, AI Copilot Code Quality 2025, page © 2026](https://www.gitclear.com/ai_assistant_code_quality_2025_research)). GitClear describes canonical systems as documented, tested and reused, and calls a DRY, modular approach essential.
- GitClear's 2026 report finds duplicated blocks up 81%, from 40.3 to 73.0 per million changed lines, 2023 to 2026 year-to-date ([GitClear, "The Maintainability Gap", 2026](http://www.gitclear.com/the_ai_code_quality_maintainability_gap)). It gives no method for detecting AI authorship, and GitClear sells code analytics.
- Huang et al. find an average maximum redundancy of new functions in agentic PRs about 1.87 times that in human PRs, mostly as semantic rather than copy-paste clones ([Huang et al., arXiv 2601.21276v1, 2026-01-29](https://arxiv.org/html/2601.21276v1)). The study covers one Python repository.
- A preregistered experiment with 151 participants found no significant difference when new developers evolved code first written with or without AI ([Borg et al., arXiv 2507.00788v3, 2026-02-26](https://arxiv.org/abs/2507.00788v3)). It covers small tasks with assistant-style AI in 2024–2025.
- Osmani warns that AI generates code faster than humans can review it. He advises being explicit about what a change should do before it is written ([Osmani, "Comprehension debt", 2026-03-14](https://addyosmani.com/blog/comprehension-debt/)). This is opinion.
- Storey suggests documenting why as well as what changed, and requiring that one human understands each AI change ([Storey, "Cognitive debt", 2026-02-09](https://margaretstorey.com/blog/2026/02/09/cognitive-debt/)). Her evidence is one student-team anecdote.
- OpenAI spent a fifth of each week cleaning up poor agent code by hand, then automated it with recurring background tasks ([OpenAI, 2026-02-11](https://openai.com/index/harness-engineering/)).
- Osmani advises giving agents only what is not obvious from the code: business nuance, trade-offs and external constraints ([Osmani, 2026-09-14](https://addyosmani.com/blog/brownfield-agentic-engineering/)).
- The duplication sources measure different things: duplication counts and redundancy (GitClear, Huang) against the time and quality of later change (Borg). They do not refute each other directly.

**Long sessions degrade:**

- Chroma found performance degrading with input length across 18 models from mid-2025, and even one distractor lowering it ([Chroma, Context Rot, 2025-07-14](https://www.trychroma.com/research/context-rot)).
- Anthropic advises the smallest set of high-signal tokens, retrieval through file paths when needed, compaction, notes kept outside the context window, and sub-agents that return summaries ([Anthropic, Effective context engineering for AI agents, 2025-09-29](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)).
- Anthropic's harness found working on one feature per session critical, with each session starting from the git log and a progress file ([Anthropic, 2025-11-26](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)).
- OpenAI advises giving Codex a map rather than a long instruction manual ([OpenAI, 2026-02-11](https://openai.com/index/harness-engineering/)).

**False "done" and provenance:**

- Anthropic reports Claude marking features complete without testing. Its fix is a JSON feature list with every feature marked failing at first, plus end-to-end browser tests; JSON is less likely to be overwritten than Markdown ([Anthropic, 2025-11-26](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)).
- Osmani warns that clean output and passing tests create false confidence ([Osmani, 2026-03-14](https://addyosmani.com/blog/comprehension-debt/)).
- Osmani proposes a durable comprehension memo in which every claim cites a file, issue, ownership record or dashboard ([Osmani, 2026-09-14](https://addyosmani.com/blog/brownfield-agentic-engineering/)). No other source on provenance for claims was found.

**Across failure modes:**

- Inferred: prose alone is reported as weak against rot and drift; the reported remedies pair docs with machine checks. This rests on OpenAI's linters and gardening agent, Anthropic's JSON feature list and tests, and the CI reference checkers.

## Splitting instruction files from the architecture doc

- Claude Code loads CLAUDE.md files from the working directory and its parents at launch, and subdirectory files on demand ([Claude Code docs, large-codebases, fetched 2026-11-28](https://code.claude.com/docs/en/large-codebases)).
- That page puts rules that apply everywhere in the root file and subsystem conventions in subsystem files. It says one root file either grows to cover every subsystem or stays too generic (same source).
- It advises moving conventions and reference content out of always-loaded files into skills, plugins or MCP servers once layering stops scaling (same source).
- Claude Code's memory page advises moving multi-step procedures, and entries that matter for one part of the code, to a skill or path-scoped rule ([Claude Code docs, memory](https://code.claude.com/docs/en/memory)).
- After compaction, Claude Code re-injects the project-root CLAUDE.md and unscoped rules from disk. Nested CLAUDE.md files and path-scoped rules reload only on demand ([Claude Code docs, context-window, fetched 2026-11-28](https://code.claude.com/docs/en/context-window)).
- After compaction, a re-read file over 5,000 tokens comes back as a path without its content (same source).
- Codex joins files from the root down to the working directory, one per directory, and the closer file wins ([Codex docs, AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)).
- Cursor applies nested AGENTS.md files within their directory, with the more local file winning. It says referenced files are not inlined, so anything that must always be in context goes in the rule body ([Cursor docs, Rules](https://cursor.com/docs/context/rules)).
- Shopware decided on one source for both audiences: a brief root AGENTS.md, subtree files only for real subtree rules, and task rules in skills ([Shopware ADR, 2026-06-17](https://developer.shopware.com/docs/resources/references/adr/2026-06-17-shared-guidance-files-for-humans-and-agents.html)). It says separate guidance per audience causes duplication and drift.
- Shopware rejected stub files that only point at READMEs, because agents do not always follow references that are not auto-loaded (same source).
- Sanity keeps an ARCHITECTURE.md, a root AGENTS.md of 1,770 lines with commands, CI checks and rules, and a CLAUDE.md that only imports AGENTS.md ([sanity AGENTS.md, read 2026-11-28](https://github.com/sanity-io/sanity/blob/main/AGENTS.md)).
- Only ARCHITECTURE.md links to AGENTS.md, from its Further Reading section; a grep of AGENTS.md found no mention of ARCHITECTURE.md (same source).
- Sanity's AGENTS.md puts a critical rule at the top because agent context often holds only the start of the file (same source).
- A study of agent configuration in repositories counted 497 reference pairs between context files, mostly CLAUDE.md pointing at AGENTS.md. It does not study links to ARCHITECTURE.md ([arXiv 2602.14690 v5, 2026-06-30](https://arxiv.org/html/2602.14690)).
- Shopware's shim of a CLAUDE.md pointing at AGENTS.md was later superseded ([Shopware ADR, 2026-06-17](https://developer.shopware.com/docs/resources/references/adr/2026-06-17-shared-guidance-files-for-humans-and-agents.html)). Shopware removed it in a later ADR dated 2026-11-19. Claude Code reads AGENTS.md directly from v2.1.277, by default only when no CLAUDE.md exists in the working directory or above it ([Claude Code docs, memory](https://code.claude.com/docs/en/memory)).
- No source states what belongs in AGENTS.md versus ARCHITECTURE.md; Sanity shows a split without explaining it.
- Inferred: a fact an agent must keep through a long session survives only in the root instruction file, not in an architecture doc read on demand. This rests on the compaction findings and Sanity's note on truncated context.
- Inferred: Shopware and Cursor pull in opposite directions on relying on a link from an instruction file to another doc. Shopware reports agents do not reliably follow such links; Cursor recommends references to avoid staleness.

## Developer surveys and where decisions belong

**What developers report needing** ([Rost, Naab, Lima, von Flach Chavez, "Architecture Documentation for Developers: A Survey", Fraunhofer IESE, ©2013](https://www.iese.fraunhofer.de/content/dam/iese/dokumente/alte-dateien/study_software_architecture_documentation_for_developers_survey-en-fraunhofer_iese.pdf)):

- The survey had 147 industrial participants and was fielded from 2012-12-01 to 2013-01-31.
- Asked what architecture information best supports their tasks (N=103, coded free text), developers answered:
  - components, interfaces, relationships and decomposition: 42.7%
  - big picture: 19.4%
  - mapping to implementation: 11.7%
  - architecture decisions and rationale: 7.8%
  - constraints: 2.9%
  - glossary and history of the architecture: 1% each
- The authors conclude that developers need an overview of the whole system plus detail on the parts in their own scope, more detail the closer a part is (§4.5, §5.1).
- Asked how much documentation is optimal (N=83), the top answers were "depends on target group and task" (19.3%) and "depends on project" (18.1%) (Table 4).
- Most participants saw no unnecessary information provided (§4.3).
- Among wishes for future documentation, "presenting design decisions and rationale" drew 10 coded answers (§4.5).
- To find information, developers want search (29.8%) and links and navigation (28.6%) (Table 6).
- The authors call a clear connection between architecture and implementation a major concern for developers (§5.2).

**Where decisions go:**

- arc42 section 9 holds important, expensive or risky decisions with rationale, as one ADR per decision, a table, or a section each ([arc42 docs, section 9, fetched 2026-11-28](https://docs.arc42.org/section-9/)).
- arc42 leaves it to the author's judgement whether a decision goes in section 9 or near the building block it concerns (same source).
- arc42's tips: document only architecturally relevant decisions, document rejected alternatives, and timestamp decisions (same source).
- oxc keeps three decisions inline in its ARCHITECTURE.md, each with a decision, rationale and trade-offs, and links to no ADR files ([oxc ARCHITECTURE.md, fetched 2026-11-28](https://github.com/oxc-project/oxc/blob/main/ARCHITECTURE.md)).
- adr.github.io calls a project's ADRs its decision log, and says nothing on where to store them or how they relate to an architecture doc ([adr.github.io, fetched 2026-11-28](https://adr.github.io/)).
- Tran, Zimmermann, Capilla and Zdun advise lean, minimalistic decision documentation and say capturing all fine-grained decisions is not possible ([InfoQ / IEEE Software reprint, 2014-03-09](https://www.infoq.com/articles/sustainable-architectural-design-decisions/)).
- They warn that templates with 10 to 20 fields per decision get skipped under pressure, and propose a one-sentence "Y-statement" instead (same source).
- Zimmermann's blog, updated 2026-09-12, advises recording only architecturally significant decisions and offers the Y-statement as a format ([ozimmer.ch](https://www.ozimmer.ch/practices/2020/04/27/ArchitectureDecisionMaking.html)).

**Limits:**

- The survey predates coding agents, studied documents mostly in Word or PDF (87%), and rests on small counts of coded answers (§4.4, Table 7).
- Ernst and Robillard gave 65 participants narrative or structured architecture docs and found format had no significant effect on understanding. Prior exposure to the source code mattered most ([arXiv 2305.17286, May 2023, accepted to EMSE](https://arxiv.org/abs/2305.17286)).
- No newer developer survey (2020–2026) on architecture-doc content was found.
- Inferred: no source makes separate decision records a rule; arc42 allows both forms, oxc keeps decisions inline, and ADR sources assume a separate log without placing it.

## Greenfield work, code quality and comprehension

The findings for this sub-question sit under "Documentation practices against each failure mode", in its greenfield and "agent code hard to understand" parts. One limit applies to all of them:

- Benchmarks measure agents building a repository from nothing: in NL2Repo-Bench the best agents pass under 40% of tests on average over 104 tasks ([arXiv 2512.12730, Dec 2025](https://arxiv.org/abs/2512.12730)), and ProjDevBench reports 27.38% acceptance over 20 projects ([arXiv 2602.01655, Feb 2026](https://arxiv.org/abs/2602.01655)). Neither tests documentation practices; the greenfield advice above is practitioner experience.

## Open questions

- **An architecture doc read on demand.** No source measures its effect on agents. The negative overview findings come from always-loaded context files. A study of on-demand docs could reverse the Answer's point on overviews for agents.
- **Whether agents open a linked ARCHITECTURE.md.** Shopware states that they do not reliably, without data. No measurement was found.
- **Settled versus provisional.** No evidence was found on whether marking what is settled, assumed or about to change alters agent behaviour; Davidson's report is anecdote.
- **Fragmented work items and comment references.** No source was found on fragmented work items. Comment-link decay is measured for human code (Hata et al., 2019), not for agent-written comments.
- **Replication.** No strict replication of Gloaguen et al. was found. An independent ablation on 17 tasks in 3 repositories found context strategy does not measurably move correctness, and reports no cost result ([Khatri, arXiv 2607.27250, 2026-07-28](https://arxiv.org/abs/2607.27250)). Its headline moved between v1 and v3, so a later version could shift again.
- **Sample breadth.** Seven of the nine sampled docs are Rust projects; no Python, Java or C/C++ project was sampled.
- **Newer releases.** Claude Code's latest release is 2.1.332 (npm, 2026-11-28); the behaviour notes cite up to v2.1.304. Codex CLI is at 0.172.0, the arc42 template at 2026.11.27.2 and Cursor at 3.31; the report names no version for these. GitHub's Copilot changelog has customization entries dated 2026-11-16 and 2026-11-18 that were not opened.
- **When Anthropic's advice changed.** No changelog dates the move of architecture descriptions to old advice on the best-practices page.

## Method

- The user confirmed the brief. Sub-questions 6, 7 and 8 were added after confirmation.
- Researcher 1 covered human-oriented sources (notes-1-human-sources.md). Pages were read through a fetch tool that returns a model-written digest, so its quotes were not checked against the raw page.
- Researcher 2 covered agent vendors and studies (notes-2-agent-guidance.md).
- Researcher 3 sampled real architecture docs with read-only `gh api` commands and `wc` on 2026-11-28 (notes-3-real-examples.md).
- Researcher 4 covered staleness and upkeep (notes-4-staleness.md).
- Researcher 5 mapped the failure modes (notes-5-failure-modes.md).
- Researcher 6 covered placement between instruction files and the architecture doc (notes-6-agent-placement.md).
- Researcher 7 covered developer surveys and decision placement (notes-7-task-fit.md).
- Researcher 8 covered greenfield work, duplication and comprehension (notes-8-greenfield-comprehension.md).
- No live checks were run, and no agents were tested in this project.
- A checker reopened every cited source on 2026-11-28, reran the `gh api` sampling (sizes, dates, invariant counts and rust-analyzer crate names matched), reran the negative searches and checked latest releases. It narrowed claims on agents.md sections, arc42 tags, Starke, Diátaxis, Gloaguen cost and models, Mehtiyev, Treude and Baltes (23.0% is of repositories), GitClear, Huang, Tran, Zimmermann and the AGENTS.md and Shopware notes; replaced the none-found claims on comment links, greenfield studies, walking skeletons and replication; and added newer releases to Open questions. All sections were covered. Some sources were read through a summarising fetch tool rather than as raw pages.
