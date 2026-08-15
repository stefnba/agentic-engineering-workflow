# 2026-08-13-review-fix-loop — PR-native review findings and the fix round

## 1. Problem Statement

Review findings return as the reviewer's final chat message. The record dies with the
session, and the conversation that receives it — the same one that authored the diff — ends
up doing the fixes. Each round arrives as unbounded prose: long verification narration,
findings re-trawled from parts of the PR earlier rounds already covered, IDs reused across
rounds for different findings, and only two severity levels to route any of it. Nothing
defines how a finding becomes a fix, and dispatching each stage requires remembering bundle
IDs, ticket numbers, and PR numbers.

## 2. Solution

Review leaves its findings on the PR itself — tiered, capped in length, line-anchored where
they point at changed code — and returns a single line plus the next command to run. A fix
round, run fresh on the PR's branch, reads the findings off the PR, fixes what is mechanical,
escalates what needs a human ruling, and reports per finding on the PR. Any fresh session can
tell where the loop stands from the PR alone; each stage hands the human the exact next
command; re-review checks the fixes and the new commits, not the whole PR again. The human's
Accept gate is unchanged.

## 3. Behavioral Requirements

BR-1: The reviewer delivers findings as one review on the PR: the review body carries the
verdict and a machine-readable verdict block (ID-2), and each finding whose subject is a
changed line additionally carries a line-anchored comment with its detail. Findings never
return as chat prose; the chat return is one line — the verdict counts and the suggested next
command.

BR-2: Every finding carries a tier, and the tier decides its routing. `blocker` — must be
resolved before Accept; the only tier that puts the PR into `fixes-pending`. `concern` — the
human rules at Accept: fix, waive with a stated reason, or route to the backlog. `nit` — a
fix round may batch-fix nits while already touching the code; nits alone never cause a round.
A pre-existing defect outside the change is not a finding: the reviewer records it in the
verdict block's `backlog` list (ID-2), and the next write-capable session lands it — a fix
round copies the list into the repo's backlog; a PR that goes straight to Accept has it
landed at ship's absorb step (existing ship behavior, unchanged).

BR-3: Every finding carries a class, assigned by the reviewer alone: `mechanical` — fixable
from the finding itself — or `decision` — needs a human ruling (an ambiguous requirement, an
architecture disagreement, a conflict with a decision record). A fix round may escalate a
mechanical finding to `decision`, never the reverse, and never resolves a `decision` finding
itself.

