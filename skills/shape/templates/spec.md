<!--
The intent artifact: what the human approved, written so that two competent implementations may
differ inside and still be identical outside. Copy it into the bundle as spec.md on the "intent plus
tickets" and "intent, plan, and tickets" routes. The direct ticket route has no spec — its ticket
carries the approved intent instead; the investigation or spike route uses spike.md.

The section set does not change with the kind of work; the weight moves:
| Intent flavor | Carries the weight                                                                    |
| ------------- | ------------------------------------------------------------------------------------- |
| feature       | BR and AC; Non-goals does the most work against over-building                         |
| bug           | Problem states the reproduction; BR states corrected behavior; INV what must not regress |
| refactor      | Outcome is the target architecture; BR is often "behavior unchanged"; INV pins what may not move |
| migration     | Outcome is the migration objective; BC holds the downtime and compatibility window; INV holds data integrity across every intermediate state |
| security      | BR is enforcement behavior; INV is the isolation property; Test intent names the negative and authorization cases |

Five ID families, referenced by plan slices, tickets, acceptance criteria, and critique findings:
  BR  behavioral requirement    BC  binding constraint    NG  non-goal
  INV invariant                 AC  acceptance criterion
Numbers are stable once approved: append, never renumber.

Fill every retained section, delete these guidance comments as you go, and omit an optional section
entirely rather than leaving an empty heading. Section names stay fixed so tickets, plans, and
critique can deep-link them.

The sections below are what this artifact owns. It does not own current repository facts, file
paths, ticket order, status, or interior implementation choices — see the Intent/spec section of
${CLAUDE_PLUGIN_ROOT}/workflow/bundle.md for the full split, and ${CLAUDE_PLUGIN_ROOT}/workflow/artifacts.md
for what happens to this file at Land.

Write target behavior in present tense; the spec describes the system as it will behave, not a
promise about future work. Every sentence constrains behavior or gets deleted. Use the repository's
existing names — the GLOSSARY.md of each domain the change touches, including its Avoid list — never
a synonym the code does not use.
-->

# <bundle-id> — <Title>

## Problem

<!-- The problem from the perspective of whoever has it, in 2–4 sentences: what breaks or is missing
today, who it affects, and what it costs. No proposed solution — naming the module or endpoint that
is the problem is fine and often unavoidable.

For a bug, this is the reproduction: what is done, what happens, what should happen instead. -->

<problem>

## Outcome

<!-- One paragraph. What is observably true once this bundle lands that is not true now — from
outside the system, in the user's or caller's terms. This is what lets an agent make an aligned
judgment call in a place the spec is silent, so state the intent, not the mechanism.

For a refactor or migration, the outcome is the target state itself: the architecture, the storage,
or the dependency that is in place afterwards, plus what stays observably unchanged. -->

<outcome>

## Scope

**In scope:**

- <capability or behavior change>

**Non-goals — do not build:**

<!-- The highest-value section in the spec: agents over-build without it. Each line is a concrete
prohibition with the reason, not a mood. Name the adjacent thing, not "stay focused". Number them so
a ticket can exclude work by ID instead of re-typing the prose.

Include the boundary of a sequential split here: what a later bundle deliberately owns, so tickets
in this one do not drift into it. -->

- NG-1: <adjacent capability agents tend to add> — <why it is out; where it lands instead>

## Behavior

<!-- Numbered, independently testable statements about externally observable behavior, in present
tense and direct declarative form — no "as a user, I want" wrappers.

One testable claim per BR: an "and" joining two observable behaviors is two BRs, and a BR you cannot
write a single AC against is already two. Branches of one condition stay in one BR. Merge
near-duplicates rather than accumulating them.

A BR binds what the system does. A property that must also hold on paths the system never takes is
an invariant, not a BR.

Complete when it covers, where relevant: happy path, failure and degraded behavior, empty, zero and
boundary states, permissions, repeated and concurrent actions, and backward compatibility.

There is no separate edge-case section, on purpose: an edge case with defined behavior is a BR like
any other and gets its own AC; one deliberately left undefined is an NG; one that needs coverage but
no new behavior is a risk case under Test intent. A table of edge cases outside this section is a
second place behavior lives, and a reviewer cannot tell whether its rows bind.

Example:
BR-4: When the balance service is unreachable, the screen shows the last fetched balance marked
stale with its timestamp; with no prior fetch it shows a retryable error state for that account
only. -->

- BR-1: <observable behavior>

## Public contracts

<!-- Optional. What another party is committed to, written exactly: HTTP request and response bodies,
schemas, event payloads, CLI surface, error codes, type signatures. Reference the BR each contract
realizes. Omit the section when the change adds no external contract.

Prefer the literal shape. A contract that is a negative or cross-response property — "a cross-tenant
read is indistinguishable from a genuine 404, including timing and error body" — cannot be drawn as a
shape; state it as precisely as prose allows and keep it here rather than losing it.

