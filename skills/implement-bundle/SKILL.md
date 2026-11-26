---
name: implement-bundle
description: Use when the human asks to implement, build, or run every ticket of an approved work bundle through sub-agents — "implement bundle X", "orchestrate the tickets of X", "run the remaining tickets with Sonnet sub-agents" — or to continue a bundle whose tickets are part way through. Takes a bundle reference. Not for one ticket in this session (implement-ticket), not for shaping, and not for landing.
argument-hint: '[bundle reference]'
---

# Implement bundle

Drive every ticket of one active bundle to the human's Accept gate, each in its own fresh sub-agent
session running the `implement-ticket` skill, in waves the plan allows, and stop at every gate for
the human. Written for any agent harness; use your harness's own sub-agent mechanism.

You are the dispatcher, never an implementer: the tickets, the plan, and the branches are the whole
state, and you keep your own context free of code so a late ticket gets the same judgment as the
first.

## Path conventions

- `templates/` paths are relative to this skill's directory, the folder holding this file.
- `scripts/` paths are the `workflow-manager` skill's: load that skill by name before the resolve
  step to find its directory.
- Every other path is relative to the repository root, `git rev-parse --show-toplevel`, not the
  current directory.

## Guardrails

- **Accept is the human's gate, per ticket.** Run `complete` only on the human's instruction naming
  that PR in this conversation, never because a hand-back reads ready. Never approve, merge, or
  review a ticket's diff yourself.
- **One ticket, one sub-agent, one PR.** Never claim or build a ticket in this session, and never
  put two sub-agents on one ticket: the claim script makes the second one fail, and a ticket already
  `doing` belongs to whoever claimed it until the human says otherwise.
- **Hand the implementer pointers, not knowledge.** The filled template is its entire prompt. Add
  nothing you remember from this session or an earlier hand-back: the sub-agent reads the bundle
  from its worktree, where sibling PRs' corrections already are, and your recollection would
  outrank the bundle's authority with a copy that may have drifted.
- **Carry an escalation through unchanged.** When a hand-back holds a question the skill reserved
  for the human — behavior, shared architecture, the ticket split, acceptance criteria — present
  both positions and stop. Never answer it on the human's behalf and never redispatch around it.
- **Run a wave only as wide as the plan says.** The frontier is ordered by `depends_on`; parallel
  safety is the plan's Parallelization section. No such section, or one that says none, means one
  ticket at a time.

## Process

### 1. Resolve the bundle and its graph

The argument is a bundle reference, `<bundle-id>` or `<member>/<bundle-id>`. Ask when it is
ambiguous; never guess.

From the main checkout, run `scripts/bundles.sh <reference>`. A non-zero exit, or a status other
than `active`, is your result: report it and stop.

Read the bundle from its branch, never from this checkout's working tree:
`git fetch -q origin bundle/<reference>` then `git show origin/bundle/<reference>:<path>` for the
plan, when the bundle has one, and for every ticket's frontmatter. Build one table: ticket, status,
`depends_on`, and whether the plan's Parallelization section names it as safe to run alongside
another ticket.

**A ticket already `doing` was claimed by an earlier session.** Read its PR with
`gh pr list --head ticket/<reference>/<NN> --json number,url,headRefOid,state`. One with an open PR
is waiting at Accept, or mid-review: treat it as a hand-back to verify in the collect step. One with
no PR was interrupted: report it, and redispatch it only when the human says so, through the resume
form of the template.

**Done when** every ticket has a row, and no row is `unknown`.

### 2. Pick the wave

The frontier is every `todo` ticket whose `depends_on` tickets are all `done`. The wave is the
frontier narrowed by the plan: tickets the Parallelization section names as compatible run together;
any other frontier ticket waits for the next wave. A ticket whose write surface the plan does not
address runs alone.

**Done when** the wave is listed, and the human has not objected to it: state it in one line before
dispatching, since each ticket costs the human a review.

### 3. Dispatch the wave

For each ticket in the wave:

1. Read `templates/implementer-prompt.md` and replace every placeholder: `{{reference}}`, `{{NN}}`,
   `{{root}}` with the main checkout's absolute path, and `{{resume}}` with the resume line the
   template's comment gives when the ticket is already claimed, otherwise with nothing.
2. Spawn one sub-agent with that text as its entire prompt, on the model the Implement row of
   `docs/conventions/models.md` names for this harness, unless the human named one at dispatch.
   Add no session context and no extra instructions. In Claude Code that is the Agent tool with
   the `general-purpose` type, in the background, without worktree isolation — the claim script
   makes the ticket's own worktree.

**Done when** every ticket in the wave has one running sub-agent, and you hold each one's identity.
If the harness cannot spawn sub-agents, stop and give the human each filled prompt to run in a new
session, as `shape-bundle` does at hand-back.

### 4. Collect the hand-backs

Wait for each sub-agent's final report; do nothing to its branch meanwhile. A report is a claim:
verify it before relaying it.

For each report, read `gh pr view <pr> --json url,headRefOid,baseRefName,mergeable,state,comments`
and check that the PR is open against `bundle/<reference>`, its `headRefOid` starts with the
short SHA the report names, and the last `## Design Review` and `## Correctness Review` comments
whose **Commit:** sha is a prefix of `headRefOid` carry, as the first bullet of their Summary, the
verdicts the report implies: Human escalation required in either for an escalation; otherwise
Ready for human review, or Fixes required for a loop stopped after round 3.
A mismatch is reported as one, beside the report's own claim.

Sort each ticket into one bucket:

- **ready for human review** at a current head, with no escalation → the Accept gate.
- **escalation or open question** → the Accept gate, carrying both positions; the human may
  accept as is, direct a fix, or return the ticket to Shape.
- **stopped after round 3** → the Accept gate, with each open blocker and the three moves
  `implement-ticket` offers.
- **no report, or a report with no PR** → check `scripts/bundles.sh <reference>`: a `doing` ticket
  with no PR was interrupted. Report it; redispatch only on the human's word, in the resume form.

**Done when** every sub-agent of the wave has returned and every ticket is in a bucket.

### 5. Hand back at the Accept gate

**For each ticket of the wave, relay the sub-agent's filled hand-back, corrected where the
collect step found a mismatch**, as one plain chat message, in ticket order.

Offer the proposed backlog lines of the whole wave once, through the `backlog` skill, after the
report. Then stop.

**Done when** the report is in chat and this session has written nothing to any branch.

### 6. Continue on the human's word

The human runs `complete` from the main checkout, or tells you to: an instruction naming the PR
runs it through the `workflow-manager` skill with the head SHA the hand-back carried, never the PR's
current head.

After each merge, rerun the resolve step: a merge may free tickets, and a sibling's merge makes
every in-flight ticket's currency check fail, which that ticket's next review round handles. Return
to the pick step while any ticket is `todo` or `doing`.

**Done when** `scripts/bundles.sh <reference>` shows every ticket `done`. Report that, and that
landing is the human's call through the `land-bundle` skill; do not run it.

## Resuming

Nothing this skill needs lives in this session: status is derived from branches and PRs, and every
hand-back is on its PR. A fresh session given the same reference continues from the resolve step,
and a sub-agent dispatched here outlives this session's turn — it stops at its own Accept gate
regardless.

## Checklist

- [ ] No ticket was claimed, built, reviewed, merged, or pushed from this session.
- [ ] Every sub-agent prompt was the filled template and nothing else.
- [ ] Every PR fact in the hand-back was read from the forge, not from the sub-agent's report alone.
- [ ] Every `complete` run here was named by the human in this conversation, at the hand-back's SHA.
