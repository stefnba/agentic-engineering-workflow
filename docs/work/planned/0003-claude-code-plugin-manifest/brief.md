# 0003 — Claude Code plugin manifest

## Problem

This repo committed to shipping as a Claude Code plugin ([decision 0001](../../../decisions/0001-distribute-as-claude-code-plugin.md)), but the one file that makes it a plugin — `.claude-plugin/plugin.json` — doesn't exist. Nothing currently loads via `--plugin-dir`, and `${CLAUDE_PLUGIN_ROOT}` has nothing to resolve to, which is what's blocking the standing backlog item to migrate `shape`'s write-boundary hook off `${CLAUDE_PROJECT_DIR}`. The repo is layout-ready (`skills/`, `agents/` already match the loader's expected component dirs per `docs/research/docs-read-2026-08-claude-code-plugins.md`) but not actually loadable as a plugin yet.

## Constraints

- Manifest lives at `.claude-plugin/plugin.json`, repo root — the only required file.
- Tier 1 only (`--plugin-dir` local dev): no `marketplace.json`, no publishing. Decision 0001 explicitly deferred marketplace distribution until the workflow skills stabilize.
- Must declare `skills` and `agents` pointing at the existing `skills/` and `agents/` directories without changing their current layout or the existing `.claude/skills` / `.claude/agents` symlink setup used for local dev today.
- Should leave the repo in a state where the deferred backlog item (migrating `shape`'s write-boundary hook to `${CLAUDE_PLUGIN_ROOT}`) is actually unblocked, not just theoretically possible.
- Repo has a real GitHub remote (`github.com/stefnba/agentic-coding`) — no placeholder URLs needed.

## Motivation

Decision 0001 made the call but nothing since has produced the loadable artifact — the repo is still just a plan to be a plugin. Landing the manifest turns that into something real: it can be dogfooded via `--plugin-dir` immediately, and it clears the way for the hook-migration backlog item that's currently stuck waiting on `${CLAUDE_PLUGIN_ROOT}` to resolve.
