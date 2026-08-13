# Review-fix loop protocol

The one home for the contracts the review-fix loop shares: what the reviewer posts on a PR,
what a fix round posts back, and how any session derives the loop's state from those
artifacts. The reviewer agent, the review skill, and the implement skill's fix mode all key
off this file — they point here and never restate a definition. Procedures (how to review,
how to fix) live in those skills; this file owns only the shared vocabulary and formats.

## Artifacts and markers

Two agent-authored artifact kinds live on a PR, each identified by a marker literal on its
own line, directly above a fenced YAML block:

- `<!-- agentic:verdict -->` — a review's machine-readable verdict.
- `<!-- agentic:fix-round -->` — a fix round's report.

Artifacts are located by marker literal only — never by author, position, timestamp, or
prose scanning; human comments carry no markers and are invisible to parsing. Rounds
increment per verdict, starting at 1; the latest verdict is the marker-bearing review with
the highest `round`, and a fix-round report answers the verdict of the same round number.

The YAML blocks below annotate each field with a `#` comment describing its shape; those comments are notes for the reader, not part of the artifact — a posted block carries only
the data.

A marker whose YAML block does not parse or lacks a required field fails loud: the session
reports what it could not parse and stops — state is never reconstructed from prose, comment
threads, or timestamps. A PR with no verdict marker at all is not an error; it is the
`needs-review` state.

## The verdict

Posted as one PR review per round. The body ends with:

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

Every field except `backlog` is required. The counts (`blockers`, `concerns`, `nits`) count
this verdict's open findings per tier and must match the `findings` list.

**Body composition — the whole-artifact budget.** The review body is, in order: the verdict
counts, the verification result — one line when everything passes, failing lines itemized
otherwise — the details of findings that don't anchor to the diff, and the verdict block.
Nothing else: no grounding narration, no praise of sound areas, no path lists.

**Per-finding budget.** In the block: a title of at most 15 words. The detail — a
line-anchored comment for a finding on a changed line, a body entry under its ID otherwise —
is at most 3 sentences, with evidence as path:line references; quote source only when the
exact wording is the defect. Never restate the diff, never narrate what is correct.

**The `backlog` list** carries pre-existing defects the review noticed outside the change —
they are not findings. The next write-capable session lands them: a fix round copies the
list into the repo's backlog; a PR that goes straight to Accept has them landed at ship's
absorb step.

## Findings: tiers and classes

Every finding carries a **tier** — `blocker | concern | nit` — and the tier decides its
routing:

| Tier      | Meaning                             | What it causes                                             |
| --------- | ----------------------------------- | ---------------------------------------------------------- |
| `blocker` | Must be resolved before Accept      | The only tier that puts the PR into `fixes-pending`        |
| `concern` | Real, but the human rules at Accept | Fix, waive with a stated reason, or route to backlog       |
| `nit`     | Style or polish                     | A fix round may batch-fix while in the code; alone nothing |

Every finding carries a **class** — `mechanical | decision` — assigned by the reviewer
alone:

- `mechanical` — fixable from the finding itself.
- `decision` — needs a human ruling: an ambiguous requirement, an architecture
  disagreement, a conflict with a decision record.

A fix round may escalate a mechanical finding to `decision`, never the reverse, and never
resolves a `decision` finding itself — the human's ruling must be recorded in the bundle or
a decision record before a later round treats it as fixable.

## The fix-round report

Posted as one PR comment after the round's push:

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

Statuses: `fixed | escalated | deferred`. A blocker is `fixed` or `escalated`, nothing
else; `deferred` — left to the human at Accept — is valid only for concerns and nits. Every
open finding ID appears with an explicit status; a finding missing from the report is a
protocol violation the next review flags. The report is the re-review's roadmap and the
human's audit trail — never a state input.

## Loop state

State derives exclusively from the PR's own facts — the latest verdict's `sha` and
`blockers` fields against the PR's current head SHA:

| Condition                                   | State             |
| ------------------------------------------- | ----------------- |
| No verdict on the PR                        | `needs-review`    |
| Verdict `sha` = head SHA and `blockers` > 0 | `fixes-pending`   |
| Verdict `sha` = head SHA and `blockers` = 0 | `awaiting-accept` |
| Verdict `sha` ≠ head SHA                    | `needs-re-review` |

Timestamps, comment-thread structure, ticket frontmatter, and labels are never state
inputs.

## The round cap

The loop caps at 3 fix rounds per PR. Entry into a fourth is refused: the refusing session
reports the unresolved findings and what each round tried, and the human takes over. The
cap never triggers a merge and is never silently continued past.

## Accounts

The protocol is account-agnostic: one verdict artifact per round, same body and block,
whoever posts it. The review's event is presentation chosen at post time — request-changes
when the reviewer authenticates as a non-author account and the verdict carries blockers, a
plain comment review in every other case (GitHub restricts an author reviewing their own PR
to comment) — and is never a state input. Approve is never posted by any account: Accept
belongs to the human.
