---
name: research
description: Use when the user says "research this", "look into", "find out how other repositories do it", "what is the current best practice for", "how do we migrate from X to Y" or "check the docs for", when a Spike needs its evidence, or when a choice depends on outside facts, such as other tools, platform features or published practice, that no report in `docs/research/` holds yet. Also use when a report in `docs/research/` may be out of date. Not for a quick answer the user wants only in chat.
---

# Research

A report in `docs/research/` answers one question: the answer first, then the sourced findings it rests on, each checked against its source by a separate agent.

## Guardrails

**Coordinate; leave reading, writing and checking to fresh subagents.** Your context holds the project's plans and existing reports, and a subagent that gets only its brief is not steered by them. Spawn each one fresh, never as a fork of this conversation. When subagents are unavailable, do each role yourself in the same order and say so in the report's Method section.

**Give subagents the purpose, and keep the preferred answer to yourself.** A researcher needs to know what the answer will be used for to judge what is relevant. It does not need to know which answer you or the user expect.

**Say what the evidence shows, and stop before the project's choice.** The report states facts, what they add up to, and what sources advise, attributed to them. What this project should do goes into a design doc or a decision record, written by the user or by `record-decision`.

**Leave only the report behind, in `docs/research/`.** Delete the working folder at hand-over, and leave the report uncommitted; the user reviews the diff first.

## Kinds of question

| Kind                  | Split into sub-questions by                                 | The answer gives                                                                                                           |
| --------------------- | ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| Comparison of options | Criterion; by option when the criteria are few              | How the options compare on each criterion, how strong the evidence is, and what the choice depends on. It names no winner. |
| Migration or upgrade  | What changed; the documented path; problems others reported | The documented path in order, the known breakages, and what the maintainers advise.                                        |
| Current practice      | Facet of the practice, or group of sources                  | What authoritative sources advise now, where they agree, where they disagree, and the date of each.                        |
| Single fact           | No split                                                    | The fact, with its source and the version or date it holds for.                                                            |

These kinds are examples. For a question that fits none of them, split it into parts that do not overlap, and write in the brief what a complete answer gives.

## Process

### 1. Look for an existing report

**List `docs/research/` and read the front matter of each report whose title touches the question.** When one holds the same question, this run rewrites it under its existing file name, and the writer gets the old report as background.

**Name a new report `NNNN-slug.md`, with the next number after the highest one among the files directly in `docs/research/`.** Subfolders do not count. The first report is `0001`, and the slug is the subject in kebab-case. The number keeps the reports in the order they were created; a report keeps its number when it is rewritten.

Done when you know the report's path, new or existing.

### 2. Write the brief

**Write the brief yourself and save it as `brief.md` in a new working folder, `docs/research/.work/<slug>/`:**

```markdown
- **Question:** What changes in the configuration format from examplelib 1.9 to examplelib 2.3.1?
- **Kind:** Migration or upgrade
- **Purpose:** Planning an upgrade of a service that loads plugins through the configuration file
- **Constraints:**
  - examplelib 1.9.0 (lockfile) to 2.3.1 (registry `latest`, released 2026-10-14)
  - The configuration file only; plugin APIs are out of scope
  - As of 2026-11-27
- **Sub-questions:**
  1. Which keys are removed, renamed or added, or is the format unchanged?
  2. What upgrade path do the maintainers document, if any?
  3. What upgrade problems are reported in issues, if any?
- **Live checks:** none
- **Answer gives:** The documented path in order, the known breakages, and what the maintainers advise.
- **Narrower than asked:**
  - Covers the `latest` channel; the `stable` channel is at 2.2.4
- **Report:** `docs/research/0007-examplelib-2-configuration.md` (new)
```

**Keep every working file of the run in that folder.** A folder outside the repository may refuse a subagent's writes.

**Word the question so it does not lead.** Ask "what is", "how does" or "what changed"; turn "why X beats Y" into "how X and Y compare on <named criteria>"; name every outcome a sub-question covers, including "none" or "unchanged".

**Carry every constraint the user gave into Constraints**, with today's date. Leave open what the user left open.

