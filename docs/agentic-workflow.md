# Agent Coding Workflow

## Steps

| Stage     | Purpose                                                                                                                | Output                                 |
| --------- | ---------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| Discover  | Find valuable work: codebase audit, bugs, backlog triage, or feature interview                                         | A prioritized, well-framed candidate   |
| Shape     | Define scope, acceptance criteria, technical approach, risks, and non-goals; challenge/validate the plan               | A feature brief + approved plan        |
| Implement | Execute the approved plan in a dedicated branch/worktree                                                               | A working change set                   |
| Verify    | Run deterministic checks: typecheck, lint, unit/integration/e2e tests, build, migrations, manual smoke test if needed  | Evidence: command results and any gaps |
| Review    | Inspect the diff against architecture, requirements, security, UX, edge cases, and maintainability                     | Findings or approval                   |
| Ship      | Apply accepted findings, re-verify affected areas, commit/PR/merge/release, update feature status and archive the plan | Shipped outcome and traceable record   |

### Discover

- codebase audi: Finds simplification, quality, reliability, and security opportunities; ranks them by impact/effort
- backlog-triage : Turns ideas/issues into scoped, prioritized feature candidates
- interview: Interviews you, challenges vague requirements, produces a concise feature brief

### Shape

- to-work: writes the work (design, plan, tickets/), acceptance criteria, non-goals, risks, migration/rollout needs
- critique work: Attempts to break the plan: missed states, API contracts, security, performance, testability, scope creep (A separate critic is valuable here -> sub-agent new context window)

### Implement

- Implements the approved plan or one ticket incrementally
- also test -> gate: CI green, per ticket

### Verify

- Runs the defined deterministic commands; checks acceptance criteria; reports exact evidence and failures

### Review

- Reviews the diff for correctness, architecture, regressions, security, maintainability, and requirement fit

Your review loop is exactly right:
Review → fix findings → re-run affected verification → review again if the fix is material → Ship

### Ship

- Reconcile: durable docs updated
- Prepares clean commits/PR summary, records verification, updates feature status, identifies follow-ups
