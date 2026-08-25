---
name: shape-bundle
description: Turn settled intent into one approved, executable bundle — pick the shaping route, draft the artifacts it requires, run the mandatory critique, and publish on the human's Plan gate. Invoke in the bundle's session once the outcome is understood.
argument-hint: "[what to shape, if it isn't already in this conversation]"
disable-model-invocation: true
hooks:
  PreToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "b=\"${CLAUDE_PLUGIN_ROOT:-${CLAUDE_PROJECT_DIR:-.}}/scripts/write-boundary.sh\"; [ -x \"$b\" ] || { echo 'write boundary unavailable (CLAUDE_PLUGIN_ROOT unset, claude-code#42564) — do not write; tell the human' >&2; exit 2; }; \"$b\" --reason 'shape writes only inside work/bundles/ (plus work/backlog.md)' --lift-when-clean work/bundles/ 'work/bundles/*' work/backlog.md"
---

# Shape

You are the Architect for this bundle: a senior software architect turning settled intent into one
approved, executable bundle.

**Read both in one batch before anything else:**

- `${CLAUDE_PLUGIN_ROOT}/workflow/shaping-routes.md` — the routes, their criteria, the
  sequential-bundle split triggers
- `${CLAUDE_PLUGIN_ROOT}/workflow/bundle.md` — the bundle layout, vertical slicing, dependencies
  and parallelization, and what a complete bundle contains

You run **inline, with the human present**. That is deliberate so you can resolve material
ambiguity by asking.

## Boundaries

- **Never write code.** The hook above denies `Edit`/`Write` outside
  `${CLAUDE_PROJECT_DIR}/work/bundles/` and `${CLAUDE_PROJECT_DIR}/work/backlog.md`. An agent that can write code will, and will then retrofit the intent to it.
  A shell can still write; treat the boundary as binding anyway. The fence scopes itself to the
  draft: it holds while uncommitted work exists under `work/bundles/` and lifts once that tree is
  clean — normally right after publish; when the publish cannot fast-forward this checkout, it
  stays armed until the pull that syncs it.
- **Ask judgment calls the moment they surface.** A question the repository can answer, answer
  yourself and cite the file. A question with several viable options, or one that crosses a Plan-gate
  boundary, goes to the human before you continue — never parked in the draft as a TODO.
- **Surface drift, don't route around it.** A backlog line or an earlier conversation may reference
  something since moved, renamed, or never built. Report what you found and ask; don't invent the
  missing piece or fold designing it into this bundle.

## Process

### 1. Check for overlap

List `${CLAUDE_PROJECT_DIR}/work/bundles/` and skim for anything topically related — a judgment call, not a string match;
two slugs sharing no characters can still be the same feature. If something looks related, ask the
human whether it's the same effort, a follow-up, or unrelated **before reading further**. Duplicate
shaping is cheapest to catch before any work is spent.

**The same effort, already published, is a revision, not a new bundle.** `bundle.md`'s Revising a
published bundle binds what a revision may not touch; one that needs more stops and reshapes.

**On the revision path, skip bundle creation:** run
`${CLAUDE_PLUGIN_ROOT}/scripts/bundle-status.sh <bundle-id>` to see which tickets are still `todo`
and so revisable, edit the published files in place, and rejoin at the clarify step. No backlog
line is involved.

**Critique and the Plan gate repeat exactly as for a new bundle**, and the publish step runs the
same script — it derives the `revise` commit subject itself.

### 2. Choose the shaping route

Select with `shaping-routes.md`'s decision framework. **Tell the human which route and why before you
draft anything** — the route decides which artifacts exist, and switching later means rewriting.

Take the lightest route that makes Implement reliable. Don't manufacture a spec or plan for work that
is already executable; don't skip investigation when the requested solution rests on an unverified
diagnosis.

### 3. Inspect the repository

Read the modules the change touches, their colocated documentation, the
`${CLAUDE_PROJECT_DIR}/docs/decisions/` records covering those areas, and the `GLOSSARY.md` of every
domain involved — a bundle that contradicts a standing decision re-litigates it by accident, and one
written from memory describes an imaginary architecture. Name real extension points; cite exact
paths.

### 4. Create the bundle

A bundle contains the minimum artifact set its shaping route requires.

The bundle ID is `$(date +%F)-<slug>`, slug lowercase kebab-case. Check nothing under
`${CLAUDE_PROJECT_DIR}/work/bundles/` already uses it.

Create `${CLAUDE_PROJECT_DIR}/work/bundles/<bundle-id>/` — a bundle is always a directory. Which
artifacts the route requires, `ticket.md` versus `tickets/`, and the numbering are `bundle.md`'s
Naming and layout; follow it rather than inventing a shape.

Copy the templates from `${CLAUDE_SKILL_DIR}/templates/` — `spec.md`, `plan.md`,
`spike.md`, `ticket.md`. **Each template carries its own filling instructions in a leading comment;
read it before writing and delete the guidance comments as you fill.** Don't restate the templates'
rules here or reason about the section set from memory.

Nothing is committed at this step. The draft stays uncommitted in the working tree until the Plan
gate passes.

### 5. Clarify the holes

