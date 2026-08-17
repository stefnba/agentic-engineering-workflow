# Agentic Coding Workflow

A **reference repo** for agentic coding: workflow design, documentation structure, tool setup, and reusable skills. It collects the practices — it is not a codebase that follows them.

That distinction matters when reading anything here:

- The docs describe conventions for a _real_ product repo (workspace packages, CI gates, feature bundles). None of that infrastructure exists here, so don't expect the layouts they describe to be present in this tree.
- The skills under `skills/` are meant to be copied into (or eventually installed by) other repos. Their instructions reference paths and structures of a target repo, not this one.
- The conventions this repo does apply to itself are [work/backlog.md](work/backlog.md), which tracks work on the reference material, and [GLOSSARY.md](GLOSSARY.md), a near-empty root vocabulary file — partly to have them, partly to dogfood the format.

## The workflow

- [docs/workflow.md](docs/workflow.md) — the five stages, human gates, and coordination rules
- [docs/artifacts.md](docs/artifacts.md) — which artifact owns which question, and for how long
- [docs/bundle.md](docs/bundle.md) — how intent, plan, and tickets cooperate inside a bundle
- [docs/shaping-routes.md](docs/shaping-routes.md) — which artifacts a given piece of work needs
- [docs/walkthrough.md](docs/walkthrough.md) — running it day to day: which skill, which session tab

## Skills

What exists today. Each name is a pointer — the authoritative description lives in that skill's `SKILL.md` frontmatter.

### Workflow skills

Stage-bound — each realizes one role of the [workflow](docs/workflow.md):

| Name           | Stage     | Purpose                              |
| -------------- | --------- | ------------------------------------ |
| `audit`        | Discover  | Sweeps the repo for drift            |
| `research`     | Discover  | Investigates one topic               |
| `interview-me` | Discover  | Grills intent until settled          |
| `pick`         | Discover  | Presents candidates; the human picks |
| `shape`        | Shape     | Writes spec and tickets              |
| `critique`     | Shape     | Attacks the shaped spec              |
| `implement`    | Implement | Executes one ticket to a PR          |
| `review`       | Review    | Judges a ticket's PR                 |
| `ship`         | Ship      | Absorbs and deletes bundle           |

### Supporting skills

Not stage-bound — they serve any session:

| Name                 | Purpose                                    |
| -------------------- | ------------------------------------------ |
| `setup`              | Installs the workflow                      |
| `bundle-git`         | Claims tickets, reports status, merges PRs |
| `backlog`            | Maintains the backlog file                 |
| `glossary`           | Maintains the domain glossary              |
| `decision`           | Writes decision records                    |
| `judge`              | Rules on open design questions             |
| `handoff`            | Compacts a dying session                   |
| `writing-for-agents` | Reviews agent-facing documents             |

## Agents

The subagents forked skills run in, under [agents/](agents/):

| Name          | Purpose                                       |
| ------------- | --------------------------------------------- |
| `architect`   | Drafts the bundle during Shape                |
| `critic`      | Read-only spec attacker, before the Plan gate |
| `implementer` | Executes one ticket to a PR, and fix rounds   |
| `reviewer`    | Judges a ticket's PR                          |

## Tool setup

[docs/tool-setup.md](docs/tool-setup.md) — configuring Claude Code for a consuming repo: trimming the default system prompt and toolset, protecting secrets, MCP servers, output styles. (Codex section is still a TODO.)

## Status

Work in progress — the workflow stages are still being designed, and the docs and skills have drifted in places (tracked in the backlog).
