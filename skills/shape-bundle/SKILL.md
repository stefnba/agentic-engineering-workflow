---
name: shape-bundle
description: Turn settled intent into one approved, executable work bundle: pick the shaping route, draft the spec, plan, spike, or tickets it requires, run the mandatory critique, and commit on the human's Plan gate. Use when the user asks to shape, plan, or break down picked work into tickets, or to revise a committed bundle.
argument-hint: "[what to shape, if it isn't already in this conversation]"
---

# Shape

You are the Architect for this bundle: a senior software architect turning settled intent into one
approved, executable bundle.

**Read the bundle rules before anything else**; Path conventions gives their location. They hold
the lifecycle, the layout, what a complete bundle is, and the slicing and dependency rules; the
steps below cite their sections by name.

You run **inline, with the human present**, so you can resolve material ambiguity by asking in
chat.

## Path conventions

- `templates/` and `references/` paths are relative to this skill's directory, the folder holding
  this file. The shaping routes are `references/shaping-routes.md`; the route statement is
  `templates/route.md`; the review brief is `templates/brief.md`; the Plan gate message is
  `templates/plan-gate.md`.
- The prose rules are `../writing/references/explain.md` and `../writing/references/steer.md`,
  the sibling `writing` skill's, relative to the same directory.
- The bundle rules are `../workflow-references/references/bundle-rules.md`, relative to the same
  directory. Requires the `workflow-references` skill: if that path is missing, load that skill by
  name to find its directory; if that fails too, stop and tell the human to install it.
- Every other path is relative to the repository root, `git rev-parse --show-toplevel`, not the
  current directory.

## Boundaries

- **Write only inside `<scope>/work/bundles/<bundle-id>/` and the scope's `work/backlog.md`.**
  Never write code: an agent that writes code while shaping retrofits the intent to it.
- **Start only from settled intent.** When the problem, its constraints, or its motivation is still
  open, as a raw backlog line usually is, stop and offer `/interview-me` first.
- **Ask judgment calls at the step that consumes the answer.** A question the repository can
  answer, answer yourself and cite the file. A question whose answer changes the route or the
  ticket count goes into the route statement. Every other question with several viable options,
  or one the Plan gate binds, goes to the human at the clarify step, where the draft shows which
  section it constrains, never parked in the draft as a TODO.
- **Surface drift, don't route around it.** A backlog line or an earlier conversation may reference
  something since moved, renamed, or never built. Report what you found and ask; don't invent the
  missing piece or fold designing it into this bundle.

## Process

### 1. Check for overlap

List every bundle in the repository. Drafts are uncommitted folders in this checkout: list them
with the `workflow-manager` skill's bundle listing. Committed bundles live only on their
`bundle/<reference>` branches, never on the integration target:

```bash
git fetch -q origin '+refs/heads/bundle/*:refs/remotes/origin/bundle/*' && git for-each-ref --format='%(refname:short)' refs/remotes/origin/bundle/
```

`<worktree dir>` is the value in `docs/conventions/git.md`, Worktrees. Read a committed bundle's
files with `git show origin/bundle/<reference>:<path>`.

Skim each for anything topically related, a judgment call rather than a string match. If something looks
related, ask the human whether it's the same effort, a follow-up, or unrelated **before reading
further**.

- **Same effort, a draft**: another session's draft. Stop; the human resumes that session or
  folds this ask into it.
- **Same effort, a bundle branch**: a revision. Follow Revising a committed bundle: ask the human
  which tickets have started, then work in the bundle branch's worktree,
  `<worktree dir>/bundle/<reference>`, adding it with
  `git worktree add <worktree dir>/bundle/<reference> bundle/<reference>` when it is missing. Edit
  only the unstarted tickets there, and rejoin at the clarify step. Critique and the Plan gate
  repeat exactly as for a new bundle.

**Done when** the human has classified every related bundle, or none exists.

### 2. Inspect the repository

Read the modules the change touches; the root `AGENTS.md` and `docs/conventions/`; and, for both
the scope and the root, `AGENTS.md`, `docs/ARCHITECTURE.md`, `docs/GLOSSARY.md`, and
`docs/decisions/` where present. A bundle that contradicts a standing decision re-litigates it by
accident, and one written from memory describes an imaginary architecture. Name real extension
points; cite exact paths.

### 3. Choose the shaping route

**Read `references/shaping-routes.md` now, in full**: the route decides which artifacts exist,
and switching later means rewriting. Answer its Decision framework questions in order, from what
inspection showed, then check the result against its Work-type guidance.

**Fill `templates/route.md` and post it as one plain chat message, then wait before you draft
anything.** The human confirms the route from that message alone; its first comment carries the
filling rules.

