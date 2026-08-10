# Agents — subagent definitions

The subagents that the workflow skills in [skills/README.md](../skills/README.md) fork into. In a consuming repo these land in `.claude/agents/*.md`; here they are reference material, like everything else in this repo.

Skills own the _when_ (invocation, gates, inline vs. fork); agents own the _who_ — the context, tool set, and preloaded knowledge a forked skill runs with.

| Agent           | Serves              | tools                                                | Notes                                                                                                                  |
| --------------- | ------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `critic`        | `critique`          | `Read, Grep, Glob`                                   | Structurally read-only: a critic that can't edit can't "fix" the spec instead of attacking it. `skills: [docs-rules]`. |
| `reviewer`      | `review`            | `Read, Grep, Glob, Bash`                             | Bash for `gh pr diff` and re-running checks. `skills: [docs-rules, evidence]`.                                         |
| `researcher`    | `audit`, `research` | `Read, Grep, Glob, Write, Edit, WebSearch, WebFetch` | Write scope (research/ + backlog only) enforced by hook, not tool list.                                                |
| `ticket-runner` | parallel implement  | full, `isolation: worktree`                          | **Phase 2.** Worktree isolation per ticket is how the claiming protocol scales past one agent.                         |

Two conventions across all of them:

- **Knowledge arrives via `skills:` preload**, not restated in the agent's system prompt — the reference layer (`docs-rules`, `evidence`) is injected in full at startup, so the one-copy rule holds for agents too.
- **Tool lists encode the role's power, hooks encode its boundaries.** What an agent may touch at all is the `tools` list; _where_ it may write within those tools is a hook. Don't try to express path scope in tool lists — it can't.

`critic` exists. `reviewer`, `researcher`, and `ticket-runner` don't yet; this file is the build plan, paired with the skills one.