Example:
GET /v2/accounts/balances (BR-2) → 200
{ "accounts": [{ "accountId": string, "balance": string /* decimal */, "currency": string /* ISO
4217 */, "asOf": string /* RFC 3339 */, "stale": boolean }] }
Balances are strings, never floats. -->

- <contract> (BR-n)

## Binding constraints

<!-- Numbered constraints every implementation must honor whatever approach it takes, and the home
for every checkable number in this spec: performance and resource limits, compatibility windows,
security requirements, mandated reuse ("go through the existing PaymentClient; add no new
dependency"), data-model or migration limits, modules that are off-limits.

Only genuinely binding, checkable constraints belong here. A preference is not a constraint, and
interior implementation stays open — a constraint that dictates the interior belongs in plan.md as a
technical decision, or nowhere.

Example:
BC-2: Balance reads stay under 200 ms at p95 measured at the API boundary. -->

- BC-1: <constraint an implementation may not cross>

## Invariants

<!-- Optional but rarely absent for refactors, migrations, and security work. What must hold before,
during, and after the change — including every intermediate state a staged rollout passes through.

The line against Behavior: a BR binds what the application does, an INV binds what any path can do,
including queries and callers the application never issues. An invariant is violated by a bug, not by
a design choice.

Example:
INV-1: An order has exactly one payment record at every point of the migration, including between
dual-write and backfill. -->

- INV-1: <property that must always hold>

## Acceptance criteria

<!-- Numbered Given/When/Then scenarios, each mapping to the IDs it proves. Every BR and every INV is
covered by at least one AC, and so is every BC whose violation is silent — an unenforced limit, an
isolation setting, a forbidden dependency. An AC that maps to nothing means an unstated requirement.

One AC is proved by one slice. If two tickets would each satisfy half of an AC, the AC is two ACs or
the slicing is wrong; fix it here rather than writing "the worker half" into a ticket.

Each must be verifiable by observing the system, not by reading the diff. Green tests are evidence,
not acceptance — the human gate is owned by ${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md.

Example:
AC-3 (BR-4): Given the upstream errors and a prior fetch exists, when the screen loads, then the
prior balance is shown marked stale with its original timestamp. -->

- AC-1 (BR-1): Given <state>, when <action>, then <observable result>.

## Test intent

<!-- What Shape owns about testing — test ownership across roles is defined in
${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md; state here only what is specific to this bundle. Not test
code, and not the repository's canonical checks, which stay canonical in CI.

- Seam: the observable boundary the acceptance tests attach to. Prefer one that already exists, and
  place it as high as the property allows: for behavior, the highest boundary that observes it; for
  an invariant that must hold on paths the application never takes, the seam sits below the
  application — an API-level test can only prove the queries the application happens to issue. List
  more than one only when two properties genuinely need different boundaries.
- Levels: which behavior is proven at which level, and why that level is the honest one.
- Risk cases: the failure, boundary, permission, concurrency, and compatibility cases that must be
  tested because they are where this change is dangerous.
- Locked tests: the scope of any test authored outside the implementing agent. lifecycle.md owns when
  that exception is admissible and who may run or modify them. Write "none" when it does not apply.

When the outcome is "behavior unchanged", the characterization-test mandate belongs to the plan —
see Vertical slicing in ${CLAUDE_PLUGIN_ROOT}/workflow/bundle.md. State the outcome here; do not
restate the mandate. -->

- Seam: <observable boundary the acceptance tests attach to>
- Levels: <what is proven where>
- Risk cases: <cases that must be covered>
- Locked tests: <scope, or none>

## Rollout and compatibility

<!-- Optional, and only the shape of the rollout as approved: what must ship behind a gate, what must
be reversible, what data must survive, what order the world sees changes in. Every checkable number
— window length, downtime budget, supported versions — is a BC, not a line here.

The mechanics that satisfy it — dual-write, backfill order, flag wiring, rollback steps — belong in
plan.md. Omit the section when the change ships in one step with nothing gated. -->

- <rollout property the implementation must satisfy>

## References

<!-- Optional, and only what binds the approved outcome: standing decision records this spec must not
re-litigate, durable research, related durable system docs, and external specifications the behavior
must conform to (a protocol, an RFC, a partner's contract). Links only, no summaries — and never a
link to another bundle, which Land will delete.

Documentation that merely informs how the work gets built — a library's API reference, a framework's
migration guide — is not a constraint on the outcome. It belongs in the plan's External references,
or in a ticket's Implementation notes. -->

- <link> — <why it constrains this bundle>

## Open questions

<!-- Draft only. Every material question is resolved before the human Plan gate: fold the answer into
the section it constrains, then delete this section. A surviving open question blocks approval.

A bounded local choice is not an open question — write it as explicit discretion under the ticket's
Autonomy boundaries, with the bounds it may not cross. What may never be delegated is owned by
${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md. -->

- [ ] <question that needs a human decision>
