---
Status: Draft | Approved | In Progress | Done
---

# Spec: <Feature Name>

<!--
Location: work/shaped/<bundle-id>/spec.md, then work/active/<bundle-id>/spec.md.
Audience: an agent (or engineer) with ZERO prior context and no ability to ask questions.
Rule of thumb: if a detail lives only in your head or in Slack, it doesn't exist. Write it down.
Lifecycle: this spec lives only for the bundle. At ship, absorb still-relevant knowledge into
durable system documentation and decision records, then delete the entire bundle.
-->

## 1. Goal

<!-- 1 short paragraph. What are we building and why. This lets the agent make
     judgment calls aligned with intent when the spec is silent. -->

## 2. Scope

**In scope:**

- <capability 1>
- <capability 2>

**Non-goals (do NOT build):**

<!-- explicitly what NOT to build; agents over-build without this -->

- <adjacent thing agents tend to over-build> — <why it's out>
- <thing deferred to v2>

## 3. Current State

<!-- Save the agent from rediscovering the codebase. Be concrete. -->

- Relevant entry points: `src/api/routes.ts`, `src/services/auth/`
- How it works today: <2–4 sentences>
- Known quirks / landmines: <e.g. "sessions table has legacy rows with null user_id">

## 4. Desired Behavior

<!-- Concrete examples beat prose. Cover happy path, errors, and edges. -->

### Example 1 — happy path

- Input / action: <...>
- Expected output / state: <...>

### Example 2 — error case

- Input / action: <...>
- Expected output: <exact error message / status code>

### Edge cases

| Case                | Expected behavior |
| ------------------- | ----------------- |
| <empty input>       | <...>             |
| <duplicate request> | <...>             |
| <boundary value>    | <...>             |

## 5. Technical Constraints

- **Follow existing patterns:** <e.g. "repository pattern as in src/repos/">
- **Use:** <libraries/versions already in the project — don't introduce new deps>
- **Do NOT touch:** <files/modules that are off-limits, e.g. migrations/, vendor/>
- **Performance / security:** <e.g. "p95 < 200ms", "input must be parameterized SQL">
- **Data model changes:** <allowed? migration strategy?>

## 6. Acceptance Criteria

<!-- Every item must be verifiable, ideally by a command. -->

- [ ] <behavioral criterion, Given/When/Then or checklist>
- [ ] <negative case: what must NOT happen>
- [ ] All new logic covered by tests in `tests/<area>/`
- [ ] `npm test && npm run lint && npm run build` all pass

**Verification commands:**

```bash
npm test -- --filter <feature>
npm run lint
npm run build
```

## 7. Open Questions (draft only)

<!--
Every material question must be resolved before human approval. Fold the answer into the section
it constrains, then delete this section.

A local implementation choice may be delegated only in the plan or ticket as bounded discretion:
state what the agent may choose and the constraints it may not cross. Never delegate a choice that
reaches a Plan-gate boundary, as the workflow's Lifecycle defines them, or that settles cross-ticket
architecture.
-->

- [ ] <question requiring a human decision>

---

Draft 2

# Feature: <Name>

## Problem

What problem are we solving?
Who has the problem?
Why does it matter?

## Goal

What outcome should exist when this feature is complete?

## Non-goals

Explicitly state what this feature will NOT do.

## User / System Behavior

Describe the desired behavior from the outside.

### Scenario: <name>

Given ...
When ...
Then ...

## Functional Requirements

- FR-001: ...
- FR-002: ...
- FR-003: ...

## Technical Requirements

- TR-001: ...
- TR-002: ...

Include important architectural constraints here:

- APIs
- data model
- security
- performance
- compatibility
- dependencies
- observability

## UX / API Contract

If applicable, define:

- screens
- API endpoints
- request/response shapes
- error behavior
- state transitions

## Invariants

Things that must ALWAYS be true.

- ...
- ...

## Acceptance Criteria

The feature is complete when:

- ...
- ...
- ...

## Edge Cases

- ...
- ...

## Open Questions (draft only)

- Every material question is resolved before approval, then this section is deleted.
- A bounded local implementation choice is written as explicit agent discretion in the plan or
  ticket, not left as an open question.

## Decisions

### YYYY-MM-DD — <decision>

Decision: ...
Reason: ...
Alternatives considered: ...

## Rollout / Migration

If applicable:

- migration strategy
- feature flags
- backwards compatibility
- rollback

## References

- Architecture docs
- Related specs
- External documentation

Give

```markdown
## Technical constraints

Order creation must go through the existing persistence abstraction.
Do not introduce a second persistence mechanism.
```
