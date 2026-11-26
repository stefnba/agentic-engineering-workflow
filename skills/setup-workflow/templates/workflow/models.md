<!-- Fill every slot; delete these comments as you fill. -->

# Models

Which model each kind of work runs on, per harness. Written by the `setup-workflow` skill; edit by hand or rerun that skill.

**Spawn a sub-agent on the cell for its kind of work and the harness you run in.** A human starting a session picks the same cell. A model the human names at dispatch overrides the cell for that dispatch only.

**When the cell is a `TODO`, spawn on the session's own model and say so in your reply.**

<!-- Fill each cell with a model the owner confirmed. Claude Code cells are a
model alias such as `opus` or `sonnet`, or a full model ID. Codex cells are
the model and the `model_reasoning_effort`, such as `gpt-6.1-terra`, `medium`.
Example row:
| Implement | `sonnet` | `gpt-6.1-terra`, `medium` | -->

| Work                | Claude Code            | Codex                 |
| ------------------- | ---------------------- | --------------------- |
| Interview and shape | {{CLAUDE_SHAPE}}       | {{CODEX_SHAPE}}       |
| Spec review         | {{CLAUDE_SPEC_REVIEW}} | {{CODEX_SPEC_REVIEW}} |
| Implement           | {{CLAUDE_IMPLEMENT}}   | {{CODEX_IMPLEMENT}}   |
| Code review         | {{CLAUDE_CODE_REVIEW}} | {{CODEX_CODE_REVIEW}} |

**Keep each review on a model at least as strong as the work it judges, and never in the session that produced that work.** A weaker or same-session reviewer weakens the approval gate without anyone noticing.

**In Codex, name both the model and the reasoning effort in the spawn request.** The request overrides the `[agents]` defaults.
