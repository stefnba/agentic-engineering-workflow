---
status: accepted
date: 2026-08-10
areas: [docs]
---

# 0004 Bundle status lives in the directory; ticket status in frontmatter

## Context

Work items exist at two granularities — multi-file bundles moving through `candidates/ → planned/ → active/`, and single-file tickets flipping `todo → doing → done` — and a frontmatter-query script (`scripts/find-by-frontmatter.*`) made it tempting to unify both on frontmatter, or on a central manifest. The question was re-examined from first principles, not from the existing guidelines.

## Decision

Status follows unit granularity. A **bundle's** status is its parent directory — the directory is the only thing that _is_ the whole multi-file unit, a `git mv` is an atomic, diff-visible transition, and `ls` answers every listing query with zero tooling. A **ticket's** status is its frontmatter — tickets live inside the bundle and must not move. One status owner per level, a different owner per level.

## Rejected

- **Frontmatter status for bundles**: the carrier problem — a bundle has no single canonical file (brief-only early, spec later), so the status-bearing file would change over the lifecycle or require a dedicated meta file. And frontmatter's headline benefit, stable paths, is neutralized here: bundles are deleted at ship, so no work-item path is durable in any scheme and references must be ID-based regardless.
- **A JSON/YAML manifest indexing all items**: a second copy of every status plus a merge hotspot on every concurrent transition — a hand-maintained derived view that goes stale invisibly.
- **Directories for tickets**: constant path churn inside the bundle for a value that changes three times per file.

## Costs

- Bundle paths break on every status move; the mitigation (reference by ID, resolve by `ls work/*/<id>-*`, never assume status from an earlier session, `git mv` for `--follow`) is permanent overhead baked into docs and skills.
- Listing by anything other than status (area, owner, age) has no directory answer; the frontmatter script only covers tickets.
- Two mechanisms to teach instead of one.

## Revisit if

- Bundles stop being deleted at ship — durable paths would revive frontmatter's strongest argument, and the call was close on first-principles grounds.
- Multi-axis queries over bundles become routine; though past ~20 active bundles the documented answer is GitHub issues, not a richer file scheme.
