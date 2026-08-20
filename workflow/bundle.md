# Work bundles

[Artifacts](./artifacts.md) defines what a bundle is and owns its authority, precedence, status,
and lifetime; [Lifecycle](./lifecycle.md) owns stages and gates. This document owns how intent,
plan, and tickets cooperate inside Shape and execution.

Use the literal formats in [`skills/shape/templates/`](../skills/shape/templates/).

## Route and contents

[Shaping routes](./shaping-routes.md) owns route selection, the artifact combination each route
requires, and the sequential-bundle criteria — including when a ticket set is too large to shape at
once. This document defines only how the selected artifacts cooperate inside a bundle.

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

Ticket numbers are two-digit, stable within the bundle, and encode identity rather than execution
order. Use the same number in the ticket heading. A lone `ticket.md` is number `01` — the scripts
derive its branch and status from that number even though it has no sibling to be distinguished
from.

Draft location is tool-local and uncommitted. After the Plan gate, skill scripts publish the exact
approved bundle under `work/bundles/` on the configured integration target using the repository's Git
conventions — committed directly, never through a PR: mandatory critique plus the human's approval
already are the review a planning artifact gets, and a PR on top adds ceremony without adding a
gate. The path never moves — shaped and active are derived states, not directories (see
[Artifacts](./artifacts.md)). Land deletes the bundle path; there is no archive.

## Shape feedback loop

Spec, planning, and ticket generation are feedback substeps inside Shape:

```text
intent/spec → plan when needed → tickets
      ▲              │               │
      └──────── missing decision ────┘
```

Planning is repository-grounded. It may reveal a migration decision, compatibility constraint,
failure behavior, or invariant absent from intent. Resolve that gap in the owning artifact before
continuing; never let a ticket silently decide it.

**Shape is complete only after:**

1. Every material question is resolved.
2. The full bounded ticket set exists with concrete done-when evidence.
3. Every acceptance criterion or invariant maps to at least one ticket.
4. Dependencies and parallel claims are credible.
5. A fresh-context Critic has attacked the bundle.
6. The human has passed the Plan gate.

## Revising a published bundle

A published bundle can be revised while its tickets are in flight, and it is revised where it was
published: as an ordinary commit on the integration target, through a repeated Plan gate. Land
deletes the bundle from the state it publishes, so a revision costs nothing at land time — the bundle
never travels backwards into the branch that deleted it ([Git mechanics](./git-mechanics.md)).

Two things a revision may not do, because in-flight work already depends on them:

- **Change the ticket set.** Adding or removing a `NN-<slug>.md` file rewrites the `depends_on` graph
  under tickets already claimed against the old one, and changes which branch this bundle's PRs
  target. A bundle that needs a different decomposition is not revised; it is stopped and reshaped.
- **Change a claimed ticket's contract.** Its branch was cut, and its accepted head is what the merge
  is bound to. Revise a ticket only while it is still `todo`; a claimed one is changed by cancelling
  the claim — delete its branch and worktree and it reads `todo` again.

An in-flight worktree does not see the revision, and does not need to: the tickets it holds are the
ones the revision left alone. What a ticket's own diff makes false is reconciled in that ticket's PR;
what only the whole bundle makes false is reconciled at Land.

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
supported. When the approved outcome is "behavior unchanged", characterization tests that pin current
behavior are mandatory, and they bind the decomposition rather than any one document: with a plan,
it names the slice that adds them; without one, a `depends_on` edge puts them ahead of every
refactoring ticket, and in a single-ticket bundle they are that ticket's pre-change evidence.

## Dependencies and parallelization

Record only real blocking edges. A ticket depends on another when it cannot satisfy its done-when
against the earlier repository state — not merely because the numbered order looks natural.

Parallel-safe means more than "no dependency": expected code ownership, migrations, shared schemas,
generated artifacts, and integration tests must not create an unsafe collision. The plan owns this
judgment; `depends_on` owns only hard execution order.

Human attention is the other ceiling. Every parallel ticket runs in its own session that the human
steers and gates, and that does not scale past a few at once — treat it as a real constraint on how
wide a parallel wave to shape, not an inconvenience.

## Autonomy and escalation

Every ticket states what the Implementer may decide and what it must preserve. Local refactoring and
helper design may be delegated within the ticket's scope.

Escalate to the human when implementation would cross a boundary that returns work to the Plan gate,
or would decide cross-ticket architecture. [Lifecycle](./lifecycle.md) owns which changes those are;
a ticket adds only the boundaries specific to its own slice.

## Git and pull requests

[Git mechanics](./git-mechanics.md) owns branch naming, branch strategy, the claim, the land, and the
settings it reads from `${CLAUDE_PROJECT_DIR}/work/config.conf`. This section owns only what a
bundle's shape implies: which branches and pull requests exist, and what each one targets.

### Single-ticket bundle

One ticket branch and worktree, based on the configured integration target, and one PR into that
target. Do not create a bundle branch with one child: there is no second ticket for it to integrate,
and that one PR already put the work on the target. Land still runs — with no bundle branch it has
nothing to merge, so its reconciliation and deletion commits go straight to the integration target
(see [Lifecycle](./lifecycle.md), which owns which of its steps that shape skips).

### Multi-ticket bundle

One bundle branch off the configured integration target, and per ticket one branch, worktree, and PR
into that bundle branch. Content reaches the bundle branch only through an accepted ticket PR, and
nothing else ever writes to it — not even Land, which merges it into a detached worktree on the
integration target and reconciles, drains and deletes the bundle there before publishing (see
[Git mechanics](./git-mechanics.md)). Then it removes the branches and worktrees.

### Incident or hotfix

Use the repository's emergency integration and release policy. A shorter shaping route does not by
itself waive verification, independent Review, or human acceptance.

### Identity rules

- Ticket: unit of approved work and implementation session.
- PR: unit of independent Review and human Accept.
- Commit: implementation history within the PR.
- Bundle: unit of coherent outcome and final Land.

Default and rule: one ticket equals one PR. If that produces meaningless PRs, the decomposition is
wrong; merge the steps into one ticket before implementation.
