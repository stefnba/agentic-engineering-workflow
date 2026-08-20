# Lifecycle

The workflow has five lifecycle stages. A stage exists when purpose, actor or context, permissions,
output, or exit authority changes materially.

```text
Discover ──Pick──▶ Shape ──Plan──▶ Implement ──verify + reconcile──▶ Review
   ▲                  │                 ▲                              │
   └──── clarify ─────┘                 └──────── fix request ─────────┤
                                                                       │
                                                                    Accept
                                                                       ▼
                                                              next ticket or Land
```

The stages stay fixed for every kind and size of work. The shaping route changes which artifacts
Discover and Shape produce, not the lifecycle.

| Stage     | Readiness movement                            | Primary output                           | Exit authority       |
| --------- | --------------------------------------------- | ---------------------------------------- | -------------------- |
| Discover  | unknown or unselected → understood and picked | picked intent or evidence                | human Pick gate      |
| Shape     | picked → approved and executable              | complete bounded bundle                  | human Plan gate      |
| Implement | executable ticket → verified and reconciled   | implementation PR                        | deterministic checks |
| Review    | verified → independently judged and accepted  | findings or accepted change              | human Accept gate    |
| Land      | accepted bundle → durable landed outcome      | integration target green; bundle deleted | prior Accept gates   |

Work may enter at the readiness level it already has. A settled human request can pass through
Discover as a direct pick; uncertain work may need research or a spike. No stage creates an artifact
solely to prove that the stage happened.

## Contents

