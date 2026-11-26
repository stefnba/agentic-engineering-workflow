# Bundle rules

The rules a bundle must satisfy: where it lives, what makes it complete, how it is decomposed,
and how it ends. `shape-bundle` shapes against them and
`critique-bundle` judges against them.

## Contents

- Lifecycle
- Land
- Shaping routes
- Layout
- A complete bundle
- Revising a committed bundle
- Vertical slicing
- Dependencies and parallelization
- Artifact authority

## Lifecycle

A **bundle** is the disposable container for one coherent approved outcome. It moves through three
stages:

- **Shape** — the `shape-bundle` skill drafts it, fresh-context **critics** challenge its shape and
  attack it as written, and the human approves it at the **Plan gate**. Until then it is an
  uncommitted draft. On approval, the bundle gets its own branch, `bundle/<reference>`, cut from the
  integration target, and one commit on it adds the bundle and deletes the backlog lines the human
  confirmed it covers.
- **Implement** — each ticket runs in its own fresh agent session, the **implementer**, and lands as
  one PR into the bundle branch. Reviewers judge it against the ticket and the intent it references;
  the human accepts it by merging. After the last ticket is `done`, the bundle may gain one
  **sweep ticket** for low-risk review findings through the `sweep-bundle` skill, which holds what
  one may admit.
- **Land** — once every ticket has merged, the bundle branch lands on the integration target; see
  Land below.

The human may abandon a bundle at any point through the `workflow-manager` skill.

Before Shape, `/interview-me` settles a vague ask into a problem, its constraints, and its
motivation. Shape starts from that settled intent.

## Land

Land is its own stage, never part of a ticket's PR. It starts when every ticket is `done` and the
human says to land the bundle, and the `land-bundle` skill runs it on the bundle branch: plan
decisions tagged `(decision record at Land)` become decision records, what only became true once
every ticket merged reaches the durable docs, the backlog is reconciled, the bundle folder is
deleted — git history keeps it — and a PR takes the bundle branch into the integration target.

## Shaping routes

The route a bundle takes decides which artifacts it holds. The routes, the framework for choosing
one, and what a lighter route may never drop are in the `shape-bundle` skill's
`references/shaping-routes.md`.

## Layout

**The scope is the workspace member the outcome belongs to** — `apps/<name>/` or
`packages/<name>/`. A bundle spanning an app and the package it motivates takes the app; one
spanning two apps, or outside every member, takes the repository root.

**A bundle is always a directory at `<scope>/work/bundles/<bundle-id>/`**, next to the scope's
`work/backlog.md`. The bundle ID is `YYYY-MM-DD-<slug>`: the shaping date and a short lowercase
kebab-case slug — short enough that the Shape and revise commit subjects stay within 72 characters.

```text
apps/business_performance_studio/work/
├── backlog.md
└── bundles/
    ├── 2026-08-17-fix-typo/             # direct ticket: no spec
    │   ├── brief.md
    │   └── ticket.md
    ├── 2026-08-17-slow-extracts/        # investigation or spike: no tickets
    │   ├── brief.md
    │   └── spike.md
    ├── 2026-08-17-add-export/           # intent plus tickets, one ticket
    │   ├── brief.md
    │   ├── spec.md
    │   └── ticket.md
    └── 2026-08-17-add-drivers/          # intent, plan, and tickets
        ├── brief.md
        ├── spec.md
        ├── plan.md
        └── tickets/
            ├── 01-contracts.md
            └── 02-catalog.md
```

**Use `ticket.md` for exactly one ticket and `tickets/NN-<slug>.md` for more than one** — never
both, whatever other artifacts exist. Ticket numbers are two-digit, stable once approved, and
encode identity, not execution order. A lone `ticket.md` is number `01`. The number in the file name
and the ticket heading match.

**Write repository paths inside a bundle relative to the repository root** — `apps/…/bps/core/…`,
not `bps/core/…` — so they resolve wherever the reader stands.

**Commit a bundle with the reserved, scopeless type `bundle`** from the Agentic engineering
workflow section of `docs/conventions/git.md`,
whichever work folder it lives in. The same commit deletes the covered lines from the scope's own
backlog; a covered line in another member's backlog goes in a separate, scopeless `backlog`
commit.

## A complete bundle

A bundle is ready for the Plan gate only when:

1. Every material question is resolved in the section it constrains, and no Open questions section,
   TODO, placeholder, `<!-- -->` guidance comment, or template `#` frontmatter comment survives.
2. Every ticket carries concrete done-when evidence. A spike instead carries numbered evidence bars
   and a budget.
