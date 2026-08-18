<!--
Use this template only when technical direction or decomposition is non-obvious. Copy it into the
bundle as plan.md, fill every retained section, and delete guidance comments. Omit optional sections.
The plan cannot add behavior absent from approved intent.
-->

# <bundle-id> — Engineering Plan

## Repository Evidence

<!-- Exact modules, tests, durable docs, decisions, existing patterns, and observed constraints that
ground the plan. Record current-state facts here rather than in the target-state spec. -->

- `<path>` — <fact or pattern that constrains the approach>

## Approach

<!-- Architecture, components, boundaries, data flow, persistence, validation, and failure handling
needed to understand the solution. Explain the design; do not write file-by-file pseudocode. -->

<approach>

## Technical Decisions

<!-- Number consequential bundle-local choices. State why and the meaningful rejected alternative.
Move durable, expensive-to-relitigate choices into a decision record at Ship. -->

- PD-1: <decision> — <reason>; rejected: <alternative and why>

## Vertical Slices

<!-- Complete decomposition for this bounded bundle. Each slice produces one observable or
independently verifiable outcome and maps to one ticket. Horizontal enabling work must name
the later slice it enables and its independent evidence. -->

| Slice | Outcome            | Intent refs | Hard dependencies |
| ----- | ------------------ | ----------- | ----------------- |
| 01    | <coherent outcome> | BR-1, AC-1  | none              |

## Parallelization

<!-- State only safe concurrency after considering shared modules, migrations, schemas, generated
artifacts, and integration tests. Omit when all work is sequential. -->

- <tickets that may run together and why their write surfaces are compatible>

## Migration, Rollout, and Rollback

<!-- Technical sequence, supported intermediate states, backfill/dual-write mechanics, observability,
and rollback. Omit when not applicable. -->

- <step or mechanism>

## Risks

<!-- Concrete failure mode, likelihood/impact where useful, prevention, detection, and recovery. -->

| Risk           | Containment  | Detection or recovery |
| -------------- | ------------ | --------------------- |
| <failure mode> | <prevention> | <signal or rollback>  |

## Plan Validation

<!-- The Architect completes this before Critique. If any line cannot be satisfied, split or revise
the bundle before the Plan gate. -->

- Every approved requirement/invariant maps to a slice.
- Every slice maps to exactly one ticket executable in one session with concrete done-when evidence.
- No later slice depends on an unvalidated assumption that requires a separate bundle.
- Dependencies and parallel claims reflect real execution constraints.
