---
status: todo # todo | doing | done — done requires every "Done when" line to hold
---

# 2026-08-13-decision-skill-elsewhere-redirects — Fix decision skill's stale "elsewhere" redirects

## Problem

Someone drafting an unwarranted decision record — for a repo-wide convention, an area-specific
gotcha, or a record of what got built — is redirected by `skills/decision/SKILL.md` to a place
that either no longer exists (`.agents/rules/`) or was replaced by a later decision (`work/done/`,
superseded by decision 0008). The redirect doesn't hold, so the author either writes the
unwarranted decision record anyway or is left with nowhere real to put the content. Separately,
`docs/agentic-workflow.md`'s Layout diagram never mentions `AGENTS.md` at all, so nothing durable
states where it sits in the tree or how it behaves in a monorepo.

## Change

`skills/decision/SKILL.md`'s "What goes elsewhere" list redirects to real, current locations:

- Conventions and style, repo-wide → `AGENTS.md` (or `CLAUDE.md` if that's what the repo uses;
  never both) — matches the phrasing in `skills/setup/SKILL.md:69`.
- Gotchas specific to one area of the code → that area's own `AGENTS.md`: root `AGENTS.md`, or
  `packages/<pkg>/AGENTS.md` in a monorepo.
- A record of what was built → nowhere dedicated; ship absorbs it into the durable docs it
  affects and deletes the bundle, git history keeps the rest (decision 0008).

The paragraph describing `AGENTS.md` files as **symlinks** into a shared `.agents/rules/`
directory is removed outright — that directory exists nowhere else in this workflow, and
`AGENTS.md` is the canonical file now, not a symlink target.

`docs/agentic-workflow.md`'s Layout diagram gains an `AGENTS.md` entry (root, durable, with a
per-package note for monorepos), and "The artifacts" section gains a matching bullet describing
its role: canonical for every tool, `CLAUDE.md` references it rather than duplicating it, and
a monorepo gets one per package for area-specific content.

## Done when

Seam: literal text of `skills/decision/SKILL.md` and `docs/agentic-workflow.md` — checked by
reading the file and grepping for exact strings, since this is a docs-only change with no
runtime behavior.

- AC-1: `grep -c '\.agents/rules' skills/decision/SKILL.md` returns 0 — no reference to the old
  mechanism survives anywhere in the file.
- AC-2: `skills/decision/SKILL.md` contains the exact line: `- Conventions and style —
  \`AGENTS.md\` (or \`CLAUDE.md\` if that's what the repo uses; never both)`.
- AC-3: `skills/decision/SKILL.md` contains the exact two-line entry: `- Gotchas specific to one
  area of the code — that area's own \`AGENTS.md\`: root \`AGENTS.md\`, or` /
  `  \`packages/<pkg>/AGENTS.md\` in a monorepo`.
- AC-4: `skills/decision/SKILL.md` contains the exact two-line entry: `- A record of what was
  built — nowhere dedicated; ship absorbs it into the durable docs it` / `  affects and deletes
  the bundle, git history keeps the rest (decision 0008)`.
- AC-5: `grep -c 'work/done' skills/decision/SKILL.md` returns 0.
- AC-6: `docs/agentic-workflow.md`'s Layout code block contains a line starting `AGENTS.md`
  whose trailing comment includes both "durable" and "packages/<pkg>/AGENTS.md".
- AC-7: `docs/agentic-workflow.md`'s "The artifacts" section contains a bullet starting
  `**\`AGENTS.md\`**` whose text includes "CLAUDE.md" and "per-package".

## Not in this

- Not adding `AGENTS.md` handling to `tool-setup.md`'s empty Codex section — separate, already
  tracked backlog item.
- Not editing `docs/decisions/0005-*.md` or `docs/decisions/0008-*.md` — cited, not changed.
- This bundle is the first place that states `packages/<pkg>/AGENTS.md` explicitly — no prior
  doc names it. It extends the per-package pattern already established for `work/` (decision
  0002, `agentic-workflow.md:68`) and `GLOSSARY.md` (decision 0014) to `AGENTS.md`, rather than
  inventing an unrelated mechanism. Not in this bundle: a decision record for that extension —
  if per-package `AGENTS.md` turns out contested later, that's a separate call.
- Not touching `skills/setup/SKILL.md` or `skills/setup/references/agents-reference.md` — their
  existing AGENTS.md/CLAUDE.md guidance is already correct and is what this bundle points to.
