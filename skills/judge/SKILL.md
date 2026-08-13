---
name: judge
description: "Get an independent recommendation on an architecture or design question — options with pros/cons, a pick, and a report of where that pick collides with existing conventions. Use when the user asks \"what would you choose\", \"what's the best way to do X\", \"give me your honest/independent take\", wants a second opinion on a settled convention, or a discussion keeps circling between approaches without a pick — even when they don't say \"independent\". The fork gets no conversation history: pass a self-contained question including the real constraints (scale, stack facts, team realities). Prefix the arguments with the word `pure` to get first-principles reasoning only, with no repo reconciliation."
argument-hint: "[pure] [the question, with its real constraints]"
context: fork
agent: arbiter
background: false
---

# Judge

**Determine the mode first.** If `$ARGUMENTS` begins with the word `pure`, strip it and run the clean-room pass only — the report omits its divergence sections. Otherwise run both passes.

**Check the question is decidable.** You receive no conversation history and have no user to ask. What remains of `$ARGUMENTS` must state a question one could rule on: what is being decided, and the hard constraints that bound it. If it doesn't, report exactly what's missing as your final message and stop.

Judge the question. Deliver the report as your final message — the session is blocked on it.
