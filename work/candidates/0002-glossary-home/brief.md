# 0002 — Home for domain language / glossary

## Problem

`docs/docs-structure.md` defines a home for decisions, systems knowledge, and feature work, but has no location for shared domain vocabulary — the terms a team or codebase uses for its concepts. There's no established place to look up what a term means or to record one, and no rule for whether that vocabulary is a single shared list or split per domain.

## Constraints

- Must fit the existing durable/disposable split in `docs-structure.md` — a glossary is durable, not scoped to one feature or bundle.
- Must scale from a single repo to a monorepo. A monorepo with distinct domains (e.g. client/server) may need separate glossaries per domain rather than one global file — similar to how `work/` bundles already push down to `packages/<pkg>/work/` in monorepos.
- Primarily agent-facing — read before creating or editing docs/code, the same way the top of `docs-structure.md` is — but should also be usable by humans onboarding.

## Motivation

This is anticipatory, not a response to an actual misalignment incident yet. `docs-structure.md` is reused across different repos, and an explicit home for domain language closes the gap before it causes drift — agents (and people) landing on inconsistent terms for the same concept. Same motivation as the shared-vocabulary pattern in mattpocock/skills `CONTEXT.md`: fights misalignment by front-loading shared language.
