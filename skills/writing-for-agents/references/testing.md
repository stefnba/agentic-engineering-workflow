# Testing agent documents

Writing for agents is test-driven development applied to process documentation. If you never watched an agent fail _without_ the document, you don't know whether the document teaches the right thing — you only know it sounds right to you.

## The loop

1. **Baseline (red).** Give 2–3 realistic task prompts to an agent without the document. Record what actually goes wrong — the choices it makes, and for discipline rules, its rationalizations verbatim. If nothing goes wrong, stop: there's nothing to fix, and guidance that fixes nothing is a no-op paying rent in context.
2. **Write minimally (green).** Address the observed failures, not hypothetical ones. Rerun the same prompts with the document; the failures should disappear.
3. **Close loopholes (refactor).** New failure or new rationalization? Add its specific counter and rerun. Repeat until stable.

## Running a baseline in practice

Spawn a fresh agent per prompt — no conversation history, no sight of the document (don't paste it, and if it's an installed skill, forbid skill invocation in the prompt). Give it a realistic fixture seeded with the facts the document is meant to protect — a small synthetic repo, a messy input file — and a concrete deliverable path. Then judge the artifacts, not the agent's self-report: agents routinely describe their output as following rules it visibly breaks.

Keep the baseline prompts, and the failure each one exposed, in a file next to the document. A later edit to any line needs them: the regression check is rerunning the prompts that motivated that line, and unrecorded prompts can't be rerun.

## Matching tests to document type

- **Discipline rules** (e.g. "tests before code"): test under pressure — time pressure, sunk cost, authority ("the user insists") — since that's when agents rationalize. Collect the excuses and counter them explicitly in the document.
- **Techniques and workflows**: test application on a fresh scenario and a variation. Gaps show up as improvisation.
- **Reference documents**: test retrieval — can the agent find and correctly apply the right entry for a task?

## Cheap iteration: micro-tests

Full scenario runs are the final gate but slow per iteration. To compare wordings, run single-shot samples: realistic surrounding context, a task that tempts the failure, 5+ repetitions per variant, always including a no-guidance control. Read every flagged output yourself — automated counts mistake quoted counter-examples for violations. Convergence is the signal: if five runs produce five interpretations, the wording isn't binding yet.

## What "done" looks like

The document fixes the failures you observed at baseline, survives the pressure or variation scenarios for its type, and contains no line that a no-guidance control already gets right.
