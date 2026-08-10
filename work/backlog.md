# Backlog

Work on the reference material itself. Unsorted collection dump — order carries no meaning.

Tags (no workspace packages here, so declared by hand): `[docs]` the guides under
`docs/`, `[skills]` everything under `skills/`, `[repo]` structure, distribution,
and meta concerns.

## Items

- [docs] [skills] decision + backlog skills contradict docs-structure.md
  - `done/` vs delete-on-ship, `.agents/rules/`, ID scheme (template shape settled by decision 0005)
  - candidates/ + brief.md not yet reflected in the skills
  - backlog skill's shell preamble hard-fails outside a workspace layout (`ls apps/*/package.json`)
- [skills] build the workflow skills and subagents mapped in skills/README.md
  - one end-to-end first, using the workflow itself
- [docs] Codex section in setup-claude-code.md is an empty TODO
- [docs] decide where review findings and verification evidence live
  - PR description/comments vs files in the repo
- [docs] no home for domain language / glossary in docs-structure
  - see mattpocock/skills CONTEXT.md — shared language fights misalignment
- [skills] review could run parallel critics — standards axis vs requirements axis
- [skills] skill-layer patterns from mattpocock/skills worth evaluating
  - router skill, per-repo setup skill, reference layer, user- vs model-invoked split
- [docs] the bundle-less 80% path is undefined — which stages and gates still apply
- [docs] verify evidence is self-reported — CI ownership of the gate unstated
- [docs] failure paths undefined — rejected review, abandoned ticket, cancelled bundle
- [docs] gather has no trigger — audit/research/prune cadence undefined
- [docs] AGENTS.md is referenced but never defined or exampled
- [skills] consistency-sweep skill (`tidy`) — detect drift between backlog, decisions, work items
  - detect and propose only, human applies; don't name it "reconcile" (taken by the per-PR obligation)
- [skills] shape's write-boundary hook uses `${CLAUDE_PROJECT_DIR}`, not `${CLAUDE_PLUGIN_ROOT}` (decision 0001, rule 4)
  - no `.claude-plugin/plugin.json` exists yet to make `${CLAUDE_PLUGIN_ROOT}` resolve; migrate once it does
- [skills] recommendation skill — weigh options with pros/cons and give a recommendation
- [skills] writing-for-agents: micro-test "Phrasing that changes behavior" and "Co-locate" before pruning
  - baseline runs on Sonnet did both unprompted (candidate no-ops); needs 5+ rep micro-tests per references/testing.md before deciding
- [skills] writing-for-agents is absent from skills/README.md (supporting-skills table, Status section)
- [repo] scripts/find-by-frontmatter.py is unused — skills stick to grep for flat ticket frontmatter (decision 0004)
  - wire it into a skill (and move it under skills/, shipped tree) only when a real use case appears: array queries (`depends_on`, `areas`) or nested metadata
- [docs] metadata format inconsistent across plan/ticket/workflow markdown files
  - some use an inline `Key: Value · Key: Value` header (e.g. decisions/0001), others use YAML frontmatter (e.g. skills/shape/SKILL.md)
- [skills] writing-for-agents: verify the Source fidelity rule with a rerun
  - the fidelity assertion in evals/evals.json (eval 0) was added after iteration 1; no with-skill run has tested it yet
- [skills] writing-for-agents: run skill-creator's description-trigger optimization on the frontmatter description
- [docs] [skills] docs-structure, docs-rules, critic, workflow doc still describe the old five-heading spec
  - the new spec/ticket templates in skills/shape are authoritative now; reconcile the four docs (headings, Non-goals→Out of Scope, open-questions fold rule)
- [repo] verify the AGENTS.md prunes with a rerun (tie-break routing sentence removed, reference-repo caveat merged)
  - restore the tie-break line if agents mis-route between docs-structure.md and agentic-workflow.md
