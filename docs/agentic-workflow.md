# Agent Coding Workflow

How work moves from idea to shipped. This doc owns the **process**: stages, gates, loops, and where the human sits. [docs-structure.md](docs-structure.md) owns the **artifacts** — which documents exist, what they contain, where they live. When a question is about a document, that doc wins; when it's about sequence or approval, this one.

## The loop

```text
discover ⇄ shape                      gate: human picks the candidate
    ↓
  shape                               gate: Open questions empty
    ↓                                       + human approves the decomposition
implement ⇄ verify        per ticket  gate: done-when commands pass (agent)
    ↓                                       + reconcile diff in the same PR
review → fix → re-verify ↺            gate: human approves
    ↓
  ship                                gate: durable docs absorbed,
                                            bundle deleted, main green
```

Five stages. Verify and reconcile appear in the diagram but are deliberately **not** stages — see [Verify is a gate](#verify-is-a-gate-not-a-stage) and [Reconcile is an obligation](#reconcile-is-an-obligation-not-a-stage).

Gates must be checkable. "Is the design good?" is not a gate — that is what review is for.

## Stages

| Stage     | Purpose                                                                            | Output                             | Exit approved by                   |
| --------- | ---------------------------------------------------------------------------------- | ---------------------------------- | ---------------------------------- |
| Discover  | Fill the backlog with candidates; pick one to pursue                               | A picked candidate (line or brief) | Human picks                        |
| Shape     | Turn the picked candidate into a design and small, verifiable work items (tickets) | `design.md` + the first tickets    | Critic challenges → human approves |
| Implement | Execute one ticket in a dedicated branch/worktree                                  | A verified, reconciled change set  | Agent (gates pass)                 |
| Review    | Judge the diff: correctness, architecture, security, requirement fit               | Findings or approval               | Human approves                     |
| Ship      | Merge/release, absorb docs, delete the bundle, record follow-ups                   | Shipped outcome, traceable record  | — (approved at review)             |

### Discover

Two halves, named by where they end: **gather** activities end as backlog lines, **pick** activities end at the Pick gate. An activity that doesn't clearly end at one of those two points doesn't belong in Discover.

Gathering fills the funnel:

- **Audit** — scan the codebase for simplification, quality, reliability, and security opportunities. Findings become backlog lines; evidence worth keeping goes to `research/` (as `audit-*.md`).
- **Research** — investigate the world: new versions, migration paths, best practices, how another repo solved something. The write-up lands in `research/`; anything actionable it reveals becomes a backlog line pointing at it.

Gathering never chooses. Its candidates enter the funnel like every other idea — the backlog is the single, unsorted collection point, and nothing bypasses it.

Picking settles on exactly one candidate:

- **From the backlog** — the human scans the list and picks a line. A crisp line goes straight to shaping; a vague one goes through an interview first.
- **Interview** — the user brings intent directly. The conversation challenges vague requirements and distills them into `work/candidates/<id>-<slug>/brief.md`: the problem in the user's framing, not a solution. Writing a brief is itself a judgment — it claims the item needs shaping. If the intent fits in a backlog line, it wasn't a brief; write the line instead.

The Pick gate is source-agnostic: the human picks one candidate, wherever it came from. An agent can gather, annotate, and propose — what's worth doing is a judgment about priorities the agent doesn't own.

### Shape

Two roles, deliberately separated:

- **Author** — reads the brief (when one exists) and writes `design.md` (target state, non-goals, open questions, acceptance criteria) and the first two or three tickets, inside the candidate's bundle. Read-only on code: an agent that _can_ write code will write code and retrofit the design to it.
- **Critic** — a **separate agent with a fresh context** that attempts to break the plan: missed states, API contracts, security, performance, testability, scope creep. The author cannot find the holes in a plan it just rationalized into existence; a critic that shares the author's context inherits the author's blind spots.

Migration and rollout needs are sequencing rationale — ship behind a flag, reversible migration before the code that needs it — so they land in `plan.md`, which exists for exactly that. A risk the design can't absorb becomes an Open question; there is no hand-wavy Risks section.

Exit is two checks: **Open questions is empty** (checkable without judgment — the section has no content), and **the human has approved the decomposition**. The second is a human gate because bad slicing is cheap to fix in a list and expensive to fix across twelve started tickets.

On exit, the bundle moves from `candidates/` to `planned/`, and `brief.md` freezes: from here on the brief is the record of what was asked, the design is what's being done about it, and when they disagree the design wins.

### Implement

One ticket per session, fresh context, dedicated branch or worktree. The agent reads the design and its ticket, respects "Not in this ticket", and works until the ticket's done-when conditions pass.

The exit gate has two halves, both in the same PR:

1. **Verify** — the repo's deterministic checks pass — typecheck, lint, unit/integration/e2e tests, build, migrations (up _and_ down) where touched — plus the ticket's own done-when commands, and a manual smoke test when the ticket calls for one. The PR records the exact commands, their output, and any check that was skipped and why: a stated gap is reviewable, an omitted one is a trap. Evidence, not claims.
2. **Reconcile** — colocated `README.md`s updated if the change made them inaccurate; `design.md` amended if implementation proved it wrong.

If a new open question appears mid-ticket: stop, add it to `design.md → Open questions`, don't decide it unilaterally.

### Review

Fresh context, no authorship of the diff under review. Judges what verify cannot: architecture fit, requirement fit, regressions, security, UX, edge cases, maintainability — and whether the reconcile half of the PR is honest (does the README diff actually match what the code now does?).

The loop: **review → fix findings → re-run affected verification → review again if the fix was material → approve.** Re-verification after fixes is not optional; a fix that breaks a done-when condition is a regression wearing a review-approval costume.

This is the last human gate. Everything after approval is mechanical.

### Ship

- Absorb what remains of `design.md` into the durable docs, then **delete the bundle** (git history keeps it)
- Clean commits, PR summary recording the verification evidence
- Merge/release; confirm main is green
- Capture follow-ups as backlog lines — not as a lingering half-open bundle

## Verify is a gate, not a stage

The earlier six-stage draft had Verify as a stage between Implement and Review. It's demoted to a gate, for two reasons:

1. **It was already inside Implement.** "CI green, per ticket" was Implement's own exit condition, so a separate Verify stage ran the same commands twice and owned neither run.
2. **A stage earns fresh context; deterministic commands don't benefit from it.** Fresh context exists to prevent an agent from grading its own homework — but `pytest` grades homework the same in any context. The part of the old Verify stage that _did_ involve judgment ("checks acceptance criteria") belongs to Review, which already has the fresh context and the mandate.

What survives from the old Verify stage is its best idea: **evidence over claims**. The implementer must paste exact commands and output into the PR, and Review may re-run any of them. An agent saying "tests pass" is a claim; a transcript is evidence.

## Reconcile is an obligation, not a stage

Reconcile appeared in three contradictory places across the earlier drafts: as a bullet inside Ship, as a standalone stage between Review and Ship, and (implicitly) in the pre-PR checklist. The checklist version wins, generalized: **reconcile is an obligation with two trigger points, enforced by gates rather than positioned as a stage.**

- **Per ticket, before review.** The same-PR rule forces this ordering: if doc updates must land in the PR, they exist _before_ the PR is reviewed — which also means the reviewer checks them, instead of doc changes slipping in post-approval, unreviewed. A reconcile stage placed after Review is self-contradicting.
- **At ship, for the feature.** Absorbing the design into durable docs and deleting the bundle can only happen once, at the end, when the design has stopped changing.

Neither point deserves stage rank because a stage implies a fresh context and a session boundary, and reconcile needs the opposite: the context of whoever just made the docs wrong. What made "reconcile as a stage" attractive was fear of it being skipped — but the protection is gates that check for it (review checks the README diff, ship checks the bundle deletion), not a box in the pipeline diagram.

## Sessions and handoffs

**The artifacts are the handoff protocol.** Fresh context per stage only works because everything a stage needs is written down. The corollary is a design test: if a stage boundary needs more than the artifact carries, the artifact template is missing a section — the handoff mechanism is not the problem.

Three mechanisms, one per situation:

| Mechanism        | When                                                         | Carrier                                        |
| ---------------- | ------------------------------------------------------------ | ---------------------------------------------- |
| Artifact handoff | Stage boundaries (planned)                                   | `brief.md`, `design.md`, ticket, PR + evidence |
| Sub-agent        | Within a stage, when the caller needs the result to continue | The sub-agent's report (e.g. critic findings)  |
| Handoff document | Unplanned breaks — a session dies mid-stage                  | A handoff file, outside the repo               |

The decision rule: a **sub-agent** when the calling session continues (the critic reports back to the author); a **new session** when the previous context is a liability (implementing after shaping); a **handoff document** only when a session ends before reaching a stage boundary. The handoff document is the exception path — its content is disposable and personal, it lives outside the repo, and it never substitutes for a stage artifact.

Still open: where review findings and verification evidence live durably — PR description and comments, or files in the repo.

## Rules that make the stages real

- **One creator per artifact type.** Interview creates briefs, shape creates designs and tickets, implement amends them — nothing is created twice. A stage writes only the artifact types in its row of the reads/writes table (docs-structure §3).
- **Fresh context per stage.** New session for shaping; new session per ticket implementation. An agent that wrote the design an hour ago will reinterpret it to match whatever it just built. The rule targets context that *biases* — interview flowing into shaping in one session is fine, because the shared context is the user's own words and the brief on disk is the checkpoint.
- **No write access during shaping.** An agent that _can_ write code will write code and retrofit the design to it.
- **Shaping cites real files.** A design that doesn't reference actual paths in the repo describes an imaginary architecture.
- **Human reviews the decomposition** before tickets are created. Bad slicing is cheap to fix in a list and expensive to fix across twelve started tickets.
- **Reconcile is enforced by gates, not conscience.** Review checks the doc diff; ship checks the bundle deletion. Skip it three times and the docs are actively misleading.

## Where the human sits

Three approvals, and only three:

1. **Pick** (Discover → Shape): what is worth doing
2. **Plan** (Shape → Implement): is this the right target state, sliced correctly
3. **Accept** (Review → Ship): is the change good

Everything between those points is agent-crossable on deterministic gates. Adding human checkpoints inside Implement defeats the purpose; removing any of the three hands the agent a judgment it doesn't own — priorities, architecture, or acceptance.

## Mechanism mapping

This doc stays tool-agnostic. The Claude Code realization lives next to the things it describes — links only:

- [skills/README.md](../skills/README.md) — the skill for each role: invocation, inline vs. fork, settings
- [agents/README.md](../agents/README.md) — the subagents forked skills run in: tools, preloaded knowledge
