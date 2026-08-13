---
status: todo # todo | doing | done — done requires every "Done when" line to hold
---

# 2026-08-13-subagent-model-effort — Pin model and effort for the four subagents

## Problem

A session forking `arbiter`, `critic`, `reviewer`, or `researcher` gets that agent's model and
reasoning effort from whatever the forking session itself happens to be running — none of the
four set `model` or `effort` in frontmatter. A lightweight session forking a one-shot
architecture ruling (arbiter) caps that judgment at the session's own tier; a power-user
session forking the unattended researcher sweep burns cost/time for no coverage gain.

## Change

Each of the four `agents/*.md` files gets explicit `model` and `effort` frontmatter fields,
tiered by role stakes:

- `agents/arbiter.md`: `model: opus`, `effort: xhigh` — single-shot, seeds a decision record,
  the highest-stakes call of the four.
- `agents/critic.md`: `model: opus`, `effort: high` — last-gate, read-only judgment before the
  Plan gate.
- `agents/reviewer.md`: `model: opus`, `effort: high` — last-gate, read-only judgment before
  the Accept gate.
- `agents/researcher.md`: `model: sonnet`, `effort: medium` — unattended, breadth-first
  background gathering; capped explicitly so a high-power session forking it doesn't run the
  sweep at unnecessary cost.

`model` and `effort` are both documented Claude Code subagent frontmatter fields
(`code.claude.com/docs/en/sub-agents.md`, "Supported frontmatter fields" table: `effort` —
"Effort level when this subagent is active. Overrides the session effort level. Default:
inherits from session. Options: low, medium, high, xhigh, max; available levels depend on the
model"); neither is repo-specific, so no existing `agents/*.md` file or decision record
mentions them yet.

One `work/backlog.md` line, exact text, tracks the staleness risk these pins introduce:

```text
- [repo] pinned subagent model/effort tiers may rename or go stale
```

Model tier names can rename or deprecate, and nothing currently re-checks a pinned name still
resolves. This mirrors the version-pin maintenance cost decision 0001 already names for the
plugin layer generally.

## Done when

Seam: the frontmatter blocks of the four `agents/*.md` files, and `work/backlog.md`'s content
— every criterion below is a grep-checkable assertion against these files at rest.

- AC-1: `agents/arbiter.md`'s frontmatter contains `model: opus` and `effort: xhigh`.
- AC-2: `agents/critic.md`'s frontmatter contains `model: opus` and `effort: high`.
- AC-3: `agents/reviewer.md`'s frontmatter contains `model: opus` and `effort: high`.
- AC-4: `agents/researcher.md`'s frontmatter contains `model: sonnet` and `effort: medium`.
- AC-5: `work/backlog.md` contains the exact line
  `- [repo] pinned subagent model/effort tiers may rename or go stale`.
- `grep -E "^(model|effort):" agents/arbiter.md agents/critic.md agents/reviewer.md agents/researcher.md`
  returns two matching lines per file with the values above.
- `grep -F "pinned subagent model/effort tiers may rename or go stale" work/backlog.md`
  returns one match.

## Not in this

- No edit to `docs/skills.md` — its "prefer portable fields where not needed" line is left as
  is; the exception's rationale lives in this bundle and the backlog line, not restated in the
  doc (human call, made during shaping).
- No changes to any other agent's or skill's frontmatter.
- No decision record — judged not to rise to that; the staleness risk is tracked as a backlog
  line instead.
