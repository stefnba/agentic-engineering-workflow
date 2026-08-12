# Agentic Coding Workflow

How work moves from idea to shipped, and which documents carry it.

## The loop

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

Five stages: verify and reconcile are not stages: verify is Implement's exit gate, reconcile an obligation that fires per ticket before review and again at ship.

## Stages

| Stage         | Purpose                                                                                                    | Output                            | Exit approved by                   |
| ------------- | ---------------------------------------------------------------------------------------------------------- | --------------------------------- | ---------------------------------- |
| **Discover**  | Fill the backlog with candidates for everything an agent gathers, e.g. audit findings, research take-aways | A picked candidate                | Human picks candiate to pursue     |
| **Shape**     | Turn the picked candidate into a spec and small, verifiable work items (tickets)                           | `spec.md` + the full ticket set   | Critic challenges → human approves |
| **Implement** | Execute one ticket in a dedicated branch/worktree                                                          | A verified, reconciled change set | Agent (gates pass)                 |
| **Review**    | Judge the diff: correctness, architecture, security, requirement fit                                       | Findings or approval              | Human approves                     |
| **Ship**      | Merge/release, absorb docs, delete the bundle, record follow-ups                                           | Shipped outcome                   | — (approved at review)             |

**Shape.** The author writes a fresh bundle (spec & fickets). A separate critic with a fresh context attacks the plan before the human sees it. Exit: every open question resolved, human approves the decomposition.

**Implement.** One ticket per session, fresh context. Works until the done-when conditions pass.The PR carries both halves of the exit gate: **verify** (the repo's checks plus the ticket's done-when pass) and **reconcile** (fix any drifts in colocated READMEs, `spec.md`, and remaining tickets ).

**Review.** Fresh context, no authorship of the diff. Judges what **verify** cannot: architecture, requirement fit, security, edge cases — and whether the **reconcile** half is honest. Implementer-written tests are part of the diff under judgment, not independent verification. After fixes, affected verification is re-run before approval.

**Ship.** Absorb what remains of the work bundle into the durable docs, then delete the bundle — git history keeps it, there is no `done/`. Merge, confirm main is green. Follow-ups become backlog lines, never a lingering half-open bundle.

## Where the human sits

Triggering the stages of the workflow. Then three approvals, and only three — everything between them is agent-crossable on deterministic gates:

1. **Pick** (Discover → Shape): what is worth doing
2. **Plan** (Shape → Implement): right target state, sliced correctly — per feature
3. **Accept** (Review → Ship): is the change good — per PR

Never hand yourself one of these: priorities, decomposition, and acceptance are human judgments.

## Layout

```text
docs/                           # durable — accumulates and stays current
  decisions/                    # immutable decision records
  research/                     # findings from discovery — evidence, not commitments
  agentic-workflow.md           # this file

work/                           # disposable — in-flight work
  backlog.md                    # one line per unshaped idea — unsorted collection dump
  shaped/                       # spec + tickets complete, not started
  active/                       # in progress
    2026-08-11-billing-retries/
      spec.md
      tickets/
        01-schema.md

src/<domain>/README.md          # durable target state, colocated with the code
```

## The artifacts

**Bundles** hold one feature's spec and tickets, named `YYYY-MM-DD-<slug>`. A bundle first appears in `work/` when it's complete; for smaller work, it's a single file, above that a directory. The parent directory is the status — never hardcode it, re-resolve with `ls work/*/<id>*`. Reference bundles by ID in prose (paths break on `git mv`), by permalink in PRs; always `git mv`, and in a monorepo keep bundles per-package (`packages/<pkg>/work/`).

**`spec.md`** pins the external behavior the change must exhibit plus only the decisions that constrain it — interior implementation stays open.

**Tickets** are one-agent-session slices with a machine-checkable done-when and `status`/`depends_on` frontmatter.

**`docs/decisions/`** — immutable; supersede with a new record, never edit. For anything durable and expensive to relitigate. Template lives with the `decision` skill.

**`docs/research/`** — evidence, not commitments. A doc weighing three options has not chosen one; if something was decided, there's a record in `decisions/`. Anything actionable becomes a backlog line pointing at the file.

**`work/backlog.md`** — one line per unshaped idea, the problem rather than a proposed solution. Unsorted; ranking happens at pick time, in front of the human.
