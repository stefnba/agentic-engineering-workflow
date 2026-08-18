# Work bundles

A bundle is the disposable planning and execution record for one coherent outcome. Read
[Artifacts](./artifacts.md) for authority, precedence, status, and lifetime; read
[Lifecycle](./lifecycle.md) for stages and gates. This document owns how intent, plan, and tickets
cooperate inside Shape and execution.

Use the literal formats in [`skills/shape/templates/`](../skills/shape/templates/). Do not embed second copies of templates in
this document.

## Route and contents

[Shaping routes](./shaping-routes.md) owns route selection, the artifact combination each route
requires, and the sequential-bundle criteria — including when a ticket set is too large to shape at
once. This document defines only how the selected artifacts cooperate inside a bundle, and repeats
neither the route names nor the split triggers.

## Naming and layout

A bundle is **always a directory**. No route ever stores a bundle as a single loose file. Three
example bundles:

```text
work/
├── backlog.md
└── bundles/
    ├── 2026-08-17-fix-typo/            # direct ticket route: no spec
    │   └── ticket.md                   # complete intent inline
    ├── 2026-08-17-add-2fa/             # intent plus tickets route: one ticket
    │   ├── spec.md
    │   └── ticket.md                   # references the spec, doesn't restate it
    └── 2026-08-17-add-invites/         # intent, plan, and tickets route
        ├── spec.md
        ├── plan.md                     # only when the route requires one
        └── tickets/                    # Multiple tickets
            ├── 01-persistence.md
            └── 02-api.md
```

The bundle ID is `YYYY-MM-DD-<slug>` using the Shape date and a short lowercase kebab-case slug.

`ticket.md` and `tickets/` are mutually exclusive, never both present. The choice depends only on
ticket count, not on whether a spec or plan also exists:

- Exactly one ticket: `ticket.md`, whether or not `spec.md`/`plan.md` are also present. On the direct
  ticket route it carries the complete approved intent; on the intent plus tickets route it
  references the spec's requirement IDs instead of restating them.
- More than one ticket: `tickets/`, one numbered file per ticket — numbering exists only to
  distinguish among multiples.

Ticket numbers in `tickets/` are two-digit, stable within the bundle, and encode identity rather
than execution order. Use the same number in the ticket heading.

Draft location is tool-local and uncommitted. After the Plan gate, skill scripts publish the exact
approved bundle under `work/bundles/` on the configured integration target using the repository's Git
conventions. The path never moves — shaped and active are derived states, not directories (see
[Artifacts](./artifacts.md)). Ship deletes the bundle path; there is no archive.

## Shape feedback loop

Spec, planning, and ticket generation are feedback substeps inside Shape:

```text
intent/spec → plan when needed → tickets
      ▲              │              │
      └──────── missing decision ────┘
```

Planning is repository-grounded. It may reveal a migration decision, compatibility constraint,
failure behavior, or invariant absent from intent. Resolve that gap in the owning artifact before
continuing; never let a ticket silently decide it.

Shape is complete only after:

1. Every material question is resolved.
2. The full bounded ticket set exists with concrete done-when evidence.
3. Every acceptance criterion or invariant maps to at least one ticket.
4. Dependencies and parallel claims are credible.
5. A fresh-context Critic has attacked the bundle.
6. The human has passed the Plan gate.

## Intent/spec

The intent artifact answers:

> If two competent implementations differed internally, what must still be identical?

It owns the problem, approved outcome, scope, externally observable behavior, public contracts,
binding constraints, invariants, acceptance criteria, and risk-specific test intent.

It does not own current repository facts, file lists, task order, transient status, or interior
implementation choices. Those belong to the plan, ticket, repository, or PR/CI.

Write target behavior in present tense. Remove all open questions before Plan approval. A bounded
local choice belongs under ticket autonomy, not under unresolved intent.

## Engineering plan

Use a plan only when the technical approach or decomposition is non-obvious. The plan answers:

> Given the approved intent and this repository, what approach and decomposition minimize risk?

Ground it in actual code, tests, durable docs, conventions, and decisions. It owns:

- repository evidence and relevant extension points
- architecture and data flow
- migration, compatibility, rollout, and rollback mechanics
- consequential technical choices and rejected alternatives
- vertical slices, dependencies, sequencing, and safe parallelization
- risks and their containment

The plan cannot add behavior absent from intent. Do not turn it into file-by-file pseudocode that an
Implementer can infer more accurately from current code.

## Tickets

A ticket is one independently reviewable outcome for one fresh implementation session and one PR.
It owns:

- the slice outcome and approved references it satisfies
- bounded scope and expected touch points
- dependencies
- explicit autonomy boundaries
- concrete done-when evidence and commands
- adjacent work excluded from the ticket
- escalation conditions

A ticket never introduces intent or cross-ticket architecture. If several tiny steps are too coupled
to review independently, combine them into one ticket during Shape. Do not create several tickets
that later share a PR. Shape the complete ticket set upfront; a bundle never grows tickets during
execution.

## Vertical slicing

Default to a thin vertical slice that is demonstrable, behaviorally testable, independently
reviewable, and independently revertible where practical. A valid slice may cross persistence,
domain, API, and UI layers; few files is not the goal.

Horizontal foundation work is an exception. Use it only when a vertical slice cannot be built
safely first. The ticket must name the later slice it enables and carry independent verification.
For refactors and migrations, use expand → migrate → contract while keeping each intermediate state
supported. When the approved outcome is "behavior unchanged", the plan mandates characterization
tests that pin current behavior, and the ticket that adds them precedes every refactoring ticket.

## Dependencies and parallelization

Record only real blocking edges. A ticket depends on another when it cannot satisfy its done-when
against the earlier repository state — not merely because the numbered order looks natural.

Parallel-safe means more than "no dependency": expected code ownership, migrations, shared schemas,
generated artifacts, and integration tests must not create an unsafe collision. The plan owns this
judgment; `depends_on` owns only hard execution order.

## Autonomy and escalation

Every ticket states what the Implementer may decide and what it must preserve. Local refactoring and
helper design may be delegated within the ticket's scope.

Escalate to the human when implementation would change approved behavior, scope, public contracts,
security, migration, compatibility, cross-ticket architecture, or acceptance criteria. Factual
drift that preserves intent is corrected visibly in the PR; material drift returns to the Plan gate.

## Git and pull requests

[Git mechanics](./git-mechanics.md) owns branch naming, the claim, and bundle-branch creation, and
names the settings it reads from `${CLAUDE_PROJECT_DIR}/work/config.conf`. This section owns how
bundle and ticket branches map onto a bundle's shape.

The shape decides the strategy — nothing declares it. A bundle with more than one ticket gets a
bundle branch; a single-ticket bundle does not.

### Single-ticket bundle

Create one ticket branch and worktree based on the configured integration target. Open one PR into
that target. Do not create a bundle branch with one child.

### Multi-ticket bundle

Create one bundle branch from the configured integration target. Each ticket gets one
branch, worktree, and PR into the bundle branch. After every ticket is accepted and merged, Ship
reconciles and deletes the bundle on the bundle branch, lands that final state on the
integration target, and removes all bundle branches and worktrees.

### Incident or hotfix

Use the repository's emergency integration and release policy. A shorter shaping route does not by
itself waive verification, independent Review, or human acceptance.

### Identity rules

- Ticket: unit of approved work and implementation session.
- PR: unit of independent Review and human Accept.
- Commit: implementation history within the PR.
- Bundle: unit of coherent outcome and final Ship.

Default and rule: one ticket equals one PR. If that produces meaningless PRs, the decomposition is
wrong; merge the steps into one ticket before implementation.
