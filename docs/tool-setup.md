# Tool setup

## Claude Code

### Getting started

1. Copy the JSON block below into `.claude/settings.json` at the repo root.
2. If the repo needs MCP servers, add them to a **separate** `.mcp.json` at the repo root — not inside `settings.json` (see [MCP servers](#mcp-servers) below).
3. **Restart Claude Code.** Settings that shape the system prompt/tool catalogue (skills, workflows, tool removal) are assembled at session start — editing the file mid-session and re-running `/context` won't show the change.
4. Verify the config actually loaded (see [Verify it's working](#verify-its-working)).
5. Edit the sensitive-file entries in `deny` to match what this specific repo actually has (see [Protecting secrets](#protecting-secrets)) — the list below is a starting point, not a universal list.

> **Note:** the file must be valid JSON — no `//` comments, no trailing commas. JSONC support is an [open feature request](https://github.com/anthropics/claude-code/issues/17968), not shipped yet. Editors like Cursor/VS Code still give schema autocomplete on a plain `.json` file via the SchemaStore catalog — no `$schema` line needed.

### Reduce tokens: trim the default system prompt/toolset

- [How To Kill The Bloat In Claude Code's System Prompt](https://www.aihero.dev/how-to-kill-the-bloat-in-claude-codes-system-prompt)
- [Claude Code settings reference](https://code.claude.com/docs/en/settings) — full list of every settings key (`[Available settings](https://code.claude.com/docs/en/settings#available-settings)` table)
- [Claude Code permissions reference](https://code.claude.com/docs/en/permissions) — permission rule syntax, scopes, precedence

```json
{
  "permissions": {
    "deny": [
      "EnterPlanMode",
      "ExitPlanMode",
      "DesignSync",
      "NotebookEdit",
      "SendMessage",
      "PushNotification",
      "RemoteTrigger",
      "ReportFindings",
      "ScheduleWakeup",
      "AskUserQuestion",
      "CronCreate",
      "CronDelete",
      "CronList",
      "Read(.env)",
      "Read(.env.local)",
      "Read(.env.production)",
      "Read(.env.development)",
      "Read(.env.staging)",
      "Read(secrets/**)",
      "Read(config/credentials.json)"
    ]
  },
  "disableBundledSkills": true,
  "disableWorkflows": true,
  "disableRemoteControl": true,
  "disableClaudeAiConnectors": true,
  "disableArtifact": true,
  "autoMemoryEnabled": false,
  "disableDeepLinkRegistration": "disable",
  "disableAgentView": true
}
```

| Key                                                                    | What it does                                                                                                                                                                                                          | Docs                                                                                                                |
| ---------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `permissions.deny` (bare tool names)                                   | Removes each named tool from Claude's context entirely — this is what actually saves tokens, vs. a scoped rule like `Bash(rm *)` which just blocks a call while leaving the tool's schema loaded.                     | [Tool name wildcards](https://code.claude.com/docs/en/permissions#tool-name-wildcards)                              |
| `permissions.deny` (`Read(...)` entries)                               | Blocks `Read`/`Edit` and recognized Bash file-reads on listed paths. See [Protecting secrets](#protecting-secrets) for the coverage gap.                                                                              | [Read and Edit rules](https://code.claude.com/docs/en/permissions#read-and-edit)                                    |
| `disableBundledSkills`                                                 | Drops Anthropic's bundled skills from the tool catalogue. Use `skillOverrides` instead to keep specific ones rather than all-or-nothing.                                                                              | [Available settings](https://code.claude.com/docs/en/settings#available-settings)                                   |
| `disableWorkflows`                                                     | Removes the multi-agent Workflow tool. Paired with the bare-name denies above (`DesignSync`, `SendMessage`, etc.), which are that system's individual sub-tools.                                                      | [Available settings](https://code.claude.com/docs/en/settings#available-settings)                                   |
| `disableAgentView`                                                     | Turns off `claude agents`, `--bg`, `/background` — the dashboard for running separate, independent sessions. **Does not** affect subagents (Task tool) running inside a single session, including backgrounding them. | [Agent view](https://code.claude.com/docs/en/agent-view) · [Sub-agents](https://code.claude.com/docs/en/sub-agents) |
| `disableRemoteControl`, `disableClaudeAiConnectors`, `disableArtifact` | Trim remote-control, claude.ai connector, and artifact tooling if unused in this repo.                                                                                                                                | [Available settings](https://code.claude.com/docs/en/settings#available-settings)                                   |
| `autoMemoryEnabled: false`                                             | Stops Claude Code from writing memory files automatically.                                                                                                                                                            | [Available settings](https://code.claude.com/docs/en/settings#available-settings)                                   |

**Optional, situational addition:**

```json
"includeGitInstructions": false
```

Removes the built-in commit/PR workflow instructions and the automatic git status snapshot from the system prompt. Worth adding _only_ if the repo documents its own git conventions (in `docs/agents/git.md`) — Claude still has full Bash access either way and can run `git diff`/`git status`/`git branch` itself, it just won't have that context pre-loaded for free every turn. ([Available settings](https://code.claude.com/docs/en/settings#available-settings))

### Protecting secrets

- `Read(...)` deny rules also cover `Edit`/`Write` on the same paths and recognized Bash reads (`cat`, `head`, `tail`, `sed`) — but **not** the dedicated `Grep`/`Glob` tools or arbitrary Bash tricks (e.g. `grep -r` from a parent directory). Treat these rules as a guardrail against casual reads, not a hard boundary. ([Read and Edit rules](https://code.claude.com/docs/en/permissions#read-and-edit))
- For an actual hard boundary, enable [sandboxing](https://code.claude.com/docs/en/sandboxing) — it enforces at the OS level, across every tool and subprocess. See also [how permissions interact with sandboxing](https://code.claude.com/docs/en/permissions#how-permissions-interact-with-sandboxing).
- Avoid a blanket `Read(.env.*)` if the repo has a `.env.example`/`.env.sample` template — the wildcard blocks that too, and a deny rule can't be carved back open with an allow rule (deny always wins regardless of specificity). List the real variants instead.

### MCP servers

MCP servers go in `.mcp.json` at the repo root — **not** nested under a `mcp` key in `settings.json`. See [MCP quickstart](https://code.claude.com/docs/en/mcp-quickstart) and the [MCP reference](https://code.claude.com/docs/en/mcp) (server config shape, tool search/deferred loading, org controls).

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": { "Authorization": "Bearer ${GITHUB_TOKEN}" }
    }
  }
}
```

- Never hardcode secrets — reference env vars with `${VAR}` / `${VAR:-default}`; each developer exports their own locally.
- First-run approval is by design: anyone cloning the repo gets prompted to approve each server before it runs. Pre-approve specific servers for CI with `enabledMcpjsonServers`, or all of them with `enableAllProjectMcpServers: true`, in `.claude/settings.json`. ([Available settings](https://code.claude.com/docs/en/settings#available-settings))
- MCP tool schemas are deferred by default (Tool Search) — connecting a server doesn't load its full toolset into context upfront, only names + a short instruction blurb. The main lever for trimming MCP token cost is fewer connected servers, not fewer tools within one. ([MCP reference](https://code.claude.com/docs/en/mcp))
- MCP-specific permission rules (`mcp__server__tool`) are documented under [Permissions → MCP](https://code.claude.com/docs/en/permissions#mcp).

### Output styles

Different from everything above — output styles change _how Claude responds_ (role, tone, output format), not what tools it has. They modify the system prompt, same mechanism as the token-reduction settings, so they're worth knowing about even if your repo doesn't need one yet. For project conventions/codebase context, use `CLAUDE.md` instead — output styles are for changing Claude's voice or default format, not teaching it about the repo.

Three built-in styles beyond the default: **Proactive** (acts on reasonable assumptions instead of pausing), **Explanatory** (adds educational "Insights" while coding), **Learning** (leaves `TODO(human)` markers for you to fill in). Set one with:

```json
"outputStyle": "Explanatory"
```

Custom styles are Markdown files with frontmatter, stored in `.claude/output-styles/`. Full reference, including how to keep vs. drop Claude Code's built-in coding instructions: [Output styles](https://code.claude.com/docs/en/output-styles).

### Verify it's working

```
/doctor        → flags invalid/stripped settings, duplicate installs, config issues
/context       → confirm System tools / System prompt / Skills shrank vs. baseline
```

`/status` and `/permissions` are both documented commands, but neither is guaranteed to be available — some hosts/extensions/embeds only expose a subset of slash commands. `/doctor` and `/context` are the two to rely on; if either of those also errors, the environment likely doesn't support interactive slash commands at all, and `claude doctor` from a terminal (outside any session) is the fallback that doesn't depend on them.

If numbers don't move: restart the session first before assuming the config is wrong — see [Debug your configuration](https://code.claude.com/docs/en/debug-your-config) for the fuller troubleshooting flow (settings precedence, env var overrides, `/mcp` for server-specific issues).

## Codex

_TODO_
