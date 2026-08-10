# 0003 The feature document is `spec.md`, not `design.md`

Date: 2026-08-10 · Status: accepted · Areas: docs, skills

## Context

The feature document was named `design.md`, but its content rules were always spec-shaped: target state as observable behavior, non-goals, acceptance criteria, "say what and why, not how," and a standing anti-pattern against pseudocode-level detail. A spec describes external behavior — what the change must do, observable from outside — while a design doc describes internal structure. The name promised content the document deliberately refuses to hold, and docs-structure.md had banned the word "spec" only because industry usage is sloppy, not because the concept was wrong.

## Decision

The document is `spec.md`. "Spec" is defined in docs-structure.md and means: the external behavior the change must exhibit (contracts, observable outcomes, acceptance criteria) plus only the internal decisions that constrain it (public interfaces, data models, patterns to follow) — interior implementation deliberately open. The heading set is unchanged (`Problem / Target state / Non-goals / Open questions / Acceptance criteria`): stable anchors are load-bearing for ticket deep-links and gate checks, and "Target state" keeps the present-tense rationale. In prose it is "the spec".

## Rejected

- **Keeping `design.md`**: the name invites exactly the internal-structure content the rules prohibit, and alternatives-considered already lives in `decisions/`, sequencing in `plan.md` — the ecosystem routes design-heavy content elsewhere on purpose.
- **`feature-spec.md` / `technical-spec.md`**: the qualifier adds nothing inside a bundle that is already one feature.
- **Restructuring headings around the spec/design split** (e.g. a `Behavior` section): breaks every deep link, gate grep, and skill that anchors on the fixed heading set, for a distinction the section guidance can carry.
- **Continuing to avoid the word "spec"**: the objection was undefined usage; a definition in the conventions file is the cure, not abstinence.

## Costs

- "Spec" remains overloaded outside this repo; the definition holds only as long as review enforces it and shaped specs actually stay behavior-first.
- The avoided-terms rule reversed itself; readers of older commits will find the ban and the adoption in the same file's history.
- Every doc, skill, and agent prompt referencing `design.md` had to change at once, and the research/audit files intentionally still carry the old name as historical evidence.

## Revisit if

- Shaped specs drift into implementation detail anyway — then the name isn't the lever, the critic and review checklists are.
- Consumers confuse `spec.md` with API-spec artifacts (OpenAPI et al.) often enough that the qualifier earns its keep.
