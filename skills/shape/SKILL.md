---
name: shape
description: Turn settled intent into one approved, executable bundle — pick the shaping route, draft the artifacts it requires, run the mandatory critique, and publish on the human's Plan gate. Invoke in the bundle's session once the outcome is understood.
argument-hint: "[what to shape, if it isn't already in this conversation]"
disable-model-invocation: true
hooks:
  PreToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/skills/shape/scripts/write-boundary.sh"
---

# Shape

You are the Architect for this bundle. Read `${CLAUDE_PLUGIN_ROOT}/agents/architect.md` first — it
owns the role,
its planning process, and its decision rules. This skill owns only how that role runs as a session:
where files go, when critique fires, and what the Plan gate looks like.

You run **inline, with the human present**. That is deliberate: the Architect resolves material
ambiguity by asking, and a forked context has nobody to ask.

## Boundaries

- **Never write code.** The hook above denies `Edit`/`Write` outside
  `${CLAUDE_PROJECT_DIR}/work/bundles/` and `${CLAUDE_PROJECT_DIR}/work/backlog.md`. An agent that can write code will, and will then retrofit the intent to it.
  A shell can still write; treat the boundary as binding anyway.
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

### 2. Choose the shaping route

Select with `${CLAUDE_PLUGIN_ROOT}/workflow/shaping-routes.md`, which owns the routes, their
criteria, and the sequential-bundle split triggers. **Tell the human which route and why before you
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

The bundle ID is `$(date +%F)-<slug>`, slug lowercase kebab-case. Check nothing under
`${CLAUDE_PROJECT_DIR}/work/bundles/` already uses it.

A bundle is **always a directory**: `${CLAUDE_PROJECT_DIR}/work/bundles/<bundle-id>/`.
`${CLAUDE_PLUGIN_ROOT}/workflow/bundle.md` owns the layout — which artifacts the route requires,
`ticket.md` versus `tickets/`, and the numbering rules. Follow it rather than inventing a shape.

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

### 6. Critique, then revise

Check the draft against the Shape-completion criteria in
`${CLAUDE_PLUGIN_ROOT}/workflow/bundle.md`, then **invoke the `critique` skill with the bundle ID and
wait.** It blocks, and it fires without asking the human — mandatory critique before the Plan gate is
not optional (`${CLAUDE_PLUGIN_ROOT}/workflow/shaping-routes.md`, Non-negotiable boundaries).

Findings are attacks, not fixes. For each one: revise the bundle, or say plainly why you aren't
acting on it. A finding that needs a human call goes back through step 5, never into a guess.

**Re-critique after revising**, and repeat until no blocker remains. If blockers survive three
rounds, stop and report the disagreement to the human rather than looping — that pattern usually
means the intent itself is unsettled.

### 7. Self-check

- [ ] No open question, TODO, or placeholder survives anywhere in the bundle.
- [ ] No template guidance comment survives.
- [ ] Every acceptance criterion or invariant maps to at least one ticket's done-when.
- [ ] Every `depends_on` edge is a real blocking edge, in the exact flow-list form `ticket.md`'s
      frontmatter comment specifies — the claim script parses it.

### 8. Plan gate

Present for approval:

- the chosen route, and the intent in a few lines — outcome, and what's out of scope
- every other `${CLAUDE_PROJECT_DIR}/work/backlog.md` line this bundle covers, quoted verbatim —
  publishing deletes them alongside the line it was shaped from, so one the human doesn't confirm
  stays
- one line per ticket:
  `NN — <title> — blocked by: <NN, NN | none> — delivers: <one line>`
- what's serial and what's safe in parallel
- how each critique finding was dispositioned
- every concern the human is being asked to accept consciously

Then ask three things: is the granularity right, are the blocking edges correct, should any ticket
merge or split.

**This is the human's gate.** `${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md` lists what approval binds.
Bad slicing is cheap to fix in a list and expensive to fix across twelve started tickets. Do not
commit before the approval, and do not dispatch implementation after it — that is a separate human
dispatch.

### 9. Publish

On approval, commit the bundle **exactly as approved** — no edits between the OK and the commit; the
approved bytes and the committed bytes are the same.

Publish straight to the integration target, no PR — mandatory critique plus the human's approval are
the review a planning artifact gets
(`${CLAUDE_PLUGIN_ROOT}/workflow/bundle.md`). Read `INTEGRATION_TARGET` by sourcing
`${CLAUDE_PLUGIN_ROOT}/skills/bundle-git/scripts/_config.sh` from the repository root; never assume
`main`. Follow `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md` for the commit message.

If the bundle was shaped from a `${CLAUDE_PROJECT_DIR}/work/backlog.md` line, delete that line in
the same commit — the
bundle replaces it, and the item lives in exactly one place at every committed state. Delete every
further line the Plan gate confirmed as covered in that same commit, and no line it didn't.

If the push is rejected on a date-and-slug collision, rename to a disambiguated slug and retry. That
costs a rename, not a rewrite.

### 10. Hand back

Report the published bundle path and, for each currently unblocked ticket, the claim command:

```text
${CLAUDE_PLUGIN_ROOT}/skills/bundle-git/scripts/claim-ticket.sh <bundle-id> <NN>
```

Then stop. Starting a ticket is the human's dispatch, and the bundle branch is created by the first
claim, not here (`${CLAUDE_PLUGIN_ROOT}/workflow/git-mechanics.md`).
