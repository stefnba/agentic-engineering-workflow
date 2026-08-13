---
name: review
description: Review a ticket's PR in a fresh, forked context with no authorship of the diff — architecture, requirement fit, security, edge cases, and whether the reconcile half is honest. Resolves its own target with no arguments (current branch, else the sole in-progress bundle's open PR); an explicit PR number overrides. Findings post to the PR; the human's Accept gate reads them there.
argument-hint: "[PR number]"
disable-model-invocation: true
context: fork
agent: reviewer
background: false
---

# Review

Every definition below — the verdict and fix-round contracts, marker literals, the state
table, tiers, classes, budgets, the round cap, account rules — lives in
`skills/review/references/protocol.md`. Read it before acting; this file states only the
steps.

## 1. Resolve the target

An explicit PR number in `$ARGUMENTS` always overrides inference — resolve that PR and skip
to step 2.

No arguments: resolve branch-first. If the current branch matches
`<bundle-id>/NN-<slug>` (single-file bundle: `<bundle-id>`), that names the bundle and
ticket, and the branch's open PR is the PR. On the default branch: resolve the bundle
first — exactly one bundle under `work/active/`, else exactly one under `work/shaped/`,
else report that neither resolves and stop; you have no user to ask. Then the PR: exactly
one open PR on the bundle's branches drives mode inference; several open PRs → report each
with its state and stop; none → report that there's nothing to review and stop.

## 2. Determine mode

Read the PR's latest verdict — the marker-bearing review with the highest `round` — and
compute the loop state from protocol.md's table (verdict `sha` vs. the PR's head SHA,
`blockers` count). A marker present whose block doesn't parse or is missing a required
field fails loud: report what didn't parse and stop, taking no further action. No marker at
all is `needs-review`, not an error.

State → mode:

| State              | Mode              |
| ------------------ | ----------------- |
| `needs-review`     | Full review       |
| `needs-re-review`  | Scoped re-review  |
| `fixes-pending`    | No-op             |
| `awaiting-accept`  | No-op             |

Echo the inferred mode (or "explicit PR #N" when an argument was given) before acting.

## 3. Act

**No-op** (`fixes-pending` or `awaiting-accept`): take no action — no re-run of
verification, no post. Report the state and the next command per step 4, and stop.

**Full review** (`needs-review`): read the PR body for the bundle permalink, then follow
the reviewer agent's ground-yourself, judging, and reporting steps in full against the
PR's current head.

**Scoped re-review** (`needs-re-review`): gather the latest verdict, the fix-round report
answering it, and the commits added since the verdict's `sha` (`gh pr diff` scoped to that
range, or `git log <verdict-sha>..HEAD` on the PR branch). Follow the reviewer agent's
scoped re-review step: verify claimed fixes, review only the delta, restate open findings
under their original IDs, raise new findings only from the delta under fresh IDs (the
late-blocker exception aside).

Either review path ends by posting one verdict per protocol.md's contract — this is the
only side effect a review round makes.

## 4. Close out

Compute `<command>` for the reviewer's one-line chat return (format in `agents/reviewer.md`'s
Report step):

- `blockers` above zero — the verdict just posted, or the latest existing one for a
  no-op — → `/implement fix <PR>`.
- Zero blockers → no skill command; the PR is ready for the human's Accept (merge).
