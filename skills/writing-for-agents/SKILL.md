---
name: writing-for-agents
description: Use when writing, reviewing, or improving any document an agent will consume or follow — skills, CLAUDE.md / AGENTS.md files, runbooks, prompt files, workflow docs — including when the user says things like "write a CLAUDE.md", "document this so Claude can follow it", "make a skill for X", or "turn these steps into instructions", without mentioning the word "agent". Also use when the user reports an agent misbehaving around a document — "Claude keeps ignoring my CLAUDE.md", "my skill never triggers", "the agent skips steps in the runbook" — since the fix is usually in the document's wording.
---

# Writing for Agents

Reference for any document whose reader is an agent. The packaging differs — skill, instructions file, runbook — but the writing does not: the same levers make each one predictable. The goal is that the agent takes the same _process_ every run, not that it produces identical output.

## The procedure

Writing a new document and improving an existing one follow the same loop:

1. **Decide the packaging.** Skill, instructions file, runbook. For a skill, read `${CLAUDE_SKILL_DIR}/references/skill-mechanics.md` before drafting; if a dedicated skill-scaffolding skill is installed, it owns scaffolding and evals — this document owns the writing.
2. **Baseline.** For a new document or section, give the task to an agent _without_ it and record what actually goes wrong — `${CLAUDE_SKILL_DIR}/references/testing.md` has the mechanics. For a change to an existing line, rerun the prompts that motivated that line instead of a full baseline.
3. **Draft short.** Write the shortest sentence that resolves the observed failure, using the
   sections below. Add words only when the baseline shows the terse version still fails — not by
   default, and not to explain the why unless a reader without it acted wrong.
4. **Prune** sentence by sentence (see Pruning) — a pass for what step 3 still let through, not
   the primary mechanism.
5. **Verify.** Rerun the same prompts with the document in place; the observed failures should disappear.

## The two budgets

Every document and every reference to it spends one of two budgets:

- **Context load** — always-loaded material (a CLAUDE.md line, a skill description) costs tokens and attention on every turn, whether or not it fires. Prune it hardest.
- **Cognitive load** — the human's burden of remembering what documents exist and when to invoke them. Not a cost to zero out — it's the price of human control — but spend it deliberately.

Material behind a pointer escapes context load at the price of the pointer's own line. Material with no pointer at all rides entirely on the human remembering it.

## Pointers decide reachability

A pointer is any in-context line that names out-of-context material and the condition for reading it: a skill description, a CLAUDE.md line naming a doc, a "read X before doing Y" sentence. The pointer's _wording_ — not its target's quality — decides whether the agent ever gets there. Essential material behind a vague pointer is a reliability bug: sharpen the wording first; inline the material only if sharpening fails.

Writing pointers:

- State what the material is and the distinct cases that should trigger reading it. Collapse synonyms — two phrasings of the same case are one trigger written twice.
- Describe triggering _conditions_, not the target's workflow. A pointer that summarizes the process invites the agent to follow the summary and skip the document.
- Front-load the words the agent will actually have in context when the condition arises: error messages, task phrasings, file types.

```markdown
# Vague — "relevant" is not a condition the agent can test; never fires

See docs/db.md for relevant database information.

# Sharp — names the material and the observable cases that trigger reading it

Read docs/db.md before writing a migration or adding an index — it covers
the naming scheme and which tables must not be locked.
```

## The information hierarchy

Documents mix two content types: **steps** (ordered actions) and **reference** (rules, facts, definitions consulted on demand). Place each piece on a ladder ranked by how immediately the agent needs it:

1. **In-file steps** — the primary tier: what to do, in order.
2. **In-file reference** — consulted on demand; a flat set of rules on one rung is fine.
3. **Disclosed reference** — a separate file behind a pointer, loaded only when needed.

Progressive disclosure is the move down this ladder. It's not mainly token savings — it protects the top of the document. Reference that buries the steps turns following them into a coin flip. The cleanest test is branching: inline what every path needs; disclose what only some paths reach. Give disclosed files over ~300 lines a table of contents.

**Co-locate** within a file: keep a concept's definition, rules, and caveats under one heading so reading one part brings its neighbors. Scattering fragments one meaning across the document; the agent gets half of it.

## Writing steps

End every step on a **completion criterion** — the observable condition that says the step is done. Two properties matter:

