---
date: 2026-08-08
source: official Claude Code docs (plugins, plugins-reference, plugin-marketplaces, discover-plugins), read against this repo's layout
---

# Docs read: packaging this repo as a Claude Code plugin

**Evidence, not commitments.** Nothing below is decided. This records what the plugin mechanism offers and how this repo maps onto it; whether and when to convert is a backlog/pick question.

---

## Why this is relevant

The README already frames the skills as "meant to be copied into (or eventually installed by) other repos." Plugins are the docs' recommended mechanism for exactly that: a versioned, namespaced, installable bundle of skills + agents + hooks. The docs' own progression matches this repo's status line: iterate in a standalone `.claude/` dir, convert to a plugin when ready to share.

## What a plugin is

A plugin is a directory with one required file, `.claude-plugin/plugin.json`, plus conventional component directories. It can bundle skills, agents, hooks, MCP servers, commands, and default settings. Only `name` is required in the manifest.

This repo is already ~80% in plugin layout — `skills/<name>/SKILL.md` and `agents/*.md` at the top level are exactly what the loader expects. (Today those top-level dirs are inert: Claude Code only auto-loads `.claude/skills/`, not `skills/`.) The docs are ignored by the loader and can stay.

```
agentic-coding/
├── .claude-plugin/
│   └── plugin.json          # the one new required file
├── skills/…                 # already the expected layout
├── agents/…                 # once the planned subagents exist
└── docs/                    # ignored by the loader
```

Minimal manifest:

```json
{
  "name": "agentic-coding",
  "version": "0.1.0",
  "description": "Agentic workflow skills: shape, implement, review, ship, backlog, handoff",
  "repository": "https://github.com/<owner>/agentic-coding",
  "skills": "./skills/",
  "agents": ["./agents/"]
}
```

## Mechanics that matter for this repo's process rules

- **Namespacing.** Installed skills become `/agentic-coding:shape` etc.; agents become `agentic-coding:researcher`. No collisions with a target repo's own skills. Cross-skill references inside the plugin resolve by plain name.
- **Skill frontmatter survives packaging.** `disable-model-invocation`, `context: fork`, `agent:`, and skill-scoped `hooks` all work inside plugins — the shape-time write-boundary hook (skills/README.md, "Settings that carry process rules") ships with the plugin.
- **One limitation:** plugin _agents_ cannot declare their own `hooks`, `mcpServers`, or `permissionMode` (skills can carry hooks). If an agent needs a hook, it must live on the skill that forks into it.
- **`${CLAUDE_PLUGIN_ROOT}`** is the only safe way to reference plugin files from hook commands. Installed plugins are copied to a cache (`~/.claude/plugins/cache/…`) and cannot reference files outside their own directory — relative paths that escape the plugin break after install.
- **Versioning.** Explicit `version` in plugin.json is the pin; users update when it bumps. Without it, fallback is git tag → commit SHA. `claude plugin validate . --strict` checks the bundle before distributing.
- **Path assumptions.** Skill instructions referencing this repo's `docs/` tree would dangle in a target repo. The existing skills already write against a target repo's structure by design; that property has to hold for every skill that ships.

## Three distribution tiers

1. **Local dev, no publishing:** `claude --plugin-dir ~/…/agentic-coding` loads the plugin for one session; `/reload-plugins` picks up edits. The right tier while skills are churning — dogfood against a real codebase without freezing anything.
2. **Install from GitHub:** add `.claude-plugin/marketplace.json` and the repo doubles as a one-plugin marketplace:

   ```json
   {
     "name": "stebau-agentic",
     "owner": { "name": "Stefan Bauer" },
     "plugins": [
       {
         "name": "agentic-coding",
         "source": "./",
         "description": "Agentic workflow skills"
       }
     ]
   }
   ```

   Consumers run `/plugin marketplace add <owner>/agentic-coding`, then `/plugin install agentic-coding@stebau-agentic`. Auto-update is off by default for third-party marketplaces.

3. **Per-repo auto-setup:** a target repo commits `extraKnownMarketplaces` + `enabledPlugins` in its `.claude/settings.json`; anyone trusting the folder is prompted to install. This is how a real product repo would adopt the workflow wholesale.

## Alternatives weighed (none chosen)

- **`~/.claude/skills/`** — personal cross-project reuse; no namespacing, no versioning, no way to hand to a teammate or pin a repo to a version.
- **Copy / symlink / git submodule into each repo's `.claude/`** — works, but the sync problem is yours; installed-plugin caching exists precisely to avoid it.
- **Plugin** — versioned, namespaced, installable, and the docs' explicit recommendation once sharing is the goal.

The tension worth noting: publishing a versioned marketplace implies release discipline, and the workflow skills are still a build plan (skills/README.md, Status). Tier 1 costs nothing now; tiers 2–3 make sense after `shape`/`implement`/`review` exist and stabilize.

## Sources

- https://code.claude.com/docs/en/plugins
- https://code.claude.com/docs/en/plugins-reference
- https://code.claude.com/docs/en/plugin-marketplaces
- https://code.claude.com/docs/en/discover-plugins
