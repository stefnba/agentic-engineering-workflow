---
name: implement
description: Execute one ticket from a shaped bundle until its done-when passes — TDD at the spec's agreed seam, then verify, reconcile, and open the PR. Invoke fresh per ticket with the bundle ID, optionally naming a ticket number; without one, the next unblocked todo ticket is taken.
argument-hint: "[bundle id] [ticket NN]"
disable-model-invocation: true
---

# Implement one ticket

**Executor role**: turn one settled ticket into a verified, reconciled change set on its own
branch, ending at an open PR. Everything decidable was decided upstream — the spec passed the
human's Plan gate — so the ticket, the spec, and the code are the full input. Stage definitions
(verify, reconcile, where review sits) live in
[docs/agentic-workflow.md](../../docs/agentic-workflow.md); this skill doesn't restate them.

Two rules apply across every step:

**Test-first at the agreed seam.** The spec's `Testing Decisions` section names the seam — the
observable boundary the human confirmed during shaping (in a single-file bundle, the `Seam:`
line under `Done when`). Every test you write attaches there. The seam is a shaping decision:
you have no authority to move it, add one, or test below it at internals.

**Surface drift, don't absorb it.** When the bundle and the codebase disagree, the kind of
disagreement decides the move:

- _Factual drift_ — the spec or ticket describes code that has since moved, been renamed, or
  never existed: fix the spec or ticket first, then write the code against the corrected text,
  and say so in the PR. The spec is living documentation; code written against its wrong claim
  entrenches the error.
- _Decision drift_ — the seam won't attach, an AC is unreachable as written, a requirement has
  two viable readings, or the change would contradict a `docs/decisions/` record: stop and put
  the question to the human. Resolving it yourself silently re-runs the Plan gate without them.

## Process

### 1. Resolve the bundle and pick the ticket

**Resolve the bundle** with `ls work/*/$ARGUMENTS*`. A single `.md` file is the whole bundle —
spec and ticket merged; its `Done when` is the ticket. A directory bundle: read `spec.md` in
full, then the ticket. No match or two bundles matching — ask, don't guess.

**Pick the ticket**: the one named in the invocation, otherwise the lowest-numbered ticket with
`status: todo` whose `depends_on` entries are all `done`. If the named ticket has an unmet
dependency, stop and report it — ticket order is part of the approved decomposition, not yours
to reshuffle.

### 2. Activate

**Move a fresh bundle to active**: if the bundle still sits under `work/shaped/`, `git mv` it
to `work/active/` — starting its first ticket is what "in progress" means.

**Create the ticket's branch** off the default branch: `<bundle-id>/NN-<slug>` (single-file
bundle: `<bundle-id>`). One ticket, one branch, one session — parallel tickets belong in
separate sessions on separate branches.

**Set the ticket's `status: doing`.** Done when: you are on a fresh branch and the ticket
frontmatter says `doing`.

### 3. Read the code

**Read the files the ticket's Scope names, plus their colocated READMEs.** Where a README and
the spec disagree about the current system, the README wins — it describes what is; the spec
owns only what this change makes true. A path the ticket cites that doesn't resolve is
factual drift — handle it under the drift rule before writing anything.

### 4. Red-green loop

Work one acceptance criterion at a time, in the ticket's `Done when` order:

1. **Red** — write one failing test for the criterion, at the seam, phrased in the spec's
   Given/When/Then language. Run it and watch it fail; a test that passes before the change
   exists tests nothing.
2. **Green** — write the least code that makes it pass. Run that test file and the typechecker
   before moving on, not the full suite — the suite comes once, at verify.
3. Next criterion.

**Locked acceptance tests are read-only.** Where the bundle lists pre-authored test files,
run them as-is; a locked test that can't pass unmodified is drift, never an edit.

**Write unit tests below the seam freely** — but they are part of the diff under review's
judgment, not verification, so they earn nothing at the verify step.

**Refactor only inside the ticket's scope, only on green.** Wider cleanup you're tempted into
is a backlog line, not a commit — wide refactors get shaped into their own expand → migrate →
contract tickets.

Done when: every acceptance criterion in the ticket's `Done when` has a test at the seam that
failed first and passes now.

### 5. Verify

**Run every `Done when` line and the repo's own checks** (full test suite, lint, typecheck —
whatever the consuming repo's CI runs). Every line passes, exactly as written — a line that
won't pass goes back through the drift rule, not into a weakened test or a reworded ticket.

### 6. Reconcile

**Repair what the diff made stale, in the same branch**: colocated READMEs now describing
old behavior, glossary entries the change renamed or redefined, `spec.md` where implementation
corrected it, and remaining tickets this ticket invalidated — amend them, don't leave them to
mislead the next session. Done when: no document in the repo describes the pre-change system.

### 7. Close out

**Set `status: done`** — legitimate only while every `Done when` line holds.

**Commit, push the branch, open the PR.** Reference the bundle by permalink, never bare path —
the bundle dies at ship; the permalink survives it. The PR body carries the verify results and
names what reconcile touched, so review can judge the reconcile half's honesty.

**Stop there.** Review is the next stage and a human gate: no merging, no self-review, no
starting the next ticket — the next ticket gets a fresh session.
