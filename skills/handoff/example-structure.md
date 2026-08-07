# Handoff structure

+An illustration of shape and detail level, not content to reuse — the task, paths, SHAs, and timestamp below are invented.

Note what's missing: this was an implementation session, so it has no **Findings** or **Ground covered** sections. Those belong to discovery work. Omit sections the same way rather than filling them to complete the set.

---

# Handoff: Move session auth from cookies to signed tokens

- **Written:** 2026-08-07 14:30 (use correct timezone of user)
- **Repo:** api-gateway
- **Branch:** auth-token-migration
- **Worktree:** example-worktree
- **Next session:** finish the middleware and get the integration suite green

## Objective

Replace cookie-based sessions with signed short-lived tokens so the mobile clients stop needing a cookie jar. Scope is the gateway only — the downstream services keep trusting the `X-User-Id` header the gateway sets, and changing that is explicitly out of scope for now.

## Open questions

- What should happen to in-flight requests when a token expires mid-request? Settled by asking whether the gateway or the client owns retry.
- Does the mobile team actually expect a 15-minute token lifetime? A comment in `docs/mobile-auth-notes.md` implies it, but nobody has confirmed it — treat as unverified.
- Does the admin console need a migration window, or can it cut over at the same time? Ask whoever owns `admin-console`.

## Working tree

- `src/auth/token.ts` — new, untracked. Deliberate WIP, signing works and is tested.
- `src/middleware/verify.ts` — modified, half-finished. Verification is stubbed to return `true`.
- `scratch/jwt-poc.ts` — untracked debris from an early experiment, safe to delete.
- No stashes.

## Current state

Signing works and is covered by unit tests. Verification is stubbed, so the integration suite passes for the wrong reason — every request currently authenticates. The build is green. Don't trust `npm run test:integration` until `verify.ts` is real.

## What's been done

- `a3f91c2` — added `TokenSigner` and its unit tests
- `7bd0e14` — pulled the signing key out of config into the secrets loader
- Middleware chain reordered in the working tree, not yet committed

## Next steps

1. Implement real verification in `src/middleware/verify.ts` — signature, expiry, issuer.
2. Delete `scratch/jwt-poc.ts`.
3. Re-run `npm run test:integration` and expect failures that the stub was masking.
4. Decide the expiry question above before wiring the refresh path.

## Decisions and constraints

- Symmetric signing (HS256), not asymmetric. The gateway is the only verifier, and the user explicitly didn't want key distribution to become part of this change.
- No refresh tokens in this pass. Agreed to ship short-lived tokens first and revisit.
- The user asked to keep changes out of the downstream services entirely, even where it would be tidier to touch them.
- Verification has to run before rate limiting. `src/middleware/chain.ts:41` builds the chain in array order and the limiter keys on identity, so an unverified request would key every caller to `anonymous`.

## Dead ends

- Tried verifying inside the existing `authenticate()` helper (`c40d8b1`, reverted). It runs per-route rather than per-request, so tokens got verified two or three times on routes with sub-handlers.
- Considered `jsonwebtoken` and rejected it — the repo already depends on `jose`, and adding a second JWT library was a non-starter in review.

## Key files

- `src/auth/token.ts` — signing, new this session
- `src/middleware/verify.ts` — where the remaining work is
- `src/middleware/chain.ts` — ordering matters here, see Findings
- `docs/mobile-auth-notes.md` — source of the unconfirmed expiry assumption

## Verification

- `npm run build`
- `npm run test:unit` — passing, 4 new tests for signing
- `npm run test:integration` — passing but meaningless while verification is stubbed
- `test/rate-limit.spec.ts:88` was already failing on `main` before this work started. Not caused by this change.

## Suggested skills

- `code-review` — before opening the PR, since this touches the auth path
