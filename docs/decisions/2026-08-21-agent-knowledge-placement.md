---
date: 2026-08-21
status: accepted
areas: [workflow, skills]
supersedes:
  the "contract → `workflow/`" line of
  [2026-08-18-consuming-repo-layout.md](./2026-08-18-consuming-repo-layout.md)'s Consequences block,
  for documents an agent needs on every invocation
---

# Knowledge every agent invocation needs is a preloaded skill, not a `workflow/` doc

## Context

`workflow/` held every contract document and agents reached them by path at the step that needed
them. Two costs compounded: a forked agent re-read the same document every round — `reviewer` cited
`finding-protocol.md` three times per review — and the read depended on the agent choosing to follow
the pointer. The `skills:` field loads a skill's body into a forked agent's system prompt before its
first action.

## Decision

A document an agent needs on every invocation lives in `skills/<name>/SKILL.md` and arrives by
preload. One that only some runs need stays in `workflow/`, read at its branch.

- `workflow/finding-protocol.md` → `skills/finding-rules/SKILL.md`; `critic` and `reviewer` carry
  `skills: [finding-rules]`.
- Preloading moves a document; `workflow/` keeps no second copy.
- Only a forked agent preloads. `implement` is inline, so it reads the same file.
- `workflow/components.md` owns the rule; `AGENTS.md` names the exception.

## Rejected

- Leave it in `workflow/`, read by path: a round trip per round, and it depends on the agent
  following the pointer.
- A skill that restates or points at the `workflow/` doc: restating drifts within a few edits (the
  prior `docs-rules` skill); pointing preloads a pointer, not content.
- "Agents thin, skills fat" wholesale: holds for inline skills, but a forked skill's body is the
  fork's task prompt, so moving content there relocates the cost.

## Costs

- Contract material now lives in the payload directory; `workflow/` is no longer the whole contract.
- A preloaded skill's description sits in every session's routing index whether or not a review runs.
- The always/sometimes line is a judgment call; material that drifts across it needs a move, not an
  edit.
- `skills:` preloading is unverified here — no run has exercised it.
