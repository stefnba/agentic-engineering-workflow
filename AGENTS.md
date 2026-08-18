# AGENTS.md

Orientation for agents working on this repo. Only orientation lives here — the contract itself lives in `workflow/`. Read the owning doc before acting; don't work from a summary of it.

## Reference repo, not consuming repo

This repo collects agentic-coding practices — workflow design, documentation structure, reusable skills — for _other_ repos to install (see [README.md](README.md)). Docs and skills therefore describe a consuming repo's layout: workspace packages, CI gates, colocated `src/<domain>/README.md` files. None of that exists in this tree. Treat a referenced path that doesn't resolve here as intentional — leave it as written; note real drift in [work/backlog.md](work/backlog.md).

## Where things live

This repo is also the plugin: its root is the plugin root, so everything here ships to consuming
repos. Three layers, distinguished by who may change a file:

| Path                              | Layer                                             | Changed by                 |
| --------------------------------- | ------------------------------------------------- | -------------------------- |
| `workflow/`, `agents/`, `skills/` | plugin — the workflow contract and its components | the workflow author        |
| `docs/conventions/*.md`           | rules a consuming repo owns, installed by `setup` | the consuming repo's owner |
| `work/config.conf`                | settings a consuming repo owns that scripts read  | the consuming repo's owner |
| `docs/*.md`, `docs/decisions/`    | published narrative, never loaded by an agent     | the workflow author        |

Each layer has its own directory, so placement answers the question the table asks: a rule the
workflow owns goes in `workflow/`, a convention a repository owns goes in `docs/conventions/`,
and prose only a human reads goes in `docs/`. The one split that isn't by directory: anything a
script consumes is machine-readable config in `work/config.conf`, never prose in `docs/conventions/`
(see [docs/decisions/2026-08-18-script-read-settings.md](docs/decisions/2026-08-18-script-read-settings.md)).

Placement rule for supporting material: **one consumer keeps it in that skill's own folder; two or
more promote it to `workflow/`.**

Reference by link form, not by guesswork — a bare relative path resolves differently at runtime than
on GitHub:

- plugin file from a `SKILL.md` → `${CLAUDE_PLUGIN_ROOT}/workflow/<file>.md`
- the skill's own bundled file → `${CLAUDE_SKILL_DIR}/<path>`
- the consuming repo's file → `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md`
- doc to doc inside the repo → plain relative, so GitHub renders it

## Conventions this repo applies to itself

- **The `work/` tree is live here**, dogfooding its own format: new ideas, noticed drift, and follow-ups become lines in [work/backlog.md](work/backlog.md) (tags and format defined at the top of the file) — not TODOs scattered in other files.
- **[GLOSSARY.md](GLOSSARY.md) is live here too**, near-empty by design — only terms no owning doc already defines; artifact terms (bundle, spec, ticket, backlog) stay owned by [workflow/artifacts.md](workflow/artifacts.md).
- **Decision records are immutable.** Supersede a `docs/decisions/` record with a new one; never edit it.
- **One copy.** Docs reference each other instead of restating. When adding material, link to the owning doc; if nothing owns it yet, decide where it belongs before writing.
- Read [docs/conventions/git.md](docs/conventions/git.md) before any git operation — it holds this repo's commit and PR conventions and the plain-git worktree rule. Settings the scripts read live in [work/config.conf](work/config.conf); [workflow/git-mechanics.md](workflow/git-mechanics.md) owns the procedures that consume both.

## Output style

- **Trim to what's needed** — cut filler, don't restate the question, don't summarize what was just done.
- **Use bullets, numbered lists, or headings** for anything with more than one part (steps, options, comparisons).
- Use a short paragraph only for a single point that doesn't decompose into list items.
- **Favor brevity** over polished grammar; fragments are fine.
