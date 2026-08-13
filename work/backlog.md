# Backlog

Work on the reference material itself. Unsorted collection dump — order carries no meaning.

Tags (no workspace packages here, so declared by hand): `[docs]` the guides under
`docs/`, `[skills]` everything under `skills/`, `[repo]` structure, distribution,
and meta concerns.

## Items

- [repo] rename the GitHub repo from `agentic-coding` to `agentic-workflow` to match the plugin name
  - update `plugin.json`'s `repository` field and README references once done
- [skills] build the workflow skills and subagents mapped in work/skills-build-plan.md
  - one end-to-end first, using the workflow itself
- [docs] Codex section in tool-setup.md is an empty TODO
- [skills] review could run parallel critics — standards axis vs requirements axis
- [skills] skill-layer patterns from mattpocock/skills worth evaluating
  - router skill, per-repo setup skill, reference layer, user- vs model-invoked split
- [docs] verify evidence is self-reported — CI ownership of the gate unstated
- [docs] failure paths undefined — abandoned ticket, cancelled bundle (rejected review is shaped: 2026-08-13-review-fix-loop)
- [docs] gather has no trigger — audit/research/prune cadence undefined
- [skills] consistency-sweep skill (`tidy`) — detect drift between backlog, decisions, work items
  - detect and propose only, human applies; don't name it "reconcile" (taken by the per-PR obligation)
- [skills] judge: 5 test rounds confirm decidability bail-out, pure mode, pass-1 discipline (reasons from general practice, no repo leakage into first-principles section), and divergence citations are real and correctly grounded (path+line verified) — fixed one template deviation (stray preamble sentence before `## Question`)
  - still unexercised: a genuine collision where reconciliation actually changes the pick — 3/3 default-mode test questions found the repo's convention already matched; needs a real mismatch case, not a contrived one
- [skills] writing-for-agents: micro-test "Phrasing that changes behavior" and "Co-locate" before pruning
  - baseline runs on Sonnet did both unprompted (candidate no-ops); needs 5+ rep micro-tests per references/testing.md before deciding
- [skills] writing-for-agents: verify judgment-added lines with reruns — the "one instruction per paragraph" bullet, skill-mechanics' "Bundled files" section, and the slot-guidance-in-comments rule
  - added on judgment (no baseline); candidate no-ops — micro-test per references/testing.md alongside the Phrasing/Co-locate item
- [repo] scripts/find-by-frontmatter.py is unused — skills stick to grep for flat ticket frontmatter (decision 0004)
  - wire it into a skill (and move it under skills/, shipped tree) only when a real use case appears: array queries (`depends_on`, `areas`) or nested metadata
- [docs] metadata format inconsistent across plan/ticket/workflow markdown files
  - some use an inline `Key: Value · Key: Value` header (e.g. decisions/0001), others use YAML frontmatter (e.g. skills/shape/SKILL.md)
- [skills] writing-for-agents: verify the Source fidelity rule with a rerun
  - the fidelity assertion in evals/evals.json (eval 0) was added after iteration 1; no with-skill run has tested it yet
- [skills] writing-for-agents: run skill-creator's description-trigger optimization on the frontmatter description
- [repo] verify the AGENTS.md prunes with a rerun (tie-break routing sentence removed, reference-repo caveat merged)
  - docs-structure.md has since been merged into agentic-workflow.md — the two-doc tie-break no longer applies
- [repo] bundles 0001, 0003, 0004 predate the skills/README.md + agents/README.md → docs/skills.md move
  - 0003's spec shaped the opposite resolution (fold agents/README.md into skills/README.md, colocation-exception decision) — reconcile or re-shape before implementing; 0001 and 0004 only need their references re-pointed
- [docs] record a decision for skills/agents docs moving central to docs/skills.md
  - supersedes the colocation expectation for plugin payload trees; driver is the plugin agent scanner (no README carve-out) plus the derived-view cleanup
- [docs] decision 0003's spec heading set (`Problem / Target state / Non-goals / …`) contradicts the eight-heading format in agentic-workflow.md — supersede if the drift matters
- [docs] decisions 0002, 0004, and 0012 carry stale mechanism details (`next-id`, `claim-bundle.sh`, `candidates/`/`planned/`) after decision 0013 — 0013's Costs names only 0002 and 0012, but 0004's Context also states the superseded three-tier `candidates/ → planned/ → active/` scheme; catch all three in a reconciliation sweep
- [skills] backlog skill restructure is unverified — rerun add prompts per writing-for-agents references/testing.md
  - entry format + tag discipline moved behind a references/entry-format.md pointer; check the pointer gets followed on add
- [skills] decision + shape keep fill-in templates at skill root — route to assets/ per skill-mechanics, as backlog now does
  - decision/template.md, shape/{spec,ticket,work-file}-template.md; check each SKILL.md pointer after moving
- [skills] glossary skill's trigger reliability is unverified — spec deferred it to a backlog line that was never added
  - micro-test per writing-for-agents references/testing.md: does it fire on defining/renaming/disambiguating a term without the word "glossary"
- [skills] audit + research skills and researcher agent are unverified — no baseline or with-skill run yet
  - check the background fork completes, the `${CLAUDE_PLUGIN_ROOT}` write-boundary hook fires, and the backlog-skill preload actually injects the entry format into the agent
- [skills] shape's backlog commit overwrites the whole file, clobbering concurrent edits
  - should stage/commit only the lines it touched, not the full file — happened during this session
- [docs] docs/skills.md's namespacing example (`/agentic-coding:shape`) is stale — plugin.json's `name` is now `agentic-workflow`; see docs/research/audit-2026-08-repo-sweep.md
- [docs] docs/skills.md's manual-invocation rule ("crosses a human gate" → `disable-model-invocation: true`) doesn't match the actual pattern — audit, research, handoff, and setup are all manual without crossing Pick/Plan/Accept; see docs/research/audit-2026-08-repo-sweep.md
- [docs] docs/skills.md claims agent-preloaded skills are hidden via `user-invocable: false`, but backlog (the one real preloaded skill, via agents/researcher.md) has no such field and is also directly user-facing; see docs/research/audit-2026-08-repo-sweep.md
- [docs] decision 0015 carries one stale ownership sentence ("workflow doc describes both strategies generically") after the in-flight ID-6 amendment
  - argument unaffected (per-repo git.md, setup choice, trunk default all stand) — catch in a reconciliation sweep or supersede, precedent: 0013's handling of 0002/0012
- [skills] setup's strategy question and implement/ship's mode-conditional branching are unverified — no fresh-session baseline or with-skill run yet (built and grep-verified only)
  - per writing-for-agents references/testing.md: does setup ask/skip the question correctly on first-run vs re-run; does implement actually branch/PR per the declared mode and sync the integration branch under bundle-branch; does ship actually land the integration branch correctly — this repo's own docs/agents/git.md (trunk) is the one real instance to test against
- [repo] pinned subagent model/effort tiers may rename or go stale
