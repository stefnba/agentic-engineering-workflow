<!--
The implementation PR's body: the whole handoff from Implement to Review, and — because Land deletes
the bundle — the permanent bridge from a landed line of code back to the planning record that
approved it.

${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md owns the handoff contract; these sections are that
contract's five elements in the order a reviewer needs them. Nothing here is optional, and a section
with nothing to say says "none" rather than disappearing — an absent Reconciled section reads as an
oversight, "None" reads as a claim someone can check.

Bullets, not prose. Everything below the opening sentence is a list or a labelled line, one fact
per bullet. A paragraph in this body is nearly always the bundle restated back to a reviewer who
has the bundle, and the whole body is read at a gate a human passes in about a minute.

Fill it, delete these guidance comments, and pass it as a file: `gh pr create --body-file <path>`.
A body assembled inline mangles fences and lists.

Keep it current. When a fix round moves the head, the SHA and the verification results below move
with it; a body describing an older head is the dishonest evidence the Reviewer is told to treat as
a blocker.

The title is not part of this file — ${CLAUDE_SKILL_DIR}/templates/pr-title.md owns it.
-->

<!-- One sentence, above every heading: what is true once this merges. It is the first thing a human
sees at the Accept gate and, with the title, all a reader gets years from now without opening the
diff. Not a restatement of the title — the title says what changed, this says what it means.

One sentence means one, under about 25 words: no em-dash aside, no semicolon chain, no list of the
parts. Everything it makes you want to append is Delivered's job, one bullet each.

Example: A human can ask any session where it stands and get one message back, recalled from the
conversation alone.
Not: … and get one message back — subject, digest, what is settled, what is open, and the gate that
is due — recalled from the conversation alone, with nothing read, run, or written. -->

<one sentence: what is true once this merges>

## Ticket

<!-- Do not write these three lines by hand. Run, from this worktree:

    ${CLAUDE_PLUGIN_ROOT}/skills/bundle-git/scripts/pr-links.sh <bundle-id> <NN>

and paste what it prints. It pins both links to the commit that published the approved bundle on the
integration target, for two reasons that are easy to miss by hand. That commit is the state the Plan
gate bound — this branch's copy also carries reconcile amendments no human approved. And it stays
reachable through ordinary history: under the default squash merge, this branch's own commits never
reach the bundle branch, so a link pinned to one survives only on forge-specific retention of the
pull request. A `/blob/<branch>/…` link is worse again — it breaks outright once Land deletes the
branch.

Both links point at the same file on the direct ticket route: that is correct, not a mistake to work
around. If the Plan gate was repeated mid-flight, rerun the script — it resolves to the newly
approved version. -->

- Bundle: [`<bundle-id>`](<permalink to the bundle directory>)
- Ticket: `<NN>` — [`<path within the bundle>`](<permalink to this ticket's file>)
- Base: `<branch this PR merges into>`

## Delivered

<!-- What is observably true when this merges that was not true before, one bullet per fact, present
tense, so a reviewer can judge fit without opening the spec and then check it against the IDs.
Facts, not narration: not how you built it, not the order you did it in, not the ticket's plan.

Three to six bullets. Needing more than that is a signal the ticket was too big; needing a paragraph
is a signal you are describing the design rather than the outcome, and the diff already has it.

Example:
- Login is throttled at five attempts per 60 s per IP; the sixth returns 429.
- The limits are config values rather than literals, so changing them needs no deploy.
- Sessions, password reset, and the admin API behave exactly as before. -->

- <what is now true>

**Satisfies:** <BR-2, INV-1, AC-4 — the ticket's Delivers line>

<!-- Touch points: not the file list, which the diff already shows — whether the diff stayed inside
the ticket's Scope, which only the ticket says. Scope is the expected landing zone and it licenses
going outside for required tests, reconciliation, and clearly justified local support work, so name
where you went outside and why. "As the ticket's Scope" is a complete and checkable answer; a
reviewer reading it against the changed-files list can tell in one pass whether the slice held.

Example: As the ticket's Scope, plus `src/config/index.ts` — the limits had to be config values
rather than literals, per the ticket's Implementation notes. -->

**Touch points:** <as the ticket's Scope | as the ticket's Scope, plus `<path>` — <why>>

<!-- Corrections: every factual correction you made to the bundle — a path that had moved, a claim
that no longer held. Lifecycle requires the correction to be visible in the PR, and buried in the
diff is not visible. One line each, in the form <what the bundle said> → <what is true>, plus where
it is now recorded. "None." is the common answer and a checkable one.

A correction that changed behavior, decomposition, or acceptance criteria does not belong here at
all: that one went back to the Plan gate before you wrote a line.

Example: BC-2 cited `src/api/login.ts` → the file had moved to `src/api/routes/login.ts`; the
ticket's Scope is amended in this branch. -->

**Corrections:** <none | one line each, below>

## Verification

<!-- Run at the head named below, and reported as results rather than as a claim that it passed: the
Reviewer reruns every one of these, and a mismatch is a blocker. List the ticket's own Done when
commands and the repository's canonical checks — test, lint, type, build.

State the preconditions the ticket's Requires line names. An independent Reviewer reruns these from
a fresh worktree, and a command that silently needs a seeded fixture fails for them and not for you.

Example:
- `pytest tests/api/test_rate_limit.py -q` → 4 passed
- `pytest -q` → 312 passed, 0 failed
- `ruff check . && mypy src` → clean -->

**Head:** `<sha>` · **Requires:** <preconditions, or none>

<!-- Pre-change evidence is the ticket's own line, and it is the one result in this body a Reviewer
cannot reproduce: at this head the code is already there, so a red test is green and a reproduction
no longer reproduces. If it is not recorded here it is gone, and nothing left in the PR proves the
ticket tested anything. Name the command, the commit it ran at, and what it showed — the failure
reason, not just "failed". Where the ticket named an alternative to a red test, that alternative
goes here instead, in the same shape.

Example: `pytest tests/api/test_rate_limit.py -q` at 3f2a1c9 → 4 failed, `AttributeError: no
attribute 'rateLimit'` — no limiter existed. -->

**Pre-change:** <command> at `<sha>` → <what it showed>

- <command> → <result>

## Reconciled

<!-- Every document this diff made false, and what it now says. Reconciliation is half of what Review
judges, and it is invisible in a diff full of source changes unless it is listed.

Colocated READMEs, glossary entries this change renamed or redefined, the spec where implementation
corrected it, and remaining tickets this one invalidated. What no single ticket owned is Land's, and
saying so here is how Land knows it was a decision rather than an omission.

"None — this diff made no document stale" is a valid entry, and a checkable one. -->

- `<path>` — <what changed there and why this diff made it necessary>

## Limitations and residual risk

<!-- What you know is not covered, and what could still go wrong — including anything you could not
verify and why. This is where honesty is cheapest and its absence is most expensive: a limitation
the Reviewer discovers unlisted reads as concealment, one you list is just scope.

Not a place to pre-empt findings or to reopen the ticket's own exclusions — those are in the ticket's
Not in this ticket, and repeating them here pads the body a human has to read at the Accept gate.

"None known." is a valid entry. -->

- <limitation, or what could not be verified and why>
