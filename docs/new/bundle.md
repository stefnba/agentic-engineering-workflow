# Work bundles

- Spec = what/why/constraints.
- Engineering plan = decomposition decisions.
- Tickets = independently executable slices of work, ideally thin vertical slices

All three are in-flight artifacts in one disposable work bundle. They must remain stable and
readable across planning, implementation, and review, but they are not permanent system
documentation. When the whole bundle ships, its still-relevant knowledge is absorbed into durable
documentation and decision records, then the bundle is deleted. Git history preserves the work
record.

The spec should be human-readable and stable for the bundle's lifetime.
The ticket should be agent-readable and executable.

```text
                    ┌──────────────┐
                    │    SPEC      │
                    │  Why + What  │
                    └──────┬───────┘
                           │
                    requirements
                           │
                    ┌──────▼───────┐
                    │     PLAN     │
                    │ decomposition        │
                    │ how to break it down |
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │ WORK ITEMS   │
                    │  executable work units  │
                    └──────┬───────┘
                           │
                       agents
                           │
                    ┌──────▼───────┐
                    │ CODE + TESTS │
                    └──────┬───────┘
                           │
                       evidence
                           │
                    ┌──────▼───────┐
                    │    DONE      │
                    └──────────────┘

```

## Loop

But there should be a feedback loop. The important nuance is that writing the plan and tickets will often expose problems in the spec.

For example:

```text
Spec
 ↓
Plan
 ↓
"We need a migration strategy here."
 ↓
Spec doesn't define migration behavior
 ↓
Update spec
 ↓
Plan
 ↓
Tickets
```

So I would treat the first three stages as a specification phase, rather than three completely independent phases.

### Phase 1 — Spec

Create enough of the spec to establish:

problem
goals/non-goals
desired behavior
requirements
constraints
acceptance criteria
important edge cases

Don't worry yet about every implementation detail.

### Phase 2 — Engineering plan

An architect/human/agent **analyzes the repository** and produces:

proposed architecture
technical approach
dependencies
migration considerations
risks
work breakdown
parallelization opportunities

This is where repository exploration becomes important. The plan shouldn't be created in a vacuum from the product spec.

### Phase 3 — Ticket generation

Turn the plan into executable work items.

Each ticket gets:

objective
scope
dependencies
requirements addressed
acceptance criteria
verification requirements
constraints

At this point, tickets should be executable by an implementation agent. Human approval promotes
the completed bundle into the shaped state.

## Tailor to size of work bundles

See [Tailor to size of work bundles](./bundes-by-size.md)

---

## Spec

spec relatively stable and not turning it into a task checklist.

The spec should answer:

"If two competent engineers implemented this independently, what must they agree on?"

It shouldn't answer:

"First edit this file, then create this class, then run this command."

## Engineering Plan

- The engineering plan is optional for very small features but extremely useful for larger ones.
- Don't put implementation plans in the behavioral spec. Agents are much better at discovering
  where a change belongs from a repository-grounded plan than from design detail mixed into intent.

### Why plan before tickets?

**important one**: grounding the plan in actual repository exploration. Plans written from the product spec alone consistently produce tickets that reference files that don't exist, miss existing utilities, or propose architectures that fight the codebase's conventions. Having the planning agent read the code first is what makes Phase 3 tickets executable rather than aspirational.

The plan answers:

"Given this spec, what is the sensible engineering decomposition?"

The tickets answer:

"What are the independently executable units produced by that decomposition?"

So the natural flow is:

### Thin vertical slices

Plan does vertical slicing the default.

Each slice is:

- small
- demonstrable
- testable
- independently reviewable
- independently revertible where possible

Feature → Vertical Slice → Ticket.

A slice can simply be a grouping/concept in the plan.

```markdown
## Vertical slices

### Slice 1 — Create document

User can create a document and see it in their document list.

Touches:

- database
- domain
- API
- frontend

Tickets:

- DOC-001

### Slice 2 — Edit document

User can open and edit an existing document.

Touches:

- API
- domain
- frontend

Tickets:

- DOC-002
```

