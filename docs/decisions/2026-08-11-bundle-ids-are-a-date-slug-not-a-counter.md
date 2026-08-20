---
status: accepted
date: 2026-08-11
areas: [docs, skills]
---

# 0013 Bundle ids are a date-slug, not a sequential counter

## Context

The sequential-counter scheme (`work/next-id`, `claim-bundle.sh`) exists only to hand out
collision-free numbers from one shared mutable file. That requirement is what forced a claim-first
commit ahead of any spec content, and the claim-first commit is what `candidates/` existed to hold —
the window between claiming an id and finishing the spec. Revisiting the scheme while drafting the
consumer-facing workflow doc (`skills/setup/workflow-doc.md`) surfaced that the coordination problem
is self-inflicted: an id derived from content needs no shared counter at all.

## Decision

Work-item bundles are identified by `YYYY-MM-DD-<slug>` — the date, plus a kebab-slug of the title —
not a counter. `shape` checks that the exact path doesn't already exist and skims currently open
bundles for topical overlap (a judgment call, surfaced to the human when something looks related,
not a string-distance match) before doing any deep reading. It then writes the bundle locally as
before, but commits and pushes it once, as a whole, at the Plan gate — there is no separate claim
step, no `work/next-id`, no `claim-bundle.sh`. Bundle status collapses from three directories to two:
`shaped/` (spec + tickets complete) and `active/` (implementation underway). `candidates/` existed
solely for the claimed-but-unshaped window; that window no longer exists once nothing is written
to disk as a bundle until the bundle is complete.

## Rejected

- **Keep the counter, move the claim to the end** (write spec + tickets first, claim last): still
  needs a shared mutable counter and a retry protocol, and moves the collision-retry cost to after
  the expensive part — a full spec-and-tickets rename — instead of before it. That's the opposite of
  what `claim-bundle.sh`'s own design note argued for: keeping the collision window short regardless
  of how long the spec takes to write.
- **Keep three statuses under the new scheme**: `candidates/` was justified by the claim-first commit
  creating an empty, id-holding directory before content existed. With no claim step, nothing is
  written to `work/` at all until the bundle is complete — keeping the bucket would mean inventing a
  new reason for it, not preserving the one it had.

## Costs

- Bundles are referenced in prose by a longer, less pronounceable id (`2026-08-11-billing-retries` vs.
  `0042`) — smaller in practice than it sounds, since people already say the slug, not the number, but
  a real loss for anyone who liked short numeric references.
- Loses the coincidence that a decision and a work item could share a number (noted in decision 0012)
  — never load-bearing, just a footnote that no longer applies now the two id formats can't collide.
- `work/next-id` and `claim-bundle.sh` are deleted outright. Two earlier accepted records mention them
  as part of their own reasoning — decision 0002 lists `next-id`/`candidates/`/`planned/` in its
  Decision text, and decision 0012 names `claim-bundle.sh` as shape's id-allocation mechanism. Neither
  record's actual argument is affected (work items still live in `work/` at the repo root; interview
  still persists nothing and shape is still the sole author of intent), so neither is superseded here
  — but both now carry one stale implementation detail a future reconciliation sweep needs to catch.
- The topical-overlap check is a judgment call, not a guarantee — unlike the counter, which made a
  silent duplicate id impossible by construction, nothing here guarantees an agent notices near-duplicate
  effort filed under an unrelated-looking slug.

## Revisit if

- Skimming currently-open bundle titles stops being a reliable check at scale — matches the existing
  "past ~20 active bundles, use GitHub issues" threshold already in place for a different reason.
- Two agents collide on the same date *and* the same slug in practice, not just in theory — would need
  a disambiguation suffix.
- A monorepo consumer's single package produces enough same-day bundles that date+slug collisions
  become routine rather than exceptional.
