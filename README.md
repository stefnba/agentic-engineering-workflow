# agentic-coding

A **reference repo** for agentic coding: workflow design, documentation structure, tool setup, and reusable skills. It collects the practices — it is not a codebase that follows them.

That distinction matters when reading anything here:

- The docs describe conventions for a _real_ product repo (workspace packages, CI gates, feature bundles). None of that infrastructure exists here, so don't expect the layouts they describe to be present in this tree.
- The skills under `skills/` are meant to be copied into (or eventually installed by) other repos. Their instructions reference paths and structures of a target repo, not this one.
- The one convention this repo does apply to itself is [work/backlog.md](work/backlog.md), which tracks work on the reference material — partly to have a backlog, partly to dogfood the format.

## Skills and agents

What exists today. The conventions they follow — and the build plan for the unbuilt rest — live in [docs/skills.md](docs/skills.md).

| Name                 | Kind                      | What it does                                                            |
| -------------------- | ------------------------- | ----------------------------------------------------------------------- |
| `interview`          | workflow skill (Discover) | Turns user intent into a brief in `work/candidates/`                    |
| `shape`              | workflow skill (Shape)    | Turns a picked candidate into `spec.md` and its full ticket set         |
| `critique`           | workflow skill (Shape)    | Attacks a shaped spec in a fresh context; forks into the `critic` agent |
| `backlog`            | supporting skill          | Maintains `work/backlog.md` — add, complete, promote, look up           |
| `decision`           | supporting skill          | Writes or supersedes records in `docs/decisions/`                       |
| `handoff`            | supporting skill          | Compacts a dying session into a handoff document                        |
| `writing-for-agents` | supporting skill          | Writing and reviewing documents an agent will consume or follow         |
| `docs-rules`         | reference skill           | Procedural distillate of docs-structure, preloaded into subagents       |
| `critic`             | subagent                  | Read-only spec attacker the `critique` skill forks into                 |

## Status

Work in progress — the workflow stages are still being designed, and the docs and skills have drifted in places (tracked in the backlog).
