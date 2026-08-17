# Git conventions

Branch strategy: bundle-branch
Integration target: main

## Branch naming

- Bundle branch: `bundle/<bundle-id>`
- Ticket branch: `ticket/<bundle-id>/<NN>` — a separate prefix from `bundle/` so it never collides
  with the bundle branch itself.

## Commit messages

Conventional Commits — `type(scope): subject`.

- Types, exactly these seven: feat, fix, refactor, docs, test, chore, ci.
- Subject imperative, lowercase after the colon, ≤ 72 characters.
- Body only when the why isn't obvious from the diff.
- One logical change per commit.

## PR conventions

- **Title**: same shape as a commit subject — `type(scope): summary`, imperative,
  ≤ 72 characters. Squash merge turns the title into the target branch's commit message,
  so this keeps history in one convention rather than two.
- **Merge method**: squash — one commit per PR on its target branch.

## Worktrees

**Location**: `.claude/worktrees/` — the path under it mirrors the branch name.

**Base rule**: a branch is cut from the branch its work will PR into — for bundle work the `bundle-git` skill derives that target; outside a bundle it is the configured integration target (unless an optional Release promotion section below says otherwise).

**Always create with plain git** — never a WorktreeCreate hook, for any worktree: a hook replaces creation globally and silently disables `.worktreeinclude`.

**Bundle branches and worktrees go through the `bundle-git` skill** — it owns their creation, sync, and cleanup, deriving every name from the strategy and location declared here. Worktrees outside a bundle follow the rules above directly.

**Claiming a ticket is creating its branch.** Push the ticket branch to the remote at the head of the branch its PR will merge into, and read the push's porcelain status flag as the verdict: `*` means this push created the branch, so the claim is yours; anything else — `=` (already at that commit) or a plain fast-forward — means another session claimed it first, so stop. Never force-push a claim.

**Bundle-branch creation is race-safe by construction, not by locking.** Fetch first: if `bundle/<bundle-id>` already exists, branch the ticket off it directly. If not, create it from the integration target and push it. If that push is rejected because the ref now exists — another ticket's claim won the race — fetch it and branch off that instead of failing.
