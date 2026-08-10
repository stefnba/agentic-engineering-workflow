# 0001 — Workflow skills v1: interview, shape, critique

Instructions for the implementing agent. Read this file fully, then the authorities below, before writing anything.

## Target state

Three workflow skills exist under `skills/` — `interview`, `shape`, `critique` — plus their two dependencies: the `critic` subagent definition under `agents/` and the `docs-rules` reference skill. Together they cover the pipeline from user intent to approved plan. The mechanism decisions tabled in `skills/README.md` and `agents/README.md` are implemented exactly: invocation, inline vs. fork, blocking behavior, and settings.

## What each one is about

The tables in `skills/README.md` are the spec — this list adds nothing to them, and this file deliberately does not prescribe skill content:

- `interview` — the pick-side dialogue that turns user intent into a brief inside a new candidate bundle
- `shape` — the author role: brief in, spec and first tickets out, human plan-approval at the end
- `critique` — the critic role: a fresh, isolated context that attacks the spec before the human sees it
- `critic` (agent) — the read-only context `critique` forks into
- `docs-rules` (reference skill) — the procedural distillate of docs-structure that skills and agents load instead of restating it

## Authorities, in precedence order

1. `docs/agentic-workflow.md` — the process: stages, gates, roles, session rules
2. `docs/docs-structure.md` — the artifacts: what each document is, its headings, its lifecycle
3. `skills/README.md` and `agents/README.md` — the mechanism spec for exactly these skills
4. The existing skills (`skills/backlog`, `skills/decision`, `skills/handoff`) — style exemplars: match their voice, density, and the way every rule carries its reason
5. Official references: https://code.claude.com/docs/en/skills, https://code.claude.com/docs/en/sub-agents, https://code.claude.com/docs/en/hooks

Inspiration, not import: https://www.aihero.dev/skills-grill-with-docs for the interviewing posture (challenge, don't transcribe), and https://github.com/mattpocock/skills/tree/main/skills/engineering for how mature skills are structured and composed. Where either conflicts with this repo's docs, this repo's docs win.

## Increments, in order

1. `docs-rules` — dependency of everything forked; pure distillation, no new rules
2. `interview` — includes the ID-allocation mechanics (`work/next-id`)
3. `critique` + the `critic` agent — first fork; also the first real test that the artifacts alone carry enough context
4. `shape` — last, because of the open point below

**Stop after each increment for human review.** That review is this pipeline's Accept gate; do not batch increments.

## Constraints

- **Skills encode the docs; they don't restate them.** Link to the authority or rely on `docs-rules` — one copy, always.
- **Where the spec is silent: propose, don't decide.** Answer evidence questions yourself from the repo, citing files. Collect judgment questions and raise them at the increment checkpoint.
- **One open point you must not decide:** findings 3 and 5 in `docs/research/audit-2026-08-workflow-docs.md` propose changes to the Open-questions gate that `shape` would encode. Before writing `shape`, ask the user whether those go into the docs first.
- **One gap you should propose a fix for:** docs-structure describes `brief.md`'s content but defines no heading template (spec.md and tickets have one; stable headings are the anchor strategy). Propose a template during increment 2, get approval, and update docs-structure in the same change — that's reconcile, not scope creep.
- `shape`'s write boundary is a skill-scoped PreToolUse hook (see skills/README.md §Settings). Prototype the hook standalone before embedding it.
- This repo keeps skills in `skills/`, not `.claude/skills/` — decide how to make them invocable here for exercising (symlink is the obvious candidate), and document whatever you choose.
- Keep skill bodies concise. Loaded skill content is a recurring token cost; the existing skills show the target density.

## Done when

Per increment: the files exist with frontmatter matching the spec tables; the skill has been exercised once on a real item in this repo (the backlog has genuine candidates); and `skills/README.md`'s Status section plus `work/backlog.md` reflect the new reality — reconcile is part of the increment, not a follow-up.
