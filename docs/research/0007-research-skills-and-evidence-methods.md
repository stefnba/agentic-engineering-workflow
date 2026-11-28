---
question: "How do existing agent research skills research a question and write the result, and what do other fields use to label evidence and confidence and to keep questions and reports neutral?"
researched: "2026-11-28"
versions: "obra/superpowers 22f0b463; mattpocock/skills bbadaa63; google/elephant-goldfish-model 46933754; github/spec-kit f2010547; Fission-AI/OpenSpec dff0188f; open-gsd/gsd-core e9c3e540; bmad-code-org/BMAD-METHOD e435a225; anthropics/skills e4bb5d96; openai/skills 49f948fa; langchain-ai/deepagentsjs 669bbe32; NVIDIA-AI-Blueprints/aiq 951a1a11; installed: anthropic-skills 1.0.0 (deep-research, catalog updatedAt 2026-09-14), Notion 3.0.9, life-science-research 1.0.3, NVIDIA plugin 1.0.2 (aiq-research 2.1.0)"
---

# Research skills, evidence labels and neutral wording

## Answer

The research skills compare as follows on the five aspects. Each cell rests on a finding in the two skill sections and in the section on the parts read after confirmation.

| Skill | Splits work | Sets depth | Checks claims | Tags provenance or confidence | Writes |
| --- | --- | --- | --- | --- | --- |
| mattpocock `research` | One background agent | Not set; the user scopes | Primary-source rule only, no pass | A citation per claim | One Markdown file in the repo |
| spec-kit `speckit.assess.research` | One agent | Fixed lenses | Host allowlist, no second source | `cited` or `assumption`, plus high, medium or low | `research.md` with a required Evidence Against section |
| spec-kit `/speckit.plan` Phase 0 | One research agent per unknown | Not set | None | None | `research.md` as Decision, Rationale, Alternatives |
| gsd-core researchers | Four parallel researchers and a synthesizer; one researcher in `/gsd:explore` | Research mode; 3–5 findings in explore | Researcher's own tagging rules and a checklist; refute-first in explore | `VERIFIED`, `CITED`, `ASSUMED`, mapped to a confidence a CLI computes | One file per dimension, then `SUMMARY.md` |
| BMAD `bmad-deep-recon` | Plan gate picks breadth-first, depth-first or one assistant | Presets for subagents, sources and rounds, with caps | Fresh-context verifiers as material lands, at three levels; optional red team | Per-claim source, publisher, dates, confidence, class and status, in a script-written ledger | Summary first, source appendix, computed staleness map |
| anthropics/skills deep-researcher template | One agent, 3–5 sub-questions | `effort: low` | Self-check of every citation | Inline citations and a confidence-and-gaps section | Report graded by a rubric |
| LangChain `web-research` | Up to 3 parallel subagents | Subtopic count; 3–5 searches each | None seen | Source URLs in findings files | One findings file per subtopic |
| Installed `deep-research` (Anthropic) | Coordinator, parallel researchers, one writer | Researcher-count table; about 10 tool calls each; one extra round | Instructions only, no verifier | One inline link per claim; findings apart from inferences | Narrative prose report |
| Notion `notion-research-documentation` 3.0.9 | One agent | Output format; stop when covered | Instructions on dates and supersession | Citations near claims; findings apart from inference | Chat answer or Notion page |
| `research-router-skill` (OpenAI life sciences) | Subagents only for independent lanes | Minimum useful set of skills | Instructions only | Supports, only suggestive, or missing or contradictory | Answer, evidence by lane, caveats |
| NVIDIA AI-Q server | Planner, concurrent workers (default cap 6), writer without search tools | Shallow or deep route; resource limits | Code checks each citation against captured sources and removes unmatched ones | Internal evidence scores kept out of the report | `output.md` accepted only if its digest matches |

