---
date: 2026-08-20
status: accepted
areas: [workflow, skills]
---

# A ticket branch must be current with its base before Accept, not after

## Context

Two sibling tickets with no `depends_on` edge both branch from `bundle/<id>`. The first merges; the
second's accepted head now predates it. The two states merge with **no text conflict** and can still
be broken.

Reproduced: `01` changes a value, `02` asserts on the old one. Both pass on their own branches.
`git merge` exits 0 and the merged tree fails its own assertion. Nothing in the workflow saw it —
and branch protection is not available as a cover, because
`skills/setup/references/prerequisites.md` routes a protected default branch onto an unprotected
integration target.

## Decision

**A ticket PR merges only when its base is an ancestor of the accepted head.**
`complete-ticket.sh` checks `git merge-base --is-ancestor` and exits `2` rather than merging.

The cure — merge the base in and re-verify — moves the head, and `--match-head-commit` binds the
Accept to an exact SHA. So the cure cannot follow the Accept: **currency is a precondition of Accept,
and a branch found stale at merge time goes back for a fix round and a fresh Accept.**

## Rejected

- **Auto-merge the base in at merge time.** Moves the head, so the Accept no longer applies to what
  lands. That is the failure this exists to prevent, not a shortcut around it.
- **Rebase the ticket branch.** Reissues commits the review record points at.
- **Rely on the forge's "require branches to be up to date".** Not available on the integration
  target a protected repository is routed onto, and it is a repository setting rather than a workflow
  guarantee.
- **Do nothing, and let the Land check catch it.** It would — at the end, on the assembled bundle,
  with no way to tell which ticket owns the break and every ticket already accepted.

## Costs

- One extra fix round per stale sibling, each with a fresh Accept.
- Only parallel siblings can go stale; `depends_on` already serializes a dependent behind its
  dependency's merge, so ordering work into a chain avoids the cost entirely — at the price of
  the parallelism the chain gives up.
