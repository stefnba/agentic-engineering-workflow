# Workflow

The workflow has four lifecycle stages. They are stable regardless of work size; adaptive sizing
changes the work performed inside a stage, not the stages themselves.

```text
Discover → Shape → Implement + Review → Ship
   │         │              │            │
   ▼         ▼              ▼            ▼
 Pick       Plan          Accept       shipped
 human      human          human       outcome
```

The uncertainty model is a readiness model inside this lifecycle:

```text
UNKNOWN ──Discover──▶ KNOWN ──Shape──▶ EXECUTABLE
                                         │
                              Implement + Review
                                         ▼
                              VERIFIED + ACCEPTED
                                         │
                                        Ship
                                         ▼
                                      SHIPPED
```

Work may enter at the readiness level it already has. A well-understood request can pass through
Discover as a direct human pick; a high-uncertainty request may need research or a spike before it
is ready for Shape. No stage manufactures an artifact solely to prove the stage happened.

## 1. Discover

**Objective:** reduce enough uncertainty for the human to decide whether the work is worth shaping.

Discovery may include intake, repository inspection, research, reproduction, investigation, or a
time-boxed spike. Its output is settled intent or evidence, not an implementation plan.

**Pick gate:** the human chooses the candidate. An explicit, already-settled human request satisfies
this gate directly; an agent never promotes its own finding into work.

Done when the human has picked a problem or outcome whose remaining uncertainty can be resolved in
Shape.

## 2. Shape

**Objective:** create one approved work bundle that is executable without silent product or
cross-cutting design decisions.

Choose the lightest artifact set that makes implementation reliable:

- Direct, low-impact work: one ticket.
- Behaviorally significant work with obvious decomposition: intent/spec plus ticket(s).
- High-impact or non-obvious decomposition: intent/spec, engineering plan, then tickets.
- Refactor or migration: target architecture or invariants, plan, then tickets.

Spec, plan, and ticket generation form a feedback loop. Planning or decomposition that exposes a
missing behavioral decision returns to the intent artifact before proceeding.

**Critique is mandatory before approval:** a fresh-context, read-only critic attacks requirement
coverage, architecture, slicing, dependencies, risks, and testability. The Architect resolves valid
findings and returns human judgment calls to the human. The author and critic cannot approve the
bundle.

**Plan gate:** after critique, the human approves the target outcome, technical direction when one
exists, ticket decomposition, dependency graph, and test strategy. Material unresolved questions
block approval.

Done when the approved bundle contains the minimum artifacts needed for every ticket to be executed
and verified independently.

## 3. Implement + Review

**Objective:** turn each approved ticket into an independently verified and human-accepted change.

For each ticket:

```text
implement → verify → review → fix → re-verify → review ↺ → human accept
```

The Implementer works one ticket in one session and reconciles affected temporary and durable
documentation in the same change. A fresh-context, read-only Reviewer independently reruns required
checks and reports evidence-backed findings. Reviewer findings return to the Implementer; a fix that
changes approved intent or decomposition returns to the Plan gate.

**Accept gate:** the human accepts each reviewed ticket change. Neither Implementer nor Reviewer may
approve or merge their own work.

Done when every ticket is accepted and merged into its configured integration target.

## 4. Ship

**Objective:** land the complete outcome and remove its temporary planning record.

Absorb still-relevant bundle knowledge into durable system documentation, terminology, and decision
records. Land the bundle on the default branch according to the repository's branch strategy,
confirm the default branch is green, convert follow-ups into backlog entries, then delete the entire
bundle. Git history preserves the work record; there is no shipped-bundle archive.

Done when the outcome is on the default branch, required checks pass, durable documentation is
current, and the bundle no longer exists in the working tree.

## Human authority

Only the human may pass these gates:

1. **Pick:** this work is worth shaping.
2. **Plan:** this is the right outcome, approach, decomposition, and test strategy.
3. **Accept:** this implementation is acceptable.

Agents may cross deterministic checks between gates. They may not infer, self-grant, or bypass a
human gate.

## Test ownership

- **Architect/Shape owns test intent:** observable acceptance criteria, the test seam, required
  test levels, and risk-specific cases. It does not normally author test code.
- **Critic owns pre-implementation challenge:** coverage gaps, untestable criteria, weak seams, and
  missing failure or boundary cases.
- **Ticket owns required evidence:** acceptance criteria addressed plus exact verification commands
  and expected outcomes.
- **Implementer owns test code by default:** write the behavior test first, observe it fail, implement
  the change, and add honest supporting tests.
- **Reviewer owns independent judgment:** rerun required evidence and judge whether author-written
  tests actually constrain the required behavior. Passing tests are evidence, not self-approval.
- **Repository CI owns global gates:** existing test, lint, type, build, and policy checks remain the
  canonical commands rather than being copied differently into every spec.

For a high-risk contract or regression, Shape may require separately authored, locked black-box
acceptance tests. A verifier independent of the Implementer writes them before implementation; the
Implementer may run but not modify them. This is an explicit exception, not the default.
