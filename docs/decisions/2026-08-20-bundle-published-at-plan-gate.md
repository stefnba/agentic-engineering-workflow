---
date: 2026-08-20
status: accepted
areas: [workflow, skills]
supersedes:
  the persistence half of
  [2026-08-10-interview-persists-nothing-shape-claims-the-bundle.md](./2026-08-10-interview-persists-nothing-shape-claims-the-bundle.md)
  — `shape` calling `claim-bundle.sh` to allocate an id and create the bundle directory before
  drafting. Its first half, that `interview` writes nothing, stands
---

# The bundle is published at the Plan gate, not claimed before drafting

## Context

`shape` claimed a bundle directory as its first act, then wrote the spec and tickets into it. The
claim existed to hand out a collision-free id from a shared counter; 0013 removed the counter and
left the claim behind. What remained was a committed, published directory holding a draft no gate
had passed — visible to every other session as though it were work.

## Decision

The draft is tool-local and uncommitted. On the human's approval at the Plan gate, `shape` commits
the exact approved bundle under `work/bundles/` on the integration target.

- The id is `$(date +%F)-<slug>`, checked against `work/bundles/` before drafting starts.
- Committed directly, never through a PR: mandatory critique plus the human's approval are the
  review a planning artifact gets.
- The approved bytes and the committed bytes are the same — no edits between the OK and the commit.
- A push rejected on a date-and-slug collision is a rename and a retry, not a rewrite.

## Rejected

- **Claim the id first (0012)**: publishes an unapproved directory, and the id it protects needs no
  protecting once it derives from the date and the title.
- **A PR for the bundle**: adds ceremony without adding a gate — critique and the Plan gate already
  are the review, and a second approval on the same bytes is theatre.

## Costs

- A shaping session that dies before the Plan gate loses the whole draft; nothing partial survives.
- Two sessions can shape the same slug on the same day and only find out at the push.
- Overlap is caught by reading `work/bundles/` and judging, not by a collision — a related bundle
  under an unrelated slug is invisible to the check.

## Revisit if

- Lost drafts become a recurring cost rather than a theoretical one.
- Concurrent shaping sessions become common enough that a same-day slug collision stops being rare.
