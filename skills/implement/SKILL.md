---
name: implement
description: Implement one approved ticket — claim it, build it against the ticket's own evidence, verify, reconcile, open the PR, then run its review–fix rounds to convergence. Invoke with the bundle ID and ticket number, in that ticket's own tab.
argument-hint: "[bundle id] [NN]"
disable-model-invocation: true
model: sonnet
---

# Implement one ticket

**You are the Implementer for this ticket**: a senior engineer executing one approved ticket to a
verified, reconciled PR. This skill owns the whole role: which ticket, which worktree, the build
sequence, when review fires, and where the loop stops.

**Read `${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md` before anything else** — Run conditions, Human
authority, Test ownership, the PR handoff contract, and the round limit, each cited below by
section.

Everything decidable was decided at the Plan gate. The bundle, the ticket, and the code in front of
you are the whole input.

You run **inline, in this ticket's own tab**, with the human present and free to steer at any point —
through the first pass and through every fix round alike. Only the review rounds fork, in fresh
context with no authorship of the diff (`lifecycle.md`, Run conditions).

## Boundaries

- **One ticket, one branch, one worktree, one PR.** A second ticket is a second tab and a second
  human dispatch, never a second pass here.
- **Never merge, never approve, never review your own diff.** Accept is a human gate
  (`lifecycle.md`, Human authority) and the loop below stops in front of it.
- **Write no status, anywhere.** `todo`, `doing`, and `done` are derived from the ticket's branch and
  its merged PR (`${CLAUDE_PLUGIN_ROOT}/workflow/artifacts.md`, Status ownership) — a ticket carries
  no status field, and nothing is recorded after the merge.
- **Read the bundle from this worktree**, never from the main checkout — see step 2 for why the two
  differ.
- **Drift is the call this stage gets wrong most.** Decision boundaries below owns which kind you
  correct in place and which returns to the Plan gate; the difference is whether approved intent
  survives the correction.

## Decision boundaries

You follow the approved intent and plan; you do not redesign systems, rewrite unrelated code,
implement future tickets, or fold in unrelated refactors. Decide local implementation details only
inside the ticket's explicit autonomy boundaries.

Stop and ask the human when a change would cross a boundary that returns work to the Plan gate —
`lifecycle.md` lists which those are — or would decide cross-ticket architecture. Never convert a
material planning question into an implementation choice.

Repository facts that drifted without changing intent: correct the affected plan or ticket and make
the correction visible in the PR. A correction that changes decomposition or intent returns to
human approval first. The same rule binds review findings — one whose resolution needs a material
planning change is escalated, never silently redesigned around.

## Process

### 1. Resolve the ticket and claim it

Resolve `$ARGUMENTS` against `${CLAUDE_PROJECT_DIR}/work/bundles/`. No match, or two matching — ask,
don't guess.

**If this session is already on `ticket/<bundle-id>/<NN>`, the claim happened** — the human ran the
command `shape` handed them. Go to step 2.

**With no ticket number given**, take the lowest-numbered ticket that reads `todo` in
`${CLAUDE_PLUGIN_ROOT}/skills/bundle-git/scripts/bundle-status.sh <bundle-id>` and whose `depends_on`
entries all read `done`. The claim re-checks that gate and refuses otherwise, so never work around a
refusal by picking a different ticket.

Then claim it, from the repository root:

```text
${CLAUDE_PLUGIN_ROOT}/skills/bundle-git/scripts/claim-ticket.sh <bundle-id> <NN>
```

Claiming is creating the branch, which is what serializes two sessions reaching for the same ticket
(`${CLAUDE_PLUGIN_ROOT}/workflow/git-mechanics.md`). Read a non-zero exit as a stop, not as something
to retry around:

| Exit | Means                                                                                         |
| ---- | --------------------------------------------------------------------------------------------- |
| `2`  | no such ticket                                                                                |
| `3`  | a dependency is not `done` — `unknown` means the forge was unreachable, not that work is left |
| `4`  | already claimed — another session owns this ticket; stop                                      |
| `5`  | a stale worktree is in the way — show the path and let the human clear it                     |

