---
name: critique
description: Attack a draft bundle in a fresh, read-only context before the human Plan gate. Dispatched by the shape skill once the draft is complete; also usable when the user asks to critique, red-team, or attack a bundle. Never run it on a partial draft.
argument-hint: "[bundle id]"
context: fork
agent: critic
background: false
---

# Critique

Resolve the bundle: `${CLAUDE_PROJECT_DIR}/work/bundles/$ARGUMENTS/`. A bundle is always a directory — read every file in
it. No match, or more than one match, is your result: report that and stop. You have no user to ask.

Attack this bundle. Deliver your findings as your final message — the shaping session is blocked on
them, and the human has not seen the bundle yet.
