# Lifecycle

The workflow has five lifecycle stages. A stage exists when purpose, actor or context, permissions,
output, or exit authority changes materially.

```text
Discover ──Pick──▶ Shape ──Plan──▶ Implement ──verify + reconcile──▶ Review
   ▲                  │                 ▲                              │
   └──── clarify ─────┘                 └──────── fix request ─────────┘
                                                                        │
                                                                     Accept
                                                                        ▼
                                                         next ticket or Ship
```

The stages stay fixed for every kind and size of work. The shaping route changes which artifacts
Discover and Shape produce, not the lifecycle.

| Stage     | Readiness movement                            | Primary output                           | Exit authority       |
| --------- | --------------------------------------------- | ---------------------------------------- | -------------------- |
| Discover  | unknown or unselected → understood and picked | picked intent or evidence                | human Pick gate      |
| Shape     | picked → approved and executable              | complete bounded bundle                  | human Plan gate      |
| Implement | executable ticket → verified and reconciled   | implementation PR                        | deterministic checks |
| Review    | verified → independently judged and accepted  | findings or accepted change              | human Accept gate    |
| Ship      | accepted bundle → durable shipped outcome     | integration target green; bundle deleted | prior Accept gates   |

Work may enter at the readiness level it already has. A settled human request can pass through
Discover as a direct pick; uncertain work may need research or a spike. No stage creates an artifact
solely to prove that the stage happened.

## Coordination

Coordination is split between the human and deterministic skill scripts — there is no coordinator
agent and no standing system that watches state and reacts on its own: an autonomous agent in the
dispatch position could infer or erode human gates, so that implementation is prohibited by design.

Mechanically, everything below runs inline inside a human-launched chat session — see [Running the
workflow](../docs/walkthrough.md) for the concrete session/tab model. A skill script only runs when a human
or an already-running session invokes it.

**The human dispatches stages.** Discovery, shaping, each ticket's implementation, and Ship start
on explicit human dispatch. Every stage ends by reporting the suggested next move — the
now-unblocked tickets, safe parallel sets from the plan, or the human gate that is due — but a
stage-level suggestion dispatches nothing; only the human starts the next stage. When the human
delegates the choice ("take the next ticket"), the invoked skill selects the lowest-numbered
unblocked `todo` ticket.

**A stage's own skill script auto-dispatches its fixed inner loop.** No human trigger sits between
the substeps a stage's contract already defines — each dispatch is the current session's skill
script starting the next subagent inline, not a separate coordinator reacting after the fact:

- Shape: completing a draft bundle automatically dispatches the fresh-context Critic; the Architect
  revises and re-critique follows until no blocker remains, then the bundle goes to the human Plan
  gate.
- Implement and Review: opening or updating the PR automatically dispatches a fresh-context review
  round; a round with findings automatically dispatches a fix-mode Implementer, whose response
  automatically dispatches the next round. The loop ends only per the convergence rules — ready for
  human review, escalation, or the round limit — and always terminates at the human Accept gate or
  an escalation, never at a merge.

Inner dispatches follow the stage contract deterministically; they carry no product judgment and
cannot cross a human gate.

**Deterministic skill scripts own transition mechanics.** Skill scripts — never prompts, never an
agent's judgment — execute state transitions so they are serialized and auditable:

- **Claim:** check that every dependency is `done`, then create the ticket branch on the remote at the
  current head of the branch the ticket's PR will merge into — the bundle branch for a multi-ticket
  bundle under `bundle-branch`, otherwise the configured integration target (see [Work
  bundles](./bundle.md)) — and cut its worktree from that exact state. Creating the branch _is_ the
  claim, so git serializes it: parallel claims on different tickets never collide, and a second claim
  on the same ticket fails and aborts. A multi-ticket bundle's first claim also creates the bundle
  branch; [Git mechanics](./git-mechanics.md) owns both procedures, and
  [`docs/conventions/git.md`](../docs/conventions/git.md) declares the values they use.
- **Dispatch mechanics:** start each Architect, Critic, Implementer, and Reviewer with the required
  fresh context and permissions, and record review-round numbers for fix and re-review runs.
- **Merge:** after human Accept, merge according to the repository's Git conventions. The merge is the
  last write — `done` follows from it and is never recorded afterward.

These skill scripts never own product or technical judgment and cannot pass a human gate: Pick,
Plan, and Accept are explicit human decisions, observed and never inferred. The Implementer never
selects or claims its own ticket; claim and merge transitions live in scripts because a prompt-only
instruction cannot guarantee serialization.

## Finding protocol

Critic and Reviewer findings use the same severities:

- **Blocker:** an evidence-backed contract, correctness, safety, executability, or gate violation that
  must be resolved before the next human gate.
- **Concern:** an evidence-backed material risk or tradeoff that the human may consciously accept at
  the next gate after its consequence is explicit.

