---
status: accepted
date: 2026-08-10
areas: [docs]
---

# 0009 Durable system docs live next to their code, not in a central tree

## Context

A subsystem's target-state documentation needs a home where it stays accurate. Central `docs/` trees are discoverable and don't collide with package READMEs, and most repos default to them.

## Decision

Target state for a subsystem lives in a colocated `README.md` (`src/billing/README.md`). Proximity is the only mechanism that reliably prevents staleness: a PR touching the code shows the README in the same diff, so a reviewer sees the mismatch — and the doc dies correctly when its directory is deleted. Only genuinely cross-cutting concerns (auth, data flow, deployment) go to `docs/systems/`, whose README is an index of links, never content.

## Rejected

- **Central `docs/systems/` for everything**: discoverable, but invisible in exactly the review where it goes stale — a central doc is never in the diff of the change that falsifies it.
- **Published-package conflict workaround in one file**: where a `README.md` must be install-and-usage for consumers, target state goes to `ARCHITECTURE.md` beside it rather than cramming two genres into one file.

## Costs

- System knowledge is scattered across the tree; there is no single place to read the whole architecture — the `docs/systems/README.md` index is a partial mitigation that must be maintained.
- Two features touching the same subsystem concurrently both edit one README; the resulting merge conflict is deliberate (incompatibility surfaces instead of shipping silently) but still a conflict someone resolves.

## Revisit if

- Tooling emerges that reliably surfaces central-doc staleness in code review — proximity's monopoly on freshness is the entire argument.
