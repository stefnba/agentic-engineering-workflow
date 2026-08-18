<!--
The engineering plan: how this repository realizes and decomposes the approved intent.

Copy it into the bundle as plan.md when the chosen route requires a plan — ${CLAUDE_PLUGIN_ROOT}/workflow/shaping-routes.md
owns which route that is and when to take it. A plan that would merely restate the tickets is not
worth writing.

Fill every retained section, delete these guidance comments as you go, and omit an optional section
entirely rather than leaving an empty heading.

The sections below are what this artifact owns; the Engineering plan section of
${CLAUDE_PLUGIN_ROOT}/workflow/bundle.md owns the split against intent and tickets. Two boundaries are
worth repeating because they are the ones plans cross: it cannot add behavior the approved intent
does not contain, and it is not file-by-file pseudocode.

Reference intent by ID (BR, BC, INV, NG, AC) rather than restating it. This plan's own decisions are
numbered PD-n and referenced the same way from tickets. Slice number = ticket number = the NN in the
ticket's file name. Numbers are stable once approved.

Before dispatching critique, check the bundle against the Shape-completion criteria in
${CLAUDE_PLUGIN_ROOT}/workflow/bundle.md. That check is the Architect's, and its result is not plan
content: nothing in this file attests that the bundle is ready.
-->

# <bundle-id> — Engineering Plan

## Repository evidence

<!-- Exact modules, tests, durable docs, decision records, existing patterns, and observed
constraints that ground the plan. Current-state facts live here, never in the target-state spec.
Every consequential claim is something you inspected, not something you remember. -->

- `<path>` — <fact or pattern that constrains the approach>

## Approach

<!-- Architecture, components, boundaries, data flow, persistence, validation, and failure handling
— enough that another agent can explain the solution and its failure modes without inventing a
missing decision. Name the existing extension points being used; prefer extending a pattern that
exists over introducing one. Explain the design; do not write the code. -->

<approach>

## Technical decisions

<!-- Consequential, bundle-local choices. State the reason and the alternatives that lost, so a
reader who disagrees can see whether their objection was weighed. A choice with no plausible
alternative is not a decision — leave it out. Use as many lines per decision as the alternatives
need; the one-line form below is a floor, not a shape.

Tag the ones that outlive this bundle as `(decision record at Ship)` so Ship does not have to
re-derive which they were.

Example:
PD-2 (decision record at Ship): Enforce the limit in middleware rather than in the login handler —
one enforcement point for every future auth route.
  Rejected: per-handler checks, which drift the moment a route is added.
  Rejected: gateway rate limiting, which cannot see the authenticated principal. -->

- PD-1: <decision> — <reason>
  - Rejected: <alternative and why>

## External prerequisites

<!-- Optional. Anything a slice depends on that this repository cannot produce: infrastructure in
another repo, a credential or role an operator must create, a vendor change, an approval. Name the
owner and what unblocks it — these are invisible to depends_on and to every check, and they are what
strands a ticket that otherwise looks claimable. Omit when the bundle is self-contained. -->

- <what must exist> — <who owns it> — <blocks slice NN>

## External references

<!-- Optional. The documentation outside this repository that the approach depends on: a library's
API reference, a framework migration guide, a protocol or vendor spec. Pin each to the version
actually in use and say what it was checked for — an approach grounded in the wrong major version is
wrong in a way no file in this repository reveals, and an implementer will otherwise resolve "the
docs" to whatever a search returns.

Link what the approach rests on, not everything the topic touches. Omit the section when the change
stays inside patterns this repository already contains.

The line against the spec's References: if violating the document makes the approved outcome wrong —
a protocol, an RFC, a partner's contract — it is binding intent and belongs in the spec. If ignoring
it only makes the approach worse while the behavior still comes out approved, it belongs here.

Example:
- Hono v4.6 middleware — https://hono.dev/docs/guides/middleware — `createMiddleware` typing; the v3
  `MiddlewareHandler` signature in older examples does not apply here -->