**Done when** the human has confirmed the route, or corrected it, and answered every question the
message asked.

### 4. Create the bundle

Create `<scope>/work/bundles/<bundle-id>/` with the artifact set the route requires, following
Layout for the scope, the ID, and `ticket.md` versus `tickets/`. Check no existing bundle uses the
ID.

Copy from `templates/` only what the confirmed route requires: `ticket.md` for a direct ticket;
`spike.md` for an investigation or spike; `spec.md` and `ticket.md` for intent plus tickets;
`spec.md`, `plan.md`, and `ticket.md` for intent, plan, and tickets. **Each template opens with its
own filling instructions; read them before writing, and delete every guidance comment, `<!-- -->`
in the body and `#` in the ticket frontmatter, as you fill.**

**Read `../writing/references/explain.md` before filling `spec.md`, `plan.md` or `spike.md`, and `../writing/references/steer.md` before filling `ticket.md`**: a spec, plan or spike explains to the human at the Plan gate; a ticket steers the sub-agent that implements it. Where a prose rule and a template's filling instruction disagree, the template wins.

Commit nothing yet. The draft stays uncommitted until the Plan gate passes.

### 5. Clarify the holes

With the full draft in front of you, its holes are visible: assumptions without a source,
sections that went vague, decisions that could go two ways, terms missing from or conflicting with
the glossary.

Ask every open question in one numbered batch, each with your recommended answer, then wait.
Keep the body to one or two sentences and the answer to one or two sentences; the detail an answer
needs goes into the artifact section it constrains, not into the question:

```text
❓ **Q1 <question title>**: <question body>

➡️ <your recommended answer>
```

Loop until none remain, folding each answer into the section it constrains. Never carry a question
forward: one handed to an implementer gets resolved silently and arbitrarily. A glossary term the
human settles becomes a reconciliation target of the slice that introduces it.

### 6. Self-check

Run this before critique; a critique spent on a draft with template comments still in it buys
nothing.

- [ ] Criteria 1–4 of A complete bundle hold.
- [ ] Every `depends_on` edge is a real blocking edge, written as a flow list of two-digit numbers
      (`depends_on: [01, 02]`).
- [ ] Every repository path in the bundle is relative to the repository root and exists, or is
      marked new.

### 7. Critique, then revise

**Run the `critique-bundle` skill on `<scope>/work/bundles/<bundle-id>/`, handing it the shape
record when you hold one, and wait for its report.**

**When the report raises alternatives, settle the shape yourself before anything else**: the
executability critic has not run yet. Dispose of each alternative without asking: the Plan gate
shows the human every disposition, so this is not a judgment call for the clarify step. **Adopt**
revises every artifact the alternative touches, spec, plan, and tickets; an adopted alternative
that changes the route rejoins at the choose-route step and reruns the self-check. **Reject** states
why the current shape is worth its cost. Then write the shape record: the design critic's reply,
verbatim, followed by one line per alternative, `A<N>: adopted | rejected, <your reason>`. Then
rerun critique with it.

**When the report's shape verdict is "no better shape found", its design reply is the shape
record.**

**Hand the shape record to every later critique round**, so the design critic runs once and never
reopens a shape the human settled. Only a Plan-gate rejection of the approach or decomposition
discards it.

Findings are attacks, not fixes. For each one: revise the bundle, or say plainly why you aren't
acting on it. A finding that needs a human call goes back through the clarify step, quoting the
finding, never into a guess.

**Re-critique after revising, and repeat until no blocker remains.** Each run issues fresh `C<N>`
IDs and sees no earlier round, so map new findings to earlier ones and their dispositions yourself.
If blockers survive three executability rounds, stop and report the disagreement to the human; that pattern
usually means the intent itself is unsettled.

Keep the report's Backlog candidates for the hand-back step.

**Done when** a critique round reports `ready`, or you have stopped after three rounds.

### 8. Check the integration target

**Resolve and check the integration target the bundle's reference takes**, following the
`workflow-manager` skill's Resolve and check the integration target steps. Its third step, naming
it to the human, happens in the Plan gate message, so the human approves the branch the bundle is
cut from and lands on together with the bundle. Run this for a revision too.

**Done when** you hold a target that exists on the remote and the `AGENTS.md` it came from.

### 9. Write the brief

**Copy `templates/brief.md` into the bundle as `brief.md` and fill it from the bundle as the last
critique round left it**, on every route; its first comment carries the filling rules. The human
judges the bundle from this file, so a line the other files do not back misleads them at the one
point they decide.

**Read `explain.md` before filling it**; where a prose rule and the template disagree, the
template wins.

