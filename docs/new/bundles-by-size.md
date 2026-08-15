# Tailor bundles by uncertainty and impact

This guide selects the lightest route through Discover and Shape. It never changes the five
lifecycle stages in [Workflow](./workflow.md): every approved ticket still passes through Implement,
independent Review, and human Accept; every completed bundle passes through Ship.

## Decision framework

Classify the work by uncertainty and impact, then increase rigor when coordination is high.

|                 | Low uncertainty                                                 | High uncertainty                                  |
| --------------- | --------------------------------------------------------------- | ------------------------------------------------- |
| **Low impact**  | ticket directly                                                 | investigation/spike → ticket                      |
| **High impact** | intent/spec → tickets; add plan if decomposition is non-obvious | discovery evidence → intent/spec → plan → tickets |

Coordination is a multiplier. Cross-service changes, shared schemas, migrations, several parallel
agents, or multiple rollout steps usually require a plan even when the desired behavior is clear.

Ask in order:

1. **Is the problem understood?** If not, Discover through reproduction, investigation, or a spike.
2. **Is the approved outcome obvious and bounded?** If not, write an intent artifact.
3. **Is the repository-grounded approach and decomposition obvious?** If not, write a plan.
4. **Can every ticket carry concrete done-when evidence now?** If not, split into sequential bundles.

No artifact is mandatory by name. Each artifact must remove a named uncertainty or establish an
execution boundary.

## Routes

### Direct ticket

Use when one agent can safely understand, implement, verify, and review the complete outcome in one
PR without a separate design decision.

Typical examples:

- low-risk configuration change
- small dependency update
- known bug with reproducible expected behavior
- narrow UI or API adjustment

The ticket contains complete intent: outcome, scope, constraints, evidence, and escalation triggers.

### Investigation or spike first

Use when diagnosis or feasibility is unknown. The deliverable is evidence and a decision, not
production code disguised as exploration.

Typical examples:

- intermittent production failure
- unexplained performance regression
- unfamiliar legacy behavior
- “would technology X work here?”
- operational tuning whose safe value is unknown

A successful result may be “do not proceed.” If implementation is warranted, the human picks that
result before Shape creates a bundle.

### Intent/spec plus ticket(s)

Use when observable behavior or binding constraints need approval, but the technical approach and
decomposition are straightforward from repository patterns.

Typical examples:

- small user-facing feature
- contained API addition
- bug that changes documented behavior
- security rule with one clear enforcement point

Do not manufacture a plan when it would merely repeat the tickets.

### Intent/spec, plan, and tickets

Use when impact, architecture, sequencing, migration, rollout, or coordination makes decomposition a
real design problem.

Typical examples:

- cross-service feature
- authorization or tenant-isolation change
- database migration with compatibility period
- large refactor with expand → migrate → contract steps
- major dependency upgrade with breaking changes
- parallel implementation across several slices

The plan is grounded in repository evidence and decomposes intent into vertical slices. It cannot
invent new behavior.

### Sequential bundles

Use for initiatives too large or uncertain to shape honestly as one executable ticket set. Approve a
coherent first outcome, implement and ship it, then shape the next bundle using what was learned.

Split rather than speculate when:

- later tickets depend on an unvalidated architectural assumption
- exact verification for later tickets cannot yet be stated
- the work contains multiple independently useful outcomes
- one Plan gate cannot meaningfully approve the whole dependency graph
- integration drift would dominate before the bundle ships

Do not use sequential bundles to evade complete shaping. Every individual bundle still has its full
ticket set and its own Plan gate before implementation.

## Work-type guidance

| Work type          | Default route                                   | Increase rigor when                                                |
| ------------------ | ----------------------------------------------- | ------------------------------------------------------------------ |
| Small feature      | intent/spec + ticket                            | public contract, permissions, or rollout is non-trivial            |
| Large feature      | intent/spec + plan + tickets                    | split into sequential bundles when later slices are speculative    |
| Known bug          | direct ticket with expected/actual/reproduction | diagnosis is uncertain or behavior change is contested             |
| Complex bug        | investigation → decision → ticket(s)            | root cause crosses services or requires migration                  |
| Refactor           | invariants/target + plan + tickets              | callers require staged compatibility or rollback                   |
| Dependency upgrade | direct ticket                                   | major-version breakage or ecosystem migration is broad             |
| Database migration | target/invariants + plan + tickets              | backfill, dual-write, rollback, or zero-downtime constraints apply |
| Security change    | security intent/threat model + plan + tickets   | almost always; visible behavior alone rarely covers the risk       |
| Prototype          | spike → evidence → decision                     | productionization becomes a separate picked bundle                 |
| Incident/hotfix    | minimal ticket → Implement → Review             | permanent fixes and root-cause work become later picked bundles    |

## Non-negotiable boundaries

Adaptive sizing removes unnecessary artifacts, not safeguards:

- Human Pick, Plan, and Accept authority never moves to an agent.
- Mandatory Critique still precedes the Plan gate.
- Material open questions never pass to an Implementer.
- Every ticket remains one session and one PR.
- Review remains fresh-context, independent, and read-only.
- Verification and reconciliation remain part of Implement.
- Ship still absorbs durable knowledge and deletes the complete bundle.