3. Every acceptance criterion and invariant maps to at least one ticket.
4. Dependencies and parallel claims are credible.
5. Fresh-context critics have attacked it, every alternative they raised carries a disposition,
   and no blocker remains.
6. `brief.md` states nothing the other bundle files do not, and no other bundle file changed after
   it was last written. The Architect writes and checks it after critique, so critics never judge
   it.

**Keep `brief.md` true for as long as the bundle exists.** Whoever changes another bundle file —
a revision, an implementer correcting the spec or a later ticket, the sweep ticket — rewrites the
brief lines that change makes false, in the same commit.

**Keep execution state out of bundle files.** No status field, PR state, or blocker note — status
lives in branches and PRs, and a copy goes stale.

**Leave the backlog to the Shape commit.** Tickets never delete backlog lines; the bundle's own
commit does, for the lines the human confirmed at the Plan gate.

**Never reference a bundle from code, durable docs, or comments** — Land deletes it.

## Revising a committed bundle

A committed bundle can be revised while its tickets are in flight, through a repeated critique and
Plan gate. A revision may not:

- **Change the ticket set.** Adding or removing a ticket file rewrites the `depends_on` graph under
  tickets already started. A bundle that needs a different decomposition is stopped and reshaped.
  The one exception is the sweep ticket the `sweep-bundle` skill adds after every ticket is `done`.
- **Change a started ticket's contract.** Revise only tickets nobody has started; the human knows
  which have.

## Vertical slicing

**Default to a thin vertical slice** that is demonstrable, behaviorally testable, independently
reviewable, and independently revertible where practical. A slice may cross core, composition, and
entrypoint layers; few files is not the goal.

**Use a horizontal foundation slice only when no vertical slice can be built safely first**, and
make the ticket name the later slice it enables and carry its own verification.

**For refactors and migrations, go expand → migrate → contract**, keeping every intermediate state
supported.

**When the outcome is "behavior unchanged", pin current behavior with characterization tests
first:** with a plan, it names the slice that adds them; without one, a `depends_on` edge puts them
ahead of every refactoring ticket; in a single-ticket bundle they are its pre-change evidence.

**Keep each ticket to one session and one reviewable PR.** A ticket delivering most of the spec's
requirements is the usual sign it is several tickets.

## Dependencies and parallelization

**Record only real blocking edges.** A ticket depends on another when it cannot satisfy its done-when
against the repository state before that other ticket merges — not because the numbering looks
natural.

**Judge parallel safety on write surfaces, not on missing edges.** Shared modules, contracts,
schemas, generated files like `definitions/schema.json`, `uv.lock`, and integration tests can
collide between tickets with no dependency. The plan owns that judgment; `depends_on` owns only hard
order.

**Keep a parallel wave to a few tickets.** Each runs in its own session the human steers and
reviews, and human attention is the real ceiling.

One ticket is one PR. If that produces meaningless PRs, merge the tickets before implementation.

## Artifact authority

| Artifact        | Owns                                                                   | Never owns                                   |
| --------------- | ---------------------------------------------------------------------- | -------------------------------------------- |
| `spec.md`       | the approved outcome, behavior, constraints, and invariants            | current repository facts, interior design    |
| `plan.md`       | how this repository realizes and decomposes the spec                   | behavior the spec lacks                      |
| ticket          | one slice's scope, dependencies, autonomy, and done-when evidence      | cross-ticket architecture, product decisions |
| `spike.md`      | the open question, the evidence that settles it, the decision it feeds | the answer itself                            |
| `brief.md`      | nothing: the human's one-page view, derived from the files above       | any fact those files do not state            |
| PR and CI       | what changed, what ran, what was reviewed                              | intent or decomposition                      |
| durable docs    | how the system works now (`ARCHITECTURE.md`, READMEs)                  | in-flight plans                              |
| decision record | a durable, contested choice and why (`<scope>/docs/decisions/`)        | work status                                  |
| `GLOSSARY.md`   | canonical domain terms and their avoided synonyms                      | general programming terms                    |

**Resolve a conflict by axis:** the spec wins on outcome and behavior, the approved plan on
technical direction and decomposition, the ticket on one slice within both. A ticket may narrow the
plan, never contradict it.

**Surface drift between durable docs and code rather than picking a side.** Durable docs outrank the
bundle for current-system claims; if code contradicts them, report both readings to the human. A
part `ARCHITECTURE.md` marks _(planned)_ is target design the bundle may build, not drift.

**Use the glossary's terms and never an entry's Avoid synonym**, in every bundle file. The scope's
`docs/GLOSSARY.md` owns its domain's terms and the root's owns shared ones; a bundle that
contradicts or extends either says so, and the glossary change is a reconciliation target.