- obra/superpowers, google/elephant-goldfish-model and Fission-AI/OpenSpec have no research skill, and Claude Code's `installed_plugins.json` lists no research plugin, though Anthropic's `deep-research` skill is synced under `~/.claude/skills/`. The skill findings are snapshots of each repository's HEAD between June and November 2026. The issue-tracker evidence rests on titles only, and the community skills found by search were not opened.
- Inferred, from the skill findings: the skills fall into two designs. One gives a single agent a primary-source rule (mattpocock, spec-kit, Notion, the anthropics template). The other fans out to several agents under a claim contract and a tag scheme (BMAD, gsd-core, AI-Q). Only AI-Q checks citations in code against what the tools fetched. Every installed skill except `aiq-research`, which hands the work to a server, checks claims only by instruction to the agent that gathered them.
- The published schemes agree on one point: they keep "how likely" apart from "how sure we are of the basis". The UK PHIA yardstick (page dated 2025-03-24) and the IPCC AR5 note (2010) both do this ([gov.uk 2025](https://www.gov.uk/government/publications/explaining-uncertainty-in-uk-intelligence-assessment/explaining-uncertainty-in-uk-intelligence-assessment); [IPCC AR5 note](https://www.stat.berkeley.edu/users/aldous/157/Papers/ipcc_uncertainty-guidance-note.pdf)). They disagree on the numbers behind the same word, on band shape, and on the number of confidence levels. GRADE (Cochrane Handbook v6.5, August 2023) rates a body of evidence per outcome instead ([Cochrane ch. 14](https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-14)). Source reliability gets its own label in the Admiralty code. The Admiralty definitions rest on a 2025 paper's quotation of STANAG 2511, not on AJP-2.1 itself ([Kelly et al., 2025](https://www.cambridge.org/core/product/E67548E8010A47345C3439D45D9EC6B3/core-reader)). ICD 206 could not be read.
- Readers misread probability words unless the number sits beside the word. In one study, bracketed ranges raised agreement with ICD 203 from 32% to 66%, while a linked table did little ([Wintle et al., 2019](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0213522)). Analysts also struggle to rate source and information independently, as the Admiralty code requires ([Kelly et al., 2025](https://www.cambridge.org/core/product/E67548E8010A47345C3439D45D9EC6B3/core-reader)).
- On neutral questions, forensic interviewing (ABE, updated 2023-06-21; NICHD, 2007) puts open questions first and bars questions that suggest an answer or presuppose a fact. NN/g also says not to suggest an answer, and Pew says to check wording for bias. AAPOR's Code (June 2026) requires the exact wording to be disclosed. One LLM study (arXiv 2602.23971, v4 2026-07-29) found statements draw more sycophancy than questions, and that rewriting input as a question reduces it ([ABE 2023](https://assets.publishing.service.gov.uk/media/6492e26c103ca6001303a331/achieving-best-evidence-criminal-proceedings-2023.pdf); [AAPOR 2026](https://aapor.org/wp-content/uploads/2026/06/AAPOR-2026-Code-of-Ethics-Final-.pdf); [Dubois et al.](https://arxiv.org/abs/2602.23971)).
- On neutral reports, Wikipedia NPOV and Reuters require attribution and keep fact apart from opinion. Reuters adds neutral verbs ("said") and never citing one source as several. The journalism evidence rests on one Reuters handbook mirror from 2008–2012, because BBC, AP, NPR and NYT pages refused fetches ([Reuters Handbook, mirror](https://www.mediareform.org.uk/wp-content/uploads/2015/12/Reuters_Handbook_of_Journalism.pdf)).
- The best-measured failure is citations whose page does not support the claim. Frontier models in May 2026 scored 39–77% on fact support while over 94% of their links worked ([Onweller et al.](https://arxiv.org/html/2605.06635)). Other documented failures are fabricated URLs, one-sided answers, retrieved errors overriding a correct prior, over-spawning and endless search. Measured fixes are few: a URL-liveness tool, multi-agent research on Anthropic's internal eval, and question rewriting against sycophancy. No source measures a claim-support verification pass. Every claim-support rate comes from an LLM judge. DeepTRACE reports moderate human agreement (r = 0.62), and Onweller et al. report only a calibration by manual review.
- Anthropic's only per-size numbers date from June 2025 and Claude Opus 4 and Sonnet 4. A simple fact takes 1 agent with 3–10 tool calls, a comparison 2–4 subagents, and complex research more than 10 ([Anthropic, 2025-06-13](https://www.anthropic.com/engineering/multi-agent-research-system)). Later Anthropic pages say to start with one agent and warn that Opus 4.6 and Opus 5 over-delegate. No OpenAI source read gives counts or budgets. It says to maximize one agent first, and the Codex docs advise parallel subagents for read-heavy work ([OpenAI guide](https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/); [Codex subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)).

## Research skills in the reference repositories and other public repositories

Read 2026-11-28 with `gh api --method GET`. Candidates were found with `gh api --method GET "repos/<repo>/git/trees/HEAD?recursive=1" --jq '.tree[].path' | grep -iE 'research|investigat|explor|deep|search|spike|discover'` (tested 2026-11-28).

**Repositories with no research skill**

- obra/superpowers (22f0b463, 2026-11-03) has no skill that researches a question. The grep matched only two discovery reference files (tested 2026-11-28: tree listing filtered on `SKILL.md`).
- google/elephant-goldfish-model (46933754, 2026-11-25) has no research skill or agent. egm-brainstorm mentions outside libraries only as a lens question (tested 2026-11-28: `gh api --method GET repos/google/elephant-goldfish-model/contents/skills/egm-brainstorm/SKILL.md`).
- In Fission-AI/OpenSpec (dff0188f, 2026-11-28), `openspec-explore` is "a stance, not a workflow", with no subagents, depth, checks or tags ([SKILL.md, dff0188f](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/skills/openspec-explore/SKILL.md)).

**mattpocock/skills `research`** (bbadaa63, 2026-11-27)

- The whole job goes to one background agent started "with a fresh context window" ([SKILL.md, bbadaa63](https://github.com/mattpocock/skills/blob/bbadaa631c37af594e5a05c9cefacd9956136b18/skills/engineering/research/SKILL.md)).
- It asks the agent to "Follow every claim back to the source that owns it" and to write "a single Markdown file, citing each claim's source" (same file). It has no confidence label.
- The doc page says there is "no allowlist, no domain gate, and no verification pass", and "The skill has no stopping criterion" ([docs/engineering/research.md, bbadaa63](https://github.com/mattpocock/skills/blob/bbadaa631c37af594e5a05c9cefacd9956136b18/docs/engineering/research.md)).
- The doc still calls nesting bug #530 "an open bug". The issue was closed as not planned on 2026-10-06, and its last comment says stopping re-spawning "is the harness's responsibility" (tested 2026-11-28: `gh api --method GET repos/mattpocock/skills/issues/530`). The doc was last changed 2026-10-07, after the closing.

**github/spec-kit `speckit.assess.research`** (f2010547; command added 2026-07-17)

- It runs in one agent and covers fixed lenses: Users & demand, Prior art, Market & context, Data & constraints ([speckit.assess.research.md, f2010547](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/extensions/assess/commands/speckit.assess.research.md)).
- Each finding is tagged "confidence `high | medium | low`" and `cited` or `assumption` (same file).
- A URL allowlist governs fetching. For a host off the list, the agent asks once in interactive mode and records `[UNVERIFIED — fetch skipped]` in automated mode. There is no second-source check (same file).
- The report needs "an **Evidence Against the Idea** section every time — if you cannot find any, say so explicitly" (same file).

**open-gsd/gsd-core researcher agents** (e9c3e540, 2026-11-28)

- `/gsd:new-project` spawns "4 parallel gsd-project-researcher agents", one each for Stack, Features, Architecture and Pitfalls ([elaboration.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/new-project/detail/elaboration.md)). `gsd-research-synthesizer` reads the four files, writes `SUMMARY.md` with a confidence table per area, and commits ([gsd-research-synthesizer.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/agents/gsd-research-synthesizer.md)).
- The phase researcher tags every claim `[VERIFIED: …]`, `[CITED: …]` or `[ASSUMED]`, which map to HIGH, MEDIUM and LOW ([gsd-phase-researcher.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/agents/gsd-phase-researcher.md)).
- An in-repo value earns `[VERIFIED]` only if the file was opened with `Read` "**this session**", with a verbatim quote (same file).
- A claim resting on missing metadata stays `[ASSUMED]` unless a failing test output is pasted. "Registry existence alone does not confer `[VERIFIED]` status — a slopsquatted package also passes `npm view`" (same file).
- Confidence comes from a CLI call, `gsd_run query classify-confidence`, not from the agent's judgement ([gsd-project-researcher.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/agents/gsd-project-researcher.md)).
- ADR-0656 (Accepted, 2026-06-03) moved provider order and confidence tiers into one code module. Before that, seven researcher files "drifted independently". "Provider authority alone caps at MEDIUM" ([ADR-0656](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/docs/adr/0656-research-module-seam.md)).
- A shared checklist asks for negative claims checked against official docs, cross-referencing for critical claims, checked publication dates, and a "What might I have missed?" review ([research-verification-protocol.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/references/research-verification-protocol.md)).
- `/gsd:explore` spawns one researcher for "3-5 key findings, no more than 200 words". It tells the researcher to "first try to REFUTE" each finding. Findings are tagged `[admit: …]`, `[refute: …]` or `[abstain: …]`, and abstentions go to an "Unresolved ledger, never smoothed into the narrative" ([explore.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/explore.md)). For Codex it adds a rule to stop and wait for the subagent (same file).

**bmad-code-org/BMAD-METHOD `bmad-deep-recon`** (e435a225, 2026-11-12; folder moved 2026-11-11)

- The plan gate is the one hard stop. It picks breadth-first (assistants split dimensions), depth-first (split by angle) or straightforward ("one assistant, a handful of calls, no fan-out") ([run.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/core-tools/bmad-deep-recon/references/run.md)).
- Presets set depth, and the user's request overrides them (same file). The caps are 10 subagents, 25 sources per round and 5 rounds.

  | Preset | Subagents | Sources per round | Rounds |
  | --- | --- | --- | --- |
  | `quick` | 2 | 5 | 1 |
  | `standard` (default) | 3 | 8 | 2 |
  | `deep` | 6 | 12 | 3 |

- Each researcher's budget is "under 5 for a simple lookup, ~5 medium, ~10 hard, 15 for genuinely multi-part, 20 never exceeded" (same file).
- A dimension stops on coverage or "novelty exhaustion". A "stop-and-write valve" writes from digests already on disk when a run drags (same file).
- Research subagents "receive only their brief — no project files, no ambient context". The skill adds "Never conclude from training data alone" ([SKILL.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/core-tools/bmad-deep-recon/SKILL.md)).
- Each researcher returns "a digest, not raw results", with each claim as `{claim, source, publisher, pub_date, accessed, confidence, class}`, plus what it could not find ([run.md](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/core-tools/bmad-deep-recon/references/run.md)).
- Fresh-context verifiers check claims "as material lands … never as an end-of-run rewrite pass". `normal` spot-checks load-bearing claims, `high` cross-checks two-source classes and adds a red team, and `max` cross-checks every claim ([verification.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/core-tools/bmad-deep-recon/references/verification.md)).
- An independent source is "a different publisher with different underlying data or reporting — not a syndication" (same file).
- Each claim ends verified, disputed ("report both figures … never average"), unverified or overturned. "Confidence is per-claim, never per-section" (same file).
- The optional red team, off by default, gets "the conclusion and a search budget, no supporting evidence" (same file).
- Claims go to an append-only ledger through a script, and `recon_kit.py tally` produces the counts, "never hand-counted" ([synthesis.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/core-tools/bmad-deep-recon/references/synthesis.md)).
- The report runs: executive summary ("Written last, placed first"), dimension sections, cross-dimension insights, contrary evidence, recommendations, open questions, a source appendix, and a staleness map computed by script (same file).

**Other public repositories**

- anthropics/skills (e4bb5d96) ships a Managed Agents "deep researcher" template inside `claude-api`, not a standalone skill ([deep-researcher.md, e4bb5d96](https://github.com/anthropics/skills/blob/e4bb5d960d87126ff3b3a8af1a104b7db67560ba/skills/claude-api/shared/managed-agents-quickstarts/deep-researcher.md)).
  - It is one agent that will "Decompose it into 3-5 concrete sub-questions", with `effort: low`.
  - It tells the agent to "check every citation" and replace secondary sources with primary ones, and to "close with a 'confidence & gaps' section".
  - Its rubric includes "Disagreements between sources are surfaced rather than smoothed over".
- openai/skills (49f948fa, HEAD 2026-06-24) has only `notion-research-documentation`, with no subagents and no confidence labels ([SKILL.md, 49f948fa](https://github.com/openai/skills/blob/49f948faa9258a0c61caceaf225e179651397431/skills/.curated/notion-research-documentation/SKILL.md)).
- LangChain's `web-research` example plans "2-5 specific subtopics" and will "Run up to 3 subagents in parallel", each with "Budget: 3-5 web searches maximum". Each writes `findings_[subtopic].md` with source URLs ([deepagentsjs, 669bbe32](https://github.com/langchain-ai/deepagentsjs/blob/669bbe32c38ea99efca8cab54ec727fd3b4e838f/examples/skills/web-research/SKILL.md)). No claim check appeared in the first 70 lines, which is all that was read.
- `gh search code "research subagents" --filename SKILL.md` (tested 2026-11-28) found more research skills, among them glittercowboy/plugin-freedom-system `deep-research` and aiskillstore/marketplace `research`. None was opened.

## Research skills installed on this machine

Read 2026-11-28 with `find`, `grep`, `cat`, `diff`, `md5` and `git log`, read-only. The search `find ~/.claude ~/.codex ~/.agents "~/Library/Application Support/Claude" \( -name SKILL.md -o -path '*/agents/*.md' \) | xargs grep -il research` found 1049 `SKILL.md` files. About 100 of them mention research, most only in passing.

**`deep-research` (Anthropic, plugin `anthropic-skills` 1.0.0, catalog `updatedAt` 2026-09-14)**

- Two identical copies sit on disk (tested 2026-11-28: `diff -r`): one under `~/.claude/skills/synced/` and one under Claude Desktop's skills plugin.
- One coordinator spawns N researchers in parallel, then one report writer. The coordinator is told it "should never conduct research or write files directly" ([SKILL.md](file:///Users/stebau/.claude/skills/synced/5b890911-378c-4e9f-bd8c-fd223927b55b_9e22c7b4-b300-41d4-87b9-427a50b7d14c/deep-research/SKILL.md)). Subtopics are to be "mutually exclusive and collectively exhaustive".
- A table maps question shape to researcher count, from 1 for a single fact to 6+ for a large set. "When in doubt, 3 researchers is a reasonable default." One extra round is allowed, and "This step can only be followed once" (same file).
- Each researcher gets "Roughly 10 tool calls is typical; avoid exceeding 15" ([researcher.md](file:///Users/stebau/.claude/skills/synced/5b890911-378c-4e9f-bd8c-fd223927b55b_9e22c7b4-b300-41d4-87b9-427a50b7d14c/deep-research/references/researcher.md)).
- There is no verification step. The researcher judges each source (speculation or fact, primary or aggregator) and must note conflicts. Notes carry Takeaway, Cited Findings, Inferences and Gaps. Every claim needs an inline link, or it moves to Gaps (same file).
- The writer drops major claims without a URL. It writes dense prose ("Don't use bullets or numbered lists"). It is told to "Avoid hedging" and also to "Explicitly state what is uncertain or unknown" ([report-writer.md](file:///Users/stebau/.claude/skills/synced/5b890911-378c-4e9f-bd8c-fd223927b55b_9e22c7b4-b300-41d4-87b9-427a50b7d14c/deep-research/references/report-writer.md)).
- It names Claude tools: AskUserQuestion, "the Agent tool (named Task in some versions)", WebSearch and WebFetch ([SKILL.md](file:///Users/stebau/.claude/skills/synced/5b890911-378c-4e9f-bd8c-fd223927b55b_9e22c7b4-b300-41d4-87b9-427a50b7d14c/deep-research/SKILL.md)).

**`notion-research-documentation` (Notion 3.0.9, Codex remote cache, folder dated Nov 12 2026)**

- It uses no subagents. It picks one of four output formats and says "Stop retrieval when the question is covered and material conflicts are resolved or explicitly reported" ([SKILL.md 3.0.9](file:///Users/stebau/.codex/plugins/cache/openai-curated-remote/notion/3.0.9/skills/notion-research-documentation/SKILL.md)).
- It says "Check effective dates and explicit supersession", "Do not describe partial search as exhaustive", and "separate findings from inference or recommendations" (same file).
- An older copy from marketplace commit 11c74d6b (2026-07-13) is a shorter quick-start: "prefer direct quotes for critical facts" ([older SKILL.md](file:///Users/stebau/.codex/plugins/cache/openai-curated/notion/11c74d6b/skills/notion-research-documentation/SKILL.md)). Which copy a Codex session loads was not tested.

**`research-router-skill` (OpenAI life-science-research 1.0.3)**

- It uses subagents "only when the work cleanly decomposes into independent lanes". It avoids them when "the extra coordination cost is likely to exceed the retrieval benefit" ([SKILL.md](file:///Users/stebau/.codex/.tmp/plugins/plugins/life-science-research/skills/research-router-skill/SKILL.md), lines 88–120).
- The coordinator keeps interpretation, conflict resolution and synthesis. Each subagent returns what it checked, findings, caveats, sources used and artifact paths (same file).
- It labels evidence as "supports a conclusion", "only suggestive", or "missing or contradictory" (same file).
- It sits only in a marketplace clone at commit 11c74d6b (2026-07-13) and is not enabled in `~/.codex/config.toml` (tested 2026-11-28: `grep` on config.toml and `git log -1`).

**`aiq-research` (NVIDIA plugin 1.0.2, skill 2.1.0)**

- It sends the question to a local AI-Q server and polls the job. The skill itself does none of the five things ([SKILL.md](file:///Users/stebau/.codex/.tmp/plugins/plugins/nvidia/skills/aiq-research/SKILL.md)). Like the router, it is in the July 2026 clone only and not enabled.

**What else turned up**

- `~/.claude/plugins/installed_plugins.json` lists skill-creator, code-simplifier, code-review, commit-commands and frontend-design, so Claude Code has no research plugin installed (tested 2026-11-28).
- Inferred, from the four skill findings above: no installed skill has a separate claim-checking step, and none asks for a quote, version, date or command beside each claim.

## Schemes for evidence strength, source reliability and confidence

**ICD 203, Analytic Standards (ODNI; signed 2015-01-02, with later technical amendments)**

- Likelihood applies to "an event or development". Products must use one of two seven-term word sets tied to contiguous bands from 01–05% to 95–99%. Mixing the two sets is discouraged ([ICD 203 as amended](https://archive.dni.gov/files/documents/ICD/ICD-203.pdf)).
- Confidence applies to the judgement and rests on "the logic and evidentiary base". Products "must not combine a confidence level and a degree of likelihood … in the same sentence" (same source).
- Source quality is described with source descriptors under ICD 206, covering factors such as access, motivation and bias (same source).

**UK PHIA Probability Yardstick (gov.uk page published 2025-03-24)**

- Seven terms carry approximate bands with gaps between them, for example 75–80% falls between "Likely or Probable" and "Highly Likely" ([gov.uk, 2025-03-24](https://www.gov.uk/government/publications/explaining-uncertainty-in-uk-intelligence-assessment/explaining-uncertainty-in-uk-intelligence-assessment)).
- Confidence is a separate rating: "One of three ratings is assigned - High, Moderate or Low" (same page). The page does not mention source reliability.

**IPCC AR5 Guidance Note (Mastrandrea et al., November 2010)**

- Evidence is rated limited, medium or robust, and agreement low, medium or high. Authors must give "a traceable account" ([IPCC AR5 note](https://www.stat.berkeley.edu/users/aldous/157/Papers/ipcc_uncertainty-guidance-note.pdf)).
- Confidence has five qualifiers and "should not be interpreted probabilistically" (same source).
- Likelihood bands are nested with "fuzzy" boundaries; "likely" (66–100%) contains "very likely". The note prefers a numeric range when one exists (same source).
- It asks for reciprocal statements "to avoid value-laden interpretations", for example both dying and surviving (same source).

**GRADE, in the Cochrane Handbook v6.5 chapter 14 (last updated August 2023)**

- Certainty applies to "a body of evidence for each individual outcome", on four levels from high to very low ([Cochrane ch. 14](https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-14)).
- Randomized trials start high and non-randomized studies low. Five domains lower the rating: risk of bias, inconsistency, indirectness, imprecision and publication bias (same source).

**How they compare.** The word "likely" maps to different numbers in each scheme:

| Scheme | "Likely" | Band shape | Confidence levels |
| --- | --- | --- | --- |
| ICD 203 | 55–80% | Contiguous | Not listed in the extracted text beyond "high confidence" |
| PHIA 2025 | 55–75% | Gaps between bands | Three |
| IPCC AR5 2010 | 66–100% | Nested | Five |
| GRADE | No likelihood scale | — | Four certainty levels |

- ICD 203 keeps source quality as a separate required description. IPCC folds it into evidence quality and GRADE into risk of bias ([ICD 203](https://archive.dni.gov/files/documents/ICD/ICD-203.pdf); [IPCC](https://www.stat.berkeley.edu/users/aldous/157/Papers/ipcc_uncertainty-guidance-note.pdf); [Cochrane](https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-14)).
- Each scheme requires a stated basis for its ratings and uses a small fixed vocabulary (same sources).
- Inferred, from the band table: a word like "likely" is ambiguous unless the report names the scheme it borrows from.

## Wording questions and reports neutrally

- Pew advises checking words for bias and avoiding double-barreled questions. It recommends a choice between statements over agree-disagree items, because of acquiescence. It warns that question order changes answers ([Pew, "Writing Survey Questions", undated, © 2026](https://www.pewresearch.org/writing-survey-questions/)).
- NN/g's rules for user research include "Do not suggest an answer" and "Do not assume you know what the user is feeling" ([Schade, NN/g, 2017-12-17](https://www.nngroup.com/articles/leading-questions/)).
- The US Intelligence Community standards require analysts to "distinguish between underlying intelligence information and analysts' assumptions and judgements" and to "Incorporate analysis of alternatives". They were "revised, revalidated, and approved by the DNI in January 2015 and again in June 2023" ([intel.gov, undated](https://www.intel.gov/mission/our-values/objectivity); [ICD 203](https://archive.dni.gov/files/documents/ICD/ICD-203.pdf)).
- Wikipedia's NPOV policy says "Avoid stating opinions as facts", "Avoid stating seriously contested assertions as facts" and "Prefer nonjudgmental language". It allows biased opinion only "with in-text attribution" ([Wikipedia:NPOV, oldid=1386821137, fetched 2026-11-28](https://en.wikipedia.org/wiki/Wikipedia:Neutral_point_of_view)).
- Sharma et al. found that "five state-of-the-art AI assistants consistently exhibit sycophancy", and that "when a response matches a user's views, it is more likely to be preferred" ([arXiv:2310.13548, v1 2023-10-20, v4 2025-05-10](https://arxiv.org/abs/2310.13548)).
- Dubois et al. (UK AISI) found "sycophancy is substantially higher in response to non-questions compared to questions". Sycophancy "increases monotonically with epistemic certainty conveyed by the user" ([arXiv:2602.23971, v1 2026-02-27, v4 2026-07-29](https://arxiv.org/abs/2602.23971)).
- Asking the model to turn non-questions into questions "significantly reduces sycophancy", more than a prompt telling it not to be sycophantic. The abstract does not name the models tested (same source).
- Inferred, from the Dubois et al. findings: a lead agent that hands its hypothesis to a subagent as a statement invites agreement. No source tests agent-to-subagent briefs.

## Failure modes of LLM research and report writing, and tested countermeasures

**Documented failures**

- DeepTRACE audited 9 public systems on 303 queries as of 2025-08-27. Citation accuracy in its Table 1 ranged from 79.1% for GPT-5 (DR) to 31.4% for GPT-5 with search. Unsupported statements ranged from 12.5% for GPT-5 (DR) to 97.5% for Perplexity (DR) ([DeepTRACE, arXiv 2509.04499v1, Sep 2025](https://arxiv.org/html/2509.04499v1)). Its text gives Gemini 40.3% where its table gives 50.3%. Its abstract's "40–80%" does not cover its own 31.4% figure.
- In DeepTRACE, one-sidedness on debate questions stayed at 54.7–94.8% even in deep-research modes. The paper describes GPT-5 (DR) as "aligning only with the users perspective" (same source).
- Onweller et al. fetched each cited page for 14 models on 130 queries. Frontier models scored 39–77% on Fact Check, while "link validity above 94% and relevance above 80%" ([arXiv 2605.06635, 2026-05-07](https://arxiv.org/html/2605.06635)).
- Raising the tool-call limit from 2 to 150 lowered Fact Check from about 79% to 17% for GPT-5.4 and from 80% to 58% for Claude Opus 4.6. The authors conclude "more retrieval does not produce more accurate citations" (same source).
- Rao, Wong and Callison-Burch found "3–13%" hallucinated citation URLs, counted as URLs that neither resolve nor appear in the Wayback Machine ([arXiv 2604.03173, 2026-04-03](https://arxiv.org/abs/2604.03173)).
- In ClashEval, models adopted incorrect retrieved content over a correct prior "over 60% of the time" ([arXiv 2404.10198v2](https://arxiv.org/html/2404.10198v2)).
- Anthropic's early research system spawned "50 subagents for simple queries", searched endlessly for sources that do not exist, duplicated work under vague briefs, and preferred SEO content farms. The post gives no rates ([Anthropic Engineering, 2025-06-13](https://www.anthropic.com/engineering/multi-agent-research-system)).
- OpenAI's deep research system card names prompt injection and hallucination as risks, and reports training "to resist malicious instructions" found while browsing. Its summary page gives no rates ([OpenAI, 2025-02-25](https://openai.com/index/deep-research-system-card/)).

**Countermeasures with a measured effect**

- With the urlhealth liveness tool, agents corrected their own citations and cut non-resolving URLs by about 6 to 79 times, to under 1%. "effectiveness depends on the model's tool-use competence" ([Rao et al., 2026-04](https://arxiv.org/abs/2604.03173)).
- An Opus 4 lead with Sonnet 4 subagents "outperformed single-agent Claude Opus 4 by 90.2%" on Anthropic's internal eval. A tool-testing agent that rewrote tool descriptions cut later task time by 40% ([Anthropic Engineering, 2025-06-13](https://www.anthropic.com/engineering/multi-agent-research-system)).
- Chain-of-Verification "decreases hallucinations across a variety of tasks" by answering verification questions apart from the draft. The abstract gives no numbers or model ([arXiv 2309.11495, Sep 2023](https://arxiv.org/abs/2309.11495)).
- The question-rewriting result from Dubois et al. is in the section on neutral wording.
- Proposed but not tested in these sources: a citation agent, detailed briefs and source-quality heuristics (Anthropic), DeepTRACE's 16 design recommendations, and ensemble or hybrid citation judging (Onweller et al.).

**Limits**

- DeepTRACE's LLM judge agreed with humans at r = 0.62 on factual support and r = 0.72 on confidence ([DeepTRACE](https://arxiv.org/html/2509.04499v1)). Onweller et al. calibrated their judge through manual review of 50–100 LLM judgments ([arXiv 2605.06635](https://arxiv.org/html/2605.06635)).
- GPT-5 (DR) is the best system in DeepTRACE in 2025, while GPT-5.4 falls furthest at depth in Onweller et al. in 2026. The two measure different set-ups (same sources).
- Inferred, from the Rao et al. and Onweller et al. findings: a link check catches the smaller failure (3–13% fabricated URLs) and misses the larger one (unsupported citations). No source measures a claim-support verification pass.

## What Anthropic and OpenAI publish on scaling research effort

**Anthropic**

- The June 2025 post scales effort by query: "Simple fact-finding requires just 1 agent with 3-10 tool calls, direct comparisons might need 2-4 subagents with 10-15 calls each, and complex research might use more than 10 subagents" ([Anthropic Engineering, 2025-06-13](https://www.anthropic.com/engineering/multi-agent-research-system)). It ran Claude Opus 4 as lead and Sonnet 4 as subagents.
- A subagent brief must hold "an objective, an output format, guidance on the tools and sources to use, and clear task boundaries" (same source).
- Multi-agent systems "use about 15× more tokens than chats". Token usage alone explained 80% of BrowseComp variance. Coding is named as a poor fit, because agents share context (same source).
- The January 2026 blog post advises starting with one agent. It splits only "when context pollution degrades performance", "when tasks can run in parallel", or "when specialization improves tool selection". It puts the cost at "3-10x more tokens than single-agent approaches" and gives no subagent count ([Claude blog, 2026-01-23](https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them)).
- Subagents return a condensed summary of about 1,000–2,000 tokens ([Anthropic Engineering, 2025-09-29](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)).
- The undated prompting guide says "Claude Opus 4.6 has a strong tendency to use subagents" and "Claude Opus 5 also delegates to subagents more readily than prior models", and gives a damping prompt ([Prompting best practices, undated, lists models up to Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)).
- Claude Code runs 20 concurrent subagents by default and allows nesting "up to three layers below the main conversation" ([Claude Code subagents, undated, mentions v2.1.319](https://code.claude.com/docs/en/sub-agents)).
- The agent-teams page advises "Start with 3-5 teammates" and adversarial teammates that try to disprove each other ([Claude Code agent teams, undated, experimental](https://code.claude.com/docs/en/agent-teams)).

**OpenAI**

- "Our general recommendation is to maximize a single agent's capabilities first." The guide splits for complex logic or overlapping tools ([OpenAI practical guide, date not confirmed](https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/)).
- Codex docs advise "parallel agents for read-heavy tasks such as exploration, tests, triage, and summarization". They warn that subagent workflows "consume more tokens than comparable single-agent runs" and give no numeric concurrency default ([Codex subagents, undated](https://learn.chatgpt.com/docs/agent-configuration/subagents)).
- Deep research is one model that browses for "5 to 30 minutes", with no mention of subagents. "The more the model browses and thinks about what its browsing, the better it does." It "currently shows weakness in confidence calibration" ([OpenAI, 2025-02-02](https://openai.com/index/introducing-deep-research/)).
- No OpenAI source read gives subagent counts or tool-call budgets by question size.

**Dating**

- The 15× figure compares against chat and the 3–10× figure against a single agent, so neither replaces the other ([2025-06-13](https://www.anthropic.com/engineering/multi-agent-research-system); [2026-01-23](https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them)).
- No Anthropic page found revises the 2025 effort table for newer models.

## News sourcing standards, AAPOR, PRISMA 2020 and forensic interviewing

**Reuters Handbook of Journalism (mirrored PDF, pages last modified 2008–2012)**

- "A named source is always preferable to an unnamed source" and "Anonymous sources are the weakest sources" ([Reuters Handbook, mirror](https://www.mediareform.org.uk/wp-content/uploads/2015/12/Reuters_Handbook_of_Journalism.pdf)).
- "Two or more sources are better than one." A single anonymous source needs "a special authorisation procedure" (same source).
- Reporters must never "cite sources in the plural when we have only one", and must "Be explicit about what you don't know" (same source).
- Reporters should "try to disprove as well as prove your story" (same source).
- Writers should use "said" over "admitted, agreed, according to, revealed, refuted, claimed", which "contain an element of judgment by the reporter". "Allegations should not be portrayed as fact" (same source).

**AAPOR Code of Professional Ethics and Practices (June 2026)**

- It requires "The exact wording and presentation of any measurement tool", with preceding context and instructions, now including instructions to "chatbots" ([AAPOR 2026, III.A.3](https://aapor.org/wp-content/uploads/2026/06/AAPOR-2026-Code-of-Ethics-Final-.pdf)).
- Findings must be "a balanced and accurate portrayal". Members must not "imply that interpretations claim greater confidence in our findings than the data and methodology warrant" (same source, II.A.3–4).
- The 2026 Code adds disclosure of AI use (same source, Section III items 11–12).

**PRISMA 2020 (Page et al., BMJ 2021;372:n71, 2021-03-29)**

- Item 4 requires "an explicit statement of the objective(s) or question(s)". Item 6 requires every source searched and "the date when each source was last searched". Item 7 requires "the full search strategies" ([PMC copy](https://pmc.ncbi.nlm.nih.gov/articles/PMC8005924/)).
- Item 15 requires the methods used "to assess certainty (or confidence) in the body of evidence". Items 23b and 23c split limitations of the evidence from limitations of the review process (same source).

**Forensic interviewing**

- Achieving Best Evidence (4th edition, updated 2023-06-21) says questioning should start with open-ended questions, then specific-closed ones. Forced-choice and leading questions come "only … as a last resort" ([ABE 2023, para 3.51](https://assets.publishing.service.gov.uk/media/6492e26c103ca6001303a331/achieving-best-evidence-criminal-proceedings-2023.pdf)).
- A leading question "implies the answer or assumes facts that are likely to be in dispute". It "may also significantly distort the witness's memory" (same source, paras 3.68–3.69).
- "questions worded using 'the' compared with 'a' result in greater levels of erroneous responses", because "'the' presupposes the existence of an item" (same source, para 3.70).
- The NICHD protocol urges "priority to open-ended recall prompts". It defines a suggestive prompt as one that "assumes information not disclosed by the child or implies that a particular response is expected" ([Lamb et al., 2007](https://pmc.ncbi.nlm.nih.gov/articles/PMC2180422/)).
- Inferred, from the ABE and NICHD findings: the rules were written for child and vulnerable witnesses. Applying them to briefing an LLM is an analogy neither source makes.

## Admiralty grading, ICD 206 and how readers interpret probability labels

- No primary text of AJP-2.1, JDP 2-00 or FM 2-22.3 could be opened. ICD 206 on archive.dni.gov is a scanned image with no text layer ([ICD-206.pdf, fetched 2026-11-28](https://archive.dni.gov/files/documents/ICD/ICD-206.pdf)).
- Kelly, Budescu, Dhami and Mandel quote STANAG 2511 (2003) as rating source reliability from A ("tried and trusted") to E, with F "reliability cannot be judged". Information credibility runs from 1 ("confirmed by other sources") to 5, with 6 "truth cannot be judged" ([Judgment and Decision Making 20, e36, 2025-09-12](https://www.cambridge.org/core/product/E67548E8010A47345C3439D45D9EC6B3/core-reader)).
- The code "requires the evaluation of source reliability and information credibility independently". Earlier studies, as the paper reviews them, found encoders mostly assign diagonal codes such as A1 and B2 (same source).
- In the paper's own experiments, 74 analysts and 175 nonexperts took part. Source reliability weighed more in trustworthiness ratings. The authors find it "unclear whether information evaluators are capable of treating source reliability and information credibility as fully independent" (same source).
- Wintle et al. tested 924 members of the public. Range overlap with ICD 203 was 32% with no guideline, 39% with a linked table, 40% with a tooltip and 66% with numbers in brackets ([PLoS ONE 14(4): e0213522, 2019](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0213522)). The paper gives the sample as 809 in Methods and 924 in Results.
- People "do not reliably refer to guidelines unless they are directly in front of them". Negative terms spread more than positive ones (same source).
- Wintle et al. report that Budescu et al. (2014) found 40% consistency for IPCC terms with brackets against 27% without. They argue IPCC's overlapping categories are harder to read than ICD 203's (same source). The Budescu paper was not read directly.
- The IPCC note itself warns that "readers may adjust their interpretation of this likelihood language according to the magnitude of perceived potential consequences" ([IPCC AR5 note, 2010](https://www.stat.berkeley.edu/users/aldous/157/Papers/ipcc_uncertainty-guidance-note.pdf)).

## Parts of the reference skills read after confirmation, NVIDIA AI-Q, and issue trackers

**BMAD deep-recon pack and process files** (e435a225)

- The technical pack sets freshness windows: "versions & compatibility ≤ 1 mo · ecosystem signals ≤ 6 mo · landscape ≤ 12 mo (AI-adjacent ≤ 3 mo) · patterns ≤ 2 yr". It says "an old complaint against a current version is a false claim" ([types/technical.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/core-tools/bmad-deep-recon/types/technical.md)).
- Its two-source classes are version and compatibility claims, the performance numbers a recommendation rests on, and claims that a technology failed: "one post-mortem is an anecdote" (same file).
- Conflicts "resolve by recency, consistency with adjacent established facts, and publisher quality — never by averaging" ([run.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/core-tools/bmad-deep-recon/references/run.md)).
- Without subagents, the lead runs the same rounds itself, in sequence, under the same budgets (same file).
- For a choice between candidates, requirements are agreed "before any candidate research runs", and the verdict shows the strongest argument against the pick ([selection.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/core-tools/bmad-deep-recon/references/selection.md)).

**gsd-core project researcher and synthesizer** (e9c3e540)

- The project researcher sets depth by mode: Ecosystem (default), Feasibility or Comparison ([gsd-project-researcher.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/agents/gsd-project-researcher.md)). No numeric budget appeared in the files read.
- Researchers return only a short confirmation: "Do NOT return the file contents in your response" (same file).
- The synthesizer reports that Claude Code refuses a subagent's `Write` to some exact file names, `SUMMARY.md` among them, with `Subagents should return findings as text, not write report files`. It says this was "observed on Claude Code 2.1.301" ([gsd-research-synthesizer.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/agents/gsd-research-synthesizer.md)). Not tested in this run.
- The elaboration file is read only when `workflow.compact_content` is `false`; otherwise agents get condensed `*.compact.md` text ([elaboration.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/new-project/detail/elaboration.md)).

**spec-kit `/speckit.plan` Phase 0** (f2010547)

- Each `NEEDS CLARIFICATION`, dependency and integration becomes a task, then "Generate and dispatch research agents" ([templates/commands/plan.md, f201054](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/plan.md)).
- `research.md` holds "Decision", "Rationale" and "Alternatives considered". Lines 114–135 have no depth setting, no verification step and no source or confidence field (same file).

**NVIDIA AI-Q Deep Researcher** (951a1a11, 2026-10-09)

- An orchestrator with no source tools runs a source router, a planner that writes a `ResearchPlan`, concurrent researcher workers ("one worker per ResearchQuery"), and a writer that "has no source-search tools and performs no new research" ([deep-researcher.md, 951a1a1](https://github.com/NVIDIA-AI-Blueprints/aiq/blob/951a1a1114e9818073ddbe2a5fdbfa824751f4d3/docs/source/architecture/agents/deep-researcher.md)).
- `max_research_concurrency` defaults to `6`. The example config sets `max_research_queries: 20` and `max_source_tool_calls: 100` (same file).
- A chat researcher routes each query as "'shallow' for quick lookups or 'deep' for comprehensive research" ([depth.py, 951a1a1](https://github.com/NVIDIA-AI-Blueprints/aiq/blob/951a1a1114e9818073ddbe2a5fdbfa824751f4d3/src/deep_researcher_agent/agents/chat_researcher/models/depth.py)).
- With `enable_citation_verification` on by default, "a deterministic post-processing pipeline checks citations against sources captured from configured tools". "Unmatched citations are removed and recorded with an audit reason" ([deep-researcher.md](https://github.com/NVIDIA-AI-Blueprints/aiq/blob/951a1a1114e9818073ddbe2a5fdbfa824751f4d3/docs/source/architecture/agents/deep-researcher.md)).
- The runtime accepts the report "only when its exact UTF-8 bytes match the digest recorded after a successful writer mutation" (same file).
- The writer cites every source-derived claim inline as `[1]`. It presents competing claims and says "which evidence is stronger or more recent". It keeps internal evidence scores out of the report unless asked ([writer.j2, 951a1a1](https://github.com/NVIDIA-AI-Blueprints/aiq/blob/951a1a1114e9818073ddbe2a5fdbfa824751f4d3/src/deep_researcher_agent/agents/deep_researcher/prompts/writer.j2)).

**Issue trackers (titles only)**

- BMAD's deep-recon reports are all closed. Two concern the citation-parsing script: #3167 (2026-11-03, inline code counted as a citation) and #2724 (2026-08-12, numeric tables corrupt citations). #3153 (2026-10-30) asks for Run mode on hosts without web tools (tested 2026-11-28: `gh search issues --repo bmad-code-org/BMAD-METHOD deep-recon`).
- gsd-core has open research issues filed 2026-11-22 to 2026-11-24. Among them are #6616 "tell each parallel researcher its share of the web search allowance", #6621 "ask about hard limits … before research starts", and #6623 on dimensions that "assume a software project" (tested 2026-11-28: `gh search issues --repo open-gsd/gsd-core research`).
- spec-kit's research issues are mostly from 2025, such as #643 (2025-09-28) "Spec-kit still thinks it's 2024 when doing research" (tested 2026-11-28: `gh search issues --repo github/spec-kit research --sort created`).
- Inferred, from the BMAD issue titles and the AI-Q citation check: a deterministic citation checker breaks on edge cases such as inline code and numeric tables.

## Open questions

- No source measures the effect of a separate claim-support verification pass on a research report. Such a measure could change which countermeasures the Answer counts as shown.
- The primary texts of AJP-2.1 and ICD 206 were not read: AJP-2.1 was out of reach and ICD 206 is a scanned image. The Admiralty grades B–D and 2–4, and ICD 206's source-descriptor rules, are unconfirmed.
- The BBC, AP, NPR and NYT standards and the current Reuters handbook refused fetches or timed out. The journalism finding rests on one 2008–2012 mirror.
- The model-specific Anthropic prompting pages ("Prompting Claude Opus 5", "Prompting Claude Fable 5.2") were not opened. They may hold newer subagent guidance than the 2025 effort table.
- The Claude Code refusal of subagent writes to report file names is gsd-core's report for version 2.1.301 and was not tested. Which names are refused is not known.
- The community research skills found by search were not opened, and issue bodies were not read.
- ICD 203 returned Access Denied from archive.dni.gov and dni.gov on recheck (2026-11-28), so its findings, and the ICD 203 cells in the band table, rest on the researcher's read alone. They were removed from the Answer.
- The OpenAI API deep research guide mentions `o4-mini`, but the recheck did not find the 2026-10-23 shutdown date the researcher reported, so whether the 2025 deep research figures describe retired models is unconfirmed ([API guide, undated](https://developers.openai.com/api/docs/guides/deep-research)).
- The installed plugin versions (anthropic-skills 1.0.0, Notion 3.0.9, life-science-research 1.0.3, NVIDIA 1.0.2) were not compared with a registry; no public registry was checked.
- The OpenAI deep research system card PDF could not be read, so its prompt-injection and hallucination rates are missing.

## Method

- The user confirmed the brief. Sub-questions 7, 8 and 9 were added after confirmation.
- Researcher 1 covered the seven reference repositories and other public skill repositories (notes-1.md).
- Researcher 2 covered the research skills installed under `~/.claude`, `~/.codex`, `~/.agents` and `~/Library/Application Support/Claude` (notes-2.md).
- Researcher 3 covered evidence, reliability and confidence schemes: ICD 203, PHIA, IPCC AR5 and GRADE (notes-3.md).
- Researcher 4 covered neutral question and report wording, and sycophancy studies (notes-4.md).
- Researcher 5 covered failure modes and countermeasures in LLM research (notes-5.md).
- Researcher 6 covered Anthropic and OpenAI guidance on scaling effort (notes-6.md).
- Researcher 7 covered Reuters, AAPOR, PRISMA 2020 and forensic interviewing (notes-7.md).
- Researcher 8 covered the Admiralty grading, ICD 206 and interpretation studies (notes-8.md).
- Researcher 9 covered the BMAD packs, gsd-core researchers, spec-kit's plan research step, NVIDIA AI-Q and three issue trackers (notes-9.md).
- Live checks were read-only: `gh api --method GET` and `gh search` against GitHub, and file reads of the installed skill folders. Nothing was executed beyond those reads.
- Several sites refused automated fetches, and no PDF text extractor was available, so some PDFs could not be read.
- A separate checker reread the sources behind the Answer and most findings on 2026-11-28: all 11 repository HEADs (unchanged), the tree greps behind the no-research-skill claims, issue #530, the spec-kit, gsd-core, BMAD and AI-Q files, the installed skill files, the Anthropic, OpenAI, Codex and Claude Code pages, the arXiv papers, PHIA, IPCC, Cochrane, NN/g, Pew, Wikipedia, Wintle, Kelly, AAPOR, ABE and Reuters. It narrowed the snapshot dates, the installed-plugin, installed-skill checking, neutral-question, judge-agreement, OpenAI-budget and spec-kit allowlist claims, removed ICD 203 from the Answer (Access Denied), and moved the `o4-mini` shutdown date to Open questions. Not reached: intel.gov (refused), ICD 206, the NICHD paper, PRISMA, OpenAI's system card, and the gsd-core synthesizer and missing-metadata rules.
