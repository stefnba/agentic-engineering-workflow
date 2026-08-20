# Shaping routes

A **shaping route** is the lightest path through Discover and Shape that still makes implementation
reliable: which artifacts one picked outcome needs, and when to split it into sequential bundles.
This document is the single owner of both; no other document keeps a second route table or split
trigger list.

Choosing a lighter route never changes the five lifecycle stages in [Lifecycle](./lifecycle.md) —
see [Non-negotiable boundaries](#non-negotiable-boundaries) below for what a route may never remove.

There are five routes. Use these names verbatim — in prose, in an Architect's route statement, and in
any document that refers to a route:

- **Direct ticket**
- **Investigation or spike**
- **Intent plus tickets**
- **Intent, plan, and tickets**
- **Sequential bundles**

"Intent" is the intent artifact role defined in [Artifacts](./artifacts.md), usually `spec.md` — not
one mandatory filename.

## Decision framework

Classify the work by uncertainty and impact, then increase rigor when coordination is high.

|                 | Low uncertainty                                                   | High uncertainty                                       |
| --------------- | ----------------------------------------------------------------- | ------------------------------------------------------ |
| **Low impact**  | direct ticket                                                     | investigation or spike, then a direct ticket           |
| **High impact** | intent plus tickets; add a plan when decomposition is non-obvious | investigation or spike, then intent, plan, and tickets |

Coordination is a multiplier. Cross-service changes, shared schemas, migrations, several parallel
agents, or multiple rollout steps usually require a plan even when the desired behavior is clear.

Ask in order:

1. **Is the problem understood?** If not, Discover through reproduction, investigation, or a spike.
2. **Is the approved outcome obvious and bounded?** If not, write an intent artifact.
3. **Is the repository-grounded approach and decomposition obvious?** If not, write a plan.
4. **Can every ticket carry concrete done-when evidence now?** If not, split into sequential bundles.

No artifact is mandatory by name. Each artifact must remove a named uncertainty or establish an
execution boundary.

## Routes

### Direct ticket

Use when one agent can safely understand, implement, verify, and review the complete outcome in one
PR without a separate design decision.

Typical examples:

- low-risk configuration change
- small dependency update
- known bug with reproducible expected behavior
- narrow UI or API adjustment

The ticket contains complete intent: outcome, scope, constraints, evidence, and escalation triggers.

### Investigation or spike

Use when diagnosis or feasibility is unknown. The deliverable is evidence and a decision, not
production code disguised as exploration.

Typical examples:

- intermittent production failure
- unexplained performance regression
- unfamiliar legacy behavior
- “would technology X work here?”
- operational tuning whose safe value is unknown

A successful result may be “do not proceed.” If implementation is warranted, the human picks that
result before Shape creates a bundle.

The intent artifact for this route states the open question, the evidence that settles it, the time
box, and the decision the answer feeds — see
[`skills/shape/templates/spike.md`](../skills/shape/templates/spike.md).

### Intent plus tickets

Use when observable behavior or binding constraints need approval, but the technical approach and
decomposition are straightforward from repository patterns.

Typical examples:

- small user-facing feature
- contained API addition
- bug that changes documented behavior
- security rule with one clear enforcement point

Do not manufacture a plan when it would merely repeat the tickets.

### Intent, plan, and tickets

Use when impact, architecture, sequencing, migration, rollout, or coordination makes decomposition a
real design problem.

Typical examples:

- cross-service feature
- authorization or tenant-isolation change
- database migration with compatibility period
- large refactor with expand → migrate → contract steps
- major dependency upgrade with breaking changes
- parallel implementation across several slices

The plan is grounded in repository evidence and decomposes intent into vertical slices. It cannot
invent new behavior.

### Sequential bundles

Use for initiatives too large or uncertain to shape honestly as one executable ticket set. Approve a
coherent first outcome, implement and land it, then shape the next bundle using what was learned.

Split rather than speculate when:

- later tickets depend on an unvalidated architectural assumption
- exact verification for later tickets cannot yet be stated
- the work contains multiple independently useful outcomes
- the dependency graph is dominated by speculative edges
- one Plan gate cannot meaningfully approve the whole dependency graph
- integration drift would dominate before the bundle lands

Do not use sequential bundles to evade complete shaping. Every individual bundle still has its full
ticket set and its own Plan gate before implementation.

## Work-type guidance

| Work type          | Default route             | Increase rigor when                                                |
| ------------------ | ------------------------- | ------------------------------------------------------------------ |
| Small feature      | intent plus tickets       | public contract, permissions, or rollout is non-trivial            |
| Large feature      | intent, plan, and tickets | later slices are speculative — split into sequential bundles       |
| Known bug          | direct ticket             | diagnosis is uncertain or behavior change is contested             |
| Complex bug        | investigation or spike    | root cause crosses services or requires migration                  |
| Refactor           | intent, plan, and tickets | callers require staged compatibility or rollback                   |
| Dependency upgrade | direct ticket             | major-version breakage or ecosystem migration is broad             |
| Database migration | intent, plan, and tickets | backfill, dual-write, rollback, or zero-downtime constraints apply |
| Security change    | intent, plan, and tickets | almost always; visible behavior alone rarely covers the risk       |
| Prototype          | investigation or spike    | productionization becomes a separate picked bundle                 |
| Incident/hotfix    | direct ticket             | permanent fixes and root-cause work become later picked bundles    |

The route name stays the same whatever form the intent artifact takes: a feature spec, a bug
statement, target architecture plus invariants for a refactor, a migration objective, or a threat
model for a security change.

## Non-negotiable boundaries

A lighter route removes unnecessary artifacts, not safeguards. Whatever the route:

- Human Pick, Plan, and Accept authority stays with the human, and mandatory Critique still precedes
  the Plan gate.
- Material open questions never pass to an Implementer.
- Every ticket remains one session and one PR, with verification and reconciliation inside Implement.
- Review remains fresh-context, independent, and read-only. Its depth scales with the change's scope,
  impact, and risk; its existence does not.
- Land still absorbs durable knowledge and deletes the complete bundle.

[Lifecycle](./lifecycle.md) owns every rule in that list; a route narrows none of them.
