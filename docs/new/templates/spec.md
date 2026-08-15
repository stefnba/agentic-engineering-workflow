---
Status: Draft | Approved | In Progress | Done
---

# Spec: <Feature Name>

<!--
Location: keep this file in-repo, e.g. specs/<feature-slug>.md
Audience: an agent (or engineer) with ZERO prior context and no ability to ask questions.
Rule of thumb: if a detail lives only in your head or in Slack, it doesn't exist. Write it down.
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

## 7. Ticket Breakdown

<!-- Ordered, each one a mergeable unit. Mark parallelizable work. -->

| #   | Ticket               | Depends on | Parallel-safe |
| --- | -------------------- | ---------- | ------------- |
| 1   | <schema/migration>   | —          | no            |
| 2   | <core service logic> | 1          | no            |
| 3   | <API endpoint>       | 2          | yes (with 4)  |
| 4   | <UI wiring>          | 2          | yes (with 3)  |

## 8. Open Questions

<!-- Resolve before handoff, or explicitly delegate. Don't leave silent ambiguity. -->

- [ ] <question> — **Decision:** <answer, or "agent's discretion, prefer X">
