---
name: interview
description: Grill user intent into a settled shared understanding. Use when the user brings a feature or problem to discuss from scratch, or wants to pick up a vague backlog line.
argument-hint: "[what you want to build or fix]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob
---

# Interview

The pick-side half of Discover (see `docs/agentic-workflow.md` § Discover) — used when intent needs grilling before it's ready for `shape`: the user brings it directly, or an existing backlog line is too vague to shape as-is. This skill writes nothing — no brief, no file. Its only output is a settled understanding sitting in the conversation, which the human then carries straight into `shape`, invoked with no argument in this same session. `Read`/`Grep`/`Glob` are the only tools granted; there is no `Write`, `Edit`, or `Bash` to remove by convention — this skill is read-only by tool grant.

## Grill, don't transcribe

Your job is to reach a shared understanding the human would actually recognize as settled, not to write down whatever they say first. Map the ask as a **design tree** with three branches — **Problem**, **Constraints**, **Motivation** — and grill each until nothing is left assumed:

- **Problem**: if the ask is a solution ("add a Redis cache"), ask what breaks without it. The problem behind a proposed solution is usually more general than the solution itself.
- **Constraints**: surface what's implied but unstated ("it needs to work with the mobile app") and confirm it explicitly — never infer silently.
- **Motivation**: ask why this matters now. It's what lets a later reader judge whether a trade-off made during shaping still serves the original intent.

Work in **rounds**. The **frontier** is every question whose prerequisites are already settled — the ones you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round, numbered, each with your recommended answer, then wait:

```
❓ **Q1** — **<question title>**: <question body>

➡️ <your recommended answer>
```

Each round's answers reshape the tree: settled branches push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another still-open question belongs to a _later_ round, not this one.

Stay inside Problem/Constraints/Motivation. Implementation decisions, architecture, and acceptance criteria are `shape`'s job — a grilling round that starts solutioning stopped being an interview.

## Facts are yours to find, never the human's

When a frontier question needs a fact the repo can answer — an existing convention, a colocated README, whether a module already does X — resolve it yourself with `Read`/`Grep`/`Glob` before asking, or inline within the round if it's quick. Don't ask the human something the repo already answers, and don't block the rest of the frontier on a lookup that only one question in the round needs — ask the others now, fold the answer in once you have it.

## When this isn't worth grilling

Running the interview is itself a judgment: it claims the item needs more than a line. If the conversation converges on something that fits one line, it wasn't worth interviewing — say so and use the `backlog` skill instead. A vague idea that resists a one-line summary after a round of grilling is the signal that shaping, not a backlog line, is warranted.

## Check for an existing bundle, once

Before wrapping up, `Glob` `work/shaped/*` and `work/active/*` for a bundle whose slug plausibly overlaps this topic. If one exists, ask the human directly, in one question: continue that bundle, or start a fresh one? Don't infer this from how the conversation feels — it's a one-line question, not a judgment call to reason your way into. If nothing overlaps, skip this and say nothing about it.

## Done

The session is done when the frontier is empty — every branch visited, nothing silently assumed — and the human confirms you've reached a shared understanding. Do not act on it until they do.

Report back in one line: the problem, in the user's framing, is settled. Say the next step is `shape`, invoked right here with no argument — it reads this conversation directly and either creates a fresh bundle or resumes the existing one you already confirmed above. Don't invoke it yourself; the human's decision to carry this conversation into `shape` is the Pick gate (`docs/agentic-workflow.md` § Where the human sits), and that's a call they make, not you.
