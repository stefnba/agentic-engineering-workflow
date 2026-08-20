---
name: review
description: Judge one implementation PR at an exact head SHA, in a fresh read-only context with no authorship of the diff. Dispatched by the implement skill once per review round; also usable when the user asks to review, re-review, or judge a ticket's PR. Invoke with the PR number, its head SHA, and the round number.
argument-hint: "[PR number] [head SHA] [round number]"
context: fork
agent: reviewer
background: false
---

# Review

`$ARGUMENTS` carries the PR number, the exact head SHA to judge, and the round number, in that
order.

Resolve the PR with `gh pr view <pr>`. A number that doesn't resolve, a missing SHA, or a missing
round number is your result: report that and stop. You have no user to ask — and a round with no
number cannot give its findings IDs that survive to the next one.

**The SHA you were handed is the one you judge.** Confirming it is still the PR head, and that the
tree you are in sits there unmodified, is your own step 2 — a disagreement stops the round rather
than becoming a review of whatever you found.

Nothing reached you but those three values. Read the bundle, the ticket, and the diff yourself;
anything the author reported is a claim, and re-deriving it is the whole reason this round runs in
its own context.

Deliver the round assessment and your findings as your final message — the implementation session is
blocked on them, and the human's Accept gate sits behind them.
