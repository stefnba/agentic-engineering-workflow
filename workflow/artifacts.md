# Artifacts

Artifacts have one owner, answer one question, and live only as long as that question remains
useful.

## Authority

### In flight

| Artifact                    | Question it owns                                                                    | It does not own                                           |
| --------------------------- | ----------------------------------------------------------------------------------- | --------------------------------------------------------- |
| Backlog (`work/backlog.md`) | What candidate work or follow-up remains unpicked?                                  | Priority, approval, or implementation scope               |
| Discovery evidence          | What did we observe or learn?                                                       | Commitment, priority, or implementation scope             |
| Intent artifact (bundle)    | What outcome, behavior, constraints, and invariants did the human approve?          | Current implementation facts or interior design           |
| Engineering plan (bundle)   | How will this repository realize and decompose the approved intent?                 | Behavior or requirements absent from intent               |
| Ticket (bundle)             | What may one agent change, what does it depend on, and what evidence makes it done? | Cross-ticket architecture or unapproved product decisions |
| PR and CI                   | What changed, what checks ran, what was reviewed, and what is the current state?    | Intent, decomposition, or durable system truth            |

### Durable

| Artifact                                       | Question it owns                                                             | It does not own                                        |
| ---------------------------------------------- | ---------------------------------------------------------------------------- | ------------------------------------------------------ |
| Durable system docs (`src/<domain>/README.md`) | How is the current system intended to work now?                              | In-flight plans or historical feature state            |
| Decision record (`docs/decisions/`)            | Which durable, consequential choice was made and why?                        | Work status or step-by-step implementation             |
| Research doc (`docs/research/`)                | What durable reference did investigation establish?                          | Evidence for one bundle, which lives with that bundle  |
| Glossary (`GLOSSARY.md`)                       | Which project-domain terms and rejected synonyms are canonical?              | General programming or workflow-artifact terminology   |
| Agent instructions (`AGENTS.md`)               | Which repository or package conventions and gotchas must every agent follow? | Domain behavior or workflows owned by linked documents |
| Git conventions (`docs/conventions/git.md`)    | Which git conventions must a human follow here?                              | Anything a script reads — that is `work/config.conf`   |
| Script settings (`work/config.conf`)           | Which settings do the workflow's scripts run with?                           | Conventions no script consumes                         |

## Conflict rules

Authority is axis-specific, not one global document hierarchy:

- **Approved outcome and observable behavior:** the intent artifact wins. A plan or ticket cannot
  override it.
- **Binding technical direction and decomposition:** the approved plan wins. A ticket may narrow the
  plan to one slice but cannot contradict it.
- **One slice's scope, dependencies, autonomy, and evidence:** the ticket wins within the approved
  intent and plan.
- **Execution and review state:** the PR and CI system win. Do not copy transient PR states into spec
  or plan metadata.
