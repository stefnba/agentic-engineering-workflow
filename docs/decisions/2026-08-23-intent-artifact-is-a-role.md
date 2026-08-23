---
date: 2026-08-23
status: accepted
areas: [workflow, skills]
supersedes: the fixed heading set and the one-mandatory-file reading of
  [2026-08-10-the-feature-document-is-a-spec.md](./2026-08-10-the-feature-document-is-a-spec.md);
  its core — the document is named `spec.md` and holds external behavior, not internal design —
  stands
---

# The intent artifact is a role with ID families, not one file with a fixed heading set

## Context

0003 pinned `spec.md` to five headings (`Problem / Target state / Non-goals / Open questions /
Acceptance criteria`) as the stable anchors for ticket deep-links and gate checks, implying every
bundle carries that file. Shaping routes have since split — a direct ticket route with no spec, a
spike route with `spike.md` — and cross-referencing moved from heading anchors to requirement IDs.
This record writes down where the contract actually landed; the drift predates it.

## Decision

"Intent artifact" is a role, owned by `workflow/artifacts.md` § Intent artifact — feature spec, bug
statement, spike, or a single ticket carrying the complete intent for a small change. Where a route
produces a spec, the file is still `spec.md`.

- The section set is owned by `skills/shape/templates/spec.md`, richer than 0003's five headings
  and fixed so sections stay deep-linkable; the weight moves across intent flavors (feature, bug,
  refactor, migration, security), the sections don't.
- Cross-references from plans, tickets, and critique findings cite the five ID families — BR, BC,
  NG, INV, AC — stable once approved: append, never renumber.

## Rejected

- **0003's five headings as the anchor scheme**: `Target state`/`Non-goals` fit features but carry
  bug, refactor, migration, and security intent badly; and a heading rename silently breaks every
  deep link, where an ID survives restructuring.
- **A mandatory `spec.md` in every bundle**: forces a ceremony file onto the direct ticket route,
  whose ticket already carries the complete intent, and misnames what a spike produces.

## Costs

- The section set now lives in a template, not a decision record — the template can drift without
  a supersession tripping anyone.
- Prose and older records citing the five-heading set read as current unless the reader follows
  the supersession chain.
- Two reference schemes exist in history; pre-ID bundles in git archaeology don't resolve BR/AC
  citations.

## Revisit if

- Routes converge back to one artifact form — a single mandatory file would be simpler again.
- ID stability fails in practice — renumbering or ID reuse shows up in landed bundles.
