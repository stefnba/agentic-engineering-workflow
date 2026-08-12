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

Five stages — verify and reconcile are not among them: **verify** (the repo's checks plus the ticket's done-when pass) is Implement's exit gate, and **reconcile** (fix any drift the change caused in colocated READMEs, `spec.md`, and remaining tickets) is an obligation that fires per ticket before review and again at ship.

## Stages

| Stage         | Purpose                                                                                                                                       | Session                                                                           | Output                                           | Exit approved by                                           |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- | ------------------------------------------------ | ---------------------------------------------------------- |
| **Discover**  | Fill the backlog with everything agents gather — audit findings, research take-aways; an agent never turns its own finding directly into work | any                                                                               | A picked candidate                               | Human picks: a crisp line → shape, a vague one → interview |
| **Shape**     | Turn the picked candidate into a spec and small, verifiable work items (tickets)                                                              | Fresh author, read-only on code; a separate fresh-context critic attacks the plan | `spec.md` + the full ticket set                  | Open questions resolved → human approves the decomposition |
| **Implement** | Execute one ticket in a dedicated branch/worktree until its done-when passes                                                                  | Fresh per ticket                                                                  | A verified, reconciled change set                | Agent: verify + reconcile, both in the same PR             |
| **Review**    | Judge what verify cannot: architecture, requirement fit, security, edge cases — and whether the reconcile half is honest                      | Fresh, no authorship of the diff                                                  | Findings or approval                             | Human approves; affected verification re-run after fixes   |
| **Ship**      | Absorb what remains of the bundle into the durable docs, delete the bundle (git history keeps it, no `done/`), merge, confirm main green      | —                                                                                 | Shipped outcome; follow-ups become backlog lines | — (approved at review)                                     |

Two rules the table can't carry: intent the human brings directly skips the backlog altogether, and implementer-written tests are part of the diff under judgment, not independent verification.

## Where the human sits

The human triggers every stage. Beyond that, three approvals, and only three — everything between them is agent-crossable on deterministic gates:

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

**Bundles** hold one feature's spec and tickets, named `YYYY-MM-DD-<slug>`. A bundle first appears in `work/` when it's complete; for smaller work, it's a single file, above that a directory. Re-resolve with `ls work/*/<id>*`. References follow lifetime: within `work/` artifacts, by ID in prose (never by path — paths break on `git mv`); in PRs, by permalink, which pins a commit and survives the bundle's deletion; in durable docs and code comments, never. Always `git mv`, and in a monorepo keep bundles per-package (`packages/<pkg>/work/`).

**`spec.md`** pins the external behavior the change must exhibit plus only the decisions that constrain it — interior implementation stays open.

**Tickets** are one-agent-session slices with a machine-checkable done-when and `status`/`depends_on` frontmatter.

**Colocated `README.md`s** carry each subsystem's durable target state next to its code. When a README and a spec disagree about the current system, **the README wins** — it describes what is; the spec, what someone intended (the spec still owns what the change should make true). This authority is earned by reconcile: every PR updates the READMEs it made inaccurate, and review sees the README diff beside the code diff — colocation is what makes drift visible.

**`docs/decisions/`** — immutable; supersede with a new record, never edit. For anything durable and expensive to relitigate. Template lives with the `decision` skill.

**`docs/research/`** — evidence, not commitments. A doc weighing three options has not chosen one; if something was decided, there's a record in `decisions/`. Anything actionable becomes a backlog line pointing at the file.

**`work/backlog.md`** — one line per unshaped idea, the problem rather than a proposed solution. Unsorted; ranking happens at pick time, in front of the human.
