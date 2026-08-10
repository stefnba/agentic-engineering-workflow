# AGENTS.md

Orientation for agents working on this repo. Only orientation lives here — the conventions themselves live in `docs/`. Read the owning doc before acting; don't work from a summary of it.

## Reference repo, not consuming repo

This repo collects agentic-coding practices — workflow design, documentation structure, reusable skills — for _other_ repos to install (see [README.md](README.md)). Docs and skills therefore describe a consuming repo's layout: workspace packages, CI gates, colocated `src/<domain>/README.md` files. None of that exists in this tree. Treat a referenced path that doesn't resolve here as intentional — leave it as written; note real drift in [work/backlog.md](work/backlog.md).

## Where the conventions live

| Question                                                  | Owning doc                                             |
| --------------------------------------------------------- | ------------------------------------------------------ |
| Which documents exist, what they contain, where they live | [docs/docs-structure.md](docs/docs-structure.md)       |
| Process — stages, gates, loops, approval points           | [docs/agentic-workflow.md](docs/agentic-workflow.md)   |
| How workflow roles map onto skills                        | [skills/README.md](skills/README.md)                   |
| Subagent definitions the skills fork into                 | [agents/README.md](agents/README.md)                   |
| Claude Code setup for a consuming repo                    | [docs/setup-claude-code.md](docs/setup-claude-code.md) |

**Before creating or editing anything under `docs/`, read `docs-structure.md`.** It is the rule file for that tree.

## Conventions this repo applies to itself

- **The `work/` tree is live here**, dogfooding its own format: new ideas, noticed drift, and follow-ups become lines in [work/backlog.md](work/backlog.md) (tags and format defined at the top of the file) — not TODOs scattered in other files.
- **Decision records are immutable.** Supersede a `docs/decisions/` record with a new one; never edit it.
- **One copy.** Docs reference each other instead of restating. When adding material, link to the owning doc; if nothing owns it yet, decide where it belongs before writing.
