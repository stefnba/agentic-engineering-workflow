---
status: accepted
date: 2026-08-10
areas: [docs, skills]
---

# 0012 Interview persists nothing; shape claims the bundle and is the sole author of intent

## Context

`interview` currently distills a conversation into `work/candidates/<id>-<slug>/brief.md`, frozen once `shape` writes `spec.md`, as the pre-decision record of what was asked. In practice this felt like ceremony rather than protection: the brief restates a conversation `shape` is about to read anyway, in the same session, seconds later. Trying the two skills as designed also surfaced a more natural model already proven elsewhere — mattpocock's `grilling` skill runs a relentless, round-based Q&A entirely in conversation and hands off to spec-writing with nothing written down first.

## Decision

`interview` writes nothing. It runs a single relentless Q&A against a design tree scoped to problem, constraints, and motivation: each round asks every question whose prerequisites are already settled (the frontier), numbered with a recommended answer, then waits; facts the repo can answer are looked up inline (`Read`/`Grep`/`Glob`) rather than asked of the human. `interview`'s tools shrink to `Read, Grep, Glob` — no `Write`, `Edit`, or `Bash` — so it is read-only by tool grant, not by convention. It exits when the frontier is empty and the human confirms shared understanding, and tells the human the next step is `shape`, invoked in the same session with no id and no path, because none exists yet.

`shape` becomes the sole point of persistence for this pair. Invoked with no argument, it starts from whatever is in front of it — a just-finished grilling session, a backlog line, or requirements stated directly in chat — derives a title, and calls `skills/shape/scripts/claim-bundle.sh` to allocate the id and create the bundle directory before writing `spec.md` and the tickets into it. For Discover's Pick gate, the human's decision to invoke `shape` _is_ the gate; for interview-sourced work there is no longer a repo artifact evidencing it, only the session.

## Rejected

- **Shape writes a frozen `brief.md` as its first act, before `spec.md`**: keeps the Pick-gate artifact and the one-creator-per-type framing intact, but reintroduces exactly the disk write the ergonomics complaint was about, one script call later — and duplicates `spec.md`'s own Problem Statement a section above it, for no reader who wasn't already in the conversation that produced both.
- **Full `grill-with-docs`** (grilling plus glossary/ADR side effects): descoped. This repo has no `CONTEXT.md`/glossary convention to hang glossary maintenance off of, and ADRs are already `docs/decisions/`, owned by the `decision` skill. A glossary home is tracked separately (`work/candidates/0002-glossary-home`); wiring interview into it is future work, not this decision.

## Costs

- No frozen "what was originally asked" checkpoint independent of what `shape` decided to build. Previously `brief.md` and `spec.md` were two documents a reviewer could diff; now there is one, authored in the same breath as the implementation calls, with nothing to catch a grilling session getting quietly bulldozed by an eager `shape`.
- A session that dies before `shape` claims a bundle loses the grilling entirely — not even a partial artifact survives. The general handoff-document mechanism (`agentic-workflow.md` § Sessions and handoffs) covers a session dying _mid-stage_; this is a session dying _before_ the stage boundary exists at all, which that mechanism doesn't address.
- The two bundles already in flight under the old contract (`work/candidates/0002-glossary-home`, `work/candidates/0004-implement-skill`) still carry `brief.md`. `shape` has to keep reading an existing `brief.md` when the human points at one, indefinitely, rather than assume its absence.

## Revisit if

- Sessions crashing before the Pick boundary becomes a real, recurring loss rather than a theoretical one — worth a lightweight scratch artifact then, though not necessarily `brief.md`'s contract.
- The lost frozen-intent record turns out to matter in practice — review repeatedly needs "what was originally asked" separate from "what shape decided," and `spec.md`'s Problem Statement can't answer that on its own.
