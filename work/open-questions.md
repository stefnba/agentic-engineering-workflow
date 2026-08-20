# New workflow: our open questions

- What happens when you reject at the Plan gate — back to Discovery, or does the shaping session just
  revise in place?
- What ends a Shape critique loop that isn't converging, instead of looping forever? Review has a
  round limit; critique doesn't. `skills/shape/SKILL.md` now stops after three rounds with blockers
  still open and reports the disagreement to the human — a working default, not a contract:
  `workflow/lifecycle.md` still says nothing about it, and the number is picked to mirror Review.
- Hitting the Review round limit: walkthrough.md now states the ceiling (five, then back to Shape),
  but not the UX — what do you actually see, what do you decide, at four and five?
- reviewer.md settles the _policy_ for a real improvement that doesn't affect acceptance (report it
  separately as a backlog candidate, never a finding), but not the _mechanism_: the Reviewer is
  structurally read-only, so what actually turns its "Backlog candidates" comment into a persisted
  line in `work/backlog.md` — a skill script scraping PR comments, a step inside Land, a manual copy?
- The human can jump into a ticket tab and change the PR branch directly (walkthrough.md), but how is
  that captured for the reviewer — does it show up as a normal commit, does review restart, is it
  documented anywhere?
- What's the abandon/cancel path when a bundle stops partway through? Cancelling a single ticket is
  settled — delete its branch and worktree and it reads as `todo` again — but an abandoned _bundle_
  still needs an owner for deleting the bundle branch and the published bundle path.
- Who resolves a merge conflict between a ticket's PR and the bundle branch — does the implementer
  handle it autonomously, or does it stop and hand back to the human?
- Does a spike run as a bundle with its own ticket and PR, or stay inline in Discover? It has no
  bundle layout, no production code for one-ticket-one-PR to bind, and Land would delete the evidence
  that was the deliverable. (Also open item 4 in `docs-new-review.md`.)
- Should the claim gate know about preconditions that are not ticket edges — a date, an operator
  action, another repo's infrastructure? `depends_on` carries ticket edges only and an external
  blocker may not be stored in the file, so such a ticket reads as claimable on day one.
