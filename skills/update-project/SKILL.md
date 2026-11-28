---
name: update-project
description: Use when the user says "add a use case", "add a non-goal", "that is out of scope", "update the roadmap" or "change who this is for", when another skill hands over a settled problem, user, use case, constraint, non-goal or roadmap change, or when `docs/PROJECT.md` no longer matches what the user says the project is for.
---

# Update the project description

`docs/PROJECT.md` says what the project is, who it is for, what it must stay within and where it is heading, as the user settled it.

## Guardrails

**Write only `docs/PROJECT.md`.**

**Write a point only when the user decided it, the user left it assumed, or the code shows a user can already do it.** Mark an assumed point "Assumed:", with what changing it would cost. An open point goes in the report, never in the file.

**Keep out of `docs/PROJECT.md` anything someone could close:** a task, a bug, acceptance criteria, an estimate, an owner, a date, a status, a checkbox or an issue number. Return it as a candidate work item instead. Work lives in the tracker; a file that tracks it goes stale every week and turns into a second backlog.

**Keep out of `docs/PROJECT.md` how the system is built:** its parts, stack, libraries, stores, endpoints and data flow. A line that a code change could make false belongs in `docs/ARCHITECTURE.md`, which `write-architecture` keeps true to the code.

**Write a constraint only when it comes from outside the code**, such as a customer, a law, a budget or a platform the project must run on. A technology the team chose is a candidate decision for `record-decision`, not a constraint.

**Leave every change uncommitted.** The user reviews the diff first.

## Process

### 1. Sort each point

**Read `docs/PROJECT.md`, and sort each point you were given:**

- **Work item:** someone could close it. Skip it, and return it as a candidate work item.
- **Elsewhere:** how the code is built goes to `write-architecture`, a technology the team chose and the reason for a hard-to-reverse choice to `record-decision`, and a term's meaning to `update-glossary`. Skip it, and name where it belongs.
- **New:** a problem, user, use case, constraint, non-goal or roadmap theme not in the file.
- **Same:** already in the file with the same meaning. Skip it.
- **Conflict:** contradicts a line in the file, such as a non-goal the user now wants as a use case.

**Ask the user to settle each conflict and each new point without a confirmed answer**, one numbered question per point, with the exact line you would write. A caller that ran an interview has already confirmed its points.

Done when every new or conflicting point has a confirmed line, or the user dropped it.

### 2. Write the lines

**When `docs/PROJECT.md` is missing, fill `templates/PROJECT.md` from this skill's folder into it, and delete its comments as you fill.**

**Write one use case per thing a user can achieve, with the next free ID after the highest one, such as `UC-4`.** A screen, an endpoint or a step is part of a use case, not one of its own. Never reuse a removed ID, because work items and decision records cite it.

**Write the roadmap as themes, at most about three each under Now, Next and Later, with no items under a theme.** A theme may name its milestone, so its detail stays in the tracker.

**Give each non-goal and each constraint its reason.** A non-goal without a reason gets reopened by the next reader.

**Edit a conflicting line in place.** Git keeps its history.

Done when each confirmed point has exactly one line, and the file holds nothing someone could close.

### 3. Report

**List each point as added, changed or skipped.** Give the reason for each skip: same, the file it belongs in, or a work item.

**List the candidate work items separately**, so the caller or the user can create them in the tracker.

Done when the caller or the user has both lists.
