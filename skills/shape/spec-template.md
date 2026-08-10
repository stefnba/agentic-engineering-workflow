# Feature Spec — Structure Reference

Title line: `# <SPEC-ID> - <Title>` — ID from the tracker or repo convention, stable, and
referenced by tickets, PRs, and commits.

Specs are the durable core, written in present tense — statements of how the system behaves,
not future promises — so they remain valid as living documentation after shipping. Observable
behavior comes first (contracts, outcomes, what a caller can see), then only the internal
decisions that constrain the work: public interfaces, data models, patterns to follow.
Interior implementation stays open. The spec is the source of truth: if implementation
reveals it wrong, fix the spec first, then the code. Every sentence must constrain behavior
or be deleted. Sections appear in this order; omit optional sections entirely (no empty
headings). No other sections — especially no "Further Notes" catch-all.

## 1. Problem Statement (required)

The user's problem, from the user's perspective. 2–4 sentences. No solution language.

## 2. Solution (required)

What the user can now do. Strictly behavioral — no modules, architecture, or technology.

## 3. Behavioral Requirements (required)

Numbered, testable statements about externally observable behavior, IDs `BR-1...`.
Direct declarative sentences — no "As a user, I want..." wrappers. Merge near-duplicates;
coverage is the goal, length is not. Complete when it covers (where relevant): happy paths,
error/failure behavior, empty/zero/boundary states, permissions, concurrent or repeated
actions, backward compatibility.

> BR-4: If the balance service is unreachable, the screen shows the last fetched balance
> marked stale with its timestamp; if none exists, a retryable error state for that account only.

## 4. Implementation Decisions (required)

Numbered decisions (`ID-1...`), not a design narrative: modules built/modified, architecture,
schema changes, API contracts, directives that override the conventions file ("reuse the
existing PaymentClient; no new dependencies"). Performance/security only if real, measurable
requirements.

Code rules: no illustrative or implementation code, no file paths (paths go in ticket briefs).
Two exceptions: (a) **public contracts are exact, not prose** — write out request/response
shapes, schemas, event payloads, type signatures precisely; (b) a prototype snippet that
encodes a decision better than prose (state machine, reducer, schema) may be inlined, trimmed
to the decision-rich parts, marked as prototype-derived.

> ID-2: `GET /v2/accounts/balances` → 200 `{ "accounts": [{ "accountId": string,
"balance": string /* decimal */, "currency": string /* ISO 4217 */, "asOf": string
/* RFC 3339 */, "stale": boolean }] }`. Balances are strings, never floats.

## 5. Testing Decisions (required)

What makes a good test here (external behavior only, never implementation details); which
modules are tested at which level; prior art — existing tests in the codebase to imitate.
Ownership: acceptance tests are authored and locked before implementation; the implementing
agent must not modify them and writes its own unit tests, which the reviewer checks for honesty.

## 6. Acceptance Criteria (required — the definition of done)

Numbered Given/When/Then scenarios (`AC-1...`), each mapped to BR IDs; every BR covered by
at least one AC. If tests are locked as files, this section instead lists them and states:
done = all pass unmodified. Green tests are necessary, not sufficient — human review remains
a gate.

> AC-3 (BR-4): Given the upstream errors and a prior fetch exists, when the screen loads,
> then the prior balance is shown marked stale with its original timestamp.

## 7. Out of Scope (required)

Concrete prohibitions: features not to build, modules not to touch, refactors not to attempt.
"Do not modify the auth middleware" — not "stay focused."

## 8. Tickets (required before implementation)

Tickets live in `tickets/`, one file per ticket (`T-<n>-<slug>.md`), following the ticket
structure reference. This section keeps only an ordered index — `- T-1 — <title> (depends:
—)` — plus the coverage guarantee: every AC is covered by at least one ticket. Each ticket
is a vertical slice, independently testable, sized for one agent session. All ticket detail
(covered ACs, file paths, verification) lives in the ticket file, never here.

## 9. Rollout & Flags (optional)

Only if flagged/staged: flag name, default state, enable conditions, kill switch.

## 10. Open Questions (optional — plan-review workspace only)

During plan review, every line uses: `- [resolved] <question>? → <answer>`. Before
implementation starts, each resolved answer is folded into the section it constrains
(usually a BR or ID) and its line deleted — the section is empty or absent when an agent
receives the spec. Never hand an agent unresolved questions: it will resolve them itself,
silently and arbitrarily.
