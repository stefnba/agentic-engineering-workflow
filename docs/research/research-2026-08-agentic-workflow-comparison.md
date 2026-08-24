---
date: 2026-08-24
source: Five public agentic-coding workflow repos (coleam00/skills, addyosmani/agent-skills, mattpocock/skills, github/spec-kit, gastownhall/gastown), each shallow-cloned and read in full, compared against the target workflow design in agentic-coding/docs/new/
---

# Research: How five public agentic workflow designs compare to the target workflow

**Evidence, not commitments.** Nothing below is decided. One-line pointers live in
`work/backlog.md`; this file holds the reasoning those lines can't carry.

File citations are repo-relative inside each cited repository at its 2026-08 head.

## The target design's distinctive combination has no counterpart in the field

**No studied repo combines a fresh-context Critic of the plan, axis-specific artifact authority, disposable bundles reconciled at Ship, and an uncertainty×impact routing matrix; every repo lacks at least three of the four.**

- coleam00/skills — plans go from author straight to human; fresh-context independence exists only at code review (`piv-review-pr`), never at plan time.
- addyosmani/agent-skills — its adversarial loop (`doubt-driven-development`) targets build-time artifacts, not the spec; conflict handling is "surface and ask", not authority axes.
- mattpocock/skills — the human's approval of the ticket breakdown is the only pre-build check; nothing attacks the spec.
- github/spec-kit — `/speckit.analyze` and `/speckit.converge` run in the authoring session and inherit its blind spots; `docs/concepts/spec-persistence.md` names three artifact-lifecycle models and punts the choice to team convention, listing exactly the drift risks delete-at-Ship answers.
- gastownhall/gastown — no spec/plan artifacts at all; decomposition quality rests on the Mayor's in-context judgment.

## coleam00/skills — closest in ambition; strongest on validation independence and autonomy, weakest on artifact lifecycle

**A full prime → plan → implement → validate → review → commit → PR loop per ticket plus an autonomy capstone, but no plan critic, no routing rule, and artifacts that accumulate forever.**

- `piv-plan-implementation` (Phase 2 "GATE") — clarifying questions only after codebase analysis, one numbered cluster of 3–6 each with a recommended default, hard end-the-turn semantics; declined answers become named `Assumed —` lines, never silent guesses.
- `piv-implement` → `piv-create-pr` → `piv-review-pr` — deviation-documentation contract: the implementer records deviations with reasons in a report; the reviewer treats documented deviations as intent and flags only undocumented divergence.
- `build-dark-factory` `references/validation-harness.md` — the "independence line": anything the agent can read or run is inside its own optimization loop; trust requires checks above a line it cannot see or edit (holdout scenarios written before implementation; governance files read from the base branch so "a change is not judged against a rulebook it just edited"); "empty is not pass" — assert how many checks ran, with counts.
- dark factory `plan.md` prompt — judgement vs product values ("a JUDGEMENT value decides what counts as passing — never choose one; a PRODUCT value — choose it and record it") plus a mandatory `CHANGE IF:` line on every assumption.
- `piv-implement-issue` §2 — drift check: before implementing from a stale artifact, diff its cited snippets against current code; stop and re-investigate on material drift.
- `opportunity-scan`, `ablate-ai-layer`, `rules-check-drift` — an empirical meta-loop: "what in the AI layer would have prevented this failure?", plus A/B ablation of whether rules still earn their context cost.
- `piv-slice-epic` — numeric AI-scoped ticket sizing (~500–1500 LOC incl. 20–50% tests, "one focused loop can one-shot it without context rot") and just-in-time planning of dependent tickets.
- Weaknesses observed: `.claude/plans|reports|code-reviews/` accumulate with no reconciliation or deletion; 4-level severity in the interactive loop invited nit-blocking — the factory judge re-fixed it with a block-list/notes split that is effectively the target's blocker/concern protocol; `piv-run-full-loop` chains all phases in one context; no review round limits.

## addyosmani/agent-skills — discipline scaffolding and reviewer-independence mechanics; human-as-orchestrator by doctrine

**Six phases gated at every transition with the human as the only orchestrator (automating stage transitions is a named anti-pattern), and the field's most concrete independence mechanics.**

- `doubt-driven-development` — the fresh-context reviewer receives the artifact and its contract but never the author's claim or reasoning ("handing the reviewer your conclusion biases it toward agreement"); findings classified in precedence order with contract-misread first (a wrong finding caused by an unclear contract fixes the contract, not the artifact); bounded at 3 cycles; "doubt theater" signal — ≥2 substantive cycles with zero classified-actionable findings means rubber-stamping.
- Every SKILL.md — Common Rationalizations table (enumerated excuses with rebuttals) plus Red Flags; `evals/README.md` ships pressure-case evals that test whether the workflow docs hold under time-pressure/sunk-cost/authority prompts.
- `.claude/commands/build.md` — hedged-approval rejection ("looks reasonable", "I guess" are NOT approved) and a clean-git-baseline precondition for autonomous runs so per-task commits stay revert-clean.
- `references/orchestration-patterns.md` — anti-pattern catalog; Anti-pattern C (a sequential orchestrator that paraphrases between stages loses fidelity) is a direct design constraint for a Coordinator: dispatch, never summarize.
- `references/definition-of-done.md` — a standing project-level done floor distinct from per-ticket acceptance criteria, defined once and never renegotiated.
- Weaknesses observed: specs/plans permanent with only "living document" exhortation against staleness; gate density incompatible with high autonomy; reviewers rerun nothing themselves; no stable finding IDs or PR round caps; sizing by ad-hoc skip rules.

