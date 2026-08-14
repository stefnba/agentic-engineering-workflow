# Work file template — single-file bundles

Spec and ticket merged into one document, for work that fits one agent session. The spec
template's whole-document rules apply, with one inversion: exact file paths are allowed — the
file doubles as the ticket. Copy the skeleton, fill it, delete the `<!-- -->` guidance as you
go.

```markdown
---
status: todo # todo | doing | done — done requires every "Done when" line to hold
---

# <YYYY-MM-DD-slug> — <Title>

## Problem

<!-- 1–2 sentences, the user's perspective. No solution language. Be conscise -->

## Change

<!-- What the user can now do, plus the few decisions that constrain how — public contracts
written exactly, not as prose. Present tense. Be conscise and to the point -->

## Done when

Seam: <the observable boundary the checks attach to — confirmed with the human during shaping>

<!-- Concrete, checkable conditions only: Given/When/Then scenarios (AC-1...) and commands
with expected outcomes. Green checks are necessary, not sufficient — human review remains a
gate.

Example:
- AC-1: Given the upstream errors and a prior fetch exists, when the screen loads, then the
  prior balance is shown marked stale with its original timestamp.
- `pytest tests/billing/test_retry_schema.py` passes
-->

## Not in this

<!-- Concrete prohibitions and adjacent work deliberately excluded: features not to build,
modules not to touch. Name where deferred work lands if known. -->
```
