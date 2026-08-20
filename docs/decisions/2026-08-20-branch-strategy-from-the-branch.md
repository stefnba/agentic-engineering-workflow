---
date: 2026-08-20
status: accepted
areas: [workflow, skills]
supersedes: the branch-strategy bullet of
  [2026-08-20-derived-execution-state.md](./2026-08-20-derived-execution-state.md), which derived it
  from the ticket count alone. Everything else in that record stands, including its rejection of a
  declared strategy
---

# Once the bundle branch exists, it is the branch strategy

## Context

Branch strategy was derived from the number of `NN-<slug>.md` files in a bundle: more than one gets a
bundle branch, one targets the integration target. Deriving beats declaring — that is
[2026-08-20-derived-execution-state.md](./2026-08-20-derived-execution-state.md) and it holds — but a
file count is not a fact about git. It is a fact about a file, and files change.

`ticket_base()` is called on every status query and every claim. Probed across the states a bundle
actually reaches:

| state                             | tickets | `bundle/B` on remote | count rule | correct |
| --------------------------------- | ------- | -------------------- | ---------- | ------- |
| shaped, before the first claim    | 2       | no                   | `bundle/B` | same    |
| first claim created the branch    | 2       | yes                  | `bundle/B` | same    |
| revised down to one ticket        | 1       | yes                  | `main`     | wrong   |
| bundle deleted, mid-Land          | 0       | yes                  | `main`     | wrong   |

In both wrong rows the strategy flips under PRs that already merged into `bundle/B`.
`ticket-status.sh` filters merged PRs by `baseRefName == base`, so a finished ticket reads `todo`,
which unblocks its dependents on work that is done and re-targets the tickets still open.

## Decision

**If `bundle/<bundle-id>` exists on the remote, that is the base.** The ticket count decides only
before the first claim, when no branch exists and no PR can be pointing anywhere yet.

The remote branch is the better source for the same reason the record above prefers git over a
declaration: it is the artifact the PRs are actually merging into, it cannot disagree with itself,
and it is created by the claim that makes the strategy matter.

## Rejected

- **Keep the count and forbid revising the ticket set.** The count would still be read after Land
  deletes the bundle directory, where it silently reports zero. A rule cannot fix a derivation that
  is wrong about a state the workflow reaches on its own.
- **Record the base in the ticket file at claim time.** Re-introduces a declared fact, and one
  written by the same claim whose branch already carries it.
- **Read the base off each ticket's open PR.** Correct, but unavailable before the PR exists and
  gone once a ticket is cancelled — the claim gate needs an answer at both moments.

## Costs

- One `git ls-remote` per `ticket_base()` call, and `bundle-status.sh` fans out per ticket. It is
  small next to the `gh pr list` each status already makes, but it is a network call on a path that
  had none.
- The derivation now has two arms, so the docs have to say which arm applies when —
  `workflow/git-mechanics.md` states it, and the scripts' one definition lives in
  `skills/bundle-git/scripts/_config.sh`.
- After Land deletes the bundle branch, the count arm answers again. That is the correct end state,
  but it means the two arms are not ordered by time so much as by whether the branch is alive.

## Revisit if

- A bundle ever needs a strategy neither the branch nor the count expresses — the same trigger the
  superseded record already names.
