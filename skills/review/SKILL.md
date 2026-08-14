---
name: review
description: Review a ticket's PR in a fresh, forked context with no authorship of the diff — architecture, requirement fit, security, edge cases, and whether the reconcile half is honest. Invoke with the PR number once implement has opened the PR; findings return to the human for the Accept gate.
argument-hint: "[PR number]"
disable-model-invocation: true
context: fork
agent: reviewer
background: false
---

# Review

Resolve the PR with `gh pr view $ARGUMENTS` — its body carries the self-reported verify
results, what reconcile touched, and the permalink to the bundle. A number that doesn't
resolve, or no number at all — report that back as the result and stop; you have no user
to ask.

Review this PR. Deliver your findings as your final message — the human's Accept gate is
blocked on them.
