---
name: finding-rules
description: What a Critic or Reviewer may report and what survives a round — the two severities, the violated-referent rule, confidence flags, the record form, and the rules across rounds. Preloaded by the critic and reviewer agents; invoke or read it when writing, disposing, rebutting, or escalating a finding.
---

# Finding rules

What a Critic or Reviewer may report, and what survives a round.

A finding is an argument addressed to a human gate. Everything below exists to keep it that — an
argument the human can act on — rather than a list of things an agent noticed.

## Two severities

Critic and Reviewer findings use the same severities:

- **Blocker:** an evidence-backed contract, correctness, safety, executability, or gate violation
  that must be resolved before the next human gate.
- **Concern:** an evidence-backed material risk or tradeoff that the human may consciously accept at
  the next gate after its consequence is explicit.

Do not create minor or suggestion findings. A useful improvement that does not affect the next gate
is a backlog candidate, never a finding. A read-only Critic or Reviewer reports it separately (see
[Artifacts](../../workflow/artifacts.md)).

## Every finding names what it violates

A finding carries a **violated referent** — the thing the work is measured against — and one of
these is admissible:

- a spec identifier: `BR-n`, `INV-n`, `AC-n`, or a named binding constraint
- a ticket's `Done when` condition
- a decision record the work contradicts
- a canonical repository check or CI gate
- a concrete failure mechanism, stated as the execution path that reaches it

A finding that cannot name one is not a finding — taste has no referent, so it has nowhere to go in
the record.

The last referent is the one that leaks. "A concrete failure mechanism" means the path from an input
a caller can supply to the wrong outcome, not the observation that a wrong outcome is imaginable.

Which referents each agent admits differs — the Critic judges a bundle before code exists, the
Reviewer judges a diff at a fixed SHA — so each prompt lists its own admissible set against this
taxonomy.

## Confidence is explicit

Every finding is flagged `verified` or `suspected`:

- **verified** — you ran the case, reproduced the failure, or read the deciding line.
- **suspected** — you reasoned to it but did not confirm it.

Report suspected findings; withholding a real risk to keep the record clean is the worse failure.
But flag them honestly, because the flag is what the fix round acts on: **fix mode confirms a
suspected finding before fixing it or rebutting it**, and says which it did.

## Record form

A finding is written as a block: an identifier line — ID, severity, confidence, axis, and where it
lives — then one line each for what it violates, what the work claims, the evidence, the impact, and
the outcome a fix must establish. Each agent's prompt carries the exact block. The ID prefix is what
differs, because the stages count differently: `C<N>` for a bundle critique, which runs once, and
`R<round>-F<N>` at PR time, where an ID must survive into the next round.

```text
❌ R2-F3 [verified] correctness — src/billing/refund.ts:88

- Violates: AC-4 (a partial refund never exceeds the original charge)
- Claim: `applyRefund` trusts the caller-supplied `amount` without comparing it to `charge.total`
- Evidence: ran `refund(charge, {amount: charge.total + 1})`; it succeeded and left `charge.refunded` negative
- Impact: a caller can drain more than the original charge, corrupting the ledger
- Required outcome: `applyRefund` rejects any amount exceeding the remaining refundable balance
```

Severity carries a glyph: ❌ blocker, ⚠️ concern, ✅ passed or closed.

**A report carries only what the next fix round or the next human gate acts on.** A check that
passed and raised no finding does not appear — a rerun verification table is the exception, because
it is the evidence of record. Do not restate what holds, inventory what you inspected, or assign
fault for a finding; that derivation belongs in the reporting agent's context, not in the record.

## Across rounds

- **A finding's severity may not increase across rounds.** A concern stays a concern. If new
  evidence shows the risk is worse than judged, that is a new finding with its own ID and its own
  evidence — not a re-grade of the old one. Re-grading turns review into leverage over a
  disagreement the human already saw.
- **A closed finding does not reopen without new evidence**, and an accepted outcome is never
  replaced with a reviewer's preferred implementation.
- **New findings on a later round are limited** to material issues introduced by the fix or
  genuinely missed earlier.

## A concern the human accepts leaves a trace

When the human accepts a concern, it becomes a backlog entry — or a decision record when the
acceptance encodes a durable choice, per [Artifacts](../../workflow/artifacts.md). An accepted
concern with no durable trace gets rediscovered as new work next round.

## Concern is not escalation

Both arrive at a human gate; they ask for different things, so keep them visibly distinct:

- A **concern** is the reviewing agent's own judgment, offered for the human to accept or reject.
- An **escalation** is an unresolved disagreement — the reviewing agent and the implementing or
  shaping agent reached opposite conclusions and neither yielded. It arrives with **both positions
  attached**, because the human is choosing between two arguments rather than accepting one.

Presenting an escalation as a concern hides that a disagreement exists. Presenting a concern as an
escalation invents one.
