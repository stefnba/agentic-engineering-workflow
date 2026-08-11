# Agentic Coding Worfklow

## Workflow

How work moves from idea to shipped.

### The loop

```text
discover ⇄ shape                      gate: human picks the candidate
    ↓
  shape                               gate: Open questions resolved
    ↓                                       + human approves the decomposition
implement ⇄ verify        per ticket  gate: done-when commands pass (agent)
    ↓                                       + reconcile diff in the same PR
review → fix → re-verify ↺            gate: human approves
    ↓
  ship                                gate: durable docs absorbed,
                                            bundle deleted, main green
```

### Stages

| Stage     | Purpose                                                                          | Output                                                                   | Exit approved by                   |
| --------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | ---------------------------------- |
| Discover  | Fill the backlog with candidates; pick one to pursue                             | A picked candidate (line, or a settled understanding carried in-session) | Human picks                        |
| Shape     | Turn the picked candidate into a spec and small, verifiable work items (tickets) | `spec.md` + the full ticket set                                          | Critic challenges → human approves |
| Implement | Execute one ticket in a dedicated branch/worktree                                | A verified, reconciled change set                                        | Agent (gates pass)                 |
| Review    | Judge the diff: correctness, architecture, security, requirement fit             | Findings or approval                                                     | Human approves                     |
| Ship      | Merge/release, absorb docs, delete the bundle, record follow-ups                 | Shipped outcome, traceable record                                        | — (approved at review)             |

#### Discover

Two halves:

**Gathering** fills the funnel:

- **Audit** — scan the codebase for simplification, quality, reliability, and security opportunities. Findings become backlog lines; evidence worth keeping goes to `research/` (as `audit-*.md`).
- **Research** — investigate the world: new versions, migration paths, best practices, how another repo solved something. The write-up lands in `research/`; anything actionable it reveals becomes a backlog line pointing at it.

Gathering never chooses. Its candidates enter the funnel like every other idea — the backlog is the single, unsorted collection point, and nothing bypasses it.

**Picking** settles on exactly one candidate:

- **From the backlog** — the human scans the list and picks a line. A crisp line goes straight to shaping; a vague one goes through an interview first.
- **Interview** — the user brings intent directly. A relentless round-based Q&A challenges vague requirements until problem, constraints, and motivation are settled and a shared understanding has been reached — the problem in the user's framing, not a solution.

#### Shape

Two roles, deliberately separated:

**Author** writes features artifacts:

- Starts from a just-finished interview, a backlog line, or a requirement stated directly in chat.
- Writes `spec.md` (target state, non-goals, open questions, acceptance criteria) and the full ticket set, inside that bundle — every acceptance criterion covered by some ticket's done-when. Read-only on code: an agent that _can_ write code will write code and retrofit the spec to it.

**Critic** attemts to break the artifacts:

- Separate agent with a fresh context to not inherit the author's blind spots.
- Attempts to break what the authoring agent wrote: missed states, API contracts, security, performance, testability, scope creep, adherence to repo conventions.
- Goal is to have a documents that would pass a senior staff review.

#### Implement

One ticket per session, fresh context, dedicated branch or worktree. The agent reads the spec and its ticket, respects "Not in this ticket", and works until the ticket's done-when conditions pass.

The exit gate has two halves:

1. **Verify** — the repo's deterministic checks pass — typecheck, lint, unit/integration/e2e tests, build, migrations (up _and_ down) where touched — plus the ticket's own done-when commands, and a manual smoke test when the ticket calls for one. The PR records the exact commands, their output, and any check that was skipped and why: a stated gap is reviewable, an omitted one is a trap. Evidence, not claims.
2. **Reconcile** — colocated `README.md`s updated if the change made them inaccurate; `spec.md` amended if implementation proved it wrong; remaining tickets amended if the landed change invalidated them. Detail repairs happen here; a _scope_ change is a deviation.

#### Review

Fresh context, no authorship of the diff under review. Judges what verify cannot: architecture fit, requirement fit, regressions, security, UX, edge cases, maintainability — and whether the reconcile half of the PR is honest (does the README diff actually match what the code now does?). Any `spec.md` amendment in the diff gets checked against describe-never-decide — an amendment that smuggled a deviation through as a clarification is a finding, not a nitpick.

The loop: **review → fix findings → re-run affected verification → review again if the fix was material → approve.** Re-verification after fixes is not optional; a fix that breaks a done-when condition is a regression wearing a review-approval costume.

This is the last human gate. Everything after approval is mechanical.

#### Ship

- Absorb what remains of `spec.md` into the durable docs, then **delete the bundle** (git history keeps it)
- Clean commits, PR summary recording the verification evidence
- Merge/release; confirm main is green
- Capture follow-ups as backlog lines — not as a lingering half-open bundle

### Where the human sits

Three approvals, and only three:

1. **Pick** (Discover → Shape): what is worth doing
2. **Plan** (Shape → Implement): is this the right target state, sliced correctly
3. **Accept** (Review → Ship): is the change good

Everything between those points is agent-crossable on deterministic gates.

---

## Artifacts

This file explains what lives where, why, and the rules that keep it from rotting.

