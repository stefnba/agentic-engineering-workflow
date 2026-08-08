# Backlog

Work on the reference material itself. Unsorted collection dump — order carries no meaning.

Tags (no workspace packages here, so declared by hand): `[docs]` the guides under
`docs/`, `[skills]` everything under `skills/`, `[repo]` structure, distribution,
and meta concerns.

## Items

- [docs] [skills] decision + backlog skills contradict docs-structure.md
  - template shape, `done/` vs delete-on-ship, `.agents/rules/`, ID scheme
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
- [docs] dogfood decisions/ — docs-structure choices have real rejected alternatives
  - no done/, files over issues, decisions not adr, colocation, target-state phrasing
- [docs] AGENTS.md and decisions/template.md are referenced but never defined or exampled
- [skills] consistency-sweep skill (`tidy`) — detect drift between backlog, decisions, work items
  - detect and propose only, human applies; don't name it "reconcile" (taken by the per-PR obligation)
- [skills] shape's write-boundary hook uses `${CLAUDE_PROJECT_DIR}`, not `${CLAUDE_PLUGIN_ROOT}` (decision 0001, rule 4)
  - no `.claude-plugin/plugin.json` exists yet to make `${CLAUDE_PLUGIN_ROOT}` resolve; migrate once it does
