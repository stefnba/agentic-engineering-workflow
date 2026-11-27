---
name: research
description: Use when the user says "research this", "look into", "find out how other repositories do it", "what is the current best practice for", "how do we migrate from X to Y" or "check the docs for", when a Spike needs its evidence, or when a choice depends on outside facts, such as other tools, platform features or published practice, that no note in `docs/research/` holds yet. Also use when a note in `docs/research/` may be out of date. Not for a quick answer the user wants only in chat.
---

# Research

A note in `docs/research/` answers one question: the answer first, then the sourced findings it rests on, each checked against its source by a separate agent.

## Guardrails

**Coordinate; leave reading, writing and checking to fresh subagents.** Your context holds the project's plans and existing notes, and a subagent that gets only its brief is not steered by them. Spawn each one fresh, never as a fork of this conversation. When subagents are unavailable, do each role yourself in the same order and say so in the note's Method section.

**Give subagents the purpose, and keep the preferred answer to yourself.** A researcher needs to know what the answer will be used for to judge what is relevant. It does not need to know which answer you or the user expect.

**Say what the evidence shows, and stop before the project's choice.** The note states facts, what they add up to, and what sources advise, attributed to them. What this project should do goes into a design doc or a decision record, written by the user or by `record-decision`.

**Write only the note in `docs/research/`.** Leave it uncommitted; the user reviews the diff first.

## Kinds of question

| Kind                  | Split into sub-questions by                                 | The answer gives                                                                                                           |
| --------------------- | ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| Comparison of options | Criterion; by option when the criteria are few              | How the options compare on each criterion, how strong the evidence is, and what the choice depends on. It names no winner. |
| Migration or upgrade  | What changed; the documented path; problems others reported | The documented path in order, the known breakages, and what the maintainers advise.                                        |
| Current practice      | Facet of the practice, or group of sources                  | What authoritative sources advise now, where they agree, where they disagree, and the date of each.                        |
| Single fact           | No split                                                    | The fact, with its source and the version or date it holds for.                                                            |

These kinds are examples. For a question that fits none of them, split it into parts that do not overlap, and write in the brief what a complete answer gives.

## Process

### 1. Look for an existing note

**List `docs/research/` and read the front matter of each note whose title touches the question.** When one holds the same question, this run rewrites it, and the writer gets the old note as background.

Done when you know the note's path, new or existing.

### 2. Write the brief

**Write the brief yourself and save it as `brief.md` in a new temporary folder outside the repository:**

```markdown
**Question** — What changes in the configuration format from examplelib 1.9 to examplelib 2.3.1?
**Kind** — Migration or upgrade
**Purpose** — Planning an upgrade of a service that loads plugins through the configuration file
**Constraints** — examplelib 1.9.0 to 2.3.1 (latest stable, released 2026-10-14); configuration file only, plugin APIs out of scope; as of 2026-11-27
**Sub-questions** — 1. Which keys are removed, renamed or added, or is the format unchanged? 2. What upgrade path do the maintainers document, if any? 3. What upgrade problems are reported in issues, if any?
**Answer gives** — The documented path in order, the known breakages, and what the maintainers advise.
**Note** — `docs/research/examplelib-2-configuration.md` (new)
```

**Word the question so it does not lead.** Ask "what is", "how does" or "what changed"; turn "why X beats Y" into "how X and Y compare on <named criteria>"; name every outcome a sub-question covers, including "none" or "unchanged".

**Carry every constraint the user gave into Constraints**, with today's date. Leave open what the user left open.

**When the question concerns a versioned tool, resolve its versions before writing the brief.** Take the project's current version from its manifest or lockfile, and the latest stable release from the release page or package registry. Your memory stops at your training date, so it is not a source for "latest".

**Use one sub-question for a single fact, up to 3 for most questions, and up to 6 when the question covers many independent items.**

**Show the user the brief and wait for their OK before spawning anyone**, also when another skill invoked this one. Nothing later in the run catches a wrong or slanted question. When the user edits the brief, apply the edits to the saved file and show it again.

**Add a last line to the saved brief, `**Confirmed by user** — yes`, once the user has confirmed it.** When no user can answer, write `no` there and go on; the writer carries the line into the note's Method section.

Done when the user has confirmed the saved brief, or the run has noted that nobody could.

### 3. Run the researchers

**Fill `templates/researcher-brief.md` from this skill's folder once per sub-question.** Each filled brief is a subagent's whole prompt and names the file in the temporary folder where that researcher saves its report.

**Spawn every researcher in one message**, so they run in parallel.

**Run one more round only for a sub-question whose researcher found no answer**, with a brief that names what is missing. After that round, go on with what there is.

Done when every sub-question has a report file in the temporary folder.

### 4. Write the note

**Fill `templates/writer-brief.md` and spawn the writer.** It reads the brief and the reports, and writes `docs/research/<slug>.md` from `templates/note.md`.

Done when the note exists at its path.

### 5. Check the note

**Fill `templates/checker-brief.md` and spawn the checker.** It opens the sources the note cites, corrects the note where a source says less or something else, and returns what it changed.

Done when the checker has returned its list of changes.

### 6. Report

**Report in this shape:**

```markdown
- `docs/research/examplelib-2-configuration.md` — new; 3 researchers; checker narrowed 3 claims and moved 2 to Open questions
- Answer: 2.x renames `plugins` to `extensions` and drops `legacy_mode`; the maintainers document a two-step upgrade through 2.0.
- Open: whether the old `plugins` key still loads with a warning
```

Done when the user has the path, the answer in a line or two, what the checker changed and what is still open.
