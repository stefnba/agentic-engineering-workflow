# Tailor to size of work bundles

This document chooses the lightest route through Discover and Shape. It does not define alternative
lifecycle stages: every approved bundle continues through Implement + Review and Ship as defined in
[Workflow](./workflow.md).

Yes. The **Spec → Plan → Tickets → Agents** flow is excellent as a default, but I would _not_ make it mandatory for every change.

The key is to choose the **lightest workflow that still gives the agent enough context and gives you enough control**.

## The decision framework

I’d classify work by two dimensions:

|                 | Low uncertainty | High uncertainty               |
| --------------- | --------------- | ------------------------------ |
| **Low impact**  | Ticket directly | Spike / investigation → ticket |
| **High impact** | Spec → tickets  | Spec → plan → tickets          |

---

### For a tiny change

Small spec
↓
Ticket

### For a medium feature

Spec
↓
Plan
↓
Tickets

### For a large feature

Product spec
↓
Architecture / engineering plan
↓
Work breakdown
↓
Tickets
↓
Parallel agent execution
↓
Integration / verification

Works well:

New feature (multi-ticket) — the ideal case. Real design ambiguity, coordination across tickets, parallelization payoff. All three phases earn their cost.
Large refactoring / migrations — arguably even better than features. The plan substep's repo exploration is the work's foundation, and migration ordering plus "don't touch" boundaries are exactly what agents need to not break things. One adjustment: acceptance criteria become "behavior unchanged," so the plan should mandate characterization tests before any refactoring tickets run.
Cross-cutting changes (auth overhaul, logging standardization, dependency major-version bump) — high fan-out, high risk, needs the dependency analysis and phasing.

Works poorly:

Bug fix — the process inverts. You can't plan the fix before diagnosing, and diagnosis is most of the work. Alternative: an investigation-first loop — reproduce → diagnose → write a failing test → fix. The "spec" is just the repro steps and expected behavior; one ticket total.
Config change / small tweak — three documents for a one-line change is pure overhead. Alternative: one ticket with a verification command. Done.
Exploratory / uncertain work ("would approach X even work here?") — you can't spec what you don't understand yet. Alternative: a time-boxed spike ticket whose deliverable is the engineering plan itself. The spike feeds the pipeline rather than following it.
Hotfixes / incidents — speed beats process. Fix first, write the postmortem after, and backfill a proper ticket if follow-up work is needed.

---

So the question isn't really "Do we always need a spec?"

It's:

> **How much uncertainty and coordination does this change contain?**

---

## 1. New feature — Spec → Plan → Tickets

This is the canonical case.

Example:

> Add collaborative editing to documents.

There are likely questions around:

- user behavior
- data model
- API
- permissions
- concurrency
- UI
- migration
- performance
- rollout

So:

```text
Feature Spec
    ↓
Engineering Plan
    ↓
10–30 work items
    ↓
Agents
```

### Why it works

The spec gives agents a stable definition of **what we're building**.

The plan gives them the architectural decomposition.

The tickets provide bounded execution units.

### I would strongly recommend this workflow for

- new user-facing capabilities
- new APIs
- significant backend features
- changes spanning multiple services
- database/schema changes
- anything involving multiple teams/agents
- anything where you expect parallel implementation

---

## 2. Small feature — Spec → Ticket

Suppose:

> Add a "copy link" button to the document page.

A full engineering plan is probably bureaucracy.

You might have:

```text
Mini-spec
  ↓
One ticket
  ↓
Agent
```

The ticket can contain the requirements directly.

For example:

```text
Goal
Acceptance criteria
Constraints
Relevant existing code
Verification
```

No separate plan needed.

### Rule of thumb

If the decomposition is obvious:

> **Don't manufacture a plan.**

---

## 3. Config change — Ticket directly

Example:

> Increase the maximum request body size from 5 MB to 10 MB.

A spec would be excessive.

Use:

