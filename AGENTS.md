# AGENTS.md

## Goal

Agent skills for a staged engineering workflow, installed into other repositories: shape work
into a spec and tickets, implement ticket by ticket with review, merge with human approval. This
is version 2, designed from an empty tree because version 1 grew too complex.

Nothing is built yet. `docs/` holds the owner's working drafts: `BRIEF.md` (constraints and
tested harness facts), `agentic-workflow-design.md`, and `github-issues-workflow.md`.

`.agents/skills/` holds skills for working on this repository, not the product. Run the
`writing` skill before writing or editing any Markdown file.

## Guardrails

- **Stay lean.** Add a skill, file, or rule only for a need the owner names. Prefer removing to
  adding.
- **Stay harness agnostic.** The skills run under Claude Code and Codex. Use no mechanism only
  one of them has.
- **Leave undecided things undecided.** Where the drafts are open or contradict each other, ask
  the owner; do not pick. Edit a file in `docs/` only when asked.
- **Design without the earlier versions.** Tags `v1-final` and `v2-baseline` hold them. Read
  them only when the owner asks.
