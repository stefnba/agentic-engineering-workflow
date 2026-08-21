---
written: <YYYY-MM-DD HH:MM> # from `date '+%Y-%m-%d %H:%M'`, never from memory
repo: <name> # the basename of `git rev-parse --show-toplevel`
branch: <name> # from `git branch --show-current`
worktree: # path, only when this session ran in a worktree separate from the primary checkout
mode: # `problem-only` when invoked that way, so the missing plan reads as deliberate; else delete
next_session: <what the next session is for>
---

<!--
The document a fresh agent reads instead of this conversation. Fill it, delete these guidance
comments as you go, and delete every section the work has nothing to say about — heading included.
An empty heading is worse than a missing one: it implies there was nothing to report. A discovery
session may have no working tree, an implementation session no open questions. Same for a frontmatter
key that doesn't apply: delete the line.

Keep the section order as written — it is what makes two handoffs comparable.

Length tracks the complexity of the work; most handoffs land well under 150 lines. Write for an
agent, not a human — no progress-report framing, no assessment of how the session went.

PROBLEM-ONLY MODE
Invoked as `problem-only`, for when the next session should attack the problem fresh rather than
inherit this session's reading of it — typically because this session didn't crack it, and its
framing is as likely to be the reason as the problem's difficulty.

The rule: keep what was observed, drop what was concluded. A command's output, an error message, a
file's contents, a commit that exists, a constraint the user stated — facts, all of which stay. Your
diagnosis, your plan, your ranking of the approaches, your hunch about the cause — inference, all of
which goes. The sections below carry their own problem-only note where the mode changes them; where
there is none, the section is unaffected.

The examples throughout are one running handoff, "Move session auth from cookies to signed tokens",
and are invented — never reuse their paths, SHAs, or timestamps.
-->

# Handoff: <what the work is, in one line>

## Objective

<!-- What the work is trying to accomplish, and what's explicitly out of scope.

Problem-only: the goal and its scope, not the approach you had settled on for reaching it.

Example: Replace cookie-based sessions with signed short-lived tokens so the mobile clients stop
needing a cookie jar. Scope is the gateway only — the downstream services keep trusting the
`X-User-Id` header the gateway sets, and changing that is explicitly out of scope for now. -->

<objective>

## Findings

<!-- What you learned that wasn't already known: how the system actually behaves, contra
assumptions.

Problem-only: observations only. `parseConfig() returns undefined for nested keys` stays; `so the
bug is in the merge logic` goes. -->

- <what you found, and whether it's verified>

## Open questions

<!-- What nobody has decided yet, and who owns the decision if known.

Example:
- Does the mobile team actually expect a 15-minute token lifetime? A comment in
  `docs/mobile-auth-notes.md` implies it, but nobody has confirmed it — treat as unverified. -->

- <question> — <who owns it, or how to settle it>

## Ground covered

<!-- Approaches or areas already explored, so the next agent doesn't re-tread them.

Problem-only: where you looked, not what you concluded from looking. -->

- <area explored>

## Working tree

<!-- Uncommitted files: what each one is, and whether it's deliberate WIP or debris. Say so when
there are no stashes.

Example:
- `src/auth/token.ts` — new, untracked. Deliberate WIP, signing works and is tested.
- `scratch/jwt-poc.ts` — untracked debris from an early experiment, safe to delete.
- No stashes. -->

- `<path>` — <what it is; WIP or debris>

## Current state

<!-- What currently works, what's stubbed or faked, and what to distrust.

Example: Signing works and is covered by unit tests. Verification is stubbed, so the integration
suite passes for the wrong reason — every request currently authenticates. Don't trust
`npm run test:integration` until `verify.ts` is real. -->

<state>

## What's been done

<!-- Commits and completed changes, by SHA or path. One line each, no narrative.

Example:
- `a3f91c2` — added `TokenSigner` and its unit tests
- Middleware chain reordered in the working tree, not yet committed -->

- `<sha>` — <what it did>

## Next steps

<!-- Ordered, concrete actions, each ending on a completion criterion.

Problem-only: omit this section. Anything that survives it is an open question — put it under Open
questions, phrased as the question rather than the answer.

Example:
1. Implement real verification in `src/middleware/verify.ts` — signature, expiry, issuer.
2. Re-run `npm run test:integration` and expect failures that the stub was masking. -->

1. <action> — <how you know it's done>

## Decisions and constraints

<!-- Choices already made and why, so the next agent doesn't relitigate them.

Problem-only: only what actually binds the next agent — what the user ruled out, what the
architecture forbids, what already shipped. Your own leanings are not constraints.

Example:
- Symmetric signing (HS256), not asymmetric. The gateway is the only verifier, and the user
  explicitly didn't want key distribution to become part of this change.
- Verification has to run before rate limiting. `src/middleware/chain.ts:41` builds the chain in
  array order and the limiter keys on identity, so an unverified request keys every caller to
  `anonymous`. -->

- <decision> — <why>

## Dead ends

<!-- Approaches tried and abandoned, and why, so they aren't retried.

Problem-only: only approaches you watched fail, written as the failure you saw. Drop the ones you
reasoned yourself out of without running.

Example:
- Tried verifying inside the existing `authenticate()` helper (`c40d8b1`, reverted). It runs
  per-route rather than per-request, so tokens got verified two or three times on routes with
  sub-handlers. -->

- <approach> — <why it failed>

## Key files

<!-- Paths worth opening first, one line of why each. Not an inventory of everything touched. -->

- `<path>` — <why it matters>

## Verification

<!-- Commands that confirm the state, and which failures predate this session.

Example:
- `npm run test:unit` — passing, 4 new tests for signing
- `npm run test:integration` — passing but meaningless while verification is stubbed
- `test/rate-limit.spec.ts:88` was already failing on `main` before this work started. -->

- `<command>` — <expected result>

## Suggested skills

<!-- Skills relevant to what's next, each with the condition that should make the next agent reach
for it. Take the names from this session's own skill list — a plausible-sounding name that isn't
installed sends the next agent hunting for something that doesn't exist.

Example:
- `code-review` — before opening the PR, since this touches the auth path -->

- `<skill>` — <when to use it>
