# Artifacts

Artifacts have one owner, answer one question, and live only as long as that question remains
useful. The workflow does not require every artifact for every bundle.

## Authority

| Artifact           | Question it owns                                                                    | It does not own                                           |
| ------------------ | ----------------------------------------------------------------------------------- | --------------------------------------------------------- |
| Discovery evidence | What did we observe or learn?                                                       | Commitment, priority, or implementation scope             |
| Intent artifact    | What outcome, behavior, constraints, and invariants are approved?                   | Current implementation facts or interior design           |
| Engineering plan   | How will this repository realize and decompose the approved intent?                 | New behavior or requirements absent from intent           |
| Ticket             | What may one agent change, what does it depend on, and what evidence makes it done? | Cross-ticket architecture or unapproved product decisions |
| PR and CI          | What changed, what checks ran, and what is the current review state?                | Intent, decomposition, or durable system truth            |
| Durable docs       | How does the shipped system work now?                                               | In-flight plans or historical feature state               |
| Decision record    | Which durable, consequential choice was made and why?                               | Work status or step-by-step implementation                |

“Intent artifact” is a role, not one mandatory filename. Depending on the work it may be a feature
spec, bug statement, target architecture and invariants, migration objective, security requirements,
or a ticket containing the complete intent for a small change.

## Conflict rules

- For approved outcome and observable behavior, the intent artifact wins. A plan or ticket cannot
  override it.
- For the chosen internal approach and decomposition, the approved plan wins. A ticket may narrow
  the plan to one slice but cannot contradict it.
- For one slice's scope, dependencies, autonomy, and required evidence, the ticket wins within the
  boundaries above.
- For execution and review state, the PR and CI system win; do not copy those transient states into
  spec or plan metadata.
- For the shipped system, code plus durable system documentation replace the bundle. If durable docs
  disagree with reality, reconcile them in the change rather than treating the bundle as permanent
  documentation.

A discovered conflict is never resolved by silently choosing the lower artifact. Correct factual
drift in the artifact that owns the fact. A correction that changes approved behavior, architecture,
or decomposition returns to the Plan gate.

## Bundle contents

A bundle is the disposable container for one approved outcome. It contains only the artifacts its
work route requires:

```text
small known change        ticket
small feature             intent/spec + ticket
larger feature            intent/spec + plan + tickets
refactor or migration     target/invariants + plan + tickets
complex unknown problem   investigation first; bundle only after the next route is known
```

Tickets remain one-agent-session, one-reviewable-PR units even when a bundle contains many of them.

## Lifetime

```text
local draft → work/shaped → work/active → ship: absorb durable knowledge + delete bundle
```

- **Local draft:** unapproved and not shared as committed work.
- **Shaped:** critic-reviewed and human-approved; implementation may start.
- **Active:** at least one ticket has started.
- **Shipped:** the outcome is on the default branch; the bundle has been deleted.

There is no `done/` or shipped-bundle archive. Git history preserves the temporary artifacts.

At ship:

1. Move currently true system behavior into the owning durable documentation.
2. Move durable, consequential rationale into a decision record when it meets that bar.
3. Move unfinished or newly discovered work into the backlog.
4. Delete the entire bundle: intent/spec, plan, tickets, and bundle-local investigation evidence.

Never link to a disposable bundle from code or durable documentation.
