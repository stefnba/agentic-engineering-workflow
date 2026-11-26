---
name: interview-user
description: Use when the user wants a plan, design, idea or project questioned until nothing in it is left assumed, says "interview me", "grill me", "question me on this" or "stress-test this", or when another skill needs the user's decisions before it writes anything. Also use when a plan rests on answers nobody has given yet, even if the user did not ask to be interviewed.
---

# Interview the user

The user and you share one understanding of the topic, and every point in it is marked decided, assumed or open.

## Guardrails

**Ask the user for decisions and look up facts yourself.** A fact sits in the repository, its history or a tool's output; a decision is a choice between options. Asking the user for a fact you could read wastes their attention.

**Record a point only as the user settled it.** When the user says "you choose" or "not sure", record it as assumed, with what you chose and what changing it later would cost, or as open. Never turn it into decided.

**Write no file and change nothing while interviewing.** The interview ends in a summary. The caller, or the user, decides what gets written.

## Process

### 1. Map the decisions

**List the decisions the topic needs, each with the decisions it depends on.** When the caller gave topics, start from those. Read what the repository and the conversation already settle, and leave those points out of the questions.

Done when every decision on the list either has its prerequisites named or has none.

### 2. Ask in rounds

**Ask up to seven decisions whose prerequisites are settled, in one message, then wait for the answers.** Pick the ones whose answers unblock the most other decisions. A decision that depends on one still open belongs in a later round.

**Before sending a round, look up the facts its questions need**, in a fresh context window when one is available and directly otherwise. Move a question whose fact is still missing to the next round.

**Number each question. For a choice between options, give your recommended answer and word the question so "yes" accepts it:**

```markdown
**Q1. Who uses this first?** Two kinds of user came up: the solo developer and a team of up to five. Building for both from the start doubles the setup questions.

Recommended: the solo developer first, with nothing that blocks a team later. Yes?

**Q2. …**
```

**When neither the repository nor the conversation points to an answer, ask an open question with no recommendation**, such as "What problem does this solve, and for whom?" A recommendation there is a guess the user will wave through.

**After each round, mark every answer decided, assumed or open, and recompute which decisions are now askable.** An answer can add decisions to the map or remove some.

**Mark a decision open, naming its blocker, when it depends on a decision the user left open.** It cannot be asked in this interview.

Done when no decision on the map is askable and every decision has a mark.

### 3. Hand back the summary

**Send the summary in this shape and ask the user to confirm it:**

```markdown
**Decided**

- Q1 Who uses this first — the solo developer; a team of up to five must not need a redesign

**Assumed**

- Q4 Tracker — GitHub issues; switching later means moving every open item

**Open**

- Q6 Where the roadmap lives — blocks the release plan
- Q7 Release cadence — blocked by Q6
```

**When the user corrects the summary, change it and ask again.**

Done when the user confirms the summary. Hand it to the caller, or, when the user started the interview, ask what to do with it.