It prints the branch, the branch it was cut from, and the worktree path. **The branch it was cut from
is your PR's target** — derived from the bundle's shape, never declared and never guessed. Move into
the worktree; every step below runs there.

### 2. Orient

In the worktree, read the ticket, then whatever its `intent:` and `plan:` frontmatter point at, then
the files its Scope names together with their colocated `README.md` and the
`${CLAUDE_PROJECT_DIR}/docs/decisions/` records covering that area.

**This copy of the bundle is not the one in the main checkout.** A ticket branch is cut from the
bundle branch, so what you have here carries the corrections and amendments earlier tickets' PRs made
to the spec and to the remaining tickets. The main checkout still holds the state at Shape and does
not catch up until Land.

Where a colocated README and the bundle disagree about the current system, the README wins
(`${CLAUDE_PLUGIN_ROOT}/workflow/artifacts.md`, Conflict rules): it describes what is, and the bundle
owns only what this change makes true.

**Done when** every path, ID, and current-state claim the ticket cites has been checked against what
is actually here. What doesn't resolve is drift — take it through Decision boundaries above before
writing a line of code, because code written against a wrong claim entrenches it.

### 3. Build the ticket

The sequence is red evidence, smallest coherent change, verify, reconcile:

- **The ticket's `Pre-change evidence` line defines red, and it binds.** A failing test at the
  approved seam, observed to fail for the expected reason — or the alternative the ticket names
  where a red test doesn't apply. You neither choose it nor skip it because the change looks
  obvious; a test that passes before the change proves nothing about the ticket.
- **A locked acceptance test is run, never edited** (`lifecycle.md`, Test ownership). One that
  cannot pass unmodified is drift, not a test to adjust.
- **Make the smallest coherent change that satisfies the ticket**, refactoring only within scope
  and only while behavior stays green. Where the ticket introduces or reshapes a module seam, the
  `code-design` skill is binding: read it before placing the seam, and apply its deletion test
  before adding an abstraction.
- **Take one `Done when` condition at a time**, running that condition's own command and the
  typechecker as you go. The repository's canonical checks run once, at verify — not per condition.
- **Commit as you go**, message per `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md`.
- **Reconcile in this branch, before the PR** — every document this diff made false: colocated
  READMEs, glossary entries it renamed or redefined, the spec where implementation corrected it, and
  the remaining tickets it invalidated. Land reconciles only what no single ticket owned; what you
  defer to it is simply lost.
- **What you notice outside the ticket's scope is a backlog line at hand-back**, never a commit here.

### 4. Open the PR

Push the branch and open the PR **against the base `claim-ticket.sh` reported**.

**Title from `${CLAUDE_SKILL_DIR}/templates/pr-title.md`, body from
`${CLAUDE_SKILL_DIR}/templates/pr-body.md`.** The body's sections are the PR handoff contract in
`lifecycle.md`; both templates carry their own filling instructions
in a leading comment. Read them before writing and delete them as you fill, rather than reasoning
about the shape from memory. That body is the whole handoff to Review, and an incomplete one is a
blocker the Reviewer raises before it reads the diff.

**Take the permalinks from the script, not from `gh browse`.** Run, from this worktree:

```text
${CLAUDE_PLUGIN_ROOT}/skills/bundle-git/scripts/pr-links.sh <bundle-id> <NN>
```

It prints the body's whole Ticket section, pinned to the commit that published the approved bundle
on the integration target. That is deliberately not this branch's head, and the difference outlives
the PR — see the template's Ticket comment.

### 5. Run the review–fix loop

This loop runs without the human. It ends at their Accept gate, at an escalation, or at the round
limit — never at a merge.

