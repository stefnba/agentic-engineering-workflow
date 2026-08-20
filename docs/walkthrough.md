# Running the workflow

A practical guide to using the workflow day to day: which skill you run, where you run it, and what
happens at each handoff. It describes the flow; it doesn't define it. Every rule it touches is owned
by a document under [`workflow/`](../workflow/) and linked at the point it applies — when the two
disagree, the linked document is right.

Five stages: Discover, Shape, Implement, Review, Land.

**You dispatch stages by hand; each stage's inner loop runs itself.** You start Discovery, Shape,
each ticket, and Land. You don't separately trigger the critique after a Shape draft or the
review-fix rounds after a PR opens — those are dispatched by the stage you already started.

## How you run this

There's no orchestration tooling beyond skills, subagents, worktrees, and git. In practice you'll
have two kinds of tab open:

- **One long-lived session for the bundle.** Runs Discovery and Shape, and later Land. It stays on
  the integration target and never checks out a ticket or bundle branch — Land cuts itself a
  throwaway worktree instead. You can close it and come back later from a fresh session — the bundle
  is in git and every status is derived, so nothing lives only in that conversation.
- **One tab per ticket**, each `cd`'d into that ticket's own worktree. Runs Implement, and dispatches
  its own Review rounds. Tickets with no dependency between them can have tabs open side by side.

Each ticket tab needs you in it, which is the real limit on how wide a parallel wave is worth
shaping. [Lifecycle](../workflow/lifecycle.md) defines this session model;
[Work bundles](../workflow/bundle.md) covers the parallelism ceiling.

## Discovery

**Entry point — how you arrive at something to work on:**

- **Backlog pick** — `/pick` a one-line item from `work/backlog.md`.
- **Codebase scan** — `/scan-codebase` for full or narrow findings. Results appear inline in chat,
  never in a file. You triage each one right there: accept it into the backlog, or reject it.
- **Fresh idea** — anything you bring yourself; no different from a backlog pick once it's out loud.

**Narrowing — almost every entry point still needs it.** A backlog line is a title, not a settled
intent. Run `/interview-me` in the same session and keep going until you and the agent share an
understanding of the problem, the outcome you want, and the edge cases. This stays conversational and
writes nothing — `/shape` is the first thing that produces a file. Skip it only when the pick was
already fully settled going in; treat that as rare (see Narrowing in
[Lifecycle](../workflow/lifecycle.md)).

If narrowing leaves feasibility or diagnosis genuinely unknown, don't force it — shape and run an
investigation or spike first (see [Shaping routes](../workflow/shaping-routes.md)). Its evidence
becomes the next thing you pick, not a shortcut into Shape.

Once you share an understanding, trigger `/shape` in that same session.

## Shape

Triggered once, by `/shape`, in the bundle's session. Everything after that runs on its own:

1. The agent picks a shaping route and tells you which one and why — the route decides whether you
   get a spec, a plan, or just tickets ([Shaping routes](../workflow/shaping-routes.md) owns the
   choice).
2. It drafts those artifacts.
3. It dispatches a fresh-context critique, then revises and re-critiques until nothing blocking
   remains.

What comes back to you: a summary of what will be built, the ticket list with its sequencing — what's
serial, what's safe in parallel — and one paste-ready opening prompt per currently unblocked ticket,
worktree path included.

**Plan gate — you approve.** This is the point where the outcome, the decomposition, and the test
strategy become binding; [Lifecycle](../workflow/lifecycle.md) lists what you're signing off on. On
approval the bundle is committed straight to the integration target, without a PR
([Work bundles](../workflow/bundle.md) explains why that's enough review for a planning artifact).

## Implement (per ticket)

For each ticket you're ready to start, open a new tab and paste its opening prompt. That prompt
claims the ticket, which creates its branch and worktree; the tab then runs the implementation skill,
which builds the ticket including tests, runs its checks, and opens a PR with a summary.

Which branch it's cut from and which branch its PR targets both follow from the bundle's shape — a
single-ticket bundle works directly against the integration target, a multi-ticket bundle gets a
bundle branch that every ticket PR merges into. [Work bundles](../workflow/bundle.md) has the mapping
and [Git mechanics](../workflow/git-mechanics.md) the mechanics; you don't declare any of it.

Only open a ticket's tab once every ticket it depends on is `done`.

## Review → fix loop

From the same ticket tab, the implementation session dispatches review as a fresh subagent. It shares
no message history with the implementer, so it judges independently — but it does share the tab's
worktree, so it first confirms it's looking at the exact PR head with nothing uncommitted, and stops
rather than review unpushed work. Then, without you:

- The reviewer posts its findings to the PR and returns a summary to the tab.
- The implementer works through them: it fixes, or rebuts with evidence, or escalates anything that
  would need a planning decision. Not every finding must be fixed — some are risks that carry forward
  for you to accept at merge time ([Lifecycle](../workflow/lifecycle.md) defines the two kinds).
- It posts a fix summary at the new head, which kicks off the next round. The loop is bounded; if it
  can't converge, it reports that to you instead of grinding
  ([Lifecycle](../workflow/lifecycle.md) has the limits).

Because you're in that tab's conversation the whole time, you can jump in and steer or fix things
yourself at any point — nothing about this loop locks you out.

**Accept gate — you review the PR and diff yourself, then merge**, directly or via
`/complete-ticket`. The merge is the whole record: the ticket reads as `done` because its PR is
merged, and nothing writes a status afterward.

## Land

Once every ticket is `done`, go back to the bundle's session (or a fresh one) and trigger `/land`. It
runs in order, and stops if the first step isn't green:

- confirms the checks pass on the state holding every merged ticket
- opens a throwaway worktree on the integration target and merges the bundle into it — everything
  below happens there, so a check that fails at the end costs you a directory, not a rescue
- folds anything durable — system behavior, decisions — into the docs that own it
- captures unfinished or newly discovered work as backlog lines
- deletes the bundle, so what lands carries no planning record with it
- re-verifies, then publishes that state on the integration target
- removes the branches and worktrees that are left

If somebody else pushes while you're landing, `/land` merges their work in and sends you back to
re-run the checks before it will publish. Expect to see that; it isn't a failure.

Land in [Lifecycle](../workflow/lifecycle.md) has the exact steps and which of them a single-ticket
bundle skips; [Git mechanics](../workflow/git-mechanics.md) has the land rules.
