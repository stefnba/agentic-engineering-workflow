# AGENTS.md

## Goal

Agent skills for an engineering workflow, installed into other repositories: brainstorm and shape work, implement, review, and ship.

This is version 2, designed from an empty tree because version 1 grew too complex.

## Guardrails

- **Treat the files in `docs/` as the owner's working drafts.** They are not settled decisions.
- **Put every skill in `skills/<name>/`.** That folder is the product. To use a skill in this repository, link it: `.agents/skills/<name>` → `../../skills/<name>`.
- **Run the `writing` skill before writing or editing any Markdown file.**
- **Use only mechanisms that both Claude Code and Codex have.** The skills must run under both.
- **Design without the earlier versions.** Tags `v1-final` and `v2-baseline` hold them; read them only when the owner asks.
