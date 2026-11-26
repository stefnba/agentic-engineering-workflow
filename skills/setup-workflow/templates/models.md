<!-- Template for docs/conventions/models.md, the table every skill that spawns a sub-agent reads. The setup skill copies it verbatim, dropping this comment, when the file is absent; the cells are the workflow's defaults and the repository edits them as its models change. -->

# Models

Which model each kind of work runs on, per harness. A skill that spawns a sub-agent reads its row
and spawns on that cell; a human starting a session picks the same cell. A model the human names
at dispatch overrides the cell for that dispatch only.

| Work                                              | Claude Code | Codex                   |
| ------------------------------------------------- | ----------- | ----------------------- |
| Shape (`interview-me`, `shape-bundle` session)    | `opus`      | `gpt-6.1-sol`, `high`   |
| Critique (`critique-bundle` sub-agents)           | `opus`      | `gpt-6.1-sol`, `high`   |
| Implement (`implement-bundle` sub-agents)         | `sonnet`    | `gpt-6.1-sol`, `medium` |
| Review (`review-pr`, `review-changes` sub-agents) | `opus`      | `gpt-6.1-sol`, `high`   |
| Scan (`scan-codebase` sub-agents)                 | `opus`      | `gpt-6.1-sol`, `high`   |

**Keep Review and Critique on a model at least as strong as the work they judge**, and never in
the session that produced it — a cheaper or same-session reviewer weakens the Accept gate without
anyone noticing.

Codex cells are the model and `model_reasoning_effort`; name both in the spawn request, which
beats the `[agents]` defaults.
