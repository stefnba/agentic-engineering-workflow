# Skills build plan

Mechanism commitments — invocation, context, agent — for the workflow skills and subagents not yet built, derived from the conventions in [docs/skills.md](../docs/skills.md); skill _content_ stays unspecified until shaping. When one is built, its row moves into frontmatter and the README inventory picks it up — delete the row here. The file goes with its last row.

| Skill  | Stage    | Invocation      | Context | Notes                                                                                                                                                            |
| ------ | -------- | --------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `pick` | Discover | `/pick`, manual | inline  | Dialogue — human picks from the backlog; presents candidates neutrally, routes to interview or shape, ends with prune. `backlog` stays the artifact's caretaker. |

| Agent           | Serves             | tools                       | Notes                                                                                    |
| --------------- | ------------------ | --------------------------- | ---------------------------------------------------------------------------------------- |
| `ticket-runner` | parallel implement | full, `isolation: worktree` | **Phase 2.** Worktree isolation per ticket is how ticket claiming scales past one agent. |
