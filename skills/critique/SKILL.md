---
name: critique
description: Attack a shaped design in a fresh, isolated context before the human sees it. Invoke after design.md and its first tickets are drafted — never on an unfinished draft, and never for anything short of a real attempt to break it.
argument-hint: "[candidate id]"
context: fork
agent: critic
background: false
---

# Critique

Resolve the bundle with the Glob tool — `docs/work/*/$ARGUMENTS-*` (Glob, not `ls`: this agent has no Bash). Read `design.md`, `brief.md` if present, and every ticket under `tickets/` — or the single work file, for a bundle under the file-scale threshold.

Attack the design per your standing instructions. Report back to the calling session — it's shaping, and it's waiting on you (`background: false`): the point of forking is a fresh context, not a slow one.

Don't propose the fix. Naming the hole is the job; deciding how to close it belongs to the author, with the human at the Plan gate.