Do not create minor or suggestion findings. A useful improvement that does not affect the next gate
is a backlog candidate, never a finding. A read-only Critic or Reviewer reports it separately; skill
scripts record reported candidates that satisfy the repository's backlog format without
prioritizing or promoting them.

## 1. Discover

**Objective:** reduce enough uncertainty for the human to decide whether the work is worth shaping.

Discovery may include intake, repository inspection, research, reproduction, investigation, or a
time-boxed spike. Evidence is not commitment: an agent may add a finding to the backlog, but it may
not promote its own finding into Shape.

**Pick gate:** the human selects the problem or outcome. A direct, settled human request satisfies
the gate without first becoming a backlog item.

**Narrowing:** once picked, almost every entry point still needs a conversational pass — clarifying
problem, desired outcome, and edge cases — before remaining uncertainty is low enough to shape. It
stays conversational and produces no artifact; skip it only when the pick was already fully settled
and unambiguous going in. See [Running the workflow](../docs/walkthrough.md) for how this runs
session-to-session.

Done when the human has picked work whose remaining product and technical uncertainty can be
resolved during Shape.

## 2. Shape

**Objective:** create one critic-reviewed, human-approved bundle that every assigned agent can
execute without silently making product or cross-ticket design decisions.

Select the route using [Shaping routes](./shaping-routes.md), the single owner of route selection and
sequential-bundle criteria.

Intent, planning, and ticket generation are feedback substeps, not stages. A plan or ticket that
exposes a missing behavioral decision returns to the intent artifact before Shape continues.

**Keep bundles bounded:** Shape creates the complete executable ticket set for one coherent outcome.
An outcome too large to shape honestly at once splits into sequential bundles by those criteria,
never into a speculative ticket backlog inside one bundle.

**Run conditions:** the Architect runs in the human-facing planning session with read access to the
repository and write access only to the draft bundle; enforce that boundary with tools or hooks, not
only the prompt. The Critic runs in a fresh context with no authorship of the bundle and no
file-writing or approval capability, withheld structurally rather than by instruction.

**Critique is mandatory before approval:** a fresh-context, read-only Critic attacks requirement
coverage, architecture, slicing, dependencies, risk, and testability. The Architect owns revisions;
the Critic supplies findings, never fixes or approval.

**Plan gate:** after critique, the human approves the outcome, binding constraints, technical
direction when present, complete ticket decomposition, dependency graph, and test strategy. Material
open questions block approval.

Done when every approved ticket is executable in one agent session, has objective done-when
evidence, and introduces no requirement or cross-ticket decision absent from approved intent.

## 3. Implement

**Objective:** turn one approved ticket into a verified and reconciled implementation PR.

**Run conditions:** the Implementer runs in a fresh context once per dispatched ticket, and again in
fix mode when a review round returns findings. Each run receives the approved bundle, its assigned
ticket, repository conventions, the current PR when one exists, and the branch and worktree the claim
already prepared. It never selects or claims its own ticket.

The Implementer works in a fresh session on one ticket, branch, and worktree. It reads the approved
intent, optional plan, ticket, relevant durable docs, and repository conventions before editing.

Implementation includes:

1. Start from the one dispatched ticket whose branch and worktree the claim already created.
2. Establish the ticket's required pre-change evidence. For changed behavior, normally write the
   behavior test and observe the expected failure; the ticket may specify other evidence when a red
   test is inapplicable or Shape supplied a locked test.
3. Implement only the approved ticket and bounded local support work.
4. Run every ticket done-when command plus canonical repository checks.
5. Reconcile affected durable docs, terminology, intent corrections, and remaining tickets in the
   same PR.
6. Open the PR using the handoff contract below; leave the ticket `doing` while Review is pending.

A factual correction that preserves approved intent is made visible in the PR. A change to behavior,
binding architecture, decomposition, security, migration, compatibility, or acceptance criteria
returns to the Plan gate.

### PR handoff contract

The PR is the main implementation and review surface, but not the source of approved intent. Its
body must contain:

- immutable commit permalinks to the complete approved bundle and exact implemented ticket
- the delivered scope
- verification commands and results from the current PR head
- reconciliation performed
- known limitations or residual risk

Do not use branch-relative bundle or ticket links. Keep the body current when the head or verification
evidence changes; if the Plan gate is repeated, replace the planning links with permalinks to the new
approved version.

Done when every required check passes at the PR head and the change plus reconciliation is ready for
an independent Reviewer.

## 4. Review

**Objective:** independently judge what implementation and deterministic verification cannot.

Review runs in a fresh context with no authorship of the diff. The Reviewer is structurally
read-only, reruns required checks, reads changed code in context, and applies the judgment method and
output contract in [Reviewer](../agents/reviewer.md).

