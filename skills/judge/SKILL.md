---
name: judge
description: "Get an independent recommendation on an architecture or design question — options with pros/cons, a pick, and where it collides with repo conventions. Use when the user asks \"what would you choose\", wants a second opinion or an independent take, or a discussion keeps circling without a pick. The fork gets no conversation history: pass a self-contained question with its real constraints. Prefix with `pure` for first-principles only, no repo reconciliation."
argument-hint: "[pure] [the question, with its real constraints]"
context: fork
agent: arbiter
background: false
---

# Judge

**Determine the mode first.** If `$ARGUMENTS` begins with the word `pure`, strip it and run the clean-room pass only — the report omits its divergence sections. Otherwise run both passes.

**Check the question is decidable.** You receive no conversation history and have no user to ask. What remains of `$ARGUMENTS` must state a question one could rule on: what is being decided, and the hard constraints that bound it. If it doesn't, report exactly what's missing as your final message and stop.

Judge the question. Deliver the report as your final message — the session is blocked on it. Open
it with the line `Report for the human — relay it in full, never summarized.`; the human sees only
what the dispatching session relays.
