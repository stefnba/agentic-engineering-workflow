<!-- Fill every section, except one its comment lets you drop; delete these comments as you fill. Describe the current state only, never plans.
Keep the file to about two pages; detail beyond a part's row stays in the code.
Name parts in prose by their glossary term or top-level directory, and put each [path:symbol] cite at the end of its line or in a Cite cell, so the prose survives a refactor and the cite check catches what moved.
Leave out directory trees, stack and dependency lists, commands, how a part works inside, the reasons behind a choice, and plans. Agents read the first four from the repository, reasons live in decision records, and plans in docs/PROJECT.md. -->

# Architecture

Built from commit `<sha>`.

<!-- The short commit the claims were checked against. An update reads it to find what changed since. -->

<!-- One paragraph: what the system does, its shape in one line, and the one fact a new reader must leave with. Example:
An HTTP API that takes orders and settles them with a payment provider. A modular monolith with one async worker; every write goes through the orders part. -->

## Parts

<!-- At most one Mermaid flowchart of the parts and the stores and outside systems they talk to; drop it when there are three parts or fewer. Then one row per part.
Backed by: the decision record that settles the part, such as D-0003, or "no record". A part with no record is code an agent may not copy as precedent. -->

| Part | Owns | Backed by | Cite |
| ---- | ---- | --------- | ---- |

## How a request flows

<!-- One worked example through the parts, the request a new reader meets first, one numbered hop per part with its cite. -->

## Data and external systems

<!-- Each store and outside service, and which parts read and write it, one line each with its cite. -->

## Shared code

<!-- One line per concern several parts use, such as errors, logging, configuration, auth or a shared helper, naming the part that owns it, with its cite. A reader looks here before writing a helper. Drop the section when nothing is shared. -->

## Invariants

<!-- Rules the code enforces, especially absences, each with the test, lint rule or import that enforces it as its cite. Example:
- The orders part imports nothing from the web part — [eslint.config.js:no-restricted-imports]
Drop the section when the code enforces none; a rule no code enforces is not an invariant. -->