BR-4: Review output is budgeted at two levels. Per finding: the verdict-block entry is id,
tier, class, location, and a title of at most 15 words; the detail (line comment, or a body
entry for findings that don't anchor to the diff) is at most 3 sentences, with evidence as
path:line references — quoting source only when the exact wording is the defect, never
restating the diff, never narrating what is correct. Per artifact: the review body is the
verdict counts, the verification result — one line when everything passes, failing lines
itemized otherwise — the non-anchored finding details, and the verdict block; grounding
narration, praise of sound areas, and path lists do not appear.

BR-5: Loop state derives exclusively from the PR's own facts, by SHA: no verdict on the PR →
`needs-review`; latest verdict's SHA equals the head SHA and its blocker count is above zero
→ `fixes-pending`; equals the head SHA at zero blockers → `awaiting-accept`; differs from
the head SHA → `needs-re-review`. Timestamps, comment-thread structure, ticket frontmatter,
and labels are never state inputs.

BR-6: A fix round runs fresh on the PR's branch: it fixes every `mechanical` blocker, may
batch-fix nits, escalates every `decision` blocker, re-verifies (the ticket's affected
done-when lines plus the repo's checks), pushes, and posts one fix-round report (ID-3) giving
every open finding ID an explicit status — a finding missing from the report is a protocol
violation the next review flags; concerns and nits the round didn't target are reported
`deferred`. A fix round pushes only a branch that re-verifies green: a fix that cannot reach
green is dropped and its finding escalated. The round also copies the verdict's `backlog`
list into the repo's backlog. The report is the re-review's roadmap and the human's audit
trail, never a state input. Inference starts a fix round only on blockers; an explicit
invocation may additionally target named concerns or nits at the human's direction (ID-6).

BR-7: Escalations reach the human in the fix round's close-out, and the human's ruling is
recorded in the bundle (a spec amendment) or a decision record — never only in chat — before
any later round treats that finding as fixable.

BR-8: Re-review is scoped: it verifies each finding the fix-round report claims fixed,
reviews the commits added since the last verdict, restates every still-open finding under its
original ID, and raises new findings only from those new commits — each under a fresh ID
never used on this PR before. Sole exception: a blocker-tier defect anywhere in the PR may be
raised late, naming why earlier rounds missed it. Each round runs in a fresh context receiving
the verdict, the fix-round report, and the delta — not the prior reviewer's reasoning.

BR-9: The loop caps at 3 fix rounds per PR. Entry into a fourth is refused: the refusing
session reports the unresolved findings and what each round tried, and the human takes over.
The cap never triggers a merge and is never silently continued past.

BR-10: All three dispatch skills (implement, fix, review) resolve their target without
arguments: from the current branch first — the bundle, ticket, and PR are derivable from a
ticket branch's name — falling back to the single in-progress bundle, and asking when neither
resolves. Mode follows state — for implement: `fixes-pending` → the no-op of BR-11 pointing
at `fix`, otherwise the next unblocked ticket; for fix: `fixes-pending` → a fix round,
`needs-review`, `needs-re-review`, and `awaiting-accept` → the no-op of BR-11 pointing at
`review`; for review: `needs-review` → full review, `needs-re-review` → scoped re-review,
`fixes-pending` and `awaiting-accept` → the no-op of BR-11. An inferred mode is echoed before
acting; explicit arguments always override inference.

BR-11: Every stage close-out prints the fully-qualified next command. Invoking a stage whose
state doesn't call for it — review on an already-reviewed head, implement on a PR awaiting
fixes, a fix round with nothing pending — reports the state and the right next command and
exits without side effects.

BR-12: A verdict marker present with a block that doesn't parse, or that lacks a required
field, fails loud: the session reports what it could not parse and stops. The absence of any
verdict marker is not an error — it is the `needs-review` state (BR-5). State is never
reconstructed from prose, comment threads, or timestamps.

BR-13: The protocol is account-agnostic: one verdict artifact per round, same body and block,
regardless of account. The posting event is presentation chosen at post time — a formal
request-changes review when the reviewer authenticates as a non-author account and the
verdict carries blockers, a plain comment review otherwise (always, for the author's own
account, which GitHub restricts to comment) — and state derivation reads only the verdict
block, never the review's event. Approval is never posted — Accept belongs to the human.

BR-14: While a PR is in the review loop its branch only moves forward — no force-push, no
rewrite of pushed commits; history is squashed at merge where the repo wants it linear. The
rule lives in the per-repo git conventions file, not in the skills.

BR-15: One home per concept: the protocol reference owns the schemas, marker literals, tier
and class vocabularies, state machine, budgets, and cap; the skills and the reviewer agent
point at it and never restate a definition. Marker literals and state names are shared keys a
pointing file may state where its steps branch on them.

## 4. Implementation Decisions

ID-1: The protocol reference lives at `skills/review/references/protocol.md` — review writes
these artifacts, so the review skill owns their definition; the implement skill's dispatch,
the fix skill, and the reviewer agent all point at it.

ID-2: The verdict contract, exact. The review body ends with:

````markdown
<!-- agentic:verdict -->

```yaml
round: 2 # increments per verdict on this PR, starting at 1
sha: <full head SHA reviewed>
blockers: 1
concerns: 1
nits: 0
findings:
  - id: F5 # stable for the finding's life; an ID is never reused on this PR
    tier: blocker # blocker | concern | nit
    class: mechanical # mechanical | decision
    at: src/retry.ts:42 # path:line, or "PR body"
    title: <at most 15 words>
backlog: # optional — pre-existing defects outside this change, one line each,
  - "[skills] <one line>" # in the consuming repo's backlog entry format
```
````

ID-3: The fix-round contract, exact. Posted as one PR comment:

````markdown
<!-- agentic:fix-round -->

```yaml
round: 2 # the verdict round this answers
sha: <full head SHA after the fixes>
findings:
  F5: { status: fixed, commit: <sha> }
  F6: { status: escalated, note: <one line> }
  F7: { status: deferred } # valid for concerns and nits only
```
````

Statuses: `fixed | escalated | deferred`; `deferred` — left to the human at Accept — is
valid only for concerns and nits; a blocker is `fixed` or `escalated`, nothing else.

ID-4: Agent artifacts are located by marker literal only; the latest verdict is the
marker-bearing review with the highest `round`. Rounds increment per verdict; a fix-round
report answers the verdict of the same round number.

ID-5: Line-anchored comments post in the same review call (`gh api` review with a `comments`
array — path, line, side). A finding whose subject line isn't in the diff keeps its detail in
the review body under its ID.

ID-6: Fix is its own skill, `skills/fix/SKILL.md`, run like `implement` (no fork, no
dedicated agent — it edits code on the branch, the same posture as authoring). Explicit form:
`/fix <PR> [F<id> ...]` — trailing finding IDs direct the round at named concerns or nits
beyond the default blocker set. The cap check (BR-9) runs at fix entry.

ID-7: Branch-first resolution, shared by all three dispatch skills: a current branch matching
`<bundle-id>/NN-<slug>` (single-file bundle: `<bundle-id>`) names the bundle and ticket, and
the branch's open PR is the PR. On the default branch, resolve the bundle first — exactly one
in the in-progress tree, else exactly one shaped, else ask — then the PR: exactly one open PR
on the bundle's branches drives mode inference; several → ask, listing each with its state;
none → each skill's own fallback (implement: the next unblocked ticket; fix: report nothing
pending and stop; review: report nothing to review and stop).

ID-8: The verdict review's event: request-changes when posted by a non-author account with
blockers above zero, comment in every other case; same body, same block, one artifact per
round. The event is never a state input. Approve is never posted by any account.

ID-9: The cap constant is 3 fix rounds, stated once, in the protocol reference.

ID-10: The reviewer's chat return is
`<b> blockers, <c> concerns, <n> nits on PR #<N> → next: <command>`. The Claim/Evidence/Break
entry format is retired; its content maps into the 3-sentence detail budget.

ID-11: Verification evidence placement is unchanged: implement's verify results stay in the
PR body as built. With findings settled onto the PR, this closes the promoted backlog line's
open question.

ID-12: The workflow doc's review stage row and loop description name the four states and
PR-hosted findings in stage-level prose only; no schema, marker, or budget appears there.

ID-13: The forward-only-history rule (BR-14) lands in the setup skill's git conventions
template and this repo's own instantiated conventions file — both created by the
2026-08-13-git-conventions-file bundle, which ships before this bundle implements (sequencing
settled at shaping).

## 5. Testing Decisions

Seam: the document text of the protocol reference, the three skills, the reviewer agent, the
workflow doc, and the git conventions template — every acceptance criterion is a
grep-checkable assertion against these files at rest.

Good tests here pin exact contracts — marker literals, tier/class/state vocabularies, the cap
value — and the one-home rule, never paraphrases. Live loop behavior (whether a real review
run posts a well-formed verdict) is not observable at this seam; it follows the repo's
skill-testing convention (the writing-for-agents testing reference) and is tracked as backlog
lines added at ship. Prior art: the grep-based done-when style of the
2026-08-13-git-conventions-file bundle.

## 6. Acceptance Criteria

AC-1 (BR-2, BR-3, BR-5, BR-9): Given the shipped tree, when reading the protocol reference,
then it contains both marker literals, the three tiers, the two classes, all four state
names, the cap value, and both YAML contracts exactly as ID-2/ID-3 state them.

AC-2 (BR-15): Given the shipped tree, when grepping `skills/`, `agents/`, and `docs/` for the
enumeration strings `blocker | concern | nit` and `mechanical | decision`, then each appears
in exactly one file, the protocol reference. (The state derivation's one home is judged at
review per BR-15 — state names are shared keys and not grep-gateable.)

AC-3 (BR-1, ID-10): Given the reviewer agent's document, when read, then it instructs posting
the verdict as a PR review and returning the one-line chat verdict with next command, and
`grep -c "Claim:"` over it returns 0.

AC-4 (BR-4): Given the protocol reference, when read, then both budget levels are stated: the
15-word title and 3-sentence detail caps, and the review-body composition rule (counts,
one-line verification result with only failures itemized, non-anchored details, verdict
block — nothing else).

AC-5 (BR-6, BR-7, BR-9, ID-6): Given the fix skill, when read, then it points at the protocol
reference, refuses a fourth fix round, and requires escalation rulings recorded in the bundle
or a decision record before continuing.

AC-6 (BR-10, BR-11, BR-12): Given each of the three dispatch skills (implement, fix, review),
when read, then it states branch-first zero-argument resolution, the echo of an inferred mode
before acting, the next-command close-out, the no-op behavior for a state that doesn't call
for it, and the stop on a malformed verdict block.

AC-7 (BR-8): Given the review skill and reviewer agent, when read, then re-review is scoped
as: verify claimed fixes, review only the delta commits, restate open findings under original
IDs, new findings from the delta only under never-reused IDs, with the late-blocker exception
requiring a stated reason.

AC-8 (BR-13, ID-8): Given the protocol reference, when read, then the account rules are
stated — request-changes mirror on blockers for a distinct account, approve never posted —
and the reviewer agent retains its never-approve instruction.

AC-9 (BR-14, ID-13): Given the setup skill's git conventions template and this repo's
`docs/agents/git.md`, when grepped, then both contain the forward-only/no-force-push rule for
branches in the review loop.

AC-10 (ID-12): Given the workflow doc, when read, then it names the four loop states and
PR-hosted findings, and `grep -c "agentic:verdict"` over it returns 0.

## 7. Out of Scope

- No orchestrator: the human dispatches every round; an auto-looping skill is a later
  feature.
- No bot-account or GitHub App setup automation — the distinct-account path is documented
  behavior, not built tooling.
- No CI ownership of verification (existing backlog line stands).
- No abandoned-ticket or cancelled-bundle failure paths (backlog line stands, trimmed).
- No parallel or multi-axis critics (existing backlog line stands).
- No glossary entries for protocol vocabulary — the protocol reference and workflow doc own
  it.
- No changes to the critique, judge, shape, or ship skills.
- No findings files in the repo and no mirroring of findings into `work/` — the PR is the
  only findings home.
- No edits to decision 0015 or to the 2026-08-13-git-conventions-file bundle.
- No worktree isolation for implement or fix — an orthogonal concern owned by the future
  `ticket-runner` bundle (parallel ticket execution, tracked in
  `work/skills-build-plan.md`).