## mattpocock/skills — best Discover/Shape mechanics and context economics; the back half of the lifecycle is thin

**An anti-framework library whose interview and context-management primitives are the strongest studied, grafted onto an Implement→Ship pipeline with no independent review loop, no accept gate, and no completion step — roughly the inverse of the target design, hence unusually complementary.**

- `skills/productivity/grilling/SKILL.md` — the interview as a design tree: each round asks the whole frontier of questions whose prerequisites are settled, every question numbered with a recommended answer; facts are the agent's job (dispatched to subagents), decisions the user's; done = empty frontier.
- `skills/engineering/ask-matt/PHASE-BOUNDARIES.md` — ordered context-transition tree (Continue → `/clear` → handoff → subagent → `/compact` last) grounded in a primary/secondary-source framing; shaping (grill → spec → tickets) deliberately stays in one unbroken window because "the implementation wants the reasoning verbatim, not a summary of it".
- `skills/engineering/triage/AGENT-BRIEF.md`, `to-spec`, `to-tickets` — durability over precision: name types, interfaces, and behavioral contracts; ban file paths and line numbers because artifacts outlive code layout.
- `skills/engineering/triage/OUT-OF-SCOPE.md` — a rejection knowledge base: one file per rejected concept with durable reasons, matched at triage to dedupe recurring requests; deferrals and already-implemented closures excluded.
- `skills/engineering/wayfinder/SKILL.md` — fog-of-war planning: "Fog or ticket? Whether you can state the question precisely now, not whether you can answer it now"; map as index-not-store; self-cancels when no fog surfaces.
- `skills/engineering/codebase-design/DESIGN-IT-TWICE.md` — 3+ parallel subagents each given a different design constraint, compared on depth/locality/seam placement.
- `CLAUDE.md` — router-must-not-lie: any skill change forces a re-sync of the routing doc.
- Weaknesses observed (self-documented in `docs/engineering/implement.md`): review runs inside the authoring session and can review an empty diff; nothing acts on findings; `implement` never closes the ticket; parallel implementation unsupported, with a git-corruption anecdote.

## github/spec-kit — closest structural relative; template-as-prompt engineering with fixed ceremony and no independent contexts

**The spec → plan → tasks pipeline maps directly onto spec → plan → tickets, executed through rigid templates that police abstraction level — but ceremony is constant regardless of task size, validation runs in the authoring context, and human approval is never explicit.**

- `templates/commands/specify.md` + `clarify.md` — the field's most complete clarification mechanic: budget of max 3/5 questions priority-ordered (scope > security/privacy > UX > technical); everything else becomes a documented Assumption, leftovers "Deferred with rationale"; one question at a time with a mandatory `Recommended: Option X` acceptable with "yes"; each answer immediately encoded into the owning spec section plus an append-only session log.
- `templates/plan-template.md` — Constitution Check gate plus a Complexity Tracking table: each violation needs "Why Needed" and "Simpler Alternative Rejected Because"; no silent waivers.
- `templates/commands/analyze.md` — constitution conflicts are "automatically CRITICAL and require adjustment of the spec, plan, or tasks — not dilution, reinterpretation, or silent ignoring"; requirement→task coverage math with deterministic finding IDs and a buildable-work filter.
- `templates/commands/converge.md` — code-vs-intent gap taxonomy: missing / partial / contradicts / unrequested; unrequested code is surfaced for review, never deleted; tasks file byte-for-byte unchanged when clean.
- `templates/commands/checklist.md` — "unit tests for English": checklist items interrogate requirement writing ("Is 'prominent display' quantified?"), hard ban on implementation-verification phrasing, ≥80% traceability floor.
- `handoffs:` frontmatter in every command — the pipeline as discoverable data, each stage declaring successors with pre-filled prompts.
- Weaknesses observed: no scaling down (no direct-ticket or spike route); no fresh-context critique or review; the only approval moments are inline Q&A and one soft "proceed anyway?"; tests opt-in in shipped templates despite the methodology essay's test-first rhetoric; ~60 lines of hook boilerplate per command dilutes instructions — a caution for skill design.

## gastownhall/gastown — the working answer to what the Coordinator hand-waves

**An orchestration runtime (Go, tmux, Dolt-backed "beads"), gate-averse by design, whose core lesson is architectural: the coordinator cannot be one long-lived agent.**

