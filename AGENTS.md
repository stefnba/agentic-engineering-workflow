# AGENTS.md

Orientation for agents working on this repo. Only orientation lives here — the conventions themselves live in `docs/`. Read the owning doc before acting; don't work from a summary of it.

## What this repo is

A **reference repo** for agentic coding: workflow design, documentation structure, and reusable skills. It collects the practices — it is not a codebase that follows them (see [README.md](README.md)).

The practical consequence: the docs describe conventions for a _real_ product repo (workspace packages, CI gates, colocated `src/<domain>/README.md` files). That infrastructure doesn't exist in this tree. When a doc references such a path, it means the target repo's layout — don't "fix" the reference to match this one.

## Where the conventions live

| Question                                                  | Owning doc                                             |
| --------------------------------------------------------- | ------------------------------------------------------ |
| Which documents exist, what they contain, where they live | [docs/docs-structure.md](docs/docs-structure.md)       |
| Process — stages, gates, loops, approval points           | [docs/agentic-workflow.md](docs/agentic-workflow.md)   |
| How workflow roles map onto skills                        | [skills/README.md](skills/README.md)                   |
| Subagent definitions the skills fork into                 | [agents/README.md](agents/README.md)                   |
| Claude Code setup for a consuming repo                    | [docs/setup-claude-code.md](docs/setup-claude-code.md) |

When two docs could answer the same question: artifact questions go to `docs-structure.md`, sequence/approval questions go to `agentic-workflow.md` — each doc states this split at its top.

**Before creating or editing anything under `docs/`, read `docs-structure.md`.** It is the rule file for that tree.

## Conventions this repo applies to itself

The `docs/work/` tree is live here, dogfooding its own format: [docs/work/backlog.md](docs/work/backlog.md) tracks work on the reference material (tags and format are defined at the top of the file), and candidate/planned bundles follow the layout from `docs-structure.md`. New ideas, noticed drift, and follow-ups become backlog lines — not TODOs scattered in other files.

Decision records in `docs/decisions/` are immutable: supersede with a new record, never edit.

## Editing rules

- **One copy.** Docs reference each other instead of restating. When adding material, link to the owning doc; if nothing owns it yet, decide where it belongs before writing.
- **Skills target a consuming repo.** Instructions under `skills/` reference the paths and structure of a repo that installs them, not this one. Apparent path mismatches are usually intentional; real drift belongs in the backlog.
