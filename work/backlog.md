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
- [docs] decide where review findings and verification evidence live
  - PR description/comments vs files in the repo
  - as built: implement writes verify/reconcile prose into the PR body, reviewer reads it there and returns findings as its final message — no `evidence` skill exists
- [skills] review could run parallel critics — standards axis vs requirements axis
- [skills] skill-layer patterns from mattpocock/skills worth evaluating
  - router skill, per-repo setup skill, reference layer, user- vs model-invoked split
- [docs] verify evidence is self-reported — CI ownership of the gate unstated
- [docs] failure paths undefined — rejected review, abandoned ticket, cancelled bundle
- [docs] gather has no trigger — audit/research/prune cadence undefined
- [skills] consistency-sweep skill (`tidy`) — detect drift between backlog, decisions, work items
  - detect and propose only, human applies; don't name it "reconcile" (taken by the per-PR obligation)
- [skills] judge: verify the anchoring fix with reruns — drafted from the user-reported failure (over-anchoring on repo conventions), no baseline per writing-for-agents references/testing.md yet
  - test both modes: does pass 1 actually stay out of repo files, and does the divergence report cite real paths
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
- [docs] decisions 0002 and 0012 carry stale mechanism details (`next-id`, `claim-bundle.sh`, `candidates/`) after decision 0013 — flagged in 0013's Costs, catch in a reconciliation sweep
- [skills] backlog skill restructure is unverified — rerun add prompts per writing-for-agents references/testing.md
  - entry format + tag discipline moved behind a references/entry-format.md pointer; check the pointer gets followed on add
- [skills] decision + shape keep fill-in templates at skill root — route to assets/ per skill-mechanics, as backlog now does
  - decision/template.md, shape/{spec,ticket,work-file}-template.md; check each SKILL.md pointer after moving
- [skills] glossary skill's trigger reliability is unverified — spec deferred it to a backlog line that was never added
  - micro-test per writing-for-agents references/testing.md: does it fire on defining/renaming/disambiguating a term without the word "glossary"
- [skills] review skill + reviewer agent are unverified — no baseline or with-skill run yet (built without a real PR to review)
  - run against implement's first real PR per writing-for-agents references/testing.md; check the worktree mechanics for re-running checks actually hold
- [skills] ship skill is unverified — no baseline or with-skill run yet (built without a real bundle to ship)
  - run against the first accepted bundle; check the commits-land-where logic (open PR branch vs default branch) holds, and that the grep-bundle-ID absorb gate is checkable in practice
- [skills] audit + research skills and researcher agent are unverified — no baseline or with-skill run yet
  - check the background fork completes, the `${CLAUDE_PLUGIN_ROOT}` write-boundary hook fires, and the backlog-skill preload actually injects the entry format into the agent
- [skills] shape sequences only refactor tickets — nothing keeps half-built features dark on main
  - judge ruling 2026-08-13: expose-last (internals first, user-visible wiring as the final ticket)
- [docs] branch topology (per-ticket PRs to main) is implied by skill text, never decided
  - judge ruling 2026-08-13 picked trunk-based; record the decision once accepted
