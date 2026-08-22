---
name: finding-rules
description: What a Critic or Reviewer may report and what survives a round — the two severities, the violated-referent rule, confidence flags, the record form, and the rules across rounds. Preloaded by the critic and reviewer agents; invoke or read it when writing, disposing, rebutting, or escalating a finding.
---

# Finding rules

What a Critic or Reviewer may report, and what survives a round. The `critic` and `reviewer` agents
preload it through their `skills:` field; a fix round reads it at the point it disposes a finding.

A finding is an argument addressed to a human gate. Everything below exists to keep it that — an
argument the human can act on — rather than a list of things an agent noticed.

## Two severities

Critic and Reviewer findings use the same severities:

- **Blocker:** an evidence-backed contract, correctness, safety, executability, or gate violation
  that must be resolved before the next human gate.
- **Concern:** an evidence-backed material risk or tradeoff that the human may consciously accept at
  the next gate after its consequence is explicit.

Do not create minor or suggestion findings. A useful improvement that does not affect the next gate
is a backlog candidate, never a finding. A read-only Critic or Reviewer reports it separately; skill
scripts record reported candidates in the backlog's tag and area form (see
[Artifacts](../../workflow/artifacts.md)) without prioritizing or promoting them.

## Every finding names what it violates

A finding carries a **violated referent** — the thing the work is measured against — and one of
these is admissible:

- a spec identifier: `BR-n`, `INV-n`, `AC-n`, or a named binding constraint
- a ticket's `Done when` condition
- a decision record the work contradicts
- a canonical repository check or CI gate
- a concrete failure mechanism, stated as the execution path that reaches it

A finding that cannot name one is not a finding. This is what makes a nitpick inadmissible by
construction rather than by an instruction to avoid nitpicks: taste has no referent, so it has
nowhere to go in the record.

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
suspected finding before fixing it or rebutting it**, and says which it did. A suspected finding
that survives into an accepted change without ever being confirmed is a gap in the record, not a
resolved item.

## Record form

A finding is written as a block: an identifier line — ID, severity, confidence, axis, and where it
lives — then one line each for what it violates, what the work claims, the evidence, the impact, and
the outcome a fix must establish. Each agent's prompt carries the exact block. The ID prefix is what
differs, because the stages count differently: `C<N>` for a bundle critique, which runs once, and
`R<round>-F<N>` at PR time, where an ID must survive into the next round.

Severity carries a glyph, so that a human scanning the record and an agent parsing it read the same
line: ❌ blocker, ⚠️ concern, ✅ passed or closed.

**A report carries only what the next fix round or the next human gate acts on.** A check that
passed and raised no finding does not appear — a rerun verification table is the exception, because
it is the evidence of record. Do not restate what holds, inventory what you inspected, or assign
fault for a finding; that derivation belongs in the reporting agent's context, not in the record. A
report padded with passing checks buries the two lines someone has to act on.

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

Acceptance at a gate is a decision, and it disappears unless something records it. When the human
accepts a concern, it becomes a backlog entry — or a decision record when the acceptance encodes a
durable choice, per [Artifacts](../../workflow/artifacts.md). An accepted risk with no durable trace has been
forgotten rather than accepted, and the next round of work rediscovers it as new.

## Concern is not escalation

Both arrive at a human gate; they ask for different things, so keep them visibly distinct:

- A **concern** is the reviewing agent's own judgment, offered for the human to accept or reject.
- An **escalation** is an unresolved disagreement — the reviewing agent and the implementing or
  shaping agent reached opposite conclusions and neither yielded. It arrives with **both positions
  attached**, because the human is choosing between two arguments rather than accepting one.

Presenting an escalation as a concern hides that a disagreement exists. Presenting a concern as an
escalation invents one.
