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

Five stages — verify and reconcile are not among them: **verify** (the repo's checks plus the ticket's done-when pass) is Implement's exit gate, and **reconcile** (fix any drift the change caused in colocated READMEs, affected glossaries, `spec.md`, and remaining tickets) is an obligation that fires per ticket before review and again at ship.

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
  agents/git.md                 # branch strategy + commit and PR conventions, scaffolded at setup
  agentic-workflow.md           # this file

GLOSSARY.md                     # durable — canonical domain vocabulary (per-domain in monorepos)
AGENTS.md                       # durable — canonical agent conventions (packages/<pkg>/AGENTS.md in monorepos)

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

## The git surface

How a bundle exists in git. `docs/agents/git.md` declares which strategy the repo runs;
the mechanics are executed by the `bundle-git` skill.

Every work branch gets its own worktree; the main checkout is never a work
surface.

### Under `bundle-branch`

The bundle branch is created when the bundle's first ticket starts. Every ticket PR
merges into it; only at ship does the whole bundle land on the default branch, squashed
to one revertable commit. Mid-flight the bundle branch is therefore the truth for
`work/` — the default branch's copy lags until ship.

Note: A single-file bundle takes one `<id>` branch straight to the default branch.

```text
default branch ─┬─────────────────────────────▲─ ship squash-lands the bundle once,
   shape lands  │                             │  then every branch + worktree deleted
   the bundle   └▶ <id>/bundle ─┬──────▲──────┘
                 (first ticket) └▶ <id>/ticket/<NN-slug> ─ one PR per ticket
```

### Under `trunk`

No bundle branch. Each ticket lands on the default branch, so `work/` there stays
current.

```text
default branch ─┬──────▲──────▲─ one squash PR per ticket, straight to default;
   shape lands  │      │      │  ship deletes the bundle and confirms green
   the bundle   └▶ <id>/ticket/<NN-slug>
```

## The artifacts

**Bundles** hold one feature's spec and tickets, named `YYYY-MM-DD-<slug>`. A bundle first appears in `work/` when it's complete; for smaller work, it's a single file, above that a directory. Re-resolve with `ls work/*/<id>*`. References follow lifetime: within `work/` artifacts, by ID in prose (never by path — paths break on `git mv`); in PRs, by permalink, which pins a commit and survives the bundle's deletion. **Never reference a bundle from anything durable — no READMEs, no code comments, no `docs/`.** The bundle is deleted at ship; whatever a durable doc needs from it gets absorbed into the doc, not linked. Always `git mv`, and in a monorepo keep bundles per-package (`packages/<pkg>/work/`).

**`spec.md`** pins the external behavior the change must exhibit plus only the decisions that constrain it — interior implementation stays open.

**Tickets** are one-agent-session slices with a machine-checkable done-when and `status`/`depends_on` frontmatter.

**Colocated `README.md`s** carry each subsystem's durable target state next to its code. When a README and a spec disagree about the current system, **the README wins** — it describes what is; the spec, what someone intended (the spec still owns what the change should make true). This authority is earned by reconcile: every PR updates the READMEs it made inaccurate, and review sees the README diff beside the code diff — colocation is what makes drift visible.

**`GLOSSARY.md`** — a repo's canonical domain vocabulary: term, a one-to-two-sentence
definition of what it _is_, and an _Avoid_ list of rejected synonyms; only terms specific to
the project's domain qualify, general programming concepts are excluded. Agent output — prose
artifacts and code identifiers alike — uses glossary terms and never an avoided synonym;
review judges identifier adherence, there is no mechanical gate. A repo without a glossary is
handled silently, no nagging to create one; a term missing from a glossary that already has
entries is a signal — either the agent is inventing language or there's a real gap worth
capturing. A conflict between output and a glossary definition is flagged explicitly, both
readings named, never silently resolved in either direction. Glossary freshness is part of
the per-ticket reconcile obligation: a change that renames or redefines a term updates the
affected glossary in the same PR. In a monorepo, each domain may carry its own `GLOSSARY.md`
at its root, and the root file holds cross-cutting terms plus a Domains section linking each
sub-glossary. Unlike decision records, the glossary is mutable — edited in place, history is
git's; a rename edits the entry and moves the old term to _Avoid_. The `glossary` skill is its
caretaker.

**`AGENTS.md`** — canonical for repo-wide conventions and gotchas, for every agentic tool;
`CLAUDE.md`, where a repo uses one, references it rather than duplicating it (never both). A
monorepo gets one per-package too, at `packages/<pkg>/AGENTS.md`, for area-specific content.

**`docs/agents/git.md`** — the repo's agent-facing git conventions, including the declared
branch strategy, commit-message convention, PR conventions, release promotion.

**`docs/decisions/`** — immutable; supersede with a new record, never edit. For anything durable and expensive to relitigate. Template lives with the `decision` skill.

**`docs/research/`** — evidence, not commitments. A doc weighing three options has not chosen one; if something was decided, there's a record in `decisions/`. Anything actionable becomes a backlog line pointing at the file.

**`work/backlog.md`** — one line per unshaped idea, the problem rather than a proposed solution. Unsorted; ranking happens at pick time, in front of the human.
