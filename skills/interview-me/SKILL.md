---
name: interview-me
description: Grill user intent into a settled shared understanding. Use when the user brings a feature or problem to discuss from scratch, or wants to pick up a vague backlog line.
argument-hint: "[what you want to build or fix]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob
---

Start from `$ARGUMENTS` if given, otherwise the ask already in this conversation — or ask what to discuss if neither exists.

Map it as a **design tree** with three branches — **Problem** (what breaks without this; the problem behind a proposed solution is usually more general than the solution), **Constraints** (what's implied but unstated — confirm it, never infer silently), **Motivation** (why now — lets a later reader judge whether a trade-off still serves the original intent). Grill each branch until nothing is left assumed. Stay inside these three: implementation, architecture, and acceptance criteria are `shape`'s job, not this skill's.

Work in **rounds**. The **frontier** is every question whose prerequisites are already settled. Ask the whole frontier in one round, numbered, each with your recommended answer, then wait:

```
❓ **Q1** — **<question title>**: <question body>

➡️ <your recommended answer>
```

Answers reshape the tree — settled branches unblock questions that depended on them. Recompute the frontier each round. A question that depends on another still-open one belongs to a later round.

**Facts:** the repo can answer — a convention, a colocated README, whether something already exists — are yours to find with `Read`/`Grep`/`Glob`, never the human's to be asked. Don't block the rest of the frontier on one lookup; ask the rest now, fold the answer in once you have it.

**Language matters as much as logic.** A term that conflicts with `GLOSSARY.md` gets called out with both readings, never silently picked; fuzzy or overloaded language gets a proposed canonical term. When a term resolves, offer `glossary` to capture it.

**Too small to interview:** if the conversation converges on something that fits one line, it wasn't worth interviewing — say so and use `backlog` instead.

**Done** when the frontier is empty and the human confirms the shared understanding — don't act on it before then. Report back in one line that the problem, in the user's framing, is settled, and that the next step is `shape`, invoked here with no argument. Don't invoke it yourself — that's the human's call.