```text
Implement → verify + reconcile → open PR
                                      │
                                      ▼
                                Review round
                         ┌───────────┴───────────┐
                         ▼                       ▼
                  fix required              no blockers
                         │                       │
                         ▼                       ▼
           fresh Implementer (fix mode)   final review summary
                         │                       │
                         ▼                       ▼
             verify + PR response          human Accept
                         │                       │
                         └──────► next Review        merge + complete
```

Each Reviewer starts in fresh context and reviews the complete PR at its exact head SHA. It posts one
structured round summary to the PR and uses inline comments only where a precise code location adds
evidence. Findings receive stable IDs such as `R1-F1`; later rounds preserve those IDs when recording
their disposition.

A fix request starts a fresh Implementer context in fix mode and returns the ticket to Implement
without changing its `doing` status. The Implementer checks every finding against the approved
intent, plan, and ticket rather than blindly following the comment. It fixes the finding, rebuts it
with evidence, or escalates it because resolution requires a material planning decision. After
rerunning all required checks, it posts one PR response mapping every finding ID to its disposition,
changes, verification results, and new head SHA.

The next Reviewer checks every prior disposition and reviews the complete PR again, not only the
latest patch. New findings are limited to material issues introduced by the fix or genuinely missed
earlier; a later round must not move the goalposts to personal preferences. Review never edits,
approves, or merges the change.

### Convergence and round limit

One Reviewer run is one review round. Three rounds are the normal maximum. Failure to converge by the
third round usually signals unclear intent, architectural disagreement, unstable verification, or a
change that should be reshaped; report that diagnosis to the human. A fourth or fifth round requires
explicit human direction. Five is the absolute maximum without returning to Shape or otherwise
changing the workflow.

The limit is an escalation condition, never an acceptance condition. Reaching it cannot waive a
blocker. A PR is ready for human review only when every blocker is fixed, closed by the Reviewer after
an evidence-backed rebuttal, or resolved through an explicit human planning decision. Open concerns
are carried visibly to the human Accept gate.

The final Reviewer comment is tied to the reviewed head SHA and states:

- ready for human review
- independent verification commands and results
- every finding ID and final disposition
- every open concern and its consequence
- remaining limitations or material areas that could not be verified

**Accept gate:** the human accepts the independently reviewed PR and explicitly disposes any open
concerns. Acceptance authorizes the merge, performed according to the repository's Git conventions;
the ticket reads as `done` once that merge lands on the PR's target branch.
Accept applies to the exact reviewed head SHA; any subsequent implementation change invalidates it
and requires verification and Review again.

A review round ends with either findings returned to Implement or a final summary for the human. The
Review stage ends only when the human accepts the change and it merges.

## 5. Ship

**Objective:** land the complete accepted outcome and remove its temporary planning record.

Ship begins only when every ticket is `done` and the human triggers it.

Ship:

1. Confirms canonical checks pass on the state holding every merged ticket — this gates every step
   below.
2. Reconciles remaining bundle knowledge into durable system docs, terminology, and decision
   records.
3. Converts unfinished or newly discovered work into backlog entries.
4. Deletes the complete bundle from the integration state.
5. Lands that final state on the configured integration target according to the repository's branch
   strategy.
6. Removes bundle branches and worktrees.

Git history preserves the work record; there is no shipped-bundle archive.

Done when the outcome is on the integration target, canonical checks pass there, durable
documentation is current, and no bundle artifact, branch, or worktree remains.

## Human authority

Only the human may pass these gates:

1. **Pick:** this work is worth shaping.
2. **Plan:** this is the right outcome, approach, decomposition, and test strategy.
3. **Accept:** this implementation is acceptable.

Agents may cross deterministic checks between gates. They may not infer, self-grant, or bypass a
human gate. Ship adds no fourth approval; it executes the outcome already accepted ticket by ticket.

## Test ownership

- **Architect/Shape owns test intent:** observable acceptance criteria, the test seam, required test
  levels, and risk-specific cases. It does not normally author test code.
- **Critic owns pre-implementation challenge:** identify coverage gaps, untestable criteria, weak
  seams, and missing failure or boundary cases.
- **Ticket owns required evidence:** map the behavior it delivers to exact verification commands and
  expected outcomes.
- **Implementer owns test code by default:** for changed behavior, add or adjust the behavior test and
  observe its pre-change failure when meaningful, then implement and add honest supporting tests. For
  non-behavioral work, the ticket names equivalent pre-change evidence.
- **Reviewer owns independent judgment:** rerun required evidence and judge whether author-written
  tests constrain the approved behavior. Passing tests are evidence, not self-approval.
- **Repository CI owns global gates:** existing test, lint, type, build, and policy commands remain
  canonical rather than being copied differently into each spec.

For a high-risk contract, security boundary, or regression, Shape may require separately authored,
locked black-box acceptance tests. A verifier independent of the Implementer writes them before
implementation; the Implementer may run but not modify them. This is an explicit exception, not the
default.
