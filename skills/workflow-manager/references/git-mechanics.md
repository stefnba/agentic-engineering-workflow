# Git mechanics

The reasons behind each transition. `<target>` is the bundle's integration target, resolved and
checked as `SKILL.md`'s Values section says, and `<ref>` a bundle reference; the raw git commands
sit in the header of `scripts/branch.sh`.

## Principles

- **A bundle lives on its branch.** Its folder is committed on `bundle/<ref>` at shaping time and
  reaches the integration target only through the land, where it is deleted; git history keeps it.
  Nothing about a bundle is ever committed on the target, so abandoning one deletes branches only.
- **Only ticket PRs write to a bundle branch**; the write rule is in `SKILL.md`, Names and markers.
- **A branch is cut from the branch its work will PR into**: a bundle branch from the target, a
  ticket branch from its bundle branch.
- **A rejected push means another session got there first.** Fetch and use theirs; never force.
- **Every conflict stops for the human, except one.** A backlog is written from several branches at
  once by design and both sides belong; resolve a conflict in any `work/backlog.md` by keeping both
  sides, and nothing else without asking.

## Cutting, claiming, completing, abandoning

- `scripts/branch.sh cut <ref> <target>` — needs status `draft`, `<target>` on the remote, no local
  `bundle/<ref>` branch, and no worktree at that path. It prints `cut bundle/<ref> from <target>`,
  then, as its last line, the new worktree's path. The shaping session commits the bundle folder
  there and pushes.
- `scripts/branch.sh claim <ref> <NN>` — needs the bundle `active`, every ticket in the ticket's
  `depends_on` `done`, and the ticket `todo`. The push decides a race: only the session whose push
  created the branch owns the ticket. Its last line is the ticket worktree's path. The ticket's PR
  targets `bundle/<ref>`; its merge through `complete` makes the ticket `done`.
- `scripts/branch.sh complete <pr> <sha>` — the human's Accept of a ticket PR. It refuses a ticket
  branch that lacks the current bundle branch: a sibling merged first, and the two can merge cleanly
  and still be broken, so the base is merged in, re-verified, and reviewed again. It squash-merges
  with `--match-head-commit`, so the forge refuses any head but the accepted one, then removes the
  ticket's worktree and branches.
- `scripts/branch.sh abandon <ref>` — prints every worktree and branch, local and remote, it would
  delete; `--execute` deletes them. Status `unknown` exits 2, because a bundle that may have landed
  must not be deleted blind. On a `landed` bundle it removes leftovers only.

A push that refuses to delete is branch protection or a permissions gap; report it and delete
nothing by other means.

## Landing a bundle

The `land-bundle` skill runs Land. Two mechanics it relies on:

- `scripts/branch.sh check-land <ref> <target>` exits 2 naming any first-parent commit on the bundle
  branch that is not a merged ticket PR's squash commit, a merge of the target, or a `bundle:`
  commit touching only the bundle's own folder and the work folder's `backlog.md`. It runs before
  Land's own commits, which it would name too. Passed a wrong but existing target, it names that
  branch's missing commits as foreign, so a long list of unfamiliar commits means recheck the
  target before anything else.
- The bundle PR merges into the target by squash, so the target carries one commit per bundle. The
  bundle branch's commits stay reachable through GitHub's read-only `refs/pull/<n>/head`, so the
  ticket PRs' permalinks and the bundle PR's own links keep resolving; the bundle PR body is the
  index into them.
