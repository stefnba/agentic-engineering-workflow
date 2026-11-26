<!-- Fill every section; drop a section only where its comment allows it; delete these comments as you fill.
Write every name and draw every diagram as references/notation.md says. -->

# <The directory's job, as a noun phrase>

<!-- One paragraph of at most five sentences, and nothing before it: what the directory does in the system, who
calls its entry point and when, what goes in and what comes out, and whether it does I/O. When a user-facing
reference documents the format or API this code enforces, end with a sentence linking it. No sentence about the
document, its reader or its sources. Example:
Freezes one analysis into the facts a run works from: its two periods as dates, its sources and its notes.
`create_run()` in `rca/core/run/runs.py` calls it once per analysis when a run is created. -->

## Responsibilities

<!-- Three to six bullets, one job each, led by a verb, naming the function that does it. Example:
- Turn grain, count and comparison basis into two date ranges: `periods_for()`. -->

- <job>: `<name>()`

## Not here

<!-- Two to four bullets: a job a reader would expect here, and the directory that does it. Example:
- Measuring each source's coverage: `rca/adapters/sources.py`. -->

- <job>: `<path>`

## Where the code sits

<!-- One `flowchart LR` with its legend line: the call chain from the Entry that starts it (a command, a route, an
event, a caller) to this directory's entry point and back out. When several callers reach the directory, draw the
chain of the one a reader meets first and name the others in the paragraph. Then one paragraph on what the
neighbouring code does around this call that the summary has not said. -->

<!-- One paragraph on the public surface: what other code imports from here (the package's exports), and that
everything else is internal and free to change. -->

## <The main mechanism, named as the code names it>

<!-- One sentence, then one `flowchart TD` of the entry point's steps or passes, or of the calls one caller makes
in sequence when no single function does the job, with its legend line. Show every
place a result or a failure leaves the flow. Then one bold-led paragraph per step, saying what it checks or
produces and why it runs where it does. Each fact lives in one place: the diagram shows order, the prose says why,
the code map lists names. -->

## Worked example

<!-- At most 30 lines in all. One small input, described in a sentence or shown in a fenced block small enough to
read in ten seconds; what the entry point returns for it; one variation that breaks or exercises the mechanism.
Show the parts of each output that teach something, as whole lines, and say when a block is an excerpt. Every line
comes from a run you made; paste it, never write it by hand, except that a path prefix only your machine has may
become `{member root}` or `{tmp}`, said once under the block. When the example script is committed, name its path
and the command that reruns it. End with one short paragraph on what a reader would not predict. Later sections
refer back to this example instead of introducing a second one; a later section may show a variation of it in a
block of at most ten lines. -->

## <How the parts plug in>

<!-- Drop this section when the directory has no repeated pattern. Otherwise: a table, one row per part
(a kind, a handler, a stage), one column per thing each part supplies. Then one bold-led paragraph for each place
the pattern deliberately breaks, saying why, so a reader does not "fix" it. -->

## <The non-obvious rules>

<!-- Drop this section when nothing in the code would surprise a careful reader. Otherwise: one bold-led
paragraph per mechanism a reader would get wrong from one file alone: error handling, ordering, suppression,
caching, an import that must not exist. Each paragraph states the rule, then the reason. -->

## Where a change goes

<!-- Drop this section when the directory has no extension point. Otherwise: one sentence, then a table, each row
naming a real example from the code. When the directory has tests, end with one line naming their path and the
command that runs them. -->

| The change           | Put it in              | Also change                             |
| -------------------- | ---------------------- | --------------------------------------- |
| <what the change is> | `<name>()` in `<file>` | <another doc, test or file, or nothing> |

## Code map

<!-- One sentence saying what the map covers. Then one `###` per module, in the order a reader meets them, each a
table of name and one-line purpose. The map is an index: list every name a maintainer edits, including private
helpers that hold a rule, even when the prose above explains its step; a row names what the function does and
never repeats the prose's reason. Leave out type guards and formatting helpers. Under a module's table, add one
paragraph only for a rule that module alone holds and a reader would get wrong from the table, illustrated with a
variation of the worked example. -->

### `<module>`

| Name       | What it does |
| ---------- | ------------ |
| `<name>()` | <one line>   |
