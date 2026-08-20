---
status: accepted
date: 2026-08-12
areas: [docs]
---

# 0014 The glossary lives at the repo root, not colocated with code

## Context

`GLOSSARY.md` needs a home. Decision 0009 already settled that durable system docs live
colocated with the code they describe, precisely because proximity is what keeps a PR's diff
honest about staleness. Domain vocabulary is different from a subsystem's target state: a
term crosses whatever module boundaries the domain itself crosses, so no single colocated
README owns it without splitting the one shared language across several files.

## Decision

A repo's canonical vocabulary lives in one root `GLOSSARY.md`. In a monorepo, each domain may
carry its own `GLOSSARY.md` at the domain root for terms specific to that domain, and the root
file holds cross-cutting terms plus a Domains section linking each sub-glossary. This is a
deliberate exception to 0009: colocation's freshness argument is replaced here by the
reconcile obligation (a change that renames or redefines a term updates the affected glossary
in the same PR), the same mechanism that already carries README freshness for the rest of the
workflow.

## Rejected

- **A `Language` section in each domain's colocated README**: keeps 0009's proximity intact,
  but a term used across domains would need to live in one README and be referenced from the
  others, or be duplicated and drift — splitting the one shared vocabulary defeats the point of
  having a single glossary at all.
- **A central `docs/glossary.md` or `docs/GLOSSARY.md`**: 0009 rejected central `docs/systems/`
  for exactly this reason — a central doc is invisible in the diff of the change that
  falsifies it. At the time 0009 was written there was no reconcile obligation to compensate;
  root placement only works now because reconcile explicitly names the glossary as something
  every PR must check.

## Costs

- The glossary is rarely in the diff that falsifies it — a code change that renames a concept
  doesn't touch `GLOSSARY.md` by construction, unlike a colocated README a reviewer sees
  alongside the code. Reconcile discipline, not proximity, is what has to carry freshness here,
  and reconcile can be skipped or done carelessly in a way a same-file diff can't.
- Root placement means one more file competing for attention at the top of the repo tree,
  alongside `README.md`, `AGENTS.md`, and `CLAUDE.md`.

## Revisit if

- Reconcile routinely misses glossary drift in practice — renamed or redefined terms surface
  stale entries repeatedly rather than as an occasional miss — which would mean the reconcile
  obligation isn't actually compensating for the lost proximity and colocation needs
  reconsidering after all.
