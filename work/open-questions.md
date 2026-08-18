# New workflow: our open questions

- What happens when you reject at the Plan gate — back to Discovery, or does the shaping session just
  revise in place?
- What ends a Shape critique loop that isn't converging, instead of looping forever? Review has a
  round limit; critique doesn't.
- Hitting the Review round limit: walkthrough.md now states the ceiling (five, then back to Shape),
  but not the UX — what do you actually see, what do you decide, at four and five?
- reviewer.md settles the *policy* for a real improvement that doesn't affect acceptance (report it
  separately as a backlog candidate, never a finding), but not the *mechanism*: the Reviewer is
  structurally read-only, so what actually turns its "Backlog candidates" comment into a persisted
  line in `work/backlog.md` — a skill script scraping PR comments, a step inside Ship, a manual copy?
- The human can jump into a ticket tab and change the PR branch directly (walkthrough.md), but how is
  that captured for the reviewer — does it show up as a normal commit, does review restart, is it
  documented anywhere?
- What's the abandon/cancel path when a bundle stops partway through? Cancelling a single ticket is
  settled — delete its branch and worktree and it reads as `todo` again — but an abandoned *bundle*
  still needs an owner for deleting the bundle branch and the published bundle path.
- Who resolves a merge conflict between a ticket's PR and the bundle branch — does the implementer
  handle it autonomously, or does it stop and hand back to the human?
- How does Ship land the bundle branch on the integration target? `docs/conventions/git.md` declares
  only squash, which would collapse the per-ticket commits that are the whole surviving record once
  Ship deletes the bundle. Suggested: `--no-ff` merge commit, never squash, never rebase; when the
  target has moved, merge it into the bundle branch, re-run the Ship check, then land; a repo that
  forbids merge commits declares `trunk` instead. Invariant and prohibitions go in
  `workflow/git-mechanics.md` (which has no land section at all today), the concrete method in
  `docs/conventions/git.md`. Applies only to multi-ticket under `bundle-branch`.
