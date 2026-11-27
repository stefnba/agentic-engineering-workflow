# How the reference repositories interview the user, and what `interview-user` should take

Our draft is closest to Pocock's `grilling` and to our own v1 `interview-me`. Like them, it asks numbered rounds of decisions whose prerequisites are settled, each with a recommended answer. It goes further than any source in two ways: it marks every answer Decided, Assumed or Open, and it ends in a fixed summary the user confirms `[inferred]`. The largest gaps the sources expose in our draft `[inferred]`:

- one "yes" can accept a whole round
- an unanswered question has no stated fate
- a question need not say why it matters
- nothing lets the user stop early

Sources and method: shallow clones at HEAD of the seven repositories, read on 2026-11-26, plus v1 read with `git show v1-final:<path>`. One research sub-agent per source, each in a fresh context window, reported with cites; I merged the reports and re-checked a sample of quotes and every cited issue title with `grep` and `gh`. Nothing from the clones was executed. Paths are relative to each repository. `[read]` marks a claim seen in a file or issue by one of those agents. `[inferred]` marks a conclusion. Our draft is `skills/interview-user/SKILL.md` as of commit `dc7c8cb`.

## Per-source findings

### obra/superpowers, `brainstorming`

Commit `22f0b46`. Paths under `skills/brainstorming/`.

- **Closest skill.** `SKILL.md`, a questioning conversation that ends in a design doc; `builder-check-prompt.md` is a fresh-agent prompt that finds what is still open `[read]`.
- **Phrasing.** Front matter holds only `name` and `description`; the description says "You MUST use this before any creative work" and names no trigger phrases `[read: SKILL.md:1-4]`. Prose sections, a hard gate on building before approval, and a "Red Flags" table of rationalizations `[read: SKILL.md:269-294]`.
- **One question per message.** "Ask one at a time"; the only batch is the builder-check pile, "most important first" `[read: SKILL.md:106, 263]`.
- **Ask only what changes the outcome.** A question is asked only if "the answer would change what gets built" and nothing already answers it `[read: SKILL.md:101-102]`.
- **No options before the why.** "Options steer", so the first questions are open; later ones sketch trade-offs and say which the agent would pick `[read: SKILL.md:114-118]`.
- **Facts first.** It reads code until it can explain how the relevant parts work today `[read: SKILL.md:44-50]`.
- **Ownership of answers.** "Only what they said goes in as theirs"; the agent's fill-ins go in as its own proposal `[read: SKILL.md:128-129, 198-199]`. "A default they never heard is one they couldn't reject" `[read: SKILL.md:290]`.
- **Three-pile triage.** Builder questions are sorted into answered already, minor (settle it and mark it as your call), and the user's `[read: SKILL.md:254-262]`.
- **Builder check template.** Fill-ins `[DOMAIN]` and `[DOCUMENT_PATH]`; returns only questions "where a wrong guess would matter", ranked, or "nothing important left" `[read: builder-check-prompt.md:7-22]`.
- **Ending.** Play-back chunks of 200 to 300 words ask what is wrong or missing; the design doc is written to `docs/superpowers/specs/` and committed `[read: SKILL.md:192-200, 245-248]`.
- **Opt-out.** When the partner would rather proceed, the skill ends `[read: SKILL.md:88-95]`.
- **Leaves out.** A dependency map, a per-answer status, an open state, and any ending without a file `[inferred]`.

### mattpocock/skills, `grilling`, `grill-me`, `grill-with-docs`

Commit `6f7f783`.