```text
Ticket
 ├── context
 ├── desired change
 ├── constraints
 ├── acceptance criteria
 └── verification
```

The agent can inspect the repository and make the change.

This also applies to things like:

- environment variables
- feature flag defaults
- CI configuration
- lint configuration
- dependency version bumps
- deployment configuration

### But there's an exception

If the config change has significant operational consequences:

> Increase production database connection pool from 50 → 500.

Now I'd want something closer to:

```text
Investigation
    ↓
Decision
    ↓
Ticket
```

because the difficult part isn't implementing the change. It's determining **whether the change is correct**.

---

## 4. Bug fix — usually Ticket directly

This is an important case where I would **not default to a spec**.

Suppose:

> Users occasionally receive duplicate invoices.

Start with a bug ticket:

```text
Bug
Expected behavior
Actual behavior
Reproduction
Evidence
Relevant logs
Acceptance criteria
```

Then the agent investigates.

```text
Bug ticket
    ↓
Agent investigation
    ↓
Root cause
    ↓
Implementation
    ↓
Tests
```

The agent may discover:

```text
"Duplicate invoices are caused by the retry path
not being idempotent."
```

The ticket can then be updated with the discovered root cause.

### Why not spec first?

Because you don't yet know what the system needs to do differently.

The **investigation itself is part of the work**.

---

## 5. Complex bug — Investigation/Spike → Fix ticket

This is where I'd introduce another artifact:

**Investigation / Spike**

Example:

> Production CPU usage has doubled, but we don't know why.

Don't ask an implementation agent to immediately "fix CPU usage."

Instead:

```text
Investigation
    ↓
Evidence
    ↓
Root cause
    ↓
Decision
    ↓
Implementation ticket(s)
```

The investigation might conclude:

> 80% of CPU is caused by an N+1 query introduced by X.

Now you have a well-defined implementation ticket.

This is especially useful for:

- performance problems
- intermittent production bugs
- distributed systems issues
- security investigations
- legacy code
- unclear requirements
- unfamiliar codebases

---

## 6. Refactoring — usually Plan → Tickets

Refactoring is interesting because you often know **where you want to go**, but there isn't necessarily a product spec.

Example:

> Extract the billing subsystem from the monolith.

A product spec doesn't make much sense.

Instead:

```text
Refactoring objective
       ↓
Engineering plan
       ↓
Migration tickets
       ↓
Agents
```

The plan might define:

```text
Current architecture
Target architecture
Invariants
Migration strategy
Compatibility requirements
Sequence
Rollback strategy
```

Then tickets:

```text
REF-001 Add new billing interface
REF-002 Move billing domain logic
REF-003 Introduce adapter
REF-004 Migrate caller A
REF-005 Migrate caller B
REF-006 Remove legacy implementation
```

### Critical difference

For refactoring, the "spec" is often better represented as **invariants + target architecture**.

For example:

> External behavior must remain unchanged.

> No caller may access the legacy billing implementation after phase 3.

Those are more useful to agents than a traditional product specification.

---

## 7. Dependency upgrade — Ticket directly

Example:

> Upgrade React from version X to Y.

Usually:

```text
Ticket
 ↓
Agent
 ↓
Tests
```

But if it's a major upgrade with breaking changes:

```text
Investigation
 ↓
Upgrade plan
 ↓
Tickets
```

For example:

```text
UPG-001 Assess breaking changes
UPG-002 Upgrade core dependency
UPG-003 Migrate deprecated APIs
UPG-004 Update test infrastructure
UPG-005 Remove compatibility layer
```

---

## 8. Security work — often Spec/Threat Model → Plan → Tickets

Security is one area where I'd deliberately be more rigorous.

Example:

> Add organization-level access control.

I'd want:

```text
Security requirements
       ↓
Threat model
       ↓
Architecture plan
       ↓
Tickets
```

Because otherwise an agent may satisfy the visible feature while missing:

