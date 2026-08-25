# New workflow: our open questions

- What happens when you reject at the Plan gate — back to Discovery, or does the shaping session just
  revise in place?
- What ends a Shape critique loop that isn't converging, instead of looping forever? Review has a
  round limit; critique doesn't. `skills/shape-bundle/SKILL.md` now stops after three rounds with blockers
  still open and reports the disagreement to the human — a working default, not a contract:
  `workflow/lifecycle.md` still says nothing about it, and the number is picked to mirror Review.
- Hitting the Review round limit: `finding-rules` states the ceiling (five, then back to Shape),
  but not the UX — what do you actually see, what do you decide, at four and five?
- reviewer.md settles the _policy_ for a real improvement that doesn't affect acceptance (report it
  separately as a backlog candidate, never a finding), but not the _mechanism_: the Reviewer is
  structurally read-only, so what actually turns its "Backlog candidates" comment into a persisted
  line in `work/backlog.md` — a skill script scraping PR comments, a step inside Land, a manual copy?