- **Clarity**: the agent can tell done from not-done. "Understanding reached" invites quitting early; "all tests in `tests/` pass" does not.
- **Demand**: how much the criterion requires. "Every modified file accounted for in the changelog" forces thoroughness where "produce a changelog" does not.

State commands with their expected output and what to do when reality differs. Put failure handling next to the step where the failure occurs, not in an appendix.

Refer to other steps by name — "the tag-and-push step", not "step 7". Numbered cross-references break silently when a step is inserted, and doubly so when the reference lives in another file.

**Source fidelity.** A document distilled from notes, a thread, or a conversation may state only the facts its sources contain plus what the environment confirms. Where the source is silent — a timeout, a default, a policy — write the assumption _as_ an assumption ("confirm: poll interval assumed 2 min"), because a fabricated parameter reads exactly as authoritative as a real one, and the agent following the document can't tell them apart.

## Phrasing that changes behavior

- **Imperative voice**, and give the reason when it changes behavior: "Don't edit `dist/` — it's regenerated on every build" generalizes to cases you didn't list; a bare NEVER covers only the listed ones.
- **One instruction per paragraph, bold imperative lead-in.** An instruction buried mid-paragraph competes with everything around it; the bold opening is the handle the agent acts from. Split any paragraph carrying two instructions.
- **Prompt the positive.** Prohibition drags the forbidden behavior into context and makes it more available ("don't think of an elephant"). State the target behavior instead: "write one-line comments" beats "don't write long comments". Reserve prohibitions for hard guardrails you can't phrase positively, and even then pair them with the positive target.
- **Match the form to the failure** you're fixing:

| Observed failure                              | Right form                                                        |
| --------------------------------------------- | ----------------------------------------------------------------- |
| Agent knows the rule, skips it under pressure | Explicit prohibition + counters for its specific rationalizations |
| Output has the wrong shape                    | Positive recipe: state what the output _is_ — its parts, in order |
| Agent omits a required element                | A required slot in the template it fills, not a prose reminder    |
| Behavior depends on a condition               | A conditional keyed to an observable predicate                    |

- **No nuance clauses.** "Don't X unless it matters" reopens the negotiation. Express a real exception as its own conditional on an observable predicate.

## Templates and examples

Show output formats as literal skeletons, and give one excellent example rather than several mediocre ones — complete, in the most natural language for the domain, commented for _why_. Keep it representative: agents overfit to exotic examples and treat them as the only supported case.

```markdown
## Commit message format

Skeleton: type(scope): summary in imperative, ≤72 chars

Example — change adding JWT-based user authentication:
feat(auth): implement JWT-based authentication
```

**Put slot guidance in comments inside the template.** Annotate each slot with its fill rules and a compact example in comment syntax the output format ignores (`<!-- -->` in markdown), and open the template with the instruction to delete comments while filling — in the surrounding prose when the skeleton is fenced inside an instructional file, as the first comment when the template file stands alone. A surviving comment then flags an unfilled slot. Everything outside comment syntax lands verbatim in the deliverable, so headings and other structure are placeholders, never instructions.

```markdown
<!-- Fill every section; delete these comments as you fill. -->

# <Incident title>

## Impact

<!-- Who or what was affected, for how long, in numbers. Example:
Checkout unavailable 14:02–14:19 UTC; ~3,100 sessions dropped. -->
```

Deterministic, repetitive procedures belong in executable scripts the agent runs, not prose it re-derives each run.

## Pruning

- **Single source of truth**: one meaning, one place. Duplicates drift and hand the agent contradictions. If two documents need a rule, one states it, the other points.
- **The environment is a source of truth too**: `package.json` scripts, `--help` output, the directory layout. A document restating them is a cache that goes stale, and annotating the copy doesn't rescue it — "the list adds purpose info" is the standard rationalization for keeping a restated command table. Write down only what the agent _cannot_ discover by looking — the unwritten convention, the reason behind a choice, the gotcha no config confesses.
- **Hunt no-ops** sentence by sentence: an instruction the agent already follows by default pays load to say nothing. The test — does this line change behavior versus no line? — is settled by running the document, not by debate. When a sentence fails, delete it whole.
- **Relevance decays.** Behavior and world change; lines go stale and settle into sediment because adding feels safe and removing feels risky. Shorter documents are easier to keep true.
