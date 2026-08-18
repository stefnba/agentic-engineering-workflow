---
name: interview-me
description: Grill user intent into a settled shared understanding, before anything is written down. Use when the user brings a feature, bug, or problem to discuss from scratch, or wants to pick up a vague backlog line.
argument-hint: "[what you want to build or fix]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob
---

# Interview me

Discover-stage narrowing. `${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md` owns what this step is for
and when it may be skipped.

Start from `$ARGUMENTS` if given, otherwise the ask already in this conversation — or ask what to
discuss if neither exists.

**This writes nothing.** No file, no backlog line, no bundle. You hold `Read`, `Grep`, and `Glob`
only, structurally. `/shape` is the first thing that produces a file.

## The design tree

Map the ask as three branches:

- **Problem** — what breaks without this. The problem behind a proposed solution is usually more
  general than the solution.
- **Constraints** — what's implied but unstated. Confirm it; never infer silently.
- **Motivation** — why now. This lets a later reader judge whether a trade-off still serves the
  original intent.

Grill each branch until nothing is left assumed. **Stay inside these three.** Implementation,
architecture, decomposition, and acceptance criteria belong to Shape, not here.

## Rounds

The **frontier** is every question whose prerequisites are already settled. Ask the whole frontier in
one round, numbered, each with your recommended answer, then wait:

```text
❓ **Q1** — **<question title>**: <question body>

➡️ <your recommended answer>
```

Answers reshape the tree — a settled branch unblocks questions that depended on it. Recompute the
frontier each round. A question that depends on another still-open one belongs to a later round.

**Facts the repo can answer are yours to find** — a convention, a colocated README, whether something
already exists — never the human's to be asked. Don't block the rest of the frontier on one lookup;
ask the rest now and fold the answer in when you have it.

**Language matters as much as logic.** A term that conflicts with `${CLAUDE_PROJECT_DIR}/GLOSSARY.md` gets called out with
both readings, never silently picked; fuzzy or overloaded language gets a proposed canonical term.
When a term resolves, offer the `glossary` skill to capture it.

## Where it can end

**Settled** — the frontier is empty and the human confirms the shared understanding. Report in one
line that the problem, in the human's framing, is settled, and that the next step is `/shape` in this
same session. Don't invoke it yourself; dispatching a stage is the human's call.

**Too small to interview** — the conversation converges on something that fits one line. Say so and
offer to append it to `${CLAUDE_PROJECT_DIR}/work/backlog.md` instead; the human writes it, since you hold no write tool.

**Feasibility or diagnosis is genuinely unknown** — don't force it into a shapeable outcome. Say that
the work looks like the investigation or spike route
(`${CLAUDE_PLUGIN_ROOT}/workflow/shaping-routes.md`), whose evidence becomes the next thing the human
picks. `/shape` still runs, but it shapes the investigation, not the implementation.
