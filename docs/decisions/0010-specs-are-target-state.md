---
status: accepted
date: 2026-08-10
areas: [docs]
---

# 0010 Specs describe target state in present tense, never deltas

## Context

A spec can describe the change ("add a retry scheduler") or the destination ("the retry scheduler reads from `billing_events`"). Delta phrasing is the natural way humans write plans, and every ticket-shaped tool encourages it.

## Decision

`spec.md` is written in present tense describing the system as it will exist. Delta descriptions are only true before work starts: an agent picking up ticket 4 of 7 cannot tell which deltas have already landed, while a target-state description is as true at ticket 7 as at ticket 1.

## Rejected

- **Delta phrasing**: readable exactly once, at ticket 1. Its truth decays with every merged PR, and mid-sequence agents misread it in both directions — re-doing landed work or assuming unlanded work exists.
- **Mixed phrasing** (target state plus a change list): the change list is a hand-maintained derived view of ticket status, and it goes stale invisibly — status has one owner and it isn't the spec.

## Costs

- Present tense describing a future system reads as false until the feature ships — readers must know the convention, which is why it's stated in the template itself.
- Amendments must preserve the tense discipline; a "changed X to Y" note is delta phrasing sneaking back in.

## Revisit if

- Single-ticket features become the only use of specs — with no mid-sequence reader, delta phrasing's cost mostly vanishes (though the durable-docs absorption at ship still favors target state).
