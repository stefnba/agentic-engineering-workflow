---
status: accepted # proposed | accepted | superseded
date: YYYY-MM-DD
areas: [] # tags from work/backlog.md's header
# supersedes: "0003" — only when overturning an earlier record
---

<!-- Fill every section, delete these comments as you go. The examples below are one
running record: 0003, "Rotate refresh tokens on use". -->

# NNNN <Decision as a statement, not a topic>

## Context

<!-- What was true that forced a choice. Two to four short sentences. No history lesson.

Example:
Refresh tokens lived 30 days, and a leaked one stayed valid until expiry. Two account
takeovers were traced to stolen tokens. Something had to bound the damage window.
-->

## Decision

<!-- The rule the codebase now follows, present tense, one or two sentences. Mechanics the
rule fixes — names, paths, sequences — one per bullet; omit the list when the rule stands
alone.

Example:
Every use of a refresh token invalidates it and issues a new one.

- Reuse of an invalidated token revokes the whole session family.
- A 10 s grace window absorbs concurrent refreshes.
-->

## Rejected

<!-- One line per alternative actually considered — never invented.

Example:
- Shorter token lifetime: shrinks the window without closing it; punishes idle users.
-->

## Costs

<!-- What this makes worse, harder, or riskier — one tradeoff per bullet, named honestly.

Example:
- Racing clients can trip the reuse detection and log a real user out.
-->

## Revisit if

<!-- The conditions under which this record is supposed to be overturned, one per bullet.

Example:
- Sessions move to short-lived access tokens only — rotation becomes moot.
-->
