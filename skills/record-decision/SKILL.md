---
name: record-decision
description: Use when the user says "record this decision", "write an ADR", "accept D-0003" or "supersede D-0003", when another skill hands over a settled or candidate decision to record, or when a choice just settled is hard to reverse, affects more than one feature, would surprise a reader of the code, and had a real alternative. Not for routine implementation choices.
---

# Record a decision

A decision that meets the bar is a numbered record in `docs/decisions/`, with a status that says whether the user accepted it.

## Guardrails

**Write only files in `docs/decisions/`.** A record with no commit yet is a draft; revise it in place on the user's feedback. In a committed record, change only its front matter: `status` to Accepted when the user accepts it, or the superseding fields below.

**Mark a record Accepted only when the user accepted, in this conversation, the choice as its Decision section states it.** Agents propose decisions; the user accepts them. A decision found in code, suggested by an agent, or stated more broadly than the user saw is Proposed.

**Write only the alternatives, reasons and facts that the user or a source gave, each with its source.** An invented alternative fabricates a debate that never happened, and an invented reason is later read as the team's.

**Leave every change uncommitted.** The user reviews the diff first.

## Process

### 1. Test the decision against the bar

**Record it only when all four hold:** it is hard to reverse, it affects more than one feature, a reader of the code would wonder why, and a real alternative existed. Most choices fail, and declining is the usual outcome: a record nobody needs buries the ones that matter.

**Choices that tend to pass:** lock-in technology, such as a database or an auth provider; boundaries between parts and who owns which data; a deliberate deviation from the obvious path; a constraint the code cannot show, such as a compliance rule or a partner contract.

**Ask the user, in one message, for what neither the user nor a source has given yet:** the alternatives and what sank each, what the decision costs, and what would reopen it. With no alternative, the choice was the default and fails the bar. With no cost, the trade-off has not been found; say in Consequences that none was named.

**When the bar fails, name the test that failed and where the choice belongs instead, and stop:** the doc it shapes, such as `docs/ARCHITECTURE.md`, or a code comment beside the code it explains.

**When the user questions a record that passed, answer with the test each part of the bar passes.** Drop it only when the user's answer makes a test fail.

**When the user rejected the decision, write no record.** Report it as rejected, so the caller can list it.

Done when the decision passes the bar, or the user has the test it fails.

### 2. Number the record

**When the user accepts an existing Proposed record, set its `status` to Accepted and go to the report.**

**List `docs/decisions/` and take the next number after the highest one.** The first record is `0001`. A missing folder means no records yet; create it.

**Read each record whose title touches the same topic.** When the new decision replaces or narrows one, even in part, the new record supersedes all of it.

**Before superseding an Accepted record, quote its Decision to the user and ask whether the new decision replaces it.** When the user says no, report the conflict and write nothing.

Done when you have the number and the record it supersedes, or none.

### 3. Write the record

**Fill `templates/decision.md` in this skill's folder into `docs/decisions/NNNN-slug.md`, and delete its comments and placeholder hints as you fill.** The slug is the title in kebab-case, and the ID is `D-` plus the same four digits, such as `D-0007`.

**Set the status from what the user said:**

| The user            | Status   | Also                                                                 |
| ------------------- | -------- | -------------------------------------------------------------------- |
| Accepted it         | Accepted |                                                                      |
| Left it assumed     | Proposed | An "Assumed:" line in Consequences, with what changing it would cost |
| Has not seen it yet | Proposed |                                                                      |

**When it supersedes a record, restate in the new record every part of the old decision still in force, and say in Context what changed.** Each topic then has one record that holds, and nobody traces a chain. Set the old record's `status` to Superseded and add `superseded_by: D-NNNN`; the new record names the old one in `supersedes`.

Done when the record exists, its Decision names what it binds, and each section holds content or was removed as empty.

### 4. Report

**Report one line per decision handed to you, recorded or not, in this shape:**

```markdown
- `docs/decisions/0007-postgres-for-orders.md` — D-0007, Accepted; supersedes D-0002
- Not recorded: three retries on payment calls — affects one feature; belongs in a code comment beside the client
```

Done when the caller or the user has, for each decision, the path, ID and status, or the test it failed.
