---
name: write-architecture-doc
description: Write or update a repo's or app's architecture doc (ARCHITECTURE.md). Use when creating an architecture overview, when a change adds/removes/renames a service, app, pipeline stage, store, queue, external dependency or major boundary, or when asked whether an architecture doc is still accurate — even if the user only asks "how is this structured" or "document the architecture".
---

# Write architecture doc

Leave the scope with an `ARCHITECTURE.md` that is true today: a **map, not a spec**, enough for a new engineer to orient in 10 minutes and know which files to open next. Depth lives in decision records, the glossary, component docs, and code.

## Path conventions

- `templates/` paths are relative to this skill's directory, the folder holding this file.
- `../writing/` is the sibling `writing` skill, in the same skills directory as this one.
- Every other path is relative to the repository root, `git rev-parse --show-toplevel`, not the
  current directory.

## Guardrails

**Write responsibilities, boundaries, contracts** (what crosses them, sync/async, who owns the data), **invariants, and why each boundary exists.** "Why" rots slowest, and it is what an agent needs to extend the system in a new direction safely.

**Make every sentence survive a refactor.** If a refactor that keeps every boundary and contract intact would make a sentence wrong, delete the sentence. That rules out:

- Function, method, class, and variable names. Say "the auth middleware", not `verifyJwt()`. Describe a public surface by what each entry point does; name a domain type by its glossary term — the glossary maps it to the code name.
- File paths below the directories the codebase map lists, and links to source files or line numbers. Link only to docs: decision records, runbooks, schema docs, the glossary, other members' architecture docs.
- Endpoint lists, route tables, CLI flags, config keys, env var names.
- Library versions, or the library at all unless it _is_ the architectural choice ("Kafka", not "kafkajs 2.x").
- Real code. Pseudocode for a flow is fine.
- How a component works internally, test setups, and known-issue lists.
- "Currently", "for now", "TODO", "we should" — either it's the architecture or it isn't.

**Name domain concepts with their `GLOSSARY.md` term**, and components and top-level directories exactly as the code names them.

**Describe one state and declare it** in the header's `Describes` field:

- `current system` — the default. Everything described exists now.
- `target design` — only when the system is being built toward a settled design. Mark every part not yet built _(planned)_ — including a rule no code enforces yet. Undecided questions go under _Decisions_ as `Open: …`, never into the body.

Roadmaps and wishes stay out; once a direction is settled, it becomes a decision record.

**Keep it to ~2 pages.** When a section passes ~15 lines, move the detail to a linked doc. Use at most one diagram per section, as Mermaid code.

**Write only what the repo shows.** A value no file confirms — an owner, a guarantee, an intent — is `TBD` in the doc and a question in your report, because a guessed value reads as settled fact.

## Process

### 1. Locate the doc and pick the mode

**The doc lives at `<scope>/docs/ARCHITECTURE.md`**, where the scope is the repository root in a single-project repo and the member (`apps/<name>/`, `packages/<name>/`, …) the task concerns in a monorepo. A root doc in a monorepo describes how members relate, not their insides; write one only when it already exists or the user asks. When the scope already has an architecture doc anywhere, it is the doc, under its current name and casing. Every path below is relative to the scope.

Pick the mode:

- **Write** — the scope has no doc.
- **Update** — this task's code change adds, removes, or renames a component, dependency, store, or top-level directory, reshapes a key flow, revises a constraint, or builds a _(planned)_ part. Update in the same change as the code.
- **Review** — the user asks whether the doc is accurate, or it contradicts the code you are reading.

Done when you can name the doc's path and the mode.

### 2. Gather the facts

Read the scope's README and agent-instructions file (`AGENTS.md`, `CLAUDE.md`), `docs/GLOSSARY.md` and `docs/decisions/` when present, the directory layout, build and deploy config (Dockerfile, compose, CI, IaC, workspace manifests), entry points (`main`, routers, handlers, CLIs, pipeline runners), and schema or migrations. In update and review mode, read the current doc in full first.

Done when you have written down every component — every separately runnable or deployable thing (service, worker, job, CLI, app) plus every datastore, queue, artifact store, and external API or model it calls — and the 2–4 flows a new engineer will touch first. A gap in the list means you don't understand the system yet; keep reading.

### 3. Draft or correct the doc

**Read `../writing/references/explain.md` before drafting or correcting**; it holds the prose rules for a document that explains. Where it and `templates/ARCHITECTURE.md` disagree, the template wins.

**Write mode:** copy `templates/ARCHITECTURE.md` to the doc's path, creating `docs/` if needed. Tailor it by repo shape — drop every section with nothing true to say, rename headings to the repo's vocabulary, replace the example code-map directories with the real ones — then fill each remaining section from its embedded guidance and delete every `<!-- -->` comment.

| Repo shape                | Carries the weight                                                             | Usually dropped                               |
| ------------------------- | ------------------------------------------------------------------------------ | --------------------------------------------- |
| Services / web system     | Components diagram, request flows, data ownership                              | Public surface                                |
| Data, ML, or LLM pipeline | Key flows as a stage chain naming what crosses each hop; run artifacts in Data | Components diagram when there is one runnable |
| Library / shared package  | Public surface, codebase map with dependency direction, constraints            | Components, Key flows, Data & storage         |
| CLI or single app         | Codebase map, the main command flow                                            | Components diagram, Public surface            |

In a member-scoped doc, System context shows the members that import this one and the members it imports; link their docs instead of describing their insides.

**Update mode:** change only the sections the code change affects.

**Review mode:** compare each section against what step 2 found — components against deploy config and entry points, external dependencies against the clients in the code, the codebase map against real directories, constraints against what the code enforces, _Decisions_ against `docs/decisions/`, and _(planned)_ marks against what now exists. Fix each mismatch inline.

**In update and review mode, add a template section when a fact you must record has no section to go in**; otherwise keep the doc's existing structure.

Done when every section states only what step 2 confirmed, and no comment or `…` placeholder remains.

### 4. Hand off decisions and terms

**When the task settled a choice between alternatives, use the `record-decision` skill** — it writes the record and adds the _Decisions_ line; keep the rationale out of this doc. **When the doc needs a domain term the glossary lacks, use the `glossary` skill** instead of defining it inline.

Done when every settled choice and missing term is handed off or listed in your report.

### 5. Verify every name

Check each directory, component, dependency, and link the doc mentions with `ls` or grep against the repository. Fix or delete every miss.

Done when every name resolves.

### 6. Set the header and make the doc reachable

Set `Last reviewed` to today and `Describes` to the state the doc covers. Take `Owner` from `CODEOWNERS`, the scope's README, or its `AGENTS.md`; with no source, write `TBD`.

In write mode, link the doc from the scope's README, and add a pointer to the scope's `AGENTS.md` naming when to read it — for example, "Read `docs/ARCHITECTURE.md` before adding a component, changing a boundary, or changing dependency direction."

Done when the header has no guessed value and both links exist.

### 7. Report

- **Write or update:** the doc's path, the sections you dropped or added, every other file you edited, and each `TBD` as a question to the user.
- **Review:** one line per changed section — what was wrong and what it says now — then each `TBD` as a question.

Name code problems you found along the way (stale docstrings, dead references) in one list; fixing them is outside this skill.