- [Coordination](#coordination) — who dispatches what, and which transitions are scripts
- [1. Discover](#1-discover) · [2. Shape](#2-shape) · [3. Implement](#3-implement) ·
  [4. Review](#4-review) · [5. Land](#5-land)
- [PR handoff contract](#pr-handoff-contract) — what an implementation PR body must carry
- [Convergence and round limit](#convergence-and-round-limit) — when review stops
- [Human authority](#human-authority) — the three gates no agent may pass
- [Test ownership](#test-ownership) — which role owns which part of testing

Findings are governed separately: [Finding protocol](./finding-protocol.md) owns the severities,
what a finding must name, and what survives a round. Critic and Reviewer load it without loading
this document.

## Coordination

Coordination is split between the human and deterministic skill scripts — there is no coordinator
agent and no standing system that watches state and reacts on its own: an autonomous agent in the
dispatch position could infer or erode human gates, so that implementation is prohibited by design.

Mechanically, everything below runs inline inside a human-launched chat session, and a skill script
only runs when a human or an already-running session invokes it. Two kinds of session carry a bundle:

- **One session per bundle**, long-lived, runs Discover, Shape, and later Land. Its working directory
  stays on the integration target and never checks out a ticket or bundle branch — Land works in a
  detached worktree instead, per [Git mechanics](./git-mechanics.md). Keeping it open is
  convenient, not required — the bundle lives in git and every status is derived, so Land runs just
  as well from a fresh session.
- **One session per ticket**, in that ticket's own worktree, runs Implement and dispatches that
  ticket's Review rounds. It opens only once every ticket it depends on is `done`; tickets with no
  dependency between them run side by side. Review is dispatched from here as a fresh subagent: no
  shared message history, but the same worktree, which is why a Reviewer verifies the head SHA and a
  clean tree before judging.

**The human dispatches stages.** Discovery, shaping, each ticket's implementation, and Land start
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

- **Claim:** check that every dependency is `done`, then create the ticket branch and cut its
  worktree. Creating the branch _is_ the claim, so git itself serializes competing claims — no lock
  and no coordinator. [Git mechanics](./git-mechanics.md) owns the procedure, the branch a worktree
  is cut from, and bundle-branch creation.
- **Dispatch mechanics:** start each Architect, Critic, Implementer, and Reviewer with the required
  fresh context and permissions, and record review-round numbers for fix and re-review runs.
- **Merge:** after human Accept, merge the ticket PR into its target. The merge is the last write —
  `done` follows from it and is never recorded afterward. Landing a finished bundle branch on the
  integration target is a separate Land step; [Git mechanics](./git-mechanics.md) owns both merges
  and why only one of them is configurable.

These skill scripts never own product or technical judgment and cannot pass a human gate: Pick,
Plan, and Accept are explicit human decisions, observed and never inferred. The Implementer never
selects or claims its own ticket; claim and merge transitions live in scripts because a prompt-only
instruction cannot guarantee serialization.

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
and unambiguous going in.

Done when the human has picked work whose remaining product and technical uncertainty can be
resolved during Shape.

## 2. Shape

**Objective:** create one critic-reviewed, human-approved bundle that every assigned agent can
execute without silently making product or cross-ticket design decisions.

Select the route using [Shaping routes](./shaping-routes.md), the single owner of route selection and
sequential-bundle criteria.

Intent, planning, and ticket generation are feedback substeps inside Shape, not stages — a plan or
ticket that exposes a missing behavioral decision returns to the intent artifact before Shape
continues. [Work bundles](./bundle.md) owns that loop and the criteria that complete Shape.

**Keep bundles bounded:** Shape creates the complete executable ticket set for one coherent outcome.
An outcome too large to shape honestly at once splits into sequential bundles by those criteria,
never into a speculative ticket backlog inside one bundle.

**Run conditions:** the Architect runs in the human-facing planning session with read access to the
repository and write access only to the draft bundle; that boundary is prompt-level, not enforced.
The Critic runs in a fresh context with no authorship of the bundle and no file-editing capability,
withheld structurally; a shell stays available for reading the repository, so the rest of read-only
is prompt-level too.

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
   same PR — everything this diff made false or stale, which never defers to Land.
6. Open the PR using the handoff contract below; leave the ticket `doing` while Review is pending.

A factual correction that preserves approved intent is made visible in the PR. A change to behavior,
binding architecture, decomposition, security, migration, compatibility, or acceptance criteria
returns to the Plan gate.

### PR handoff contract

The PR is the main implementation and review surface, not the source of approved intent, and —
because Land deletes the bundle — the permanent bridge back to the planning record.
[Artifacts](./artifacts.md) owns both roles and why the links must outlive that record. Its body
must contain:

- immutable commit permalinks to the complete approved bundle and exact implemented ticket
- the delivered scope
- verification commands and results from the current PR head
- reconciliation performed
- known limitations or residual risk

A branch-relative URL is not a permalink: it can drift, and it breaks once Land removes the bundle
branch. The linked commit must stay reachable through merged-PR or integration-target history after
branch cleanup. Keep the body current when the head or verification evidence changes; if the Plan
gate is repeated, replace the planning links with permalinks to the newly approved version. On the
direct ticket route the bundle and ticket links may intentionally point at the same file.

Done when every required check passes at the PR head and the change plus reconciliation is ready for
an independent Reviewer.

## 4. Review

**Objective:** independently judge what implementation and deterministic verification cannot.

**Run conditions:** the Reviewer runs in a fresh context per round with no authorship of the diff
and no file-editing capability, withheld structurally rather than by instruction. Verification needs
a shell, so the rest of read-only — no push, approve, or merge — is prompt-level, not enforced.
Read-only binds the change, not the filesystem: build output, caches, and temp files are expected;
source, refs, branches, and PR state are not. Each run receives the PR number and the exact head
SHA to judge, and confirms against the forge that the SHA is the PR head and that the tree it inspects sits there with no tracked file
modified.

The Reviewer reruns required checks, reads changed code in context, and applies its judgment method
and output contract.

```text
Implement → verify + reconcile → open PR
                                      │
                                      ▼
                                Review round
                         ┌───────────┴───────────┐
                         ▼                       ▼
                   fix required             no blockers
                         │                       │
                         ▼                       ▼
           fresh Implementer (fix mode)   final review summary
                         │                       │
                         ▼                       ▼
             verify + PR response          human Accept
                         │                       │
                         │                       ▼
                         └──────► next Review    merge + complete
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
concerns; an accepted concern leaves a durable trace rather than evaporating, per
[Finding protocol](./finding-protocol.md). Acceptance authorizes the merge, performed according to
the repository's Git conventions; the ticket reads as `done` once that merge lands on the PR's
target branch.
Accept applies to the exact reviewed head SHA; any subsequent implementation change invalidates it
and requires verification and Review again.

A review round ends with either findings returned to Implement or a final summary for the human. The
Review stage ends only when the human accepts the change and it merges.

## 5. Land

**Objective:** land the complete accepted outcome and remove its temporary planning record.

Land begins only when every ticket is `done` and the human triggers it. Then, in order:

1. **Check the merged state.** Confirm canonical checks pass on the state holding every merged
   ticket, queried remotely — the bundle branch for a multi-ticket bundle, the integration target for
   a single-ticket one, whose only PR already merged there. This gates every step below. Then open
   the land: a detached worktree on the integration target with the bundle branch merged into it, so
   every step after this one works there ([Git mechanics](./git-mechanics.md)).
2. **Reconcile durable knowledge.** Move bundle-level knowledge no single ticket owned into durable
   system docs, terminology, and decision records. What a ticket's own diff made false was already
   reconciled in that ticket's PR; anything left here is knowledge that only became true once every
   ticket had landed.
3. **Reconcile the backlog.** Convert unfinished or newly discovered work into backlog entries, and
   retire the lines this bundle made true. Landing is what makes a candidate line false, so this is
   the only stage that reliably knows which ones.
4. **Delete the complete bundle** — a commit in Land's worktree, so what gets published carries no
   planning record. A single-ticket bundle has no worktree of its own, so its deletion commit goes
   directly to the integration target.
5. **Re-verify in Land's worktree.** Re-run canonical checks on the state steps 2–4 produced: it
   carries Land's own commits and the bundle merge, so no CI run has seen it. Land's own commits
   change documentation, backlog, and bundle files only; a Land step that would change behavior is
   not Land work and returns to the Plan gate.
6. **Publish that state** on the configured integration target — [Git mechanics](./git-mechanics.md)
   owns the land rules. **If the target moved while Land worked, merging it in returns to step 5**,
   because the merged state is one no check has run against. That loop repeats until the publish
   succeeds; skipping the re-run is what it exists to prevent.
7. **Remove the leftovers in git:** whichever ticket branches, bundle branch, and worktrees still
   exist — a repository that deletes branches on merge will have removed some already. Land's own
   worktree goes last and from outside it, since removing the tree a step is standing in fails.

Done when the outcome is on the integration target, canonical checks pass there, durable
documentation is current, and no bundle artifact, branch, or worktree remains.

## Human authority

Only the human may pass these gates:

1. **Pick:** this work is worth shaping.
2. **Plan:** this is the right outcome, approach, decomposition, and test strategy.
3. **Accept:** this implementation is acceptable.

Agents may cross deterministic checks between gates. They may not infer, self-grant, or bypass a
human gate. Land adds no fourth approval; it executes the outcome already accepted ticket by ticket.
Its own commits carry no behavior change and are re-verified before landing, so nothing reaches the
integration target unverified.

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
