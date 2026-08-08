---
name: interview
description: Turn user intent directly into a brief. Use when the user brings a feature or problem to discuss from scratch, not from an existing backlog line.
argument-hint: "[what you want to build or fix]"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(cat docs/work/next-id), Bash(mkdir -p docs/work/candidates/*), Bash(git add *), Bash(git commit *), Bash(git push), Bash(git pull *)
---

# Interview

The pick-side half of Discover that starts from the user instead of the backlog (see [docs/agentic-workflow.md § Discover](../../docs/agentic-workflow.md#discover)). Output is `candidates/<id>-<slug>/brief.md`: **the problem in the user's framing, not a solution.**

## Challenge, don't transcribe

Your job is to produce a brief the author can shape, not to write down whatever the user says first. Restating "I want X" as `## Problem: wants X` wastes the interview — a brief that just transcribes the opening message would have been a backlog line.

- If the ask is a solution ("add a Redis cache"), ask what breaks without it. The problem behind a proposed solution is usually more general than the solution itself, and a brief that captures the real problem lets shaping consider options the user's opening framing foreclosed.
- If a constraint is implied but unstated ("it needs to work with the mobile app"), surface it and confirm it explicitly rather than inferring silently — an unstated constraint discovered mid-shape is a wasted design.
- If the motivation is missing ("why does this matter now"), ask. Motivation is what lets a later reader judge whether a design trade-off still serves the original intent.
- Stop challenging once problem, constraints, and motivation are each concrete enough to write down. Don't interrogate past that point — a brief is a starting point for shaping, not an exhaustive spec.

## When this isn't a brief

Writing a brief is itself a judgment: it claims the item needs shaping. If the conversation converges on something that fits one line, it wasn't a brief — say so and use the `backlog` skill instead. A vague idea that resists a one-line summary after a round of challenge is the signal that shaping, not a backlog line, is warranted.

## Write the brief

```markdown
# <id> — <Title>

## Problem

## Constraints

## Motivation
```

Same three headings, every time — see [docs/docs-structure.md § brief.md](../../docs/docs-structure.md#briefmd) for why they're fixed. Title is a short noun phrase, not the problem statement restated.

## Allocate the ID

IDs are 4-digit, sequential, and allocated here — the bundle-creating skill, not a loose script (see the backlog's ID-allocation note). `docs/work/next-id` holds the next one to give out.

1. `cat docs/work/next-id` → `<id>`.
2. Slugify the title → `<slug>` (lowercase, hyphens).
3. `mkdir -p docs/work/candidates/<id>-<slug>` and write `brief.md` there.
4. Increment the counter: write `<id> + 1`, zero-padded to 4 digits, back to `docs/work/next-id`.
5. Commit the brief and the incremented counter **together, in one commit** — that's the atomic claim.
6. `git push`. If it's rejected, someone else claimed this ID first: `git pull`, re-read `docs/work/next-id`, and retry from step 2 with the new value. The push conflict is the lock; there is no other coordination mechanism.

Don't skip the push in a repo with a remote — an uncommitted or unpushed ID isn't actually claimed, and the next interview in this repo will read the same `next-id` value and collide.

## After writing

Report the ID and path (`0043 → docs/work/candidates/0043-usage-export/brief.md`) and the one-line problem statement. Don't summarize the whole brief back — the user just answered every question in it. Say the next step is shaping (`/shape 0043`), and don't invoke it yourself — Shape is a separate stage with its own fresh-context rule (see [docs/agentic-workflow.md § Rules that make the stages real](../../docs/agentic-workflow.md#rules-that-make-the-stages-real)).