**Metadata.** A document carries metadata only if something reads it — and where metadata exists, the syntax is always YAML frontmatter, never a prose byline: one syntax means one parser for every query, skill, and sweep. Tickets carry `status`/`depends_on`; decisions carry `status`/`date`/`areas` (+ `supersedes`); research may carry `date`/`source`. `spec.md` carries **none**, deliberately — nothing machine-reads it, the directory owns bundle status, and an unused metadata block is an invitation for a second status owner.

### `work/`

#### `shaped/<bundle>/`

##### IDs and links

**Bundles** get a 4-digit ID. **Tickets** are numbered locally (`01`, `02`) — `0042/03` is a sufficient global reference.

IDs come from `work/next-id`, a single counter file holding the next one to give out — sequential, not hashed or content-addressed, because they're allocated before any content exists to address.

Decision records number themselves independently, so `0001` can be both a decision and a work item. In prose, bare IDs always mean work items; decisions are always written out as "decision 0007".

```bash
ls work/*/0042-*        # resolve by ID, works from any status directory
```

- **In repo markdown**: reference by ID in prose, don't link the path. A markdown link is a literal relative path — the glob only helps something that can execute it — so `[0042](../planned/0042-…)` 404s on the first `git mv`. Humans resolve IDs the same way: `t` on GitHub or `Cmd+P` in an editor, then type the ID.
- **In PR descriptions**: use a GitHub permalink (press `y` to pin the commit SHA). It never breaks, and it points at the spec as it read when the PR was opened — the version the reviewer needs, not whatever it says three moves later. Branch-name URLs (`/blob/main/...`) are the ones that rot.
- Always `git mv` so `git log --follow` survives the rename.

##### `spec.md`

- **Spec-heavy, design-light.** `Behavioral Requirements` and `Acceptance Criteria` pin down observable behavior first — contracts, outcomes, what a caller or user can see — then `Implementation Decisions` carries only what constrains the work: public interfaces, data models, patterns to follow. Interior implementation stays open on purpose. Over-specifying constrains the agent exactly like it constrains a human, for no benefit; the pseudocode anti-pattern below is this rule's failure mode.

- _Spec_ is used here **with a fixed meaning**, because industry usage is genuinely sloppy: a spec describes the **external behavior the change must exhibit** contracts, observable outcomes, acceptance criteria — plus only the internal decisions that constrain it (public interfaces, data models, patterns to follow). Interior implementation stays deliberately open; see `spec.md` below. Terms still avoided: _design doc_ (promises internal-structure content that belongs in `decisions/` and tickets), _SRD/SRS_ (waterfall artifact, needs a regulated context to earn its weight), _PRD_ (product framing, not ours unless a PM writes one).

##### `plan.md`

- Only written if there is sequencing _rationale_ that a dependency graph can't express (migration).

##### `tickets/NN-*.md`

- **Mandatory, not opt-in**
- Single work item one agent implements
- **Does't duplicate the spec's reasoning.** Link to it. Duplicated rationale goes stale and the agent can't tell which copy is current.

**No `done/` folder**: On ship, bundle with its file get deleted. Git history keep it.

#### `backlog.md`

One line per unshaped idea. Keep capture friction near zero; a file-per-idea directory raises it just enough that people stop capturing.

The list is an **unsorted collection dump** — order carries no meaning. Ranking happens at pick time, in front of the human, not in the file.

Sub-bullets pointing at docs/research/ files are fine — those paths never move, unlike work items, so the no-path-links rule doesn't apply.

### `docs/decisions/`

Immutable. Superseded, never edited.

Called `decisions/`, not `adr/`, deliberately.

`areas:` recovers any subset when you want it: `rg 'areas:.*server' docs/decisions/`. Taxonomy belongs in a field, not a directory name — directories give you one axis and you'll find the second one later. One folder, one template — never two directories for this.

### `docs/research/`

**Findings from discovery**: benchmarks, spikes, vendor comparisons, prior-art reads, codebase audits.

**Research files are evidence, not commitments**. A doc weighing three options has not chosen one. An agent must not treat the last option described as the decision — if something was decided, there is a record in decisions/.

**Anything actionable a research doc reveals becomes a backlog line pointing at it**. Research feeds the backlog; it never enters the workflow directly — otherwise there are two competing answers to "what might be worth doing".

---

### Anti-patterns

- **A spec detailed enough to be pseudocode.** Worse than a vague one.
- **Reasoning duplicated between spec and ticket.** One copy goes stale.
- **Keeping shipped feature docs around.** They contradict each other and poison retrieval.
- **Linking work items by path.** Paths move; use IDs, or permalinks in PRs.
- **Editing a decision record.** Write a new one that supersedes it.
- **Skipping reconcile.** Three features is roughly how long the docs stay trustworthy without it.

---

## Layout

```text
docs/                           # durable — everything here accumulates and stays current
  decisions/                    # immutable decision records
    0001-postgres-over-mongo.md
  research/                     # findings from discovery — evidence, not commitments
  agentic-workflow.md           # this file

work/                           # disposable — in-flight work, at the repo root
  backlog.md                    # one line per unshaped idea — unsorted collection dump
  next-id                       # ID counter, incremented by the bundle-creating commit
  shaped/                       # shaped, not started
  active/                       # in progress
    0042-billing-retries/
      spec.md
      plan.md                   # only if sequencing rationale exists
      tickets/
        01-schema.md
        02-scheduler.md
```
