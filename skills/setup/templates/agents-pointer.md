<!-- The setup skill appends everything below this comment, verbatim, to the consuming repo's
AGENTS.md — or CLAUDE.md, whichever that repo uses, never both — replacing a block from a prior run
rather than duplicating it. Drop this comment when copying. Nothing below may use a `${...}`
placeholder: project instructions expand none of them, so a plugin file is reachable only by naming
the skill that loads it, and this repo's own files by relative link. -->

## Agentic coding workflow

This repository uses the agentic coding workflow, installed as the `agentic-workflow` plugin.

Read [docs/conventions/git.md](docs/conventions/git.md) before any commit, branch, worktree, or PR.

Read [work/config.conf](work/config.conf) before assuming an integration target, merge method, or
worktree path — it holds this repository's values, and the workflow's scripts run on them.

Two files outlive every bundle:

- [work/backlog.md](work/backlog.md) — candidate work and follow-ups nobody has picked yet. Don't
  edit it directly; invoke the `backlog` skill to add, complete, or look up a line.
- [GLOSSARY.md](GLOSSARY.md) — this repository's canonical domain terms and the synonyms it
  rejects. Use its terms in prose and identifiers; invoke the `glossary` skill to add or rename one.
