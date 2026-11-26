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

**Read `references/extract.md` and follow it.** Done when each claim cites `[path:symbol]`, and each candidate decision names where it was seen.

### 3. Write the file

**When `docs/ARCHITECTURE.md` is missing, fill `templates/ARCHITECTURE.md` from this skill's folder into it, and delete its comments as you fill.** When it exists, show the changes and wait for approval.

Done when every claim in the file carries a cite.

### 4. Report

**Report in this shape:**

```markdown
**Architecture** — `docs/ARCHITECTURE.md` written; 5 parts, 2 data stores, 1 external system

**Candidate decisions**

- Orders are stored in Postgres through one repository class — `[src/orders/repository.ts:OrderRepository]`; rules out a document store

**Candidate terms**

- Settlement — names `src/billing/settlement.ts`; meaning unconfirmed

**Unconfirmed claims** — `docs/design-notes.md` says payments retry three times; no code shows it
```

Done when the caller or the user has the report.
