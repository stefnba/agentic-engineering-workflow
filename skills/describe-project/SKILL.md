---
name: describe-project
description: Use when the user says "describe the project", "write the project docs", "document what we are building" or "onboard this codebase", when `setup-workflow` has just finished, or when another skill asks for the project to be described. Also use when the user complains that agents keep guessing what the repository is for, which choices in it are settled, or what its terms mean.
---

# Describe the project

`docs/` says what the project is, who it is for, how it is built and what is decided, and a fresh agent that reads it can tell what is settled from what is open.

## Guardrails

**Write no doc yourself.** `update-project`, `write-architecture`, `update-glossary` and `record-decision` write `docs/PROJECT.md`, the architecture, the glossary and the decision records, and own their formats.

**Hand the writers only points the user decided, the user left assumed, or the code shows.** An open point goes in the report, never in a doc.

**Treat a file these skills write that already exists as a draft to confirm.** Edit it only after the user approves the change.

**Leave every change uncommitted.** The user reviews the diff first.

## Process

### 1. Read what exists

**Read the files these skills write, the root `README.md`, and every other doc**, such as design notes or decision records in another folder.

**Check for code:** run `git ls-files` and look for source files, meaning files in a programming language outside `docs/`, configuration and build manifests. When the folder is not a git repository, treat it as having no code and say so.

**Report in this shape:**

```markdown
**What exists**

- Code — 214 source files under `src/`
- `docs/PROJECT.md` — absent
- `docs/ARCHITECTURE.md`, `docs/GLOSSARY.md`, `docs/decisions/` — absent
- Other docs — `README.md` describes the problem; `docs/design-notes.md` holds three choices
```

Done when the report names the code, each file these skills write, and each other doc.

### 2. Gather candidates

**When there is code, run `write-architecture`.** It writes the architecture and returns candidate decisions and candidate terms.

**When other docs exist, list what they claim**, each with its source: the problem, users and use cases, choices that look like decisions, and terms. A claim the code contradicts is listed with both sources.

**When there is neither, skip this step.** The interview starts from nothing.

Done when every candidate has a source.

### 3. Interview the user

**REQUIRED: run `interview-me` skill with these topics:**

- Problem, users, core use cases and non-goals for `PROJECT.md`. Use cases get IDs `UC-1`, `UC-2`.
- Constraints: what the project must run on, work with or stay within.
- Whether a short Now, Next and Later roadmap of themes is wanted, and which themes.
- Each candidate from the gather step: accept, change or reject.
- Each term that two people could read differently.
- Each choice still to make that is hard to reverse, affects more than one feature, and had a real alternative.

**Ask about each candidate with a recommended answer**, such as "The code stores orders in Postgres through one repository class. Record that as an accepted decision?"

Done when the user confirmed the interview summary.

### 4. Write the docs

**Run `update-project` with the confirmed problem, users, use cases, constraints, non-goals and roadmap.** It returns any point someone could close as a candidate work item.

**Run `update-glossary` with the confirmed terms.**

**Run `record-decision` once per decision from the summary, saying whether the user accepted it, left it assumed or rejected it.**

Done when each point in the summary sits in exactly one file, or in the report when it is open or rejected.

### 5. Check with a fresh reader

**In a fresh context window, have a reader see only the files written in this run, and answer three questions:** what is being built and for whom, what is decided, and what is open. When no fresh context window is available, ask the user to run the check in a new session.

**Compare the answers with the interview summary.** Fix each gap the docs caused, and list the rest in the report.

Done when the answers match the summary, or each mismatch is fixed or listed.

### 6. Report

**Report in this shape:**

```markdown
**Written**

- `docs/PROJECT.md` — 4 use cases, 3 non-goals, a roadmap
- `docs/ARCHITECTURE.md` — 5 parts
- `docs/GLOSSARY.md` — 6 terms
- `docs/decisions/0001-postgres-for-orders.md` — D-0001, Accepted

**Open questions**

- Which payment provider — blocks `UC-3`

**Rejected** — the queue in `docs/design-notes.md`; no record written

**Overlapping docs** — `docs/design-notes.md` repeats `D-0001` and still names the rejected queue

**Fresh reader** — matched the summary; one gap fixed in `PROJECT.md`
```

**Offer to edit each overlapping doc**, and change it only after the user approves.

**When `docs/workflow/tracker.md` exists, offer to create one work item per candidate work item from `update-project`, and one per open question that blocks work, flagged as that file says for a needed decision.** Create them only after the user says yes, because work items are visible to everyone with access.

Done when the user has the report and the diff is uncommitted.