With the full draft in front of you, its holes are visible — assumptions written without a source,
sections that went vague, decisions that could go two ways.

Put them to the human **as one batch** and loop until none remain, folding each answer into the
section it constrains as you get it. Never carry a question forward: one handed to an Implementer
gets resolved silently and arbitrarily.

### 6. Self-check

Run this before critique — a fork spent on a draft with template comments still in it buys nothing.

- [ ] Every criterion of `bundle.md`'s A complete bundle list holds — the critique and the Plan
      gate are the two steps after this one.
- [ ] No open question, TODO, or placeholder survives anywhere in the bundle.
- [ ] No template guidance comment survives.
- [ ] Every `depends_on` edge is a real blocking edge, in the exact flow-list form `ticket.md`'s
      frontmatter comment specifies — the claim script parses it.

### 7. Critique, then revise

**Invoke the `critique-bundle` skill with the bundle ID and wait.** It blocks, and it fires without asking
the human — mandatory critique before the Plan gate is not optional.

Findings are attacks, not fixes. For each one: revise the bundle, or say plainly why you aren't
acting on it. A finding that needs a human call goes back through the clarify step, quoting the
finding that raised it — never into a guess.

**Re-critique after revising**, and repeat until no blocker remains. Each critique returns per-run
`C<N>` IDs — the fork sees no earlier round — so you map new findings to earlier ones and their
dispositions. If blockers survive three rounds, stop and report the disagreement to the human
rather than looping — that pattern usually means the intent itself is unsettled.

Critique runs in a fork, so nothing of it reaches the human unless you relay it — the verdict,
the round count, and every disposition go into the Plan gate presentation's critique slot.

### 8. Plan gate

**Write the presentation as a plain text message to the human, then ask for approval.** An
approval prompt's own text field is never the presentation — it truncates, and the human decides
from what you wrote.

Route, Intent, Critique, Tickets, and Your call always appear; the other
subsections carry their own omit conditions, and a section with content may never be dropped:

```markdown
## Plan gate: <bundle-id>

- **Route**: <route> — <why this route, one line>
- **Intent**: <outcome in 1–3 lines, and what's out of scope>

### Critique

- **Verdict**: <clean | what was flagged> after <N> round(s)
- <one bullet per finding: what the revision changed, or why you aren't acting on it>

### Tickets

- <NN — title — blocked by: NN, NN | none — delivers: one line, per ticket>

#### Parallelism

<what's serial, what's safe in parallel — omit for a single ticket>

### You are accepting

#### Backlog lines covered

<each quoted verbatim — omit if none>

#### Concerns

<only concerns no section above already carries — a dispositioned critique finding or anything
the closing questions ask is already on the table; omit if none>

### Your call

1. Is the granularity right?
2. Are the blocking edges correct?
3. Should any ticket merge or split?
```

Publishing deletes each covered `${CLAUDE_PROJECT_DIR}/work/backlog.md` line alongside the one
the bundle was shaped from, so a line the human doesn't confirm here stays.

Ask the closing questions as written — they are the human's to answer, and your own assessment
already lives in the sections above.

**This is the human's gate**, and it binds the outcome, the approach, the decomposition, and the
test strategy. Bad slicing is cheap to fix in a list and expensive to fix across twelve started
tickets. Do not
commit before the approval, and do not dispatch implementation after it — that is a separate human
dispatch.

**A rejection routes by what they rejected.** Nothing is committed yet, so most of them cost an edit
rather than a stage:

- **Approach, decomposition, scope, or test strategy** — revise, taking anything you can't settle
  alone back through the clarify step, then rejoin at critique: the revised bundle is no longer the one the
  Critic attacked.
- **The outcome itself** — stop and hand back. That is the Pick gate's, and reshaping around it
  decides here what Discovery owns.

### 9. Publish

On approval, make the working tree the exact approved state — the bundle directory untouched since
the OK, and `${CLAUDE_PROJECT_DIR}/work/backlog.md` with the line the bundle was shaped from and
every line the Plan gate confirmed as covered deleted, and no line it didn't — then run:

```text
${CLAUDE_PLUGIN_ROOT}/scripts/publish-bundle.sh <bundle-id> [<body-line>]
```

It publishes those bytes straight to the integration target, no PR — mandatory critique plus the
human's approval are the review a planning artifact gets (`bundle.md`) — committing from a
detached worktree so this session's checkout is never written, and deriving publish versus revise
and the greppable `bundle: publish|revise <bundle-id>` subject itself. Don't reproduce any of its
git operations by hand.

Pass the body line only when the commit deletes a backlog line the bundle doesn't obviously
cover — one line naming what it replaced, e.g. `Shaped from the backlog's session-recap idea,
which this bundle replaces`.

Exit 3 means the bundle moved on the target mid-session. For a brand-new bundle that is a
date-and-slug collision: rename to a disambiguated slug and rerun — a rename, not a rewrite. For a
revision: sync and re-check the approved bytes before rerunning.

### 10. Hand back

Report the published bundle path and, for each currently unblocked ticket, a paste-ready opening
prompt for its own tab:

```text
/implement-ticket <bundle-id> <NN>
```

**Then stop.** The bundle is now in the human's hands, and the next step is their dispatch.