## Ticket

should be agent-sized
One agent should be able to take the ticket, inspect the repository, implement it, test it, and determine whether it is done without needing a human to decompose it further.

A great agent ticket generally has:

- one objective
- one coherent change
- clear boundaries
- few dependencies
- testable acceptance criteria
- limited files/modules

Give agents explicit autonomy boundaries

```markdown
## Constraints

### Must

- Follow existing repository conventions.
- Preserve backwards compatibility.
- Add tests for changed behavior.
- Do not modify public API contracts outside this ticket.

### May

- Refactor local implementation if necessary.
- Add helper functions/classes within the affected module.
- Improve tests around the affected behavior.

### Must not

- Change unrelated modules.
- Add dependencies without justification.
- Modify infrastructure outside this feature.
- Change the spec's requirements.
```

Don't make agents infer the entire dependency graph from prose.

```markdown
## Dependencies

Depends on:

- FEAT-001
- FEAT-002

Blocks:

- FEAT-006
```

### Status of tickets

Persist only status that the ticket file uniquely owns:

- `todo` — approved in a shaped bundle and not yet claimed.
- `doing` — claimed; remains `doing` through implementation, verification, review, and fixes.
- `done` — accepted and merged into the ticket's integration target.

Other states already have better owners:

- Draft versus approved belongs to the bundle: an unapproved draft stays local; approval places the
  bundle under `work/shaped/`.
- Implemented, checks running, checks passed, review requested, and changes requested belong to the
  PR and CI system.
- An unmet ticket dependency is derived from `depends_on`; do not copy it into status.
- An external blocker is optional `blocked_reason` metadata while status remains `todo` or `doing`.

```markdown
bundle: local draft → work/shaped → work/active → shipped and deleted
ticket: todo → doing → done
PR/CI: implementation and verification detail
```

## Git and Pull Request

## Branch strategy

- Every work get it's own bundle branch for integration and tickets land as PR on this branch. Once done, bundle get PR into main.

## PR

Ticket = unit of intent/work

PR = unit of review/integration

Commit = unit of implementation history

- Should one ticket equal one PR? -> Default: yes. But don't force it.

### Multiple tiny tickets → one PR as the exception

These may be separate work items because they represent separate implementation steps, but reviewing three tiny PRs would be annoying.

```text
AUTH-101 Add UserRole enum
AUTH-102 Add role to User
AUTH-103 Add role serializer
```

You could have:

```text
AUTH-101 ─┐
AUTH-102 ─┼──→ PR #456
AUTH-103 ─┘
```

The PR description should list all included tickets.

I'd do this when the tickets:

are tightly coupled
don't make sense to review independently
are very small
have the same owner/agent
form one coherent change

## Concepts

| Concept              | Default                                |
| -------------------- | -------------------------------------- |
| Feature              | Spec                                   |
| Complex feature      | Spec → Plan                            |
| Plan                 | Decompose into **vertical slices**     |
| Slice                | One or more tickets                    |
| Ticket               | Prefer independently executable        |
| Ticket               | Usually one PR                         |
| Tiny related tickets | Can share one PR                       |
| Large ticket         | Split into child tickets               |
| Foundation           | Horizontal is okay                     |
| Agent                | Owns implementation + tests + evidence |
| PR                   | Review/integration boundary            |
| Merge                | Prefer small, incremental changes      |

## Model

```text
                    FEATURE
                       │
                       ▼
                SPEC / INTENT
                       │
                       ▼
               ENGINEERING PLAN
                       │
             ┌─────────┴─────────┐
             ▼                   ▼
       FOUNDATION WORK      VERTICAL SLICES
             │                   │
             │            ┌──────┼──────┐
             │            ▼      ▼      ▼
             │          TICKET TICKET TICKET
             │            │      │      │
             └────────────┴──────┴──────┘
                            │
                          IMPLEMENT
                            │
                         PR(s)
                            │
                         REVIEW <> FIX
                            │
                          MERGE
```