- authorization bypasses
- privilege escalation
- tenant isolation
- audit requirements
- indirect access paths

The "spec" here should explicitly describe **security invariants**.

---

## 9. Database migration — Plan first

For something like:

> Split `users.name` into `first_name` and `last_name`.

I wouldn't necessarily need a product spec.

But I _would_ want a migration plan:

```text
Current state
    ↓
Target state
    ↓
Compatibility period
    ↓
Migration
    ↓
Backfill
    ↓
Code migration
    ↓
Cleanup
```

Then tickets.

Database work often needs sequencing and rollback considerations that a simple ticket doesn't capture well.

---

## 10. Exploratory/prototyping work — Spike → decision

Example:

> Can we use WebAssembly to speed up this processing pipeline?

Don't write a giant spec.

Instead:

```text
Question
 ↓
Spike
 ↓
Evidence
 ↓
Decision
```

The output might simply be:

> WebAssembly gives only 8% improvement and introduces significant operational complexity. Don't pursue it.

That's a **successful outcome** even though no production code was shipped.

This is a very useful distinction for agentic workflows.

---

## 11. Incident / hotfix — Ticket → implementation

During an incident, the workflow needs to become much shorter.

```text
Incident
 ↓
Mitigation ticket
 ↓
Agent / engineer
 ↓
Verification
```

You don't want:

```text
"Let's first produce a comprehensive spec,
then an architecture plan..."
```

when production is down.

Afterwards, you can create:

```text
Incident
 ↓
Root cause analysis
 ↓
Follow-up spec/plan
 ↓
Permanent fixes
```

---

## The resulting workflow taxonomy

I'd actually formalize the system around **five work modes**:

| Work type               | Workflow                                            |
| ----------------------- | --------------------------------------------------- |
| Large feature           | **Spec → Plan → Tickets → Agents**                  |
| Small feature           | **Mini-spec → Ticket → Agent**                      |
| Bug fix                 | **Ticket → Investigate → Fix**                      |
| Complex/unknown problem | **Spike → Decision → Plan/Tickets**                 |
| Refactoring             | **Target architecture/invariants → Plan → Tickets** |
| Config/change           | **Ticket → Agent**                                  |
| Dependency upgrade      | **Ticket** or **Investigation → Plan → Tickets**    |
| DB migration            | **Plan → Tickets**                                  |
| Security change         | **Security spec/threat model → Plan → Tickets**     |
| Incident/hotfix         | **Incident → Ticket → Fix**                         |

---

## One thing I'd change from our original model

I wouldn't make **"spec"** the universal top-level artifact.

I'd make **"intent"** the universal top-level concept.

It can take different forms:

```text
                    WORK
                     │
        ┌────────────┼────────────┐
        │            │            │
      Feature       Bug        Refactor
        │            │            │
       Spec       Ticket     Architecture
        │            │         + invariants
        │            │            │
        └────────────┼────────────┘
                     │
               Engineering
                  Plan
                     │
                  Tickets
                     │
                  Agents
```

That gives you a much more flexible system.

## And there's a deeper principle

I'd optimize the workflow around **uncertainty reduction**:

```text
UNKNOWN
   ↓
Investigation / Spike
   ↓
KNOWN
   ↓
Decision / Spec
   ↓
DECOMPOSED
   ↓
Plan
   ↓
EXECUTABLE
   ↓
Tickets
   ↓
IMPLEMENTED
   ↓
VERIFIED
```

Different work starts at different points.

A well-understood config change starts almost at **EXECUTABLE**.

A big new feature starts at **UNKNOWN → KNOWN**.

A nasty production bug starts at **UNKNOWN**.

A large refactoring may start at **KNOWN → DECOMPOSED**.

That's probably the model I'd build an agentic development system around: **don't force every piece of work through the same artifact pipeline; move it through the minimum stages necessary to make the next stage reliable.**
