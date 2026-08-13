# AGENTS.md

Orientation for agents working on this repo. Only orientation lives here — the conventions themselves live in `docs/`. Read the owning doc before acting; don't work from a summary of it.

## Reference repo, not consuming repo

This repo collects agentic-coding practices — workflow design, documentation structure, reusable skills — for _other_ repos to install (see [README.md](README.md)). Docs and skills therefore describe a consuming repo's layout: workspace packages, CI gates, colocated `src/<domain>/README.md` files. None of that exists in this tree. Treat a referenced path that doesn't resolve here as intentional — leave it as written; note real drift in [work/backlog.md](work/backlog.md).

## Conventions this repo applies to itself

- **The `work/` tree is live here**, dogfooding its own format: new ideas, noticed drift, and follow-ups become lines in [work/backlog.md](work/backlog.md) (tags and format defined at the top of the file) — not TODOs scattered in other files.
- **[GLOSSARY.md](GLOSSARY.md) is live here too**, near-empty by design — only terms no owning doc already defines; artifact terms (bundle, spec, ticket, backlog) stay owned by [docs/agentic-workflow.md](docs/agentic-workflow.md).
- **Decision records are immutable.** Supersede a `docs/decisions/` record with a new one; never edit it.
- **One copy.** Docs reference each other instead of restating. When adding material, link to the owning doc; if nothing owns it yet, decide where it belongs before writing.

## Output style

- **Trim to what's needed** — cut filler, don't restate the question, don't summarize what was just done.
- **Use bullets, numbered lists, or headings** for anything with more than one part (steps, options, comparisons).
- Use a short paragraph only for a single point that doesn't decompose into list items.
- **Favor brevity** over polished grammar; fragments are fine.
