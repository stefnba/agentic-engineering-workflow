---
name: sweep-bundle
description: Use when every ticket of a work bundle is done and review findings on what it shipped are still open — "sweep the bundle", "add a sweep ticket", "the reviews left small things, can we fix them before landing" — or when land-bundle hands over open findings. Takes a bundle reference and the findings. Not for shaping new work, and not for a bundle with tickets still in flight.
argument-hint: '[bundle reference] [the findings]'
---

# Sweep bundle

Add the one sweep ticket a bundle may gain between its last ticket merging and Land, holding the
low-risk review findings the human admits, and send every other finding to the backlog.

## Path conventions

- The ticket template is `../shape-bundle/templates/ticket.md`, relative to this skill's directory,
  the folder holding this file. If that path is missing, load the `shape-bundle` skill by name to
  find its directory.
- The prose rules for a ticket are `../writing/references/steer.md`, the sibling `writing` skill's,
  relative to the same directory.
- `<reference>` is the bundle reference, `<bundle-id>` or `<member>/<bundle-id>`, and
  `<worktree dir>` the worktree directory in `docs/conventions/git.md`, Worktrees.
- Every other path is relative to the repository root, `git rev-parse --show-toplevel`, not the
  current directory.

## Guardrails

**Admit an item only when all four hold:**

1. **Low blast radius.** No public API, signature, contract, schema, or definition changes, and no
   behavior a caller, a user, or another stage observes changes. A raw exception becoming the
   stage's own error is the one behavior change allowed.
2. **Inside the bundle.** It fixes, completes, or realigns something a ticket of this bundle
   shipped, and touches only files those tickets touched, or those files' tests and docs.
3. **Fix already known.** The item states what to do; the implementer makes no design choice,
   takes no measurement, and adds no dependency.
4. **Small.** One commit's worth of change per item, and the whole ticket one PR a reviewer reads
   in one sitting.

**Send everything else to the backlog**, however small the diff looks: work in another member, the
workspace, the skills, or shared tooling; a structural change such as sharing code between two
stages; anything that needs measuring first; a test that needs live credentials; any behavior
change a user would notice.

**One sweep per bundle.** Items that surface after the sweep ticket is written go to the backlog.

**The human admits every item in chat.** A sweep has no critique round and no Plan gate; the
admitted list is its approval.

## Process

### 1. Check the bundle is ready for a sweep

Run the `workflow-manager` skill's listing for `<reference>`. Work in the bundle branch's
worktree, `<worktree dir>/bundle/<reference>`, adding it with
`git worktree add <worktree dir>/bundle/<reference> bundle/<reference>` when it is missing.

A ticket not `done`, or a ticket file named `*-sweep.md`, is a stop: say which, and offer the
`backlog` skill for the findings instead.

**Done when** the bundle is `active`, every ticket is `done`, and no sweep ticket exists.

### 2. Triage in chat

Post one message: every candidate the human or the bundle's ticket PR reviews raised, one line
each, marked `admit` or `backlog` with the guardrail that decides it. Under the list, the lines
for the refused ones in the `backlog` skill's proposal format. Then wait.

**Done when** the human has admitted the list, or changed it and admitted that.

### 3. Write the ticket

**Read `../writing/references/steer.md` before filling the ticket**; it steers the sub-agent that implements it. Where a prose rule and the template's filling instruction disagree, the template wins.

Fill the ticket template as `tickets/<NN>-sweep.md` in the bundle folder, `<NN>` the next free
number, `depends_on` naming every ticket whose files it touches. The sections a sweep fills
differently from a planned ticket:

- Scope — one line per admitted item: the path and the fix, since the fix is known.
- Not in this ticket — each refused item and that it went to the backlog.
- Done when — one condition per admitted item, plus "every existing test passes unchanged".

When the bundle has a plan, add the ticket's row to its slice table and, under Parallelization,
the line that it runs alone after every other ticket.

When the bundle holds a `brief.md`, add the sweep ticket to it: its line under Tickets, and its files
to the Code shape tree.

**Done when** the ticket has no template comment left, and the plan and the brief, where they
exist, both name it.

### 4. Commit and push

Write the refused items' backlog lines from the triage step through the `backlog` skill, then
commit from the bundle worktree. `check-land` refuses every commit on a bundle branch except a
merged ticket PR and a `bundle:` commit touching only the bundle folder and its own work folder's
`backlog.md`, so the bundle's own backlog lines ride in the revision commit:

```bash
git add <bundle-dir> <work folder>/backlog.md && git commit -m "bundle: revise bundle <bundle-id>" -m "Add the sweep ticket <NN>." -- <bundle-dir> <work folder>/backlog.md
git push origin bundle/<reference>
```

Lines for another work folder, such as the root's, go in a `backlog` commit on the integration
target from the main checkout, never on the bundle branch.

**Done when** the revision commit is on the remote bundle branch and every refused item has a
backlog line somewhere.

### 5. Hand back

Give the paste-ready prompt for the ticket's own fresh session, then stop; dispatch is the human's:

```text
Run the implement-ticket skill for ticket <NN> of bundle <reference>.
```
