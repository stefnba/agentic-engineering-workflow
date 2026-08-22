---
# Where this ticket's approved intent lives, so the IDs it references can be followed. Paths are
# relative to this file: ../spec.md from tickets/NN-<slug>.md, spec.md from a single-ticket bundle's
# ticket.md. Drop plan when the route has none, and drop both on the direct ticket route, where this
# file is the intent.
intent: ../spec.md
plan: ../plan.md
#
# depends_on is the line the claim script parses. Write it as a flow list of unquoted two-digit
# ticket numbers on one line, with nothing after the closing bracket:
#     depends_on: []            depends_on: [01]            depends_on: [01, 02]
# Every other YAML form is unsafe: quoted ("01") or unpadded (1) numbers name a branch that never
# exists and block the claim forever, a trailing # comment is read as a dependency, and
# block-sequence style parses as no dependency at all — which lets a dependent ticket start early.
# Record only real blocking edges; Dependencies and parallelization in
# ${CLAUDE_PLUGIN_ROOT}/workflow/bundle.md defines which edges those are.
depends_on: []
---

<!--
One ticket is one approved slice, one fresh agent session, and one pull request. If you cannot state
"done" as checkable conditions and commands with expected results, the ticket is not shaped yet:
clarify it, or merge it with the ticket it is really part of.

File name, ticket number, and heading number follow Naming and layout in
${CLAUDE_PLUGIN_ROOT}/workflow/bundle.md — `ticket.md` numbered 01 for a single-ticket bundle,
`tickets/NN-<slug>.md` otherwise.

Those three keys are the whole frontmatter. Never add a status field — todo, doing, and done are
derived from the ticket's branch and its merged PR — and never record an external blocker here; it
belongs on the PR, where it cannot go stale.

This file is the brief for an agent that receives the bundle and repository conventions, but not the
other tickets. It never introduces intent or cross-ticket architecture; where the bundle has a spec,
it references BR/BC/INV/NG/AC IDs instead of restating them, and where it has a plan, PD IDs.

Fill every retained section, delete these guidance comments as you go, and delete whichever
route-specific section this bundle does not use.
-->

# NN — <Short imperative title, e.g. "Add rate limiting to /api/login">

## Context

<!-- 2–3 sentences so the ticket stands on its own: what exists today, what this slice adds, and why
it is this slice. Current-state facts this slice needs belong here whatever the route — real paths,
observed behavior, known quirks — because the implementer reads this file first and should not have
to reconstruct them from the plan.

When something outside the bundle gates this ticket — a date, an operator action, an external
prerequisite from the plan — say so in one sentence here. It cannot be recorded as metadata, and
depends_on carries ticket edges only.

Example: Login has no throttling; credential stuffing is the open risk. This ticket adds the
middleware and wires it onto the login route only. Sessions are unaffected. -->

<context>

## Outcome

<!-- One paragraph: what is observably true when this ticket merges that is not true now. Written so
a reviewer can judge it without opening the spec.

The Delivers line repeats this slice's row in the plan's coverage table, identically. Spec-backed
bundles only: delete it on the direct ticket route, where the section below carries the intent. -->

<outcome>

**Delivers:** <BR-2, BR-3, INV-1, AC-4>

## Approved intent (direct ticket route only)

<!-- This bundle has no spec, so this section is the approved intent: it is what the human approves
at the Plan gate and what Review judges against. Delete the whole section — heading included — when
the bundle has a spec.

Keep the categories, skip the ID machinery: with one ticket there is nothing to cross-reference.
Test intent belongs here too; a lighter route drops artifacts, not the decisions Shape owns.

Example acceptance line: Given five failed logins in 60 s, when a sixth arrives, then the response is
429 and the body is {"error": "rate_limited"}. -->

**Behavior:**

- <observable, independently testable statement, present tense>

**Constraints:**

- <constraint any implementation must honor: compatibility, performance, security, mandated reuse>

**Non-goals:**

- <adjacent thing not to build> — <why it is out>

**Test intent:**

- Seam: <observable boundary the behavior test attaches to>
- Risk cases: <failure, boundary, permission, or compatibility cases that must be covered>

**Acceptance:**

- Given <state>, when <action>, then <observable result>.

## Scope

<!-- One line per change: the path, what changes there, and whether the file is new or modified.
Exact paths belong here — they are short-lived at ticket level and banned from the spec. Reference
decisions by ID rather than restating them.