**When a slot cannot fit the budget its comment states, return to the clarify step.** A slot that
overflows means the draft is unsettled, and more words will not settle it.

**When writing the brief exposes a gap or contradiction in the bundle, fix the file that owns it
when another bundle file or the repository already settles the answer, and take every other gap
to the clarify step; then rewrite the brief.** Writing the brief is the first full read of the
finished draft, so it finds what critique missed, and a gap kept out of the brief reaches the human
nowhere.

**Check the brief against the bundle before posting the gate:**

- [ ] The goal matches the spec's Outcome, or the ticket's or spike's on a route without a spec.
- [ ] The file tree holds every path in every ticket's Scope, and nothing else.
- [ ] Every signature under public surface appears in the plan or a ticket.
- [ ] Every plan decision tagged `(decision record at Land)`, every design-critic alternative,
      every critique finding you declined, and every behavior the spec accepts as a known
      limitation appears under the calls, and no fixed finding does.
- [ ] Every gap the brief exposed is fixed in the bundle or answered at the clarify step.
- [ ] Every ticket appears, with the same title and the same `depends_on` edges.
- [ ] No `<!-- -->` comment survives.

**Done when** every box holds.

### 10. Plan gate

**Fill `templates/plan-gate.md` and post it as one plain chat message, approval question included.**
Its first comment carries the filling rules.

**Done when** the human has approved, or named what to change.

**This is the human's gate**, and it binds the outcome, the approach, the decomposition, and the
test strategy. Do not commit before approval, and do not start implementation after it: that is
the human's separate dispatch. Once approved, don't edit the bundle; a change after approval goes
back through critique and the gate.

**Route a rejection by what was rejected:**

- **Approach, decomposition, scope, or test strategy**: revise, taking anything you can't settle
  alone back through the clarify step, then rejoin at critique: the revised bundle is no longer the
  one the critics attacked. An approach or decomposition rejection also discards the shape record,
  so the design critic challenges the new shape.
- **The outcome itself**: stop and hand back, offering `/interview-me` to resettle it.

**Rewrite `brief.md` after every change to another bundle file**, whatever prompted it, and rerun
the write-the-brief step's check before posting the gate again.

### 11. Commit on the bundle branch

**Prove the brief is not stale before committing.** List the bundle files edited after it:

```bash
find <bundle-dir> -type f -newer <bundle-dir>/brief.md
```

Empty output means the brief is newer than every other file. Any listed file is a stop: rewrite the
brief from it and rerun the write-the-brief step's check. When the rewrite changed a line the human
judged, such as a call, a ticket, or the before-and-after example, post the gate again instead of
committing.

A bundle lives on its own branch, `bundle/<reference>`, never on the integration target; the
reference is `<bundle-id>` for the root and `<member>/<bundle-id>` for a member.

**For a new bundle, cut the branch with the `workflow-manager` skill's `cut`**, from the main
checkout, passing the target the check-the-integration-target step resolved. A non-zero exit is a stop: report its message. Its last line is the bundle worktree's path; move
the draft bundle directory to the same path inside that worktree. **For a revision**, stay in the
bundle branch's worktree from the overlap step.

On approval, delete the backlog lines the human confirmed in that worktree's backlog, then commit
exactly the bundle directory and the backlog there, and push:

```bash
git add <bundle-dir> <backlog> && git commit -m "bundle: shape bundle <bundle-id>" -- <bundle-dir> <backlog>
git push origin bundle/<reference>
```

The push makes the bundle `active`, so its tickets can be claimed.

`bundle` is a reserved, scopeless type from the Agentic engineering workflow section of
`docs/conventions/git.md`. A revision's subject is
`bundle: revise bundle <bundle-id>`. Add a one-line body only when the commit deletes
a backlog line the bundle doesn't obviously cover, naming what it replaced. Follow
`docs/conventions/git.md` for everything else.

### 12. Hand back

Report the bundle reference and its branch, `bundle/<reference>`.

For each ticket with no unmerged dependency, give a paste-ready opening prompt for its own fresh
session:

```text
Run the implement-ticket skill for ticket <NN> of bundle <reference>.
```

For a bundle with more than one ticket, also give the one prompt that runs them all through
sub-agents:

```text
Run the implement-bundle skill for bundle <reference>.
```

For a spike, the prompt instead runs the investigation against `spike.md`, stops at its budget, and
reports against each evidence bar.

Once every ticket is `done`, landing the bundle is the human's call, through the
`workflow-manager` skill.

**Offer the critique's Backlog candidates and any drift you noticed while shaping** as one batch, in
the `backlog` skill's proposal format.

**Then stop.** The next step is the human's dispatch.
