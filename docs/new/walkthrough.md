# Running the workflow

A practical walkthrough of using the workflow day to day: which skill you run, which session or tab
it runs in, and what you do at each handoff. Five stages: Discover, Shape, Implement, Review, Ship.

**You dispatch stages by hand.** Everything inside a stage — critique after a Shape draft, review
after a PR opens, the fix-and-re-review loop — runs automatically once you've started the stage; you
don't separately trigger those substeps.

## How you run this

There's no orchestration tooling beyond skills, subagents, worktrees, and git. Two kinds of chat session
typically carry the whole workflow. "Integration target" below means your declared integration
target branch (see [Prerequisites](./prerequisites.md)) — usually the repo's default branch, but a
separate branch such as `dev` if the default is protected.

- **One long-lived session per bundle.** Runs Discovery and Shape, and later Ship. Its
  working directory stays on the integration target the whole time — it never checks out a ticket
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

If narrowing still leaves feasibility or diagnosis genuinely unknown, don't force it — shape and run
an investigation/spike first (see [Tailor bundles by uncertainty and
impact](./bundles-by-size.md)). Its evidence becomes the next thing you pick, not a shortcut into
Shape.

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

**Plan gate:** you approve. The bundle commits directly to the integration target — no PR. Critique
plus your approval already are the review step for a planning artifact; a PR on top of that adds
ceremony without adding a gate.

## Implement (per ticket)

For each ticket you're ready to start: open a new session tab and paste its opening prompt.

- **Single-ticket bundle:** the prompt creates the ticket's branch and worktree straight from the
  integration target, and its PR merges directly into that target.
- **Multi-ticket bundle:** claiming the first ticket also creates a bundle branch off the integration
  target (e.g. `bundle/<bundle-id>`) — no worktree for the bundle branch itself, since nothing is
  edited on it directly. Every ticket's branch and worktree are cut from that bundle branch instead
  of the integration target, and every ticket's PR merges into the bundle branch, not the target.

Either way, the tab then starts the implementation skill, which builds the ticket including tests,
runs its checks, and opens the PR with a summary.

Only open a ticket's tab once every ticket it depends on is `done`. Tickets with no dependency
between them can run in tabs side by side.

## Review → fix loop

From the same ticket tab, the implementation session dispatches review as a fresh subagent — it
shares no message history with the implementer, so it judges independently even though you launched
it from the same place.

- Reviewer posts findings to the PR as comments (as blockers or concerns), and returns a summary to the tab.
- The implementer resolves every blocker — fixes it or rebuts it with evidence. Concerns are not
  required to be fixed; they carry forward for you to accept or reject at merge time.
- Posts a fix summary at the new head, which kicks off the next review round. Three rounds is the
  normal max; four or five need your explicit go-ahead. Five is the hard ceiling — beyond that, back
  to Shape.

Because you're in that tab's conversation the whole time, you can jump in and steer or fix things
yourself at any point — nothing about this loop locks you out.

Once ready, you review the PR and diff yourself, then either merge it directly or run
`/complete-ticket` to do it.

## Ship

Once every ticket in the bundle is `done`, go back to the shaping session (or a fresh one) and
trigger `/ship`:

- confirms checks pass, by querying CI status remotely rather than checking anything out locally:
  - **multi-ticket bundle:** targets the bundle branch — this is what gates the merge below
  - **single-ticket bundle:** targets the integration target directly, since the one ticket's PR
    already merged there; this just reconfirms it's green
- folds anything durable — system behavior, decisions — from the bundle into the docs that own it
- captures unfinished or newly discovered work as backlog lines
- deletes the bundle: for a multi-ticket bundle, as a commit on the bundle branch itself, so the merge
  below lands a bundle-free state on the integration target; for a single-ticket bundle, as a commit
  directly on the integration target, since there's no bundle branch
- for a multi-ticket bundle, merges that now-bundle-free bundle branch — holding every merged ticket —
  into the integration target; a single-ticket bundle already landed there when its one PR merged, so
  this step is a no-op
- removes whichever of the ticket branches, the bundle branch (if one existed), and their worktrees
  still exist — some may already be gone if your repo auto-deletes branches on merge
