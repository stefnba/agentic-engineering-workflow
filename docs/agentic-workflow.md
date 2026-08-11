# what remains

Gates must be checkable. "Is the spec good?" is not a gate — that is what review is for.
| — (approved at review) |

## Verify is a gate, not a stage

The earlier six-stage draft had Verify as a stage between Implement and Review. It's demoted to a gate, for two reasons:

1. **It was already inside Implement.** "CI green, per ticket" was Implement's own exit condition, so a separate Verify stage ran the same commands twice and owned neither run.
2. **A stage earns fresh context; deterministic commands don't benefit from it.** Fresh context exists to prevent an agent from grading its own homework — but `pytest` grades homework the same in any context. The part of the old Verify stage that _did_ involve judgment ("checks acceptance criteria") belongs to Review, which already has the fresh context and the mandate.

What survives from the old Verify stage is its best idea: **evidence over claims**. The implementer must paste exact commands and output into the PR, and Review may re-run any of them. An agent saying "tests pass" is a claim; a transcript is evidence.

## Reconcile is an obligation, not a stage

Reconcile appeared in three contradictory places across the earlier drafts: as a bullet inside Ship, as a standalone stage between Review and Ship, and (implicitly) in the pre-PR checklist. The checklist version wins, generalized: **reconcile is an obligation with two trigger points, enforced by gates rather than positioned as a stage.**

- **Per ticket, before review.** The same-PR rule forces this ordering: if doc updates must land in the PR, they exist _before_ the PR is reviewed — which also means the reviewer checks them, instead of doc changes slipping in post-approval, unreviewed. A reconcile stage placed after Review is self-contradicting.
- **At ship, for the feature.** Absorbing the spec into durable docs and deleting the bundle can only happen once, at the end, when the spec has stopped changing.

Neither point deserves stage rank because a stage implies a fresh context and a session boundary, and reconcile needs the opposite: the context of whoever just made the docs wrong. What made "reconcile as a stage" attractive was fear of it being skipped — but the protection is gates that check for it (review checks the README diff, ship checks the bundle deletion), not a box in the pipeline diagram.
