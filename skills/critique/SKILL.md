---
name: critique
description: Attack a shaped spec in a fresh, isolated context before the human sees it. Invoke from the shape workflow's critique step, or when the user asks to critique, red-team, or attack a shaped bundle — only once spec.md and its full ticket set (or the single work file) are complete, never on a partial draft.
argument-hint: "[bundle id]"
context: fork
agent: critic
background: false
---

# Critique

Resolve the bundle with the Glob tool — `work/*/$ARGUMENTS*` and `work/*/$ARGUMENTS*/**` (Glob, not `ls`: this agent has no Bash). A single `.md` hit is the whole bundle, spec and ticket merged. Hits under a directory are the bundle's files: read `spec.md`, `brief.md` if present, and every ticket under `tickets/`. No match, or matches in two bundles — report that back as the result and stop; you have no user to ask.

Attack this bundle. Deliver your findings as your final message — the shaping session is blocked on them.
