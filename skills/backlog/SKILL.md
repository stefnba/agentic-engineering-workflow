---
name: backlog
description: Caretaker for work/backlog.md, the repo's list of candidate work and follow-ups nobody has picked yet. Use when the user asks to record something for later, asks what is outstanding for an area, or reports a backlog item done — and at the end of a task, to offer what you noticed but did not fix. Not everything you notice earns a line.
argument-hint: "[what to record, complete, or look up]"
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Backlog

`${CLAUDE_PROJECT_DIR}/work/backlog.md` holds one line per piece of candidate work nobody has picked
yet. Its value is that it reads top to bottom in under a minute — the codebase holds the detail, this
file holds the reminder. A line leaves it two ways: the human picks it and `shape` turns it into a
bundle, or it is deleted.

**Read "What earns a backlog line" in `${CLAUDE_PLUGIN_ROOT}/workflow/artifacts.md` before writing
one**, along with the kinds and areas sections under it. That document owns the bar, and most of
what you are tempted to file misses it — dropping a candidate is the ordinary outcome, not a failure
to capture.

Where no file exists — a repo that skipped `setup` — create it on the first confirmed line, as a
`# Backlog` heading, one sentence of what it holds, and an `## Items` heading.

## Who may write

**The user asked for a line — write it.** They decided; no confirmation round.

**You noticed it yourself — propose it, never write it.** Hold the candidate until the task you are
on is finished, then offer everything you collected as one batch, in the exact lines you would add:

```text
+ [drift] [skills] `bundle-git` documents a `depends_on` form its claim script doesn't parse
+ [follow-up] [docs] walkthrough.md names `/land`, which doesn't exist
```

Write the ones the user keeps, and treat silence on a line as a drop — ask once, not twice.

**Drop a candidate that misses the bar before it reaches the batch.** Proposing everything you
noticed moves the flood one step later and hands the triage to the human, which is the thing the bar
exists to prevent.

**Fix what you can fix.** A proposal is not permission to skip a two-minute correction that is
already in scope for the task you are on.

**Offer the batch on demand too** — when the user asks what you noticed, and before a session ends
or compacts. Drift gets noticed mid-work, and a candidate held only in context dies with the
context.

## The line

```text
- [kind] [area] one line
  - <evidence, only where the line means nothing without it>
```

Too vague to act on later: `- [idea] [ui] improve components`. Too much: a line whose sub-bullets
sketch the schema and the migration steps — that is a plan, so offer `/shape` on it instead.

## Before any edit

**Read the file in full first.** Near-duplicate lines are the common failure: sharpen the line
that's already there rather than adding a second one beside it.

**Check `${CLAUDE_PROJECT_DIR}/work/bundles/` for a bundle that already covers it.** If one does,
say so and record the point in that bundle instead — a backlog line shadowing live work is two
copies that drift, with neither obviously the stale one.

## Operations

**Add** — append at the end of `## Items`. Position carries no priority, so never insert, reorder,
or group.

**Complete** — delete the line. Git holds the history; a `## Done` section grows without bound and
nobody reads it. If the work settled something contested, offer `record-decision`.

**Promote** — offer to run `/shape` on the line and leave the line where it is. `shape` deletes it
in the same commit that publishes the bundle, so the item sits in exactly one place at every
committed state; deleting it here loses it if the shaping session is abandoned.

**Look up** — grep by kind or area and show the matching lines verbatim, without reformatting or
summarising them.

## Prune

**Only when asked, or as `/pick`'s closing round.** A prune is a deliberate pass over the whole
file — the one invocation where **Leave everything else alone** below doesn't bind. Never volunteer
one alongside another operation.

Four things earn a proposal:

- **Landed, whole or in part.** The work exists now. A line whose scope only partly landed is edited
  down to what's left — never given a clause recording the part that's done.
- **Superseded.** A newer line covers the same ground better.
- **Shadowed.** A live bundle under `${CLAUDE_PROJECT_DIR}/work/bundles/` already owns it.
- **Duplicated.** Two or three lines circling one problem consolidate into one sharper line, rather
  than becoming three deletions.

**Verify before proposing.** Open the file, run the grep. An unchecked "this looks landed" is the
same unverified claim a `[drift]` line gets rejected for, except here it argues for deleting
something.

**Propose, never apply** — numbered, each with its evidence, and write only what the user confirms:

```text
1. [follow-up] [server] add request logging — landed in 2026-08-02-observability
2. [idea] [ui] dark mode toggle — shadows the shaped bundle 2026-08-12-theming
3. lines 4 and 9 both describe the claim script's `depends_on` parsing — consolidate into one

Drop which?
```

Nothing earns a proposal: say the file is clean and stop.

## Leave everything else alone

Touch only the lines the user asked about. Don't reword, reorder, re-tag, deduplicate, or tidy an
entry you weren't asked to change, even one that reads badly — the exact phrasing may be what the
user recalls the context from. Say what looks wrong and let them decide.

## Reporting back

Show the lines that changed and nothing more:

```text
+ [follow-up] [server] no transaction support — repository ops can't run atomically
- [drift] [ui] date-range filters can't map to contract keys   (completed)
```

Don't print the file, don't summarise its state, and don't suggest what to work on next — `/pick`
answers that question, in front of the human.