**When the question concerns a versioned tool, resolve its versions before writing the brief.** Take the project's current version from its manifest or lockfile when it has one, and the latest release from the release page or package registry. Your memory stops at your training date, so it is not a source for "latest".

**Name beside each version where you took it from**, such as "lockfile" or "registry `latest`". Take the registry's default channel, such as npm `latest`, and list any other channel or newer pre-release under "Narrower than asked".

**Look up what each named product is today before you scope it.** One name can cover several forms, such as a CLI, a desktop app, an IDE extension and a cloud service, and forms appear after your training date. Find the current forms on the vendor's site, and cover every form the user's words cover.

**Give reported problems their own sub-question when the question is about how a tool behaves.** A researcher who also reads docs or code spends its tool calls there, and the issue reports go unfound.

**Name a target under "Live checks" when a command that only reads could settle a claim**, such as "`owner/repo` on GitHub, read-only", and write "none" otherwise. A doc can say a feature exists while the user's account does not have it, and one read shows which. The user approves the target with the brief. A researcher runs these commands with the user's credentials after reading pages it cannot trust, so the token's scope and the session's permission mode are the limit that holds, not the brief's wording.

**Use one sub-question for a single fact, up to 3 for most questions, and up to 6 when the question covers many independent items.**

**List under "Narrower than asked" every place where the brief is narrower than the user's words**, such as one form of a product, one release channel or one platform, each as a choice the user can widen. Write "nothing" when there is none.

**Show the user the brief and wait for their OK before spawning anyone**, also when another skill invoked this one. Nothing later in the run catches a wrong or slanted question. When the user edits the brief, apply the edits to the saved file and show it again.

**Add a last item to the saved brief, `- **Confirmed by user:** yes`, once the user has confirmed it.** When no user can answer, write `no` there and go on; the writer carries the line into the report's Method section.

Done when the user has confirmed the saved brief, or the run has noted that nobody could.

### 3. Run the researchers

**Fill `templates/researcher-brief.md` from this skill's folder once per sub-question.** Each filled brief is a subagent's whole prompt and names the file in the working folder where that researcher saves its notes.

**Spawn every researcher in one message**, so they run in parallel.

**When a researcher returns its notes as its message because the write was refused, save that message to its notes file word for word.**

**Read the Follow-ups section of each notes file, and leave the rest to the writer.** It lists what the question covers but no sub-question did, and the parts a researcher did not reach.

**Run one second round for the follow-ups, with at most three researchers spawned in one message.** A follow-up gets a researcher when the confirmed question's own words cover it and its entry names a source, or when it is a part of a confirmed sub-question left unanswered. When more qualify than there are researchers, take first the ones more researchers reported. You know which answer the project hopes for, so decide by these tests and not by which follow-up looks useful.

**Append each follow-up you research to the saved brief as a sub-question ending in "(added after confirmation)".** The writer then gives it a section like any other.

**Run no third round.** What the second round leaves open goes to the writer as it is.

Done when every sub-question, including the added ones, has a notes file in the working folder.

### 4. Write the report

**Fill `templates/writer-brief.md` and spawn the writer.** It reads the brief and the researchers' notes, and writes the report at the path the brief names, from `templates/report.md`.

Done when the report exists at its path.

### 5. Check the report

**Fill `templates/checker-brief.md` and spawn the checker.** It opens the sources the report cites, corrects the report where a source says less or something else, and returns what it changed.

Done when the checker has returned its list of changes.

### 6. Hand over

**Delete the run's working folder, and `docs/research/.work/` when that leaves it empty.**

**Tell the user the result in this shape:**

```markdown
- `docs/research/0007-examplelib-2-configuration.md` — new; 3 researchers; checker narrowed 3 claims and moved 2 to Open questions
- Answer: 2.x renames `plugins` to `extensions` and drops `legacy_mode`; the maintainers document a two-step upgrade through 2.0.
- Open: whether the old `plugins` key still loads with a warning
- Follow-ups: researched the new `extensions.order` key; not researched: plugin API changes, outside the question
```

Done when the working folder is gone and the user has the path, the answer in a line or two, what the checker changed, what is still open, and every follow-up with whether it was researched.
