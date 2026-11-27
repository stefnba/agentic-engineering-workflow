---
name: research
description: Use when the user says "research this", "look into", "find out how other repositories do it", "what is the current best practice for", "how do we migrate from X to Y" or "check the docs for", when a Spike needs its evidence, or when a choice depends on outside facts, such as other tools, platform features or published practice, that no note in `docs/research/` holds yet. Also use when a note in `docs/research/` may be out of date. Not for a quick answer the user wants only in chat.
---

# Research

A note in `docs/research/` answers one neutral question with checked facts, each tagged with how it was established, and proposes nothing.

## Guardrails

**Coordinate; let subagents read the sources.** You know the project's plans and the user's leanings, and that context anchors what you find. A subagent that gets only its brief cannot be anchored by them. When subagents are unavailable, say so and stop.

**Put only the neutral question, the sources and the rules in a brief.** A brief names what to read, never what the project plans, prefers or has decided.

**Write facts and leave the meaning to the user.** The note has no Recommendations section and no sentence saying what a project should do. What a finding means for the project goes into the design doc or a decision record, written by the user or by `record-decision`.

**Write only the note in `docs/research/`.** Leave it uncommitted; the user reviews the diff first.

## Process

### 1. Look for an existing note

**List `docs/research/` and read the opening of each note whose title touches the question.** When one answers the same question, this run updates it: reuse its question, and in the write step change only the claims that changed.

Done when you know the note's path, new or existing.

### 2. Frame the question

**Rewrite the question so it does not lead.**

- Drop a premise the answer would have to confirm: "why X beats Y" becomes "how X and Y compare on speed and setup cost".
- Turn "should we" into "what is" or "how do others": the note describes, the user decides.
- Split a question that asks two things into two sub-questions.
- Replace a charged word with a plain one.
- Name the version the question is about. Without a version from the user, write "latest stable release", not a number: your memory of releases is out of date, and the researchers look it up.

**Pick the level from the question:**

| Level    | Fits                                                              | Researchers | Tool calls each | Rounds                                   | Checking                                       |
| -------- | ----------------------------------------------------------------- | ----------- | --------------- | ---------------------------------------- | ---------------------------------------------- |
| Quick    | One fact or one source, worth keeping as a note                   | 1           | 10              | 1                                        | The researcher reopens the sources the answer depends on |
| Standard | Anything else; the default                                        | Up to 3     | 15              | 1, plus a gap round for an unanswered sub-question | One checker on every sourced claim             |
| Deep     | A migration, a choice that is hard to reverse, sources that disagree | Up to 6  | 15              | 2                                        | One checker, plus one search for contrary evidence |

**Name the sources each researcher should prefer**: official docs, changelogs, specifications, source code, named repositories. Primary sources come before write-ups of them.

**Split the question into sub-questions that do not overlap and together cover it, no more than the level's researchers.** Each sub-question gets one researcher. At the quick level, the question is its own single sub-question.

Done when you have the question, the versions, the sub-questions, the level and the sources.

### 3. Confirm the plan

**Show the user the plan in this shape and wait for their answer:**

```markdown
**Question** — For a reader who wants facts only: what changes in the configuration format from examplelib 1 to examplelib 2?
**Sub-questions** — 1. Keys removed, renamed or added. 2. The upgrade path the maintainers document. 3. Upgrade problems reported in issues.
**Versions** — examplelib 1.x as the user's starting point; examplelib 2 at its latest stable release
**Level** — Standard: 3 researchers, 1 checker
**Sources** — examplelib's changelog and migration guide; issues in its repository
**Note** — `docs/research/examplelib-2-configuration.md` (new)
```

Confirm the plan with the user even when another skill invoked this one, because the framing is where a leaning slips back in.

Done when the user has confirmed the plan or changed it, and you have applied the change.

### 4. Run the researchers

**Fill `templates/researcher-brief.md` from this skill's folder once per sub-question, and delete its comments as you fill.** Each filled brief is a subagent's whole prompt.

**Spawn every researcher at once, each a fresh subagent with no conversation history.** Running them in parallel costs no more than in sequence and finishes sooner.

**At the standard level, spawn one more round only for a sub-question no report answered**, with a brief that names what is still missing. At the deep level, spawn the second round for every gap the first round reports.

Done when every sub-question has a report, or a report that says what could not be found.

### 5. Write the note

**Fill `templates/note.md` from this skill's folder into `docs/research/<slug>.md`, and delete its comments as you fill.** The slug is the title in kebab-case.

**Take every claim from a report, with the tag and source the report gives.** A claim you know but no report backs stays out; it has not been checked.

**When updating a note, keep the claims that still hold, replace the ones that changed, and add a line to Rechecks.**

Done when every claim in the note carries a tag and, unless it is `[inferred]`, a source.

### 6. Check the note

**At the quick level, skip this step**: the researcher has already reopened its sources.

**Fill `templates/checker-brief.md` and spawn the checker as a fresh subagent.** At the deep level, also fill `templates/contrary-brief.md` and spawn that subagent at the same time.

**Apply each verdict:**

| Verdict                                     | Change to the note                                        |
| ------------------------------------------- | --------------------------------------------------------- |
| Not supported                               | Rewrite the claim to what the source says, or drop it      |
| Source unreachable                          | Retag the claim `[unverified]`                             |
| A conclusion tagged as read                 | Retag it `[inferred]`                                      |
| A sentence that recommends                  | Rewrite it as a fact, or drop it                           |
| Contrary evidence found                     | Add it beside the claim, attributed, without picking a side |

Done when every verdict is applied, and the method paragraph says what was checked.

### 7. Report

**Report in this shape:**

```markdown
- `docs/research/examplelib-2-configuration.md` — new; standard: 3 researchers, 1 checker; 2 claims rewritten, 1 retagged `[unverified]`
- Not settled: whether the old `plugins` key still loads with a warning
```

Done when the user has the path, the level and what is not settled.
