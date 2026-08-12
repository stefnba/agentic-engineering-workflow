# Agentic Coding Workflow

A **reference repo** for agentic coding: workflow design, documentation structure, tool setup, and reusable skills. It collects the practices — it is not a codebase that follows them.

That distinction matters when reading anything here:

- The docs describe conventions for a _real_ product repo (workspace packages, CI gates, feature bundles). None of that infrastructure exists here, so don't expect the layouts they describe to be present in this tree.
- The skills under `skills/` are meant to be copied into (or eventually installed by) other repos. Their instructions reference paths and structures of a target repo, not this one.
- The conventions this repo does apply to itself are [work/backlog.md](work/backlog.md), which tracks work on the reference material, and [GLOSSARY.md](GLOSSARY.md), a near-empty root vocabulary file — partly to have them, partly to dogfood the format.

## Skills

What exists today. The conventions they follow live in [docs/skills.md](docs/skills.md); the build plan for the unbuilt rest in [work/skills-build-plan.md](work/skills-build-plan.md).

Each name is a pointer — the authoritative description lives in that skill's `SKILL.md` frontmatter.

### Workflow skills

Stage-bound — each realizes one role of the [workflow](docs/agentic-workflow.md):

| Name           | Stage     | Purpose                     |
| -------------- | --------- | --------------------------- |
| `interview-me` | Discover  | Grills intent until settled |
| `shape`        | Shape     | Writes spec and tickets     |
| `critique`     | Shape     | Attacks the shaped spec     |
| `implement`    | Implement | Executes one ticket to a PR |
| `review`       | Review    | Judges a ticket's PR        |
| `ship`         | Ship      | Absorbs and deletes bundle  |

### Supporting skills

Not stage-bound — they serve any session:

| Name                 | Purpose                        |
| -------------------- | ------------------------------ |
| `setup`              | Installs the workflow          |
| `backlog`            | Maintains the backlog file     |
| `glossary`           | Maintains the domain glossary  |
| `decision`           | Writes decision records        |
| `handoff`            | Compacts a dying session       |
| `writing-for-agents` | Reviews agent-facing documents |

## Agents

The subagents forked skills run in:

| Name       | Purpose                 |
| ---------- | ----------------------- |
| `critic`   | Read-only spec attacker |
| `reviewer` | Judges a ticket's PR    |

## Tool setup

[docs/tool-setup.md](docs/tool-setup.md) — configuring Claude Code for a consuming repo: trimming the default system prompt and toolset, protecting secrets, MCP servers, output styles. (Codex section is still a TODO.)

## Status

Work in progress — the workflow stages are still being designed, and the docs and skills have drifted in places (tracked in the backlog).
