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

## Fixed on 2026-08-19

- **3. Implement and Ship both own reconciliation, separated by one word.** The boundary is now
  stated on both sides: [lifecycle.md](../workflow/lifecycle.md) Implement step 5 adds "everything
  this diff made false or stale, which never defers to Ship", and Ship step 2 reconciles
  "bundle-level knowledge no single ticket owned ... knowledge that only became true once every
  ticket had landed" — the phrasing
  [`skills/shape/templates/plan.md`](../skills/shape/templates/plan.md) already used for the same
  split. [implementer.md](../agents/implementer.md) carries the one operative clause, since punting
  to Ship is the failure mode it has to resist.
- **8. The dependency gate reported `unknown` as "not done".** `claim-ticket.sh` now captures the
  dependency's status and names it — `blocked: ticket 01 is unknown` rather than `is not done` — with
  an empty result from a failed query normalised to `unknown`. The gate is closed either way, which
  it already was; only the message changed. `bundle-git/SKILL.md`'s exit-code list says `3` covers
  `unknown` and that it needs the forge fixed rather than the ticket waited on. Two tests cover it:
  an unmet dependency reports `doing`, and a dependency behind a downed forge reports `unknown`.

## Fixed on 2026-08-18

- **2. Ship made unverified, unreviewed commits.** [lifecycle.md:287-300](../workflow/lifecycle.md#L287-L300)
  now runs eight steps: the pre-check still gates everything, and after reconciliation, backlog
  capture, bundle deletion, and the target merge, step 6 re-runs canonical checks on the state that
  will actually land. The Human authority section says why that means no fourth approval — Ship's own
  commits carry no behavior change and are re-verified before landing.
- **4. Investigation/spike is two different things.** The item's remaining half was "there is still
  no spike bundle layout"; [`skills/shape/templates/spike.md`](../skills/shape/templates/spike.md)
  is that layout. It states the bundle is deleted at Ship and, at
  [line 113](../skills/shape/templates/spike.md#L113), forces the evidence question at Shape rather
  than leaving it to Ship — "decided here, so the result is not stranded in a file Ship deletes",
  with a named owner. The Discover-activity/shaping-route double life is not a contradiction: an
  investigation small enough to run inside Discover needs no bundle, and one that doesn't is shaped
  as a spike bundle.
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
  [`skills/record-decision/templates/decision-record.md`](../skills/record-decision/templates/decision-record.md).
  The workflow docs no longer link it: the `record-decision` skill owns the format. Revised
  2026-08-19 from `Decision` / `Consequences` to `Context` / `Decision` / `Rejected` / `Costs` /
  `Revisit if`, so an unweighed alternative or an unnamed cost is a visibly empty section rather
  than a thin paragraph; the bar the item turns on now sits in
  [artifacts.md](../workflow/artifacts.md) instead of being gestured at. The three records already
  in `docs/decisions/` keep the two-section shape — they are immutable.
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
  Resolved 2026-08-18: the template heads with `# NN — <title>`, and bundle.md's numbering paragraph
  now states that a lone `ticket.md` is number `01` — the number `bundle-status.sh` already assumed.
