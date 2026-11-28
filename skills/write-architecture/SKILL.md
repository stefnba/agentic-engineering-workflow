---
name: write-architecture
description: Use when a repository with code has no `docs/ARCHITECTURE.md`, when that file no longer matches the code after a change to its structure, or when the user says "document the architecture", "map this codebase" or "how is this built". Also use when another skill asks for the architecture or for candidate decisions and terms drawn from code.
---

# Write the architecture

`docs/ARCHITECTURE.md` describes the current shape of the system, and every claim in it cites the code that shows it.

## Guardrails

**Write only `docs/ARCHITECTURE.md`.** Candidate decisions and terms go back to the caller or the user, for `record-decision` and `update-glossary`.

**Describe the code as it is.** Plans, intentions and choices the code does not show belong in decision records or in `docs/PROJECT.md`.

**Change an existing `docs/ARCHITECTURE.md` only after the user approves the change.** Show the lines you would change, each with the cite that makes it true.

**Leave every change uncommitted.** The user reviews the diff first.

## Process

### 1. Check there is code to describe

**Run `git ls-files` and look for source files**: files in a programming language, outside `docs/`, configuration and build manifests.

**When there are none, write nothing and stop.** Say that the architecture is written after the first end-to-end slice exists, because an empty file invites guesses.

Done when you have the source files to read, or the user knows why nothing was written.

### 2. Extract from the code

**Read `references/extract.md` and follow it.**

**When `docs/ARCHITECTURE.md` exists, extract only the parts that changed.** Run `git diff --name-only <commit>..HEAD`, with the commit its "Built from" line names, and extract each part holding a listed file. When the line is missing, extract every part.

Done when each claim cites `[path:symbol]`, and each candidate decision names where it was seen.

### 3. Check every cite

**Open each cited path and find the symbol in it.** Drop a claim whose cite does not resolve, and list it under unconfirmed claims in the report.

**Check that each link in the file you will write points at a file that exists.**

Done when every cite and link resolves.

### 4. Write the file

**When `docs/ARCHITECTURE.md` is missing, fill `templates/ARCHITECTURE.md` from this skill's folder into it, and delete its comments as you fill.** When it exists, show the changes and wait for approval.

**Set the "Built from" line to the output of `git rev-parse --short HEAD`.** An uncommitted change in a cited file makes the line false; say so in the report.

Done when every claim in the file carries a cite.

### 5. Test it with a fresh reader

**Give a fresh context window the file's text and three questions a new contributor would bring to this repository**, such as "which part writes an order", "where does a new field on an order go" and "what may the orders part not import". When the file exists, give it the text with your changes applied.

**Tell the window to answer from the text alone, naming the section it used or saying "not in the doc".** Leave your extraction out of its brief, so the answers show what the file alone gives.

**Check each answer against the code.** Fix the line behind a wrong answer. When the Parts table should have answered a "not in the doc" question, add the missing row. Leave out detail that only one file's code holds.

**When no fresh context window is available, skip the test and say so in the report.** You wrote the file, so your own reading of it tests nothing.

Done when each answer is checked against the code and the line behind each wrong one is fixed.

### 6. Report

**Report in this shape:**

```markdown
**Architecture** — `docs/ARCHITECTURE.md` written; 5 parts, 2 with no decision record; 2 data stores, 1 external system

**Candidate decisions**

- Orders are stored in Postgres through one repository class — `[src/orders/repository.ts:OrderRepository]`; rules out a document store

**Candidate terms**

- Settlement — names `src/billing/settlement.ts`; meaning unconfirmed

**Unconfirmed claims** — `docs/design-notes.md` says payments retry three times; no code shows it

**Not read** — `src/legacy/`; its window stopped before returning

**Fresh reader** — 2 of 3 right; it named the web part as the writer of orders, so the Parts row now names the orders part
```

Done when the caller or the user has the report.
