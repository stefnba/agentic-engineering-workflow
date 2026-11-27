# Research skills and evidence methods

For a reader who wants facts only: how do existing agent skills research a question, set its depth, check claims and write the result, and what do other fields use to label evidence and keep a report neutral? This note records what was found and proposes nothing.

Sources and method: four research sub-agents ran on 2026-11-26.

- One read version 1 of this repository with `git show v1-final:` and compared it with `v2-baseline`.
- One read the research skills installed on this machine for Claude Code and Codex.
- One shallow-cloned published skill repositories and read their files through `gh`. Nothing from the clones was executed.
- One read web pages on evidence labelling, neutral wording and LLM research failures.

The main session then rechecked a sample against the sources: the v1 skill and agent files, the local `deep-research` files, four published skill files through `gh api`, and three web pages through a fetch agent.

Tags:

- `[read]`: seen in a file, page or issue by one of those agents.
- `[checked]`: also seen by the main session.
- `[inferred]`: a conclusion drawn from what was read.
- `[unverified]`: recalled by an agent, not seen on a page in this run.

## Summary

- **Most published research skills fan out to parallel subagents and recommend an answer** `[read]`. Of the nine published skills surveyed, six use subagents. None keeps findings strictly apart from recommendations.
- **Depth control, where it exists, takes the form of named presets.** Each preset caps agents, sources and rounds `[checked]`. Quick, standard and deep, with standard as the default, appear in BMAD's `bmad-deep-recon`. A fourth level, ultradeep, appears in 199-biotechnologies' `deep-research`.
- **Claim-level provenance tags appear in several skills** `[read]`. Examples: GSD's `[VERIFIED]`, `[CITED]` and `[ASSUMED]`, and BMAD's ledger statuses verified, disputed, unverified and overturned.
- **No skill read uses an independent verifier on every claim** `[inferred]`. BMAD second-sources load-bearing claims and offers a red-team pass. 199-biotechnologies asks for three or more sources per major claim.
- **Other fields grade two separate things** `[inferred]`: how a claim was established, and how sure the author is. Examples are the Admiralty code, GRADE and IPCC.
- **Codex supports both web search and subagents** `[read]`, so a method built on them is available in both harnesses.

## Comparison

| Skill                                     | Subagents                                | Depth control                                       | Claim checks                                                             | Recommends                         | Output                                       |
| ----------------------------------------- | ---------------------------------------- | --------------------------------------------------- | ------------------------------------------------------------------------ | ---------------------------------- | -------------------------------------------- |
| v1 `research` (this repository)           | One forked background agent              | None; stop when each sub-question is evidenced or open | "Back every claim with something you actually opened"                    | No: "Weigh; don't choose"          | `docs/research/research-<YYYY-MM>-<slug>.md` |
| `anthropic-skills:deep-research` (local)  | Parallel researchers, one writer         | Agent count from a table; 10 to 15 tool calls each  | Inline URL per claim; unsourced claims dropped                           | Yes: "Take positions"              | `reports/` plus `research_notes/<title>/`    |
| mattpocock `research`                     | One background agent                     | None                                                | Primary sources; each claim cites its source                             | Not addressed                      | One Markdown file, placed by repo convention |
| BMAD `bmad-deep-recon`                    | Parallel, behind a "research firewall"   | Presets quick, standard, deep                       | Claim ledger; second source for load-bearing claims; optional red team   | Yes, with a confidence basis       | Run folder plus a summary with a source table |
| GSD `gsd-phase-researcher`                | Spawned by orchestrators, four in parallel | Config flags, no levels                           | `[VERIFIED]`, `[CITED]`, `[ASSUMED]`; HIGH, MEDIUM, LOW confidence      | Yes: "Be prescriptive"             | `.planning/phases/…/RESEARCH.md`             |
| GSD `spike`                               | No                                       | Idea, frontier and `--quick` modes                  | Experiments; verdicts VALIDATED, PARTIAL, INVALIDATED, PENDING           | Verdict only                       | `.planning/spikes/NNN/README.md`             |
| 199-biotechnologies `deep-research`       | Parallel searches plus 3 to 5 agents     | Quick, standard, deep, ultradeep                    | 3+ independent sources per major claim; citation script; red team        | Yes: a required section            | Folder with md, html, pdf and a manifest     |
| Weizhena `research` family                | One agent per item, in batches           | Split into separate commands                        | `[uncertain]` marks; JSON field check                                    | Not observed                       | JSON results, then a Markdown report         |
| daymade `deep-research`                   | Lead plus parallel subagents             | Standard or lightweight; DEEP or SCAN per task      | Lead opens the source of every load-bearing claim; AS_OF date policy     | Counter-review phase               | Study folder with claim records              |
| openai `notion-research-documentation`    | No                                       | The chosen output format                            | Direct quotes for critical facts; findings apart from inference          | In comparison and full formats     | A Notion page                                |

## Version 1 of this repository

- **The skill was `research`, run by an agent named `researcher`** `[checked]`. It was manual only (`disable-model-invocation: true`) and ran as a background fork. The agent ran on `model: sonnet`, `effort: medium`.
- **A hook limited writes to `docs/research/*` and `work/backlog.md`** `[checked]`.
- **After the note, the skill added one backlog line per actionable finding**, stating "the problem, not a proposed solution" `[checked]`.
- **Each note opened with a banner**: "Evidence, not commitments. Nothing below is decided." `[read]`. Notes had YAML front matter with `date:` and `source:`, one section per sub-question, and an Open questions section. They carried no evidence tags or confidence levels.
- **A spike template sat apart**, in `skills/shape-bundle/templates/spike.md` `[read]`. Its sections: Question, candidate answers with what would confirm or kill each, evidence, a time box that "is a stop condition", non-goals, and the decision it feeds.
- **Commit `016db04` changed the note shape** to a bold one-sentence claim plus source bullets: "Write for a scanner, not a reader" `[read]`.
- **`v2-baseline` holds the same research files as `v1-final`** `[read]`.