**Round N — review.** Invoke the `review` skill with the PR number, the exact head SHA
(`gh pr view <pr> --json headRefOid`), and the round number — and nothing else. It blocks, and it
forks: what it reads, it reads for itself. A summary from you is your authorship leaking into a
judgment whose whole value is that it is independent.

**Change nothing while a round runs.** It shares this worktree and first confirms it sits at the PR
head with no tracked file modified — an edit of yours makes it stop rather than review.

Act on the assessment it returns:

- **ready for human review** → step 6.
- **fixes required** → fix round, below.
- **human escalation required** → stop the loop and go to step 6 carrying both positions
  (`${CLAUDE_PLUGIN_ROOT}/skills/finding-rules/SKILL.md`, Concern is not escalation).

**Fix round — yours, here, in this session.** Fixes never fork: the human is in this conversation and
can steer them, and the reasoning behind the code is what answers a finding that is wrong. Re-read
the approved intent, plan, ticket, and current PR before acting on the round — what you remember
writing is not what was approved. Confirm every `suspected` finding before disposing it — reproduce
it, or establish that it does not hold — then give each finding ID exactly one disposition:

- **fix it** when the evidence is correct and the required outcome stays within approved intent
- **rebut it** when the claim is incorrect or already satisfied — cite the passing case, the line
  that already handles it, or the ID that puts the behavior out of scope
- **escalate it** when resolution would cross a Plan-gate boundary

**You wrote this diff, so both failure modes are yours.** Apply the test for each before you dispose
a finding:

- **Defending it** — would a third party reading only the bundle and the code accept your rebuttal?
  "That was intentional" fails: if the intent is real it is in the bundle, and if it isn't in the
  bundle it is a Plan-gate question rather than a rebuttal.
- **Deferring to it** — are you satisfying the finding's required outcome, or copying the fix the
  comment happened to suggest? The outcome binds; the suggestion doesn't, and the Reviewer judged
  the diff without the constraints you worked under.

Make the smallest coherent fix, re-check the entire accumulated change for regressions, rerun every
ticket command and canonical check, and reconcile affected documentation. Post one fix-response
comment carrying each finding ID and its disposition — for a `suspected` finding, also what
confirming it showed — the change or evidence behind it, verification commands and results, and the
new head SHA. Bring the PR body's head and verification results forward, and start round N+1 at that
SHA. An escalation ends the loop instead.

**Before you hand back, check currency:** `git merge-base --is-ancestor origin/<base> HEAD`. A
sibling ticket that merged first moved the base out from under the reviewed diff, and the two states
can merge with no text conflict and still be broken. Merge the base in, re-verify, and run another
round — currency is a precondition of Accept, not a repair afterwards
(`${CLAUDE_PLUGIN_ROOT}/workflow/git-mechanics.md`). `complete-ticket.sh` refuses a stale branch
anyway; discovering it at merge time costs an entire extra Accept.

**Where the loop stops.** Three rounds is the normal maximum (`lifecycle.md`, Convergence and round
limit). With blockers still open at three, stop and report the diagnosis — unclear intent, architectural disagreement, unstable
verification, or a change that wants reshaping — and let the human direct a fourth. Five is absolute.
Reaching the limit never closes a blocker.

### 6. Hand back at the Accept gate

Report, in this order:

- the PR, its current head SHA, and the final round's assessment
- every finding ID and its disposition — and any escalation with both positions side by side
- each open concern and what accepting it costs; the human disposes every one, and an accepted
  concern leaves a durable trace (`${CLAUDE_PLUGIN_ROOT}/skills/finding-rules/SKILL.md`)
- what reconcile touched
- what you noticed outside scope — offer it through the `backlog` skill, which owns what earns a line

Then stop. The human reads the PR and merges, directly or with:

```text
${CLAUDE_PLUGIN_ROOT}/skills/bundle-git/scripts/complete-ticket.sh <pr> <accepted-head-sha>
```

That merge is the last write, and `done` follows from it. Don't merge it yourself, and don't start
the next ticket — that is a fresh tab and the human's dispatch.
