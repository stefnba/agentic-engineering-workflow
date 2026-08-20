# Workflow doc review — 2026-08-17, re-verified 2026-08-18

Read-through of the workflow docs, agent prompts, and `bundle-git`. Written against the old
`docs/new/` tree, re-verified against the current layout (`workflow/`, `docs/`, `work/config.conf`).
A second independent pass on 2026-08-18 validated the fixes. Only open items remain here — an item
is pruned once it resolves or is promoted, and git history holds what it said.

Not triaged, not agreed work. Promote items to [backlog.md](backlog.md) as they get accepted.

## Open

### 1. A repeated Plan gate has no write path

Several docs route material drift back to the Plan gate
([lifecycle.md](../workflow/lifecycle.md#3-implement) Implement, [bundle.md](../workflow/bundle.md)
"Escalate to the human") and [artifacts.md](../workflow/artifacts.md) tells the PR to relink to the
newly approved bundle version — but nothing says where a revised bundle gets written
mid-execution. Drafts are tool-local; publication happens once, at the first Plan gate, onto the
integration target. For a
multi-ticket bundle the ticket branches were cut from the bundle branch _before_ the revision, so a
re-approved `spec.md` on the integration target is invisible to every in-flight worktree.

### 6. `work/backlog.md` is a shared write surface across parallel ticket PRs

The Implementer is told to add follow-up work "through the workflow's backlog mechanism"
([implementer.md](../agents/implementer.md), Scope Discipline); Critic and Reviewer both emit backlog
candidates. Every parallel ticket appending to one file is exactly the collision
[bundle.md](../workflow/bundle.md) warns about under "Parallel-safe means more than 'no
dependency'".

Open question #4 asks _who_ persists Reviewer candidates; the wider problem is _where_, without
conflicts. One-file-per-entry, or defer all backlog writes to Land on the bundle branch.

### 7. No staleness/rebase policy for a ticket branch whose base moved

Claim cuts from the base head and nothing revisits it. Open question #7 covers the
conflict-resolution _owner_; nobody owns whether a long-running ticket branch updates its base at
all, or whether "canonical checks pass at the PR head" means anything when the head is 40 commits
behind. Applies to single-ticket bundles off a moving integration target too.

The bundle branch now has exactly such a rule — [Land](../workflow/lifecycle.md#5-land) step 5
merges a moved integration target in before landing. A ticket branch has no equivalent.
