---
status: accepted
date: 2026-08-13
areas: [docs, skills]
---

# 0015 Git conventions are a per-repo file chosen at setup, not fixed in skills

## Context

The skills hardcode trunk-based mechanics — `implement` branches off the default branch and
PRs per ticket, `ship` merges to main — without any record deciding that topology. Pinning the
planned `ticket-runner`'s contract forced the question. An independent ruling (judge,
2026-08-13) picked trunk-based on first principles: ticket slices are independently green and
human-reviewed, so short-lived branches minimize rebase churn exactly where parallel runners
need it, and a per-bundle integration branch re-creates late integration. The human's
counter-concern was real, though: consuming repos deploy main's head via Coolify auto-deploy,
so per-ticket merges can put half-finished features in front of users. Research showed Coolify
auto-deploy is a per-app toggle with deliberate-release workarounds (production-branch
promotion, manual/API deploys) but no native deploy-on-release yet. The right topology
therefore depends on the consuming repo's release setup — and this plugin serves heterogeneous
repos.

## Decision

Per-repo git conventions live in `docs/agents/git.md`, scaffolded by `setup`. Setup asks the
branch-strategy question — trunk per-ticket PRs to main (recommended default) vs. per-bundle
integration branch — with a two-line cost description of each, and writes the answer into the
file alongside commit message conventions, PR conventions, and release-promotion mechanics.
`AGENTS.md` carries only a sharp pointer (read `docs/agents/git.md` before any git operation).
Skills key branch targets and merge semantics off the declaration in the file; a missing file
means trunk defaults. The canonical workflow doc describes both strategies generically —
`git.md` holds only this repo's choice and its repo-specific mechanics, never restated
definitions.

## Rejected

- **Trunk-based fixed for every repo** (the judge ruling's pick): assumes release timing can
  always move deploy-side — a production branch, a toggle. Repos that can't or won't decouple
  deploy from merge legitimately need whole-feature merges, and a plugin that prescribes one
  way loses them.
- **Per-bundle integration branch as the fixed way**: re-creates the late-integration failure
  the ticket design exists to eliminate — branch drift, sync churn, conflicts deferred to
  ship, and a final merge nobody reviews as a whole — at its worst precisely when tickets run
  in parallel.
- **A declaration line in `AGENTS.md` with details elsewhere**: once commit conventions
  joined, `implement` has to read `git.md` anyway, so the split line saves no read, creates
  two homes for one topic, and feeds the AGENTS.md bloat that motivated outsourcing in the
  first place.

## Costs

- Every git-touching skill pays a file read, and `implement`/`ship`/`ticket-runner` carry
  two-mode conditionals — each skill now has double the branching paths to verify.
- A new `docs/agents/` tree lands in every consuming repo for, today, one file.
- The missing-file trunk fallback is silent — a repo that loses or never scaffolds `git.md`
  gets trunk behavior with nothing flagging the assumption.
- Setup gains one more question mid-install, spending exactly the kind of user attention it
  otherwise minimizes.

## Revisit if

- Consuming repos in practice all pick the same strategy — then collapse to one way and
  delete the conditional paths.
- The two-mode conditionals mis-execute in real runs (a PR lands on the wrong target) — the
  flexibility isn't worth an unreliable gate.
- Coolify or its peers ship native deploy-on-release, changing which repos still need
  merge-side release control.