- **Closest skill.** `skills/productivity/grilling/SKILL.md` is the loop. `grill-me` is a wrapper that says "Call the Skill tool with "grilling"" `[read: skills/productivity/grill-me/SKILL.md:4-7]`. `grill-with-docs` adds `domain-modeling` and writes the glossary and decision records during the session `[read: docs/engineering/grill-with-docs.md:5]`.
- **Description.** "Grill the user relentlessly about a plan, decision, or idea", with "grill" chosen as a word the model already knows `[read: grilling/SKILL.md:3; CHANGELOG.md:273]`.
- **Rounds.** The frontier is every decision whose prerequisites are settled; the whole frontier goes in one round, numbered, with no cap `[read: grilling/SKILL.md:8, 26]`. It was one question at a time until release 1.2 `[read: CHANGELOG.md:230]`.
- **No total cap.** A limit was rejected after a "200 questions" complaint `[read: .out-of-scope/question-limits.md:3-18]`.
- **Recommendations.** Every question gets one, worded so "yes" accepts it, with no exception for open questions `[read: grilling/SKILL.md:12-24; CHANGELOG.md:19]`.
- **Facts.** A sub-agent "with a fresh context window" looks facts up without blocking the round; only downstream questions wait `[read: grilling/SKILL.md:28]`.
- **Stop.** The frontier is empty, "nothing left silently assumed", and the user confirms before anything is acted on `[read: grilling/SKILL.md:30]`.
- **Plain-text questions.** Native question tools are out of scope: each harness has its own, and pickers push toward canned choices `[read: .out-of-scope/native-question-tool.md:3-11]`.
- **Reported failures,** all `[read]` from issue titles:
  - A single yes accepts several independent decisions (#1475).
  - Yes-wording steers rounds toward yes-only questions (#1424).
  - A partly answered round counts as finished, and unanswered questions come back renumbered (#1406).
  - A confirmation that brings new facts ends the session (#1402).
  - An empty frontier lets unverified facts count as done (#1464).
  - A round asked while a lookup runs gets rewritten when it reports (#1245); sub-agents confuse the main agent (#802).
- **Leaves out.** A summary format, which the docs call "often open-ended", and a record of decisions too small for a decision record `[read: docs/engineering/grill-with-docs.md:55, 61]`.

### google/elephant-goldfish-model, `egm-brainstorm`

Commit `4693375`. EGM has no interview skill; the nearest is step 1 of `skills/egm-brainstorm/SKILL.md` `[read: :104-158]`.

- **Phrasing.** Front matter adds `license` and `disable-model-invocation: true`; the body opens with a 13-item constraint list in MUST and STRICTLY FORBIDDEN style, much of it about tone ("No Glazing") `[read: :1-11, 38-88]`. It names harness tools and `${CLAUDE_PLUGIN_ROOT}` `[read: :15-16, 30, 51]`.
- **One question, always.** The shared rule forbids "more than one question" per response `[read: resources/execution_instructions.md:115-119]`.
- **No recommendations.** Options come without a recommended marker `[read: egm-brainstorm/SKILL.md:87]`. When the author says "just pick one", `egm-draft` restates the trade-offs and asks again `[read: skills/egm-draft/SKILL.md:63-71]`.
- **Contradictions.** `egm-draft` quotes the earlier decision beside the new one and asks the user to choose `[read: skills/egm-draft/SKILL.md:262-274]`.
- **Uncertainty tags.** `egm-lite` marks unchecked contracts `[⚠️ UNVERIFIED]` and accepted assumptions with a scheduled test `[⏳ ACK]` `[read: skills/egm-lite/SKILL.md:114-117, 166-171]`.
- **Seed probes.** Problem, consumer, hard constraints, edge cases, today's workaround, success measure `[read: egm-brainstorm/SKILL.md:118-125]`.
- **Ending.** A two-to-three-sentence working hypothesis and a gate; summaries go to a file, never chat `[read: :40-45, 127-158]`.
- **Leaves out.** Batching, ordering, fact lookup before asking in brainstorm, and any decided or open marking `[inferred]`.

### github/spec-kit, `clarify`

Commit `f201054`. Paths under `templates/`.

- **Closest skill.** `commands/clarify.md`; `commands/specify.md` also embeds `[NEEDS CLARIFICATION: …]` markers and asks them in one batch `[read: specify.md:125-133, 203-236; spec-template.md:96-99]`.
- **Phrasing.** A slash command whose description promises "up to 5 highly targeted clarification questions"; nine numbered steps, capitalized rules such as "Present EXACTLY ONE question at a time" `[read: clarify.md:2, 141]`.
- **Taxonomy.** Eleven categories, each marked Clear, Partial or Missing in an internal coverage map `[read: clarify.md:73-123]`.
- **Ranking.** "(Impact * Uncertainty)", and ask only where the answer materially changes the work `[read: clarify.md:134-138]`.
- **Question format.** A real question, one "Why it matters" sentence, `**Recommended:** Option [X]`, an options table of two to five rows, and a reply line accepting a letter, "yes" or free text `[read: clarify.md:143-165]`. The "real interrogative" rule came from #3745 `[read]`.
- **Cap and stop.** Five per session; it stops on that cap, when critical ambiguities are resolved, or when the user says "stop", "done" or "proceed"; retries do not count `[read: clarify.md:175-178, 233-237]`.
- **Writing.** After each accepted answer it appends `- Q: … → A: …` under `## Clarifications` and edits the matching section in place `[read: clarify.md:182-198]`.
- **Report statuses.** Resolved, Deferred, Clear, Outstanding `[read: clarify.md:282]`; #4507 narrowed Deferred after agents deferred whole areas `[read]`.
- **Leaves out.** Dependencies between questions, a split between settled and assumed answers, and fact lookup: recommendations draw on "best practices" `[read: clarify.md:150-153]`.

### Fission-AI/OpenSpec, `explore` and `propose`

Commit `f1cd852`.

- **Closest skill.** "Planning a Change" in `skills/openspec-explore/SKILL.md` `[read: :44-64]`, generated from `src/core/templates/workflows/explore.ts` and guarded by a test for issue #1017 `[read: test/core/templates/explore.test.ts:74-114]`.
- **Phrasing.** "a stance, not a workflow" with "no fixed steps"; Don't and Do guardrails such as "Don't fake understanding" `[read: :16, 348]`. Front matter adds `allowed-tools`, `license`, `compatibility`, `metadata` `[read: :4-9]`.
- **One question by default.** "Ask one focused question at a time", saying why it matters and which decision it unlocks; small grouped batches only on request `[read: :51]`.
- **Order.** Resolve the next blocking decision first, and revisit what was assumed after an earlier answer changes `[read: :50]`.
- **Recommendations.** Only "When evidence supports" one, with reasons and alternatives; "Avoid a fixed question format" `[read: :52]`.
- **Facts.** Check artifacts, source, tests, docs and config before a factual question, and say where evidence is missing `[read: :48]`.
- **Recording.** Decisions stay in the conversation; confirmed ones are kept apart from proposed defaults and unresolved questions. "Silence is not acceptance", and accepting answers is not permission to write `[read: :53]`.
- **Stop.** When the user has enough clarity; the user may pause or defer, and the agent need not exhaust every branch `[read: :55]`.
- **Ending.** An optional summary under Problem, Approach, Open questions, Next steps, with no confirmation step `[read: :325-341]`.

### open-gsd/gsd-core, `new-project` questioning and `discuss-phase`

Branch `next`, commit `26429a6`.

- **Closest skill.** `skills/gsd-discuss-phase/SKILL.md`, routing to `gsd-core/workflows/discuss-phase.md` or its assumptions variant `[read: SKILL.md:58-66]`; intake questioning is `gsd-core/references/questioning.md` `[read]`.
- **Phrasing.** XML-tagged sections, "thinking partner, not an interviewer", and a list of what the user "shouldn't be asked": codebase patterns, risks, approach, metrics `[read: discuss-phase.md:8-112, 57; questioning.md:7]`. Front matter lists `AskUserQuestion` and `Agent` under `allowed-tools` `[read: SKILL.md:4-14]`.
- **Gray areas.** The agent finds phase-specific decisions that "could go multiple ways", bans generic labels, and lets the user pick areas `[read: discuss-phase.md:82-98, 348-358]`.
- **Cadence.** Four single-question turns per area by default; `--batch` asks two to five in one turn; `--text` is the plain-text fallback `[read: workflows/discuss-phase/modes/default.md:39-71; batch.md:11-21; text.md:9-51]`.
- **Options.** Two or three concrete options with the recommended one highlighted, plus "You decide" `[read: modes/default.md:52-60, 95]`.
- **Assumptions mode.** "Read the codebase FIRST, form opinions SECOND", aiming for a few corrections instead of many questions `[read: discuss-phase-assumptions.md:25-35]`. Each assumption carries evidence paths, an "If wrong" consequence and a confidence of Confident, Likely or Unclear `[read: agents/gsd-assumptions-analyzer.md:65-93]`.
- **Fuzzy answers.** "Never accept fuzzy answers" `[read: questioning.md:35]`.
- **CONTEXT.md template.** Numbered decisions D-01 with rationale and an optional reversibility of reversible, costly or one-way; "Claude's Discretion"; and a Deferred Ideas list for out-of-scope ideas `[read: workflows/discuss-phase/templates/context.md:58-80, 133-146]`.
- **Ending.** The user says they are ready; the agent writes and commits CONTEXT.md and a discussion log, and confirms after writing `[read: modes/default.md:74-84; discuss-phase.md:385-456]`.
- **Codex cost.** A fix stopped Codex from silently picking defaults when the question tool was missing `[read: .changeset/archived/codex-discuss-fallback.md]`.

### bmad-code-org/BMAD-METHOD, `bmad-facilitate`, `bmad-brainstorming`, `bmad-advanced-elicitation`

Commit `e435a22`. Paths under `skills/core-tools/`.

- **Closest skill.** `bmad-facilitate/SKILL.md`, the document-coaching engine the PM agent uses `[read: skills/method/bmad-agent-pm/SKILL.md:22]`. Brainstorming generates ideas and elicitation critiques drafts; neither settles decisions `[inferred]`.
- **Cadence.** Coaching asks one question at a time and "No message asks more than two things"; fast mode asks one batch of missing inputs plus up to three high-impact questions `[read: bmad-facilitate/SKILL.md:52-54]`.
- **Opening.** Invite a brain dump first and hold specific questions until the broad shape is out `[read: :48]`.
- **Recommendations.** "open questions for vision and discovery, options with a recommendation only between named alternatives" `[read: :58]`.
- **Facts.** "Ask only what only the user knows"; research sub-agents find the rest `[read: :56]`.
- **Group yes.** "a yes to a group … accepts nothing", so the agent says which items stay open `[read: :70]`.
- **Pushback and stop.** Push hardest on unexamined assumptions; stop when the remaining questions would not change the document `[read: :58]`.
- **Contradictions first.** A conflict between inputs, or with what the user says, goes to the user before anything else `[read: :56]`.
- **Handback.** Name "the three decisions you are least confident about, then wait" `[read: :90]`.
- **Machinery.** `uv run` resolvers, `{workflow.*}` customization, a memlog file, and CSV method catalogs served by scripts `[read: :14-20; bmad-brainstorming/assets/brain-methods.csv:1]`.
- **Description.** Elicitation adds a "Not for" exclusion `[read: bmad-advanced-elicitation/SKILL.md:3]`.

### Our v1, `interview-me` and `shape-bundle`

Tag `v1-final`. Cites are `v1-final:<path>:<lines>`.

- **Split.** `interview-me` covered problem, constraints and motivation and wrote nothing; `shape-bundle` clarified the draft's holes "as one batch" `[read: skills/interview-me/SKILL.md:14-15, 27-28; skills/shape-bundle/SKILL.md:100-107]`.
- **Front matter.** `argument-hint`, `disable-model-invocation: true` and `allowed-tools: Read, Grep, Glob`; the tool grant enforced "This writes nothing" `[read: interview-me/SKILL.md:4-6, 14]`.
- **Rounds.** The whole frontier per round, no cap, no ranking; every question got a recommendation in a `❓ **Q1**` / `➡️` format `[read: interview-me/SKILL.md:32-39]`.
- **Facts.** "yours to find"; a lookup does not block the round, the answer folds in later `[read: interview-me/SKILL.md:44-46]`. `shape-bundle` added "cite the file" `[read: shape-bundle/SKILL.md:38]`.
- **Terms.** A term that conflicts with the glossary is called out with both readings `[read: interview-me/SKILL.md:48-50]`.
- **Exits.** "Too small to interview" offers a backlog line; unknown feasibility routes to a spike `[read: interview-me/SKILL.md:58-63]`.
- **Ending.** The frontier is empty and the human confirms, with no summary shape `[read: interview-me/SKILL.md:54]`.
- **History.** Commit `7e3a6ce` cut the skill and dropped "Grill, don't transcribe", whose example asked what breaks without the Redis cache a user proposes; its message gives no reason `[read: git show 7e3a6ce]`.

## Comparison

| Source | Questions per message | Order | Recommendation | Facts | Answer states | Writes files | Ends with |
| --- | --- | --- | --- | --- | --- | --- | --- |
| superpowers | One | Biggest effect first | After the why is known | Looked up first | Theirs; agent's call | Design doc, committed | Approved doc |
| mattpocock `grilling` | Whole frontier, no cap | Dependency frontier | Every question; yes accepts | Fresh context, non-blocking | None | None (`grill-with-docs` does) | Empty frontier, user confirms |
| EGM `egm-brainstorm` | One | None | Forbidden | Not required in brainstorm | Tags in `egm-lite` only | Brief file | Readiness gate |
| spec-kit `clarify` | One; five per session | Impact × uncertainty | Always; yes accepts | "Best practices" | Resolved, Deferred, Clear, Outstanding | Spec, after each answer | Coverage report |
| OpenSpec `explore` | One; batch on request | Next blocking decision | When evidence supports | Checked first | Confirmed; proposed default; unresolved | Only after a separate yes | Optional summary |
| gsd-core `discuss-phase` | Four per area; batch two to five | User picks gray areas | Highlighted option | Light scout; assumptions mode | Decision; discretion; deferred | CONTEXT.md, committed | Confirm after writing |
| BMAD `bmad-facilitate` | One; at most two things | Effect on the document | Only between named alternatives | Research sub-agents | Fact, decision, assumption (memlog) | Document as answers land | Three least-confident decisions |
| v1 `interview-me` | Whole frontier, no cap | Dependency frontier | Every question | Non-blocking lookup | None | None | Human confirms |
| Our draft | Up to seven | Dependency, then most unblocked | Choices only; yes accepts | Before the round, fresh context | Decided, Assumed, Open | None | Confirmed summary |

Six of the eight sources default to one question per message (counted from the table's first column) `[inferred]`. Only Pocock and v1 batch by design, and Pocock moved to batching from one-at-a-time `[read: CHANGELOG.md:230]`.

## Recommendations for our skill

Each item names the change, the reason and the source. All fit our constraints: plain prose, no tool names, no files, front matter untouched `[inferred]`.

### Adopt

**Let one "yes" accept one decision.**
- Reason: a round of seven recommended answers invites a bare "yes" the user did not weigh item by item. Ask for answers by question number, and treat a group "yes" as accepting nothing until the user names the items.
- Source: BMAD `bmad-facilitate/SKILL.md:70`; mattpocock #1475.

**Keep an unanswered question Open, with its number.**
- Reason: our draft says how to mark answers, not silence. A partly answered round is not finished; the unanswered questions return in the next round under the same number.
- Source: OpenSpec `openspec-explore/SKILL.md:53`; mattpocock #1406.

**Require each question to say why it matters.**
- Reason: our example has a stake sentence, but the rule does not demand one. Spec-kit added the rule after agents asked bare topic labels, and the same fix keeps questions readable without earlier context.
- Source: spec-kit `clarify.md:143-146`, #3745; OpenSpec `:51`; superpowers `SKILL.md:79-80`.

**Name the alternatives a recommendation rejects.**
- Reason: yes-wording alone steers toward yes-only questions and hides the real choice. One line of rejected options keeps the choice visible and the "yes" cheap.
- Source: mattpocock #1424; OpenSpec `:52`; spec-kit options table `clarify.md:156-163`.

**Ask only when the answer changes the outcome, and settle minor calls yourself as Assumed.**
- Reason: this sharpens step 1, which today lists every decision the topic needs. Superpowers' "minor" pile is a call a sensible builder could make without changing the result, and saying it aloud keeps it rejectable.
- Source: superpowers `SKILL.md:101-102, 254-262, 290`; spec-kit `clarify.md:134`; BMAD `:58`.

**Let the user stop early.**
- Reason: our only stop is "no decision askable". When the user says "done" or "enough", every unasked decision goes to Open with its reason, and the summary follows.
- Source: spec-kit `clarify.md:235-237`; OpenSpec `:55`.

**Re-map when an answer changes an earlier one or brings new facts.**
- Reason: "recompute which decisions are now askable" covers new decisions, not ones already marked. A correction to the goal, or new facts in the confirmation, reopens the affected marks before handback.
- Source: OpenSpec `:50`; mattpocock #1402.

**Never mark Decided on an unverified fact, and cite where each fact came from.**
- Reason: a decision resting on a fact the lookup could not confirm is Open, naming the missing fact. A file cite beside a looked-up fact lets the user check an Assumed line.
- Source: mattpocock #1464; OpenSpec `:48`; v1 `shape-bundle/SKILL.md:38`; GSD `gsd-assumptions-analyzer.md:65-93`.

### Consider

**Restate the trade-offs once when the user says "you choose".**
- Reason: the draft records it as Assumed at once. One restatement may turn it into a real decision; EGM refuses to pick at all, which is stronger than we need.
- Source: EGM `skills/egm-draft/SKILL.md:63-71`.

**Ask a contradiction first, as its own question.**
- Reason: an answer that conflicts with the repository or an earlier answer blocks everything built on it. Quote both sides.
- Source: EGM `egm-draft/SKILL.md:262-274`; BMAD `:56`.

**Push back once on a vague answer, and ask for the problem behind a proposed solution.**
- Reason: "stress-test this" is a trigger, yet the draft has no challenge step. A vague answer stays Open instead of becoming Decided. Cost: one line, and a longer interview.
- Source: GSD `questioning.md:35`; BMAD `:58`; v1 `interview-me/SKILL.md:21-22`.

**Add an out-of-scope list to the summary, or mark such points Open with "out of scope".**
- Reason: ideas outside the topic have no home in the draft's summary and either get lost or creep into scope.
- Source: GSD `templates/context.md:133-146`.

**Name the least-confident Assumed points at handback.**
- Reason: it focuses the user's confirmation on the lines most likely to be wrong, at the cost of one sentence.
- Source: BMAD `:90`.

**Run a fresh-context check on the summary before handback.**
- Reason: a reader with only the summary finds the gaps the interviewer stopped seeing, ranked, or reports none. Cost: one more round.
- Source: superpowers `builder-check-prompt.md:14-22`.

**Seed the decision map from a short generic checklist.**
- Reason: a map built only from what the user mentions misses whole areas. Candidates: problem, who it is for, constraints, success measure, what exists today. Keep it topic-neutral; spec-kit's taxonomy is slanted to software specs.
- Source: EGM `egm-brainstorm/SKILL.md:118-125`; GSD `questioning.md:120-145`; spec-kit `clarify.md:73-123`.

**Offer an assumptions-first round when the repository answers most points.**
- Reason: presenting evidence-backed assumptions for correction can replace many questions. Each still stays Assumed until the user confirms it item by item, as the first Adopt item requires.
- Source: GSD `discuss-phase-assumptions.md:25-35`.

**Flag a fuzzy or conflicting term for `update-glossary` in the summary.**
- Reason: v1 caught term conflicts during the interview; v2 has a glossary skill but this skill writes nothing, so the caller gets the term list.
- Source: v1 `interview-me/SKILL.md:48-50`; mattpocock `domain-modeling/SKILL.md:44-74`.

**Say so and stop when the topic is too small, or is really an investigation.**
- Reason: v1 had both exits; v2 has no backlog or spike route yet, so the generic form is to tell the caller.
- Source: v1 `interview-me/SKILL.md:58-63`.

**Add a "Not for" clause and an opt-out line.**
- Reason: the description fires even when the user did not ask. A "Not for" clause separates it from brainstorming, and an opt-out line in the first round lets the user skip.
- Source: BMAD `bmad-advanced-elicitation/SKILL.md:3`; superpowers `SKILL.md:88-95`.

### Avoid

**One question per message as the default.**
- Reason: it multiplies round trips, and our dependency-ordered rounds already hold back questions that depend on open answers. Pocock left it for batching and keeps it only as a user opt-in.
- Source: superpowers, EGM, spec-kit, OpenSpec, GSD and BMAD defaults; mattpocock `CHANGELOG.md:230`, `docs/productivity/grilling.md:45-52`.

**Sending a round while lookups still run.**
- Reason: v1 and Pocock do this; Pocock's issues report rounds rewritten when the lookup returns and sub-agents confusing the main agent. Our draft looks facts up before the round, which avoids both.
- Source: mattpocock #1245, #802; v1 `interview-me/SKILL.md:44-46`.

**A total question cap.**
- Reason: spec-kit's five per session drops lower-ranked decisions silently. Pocock rejected a total cap; our per-round cap with more rounds keeps rounds readable without dropping decisions.
- Source: spec-kit `clarify.md:130`; mattpocock `.out-of-scope/question-limits.md:3-18`.

**Writing files during the interview.**
- Reason: it breaks our no-write guardrail, and Pocock reports inline writes silently skipped under orchestrators.
- Source: spec-kit `clarify.md:182-198`; GSD `discuss-phase.md:385-470`; BMAD `:52`; mattpocock `docs/engineering/grill-with-docs.md:49`.

**Harness question tools, tool grants, hooks and extra front matter keys.**
- Reason: none work under both harnesses. GSD needed a fix for Codex silently picking defaults, and v1 enforced "writes nothing" through a Claude-only tool grant.
- Source: GSD `.changeset/archived/codex-discuss-fallback.md`; EGM `egm-brainstorm/SKILL.md:1-11`; v1 `interview-me/SKILL.md:4-6`.

**Wrappers that call another skill by name.**
- Reason: Pocock's docs report named skills failing to load, and the wrapper depends on "the Skill tool".
- Source: mattpocock `docs/productivity/grilling.md:72-73`, `grill-me/SKILL.md:4-7`.

**Recommending with no grounding, or never recommending.**
- Reason: spec-kit recommends from "best practices" when the repository is silent, which is the guess our open-question rule forbids. EGM forbids recommendations, which costs the cheap "yes".
- Source: spec-kit `clarify.md:150-153`; EGM `egm-brainstorm/SKILL.md:87`.

**Folding "you decide" into an accepted answer or an untracked bucket.**
- Reason: spec-kit treats it as an accepted recommendation and GSD as discretion with no cost. Our Assumed mark with its cost is stronger.
- Source: spec-kit `clarify.md:171` `[inferred]`; GSD `templates/context.md:79-80`.

**Capitalized MUST rules, banned-word lists and personas.**
- Reason: they add length about tone, not procedure. Spec-kit's maintainers keep patching behaviour with more such rules.
- Source: EGM `egm-brainstorm/SKILL.md:38-88`; spec-kit #1557, #3745, #4507 `[inferred]`; superpowers `SKILL.md:8-11`.
