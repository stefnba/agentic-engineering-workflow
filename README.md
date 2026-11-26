# Agentic Engineering Workflow

Agent skills for one engineering loop: shape work, implement, review and ship. A skill is a folder you install into your own repository, and each one runs under both Claude Code and Codex.

Status: version 2 is in design and not ready for use. The skills for implementing, reviewing and shipping do not exist yet, and the way to install a skill is still to come.

## Skills

Each skill is one folder under `skills/`.

| Skill                                                    | What it does                                                                                                                     |
| -------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| [`setup-workflow`](skills/setup-workflow/SKILL.md)       | Records a repository's target branch, check commands, tracker labels and models in `docs/workflow/`, for the other skills to read |
| [`writing`](skills/writing/SKILL.md)                     | Rules for Markdown that steers an agent or explains something to a reader                                                        |
| [`write-repo-readme`](skills/write-repo-readme/SKILL.md) | Decides what a root README contains, and runs every command before showing it                                                    |

## Work on this repository

To use a skill in this repository, link it from the repository root:

```bash
ln -s ../../skills/<name> .agents/skills/<name>
```

`.claude/skills` points to `.agents/skills`, so Claude Code and Codex both see the link. [`AGENTS.md`](AGENTS.md) holds the rules for changing a skill.

## More

Both of these are working drafts, not settled decisions.

- [`docs/workflow-design.md`](docs/workflow-design.md): the design, with each item marked decided, assumed or open.
- [`docs/research/`](docs/research/): facts about how reference projects solve the same problems.
