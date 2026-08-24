---
name: scan-codebase
description: Survey the codebase for architectural and code-quality improvement candidates — module design, complexity, redundancy, dependency structure, naming — returned inline for live triage, never written to a file. Not a doc-drift audit. Invoke bare for a full sweep, or with an area path or dimension to focus it.
argument-hint: "[area path or dimension]"
disable-model-invocation: true
context: fork
agent: scanner
background: false
---

# Scan codebase

Scope: **$ARGUMENTS** — an area path or a dimension to focus on; empty means the whole repo,
every dimension below.

Sweep the scoped code for improvement candidates on these dimensions:

- **Module design** — shallow modules, leaky seams, coupling across boundaries, abstractions
  that fail the deletion test, interfaces that can't serve as a test surface
- **Complexity** — deep nesting, long functions, boolean-flag parameters, code that demands
  mental parsing to follow
- **Redundancy** — duplicated logic, dead code, over-engineered patterns nothing exercises
- **Dependency structure** — wrong dependency direction, cycles, layering violations
- **Naming** — generic or misleading identifiers; code using terms `GLOSSARY.md` rejects, where
  a glossary with entries exists
- **Consistency** — the outlier module that ignores patterns the rest of the repo has settled on

Return the findings as your final message — inline, ranked, with evidence, and nothing written
anywhere. The human triages each finding live: accepted ones become backlog lines through the
`backlog` skill, rejected ones disappear with the report.