- **Repository operation:** the applicable convention document wins for its operation; `AGENTS.md`
  and tool-specific instruction files point at the owning instructions rather than restating them,
  and [Monorepos](#monorepos) below owns how a package's file relates to the root one.
- **Terminology:** the applicable `GLOSSARY.md` owns canonical project-domain terms and avoided
  synonyms; workflow and artifact terms remain owned by their defining documents. Agent prose and
  code identifiers use canonical terms and never an avoided synonym; Review judges adherence without
  a separate mechanical gate. If output and a glossary conflict, surface both readings instead of
  silently choosing one; [Monorepos](#monorepos) below owns which glossary applies when there is
  more than one.
- **Decision history:** decision records are immutable. Supersede a decision with a new record; never
  edit the old record to make history look current. A repo-wide terminology rename is the one
  exception and sweeps records too: renaming a thing changes no decision made about it, and a record
  left in the old vocabulary reads as if it governed something else.
- **Process versus prompt:** workflow, artifact, and repository convention documents outrank agent
  prompts. Prompts load those owners and contain only role-specific judgment, escalation, and output
  instructions.
- **Current system claims during active work:** durable colocated system docs outrank the bundle. If
  code or tests contradict those docs, surface the drift and reconcile it; never silently choose the
  bundle's version.

Correct factual drift in the artifact that owns the fact. A correction material enough to reopen an
approved decision returns to the Plan gate instead — [Lifecycle](./lifecycle.md) owns which changes
those are.

## Monorepos

A repository with more than one workspace package splits some artifacts per package and keeps the
rest at the root. Which side an artifact falls on is fixed, not a per-repository choice:

| Artifact                                                 | Where                |
| -------------------------------------------------------- | -------------------- |
| `work/config.conf`, `work/backlog.md`, `work/bundles/`   | root only            |
| `docs/conventions/`, `docs/decisions/`, `docs/research/` | root only            |
| `AGENTS.md`, `GLOSSARY.md`, durable system docs          | root and per package |

One backlog and one bundle tree serve the whole repository. A bundle's tickets routinely cross
packages, so a per-package split would either duplicate the bundle or hide the half of it that
lives elsewhere; the area terms on a line or in a record are what say which package it concerns.

**The nearest file wins by adding, never by replacing.** A package `AGENTS.md` carries what is
specific to that package on top of the root file, and the closest `GLOSSARY.md` owns a term its own
domain defines while the root owns vocabulary shared across domains. A package file that restates
the root's content is the failure mode — two copies, and no signal which one went stale.

A domain's `GLOSSARY.md` sits at that domain's root. The root glossary then carries a `Domains`
section linking each one and stating how the domains relate: there is no separate map file, and the
section exists only once a sub-glossary does. Which glossary a term belongs in follows from the
term's subject, and an unclear case is a question for the human rather than a guess — a term filed
in the wrong domain is invisible to everyone working in the right one.

## Discovery evidence

Discovery evidence is not always a file: a codebase scan's findings may live only in chat, triaged
live into a backlog line (accepted) or rejected. Write a decision record for a rejection only when
it encodes a durable choice — "this stays as it is, because X" — never merely to stop a finding from
resurfacing. Drop a rejection with no durable reason behind it and let it resurface next scan.

## Bundles

### Contents

A bundle is the disposable container for one coherent approved outcome. [Work bundles](./bundle.md)
owns the layout and what a complete bundle contains; [Shaping routes](./shaping-routes.md)
owns which artifacts a route requires and when to split sequential bundles.

### Intent artifact

“Intent artifact” is a role, not one mandatory filename. It may be a

- feature spec
- bug statement
- target architecture and invariants
- migration objective
- security requirements
- ticket that contains the complete intent for a small change

Whatever the form, it answers one test: if two competent implementations differed internally, what
must still be identical?

### Status

Under `work/`, commit artifact content — spec, plan, and ticket text. Never write execution state
of any kind into an artifact file: bundle and ticket status, PR/CI state, and blocked-ness are
derived at the moment they are asked for; [Git mechanics](./git-mechanics.md) owns the states and
their derivation. Unmet ticket dependencies are derived from `depends_on`; an external blocker is
raised on the PR or escalated to the human, never recorded as ticket metadata that can go stale.

### Lifetime

A bundle is disposable: Land deletes it, and there is no `done/` or landed-bundle archive — git
history preserves temporary artifacts. [Work bundles](./bundle.md) owns the lifetime stages a
bundle moves through.

Each implementation PR is the permanent historical bridge from the landed change to its temporary
planning context — which is why the links in its body have to outlive the bundle. The PR handoff
contract in [Lifecycle](./lifecycle.md) owns what that body must carry.

The PR is also the main surface for implementation evidence, review findings, fix responses, and
review state. Its links do not transfer authority: the linked intent, plan, and ticket remain
authoritative while the work is active. PR comments are an execution log, not a second
specification or durable system documentation.

**Never reference a disposable bundle from code, durable documentation, or comments — it will not
exist once Land deletes it.**

## Decision records

A choice earns a record only when it was **contested, consequential, and not obvious from the
code** — all three. The test: someone changing it next year without the reasoning breaks something
or spends a week rediscovering why. Most bundles produce none; twenty a year means the bar slipped
and the folder is a log nobody reads.

A choice with no rejected alternative was a default, not a decision, and belongs with its owner: a
convention in `docs/conventions/`, a term in `GLOSSARY.md`, an unpicked follow-up in
`work/backlog.md`, current behavior in the durable system docs.

## Backlog

### What earns a line

A line is a pointer to a decision someone makes later, so it earns its place only when all three
hold:

- **It outlives the session that noticed it.** Something fixable in two minutes, in a file already
  open, gets fixed.
- **It still means something in three weeks.** A line nobody can decode is worse than no line: it
  occupies space and creates a small obligation to work out what it meant.
- **It needs the Pick gate.** It is work someone must choose to do — not a fact, an open question,
  or a preference.

What misses the bar has an owner already: a term dispute goes to `GLOSSARY.md`, a settled rationale
to a decision record, an unsettled question to the human, work a live bundle already covers to that
bundle. Taste with no referent behind it goes nowhere — the construction that keeps a nitpick out of
a finding ([Finding rules](../skills/finding-rules/SKILL.md)) keeps it out of here too.

**A line states the problem, never the solution.** The solution is what shaping is for, and one
written now is stale by the time it is read. A line may carry the evidence that proves its claim — a
drift nobody can cheaply re-verify is worth the extra lines — but never a design for the fix.

**A line carries what is outstanding, never a ledger of what is already done.** When part of its
scope lands, delete that part rather than moving it into an "already handled" clause. The repository
answers what exists; a line that also answers it has to be maintained every time something lands,
and goes stale the first time nobody does.

### Tags

Every repository uses the same three **kind** tags, because they classify a line's standing in this
workflow rather than anything about the repository:

- `[idea]` — worth exploring, nothing agreed
- `[drift]` — a noticed inconsistency between documents, or between documents and code
- `[follow-up]` — concrete agreed work

## Areas

An **area** is what an item is about — the second axis to the kind above — and it spans the two
artifacts that outlive every bundle: a backlog line carries its kind then its areas
(`- [drift] [api] …` — always space-separated, since `][` parses as a reference link), and a
decision record carries the same terms in `areas:`.

That vocabulary is never declared as a list; a registry drifts from use in both directions. **The
areas already in use are the vocabulary:** read the backlog's lines and the records' frontmatter,
reuse the closest term, coin one only when none fits. Widening an existing term beats a
near-synonym — `auth` beside `authentication` is what this prevents.

An area names a place, not a topic: a package, a domain, a deployable — `api`, `client`, `billing`.
If a reader can't tell which directories it covers, two people will tag the same work differently.
Keep them coarse enough to repeat, add a cross-cutting term like `ci` or `deps` only once work
accumulates there, and never reuse a kind as an area. Several areas per item are fine; a repository
with no meaningful split runs with two or three, or none until a second earns its place.
