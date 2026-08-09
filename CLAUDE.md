@AGENTS.md

## Claude Code specifics

- `.claude/skills/` and `.claude/agents/` are symlinks into `skills/` and `agents/` — this repo installs its own reference material for dogfooding. When adding a skill or agent, add the matching symlink; it loads at the next session start, not mid-session.
