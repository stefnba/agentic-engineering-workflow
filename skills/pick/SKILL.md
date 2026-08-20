---
name: pick
description: Choose the next backlog line to work on. Use when the user asks what to work on next, wants to see what's worth doing, or wants to start something from the backlog — even when they don't say "pick".
argument-hint: "[kind or area to focus on]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash
---

# Pick the next candidate

You set the table; the human chooses. Priority is one of the judgments
`${CLAUDE_PLUGIN_ROOT}/workflow/lifecycle.md` reserves for the human, alongside decomposition and
acceptance — so never hand yourself the pick, and never nudge it through ordering, emphasis, or a
recommendation nobody asked for.

## 1. Lay out the field

**Read `${CLAUDE_PROJECT_DIR}/work/backlog.md` in full.** Missing or empty: say so and stop. There
is nothing to pick, and intent the human brings directly skips the backlog for `/interview-me` or
`/shape` anyway.

**Check what's already in flight** with
`${CLAUDE_PLUGIN_ROOT}/skills/bundle-git/scripts/bundle-status.sh`, run from the repository root. It
renders as the first line of the block below, stated as fact: starting something new competes with
finishing those, but whether that matters is the human's call.

## 2. Present candidates

**Render the field as one block in this shape**, nothing before or after it:

```markdown
**In flight**: 2026-08-11-billing-retries (active) · 2026-08-12-export-csv (shaped)

**Candidates** — file order, not priority:

| #   | Kind      | Areas      | Problem                                                      |
| --- | --------- | ---------- | ------------------------------------------------------------ |
| 1   | follow-up | server     | no transaction support — repository ops can't run atomically |
| 2   | drift     | api client | list endpoints each hand-split searchParams                  |

_+3 lines withheld by the `ui` filter_

Pick a number, or ask about any line.
```

- **Problem text verbatim** — the human recognizes their own lines. Only the leading kind and area
  tags move into their own columns; never paraphrase, shorten, or merge. A line carrying evidence
  sub-bullets shows its first line only, and the human asks about the row to see the rest.
- **`#` is a conversation handle**, counted top to bottom over the displayed rows so the human can
  pick by number. It carries no rank. File order is deliberate: ranking happens here, in front of the
  human, not in the file and never by you.
- **Every row looks the same** — no icons, bolding, or flags on individual rows. Visual emphasis is
  a nudge toward that row.
- **The footer counts what `$ARGUMENTS` filtered out**, so narrowing never hides lines silently. All
  rows shown: drop the footer.

**Answer questions from the repository, not from opinion.** "Is this still real?" and "how big is
this?" you settle with Read and Grep, citing the file. Give a recommendation only when the human
explicitly asks for one, and label it as yours.

## 3. Route the pick

Wait for the human to name a line or a number, then judge one thing — is it crisp enough to shape
from? — and hand off in this shape:

```markdown
Picked: `[follow-up] [server] no transaction support — repository ops can't run atomically`

Crisp — problem and rough scope would support a spec. Next: `/shape` here, no argument needed; the
line above is its input.
```

The verbatim quote is load-bearing: `/shape` and `/interview-me` read their input from this
conversation, and this block is what they receive.

Three exits, differing only in that second sentence:

- **Crisp** — `/shape`, as above.
- **Vague** — name what is still unsettled and point at `/interview-me` with the line as its
  argument.
- **Feasibility or diagnosis genuinely unknown** — point at `/shape` anyway, saying that what it
  shapes is an investigation or spike rather than the implementation
  (`${CLAUDE_PLUGIN_ROOT}/workflow/shaping-routes.md`).

**A pick that isn't on the list is direct intent.** The human naming new work mid-dialogue skips the
backlog by design; route it through the same verdict. No line exists, so `shape` has nothing to
delete later.

**Leave the invocation to the human.** `/shape` and `/interview-me` are manual-only because invoking
one is the act of approval that closes this gate.

**Leave the picked line in the backlog.** `shape` deletes it in the commit that publishes the
bundle.
