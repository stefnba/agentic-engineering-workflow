---
date: 2026-08-13
source: full-repo sweep (scope "everything") — read docs/agentic-workflow.md, AGENTS.md,
  GLOSSARY.md, work/backlog.md, every file under docs/, skills/, agents/, plus README.md,
  CLAUDE.md, .claude-plugin/plugin.json, and work/skills-build-plan.md
---

# Audit: repo-wide drift sweep

**Evidence, not commitments.** Nothing below is decided. One-line pointers live in
`work/backlog.md`; this file holds the reasoning those lines can't carry.

A prior sweep (`docs/research/audit-2026-08-workflow-docs.md`, 2026-08-07) already covered
`agentic-workflow.md`/`docs-structure.md` critique in depth and its actionable items are
already in the backlog (self-reported verify, failure paths, gather triggers, ID allocation,
etc.). This pass reads the whole tree fresh rather than re-litigating that one; findings below
are new or sharpen an existing backlog line.

## 1. `docs/skills.md`'s namespacing example uses the pre-rename plugin name

`docs/skills.md` line 24: "Cross-skill references by plain name; namespacing
(`/agentic-coding:shape`) is applied at install." `.claude-plugin/plugin.json` (opened) now
reads `"name": "agentic-workflow"`, so an installed skill would namespace as
`/agentic-workflow:shape`, not `/agentic-coding:shape`. The same stale example appears in
`docs/research/docs-read-2026-08-claude-code-plugins.md` (manifest example and the
"Namespacing" bullet), but that file is a `docs/research/` snapshot — evidence, allowed to go
stale the way a decision record is. `docs/skills.md` is durable and states the rule as
current, so its copy is the one an agent following the convention would trust today.

This is the same root fact as backlog's existing `[repo] rename the GitHub repo...` line
(plugin.json's `name` already changed to `agentic-workflow`; `repository` URL and README
references haven't caught up) but a distinct instance — an illustrative example in a durable
doc, not the repo URL or `repository` field that line names.

## 2. `docs/skills.md`'s manual-invocation rule doesn't predict the actual frontmatter pattern

`docs/skills.md` line 11: "Every skill that crosses a human gate is manual
(`disable-model-invocation: true`); everything invoked by another skill or by context stays
model-invocable." The workflow doc (`docs/agentic-workflow.md` § Where the human sits) names
exactly three gates: Pick, Plan, Accept.

Grepped `disable-model-invocation` across `skills/*/SKILL.md`: 10 of 14 skills carry it —
`pick`, `shape`, `interview-me`, `implement`, `review`, `ship`, `audit`, `research`, `setup`,
`handoff`. Only `pick` (literally the Pick gate) and arguably `shape`/`review` (immediately
precede Plan/Accept) map cleanly onto the stated criterion. `audit`, `research`, `handoff`,
and `setup` are manual too, but none of them crosses Pick, Plan, or Accept — `audit`/`research`
feed the backlog that Pick reads, `handoff` and `setup` aren't stage-bound at all
(`docs/skills.md`'s own "Supporting skills" table in `README.md` lists them outside the
stage-bound set). The 4 skills that stay model-invocable and aren't stage-bound
(`backlog`, `glossary`, `decision`, `judge`) plus `critique` (stage-bound but invoked by
`shape`, not the human) do fit the second half of the rule.

Two ways to close this, both undecided here: broaden the stated rule (e.g. "every skill
directly invoked by the human at a stage boundary, plus session/repo-wide skills with
one-shot side effects, is manual") to match the 10-skill pattern, or treat the extra four as
exceptions and say so. Either way the doc's rule as written doesn't currently explain its own
implementation.

## 3. `docs/skills.md`'s "preloaded skills are hidden via `user-invocable: false`" claim has no matching instance

`docs/skills.md` line 17: "reusable formats preload via the agent's `skills:` field (such
skills are hidden from the `/` menu with `user-invocable: false`)". Grepped every
`agents/*.md` for a `skills:` field — the only hit is `agents/researcher.md`, which preloads
`backlog`. `skills/backlog/SKILL.md`'s frontmatter (`name`, `description`, `argument-hint`,
`allowed-tools`) has no `user-invocable` field, and `backlog` is also invoked directly by
users in the ordinary `/` menu (this very session was invoked as the `backlog` command). So
the one real example of the pattern the sentence describes doesn't carry the field it says
such skills carry — plausibly because `backlog` is deliberately dual-use (both preloaded and
directly user-facing) and the blanket "hidden from the menu" framing doesn't fit that case, but
nothing in the docs says so explicitly.

## 4. Decision 0004 also carries the stale bundle-status mechanism, not just 0002 and 0012

`work/backlog.md` already has: "decisions 0002 and 0012 carry stale mechanism details
(`next-id`, `claim-bundle.sh`, `candidates/`) after decision 0013 — flagged in 0013's Costs,
catch in a reconciliation sweep." Decision 0013's own Costs section (opened) names only 0002
and 0012 by number. But decision 0004's Context (opened,
`docs/decisions/0004-bundle-status-lives-in-the-directory.md` line 11) states as current fact:
"multi-file bundles moving through `candidates/ → planned/ → active/`" — the same three-tier
scheme decision 0013 collapsed to two (`shaped/`, `active/`). 0004's actual Decision (bundle
status = the parent directory, ticket status = frontmatter) is unaffected by the tier count and
doesn't need superseding, same as 0013 said for 0002 and 0012 — but a reconciliation sweep
grepping only "0002 and 0012" per the current backlog line would miss 0004's Context sentence.

## Open questions

- Is the `docs/skills.md` manual-invocation rule (finding 2) meant to be normative — should
  `audit`/`research`/`handoff`/`setup` lose `disable-model-invocation: true` to match the
  stated rule — or is the rule under-stated and should grow a second clause? Both are live;
  nothing in the repo says which.
- Is `backlog`'s dual role (finding 3) the intended shape, with `docs/skills.md`'s sentence
  simply describing the common case and not a universal rule? No file states that exception
  explicitly, so it reads as a real mismatch rather than a documented one.
- Assumption: plugin namespacing (finding 1) is keyed off `plugin.json`'s `name` field, per
  `docs/research/docs-read-2026-08-claude-code-plugins.md`'s "Namespacing" bullet — not
  independently reverified against current Claude Code docs in this pass.
