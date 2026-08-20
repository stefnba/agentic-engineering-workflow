---
status: accepted
date: 2026-08-10
areas: [docs]
---

# 0006 The record folder is `decisions/`, not `adr/`

## Context

Durable choices needed a home, and the industry default is `adr/` — Architecture Decision Records. But the decisions that go unrecorded are disproportionately the cross-cutting process and tooling ones (conventional commits, trunk-based development, vendoring over forking), which are exactly what a fresh agent context has no other way to discover — and none of them are architecture.

## Decision

The folder is `docs/decisions/` and holds any choice that is contested, consequential, and non-obvious from the code — architecture, tooling, process, or product alike. `areas:` frontmatter recovers any subset when filtering matters.

## Rejected

- **`adr/`**: the name's narrowness is genuinely load-bearing — it keeps the folder from becoming a junk drawer — but a folder whose name gatekeeps its own contents gets used less than it should, and it suppresses precisely the process records agents most need.
- **Splitting by kind** (`adr/` + `process/` + …): directories give one taxonomy axis and a second one always turns up; taxonomy belongs in a field.

## Costs

- The junk-drawer risk the ADR name prevented must now be held by discipline instead: the contested-consequential-non-obvious bar, and the norm that a handful of records a year is healthy while twenty means the bar slipped.

## Revisit if

- The folder trends toward a log nobody reads — that's the bar failing, and the fix is pruning standards, not renaming.
