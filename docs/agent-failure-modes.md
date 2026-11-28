# Agent failure modes

## Greenfield isn't really supported

- Existing workflows assume the basic structure and use cases are already decided. In a new repo nothing is, and the agent proceeds as if it were.

## Agents decide things you didn't ask them to decide

- A small implementation detail slips past review and later becomes the foundation for further decisions that you never intended.
- It is unclear what is settled, what is a working assumption, and what may change soon.

## Agents produce too much

- Five or six tiny backlog items come out of a single ticket, leaving a long, unstructured backlog.
- Agents are too eager to write decision records or backlog items.
- Temporary docs reference each other, go stale, and then mislead later agents.

## Agents point code at Markdown files

- **Comments cite docs:** a code comment says "see `docs/…`" instead of stating the reason. The doc gets moved, rewritten or deleted, and the comment keeps pointing at something that no longer says what it claimed.
- **Comments cite briefs:** a code comment names the brief or ticket the code came from. The brief is gone once the work ships, and the code now leans on context nobody can read.

## Agent suggestions and reviews can't be trusted at face value

- **No conviction:** the agent suggests something, you challenge it, and it immediately agrees it wasn't needed. You can't tell whether the suggestion was ever worth making.
- **No sense of scope:** design reviews return many points that don't fit what you're trying to achieve and that overcomplicate the design.
- **No calibration:** major problems and trivial findings arrive in the same list with the same weight, so you can't tell which matter.
- **Bias toward adding:** the default is always more features, more safeguards and more complexity, never "this is fine as it is".
- **No provenance**: an output doesn't say whether a claim was verified (the agent ran it, read it or tested it) or just assumed from context, so you can't tell what you can rely on.
