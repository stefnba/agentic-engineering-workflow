---
status: todo
depends_on: []
---

# 02 — Workflow doc entry and decision record

## Scope

`docs/agentic-workflow.md`: add root `GLOSSARY.md` to the Layout tree; add a **GLOSSARY.md**
entry to "The artifacts" carrying the full consumption rule per ID-1 and BR-5–BR-8 plus the
monorepo form (BR-3) and mutability contrast with decisions (BR-4); extend the reconcile
definition (the "fix any drift…" sentence under the loop diagram) so affected glossaries
join colocated READMEs, `spec.md`, and remaining tickets. Write the decision record
`docs/decisions/NNNN-glossary-lives-at-the-repo-root.md` per ID-5 from the template at
`skills/decision/template.md` — NNNN computed at write time per the decision skill's
numbering rule (highest existing plus one; 0014 if nothing lands first): context (vocabulary is cross-cutting; 0009 owns colocation),
decision (root `GLOSSARY.md`, per-domain files in monorepos), rejected (colocated Language
sections in domain READMEs — splits the one language; a `docs/` placement — invisible in
falsifying diffs with no reconcile hook at the time 0009 was written), costs (the glossary
is rarely in the diff that falsifies it; reconcile discipline carries freshness), revisit-if
(reconcile routinely misses glossary drift). Add the ID-6 note to the `review` row in
`work/skills-build-plan.md`.

## Done when

- `grep -q 'GLOSSARY.md' docs/agentic-workflow.md` passes
- `ls docs/decisions/*-glossary-lives-at-the-repo-root.md` passes
- `grep -qi 'glossar' work/skills-build-plan.md` passes
- AC-2 holds by inspection

## Not in this ticket

The AGENTS.md/README self-applied-conventions notes and the dogfooded file itself (→ 05);
any skill edits (→ 01, 03, 04).
