# 0002 Work items live in `work/` at the repo root

Date: 2026-08-10 · Status: accepted · Areas: docs, repo

## Context

`docs/work/` mixed the two lifetimes the documentation structure is built around: `docs/` accumulates durable, currently-true material, while everything under `work/` is disposable and in flight. The mix meant transient bundles sat inside a tree that publishes documentation sites and promises durability, and the durable/disposable split existed only as a convention readers had to remember.

## Decision

Work items live in `work/` at the repo root — `backlog.md`, `next-id`, `candidates/`, `planned/`, `active/`. `docs/` holds only durable material (`decisions/`, `research/`, `systems/`). The directory tree itself now expresses the lifetime split. The folder is visible, not dot-prefixed.

## Rejected

- **`docs/work/` (status quo)**: transient content inside the durable tree; the lifetime split invisible in the layout.
- **`.work/`**: `rg`, `fd`, and most search tools skip hidden directories by default — an agent's search silently missing every brief, spec, and ticket is precisely the failure class the layout exists to prevent. Hiddenness helps humans ignore the folder; agents are the primary consumers.
- **`.project/`**: same hiddenness problem, plus `.project` is Eclipse's project-metadata filename, and "project" is semantically empty — everything in the repo is the project.
- **Other names (`features/`, `wip/`, `tasks/`)**: each misdescribes the contents — `features/` excludes bugs and refactors, `wip/` misstates `planned/`, `tasks/` collides with ticket vocabulary. "Work" covers features, bugs, refactors, and migrations alike, which is why the folder was already called that.

## Costs

- One more visible entry at the repo root, in this repo and in every consuming repo.
- Every path reference in docs, skills, and hooks had to move once (`docs/work/…` → `work/…`), and external material written against the old layout is now stale.
- `docs/research/` pointers from `work/backlog.md` now cross trees and need the `docs/` prefix.

## Revisit if

- A monorepo consumer finds root-level `work/` contested; bundles already push down to `packages/<pkg>/work/`, so the pressure would be about the root tree only.
- Tooling defaults change such that hidden directories stop being search-invisible, removing the main argument against `.work/`.
