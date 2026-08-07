# Documenation

This file explains what lives where, why, and the rules that keep it from rotting.
**Agents**: read this before creating or editing anything under `docs/`.

---

## 1. Layout

```text
docs/
  README.md                 # this file
  decisions/                # immutable decision records
    template.md
    0007-postgres-over-mongo.md
  research/                 # findings from discovery — evidence, not commitments
  systems/
    README.md               # index of system docs — links only, no content
    data-flow.md            # cross-cutting concerns that have no home directory
    deployment.md
  work/
    backlog.md              # one line per unshaped idea — unsorted collection dump
    candidates/             # picked and briefed, not yet shaped
      0043-usage-export/
        brief.md
    planned/                # shaped, not started
    active/                 # in progress
      0042-billing-retries/
        brief.md            # if interview-sourced; frozen once design.md exists
        design.md
        plan.md             # only if sequencing rationale exists
        tickets/
          01-schema.md
          02-scheduler.md

src/<domain>/README.md       # durable target state, colocated with the code
src/[domain]/README.md
```

Two lifetimes are in play, and confusing them is the main failure mode:

- **Durable** — `decisions/`, `systems/`, colocated `README.md` files. These accumulate and stay current forever.
- **Disposable** — everything under `work/`. Scoped to one feature, deleted when shipped.

---

## 2. Document types

| Doc                   | Question it answers                         | Lifetime                                 |
| --------------------- | ------------------------------------------- | ---------------------------------------- |
| Colocated `README.md` | What is this subsystem, as it exists now    | Durable                                  |
| `decisions/NNNN-*.md` | Why we chose X over Y                       | Immutable                                |
| `research/*.md`       | What we found out                           | Durable, but non-binding                 |
| `work/backlog.md`     | What might be worth doing                   | Rolling                                  |
| `brief.md`            | What was asked, in the user's framing       | Feature — frozen once `design.md` exists |
| `design.md`           | What will be true when this feature is done | Feature                                  |
| `plan.md`             | In what order, and why that order           | Feature                                  |
| `tickets/NN-*.md`     | What one agent does in one PR               | Feature                                  |

**Precedence.** When a colocated `README.md` and a feature `design.md` disagree, the README wins. It describes what _is_; the design doc described what someone intended at a point in time.

