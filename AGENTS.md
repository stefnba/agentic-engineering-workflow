# AGENTS.md

Orientation for agents working on this repo. Only orientation lives here — the contract itself lives in `workflow/`. Read the owning doc before acting; don't work from a summary of it.

## Reference repo, not consuming repo

This repo collects agentic-coding practices — workflow design, documentation structure, reusable skills — for _other_ repos to install (see [README.md](README.md)). Docs and skills therefore describe a consuming repo's layout: workspace packages, CI gates, colocated `src/<domain>/README.md` files. None of that exists in this tree. Treat a referenced path that doesn't resolve here as intentional — leave it as written; note real drift in [work/backlog.md](work/backlog.md).

## Where things live

This repo is also the plugin: its root is the plugin root, so everything here ships to consuming
repos. Three layers, distinguished by who may change a file:

| Path                                                            | Layer                                             | Changed by                 |
| --------------------------------------------------------------- | ------------------------------------------------- | -------------------------- |
| `workflow/`, `agents/`, `skills/`, `scripts/`, `output-styles/` | plugin — the workflow contract and its components | the workflow author        |
| `docs/conventions/*.md`                                         | rules a consuming repo owns, installed by `setup` | the consuming repo's owner |
| `work/config.conf`                                              | settings a consuming repo owns that scripts read  | the consuming repo's owner |
| `docs/*.md`, `docs/decisions/`                                  | published narrative, never loaded by an agent     | the workflow author        |

Each layer has its own directory, so placement answers the question the table asks: a rule the
workflow owns goes in `workflow/`, a convention a repository owns goes in `docs/conventions/`,
and prose only a human reads goes in `docs/`. Two splits aren't by directory: a workflow rule every
invocation of an agent needs is a preloaded skill rather than a `workflow/` doc (see
[workflow/components.md](workflow/components.md)), and anything a script consumes is machine-readable
config in `work/config.conf`, never prose in `docs/conventions/`
(see [docs/decisions/2026-08-18-script-read-settings.md](docs/decisions/2026-08-18-script-read-settings.md)).

Building or changing a skill or an agent has its own contract in
[workflow/components.md](workflow/components.md) — where knowledge lives (skill, agent, or
`workflow/` doc), inline versus forked, write boundaries as hooks, where supporting material goes,
which link form resolves at runtime, and the four plugin rules. Read it before adding either.

## Conventions this repo applies to itself

- **The `work/` tree is live here**, dogfooding its own format: new ideas, noticed drift, and follow-ups become lines in [work/backlog.md](work/backlog.md) (format, kinds, and areas owned by [workflow/artifacts.md](workflow/artifacts.md)) — not TODOs scattered in other files.
- **[GLOSSARY.md](GLOSSARY.md) is live here too**, near-empty by design — only terms no owning doc already defines; artifact terms (bundle, spec, ticket, backlog) stay owned by [workflow/artifacts.md](workflow/artifacts.md).
- **Decision records are immutable.** Supersede a `docs/decisions/` record with a new one; never edit it — the sole exception is carrying a repo-wide terminology rename through, which changes no decision.
- **One copy.** Docs reference each other instead of restating. When adding material, link to the owning doc; if nothing owns it yet, decide where it belongs before writing. A doc may name a rule or state it, never both — where a "see X" already points at the owner, the surrounding prose stays a clause, not a paragraph. Never duplicate a number, a list, or a setting name across docs; those are what actually drift.
- **Guides own nothing.** [docs/walkthrough.md](docs/walkthrough.md) is navigational — which skill, which session, what you do at a handoff. Every rule it touches lives in `workflow/` and is linked, never restated, and no `workflow/` doc depends on it.
- Read [docs/conventions/git.md](docs/conventions/git.md) before any git operation — it holds this repo's commit and PR conventions and the plain-git worktree rule. Settings the scripts read live in [work/config.conf](work/config.conf); [workflow/git-mechanics.md](workflow/git-mechanics.md) owns the procedures that consume both.
