---
date: 2026-08-07
source: critique pass over agentic-workflow.md and docs-structure.md, followed by a challenge round on the proposed fixes
---

# Audit: workflow + docs-structure critique

**Evidence, not commitments.** Nothing below is decided. The one-line pointers live in `work/backlog.md`; this file holds the reasoning those lines can't carry. Where a proposed fix survived the challenge round it says so — that's still a proposal, not a record. Decisions, when made, go to `decisions/`.

---

## What earns its place (validated by argument, not yet by use)

Each of these counters a documented agent failure mode — which is the right test, and the pattern behind every strong part of the system:

- **Non-goals / "Not in this ticket"** — scope drift is the most common agent failure; an exclusion list is the cheapest fix. Highest value-per-word in the system.
- **Evidence over claims** — agents confidently report success that didn't happen (but see finding 2).
- **Target-state phrasing** — delta descriptions are unreadable at ticket 4 of 7.
- **Fresh-context role separation** (author/critic, implementer/reviewer) — structural fix for self-grading bias.
- **Delete-on-ship** — stale feature docs poison retrieval; an agent-specific problem human doc systems don't see.
- **Exactly three human gates, all judgment, none mechanical.**

The weak spots below are all places where "what does the agent's failure mode demand?" hasn't been asked yet.

---

## Findings and proposed resolutions

### 1. The bundle-less majority path is implicit

Bundles cover 10–20% of work; the stages apply to all of it, but the docs never state the scaling rule, so an agent can't derive which gates apply to a bug fix.

**Proposal:** state "stages are invariant; artifacts scale — gates attach to artifacts that exist" (no design → no Plan gate; no ticket → done-when in the PR; no design.md → the colocated README is the design authority).

**Challenge round amendments (load-bearing):**

- If gates attach to artifacts, whoever decides "no design needed" removes the Plan gate. The **light/heavy classification must be made at pick time, by the human** — never by the implementing agent. Otherwise the executor chooses its own gate coverage.
- On the light path, done-when written by the implementer at PR time is post-hoc goalpost-setting (the bundle path pre-registers criteria in tickets). Either the backlog line / user request carries the success criterion, or the weaker pre-registration is stated as an accepted trade-off.

### 2. Verify evidence is self-reported

The implementer pastes its own transcripts into its own PR — a claim wearing evidence's clothes. Agents fabricate, truncate, and paste stale output.

**Proposal:** the principle is "verification runs outside its author's context"; CI is the usual implementation. The PR transcript stays mandatory but is a preview, not the gate.

**Challenge round amendments:**

- CI can't run bespoke per-ticket commands without machinery. Resolution: **done-when conditions must be expressible as tests the standard suite picks up automatically** ("these tests exist and pass"), so CI needs zero ticket-awareness. Manual smoke and anything inexpressible falls under the existing declared-gap rule.
- The "reviewer re-runs commands" fallback for no-CI repos is fantasy. Honest version: without CI the gate is weaker, knowingly.

### 3. No rule for design.md amendments after Plan approval

Implement may amend the design the human approved; tickets 4–7 then execute against a design nobody approved.

**Proposal:** "an amendment may describe, never decide" — clarifications amend freely; deviations become an Open question and stop.

**Challenge round amendments:** the section-based deviation test does not mechanize cleanly ("invalidates an unstarted ticket" is judgment; Target state can change behaviorally without touching the protected sections). Keep the slogan, drop the mechanization claim, add a bias rule: **when unsure, it's a deviation — stopping costs minutes, deciding unilaterally costs the gate.** Review explicitly checks amendments against this.

### 4. Failure paths are undefined

The pipeline only describes success.

**Proposals (all reuse existing machinery):**

- Review rejects the design, not the diff → the finding _is_ an Open question; Plan gate re-arms.
- Stale claim (status `doing`, branch without commits) → reset to `todo` by whoever notices, in its own commit; the commit message is the audit trail. No timers at 2–3 agents. Scope "whoever notices" to humans or explicitly instructed agents — an agent proactively reaping claims is a new failure mode.
- Cancelled feature → symmetric with ship: **bundles never linger — ship (absorb, then delete) or cancel (backlog line pointing at the deletion SHA, then delete).**
- **Added in challenge round:** verify persistently red → often the _ticket's_ failure (wrong done-when), so it routes to an Open question rather than infinite retry; without this an agent grinds or quietly weakens the test.

### 5. The Open-questions-empty gate rewards not recording doubt

The gate is the absence of recorded doubt; the exit path of least resistance is shallow resolution or silence. Resolved questions are deleted, so answers vanish before ticket 4 needs them.

**Proposal:** questions are never deleted during the feature; they resolve in place (`- [resolved] …? → answer`). Gate becomes "no line without a resolution" — still checkable mechanically, incentive flips (answering is the exit, not hiding), answers survive, and the human sees the full Q&A at the Plan gate instead of an absence.

**Challenge round amendment (the most important sentence in the batch):** who may resolve. Split by the system's own core distinction — **evidence questions** (does X call Y?) the agent resolves, citing the file; **judgment questions** (should tokens live 15 minutes?) only the human resolves. Without this split, `[resolved]` is self-grading; and since findings 3 and 4 also route through Open questions, they inherit whatever weakness this rule has.

### 6. Smaller findings

- **ID allocation** (decided direction, pending write-up): 4-digit sequential + `docs/work/next-id` counter, incremented in the bundle-creating commit; the push conflict is the lock. Rejected: hash/random IDs — they solve a once-per-feature allocation event by making every reference forever unpronounceable, and content-addressing (the git-SHA analogy) doesn't apply to names allocated before content exists. Rejected: highest-existing+1 — delete-on-ship makes the tree forget, and a reused ID poisons old references. Fallback if the counter offends: date-based IDs (`20260807-slug`) — zero coordination, bulkier references. Mechanics live in the bundle-creating skill, not a loose script.
- **Gather triggers**: attach maintenance to events that already happen (prune at pick, follow-ups at ship). Audit/research are "user-triggered or scheduled, never assumed spontaneous" — scheduled agent runs exist, don't foreclose them.
- **Freeze-rule duplication**: brief-freeze semantics stated in full in both docs; one side should be a one-liner.
- **Human ceiling**: review latency is the pipeline's rate limiter _by design_; the fix for a slow pipeline is smaller tickets, never a weaker Accept gate. Unstated, so someone will "fix" it.

---

## Cross-cutting risks in the proposed fixes themselves

1. **Open questions is becoming the universal escape hatch** (findings 3, 4, 5 all route through it). Economical, but it concentrates risk: the who-may-resolve rule is load-bearing for all three, and design.md becomes a live state machine mid-flight. Conscious trade-off, not an accident — keep it that way.
2. **Spec bloat is now the system's own anti-pattern risk.** The docs preach terseness; agents skim long specs like humans skim hollow ones. Every fix above should fold into an existing section at one to three sentences. A fix that can't be stated that short isn't settled yet.

---

## Strongest recommendation

**Stop refining; validate.** No feature has ever run through this pipeline. Push one real piece of work through the whole spine — the natural candidate is building the first skill _using_ the workflow (interview → brief → design + critic → tickets → implement → review → ship). Reality will generate better findings than another critique round, and it tests the docs as instructions-for-agents, which is the only test that counts.
