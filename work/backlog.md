# Backlog

Work on the reference material itself. Unsorted collection dump — order carries no meaning.

Tags (no workspace packages here, so declared by hand): `[docs]` the guides under
`docs/`, `[skills]` everything under `skills/`, `[repo]` structure, distribution,
and meta concerns.

## Items

- [repo] rename the GitHub repo from `agentic-coding` to `agentic-workflow` to match the plugin name
  - update `plugin.json`'s `repository` field and README references once done
- [docs] [skills] decision skill contradicts agentic-workflow.md
  - `done/` vs delete-on-ship, `.agents/rules/`, ID scheme (template shape settled by decision 0005)
- [skills] build the workflow skills and subagents mapped in work/skills-build-plan.md
  - one end-to-end first, using the workflow itself
- [docs] Codex section in tool-setup.md is an empty TODO
- [docs] decide where review findings and verification evidence live
  - PR description/comments vs files in the repo
- [docs] no home for domain language / glossary in agentic-workflow.md
  - see mattpocock/skills CONTEXT.md — shared language fights misalignment
- [skills] review could run parallel critics — standards axis vs requirements axis
- [skills] skill-layer patterns from mattpocock/skills worth evaluating
  - router skill, per-repo setup skill, reference layer, user- vs model-invoked split
- [docs] verify evidence is self-reported — CI ownership of the gate unstated
- [docs] failure paths undefined — rejected review, abandoned ticket, cancelled bundle
- [docs] gather has no trigger — audit/research/prune cadence undefined
- [docs] AGENTS.md is referenced but never defined or exampled
- [skills] consistency-sweep skill (`tidy`) — detect drift between backlog, decisions, work items
  - detect and propose only, human applies; don't name it "reconcile" (taken by the per-PR obligation)
- [skills] shape's write-boundary hook uses `${CLAUDE_PROJECT_DIR}`, not `${CLAUDE_PLUGIN_ROOT}` (decision 0001, rule 4)
  - `.claude-plugin/plugin.json` now exists, so `${CLAUDE_PLUGIN_ROOT}` resolves — migrate the hook
- [skills] recommendation skill — weigh options with pros/cons and give a recommendation
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
- [skills] `skills/glossary/` is an empty directory — fill it or remove it
- [skills] backlog skill restructure is unverified — rerun add prompts per writing-for-agents references/testing.md
  - entry format + tag discipline moved behind a references/entry-format.md pointer; check the pointer gets followed on add