This list is also the expected touch points: it tells a reviewer where the diff should land, without
being an allowlist. An implementer may go outside it for required tests, reconciliation, or clearly
justified local support work — say so once here rather than as a done-when condition.

Example:
- `src/middleware/rateLimit.ts` (new) — fixed-window limiter, 5 attempts per 60 s per BC-2
- `src/api/routes.ts` (modified) — register the middleware on the login route only, per PD-3
- `tests/middleware/rateLimit.test.ts` (new) — happy path, reset, and boundary cases -->

- `<path>` (<new | modified>) — <what changes>

## Not in this ticket

<!-- Adjacent work deliberately excluded, even where the spec's Non-goals are silent, and where it
lands instead: another ticket by number, an NG ID, the backlog, or a follow-on bundle. -->

- <excluded work> — <ticket NN | NG-n | backlog | out of scope entirely>

## Implementation notes

<!-- Only what the agent cannot infer from the code in front of it: the pattern to copy, a decision
already made, a known trap. Delete the section rather than restating the plan or narrating the
obvious. If this ticket's position in the order is not explained by depends_on, one line of why
belongs here.

External documentation the implementer should read first goes here too, pinned to the version in use
— link it rather than leaving the agent to search, which returns the current major version whatever
this repository pins.

Example:
- Follow the middleware pattern in `src/middleware/auth.ts`
- Hono v4.6 `createMiddleware` — https://hono.dev/docs/guides/middleware — v3 examples differ
- Limits are config values in `src/config/index.ts`, never literals
- The sessions table still holds legacy rows with a null user_id — key the limiter on IP, not user -->

- <note>

## Autonomy boundaries

<!-- Bounded implementation discretion, never an unresolved product or cross-cutting question. A
material decision is resolved before approval; anything left here is a decision the Implementer is
authorized to take alone.

Under Must preserve, write the ID plus the one clause that makes it checkable — a bare ID is
unreadable at the point it matters, and a full copy of the spec text is a second version that
drifts. -->

**May decide:**

- <local choice: naming, internal structure, helper design, test layout within the slice>

**Must preserve:**

- <ID>: <the clause that makes it checkable>

## Done when

<!-- Concrete and checkable only: conditions a reviewer can re-verify, and the acceptance criteria
this ticket makes pass, by ID. Every ticket carries at least one AC unless it is enabling work, which
instead names the slice it enables and how it is verified on its own.

Keep each condition binary. A condition with an exception inside it ("zero suppressions, and every
suppression justified") is two conditions or a wrong condition — resolve it here, not in the PR.

When the slice ships a migration, a flag, or anything else that must be undoable, one condition
proves the reversal.

Example conditions:
- [ ] The 6th login attempt within 60 s returns 429 with body {"error": "rate_limited"}
- [ ] A successful login resets the counter
- [ ] `alembic downgrade -1` runs clean against a database migrated by this ticket
- [ ] AC-4 passes against the locked acceptance test, unmodified -->

**Pre-change evidence:**

<!-- What must be observed before the change, so the ticket proves something. Normally: the behavior
test at the approved seam, failing for the expected reason. Name the alternative where a red test
does not apply — a reproduction, a benchmark, a characterization test that passes both before and
after, or a locked acceptance test to run unchanged. -->

- <red test at the seam, or the named alternative>

**Conditions:**

- [ ] <behavioral check>
- [ ] <negative check: what must not happen>
- [ ] <AC-n passes>

**Commands:**

<!-- This ticket's own verification only, each with the outcome that counts as passing. The
repository's canonical test, lint, type, build, and policy commands are run by the Implementer as a
matter of course and must not be copied here — a private copy drifts from CI.

Requires: state what has to be true before these commands run — a service up, a seeded fixture, a
restored snapshot, credentials — since an independent Reviewer reruns them from a fresh worktree.

Example: pytest tests/api/test_rate_limit.py -q   # expect: 4 passed -->

**Requires:** <environment preconditions, or none>

```bash
<command>   # expect: <result>
```

## Escalate instead of guessing if…

<!-- Slice-specific tripwires only. The standing escalation triggers — anything that returns work to
the Plan gate, or settles architecture shared with another ticket — reach the Implementer from
${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md and must not be copied into a ticket, which adds only the
boundaries specific to its own slice.

Example: The limiter would have to key on user identity, which changes the approved seam. -->

- <slice-specific tripwire>
