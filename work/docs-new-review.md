# Workflow doc review — 2026-08-17, re-verified 2026-08-18

Read-through of the workflow docs, agent prompts, and `bundle-git`. Written against the old
`docs/new/` tree, re-verified against the current layout (`workflow/`, `docs/`, `work/config.conf`),
and trimmed as items land: fixed and dismissed items are recorded at the bottom rather than kept
above. A second independent pass on 2026-08-18 validated the fixes and reopened one of them.

Not triaged, not agreed work. Promote items to [backlog.md](backlog.md) as they get accepted.

## Open

### 1. A repeated Plan gate has no write path

Several docs route material drift "back to the Plan gate"
([lifecycle.md:177](../workflow/lifecycle.md#L177), [bundle.md:161](../workflow/bundle.md#L161)) and
[artifacts.md:129](../workflow/artifacts.md#L129) tells the PR to relink to "that newly approved
bundle version" — but nothing says where a revised bundle gets written mid-execution. Drafts are
tool-local; publication happens once, at the first Plan gate, onto the integration target. For a
multi-ticket bundle the ticket branches were cut from the bundle branch _before_ the revision, so a
re-approved `spec.md` on the integration target is invisible to every in-flight worktree.

### 3. Implement and Ship both own reconciliation, separated by one word

[lifecycle.md:171](../workflow/lifecycle.md#L171) has the Implementer reconcile durable docs "in the
same PR"; [Ship step 2](../workflow/lifecycle.md#L289) reconciles "_remaining_ bundle knowledge." No
rule says what legitimately defers to Ship. Predictable failure: implementers either duplicate Ship's
work or punt everything to it.

Proposal: the Implementer reconciles whatever its own diff makes false or stale, never deferring
that; Ship reconciles only bundle-level knowledge no single ticket owned.

### 4. Investigation/spike is two different things

[lifecycle.md:104](../workflow/lifecycle.md#L104) makes it a Discover activity;
[shaping-routes.md:62](../workflow/shaping-routes.md#L62) makes it one of five _shaping routes_, and
[walkthrough.md:52](../docs/walkthrough.md#L52) says "shape and run an investigation or spike."

As a route it implies a bundle — but [bundle.md:20-38](../workflow/bundle.md#L20-L38) shows no spike
layout, a spike has no production code so one-ticket-one-PR and independent Review don't obviously
apply, and Ship would _delete the spike's evidence_, which was the entire deliverable.

Ship step 2 does give that evidence a survival path (fold into a decision record), so this is
narrower than "pick one" — but it is nowhere stated, and there is still no spike bundle layout.

### 6. `work/backlog.md` is a shared write surface across parallel ticket PRs

The Implementer is told to add follow-up work "through the workflow's backlog mechanism"
([implementer.md:169-170](../agents/implementer.md#L169-L170)); Critic and Reviewer both emit backlog
candidates. Every parallel ticket appending to one file is exactly the collision
[bundle.md:150-152](../workflow/bundle.md#L150-L152) warns about when judging parallel safety.

Open question #4 asks _who_ persists Reviewer candidates; the wider problem is _where_, without
conflicts. One-file-per-entry, or defer all backlog writes to Ship on the bundle branch.

### 7. No staleness/rebase policy for a ticket branch whose base moved

Claim cuts from the base head and nothing revisits it. Open question #7 covers the
conflict-resolution _owner_; nobody owns whether a long-running ticket branch updates its base at
all, or whether "canonical checks pass at the PR head" means anything when the head is 40 commits
behind. Applies to single-ticket bundles off a moving integration target too.

The bundle branch now has exactly such a rule — [Ship step 5](../workflow/lifecycle.md#L292) merges a
moved integration target in before landing. A ticket branch has no equivalent.

### 8. The dependency gate reports `unknown` as "not done"

[prerequisites.md:21](../skills/setup/references/prerequisites.md#L21) correctly says an unreachable
forge reports `unknown`, never `todo`, and the behavior _is_ fail-closed:
[`ticket-status.sh`](../skills/bundle-git/scripts/ticket-status.sh) writes its error to stderr and
prints nothing to stdout, so the `= done` comparison in
[claim-ticket.sh:36-37](../skills/bundle-git/scripts/claim-ticket.sh#L36-L37) fails on an empty
string. (Its non-zero exit is discarded by the command substitution, so the exit code is not what
saves it.) Only the message lies — it says "blocked: ticket NN is not done" when the truth is
"couldn't tell." Same in [SKILL.md](../skills/bundle-git/SKILL.md)'s exit-code list.

Downgraded from a design hole to a wording fix: report the status that was actually observed, and say
`3` covers `unknown` too.

### 9. Reviewer independence: stated honestly now, still not enforced

Reopened by the second review pass. What landed: Review gained a **Run conditions** paragraph
([lifecycle.md:201](../workflow/lifecycle.md#L201)) like Shape and Implement already had; Reviewer
and Critic gained `tools:` allowlists; the Reviewer confirms the assigned SHA against the forge and
that no tracked file is modified before judging; walkthrough notes the shared worktree.

What did not land: both agents keep `Bash`, because verification and repository reading need a shell,
so nothing structurally prevents a push, approve, or merge. The allowlist withholds file editing and
nothing else. Every prompt and the Run conditions paragraphs now say that plainly instead of claiming
the restriction is structural — but the gap itself needs a hook or a permission rule, tracked in
[backlog.md](backlog.md).

## Fixed on 2026-08-18

- **2. Ship made unverified, unreviewed commits.** [lifecycle.md:287-300](../workflow/lifecycle.md#L287-L300)
  now runs eight steps: the pre-check still gates everything, and after reconciliation, backlog
  capture, bundle deletion, and the target merge, step 6 re-runs canonical checks on the state that
  will actually land. The Human authority section says why that means no fourth approval — Ship's own
  commits carry no behavior change and are re-verified before landing.
- **5. Nothing declared how a bundle branch lands on the integration target.**
  [git-mechanics.md](../workflow/git-mechanics.md) now has a "Landing a bundle" section: merge with
  `--no-ff`, never squash, never rebase, merge a moved target in and re-verify before landing. The
  land is fixed rather than a setting — `TICKET_MERGE_METHOD` is named for its scope, in both config
  files and in the README — because it is what makes "git history preserves the work record; there is
  no shipped-bundle archive" true. The invariant is stated as _the land preserves each ticket's
  commits as they reached the bundle branch_, which does not assume `TICKET_MERGE_METHOD=squash`.
  [lifecycle.md](../workflow/lifecycle.md) Ship steps 5–7 and
  [walkthrough.md](../docs/walkthrough.md)'s Ship bullets both sequence it. Confirmed by an
  independent agent before implementing; the earlier "declare `trunk` instead" fallback died when
  branch strategy became derived, so a repo whose target forbids merge commits now declares a
  different integration target.
- **10. "Read-only" was overloaded.** Read-only binds the change, not the filesystem — build output
  and caches are expected; source, refs, branches, and PR state are not. Stated in Reviewer, Critic,
  and the Run conditions paragraphs.
- **12. Decision records used as a suppression list.** Both
  [artifacts.md](../workflow/artifacts.md) and [walkthrough.md](../docs/walkthrough.md) now split on
  whether a rejection encodes a durable choice: "this stays as it is, because X" earns a record, "not
  worth it now" earns nothing and correctly resurfaces next scan. The missing template exists at
  [`skills/record-decision/templates/decision-record.md`](../skills/record-decision/templates/decision-record.md)
  — `Decision` / `Consequences`, matching the two records already in `docs/decisions/`. The workflow
  docs no longer link it: the `record-decision` skill owns the format.
- **13. Direct push to the integration target was never stated outright.** Folded into 5's
  prerequisites bullet, which now requires a target permitting direct pushes, and merge commits once
  a bundle has more than one ticket, naming the required-review, required-PR, and linear-history
  rules that disqualify a branch.
- `prerequisites.md` had no H1.
- Both `lifecycle.md` ASCII diagrams were misaligned — the Accept connector dangled a column off the
  `fix request` corner, `merge + complete` sat under no branch, and two Review-diagram labels sat off
  their arrows.
- `bundle.md` had a stray mid-sentence line wrap and curly quotes with an unspaced em-dash.
- `git-mechanics.md` credited `bundle-git` with an undefined, unimplemented bundle-branch "sync".
- `walkthrough.md` pointed at `prerequisites.md` for the integration target, which is now
  `INTEGRATION_TARGET` in `work/config.conf`.
- `docs/conventions/git.md`'s PR-title rule said a squash merge writes "the target branch's" commit
  message without noting that a ticket PR targets the bundle branch.

## Dismissed on re-verification

- **11. "No coordinator" is over-stated.** [lifecycle.md:61-62](../workflow/lifecycle.md#L61-L62)
  already states the intended invariant — inner dispatches "carry no product judgment and cannot
  cross a human gate." The contradiction had been edited out. The leftover asymmetry (Shape has no
  round limit, Review does) is open question #2.
- **14. Narrowing is session-bound with no durable record.**
  [walkthrough.md:24-26](../docs/walkthrough.md#L24-L26) scopes its session-independence claim to the
  bundle being in git and status being derived; it never promises the Discover→Shape handoff
  survives. Losing narrowing is real, the over-promise isn't, and the backlog's `/recap` idea already
  covers the symptom.
- **Lone `ticket.md` can't satisfy the template.**
  [ticket.md:7](../skills/shape/templates/ticket.md#L7) heads with `# Ticket: <title>` and no number;
  [bundle.md:51-52](../workflow/bundle.md#L51-L52) scopes numbering to `tickets/`.
