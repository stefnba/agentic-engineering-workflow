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
- What stops two independently-unblocked tickets from racing to create the bundle branch if claimed
  around the same time? Discussed direction: make bundle-branch creation self-healing via git's
  atomic ref creation (first push wins; second fetches and rebases onto it) — not yet written into
  git.md.
- What's the abandon/cancel path when a bundle stops partway through — do unclaimed tickets just
  never get opened, and who cleans up the bundle branch and worktrees?
- Who resolves a merge conflict between a ticket's PR and the bundle branch — does the implementer
  handle it autonomously, or does it stop and hand back to the human?