- <library or spec> <version in use> — <link> — <what it was checked for>

## Test approach

<!-- Repository-grounded, and distinct from the spec's Test intent, which owns the seam, the levels,
and the risk cases: this section owns what this repository makes of them. Prior art to imitate,
harness or fixture work a slice must build first, and which slice carries it.

Required when the approved outcome is "behavior unchanged" — Vertical slicing in
${CLAUDE_PLUGIN_ROOT}/workflow/bundle.md puts the characterization-test mandate on the plan, and this
is where it lands, naming the slice that pins current behavior before any slice changes it.
Otherwise optional: delete it when existing test infrastructure covers the change with no
preparation. -->

- <existing test to imitate, fixture to build, or slice that must land the harness first>

## Vertical slices

<!-- The complete decomposition of this bounded bundle: one row per slice, one slice per ticket.

- Intent refs: the BR, BC, INV, and AC IDs this slice satisfies. This table is the coverage map — the
  ticket's Delivers line repeats its own row, and the two must stay identical. A requirement every
  slice must satisfy ("behavior otherwise unchanged") belongs to the slice that verifies it, not
  parked on an arbitrary row.
- Produces: what this slice publishes that a later slice consumes — a module, a table, a role, a
  fixture, a flag. Dependency edges come from this column; a slice that consumes something no
  earlier row produces has a missing edge, and one that consumes nothing is genuinely parallel-safe.
- Hard dependencies: real blocking edges only, the same definition the ticket's depends_on uses.

Every row must be executable in one agent session. If you cannot tell that from the row, the slice is
too big — split it before the Plan gate. What makes a slice valid, when horizontal work is
admissible, and how refactors and migrations sequence are owned by Vertical slicing in
${CLAUDE_PLUGIN_ROOT}/workflow/bundle.md. -->

| Slice | Outcome            | Intent refs | Produces           | Hard dependencies |
| ----- | ------------------ | ----------- | ------------------ | ----------------- |
| 01    | <coherent outcome> | BR-1, AC-1  | <what 02+ consume> | none              |

## Parallelization

<!-- Optional. Which slices may run at the same time, and why their write surfaces do not collide —
shared modules, migrations, schemas, generated artifacts, and integration tests all have to be
considered, not just the dependency column. Absence of a dependency is not evidence of safety, and
Dependencies and parallelization in ${CLAUDE_PLUGIN_ROOT}/workflow/bundle.md owns the ceiling on how
wide a wave to shape. Omit the section when the work is sequential. -->

- <slices that may run together> — <why their write surfaces are compatible>

## Migration, rollout, and rollback

<!-- Optional, and the densest content in the plan: one row per stage the system actually passes
through. Trigger is what starts the stage — a merge, an operator action, a date, a metric. Reversal
is how that stage is undone, or "irreversible" plus what that costs. Proof is the signal that says
the stage worked, not that it was performed.

State supported intermediate states explicitly: every stage boundary is a state some request will be
served in. Omit the section when the change ships in one step. -->

| Stage | Slice | Trigger          | Reversal           | Proof signal           |
| ----- | ----- | ---------------- | ------------------ | ---------------------- |
| 1     | NN    | <what starts it> | <how it is undone> | <what shows it worked> |

## Reconciliation targets

<!-- Optional. The durable documentation, colocated READMEs, and glossary terms this bundle makes
stale, and which slice updates each. List only what a specific slice can fix inside its own PR;
knowledge that only becomes true once every ticket has landed is Ship's, per
${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md. Omit the section when no document goes wrong. -->

- `<path>` — <what changes> (slice NN)

## Risks

<!-- Concrete failure modes with a plausible path, not a hazard list. Say how the plan prevents each,
and how it is detected or recovered when prevention fails. A risk with no containment is a Plan-gate
question, not a table row. -->

| Risk           | Containment  | Detection or recovery |
| -------------- | ------------ | --------------------- |
| <failure mode> | <prevention> | <signal or rollback>  |
