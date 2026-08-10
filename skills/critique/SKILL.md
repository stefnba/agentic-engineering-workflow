---
name: critique
description: Attack a shaped spec in a fresh, isolated context before the human sees it. Invoke after spec.md and its first tickets are drafted — never on an unfinished draft, and never for anything short of a real attempt to break it.
argument-hint: "[candidate id]"
context: fork
agent: critic
background: false
---

# Critique

Resolve the bundle with the Glob tool — `work/*/$ARGUMENTS-*` (Glob, not `ls`: this agent has no Bash). Read `spec.md`, `brief.md` if present, and every ticket under `tickets/` — or the single work file, for a bundle under the file-scale threshold.

Attack the spec per your standing instructions. Report back to the calling session — it's shaping, and it's waiting on you (`background: false`): the point of forking is a fresh context, not a slow one.

Don't propose the fix. Naming the hole is the job; deciding how to close it belongs to the author, with the human at the Plan gate.
