<!--
The review brief: the one page the human reads to judge what they approve at the Plan gate. Copy it
into the bundle as brief.md on every route, after the last critique round.

For the human at the Plan gate: what will exist after this bundle lands, and which calls they are
accepting. They read it without the other bundle files open.

Derive every line from spec.md, plan.md, the tickets, spike.md, and the critique dispositions.
A fact the brief needs that no other file holds is a gap in the bundle; the write-the-brief step
says how to close it. The other files win any disagreement, and the brief is then stale.

Name a bundle ID (BR-n, AC-n, PD-n, NG-n) only in parentheses after the words that carry its
meaning, and only where the human may want to open the file.

Fill every slot inside its budget; delete these comments as you fill. Omit a section the comment
marks optional, heading included.
-->

# <bundle-id>: Brief

## Goal

<!-- 1 to 3 sentences: what is observably true after this bundle lands that is not true now, in the
user's or caller's terms. -->

<goal>

**Route**: <route>, because <one line>

## Before and after

<!-- One worked example with real numbers or real names, the clearest proof of the goal: today's
output, then the output after the bundle, for the same input. Use what the change produces — ledger
rows, CLI output, a file, a function's return value — as a short table or code block. Hand-build it
from fixtures, existing run output, or the spec's examples; never run a warehouse query or an LLM
call to get it. At most 15 lines per side. A spike instead shows the question and the decision each
possible answer leads to. Example:

Today, `facts.csv` for Matchmaking, September 2026, ends with the daily facts:

| fact_id | scope | metric  | value  |
| ------- | ----- | ------- | ------ |
| D-14    | CH    | revenue | 41,200 |

After, an excess fact per scope and leaf metric follows them:

| fact_id | scope | metric  | reference | actual | excess | history     |
| ------- | ----- | ------- | --------- | ------ | ------ | ----------- |
| X-1     | CH    | revenue | 38,900    | 41,200 | +2,300 | three years |
-->

## How it fits

<!-- Optional on the direct ticket and spike routes. One Mermaid flowchart, at most 12 nodes, of
the data or call flow the bundle touches, drawing only edges the plan or tickets state. Keep both
classDef lines; put :::new on new parts and :::changed on changed parts, and leave untouched parts
unstyled, so the human sees where the change sits. -->

```mermaid
flowchart LR
    a[<untouched part>] --> b[<new part>]:::new
    b --> c[<changed part>]:::changed
    classDef new fill:#d4f7d4,stroke:#2a7a2a
    classDef changed fill:#fff2c2,stroke:#a07a00
```

## Code shape

<!-- Optional on the spike route. Three parts, derived from the tickets' Scope and the plan's
Approach. -->

<!-- Files: a tree of every file the tickets create, change, or delete, marked (new), (changed), or
(deleted), with a few words each. Collapse files that change for one reason, such as several docs,
into one line. -->

```text
<tree>
```

<!-- Public surface: each function, class, CLI command, or file format that another module or a
later ticket relies on, as its signature and one line of purpose. Write "none" when the bundle adds
or changes no such surface. -->

<surface>

<!-- One line naming what the implementer decides, from the tickets' Autonomy boundaries, so the
human sees which parts of the shape this brief does not fix. -->

**Implementer decides**: <one line>

## Calls you might disagree with

<!-- One line per call, most consequential first: a choice the bundle makes for the human, then
its consequence in practice. List every plan decision that becomes a decision record at Land, every
design-critic alternative with the reason for its disposition, every critique finding you declined
with the reason, and every behavior the spec accepts as a known limitation. A finding the bundle
fixed is not a call. This section has no line cap: list every call the sources hold. Example:

- **A cell with no level in its window gets a reference of 0** (NG-2): its whole value counts as
  excess until estimation cells land, so new small cells can look like causes.
-->

- **<the choice>** (<ID>): <its consequence in practice>

## Tickets

<!-- One line per ticket in dependency order: what it builds in words, then what it waits for.
Then one line on what may run in parallel, omitted for one ticket. The spike route instead lists
the evidence bars in words and the budget. -->

1. **<title>**: <what it builds> · waits for: <none | ticket titles>

## Leaves out

<!-- The 2 to 5 non-goals an implementer or the human is most likely to assume are in scope, a few
words each, with what handles them instead where something does. -->

- <non-goal>