- `docs/design/convoy/mountain-eater.md` §2 — "no agent holds the thread": single-coordinator loops die at context compaction, so durable work-item state is the thread and every checker derives state fresh; the coordinator is layered — mechanical daemon for the happy path, per-area Witness monitors for failure patterns, periodic fresh-context Dogs for judgment, Mayor for strategy.
- `internal/cmd/sling.go` — the complete claim protocol: per-item lock, refuse-if-claimed, idempotent same-target re-claim, and auto-reclaim only when the holder's session is provably dead.
- `templates/polecat-CLAUDE.md` — the session-exit invariant: every implementation session ends with either a pushed branch or an explicit status reset, else a sweep resets the item to open (documented failure: 6–7 agents spawned onto one item without this rule).
- `docs/design/convoy/spec.md` — a periodic stranded-work scan re-feeds ready-but-unclaimed items and closes empty containers; the crash-recovery complement to event-driven dispatch.
- `docs/design/architecture.md` — Bors-style merge queue: batch pending MRs, rebase as a stack, test only the tip, bisect on red; merge rejection writes structured failure details into the work item so the retry reworks the existing branch; `--pre-verified` fast path when the worker already ran the gates; `integration/<epic>` branches land as one merge commit.
- `internal/formula/formulas/gate-bead-instructions.md` — review as a dependency-graph node: a verification item blocked by all implementation items, executed by a fresh agent with no authorship memory — "review happens" enforced mechanically, not by convention.
- `docs/design/escalation.md` — severity levels, acknowledgment, staleness detection with automatic re-escalation and severity bumping through a Deacon → Mayor → Overseer tier chain.
- Work-formula `implement` step — persist-findings-early: "code survives in git, but analysis exists only in your context window — persist to the bead before closing steps"; `branch-setup` step — ticket ID embedded in the branch name, never reuse a branch across items (documented mis-attribution failure mode).
- Weaknesses observed: no planning artifacts, routing, or pre-work critique; no default human review, finding protocol, or round caps; no durable-knowledge reconciliation (beads decay and compact, nothing promotes learning into docs); requires Go binaries, Dolt, tmux, daemons.

## What the field independently validates in the target design

**Four target-design choices were independently converged on or painfully rediscovered by the studied repos.**

- Fresh-context review with structural independence — coleam00 (`piv-review-pr`), addyosmani (doubt-driven), gastown (gate beads) all arrived at it separately.
- Two-severity findings with improvements-to-backlog — coleam00's factory judge had to rediscover exactly this after 4-level severity caused nit-blocking in its interactive loop.
- Vertical slicing as default — addyosmani's `planning-and-task-breakdown` carries a near-identical good/bad example; spec-kit's user-story phases with independent-test checkpoints are the same idea well executed.
- Disposable artifacts reconciled at Ship — spec-kit names the staleness risks and cannot resolve them; coleam00 built drift-patching skills to cope; permanence is the pattern's known failure mode.
- Three named human gates sits deliberately between addyosmani (gates at every transition, incompatible with autonomy) and gastown (no gates, escalation only).

## Gaps in the target design the field exposes

**Three gaps recur across independent designs; five more are cheap single-source adoptions.**

- Clarification mechanics — three repos independently built the same machine (spec-kit's budget + recommended options + answers-encoded-into-the-artifact; coleam00's GATE clusters; mattpocock's grilling frontier); the target Architect has only "ask immediately", with no protocol.
- Coordinator liveness — dead-holder reclaim, the session-ends-with-push-or-reset invariant, a stranded-work sweep, and merge-rejection feedback (all gastown) are missing from the target claim protocol; all are expressible as document rules without infrastructure.
- Role-prompt inoculation — anti-rationalization tables, red flags, and pressure evals (addyosmani); withholding the author's conclusion when briefing Critic/Reviewer and contract-misread-first finding classification (addyosmani); the target prompts state rules but don't defend them.
- Deviation-documentation contract (coleam00) — documented deviations as a reviewer-exempt category in the PR handoff.
- Process-improvement loop (coleam00) — nothing in the target workflow ever asks "what would have prevented this failure?".
- Rejection memory (mattpocock `.out-of-scope/`) — the backlog holds candidates; nothing holds durable "no"s, so rejections get re-litigated.
- Gate hygiene — hedged-approval rejection (addyosmani), escalation staleness rules (gastown), Complexity-Tracking-style exception ledgers (spec-kit).
- Sequential-bundle criterion — wayfinder's "can you state the question precisely now?" fog test (mattpocock) is crisper than a trigger list.

## Open questions

- Should clarification mechanics live in the Architect prompt, a shared skill, or the workflow doc — and does a question budget conflict with "material open questions block approval"?
- How much of gastown's liveness machinery is needed at 1–3 parallel implementers, and at what parallelism does serial merge-after-Accept become the bottleneck?
- Do ticket Context/Scope path lists need a staleness rule (mattpocock bans paths in durable artifacts; bundles are short-lived but can sit shaped for a while)?
- Is a spec-kit-style constitution redundant given AGENTS.md + decision records, or is its "adjust the artifact, never dilute the principle" enforcement rule worth adopting on its own?
- Where would a process-retro loop (opportunity-scan analog) attach — Ship, or a standing Discover activity?