Terms deliberately avoided: _spec_ (means four different things depending on who's talking), _SRD/SRS_ (waterfall artifact, needs a regulated context to earn its weight), _PRD_ (product framing, not ours unless a PM writes one).

---

## 3. Workflow

The process — stages, gates, loops, approval points — is defined in [agentic-workflow.md](agentic-workflow.md), which is authoritative for anything about sequence or approval. This doc owns the artifact side: which stage reads and writes which document.

| Stage     | Reads                                                  | Writes                                                                         |
| --------- | ------------------------------------------------------ | ------------------------------------------------------------------------------ |
| Discover  | `backlog.md`, colocated READMEs                        | `research/*.md`, backlog lines, `candidates/<id>/brief.md`                     |
| Shape     | brief or backlog line, colocated READMEs, `decisions/` | `design.md`, `plan.md` (rarely), first tickets; moves the bundle to `planned/` |
| Implement | ticket, `design.md`, colocated READMEs                 | code; ticket status; README and `design.md` amendments                         |
| Review    | the PR diff, `design.md`, colocated READMEs            | findings                                                                       |
| Ship      | the bundle                                             | durable docs (absorbing the design); deletes the bundle                        |

---

## 4. `work/` — feature bundles

### When to open a bundle

**Opt-in, not mandatory.** Roughly 10–20% of items need one. A bundle is justified when the work is genuinely multi-increment _and_ needs shaping before code.

| Kind of work                   | Bundle?                                                        |
| ------------------------------ | -------------------------------------------------------------- |
| Bug fix                        | No — branch and PR                                             |
| Small feature (1–2 PRs)        | No — backlog line, then PR                                     |
| Multi-increment feature        | Yes                                                            |
| Refactor with risky boundaries | Yes                                                            |
| Interview-sourced feature      | Yes — starts in `candidates/` with `brief.md`                  |
| Migration                      | `plan.md` only — design is trivial, ordering is the difficulty |
| Spike                          | No — output goes to `research/`                                |

Writing hollow design docs for work that doesn't need them trains everyone to skim design docs.

### Scale

- Under ~3 tickets → one file, `work/planned/0042-billing-retries.md`, with `## Target state` and `## Increments`. Interview-sourced items are the exception: a brief already forces the directory form.
- More → promote to a directory. `git mv`, never delete-and-recreate.
- Monorepo → push bundles down to `packages/<pkg>/docs/work/`; keep only cross-cutting work at root.
- If `active/` holds more than ~20 bundles, or multiple teams share the ID space, switch tickets to GitHub issues. You need query and filter at that point, not storage.

### IDs and links

Features get a 4-digit ID. Tickets are numbered locally (`01`, `02`) — `0042/03` is a sufficient global reference.

The parent directory is the status. **Never hardcode it.**

```bash
ls docs/work/*/0042-*        # resolve by ID
```

- **In repo markdown**: reference by ID in prose, don't link the path. Paths break on status moves.
- **In PR descriptions**: use a GitHub permalink (press `y` to pin the commit SHA). That points at the design as it read when the PR opened, which is the version the reviewer needs.
- Always `git mv` so `git log --follow` survives the rename.

### `brief.md`

Written during discovery, by the interview — before any design exists. It captures **what was asked, in the user's framing**: problem, constraints, motivation. Not a solution.

Writing one is itself a judgment: a brief claims the item needs shaping. If the intent fits in a backlog line, it wasn't a brief — write the line instead.

The bundle starts life in `candidates/` holding only the brief, and moves to `planned/` when shaping completes.

**Frozen once** `design.md` **exists.** From that point the brief is the record of intent and the design is what's being done about it. They may overlap, and that's harmless precisely because a frozen document can't drift — the same reasoning that lets superseded decision records keep their original text. When they disagree, `design.md` wins.

### `design.md`

**Write in present tense, describing the system as it will exist.** Not "add a retry scheduler" but "the retry scheduler reads from `billing_events` and backs off exponentially."

Delta descriptions are only true before you start. An agent picking up ticket 4 of 7 can't tell which changes are already applied. Target-state descriptions are as true at ticket 7 as at ticket 1.

```markdown
# 0042 — Billing retries

## Problem

## Target state ← present tense, the durable core

## Non-goals

## Open questions ← must be empty before implementation starts

## Acceptance criteria
```

- **Keep these headings identical across every design doc.** Stable anchors mean tickets can deep-link and `AGENTS.md` can give generic instructions.
- **Non-goals is the highest-value section.** Agents wander — they refactor adjacent code, add unrequested error handling, upgrade dependencies. An explicit exclusion list prevents most scope drift.
- **Say what and why, not how.** A design detailed enough to be pseudocode removes the agent's ability to adapt while adding surface area for you to have been wrong.
- **Open questions is the gate.** If it's non-empty, do not implement. If a new question appears mid-implementation, stop and add it — do not decide it yourself.

### `plan.md`

Only write one if there is sequencing _rationale_ that a dependency graph can't express — "ship 03 behind a flag so we can measure before committing to 04."

A table that merely restates ticket order is a hand-maintained derived view, and it goes stale invisibly. If dependencies live in ticket frontmatter, skip this file.

No status column. No checkboxes. Those duplicate the tickets.

### `tickets/NN-*.md`

```markdown
---
status: todo # todo | doing | done
depends_on: [01]
---

# 02 — Retry scheduler

## Scope

One paragraph. What changes.

## Done when

- `pytest tests/billing/test_retry_schema.py` passes
- Migration reversible: `alembic downgrade -1` clean

## Not in this ticket

Backoff policy, alerting.
```

- **Slice by what must be true when this PR merges** — not by file, not by layer. One PR, independently revertible, `main` stays green after each.
- **Every ticket needs a machine-checkable done condition.** "Users can retry failed payments" is not verifiable. A test command is. If you can't write the check, the ticket isn't specified yet.
- **Don't duplicate the design's reasoning.** Link to it. Duplicated rationale goes stale and the agent can't tell which copy is current.
- **Don't create all tickets upfront.** Beyond the first two or three, they're written against assumptions implementation will invalidate. Generate the rest after the first lands.

### Claiming, with parallel agents

Set `status: doing` and push _before_ starting work. A rejected push on a stale ref means someone else claimed it — re-read and pick another. Not a real lock, but sufficient for two or three concurrent agents. Beyond that, use issues, where assignment is atomic.

### On ship

Absorb the design into the durable docs, then **delete the bundle**. Git history keeps it.

There is no `done/`. Feature docs describe the system at a moment that is now past; keeping five of them around a subsystem produces confidently-worded, mutually contradictory documentation that retrieval can't disambiguate. That is worse than no documentation.

---

## 5. Durable system docs

Target state for a subsystem lives **next to its code**:

```
src/billing/README.md
```

Colocation is the only thing that reliably prevents staleness. A PR touching `src/billing/` shows the README in the same diff, so a reviewer sees the mismatch. A central doc is invisible in that review. Colocated docs also die correctly — delete the directory and the doc goes with it.

- **Published package?** Keep `README.md` for consumers, put target state in `ARCHITECTURE.md` beside it. A README is expected to be install-and-usage; don't cram two genres into one file.
- **No home directory?** Auth, data flow, deployment topology, observability — these genuinely cut across everything. They go in `docs/systems/`.
- `docs/systems/README.md` **is an index.** One line per system, linking to the colocated file. Links only. Content never lives in two places.

Reconcile means updating these — not just patching the feature's own design doc. Two features touching billing concurrently both diff against one README, so incompatibility surfaces as a merge conflict instead of shipping silently.

---

## 6. `decisions/`

Immutable. Superseded, never edited.

```markdown
---
id: 0007
type: architecture # architecture | tooling | process | product
status: accepted # proposed | accepted | superseded
supersedes: 0003
---

# Postgres over Mongo

## Context

## Decision

## Consequences
```

Called `decisions/`, not `adr/`, deliberately. Conventional commits, trunk-based development, dropping Safari 15, vendoring instead of forking — none are architecture, all are durable and expensive to relitigate. A folder whose name gatekeeps its own contents gets used less than it should, and the decisions that go unrecorded are disproportionately the cross-cutting process ones — exactly what a fresh agent context has no other way to discover.

`type:` recovers the ADR subset when you want it: `rg 'type: architecture' docs/decisions/`. Taxonomy belongs in a field, not a directory name — directories give you one axis and you'll find the second one later.

Use `template.md`. Never two directories for this.

---

## 7. `research/`

Findings from discovery: benchmarks, spikes, vendor comparisons, prior-art reads.

**Research files are evidence, not commitments.** A doc weighing three options has not chosen one. An agent must not treat the last option described as the decision — if something was decided, there is a record in `decisions/`.

Anything actionable a research doc reveals becomes a backlog line pointing at it. Research feeds the backlog; it never enters the workflow directly — otherwise there are two competing answers to "what might be worth doing".

---

## 8. `backlog.md`

One line per unshaped idea. Keep capture friction near zero; a file-per-idea directory raises it just enough that people stop capturing.

The list is an **unsorted collection dump** — order carries no meaning. Ranking happens at pick time, in front of the human, not in the file.

```markdown
## Features

- Retry failed billing charges with backoff — asked by 3 customers
- Vite 6 migration — breaking changes in plugin API
  - see research/vite-6-migration.md

## Bugs

- Timezone drift in weekly digest — reproducible, low sev

## Debt

- `auth/` still on the old session shim
```

Append at the end of a section so concurrent edits conflict trivially. Prune periodically — move stale lines to `## Parked` or delete them. Items graduate to `work/planned/` when they're worth shaping.

Sub-bullets pointing at `research/` files are fine — those paths never move, unlike work items, so the no-path-links rule doesn't apply.

---

## 9. Anti-patterns

- **A design doc detailed enough to be pseudocode.** Worse than a vague one.
- **Reasoning duplicated between design and ticket.** One copy goes stale.
- **Status in two places** — frontmatter _and_ directory, or checkboxes _and_ ticket files. Pick one owner.
- **A bundle for every item.** Filler docs teach people to skim.
- **Keeping shipped feature docs around.** They contradict each other and poison retrieval.
- **Linking work items by path.** Paths move; use IDs, or permalinks in PRs.
- **Editing a decision record.** Write a new one that supersedes it.
- **Skipping reconcile.** Three features is roughly how long the docs stay trustworthy without it.

---

## 10. Agent quick reference

```text
Starting a ticket
  1. Read AGENTS.md
  2. ls docs/work/*/<feature-id>-*  → read design.md
  3. Read the colocated README.md for any directory you'll touch.
     It is authoritative over design.md.
  4. Read your ticket. Respect "Not in this ticket."
  5. Set status: doing, push, then work.

Blocked by an unanswered question
  Stop. Add it to design.md → Open questions. Do not decide it.

Before opening the PR
  - Done-when conditions pass
  - Colocated README.md updated if the change made it inaccurate
  - design.md amended if implementation proved it wrong
  - Ticket status: done
```