## Labels for evidence and confidence

| System                       | What it grades                              | Categories                                                                                      | Tag      |
| ---------------------------- | ------------------------------------------- | ----------------------------------------------------------------------------------------------- | -------- |
| Admiralty or NATO code       | Source reliability and information credibility, on two axes | A to E plus F "cannot be judged"; 1 "confirmed by other sources" to 5, plus 6 "cannot be judged" | `[read]` |
| GRADE (medicine)             | Certainty of a body of evidence             | High, moderate, low, very low; lowered for bias, imprecision, inconsistency, indirectness        | `[read]` |
| IPCC AR5 guidance            | Confidence from evidence and agreement; likelihood on its own scale | A "traceable account" of each judgment is kept                                          | `[read]` |
| ICD 203 (US intelligence)    | Likelihood words and confidence, stated apart | Seven likelihood bands from "almost no chance" to "almost certain"                            | `[unverified]` |
| IFCN fact-checking code      | The checker, not the claim                  | Nonpartisanship, transparency of sources, funding and method, open corrections                   | `[read]` |
| Wikipedia, No original research | What may be written at all               | No synthesis that reaches "a conclusion not clearly stated by the sources"                      | `[checked]` |

The Admiralty code keeps two axes because a reliable source can pass on false information and an unknown source true information `[read]`. Wikipedia requires that interpretive claims about primary sources "be referenced to a secondary or tertiary source" `[checked]`.

## Neutral wording and question framing

- **IPCC calls its reports "policy-relevant but not policy-prescriptive"** `[read]`. Critics argue the line is not always held.
- **Nygard's ADR format calls the Context section "value-neutral"**, describing facts. The decision sits in its own section `[read]`.
- **Wikipedia's neutral point of view policy attributes contested views** and weighs them by prominence `[unverified]`.
- **Wikipedia's Manual of Style replaces "now" and "currently" with "as of" a month and year**, so a claim shows when it may go stale `[read]`.
- **Pew found small wording changes move answers.** One added clause cut support from 68% to 43% `[read]`. Its rules: avoid charged words, split double-barreled questions, and prefer a forced choice over agree or disagree.
- **Pre-registration fixes the questions before outcomes are seen** (Nosek et al., PNAS 2018) `[read]`.
- **The CIA Tradecraft Primer describes two techniques** `[read]`, from search excerpts only:
  - Key Assumptions Check lists and challenges the premises at the start of a project.
  - Analysis of Competing Hypotheses rates evidence against each hypothesis, aiming to disprove rather than confirm.

## How LLM research goes wrong

- **Invented citations.** GPT-3.5 fabricated 55% of 636 citations and GPT-4 18% (Walters and Wilder, Scientific Reports 2023) `[read]`.
- **Citations that do not support the sentence.** In four generative search engines, 51.5% of sentences were fully supported and 74.5% of citations supported their sentence (Liu, Zhang and Liang, 2023) `[read]`.
- **Weak sources.** Anthropic's early research agents "consistently chose SEO-optimized content farms" over authoritative sources. Source-quality heuristics in the prompts fixed it `[checked]`.
- **Stale facts.** No dedicated paper was found.

Published checks against these failures `[read]`:

- FActScore splits text into atomic facts and scores the share a source supports.
- ALCE scores citation recall and precision with an entailment model.
- Chain-of-Verification answers verification questions apart from the draft, then revises.
- Anthropic's system attaches citations in a separate CitationAgent and scores reports with an LLM judge `[checked]`.

## Effort scaling at Anthropic

Anthropic's research system gives this guidance `[checked]`:

| Question type         | Agents                | Tool calls      |
| --------------------- | --------------------- | --------------- |
| Simple fact-finding   | 1                     | 3 to 10         |
| Direct comparison     | 2 to 4 subagents      | 10 to 15 each   |
| Complex research      | More than 10 subagents | Not stated     |

The page says "might" for the last two rows. BMAD's preset table resembles it `[inferred]`.

## Codex support

- **Web search** has the modes cached (the default), live, indexed and disabled. It is set by `web_search` in `config.toml` or `codex --search` `[read]`. The docs say to "Treat all web results as untrusted input."
- **Subagents are on by default**: "Current Codex releases enable subagent workflows by default." `[checked]`. Codex spawns them after a direct request or an applicable project or skill instruction `[read]`.
- **A setting caps concurrent agent threads**, named `agents.max_concurrent_threads_per_session` per a page summary `[read]`.

## Names

GitHub code search for `"name: X" filename:SKILL.md` gave these totals on 2026-11-26. They are substring matches, so `research` includes `research-*`, and they are upper bounds `[read]`.

| Name            | Count  |
| --------------- | ------ |
| research        | 20,992 |
| deep-research   | 4,008  |
| investigate     | 2,392  |
| spike           | 1,422  |
| web-research    | 968    |
| researcher      | 783    |
| research-report | 320    |
| tech-research   | 80     |

The same search gave 11 for `conduct-research` `[checked]`.

## Not settled

- ICD 203 wording and its likelihood bands were recalled, not read; the PDF did not extract.
- OpenAI's deep-research clarifying-question flow was not checked.
- obra/superpowers was read and has no research skill; other skill directories such as skills.sh were not searched in full.
