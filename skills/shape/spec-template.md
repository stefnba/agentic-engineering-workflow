# Spec template

Copy the skeleton, fill every required section, delete the `<!-- -->` guidance as you go. Omit
optional sections entirely — no empty headings. No other sections, especially no "Further
Notes" catch-all. Headings never vary between specs so tickets and tooling can deep-link.

Rules that apply to the whole document:

- **Present tense.** Statements of how the system behaves, not future promises — the spec
  remains valid as living documentation after shipping.
- **The spec is the source of truth.** If implementation reveals it wrong, fix the spec first,
  then the code.
- **Every sentence constrains behavior or gets deleted.**
- **One name per concept.** Use the codebase's existing names for modules and domain terms —
  the project glossary, where one exists — never a synonym the code doesn't use: tickets and
  tests inherit the drift.
- **One feature per spec.** Behavioral Requirements that keep growing past a screenful are
  usually two features — split the bundle before writing tickets.
- **No file paths, no illustrative code.** Paths are short-lived and live in tickets. Two
  exceptions: (a) public contracts are exact, not prose — write out request/response shapes,
  schemas, event payloads, type signatures precisely; (b) a prototype snippet that encodes a
  decision better than prose (state machine, reducer, schema) may be inlined, trimmed to the
  decision-rich parts, marked as prototype-derived.

```markdown
# <YYYY-MM-DD-slug> — <Title>

## 1. Problem Statement

<!-- The user's problem, from the user's perspective. 2–4 sentences. No solution language. -->

## 2. Solution

<!-- What the user can now do. Strictly behavioral — no modules, architecture, or technology. -->

## 3. Behavioral Requirements

<!-- Numbered, testable statements about externally observable behavior. Direct declarative
sentences — no "As a user, I want..." wrappers. Merge near-duplicates; coverage is the goal,
length is not. Complete when it covers (where relevant): happy paths, error/failure behavior,
empty/zero/boundary states, permissions, concurrent or repeated actions, backward
compatibility. -->

BR-1: ...

<!-- Example:
BR-4: If the balance service is unreachable, the screen shows the last fetched balance
marked stale with its timestamp; if none exists, a retryable error state for that account only.
-->

## 4. Implementation Decisions

<!-- Numbered decisions, not a design narrative: modules built/modified, architecture, schema
changes, API contracts, flag mechanics if the change is flagged, directives that override the
conventions file ("reuse the existing PaymentClient; no new dependencies"). Performance and
security only if real, measurable requirements. Interior implementation stays open. -->

ID-1: ...

<!-- Example — a public contract, written exactly:
ID-2: `GET /v2/accounts/balances` → 200 `{ "accounts": [{ "accountId": string,
"balance": string /* decimal */, "currency": string /* ISO 4217 */, "asOf": string
/* RFC 3339 */, "stale": boolean }] }`. Balances are strings, never floats.
-->

## 5. Testing Decisions

Seam: <the observable boundary the acceptance tests attach to — confirmed with the human
during shaping>

<!-- Then: what makes a good test here (external behavior only, never implementation details);
which modules are tested at which level; prior art — existing tests in the codebase to imitate.
Ownership: acceptance tests are authored and locked before implementation; the implementing
agent must not modify them and writes its own unit tests, which the reviewer checks for
honesty. -->

## 6. Acceptance Criteria

<!-- Numbered Given/When/Then scenarios, each mapped to BR IDs; every BR covered by at least
one AC. If tests are locked as files, list them instead and state: done = all pass unmodified.
Green tests are necessary, not sufficient — human review remains a gate. -->

AC-1 (BR-1): Given ..., when ..., then ...

<!-- Example:
AC-3 (BR-4): Given the upstream errors and a prior fetch exists, when the screen loads,
then the prior balance is shown marked stale with its original timestamp.
-->

## 7. Out of Scope

<!-- Concrete prohibitions: features not to build, modules not to touch, refactors not to
attempt. "Do not modify the auth middleware" — not "stay focused." -->
```
