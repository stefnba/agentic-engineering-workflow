---
name: review-pr
description: Judge one implementation PR at its exact head SHA. Dispatched by the implement-ticket skill once per review round; also use when the user asks to review, re-review, or judge a ticket's PR. Invoke with the PR number, its head SHA, and the round number.
argument-hint: "[PR number] [head SHA] [round number]"
context: fork
agent: reviewer
background: false
---

# Review PR

One review round: judge the PR at the assigned head SHA and return the round's findings.

## Process

### 1. Resolve the assignment

`$ARGUMENTS` carries the PR number, the exact head SHA to judge, and the round number, in that
order. Resolve the PR with `gh pr view <pr>`. A number that doesn't resolve, a missing SHA, or a
missing round number is your result: report it and stop — a round with no number cannot give its
findings IDs that survive to the next one.

**Done when** you hold all three values and the PR resolves.

### 2. Confirm the tree

**The SHA you were handed is the one you judge.** Confirm:

- the assigned SHA is the PR's actual head — `gh pr view <pr> --json headRefOid`
- the tree you are in sits at that SHA — `git rev-parse HEAD`
- no tracked file is modified — `git status --porcelain --untracked-files=no`

Untracked build output from an earlier round is expected. Any other disagreement stops the round —
report it instead of reviewing, because a review dispatched from the author's own worktree is
otherwise indistinguishable from reviewing unpushed work.

**Done when** all three checks agree, or the round has stopped with the disagreement reported.

### 3. Read the contract

Nothing reached you but the three values. Read for yourself:

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
against the author's disposition, then re-judge the complete accumulated PR at the new head, not
only the fix diff — the fix may have broken something the fix diff does not touch.

Findings carry IDs `R<round>-F<N>`.

**Done when** the full PR is judged at the head and your role's re-review condition holds for
every earlier finding.

### 6. Deliver

Post one comment on the PR, tied to the reviewed head SHA, filled from
`${CLAUDE_SKILL_DIR}/templates/round-comment.md`; use an inline comment only where a code
location is itself the evidence. Then deliver the round assessment and the findings as your final
message — the implementation session is blocked on them, and the human's Accept gate sits behind
them.

**Done when** the comment is on the PR and the final message carries the assessment.
