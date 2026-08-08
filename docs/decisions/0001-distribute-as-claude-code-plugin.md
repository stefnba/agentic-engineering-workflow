# 0001 Distribute the workflow as a Claude Code plugin

Date: 2026-08-08 · Status: accepted · Areas: repo

## Context

The skills and agents here are built to be consumed by other repos, but nothing defined how they get there — copying by hand was the implicit default, which puts the sync problem on every consumer and offers no versioning or namespacing. The plugin mechanism was researched against this repo's layout in `research/docs-read-2026-08-claude-code-plugins.md`; the repo is already ~80% in plugin form.

## Decision

This repo ships as a Claude Code plugin: `.claude-plugin/plugin.json` at the root, with `skills/` and `agents/` as the component directories. Adoption is tiered — `--plugin-dir` for local use now, while the workflow skills are still being built; marketplace install (`marketplace.json` in this same repo) once they stabilize. Every skill is written plugin-compatible from now on: target-repo paths only, cross-skill references by plain name, hooks declared on skills rather than agents, `${CLAUDE_PLUGIN_ROOT}` in hook commands.

## Rejected

- **`~/.claude/skills/` (personal skill dir)**: reuse for one person only — no namespacing, no versioning, no way to hand the workflow to a teammate or pin a repo to a version.
- **Copy / symlink / git submodule into each consumer's `.claude/`**: works, but every consumer owns the sync problem; the plugin cache exists precisely to remove it.
- **Publishing a marketplace immediately**: versioned distribution implies release discipline, and the workflow skills are still a build plan — freezing interfaces that renamed twice in one afternoon would trade iteration speed for stability nobody consumes yet. Deferred, not rejected outright.

## Costs

- Plugin compatibility is now a constraint on every future skill and agent, not a packaging step at the end — the four rules in the Decision section have to hold continuously.
- The mechanism layer is committed to Claude Code. The process and artifact docs stay tool-agnostic, but any other runtime (the Codex TODO) needs its own separately built mechanism layer.
- Once the marketplace tier ships, version bumps become a standing duty, and consumers can sit on stale pins.

## Revisit if

- A runtime other than Claude Code becomes an execution target rather than a documentation aspiration.
- Release discipline starts fighting iteration speed — the fallback is staying on `--plugin-dir` indefinitely, which loses nothing but shareability.
- The plugin mechanism itself changes materially (caching, namespacing, or the agent-hook limitation).
