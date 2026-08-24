---
name: review-changes
description: Judge local git changes with the independent reviewer, without a PR. Use when the user asks to review the working tree, staged or uncommitted changes, the current diff, or a branch with no PR yet — "review my changes", "check this before I commit", "second opinion on this diff" — even when the changes span several conversations or the user authored them by hand. Invoke with an optional base ref (default is HEAD, judging the staged and uncommitted work like `git diff`; a base ref widens it to commits, branches, or remotes) and an optional one-line intent to judge against. Not for a ticket's PR, which review-pr judges.
argument-hint: "[base ref] [stated intent]"
context: fork
agent: reviewer
background: false
---

# Review changes

One independent review of local work no PR carries: judge the change set against its contract and
return the findings.

## Process

### 1. Resolve the assignment

`$ARGUMENTS` optionally carries a base ref, then a one-line stated intent. Treat the first token
as a base ref only when `git rev-parse --verify <token>^{commit}` resolves; everything else is
the stated intent.

The baseline is the commit the change set is diffed against:

- no base ref — including an empty `$ARGUMENTS` — the baseline is `HEAD`; the change set is the
  staged, unstaged, and untracked work, like `git diff`.
- a base ref — the baseline is `git merge-base <base> HEAD`; the change set is every commit since
  it, plus the uncommitted work on top.

When the change set is empty, stop and tell the human there is nothing to review against this
baseline — with no base ref that usually means the work was already committed, so name the fix:
rerun with a base ref, e.g. the integration target.

**Done when** the baseline commit resolves and the change set is non-empty, and you hold the
stated intent or know none was given.

### 2. Fingerprint the tree

There is no PR head to pin — a working tree can move mid-review. Make movement detectable
instead. Record:

- the baseline SHA and `git rev-parse HEAD`
- the fingerprint: `{ git diff <baseline>; git status --porcelain; } | shasum`

**Done when** both are recorded for the delivery step to re-check.

### 3. Read the contract

No ticket or PR defines this change set. Its contract is:

- the stated intent, when one was given
- repository conventions, the decision records the change touches, and the glossary

Read the complete change set; treat an untracked file as an addition — `git diff` does not show
it.

**Done when** the contract artifacts and every file in the change set have been read.

### 4. Verify

Run the repository's canonical checks against the tree as dispatched.

**Done when** your role's recorded-result condition holds for the tree.

### 5. Judge

Judge the change set under your role's contract. Findings carry IDs `F<N>`, scoped to this run —
no round follows, and a rerun issues fresh IDs. Admissible referents here: a decision record, a
repository convention or canonical check, the stated intent, or a concrete failure mechanism.

**Done when** the full change set is judged.

### 6. Deliver

Recompute the fingerprint. A changed fingerprint does not void the review — report it on the
report's baseline line, because findings may point at lines that have moved.

Fill `${CLAUDE_SKILL_DIR}/templates/report.md` and deliver it as your final message — the only
channel this review has; nothing is posted anywhere.

**Done when** the fingerprint has been re-checked and the final message carries the assessment
and every finding.
