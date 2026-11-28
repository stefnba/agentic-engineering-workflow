# Agent failure modes

Ways coding agents go wrong in everyday use, independent of any one tool or workflow.

## Workflows need a foundation that greenfield lacks

- **Workflows fit brownfield:** existing workflows, and the ones designed here so far, work well when code, structure and use cases exist and the task is to add a feature.
- **Greenfield gives nothing to anchor on:** a new repository has no code organization and no basic use cases. The agent fills the gap with whatever it thinks best.
- **No path from small to solid:** no workflow guides starting small and building the foundation step by step.
- **Cause unclear:** the gap may lie in the process or in how the user works with agents.

## Agents act on decisions nobody made

- **Details become foundations:** a small implementation detail slips past review and later becomes the base for further decisions you never intended.
- **Status is invisible:** it is unclear what is settled, what is a working assumption, and what may change soon.

## Agents produce too much

- **Work splits into fragments:** five or six tiny backlog items come out of a single ticket, leaving a long, unstructured backlog.
- **Records multiply:** agents are too eager to write decision records and backlog items.

## Agents leave references that rot

- **Temporary docs cite each other:** they go stale together and then mislead later agents.
- **Comments cite docs:** a code comment says "see `docs/…`" instead of stating the reason. The doc gets moved, rewritten or deleted, and the comment keeps pointing at something that no longer says what it claimed.
- **Comments cite briefs:** a code comment names the brief or ticket the code came from. The brief is gone once the work ships, and the code now leans on context nobody can read.

## Agent suggestions and reviews can't be trusted at face value

- **No conviction:** the agent suggests something, you challenge it, and it immediately agrees it wasn't needed. You can't tell whether the suggestion was ever worth making.
- **No sense of scope:** design reviews return many points that don't fit what you're trying to achieve and that overcomplicate the design.
- **No calibration:** major problems and trivial findings arrive in the same list with the same weight, so you can't tell which matter.
- **Bias toward adding:** the default is always more features, more safeguards and more complexity, never "this is fine as it is".
- **No provenance:** an output doesn't say whether a claim was verified (the agent ran it, read it or tested it) or just assumed from context, so you can't tell what you can rely on.
