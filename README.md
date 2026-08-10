# Agentic Coding Workflow

A **reference repo** for agentic coding: workflow design, documentation structure, tool setup, and reusable skills. It collects the practices — it is not a codebase that follows them.

That distinction matters when reading anything here:

- The docs describe conventions for a _real_ product repo (workspace packages, CI gates, feature bundles). None of that infrastructure exists here, so don't expect the layouts they describe to be present in this tree.
- The skills under `skills/` are meant to be copied into (or eventually installed by) other repos. Their instructions reference paths and structures of a target repo, not this one.
- The one convention this repo does apply to itself is [work/backlog.md](work/backlog.md), which tracks work on the reference material — partly to have a backlog, partly to dogfood the format.

## Skills

What exists today. The conventions they follow — and the build plan for the unbuilt rest — live in [docs/skills.md](docs/skills.md).

### Workflow skills

Stage-bound — each realizes one role of the [workflow](docs/agentic-workflow.md):

| Name        | Stage    | What it does                                                            |
| ----------- | -------- | ----------------------------------------------------------------------- |
| `interview` | Discover | Turns user intent into a brief in `work/candidates/`                    |
| `shape`     | Shape    | Turns a picked candidate into `spec.md` and its full ticket set         |
| `critique`  | Shape    | Attacks a shaped spec in a fresh context; forks into the `critic` agent |

### Supporting skills

Not stage-bound — they serve any session:

| Name                 | What it does                                                    |
| -------------------- | --------------------------------------------------------------- |
| `backlog`            | Maintains `work/backlog.md` — add, complete, promote, look up   |
| `decision`           | Writes or supersedes records in `docs/decisions/`               |
| `handoff`            | Compacts a dying session into a handoff document                |
| `writing-for-agents` | Writing and reviewing documents an agent will consume or follow |

## Agents

The subagents forked skills run in:

| Name     | What it does                                            |
| -------- | ------------------------------------------------------- |
| `critic` | Read-only spec attacker the `critique` skill forks into |

## Status

Work in progress — the workflow stages are still being designed, and the docs and skills have drifted in places (tracked in the backlog).
