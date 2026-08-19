---
date: <YYYY-MM-DD>
status: accepted # accepted | superseded by <link>
areas: [] # the parts of this repo the decision binds
supersedes: # <link>, and which part, only when this record replaces an earlier one
---

<!--
Fill every section and delete these comments as you go. A record is a reference, not a
narrative: bullets over paragraphs, no history lesson, nothing the code already states.
The examples below are one running record, "Rotate refresh tokens on use".
-->

# <The decision, stated as a claim>

## Context

<!--
What was true that forced a choice. Two to four sentences. Be extremly concise.

Example:
Refresh tokens lived 30 days, and a leaked one stayed valid until expiry. Two account takeovers
were traced to stolen tokens. Something had to bound the damage window.
-->

## Decision

<!--
What holds now, present tense. One or two sentences, then the mechanics it fixes — names,
paths, settings, commands — one per bullet. Omit the bullets when the rule stands alone.

Be extremly concise.

Example:
Every use of a refresh token invalidates it and issues a new one.

- Reuse of an invalidated token revokes the whole session family.
- A 10s grace window absorbs concurrent refreshes.
- -->

## Rejected

<!--
One line per alternative that was actually considered, and what sank it. Never invented.

Example:
- Shorter token lifetime: shrinks the window without closing it; punishes idle users.
- -->

## Costs

<!--
What this makes worse, harder, or riskier — one honestly named tradeoff per bullet.

Example:
- Racing clients can trip the reuse detection and log a real user out.
- -->

## Revisit if

<!--
The conditions under which this record is meant to be overturned, one per bullet.

Example:
- Sessions move to short-lived access tokens only — rotation becomes moot.
- -->
