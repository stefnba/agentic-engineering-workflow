# Running the workflow

A practical walkthrough of using the workflow day to day: which skill you run, which session or tab
it runs in, and what you do at each handoff. Five stages: Discover, Shape, Implement, Review, Ship.

**You dispatch stages by hand.** Everything inside a stage — critique after a Shape draft, review
after a PR opens, the fix-and-re-review loop — runs automatically once you've started the stage; you
don't separately trigger those substeps.

## How you run this

There's no orchestration tooling beyond skills, subagents, worktrees, and git. Two kinds of chat session
typically carry the whole workflow:

- **One long-lived session per bundle.** Runs Discovery and Shape, and later Ship. Its
  working directory stays on the integration branch the whole time — it never checks out a ticket
  branch itself.
- **One chat session tab per ticket, each cd'd into that ticket's own worktree.** Opened only once the
  ticket's dependencies are `done`; independent tickets can have tabs open in parallel. Runs
  Implement; Review is dispatched from inside this same tab as a fresh subagent (see Review below).

Keeping the shaping session open is convenient, not required — bundle and ticket state live in files
and git, not in a session's memory, so `/ship` works fine from a fresh session too.

Babysitting tabs doesn't scale past a few at once — treat that as a real constraint on how many
tickets you shape into one parallel wave, not just an inconvenience.

## Discovery

**Entry point — how you arrive at something to work on:**

- **Backlog pick** — `/pick` a one-line backlog item.
- **Codebase scan** — run `/scan-codebase` for full or narrow findings. Results
  appear inline in chat only, never written to a file. Triage each finding right there: accept it
  (→ backlog line, title plus a short breadcrumb) or reject it with a reason (→ decision record
  under `docs/decisions/`, so the next scan doesn't resurface it).
- **Fresh idea** — anything you bring yourself; no different from a backlog pick once it's out loud.

**Narrowing — almost every entry point still needs this.** A backlog line is a title, not a settled
intent. Run `/interview-me` in the same session and keep going until you and the agent share an
understanding of the problem, desired outcome, and edge cases. This stays conversational and
produces no file — `/shape` is the first thing that writes anything durable. Skip the interview only
when the pick was already fully settled and unambiguous going in; treat that as the rare case, not
the default.

Once you've reached shared understanding, trigger `/shape` in that same session.

## Shape

Triggered once, by `/shape`, in the shaping session. Everything after that is automatic:

1. Agent picks the shaping route (direct ticket / spec + tickets / spec + plan + tickets /
   sequential bundles) based on uncertainty and impact, and states why.
2. Drafts intent, plan (when the route calls for one), and tickets.
3. Auto-dispatches a fresh-context critique; revises and re-critiques until no blocker remains.

You then get: a brief summary of what will be built, the ticket list with sequencing (what's serial,
what's safe to run in parallel), and one paste-ready opening prompt per currently unblocked ticket
(worktree path included).

**Plan gate:** you approve. The bundle commits directly to the integration branch — no PR. Critique
plus your approval already are the review step for a planning artifact; a PR on top of that adds
ceremony without adding a gate.
Only open a ticket's tab once every ticket it depends on is `done`. Tickets with no dependency
between them can run in tabs side by side.

- Same implementation session kicks off review agent to review with prompt to specifally work on that PR and review diff
  - review agent posts comment in structured format based on template into PR
    - Blockers
    - Concerns
  - also returns summary back to implementation
  - Mayebe we even do review based on two axes like mattpott skills (does it meet spec? and does it meet codebase requirement and conventions?)
- Same implementation sessions validates these findings (tbd if that is good practice) and fixes blockers and maybe concerns too?
- Once done, posts fixes done to PR and starts new review session
  - Starts from beginning
  - Max 3 loops for now
- Implemenation session gives final summary of what was built and fixes and recommends view

- Users reviews the PR and diff in detail and would either a) call a /complete-ticket skill to merge the PR into target branch or b) merges PR themselves

**Open question**:

- What if users wants to make some changes themselves (minor or major changes)?

## Ship

## Open questions

- What happens when you reject at the Plan gate — back to Discovery, or does the shaping session just
  revise in place?
- What ends a critique loop that isn't converging, instead of looping forever?
- What does hitting the review round limit actually look like for you — what do you see, what do you
  decide?
- Does `/complete-ticket` merge directly, or only prepare the merge for you to confirm?
- How can the human do changes to a PR branch for a ticket. how is that handled with review and documenated?
