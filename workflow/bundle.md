# Work bundles

The bundle as a container: its layout, completeness, lifetime, revision, and decomposition.
Use the literal formats in [`skills/shape/templates/`](../skills/shape/templates/).

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
gate. The path never moves — shaped and active are derived states, not directories. Land deletes
the bundle path; there is no archive.

## A complete bundle

Shape may not hand a bundle to the Plan gate until:

1. Every material question is resolved.
2. The full bounded ticket set exists with concrete done-when evidence.
3. Every acceptance criterion or invariant maps to at least one ticket.
4. Dependencies and parallel claims are credible.
5. A fresh-context Critic has attacked the bundle.
6. The human has passed the Plan gate.

## Lifetime

- **Local draft:** unapproved and not shared as committed work.
- **Shaped:** critic-reviewed and human-approved; implementation may start.
- **Active:** at least one ticket has started.
- **Landed:** every ticket is done, the outcome is on the integration target, and the bundle is
  deleted.

## Revising a published bundle

A published bundle can be revised while its tickets are in flight, and it is revised where it was
published: as an ordinary commit on the integration target, through a repeated Plan gate. Land
deletes the bundle from the state it publishes, so a revision costs nothing at land time — the bundle
never travels backwards into the branch that deleted it.

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

## Identity rules

- Ticket: unit of approved work and implementation session.
- PR: unit of independent Review and human Accept.
- Commit: implementation history within the PR.
- Bundle: unit of coherent outcome and final Land.

Default and rule: one ticket equals one PR. If that produces meaningless PRs, the decomposition is
wrong; merge the steps into one ticket before implementation.
