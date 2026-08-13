---
name: pick
description: Choose the next backlog line to work on. Use when the user asks what to work on next, wants to see what's worth doing, or wants to start something new from the backlog — even when they don't say "pick".
argument-hint: "[optional tag or area to focus on]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Skill(backlog *)
---

# Pick the next candidate

**Dialogue role**: the human chooses what is worth doing next; this skill only sets the
table. Priorities, like decomposition and acceptance, are a judgment the workflow reserves
for the human — never hand yourself the pick, and never nudge it with ordering, emphasis, or
recommendations nobody asked for.

## 1. Lay out the field

**Read `work/backlog.md` in full.** Missing or empty: say so and stop — there is nothing to
pick, and intent the human brings directly skips the backlog and goes straight to
`interview-me` or `shape`.

**Check what's already in flight** — the bundles under `work/shaped/` and `work/active/`.
They render as the first line of the block below, stated as fact: starting something new
competes with finishing these, but whether that matters is the human's call.

## 2. Present candidates

**Render the field as one block in this shape**, nothing before or after it. Example — a
backlog of two lines with one trigger-gated entry:

```markdown
**In flight**: 2026-08-11-billing-retries (active) · 2026-08-12-export-csv (shaped)

**Candidates** — file order, not priority:

| #   | Tag    | Problem                                                       |
| --- | ------ | ------------------------------------------------------------- |
| 1   | server | no transaction support — repository ops can't run atomically  |
| 2   | ui     | date-range filters can't map to contract keys like startDate  |

_+1 line withheld (trigger-gated, event not fired)_

Pick a number, or ask about any line.
```

Rules the skeleton can't carry:

- **Problem text verbatim** — the human recognizes their own lines. Only the leading `[tag]`
  moves into its own column; never paraphrase, shorten, or merge.
- **`#` is a conversation handle**, counted top to bottom over the displayed rows so the
  human can pick by number — it carries no rank. File order is deliberate: ranking happens
  here, in front of the human, not in the file and never by you.
- **Every row looks the same** — no icons, bolding, or flags on individual rows; any visual
  emphasis is a nudge toward that row.
- **The footer counts everything kept off screen** — `$ARGUMENTS` narrows rows to matching
  tags or areas, and `## Trigger-gated` entries stay out unless their event has plainly
  fired; the count is what keeps that filtering from hiding lines silently. All rows shown:
  drop the footer.

**Answer questions from the repo, not from opinion.** "Is this still real?" or "how big is
this?" you settle with Read/Grep, citing the file. Give a recommendation only when the human
explicitly asks for one, and label it as yours.

## 3. Route the pick

Wait for the human to name a line or number, then judge one thing only — is it crisp enough
to shape from? — and hand off in this shape:

```markdown
Picked: `[server] no transaction support — repository ops can't run atomically`

Crisp — problem and rough scope would support a spec. Next: invoke `shape` here, no
argument needed; the line above is its input.
```

A vague line swaps the second sentence: name what's still unsettled, and point to
`interview-me` with the line as its argument. The verbatim quote is load-bearing — `shape`
and `interview-me` read their input from this conversation, and the handoff block is what
they receive.

**A pick that isn't on the list is direct intent** — the human naming new work mid-dialogue
skips the backlog by design. Route it through the same verdict; no backlog line exists, so
there is nothing for shape to delete later.

**Leave the invocation to the human** — `shape` and `interview-me` are manual-only because
invoking them is the act of approval that closes this gate.

**Leave the picked line in the backlog** — deleting it is shape's job, in the commit that
lands the bundle; the `backlog` skill's promote rule owns the reasoning.

## 4. Prune

**Before ending, flag lines that look dead** — obsoleted by shipped work, superseded by a
newer line, or shadowing a live bundle — numbered, each with its evidence, and ask:

```markdown
Possibly dead:

1. `[server] add request logging` — shipped in 2026-08-02-observability
2. `[ui] dark mode toggle` — shadows the shaped bundle 2026-08-12-theming

Drop which?
```

REQUIRED: confirmed deletions go through the `backlog` skill — this skill never edits the
file itself, and the backlog skill's diff report is the prune's closing output. Nothing
looks dead: end without a prune round.
