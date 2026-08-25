---
name: review-pr
description: Judge one implementation PR at its exact head SHA. Dispatched by the implement-ticket skill once per review round; also use when the user asks to review or re-review a ticket's PR. Takes the PR number, head SHA, round number, and a scope — full (default) or delta (only the fixes since the previous round). Every argument is optional; an omitted PR number resolves from the current branch, an omitted SHA or round number from the forge.
argument-hint: "[PR number] [head SHA] [round number] [full|delta] — omitted values are derived"
context: fork
agent: reviewer
background: false
---

# Review PR

One review round: judge the PR at the assigned head SHA and return the round's findings.

## Process

### 1. Resolve the assignment

`$ARGUMENTS` carries up to four values in order — PR number, head SHA to judge, round number,
and a scope, `full` or `delta`.

The implement-ticket loop passes the first three explicitly; a
human typing `/review-pr` may pass any prefix of them, including nothing.

A passed value binds exactly as given. Derive each omitted one — never stop over it, and never ask:

- **PR number** — the current branch's PR: `gh pr view --json number -q .number`. No PR for the
  branch is your result: report it and stop.
- **Head SHA** — the PR's current head: `gh pr view <pr> --json headRefOid`. A passed SHA is an
  independent cross-check on the dispatch; a derived one waives that check — say so in your
  report and beside the round comment's `Head:` value, so the record shows which one this was.
- **Round number** — one more than the highest `Review — round <N>` comment already on the PR;
  `1` when there is none. This keeps finding IDs continuous across rounds.
- **Scope** — `full`; round 1 is `full` regardless — there is no earlier round to narrow
  against.

Resolve the PR with `gh pr view <pr>`. A number that doesn't resolve is your result: report it
and stop. Anything that does resolve is a working value, not a result — announcing the resolved
dispatch is not running the round; the round ends only at step 6's report or at a stop a step
names.

**Done when** you hold all four values and the PR resolves.

### 2. Confirm the tree

**The SHA resolved in step 1 is the one you judge.** Confirm:

- the SHA to judge is the PR's actual head — `gh pr view <pr> --json headRefOid`; for a derived
  SHA this only catches a head that moved since step 1
- the tree you are in sits at that SHA — `git rev-parse HEAD`
- no tracked file is modified — `git status --porcelain --untracked-files=no`
- the PR has no text conflict with its base — `gh pr view <pr> --json mergeable -q .mergeable`. Only
  `CONFLICTING` is a stop; `UNKNOWN` is the forge still computing it, wait a few seconds and check
  once more before treating it as unresolved. Branch protection, a pending required check, or a
  missing approval (`mergeStateStatus`: `BLOCKED`, `UNSTABLE`, `BEHIND`) are not this check's
  concern — those gate the merge, not whether the diff can be judged, and this review is often what
  clears them.

Untracked build output from an earlier round is expected. Any other disagreement stops the round —
report it instead of reviewing, because a review dispatched from the author's own worktree is
otherwise indistinguishable from reviewing unpushed work. A text conflict is the same kind of stop:
judging a diff that cannot land as reviewed spends the round on a defect a sync resolves, not one a
finding would.

**Done when** all four checks agree, or the round has stopped with the disagreement reported.

### 3. Read the contract

Nothing reached you but the dispatched values. Read for yourself:

- repository conventions and the decision records the change touches
- the complete diff and, on round 2 or later, all earlier review and fix-response comments
- the PR body and planning record, per the route below

The head branch name picks the route: `ticket/<bundle-id>/<NN>`
(`${CLAUDE_PLUGIN_ROOT}/workflow/git-mechanics.md#branch-naming`) means a bundle backs this PR;
any other name means none does.

- **Bundle-backed** — read the bundle and the ticket, including its Done when conditions. The
  body must satisfy the handoff contract in `${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md` — an
  incomplete handoff is a blocker before you read the diff.
- **No bundle** — there is no planning record. The body must state the intent, delivered scope,
  verification commands and results from the current head, and known limitations or residual
  risk; a missing one is the same blocker. With no Done when condition, requirement fit drops out
  of this review.

**Done when** the route is determined and each artifact it calls for has been read at this round's
head.

### 4. Verify at the head

Rerun every verification command the ticket names and the repository's canonical checks, at the
head.

**Done when** your role's recorded-result condition holds at this head.

### 5. Judge the round

Judge the change under your role's contract. On round 2 or later, check every earlier finding ID
against the author's disposition, then re-judge at the new head under the assigned scope:

- **full** — the complete accumulated PR, not only the fix diff; the fix may have broken
  something the fix diff does not touch.
- **delta** — a deep pass only on the earlier findings, the diff from the previous round
  comment's `Head:` SHA to the current head — never "the last commit" — and that diff's blast
  radius: the callers and tests of what it changed. Everything else gets confirmation-level
  tracing — enough to see the fix did not reach it. Whatever step 4's verification flags
  re-enters the deep pass wherever it lives.

A delta scope narrows reading, never reporting: `finding-rules`' round rules still bind, and a
finding you do reach is reported whether or not it sits inside the scope.

Findings carry IDs `R<round>-F<N>`.

**Done when** the PR is judged at the head under the assigned scope and your role's re-review
condition holds for every earlier finding.

### 6. Deliver

Post one comment on the PR, tied to the reviewed head SHA, filled from
`${CLAUDE_SKILL_DIR}/templates/round-comment.md`; use an inline comment only where a code
location is itself the evidence. Then deliver the round assessment, the findings, and the Backlog
candidates as your final message — the implementation session is blocked on the first two, and the
human's Accept gate sits behind them. Open it with the line
`Report for the human — relay it in full, never summarized.`; the human sees only what the
dispatching session relays.

**No bundle:** nothing ever sweeps this PR's backlog candidates back. Say so plainly in the final
message, so whoever invoked this round routes the candidates through the `backlog` skill directly
instead of leaving them stranded in the comment.

**Done when** the comment is on the PR and the final message carries the assessment and, where the
route is No bundle, the sweep warning.
