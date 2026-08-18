# Review of `docs/new/` — 2026-08-17

Read-through of all 14 files under [docs/new/](../docs/), plus
[docs/agents/git.md](../docs/agents/git.md) and [skills/bundle-git/SKILL.md](../skills/bundle-git/SKILL.md).
The workflow is a first draft with known gaps — everything below is deliberately *outside* what
[docs/new/open-questions.md](open-questions.md) and [work/backlog.md](backlog.md)
already track, except where noted.

Not triaged, not agreed work. Promote items to the backlog as they get accepted.

## Real holes

### 1. A repeated Plan gate has no write path

Several docs route material drift "back to the Plan gate"
([workflow.md:163](../workflow/lifecycle.md#L163), [bundle.md:161](../workflow/bundle.md#L161)) and
[artifacts.md:122](../workflow/artifacts.md#L122) tells the PR to relink to "that newly approved
bundle version" — but nothing says where a revised bundle gets written mid-execution. Drafts are
tool-local; publication happens once, at the first Plan gate, onto the integration target. For a
multi-ticket bundle the ticket branches were cut from the bundle branch *before* the revision, so a
re-approved `spec.md` on the integration target is invisible to every in-flight worktree, and to the
claim script reading `depends_on`.

This is the design gap behind the unimplemented "sync" the backlog already notes as a skill gap.

### 2. Ship makes unverified, unreviewed commits and calls it "no fourth approval"

[workflow.md:266-274](../workflow/lifecycle.md#L266-L274) confirms checks at step 1, *then* writes
durable docs, backlog entries, and the bundle deletion at steps 2–4, then lands the result. Those
commits didn't exist when the gate ran, get no Review round, and get no Accept — yet the stage table
claims Ship's exit authority is "prior Accept gates." Ship reconciliation can be substantial (system
docs, decision records).

Either re-verify after step 4, or say plainly that Ship's own output is trusted and why.

### 3. Implement and Ship both own reconciliation, separated by one word

[workflow.md:159](../workflow/lifecycle.md#L159) has the Implementer reconcile durable docs "in the
same PR"; Ship step 2 reconciles "*remaining* bundle knowledge." No rule says what legitimately
defers to Ship. Predictable failure: implementers either duplicate Ship's work or punt everything
to it.

### 4. Investigation/spike is two different things

[workflow.md:101](../workflow/lifecycle.md#L101) makes it a Discover activity;
[shaping-routes.md:63](../workflow/shaping-routes.md#L63) makes it one of five *shaping routes*, and
[walkthrough.md:49](../docs/walkthrough.md#L49) says "shape and run an investigation or spike."

As a route it implies a bundle — but [bundle.md:23-38](../workflow/bundle.md#L23-L38) shows no spike
layout, a spike has no production code so one-ticket-one-PR and independent Review don't obviously
apply, and Ship would *delete the spike's evidence*, which was the entire deliverable.

Pick one: Discover activity with chat/backlog/decision-record output, or a real bundle shape with
defined Ship semantics.

### 5. Nothing declares how a bundle branch lands on the integration target

[docs/agents/git.md](../docs/agents/git.md) declares squash for PRs only. If Ship step 5 squashes,
per-ticket history collapses — contradicting [workflow.md:276](../workflow/lifecycle.md#L276) "Git
history preserves the work record; there is no shipped-bundle archive," which is the stated
justification for having no archive at all. If it merges, say so in `git.md`.

### 6. `work/backlog.md` is a shared write surface across parallel ticket PRs

The Implementer is told to "report unrelated work through the repository's backlog mechanism"
([implementer.md:45](../agents/implementer.md#L45)); Critic and Reviewer both emit backlog
candidates. Every parallel ticket appending to one file is exactly the collision
[bundle.md:150-152](../workflow/bundle.md#L150-L152) warns about when judging parallel safety.

Open question #4 asks *who* persists Reviewer candidates; the wider problem is *where*, without
conflicts. One-file-per-entry, or defer all backlog writes to Ship on the bundle branch.

### 7. No staleness/rebase policy for a ticket branch whose base moved

Claim cuts from the base head and nothing revisits it. Open question #7 covers the
conflict-resolution *owner*; nobody owns whether a long-running ticket branch updates its base at
all, or whether "canonical checks pass at the PR head" means anything when the head is 40 commits
behind. Applies to single-ticket bundles off a moving integration target too.

### 8. The dependency gate has no `unknown` branch

[prerequisites.md:14](../skills/setup/references/prerequisites.md#L14) correctly says an unreachable forge reports
`unknown`, never `todo`. But claim's contract ([workflow.md:67](../workflow/lifecycle.md#L67)) is
"check that every dependency is `done`" and `claim-ticket.sh` exposes only exit 3 "blocked by an
unfinished dependency." Fail-closed is surely intended — nothing says it.

## Smells

### 9. Reviewer independence is asserted but the described mechanism doesn't deliver it

[reviewer.md:3-5](../agents/reviewer.md#L3-L5) demands write/approve/merge capability be
withheld "structurally," while [walkthrough.md:91](../docs/walkthrough.md#L91) dispatches Review
as a subagent from the implementer's tab, cwd'd into the implementer's worktree. Fresh context ≠
restricted tools, and nothing pins the reviewer to the PR head SHA rather than a possibly-dirty
local worktree — even though "reviewed head SHA" appears in the output contract five times. Every
agent doc says "enforce with tools or hooks, not only this prompt" and none names the mechanism.

### 10. "Read-only" is overloaded to the point of self-contradiction

[reviewer.md:3](../agents/reviewer.md#L3) grants "read-only repository and PR access **plus
permission to run verification commands**." Running a test suite writes build caches, temp files,
sometimes migrations. Split the concept: no source/PR-state writes vs. no filesystem writes.

### 11. The "no coordinator" claim is over-stated

[workflow.md:33-35](../workflow/lifecycle.md#L33-L35) says there's "no standing system that watches
state and reacts on its own," then lines 48–59 describe a script that runs Critic→Architect→Critic
and Reviewer→Implementer→Reviewer loops with round counting. That *is* orchestration; the real (and
good) invariant is "no autonomous product judgment, cannot cross a human gate." Say that instead —
as written, someone implementing the skills gets contradictory guidance.

Related: the Shape loop has no round limit while Review has one (open question #2). That asymmetry
is what makes the framing feel strained.

### 12. Decision records are being used as a suppression list

[walkthrough.md:38-39](../docs/walkthrough.md#L38-L39) writes a rejected scan finding to
`docs/decisions/` "so the next scan doesn't resurface it."
[artifacts.md:17](../workflow/artifacts.md#L17) defines that artifact as "which durable,
consequential choice was made and why," and they're immutable. "We looked at this lint nit and
passed" isn't that.

Separately: decision records appear in the authority table, in Ship, and in scan triage, but
`docs/new/` has no template and no owning doc for them — the only artifact in the table with that
gap.

### 13. The workflow requires direct push to the integration target and never says so outright

Bundle publication is "no PR" ([walkthrough.md:70](../docs/walkthrough.md#L70)) and
single-ticket Ship commits the deletion straight to the target.
[prerequisites.md:6-8](../skills/setup/references/prerequisites.md#L6-L8) implies it via the protected-branch
workaround; it's worth one explicit line, since "all changes go through a PR" is a common org policy
that this workflow cannot satisfy for its own artifacts.

### 14. Narrowing is session-bound with no durable record

[walkthrough.md:25-27](../docs/walkthrough.md#L25-L27) advertises session-independence. That
claim is true for Ship and status but false for the Discover→Shape handoff: `/interview-me`
"produces no file," so losing the tab before `/shape` loses the whole narrowing. Probably
acceptable — just scope the session-independence claim so it doesn't over-promise. The backlog's
`/recap` idea mitigates the symptom; the over-broad claim in walkthrough.md is separate.

## Nits

- Lone `ticket.md` has no number, but [templates/ticket.md:11](../skills/shape/templates/ticket.md#L11)
  mandates `# NN — <title>`. Direct-ticket bundles can't satisfy the template.
- [prerequisites.md](../skills/setup/references/prerequisites.md) is the only doc with no H1.
- Both ASCII diagrams in `workflow.md` are misaligned —
  [line 10](../workflow/lifecycle.md#L10)'s connector dangles a column off the `fix request` corner,
  and in the Review diagram [line 208](../workflow/lifecycle.md#L208) `merge + complete` sits under
  no branch.
- [bundle.md:167-168](../workflow/bundle.md#L167-L168) has a stray mid-sentence line wrap ("This
  section owns how bundle / and ticket branches…").
- [bundle.md:150](../workflow/bundle.md#L150) uses curly quotes and an em-dash without spaces where
  the rest of the file uses straight quotes and spaced dashes.
