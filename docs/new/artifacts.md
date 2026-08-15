# Artifacts

Artifacts have one owner, answer one question, and live only as long as that question remains
useful. A bundle contains the minimum artifact set its shaping route requires.

## Authority

| Artifact            | Question it owns                                                                    | It does not own                                           |
| ------------------- | ----------------------------------------------------------------------------------- | --------------------------------------------------------- |
| Discovery evidence  | What did we observe or learn?                                                       | Commitment, priority, or implementation scope             |
| Intent artifact     | What outcome, behavior, constraints, and invariants did the human approve?          | Current implementation facts or interior design           |
| Engineering plan    | How will this repository realize and decompose the approved intent?                 | Behavior or requirements absent from intent               |
| Ticket              | What may one agent change, what does it depend on, and what evidence makes it done? | Cross-ticket architecture or unapproved product decisions |
| PR and CI           | What changed, what checks ran, what was reviewed, and what is the current state?    | Intent, decomposition, or durable system truth            |
| Durable system docs | How is the shipped system intended to work now?                                     | In-flight plans or historical feature state               |
| Decision record     | Which durable, consequential choice was made and why?                               | Work status or step-by-step implementation                |

“Intent artifact” is a role, not one mandatory filename. It may be a feature spec, bug statement,
target architecture and invariants, migration objective, security requirements, or a ticket that
contains the complete intent for a small change. When one file plays both intent and ticket roles,
its sections must still keep approved behavior separate from execution instructions.

## Conflict rules

Authority is axis-specific, not one global document hierarchy:

- **Approved outcome and observable behavior:** the intent artifact wins. A plan or ticket cannot
  override it.
- **Binding technical direction and decomposition:** the approved plan wins. A ticket may narrow the
  plan to one slice but cannot contradict it.
- **One slice's scope, dependencies, autonomy, and evidence:** the ticket wins within the approved
  intent and plan.
- **Execution and review state:** the PR and CI system win. Do not copy transient PR states into spec
  or plan metadata.
- **Current system claims during active work:** durable colocated system docs outrank the bundle. If
  code or tests contradict those docs, surface the drift and reconcile it; never silently choose the
  bundle's version.
- **Shipped system:** code, tests, and durable docs replace the bundle. The bundle is not permanent
  documentation.

Correct factual drift in the artifact that owns the fact. A correction that changes approved
behavior, binding architecture, decomposition, security, migration, compatibility, or acceptance
criteria returns to the Plan gate.

## Bundle contents

A bundle is the disposable container for one coherent approved outcome. [Tailor bundles by
uncertainty and impact](./bundles-by-size.md) exclusively owns which artifacts a work shape requires
and when to split sequential bundles.

Every bundle is fully shaped before implementation: all of its tickets exist, have concrete
done-when evidence, and passed the Plan gate. If that is not credible because later work depends on
unvalidated assumptions, split the effort into sequential bundles rather than writing speculative
tickets.

One ticket equals one implementation session and one reviewable PR. Several tiny steps that cannot
be reviewed independently are one ticket, not several tickets sharing a PR.

## Status ownership

Persist only status an artifact uniquely owns:

```text
bundle: local draft → work/shaped → work/active → shipped and deleted
ticket: todo → doing → done
PR/CI: implementation, checks, review, and merge state
```

- `todo`: approved and not claimed.
- `doing`: claimed; remains `doing` through Implement, Review, fixes, human review, and merge pending.
- `done`: human-accepted and merged into the configured integration target.

Do not persist `ready`, `implemented`, `verifying`, `blocked`, or `changes_requested` in ticket
status. The bundle, PR, and CI already own those facts. Unmet ticket dependencies are derived from
`depends_on`; an external blocker is raised on the PR or escalated to the human, never recorded as
ticket metadata that can go stale.

## Lifetime

- **Local draft:** unapproved and not shared as committed work.
- **Shaped:** critic-reviewed and human-approved; implementation may start.
- **Active:** at least one ticket has started.
- **Shipped:** every ticket is done, the outcome is on the default branch, and the bundle is deleted.

There is no `done/` or shipped-bundle archive. Git history preserves temporary artifacts.

Each implementation PR is the permanent historical bridge from the shipped change to its temporary
planning context. Its body must contain immutable commit permalinks to the complete approved bundle
and the exact ticket it implements. A branch-relative URL is not a permalink: it can drift or break
when Ship removes the bundle branch. The linked commit must remain reachable through merged PR or
default-branch history after branch cleanup. If a material change passes the Plan gate again, update
the PR links to that newly approved bundle version.

The PR is the main surface for implementation evidence, review findings, fix responses, and review
state. Its links do not transfer authority: the linked intent, plan, and ticket remain authoritative
while the work is active. PR comments are an execution log, not a second specification or durable
system documentation.

At Ship:

1. Move currently true system behavior into the owning durable documentation.
2. Move durable, consequential rationale into a decision record when it meets that bar.
3. Move unfinished or newly discovered work into the backlog.
4. Delete the complete bundle: intent/spec, plan, tickets, and bundle-local evidence.

Never link directly to a disposable bundle from code or durable documentation. Use the implementation
PR when a historical reference is necessary; that PR owns the immutable links to its bundle and
ticket.
