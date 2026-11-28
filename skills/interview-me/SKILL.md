---
name: interview-me
description: Use when the user wants a plan, design, idea or project questioned until nothing in it is left assumed, says "interview me", "grill me", "question me on this" or "stress-test this", or when another skill needs the user's decisions before it writes anything. Also use when a plan rests on answers nobody has given yet, even if the user did not ask to be interviewed.
---

# Interview the user

The user and you share one understanding of the topic, and every point in it is marked decided, assumed or open.

## Guardrails

**Ask the user for decisions and look up facts yourself.** A fact sits in the repository, its history or a tool's output; a decision is a choice between options. Asking the user for a fact you could read wastes their attention.

**Name the source of every fact you state**, such as `docs/PROJECT.md`, Users, or say you could not verify it. A decision that rests on an unverified fact stays open.

**Record a point only as the user settled it.** When the user says "you choose" or "not sure", record it as assumed, with what you chose and what changing it later would cost, or as open. A question the user did not answer stays open. Never turn either into decided.

**Take each answer for the question number it names.** A reply that names no number, such as a bare "yes" to a round, accepts nothing; ask which questions it answers.

**Put every call you make yourself into the round as assumed**, so the user can reject it. A default the user never heard is one they could not reject.

**Include the smaller option in every choice**: leave it out, or keep it as it is. Recommend it when nothing you found argues for more.

**Hold a recommendation when the user challenges it.** Say whether their point changes it and why, and change it only for a reason you can name.

**Write no file and change nothing while interviewing.** The interview ends in a summary. The caller, or the user, decides what gets written.

## Process

### 1. Read the project docs

**Read `docs/PROJECT.md`, `docs/GLOSSARY.md`, `docs/ARCHITECTURE.md` and `docs/decisions/` when they exist.** Use the glossary's terms in your questions. When the user uses a term in a different sense than the glossary, ask about it as a decision.

Done when you have read each of these that exists, or found that none does.

### 2. Map the decisions

**List the decisions the topic needs, each with the decisions it depends on.** When the caller gave topics, start from those. When the repository has no docs and no code, start from these: the problem, who it is for, the core use cases, the constraints, what done means and what is out of scope.

**Leave out a decision the repository or the conversation already settles, and one whose answer would not change the outcome.** Settle such a minor point yourself and mark it assumed.

**Note each idea outside the topic as out of scope**, instead of mapping it.

Done when every decision on the list either has its prerequisites named or has none.

### 3. Ask in rounds

**Ask three to five decisions whose prerequisites are settled, in one message, then wait for the answers.** Ask fewer only when fewer are askable. A decision that depends on one still open belongs in a later round.

**Put a contradiction first**, quoting both sides, when an answer conflicts with the repository or an earlier answer. Then pick the decisions whose answers unblock the most others.

**Before sending a round, look up the facts its questions need**, in a fresh context window when one is available and directly otherwise. Move a question whose fact is still missing to the next round.

**Number each question, say why its answer matters, and for a choice between options give your recommended answer, worded so "yes" accepts it.** End the round with how to reply:

```markdown
❓ **Q1. Does the first release support teams?**
Two kinds of user came up: the solo developer and a team of up to five (`docs/PROJECT.md`, Users). Team support adds roles to every setup question.

- A. Solo developer only, with nothing that blocks a team later
- B. Solo developer and team from the start

➡️ Recommended: A, because every user named so far works alone. Yes?

❓ **Q2. …**

Reply by number, such as "Q1 yes, Q2 B, Q3 not sure".
```

**When neither the repository nor the conversation points to an answer, ask an open question with no recommendation**, such as "What problem does this solve, and for whom?" A recommendation there is a guess the user will wave through.

**After each round, mark every answer decided, assumed or open, and recompute which decisions are now askable.** An answer can add decisions to the map or remove some. When an answer changes an earlier one or brings new facts, mark again every decision that depended on it.

**Ask an unanswered question again in the next round, under its number.**

**Mark a decision open, naming its blocker, when it depends on a decision the user left open.** It cannot be asked in this interview.

**When the user says "stop", "done" or "enough", mark every decision not yet asked open**, with "not asked" as its blocker, and go to the summary.

Done when no decision on the map is askable and every decision has a mark.

### 4. Hand back the summary

**Send the summary in this shape and ask the user to confirm it:**

```markdown
**Decided**

- Q1 Teams in the first release — solo developer only; nothing may block a team later

**Assumed**

- Q4 Tracker — GitHub issues; switching later means moving every open item

**Open**

- Q6 Where the roadmap lives — blocks the release plan
- Q7 Release cadence — blocked by Q6

**Out of scope**

- A plugin marketplace — came up in Q3
```

**When the user corrects the summary, change it and ask again.** When the correction brings new facts or changes the goal, go back to mapping the decisions.

Done when the user confirms the summary. Hand it to the caller, or, when the user started the interview, ask what to do with it.
