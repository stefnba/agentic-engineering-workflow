---
name: record-decision
description: Use when the user says "record this decision", "write an ADR" or "supersede D-0003", when another skill hands over a settled or candidate decision to record, or when a choice just settled is hard to reverse, affects more than one feature, and had a real alternative. Not for routine implementation choices.
---

# Record a decision

A decision that meets the bar is a numbered record in `docs/decisions/`, with a status that says whether the user accepted it.

## Guardrails

**Write only files in `docs/decisions/`.** In an existing record, change only its Status line, and only to mark it superseded.

**Mark a record Accepted only when the user accepted the decision in this conversation.** Agents propose decisions; the user accepts them. A decision found in code, or suggested by an agent, is Proposed.

**Leave every change uncommitted.** The user reviews the diff first.

## Process

### 1. Test the decision against the bar

**Record it only when all three hold:** it is hard to reverse, it affects more than one feature, and a real alternative existed. Agents write too many records, and a record nobody needs buries the ones that matter.

**When the bar fails, say where the choice belongs instead and stop:** in the doc it shapes, such as `docs/ARCHITECTURE.md`, or in a code comment beside the code it explains.

**When the user rejected the decision, write no record.** Report it as rejected, so the caller can list it.

Done when the decision passes the bar, or the user has the reason it does not.

### 2. Number the record

**List `docs/decisions/` and take the next number after the highest one.** The first record is `0001`. A missing folder means no records yet; create it.

**Read each record whose title touches the same topic.** When the new decision replaces one, the new record supersedes it.

Done when you have the number and the record it supersedes, or none.

### 3. Write the record

**Fill `templates/decision.md` in this skill's folder into `docs/decisions/NNNN-slug.md`, and delete its comments as you fill.** The slug is the title in kebab-case, and the ID is `D-` plus the same four digits, such as `D-0007`.

**Set the status from what the user said:**

| The user            | Status   | Also                                                                 |
| ------------------- | -------- | -------------------------------------------------------------------- |
| Accepted it         | Accepted |                                                                      |
| Left it assumed     | Proposed | An "Assumed:" line in Consequences, with what changing it would cost |
| Has not seen it yet | Proposed |                                                                      |

**When it supersedes a record, set that record's Status line to `Superseded by D-NNNN`.**

Done when the record exists and each section holds content or was removed as empty.

### 4. Report

**Report in this shape:**

```markdown
- `docs/decisions/0007-postgres-for-orders.md` — D-0007, Accepted; supersedes D-0002
```

Done when the caller or the user has the path, the ID and the status.
