---
status: accepted
date: 2026-08-10
areas: [docs]
---

# 0007 Tickets are files in the repo, not GitHub issues

## Context

Tickets need storage, claiming, and linkage to the spec. GitHub issues offer atomic assignment and querying; files offer colocation and zero infrastructure. The workflow targets solo-to-small scale with one to three concurrent agents.

## Decision

Tickets are markdown files in the bundle (`tickets/NN-*.md`), with `status` frontmatter and push-conflict claiming. At this scale the API roundtrip is pure overhead, and colocation means the ticket and the code it produced land in one diff — the reviewer sees both or neither.

## Rejected

- **GitHub issues**: atomic claims and real querying, but the workflow would trade same-diff colocation and version history for machinery it doesn't need below ~3 concurrent agents.
- **Issues-only for all work tracking** (no files at all): loses version history and greppability of the work artifacts themselves.
- **No tickets** (spec + PRs directly): loses the decomposition review gate — the step that catches bad slicing while it's still cheap, which matters *more* with agents, which slice badly.

## Costs

- Claiming is not a real lock — two agents on different tickets can still conflict in code, and beyond a few agents the push-conflict protocol degrades.
- No query/filter beyond `grep` and the frontmatter script.

## Revisit if

The switch condition is explicit: more than ~3 concurrent agents, multiple teams sharing the ID space, or collaborators who don't clone the repo. Migration is cheap by construction — ticket files are already shaped like issue bodies.
