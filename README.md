# Agentic Coding Workflow

A **reference repo** for agentic coding: workflow design, documentation structure, tool setup, and reusable skills. It collects the practices — it is not a codebase that follows them.

That distinction matters when reading anything here:

- The docs describe conventions for a _real_ product repo (workspace packages, CI gates, feature bundles). None of that infrastructure exists here, so don't expect the layouts they describe to be present in this tree.
- The skills under `skills/` are meant to be copied into (or eventually installed by) other repos. Their instructions reference paths and structures of a target repo, not this one.
- The conventions this repo does apply to itself are [work/backlog.md](work/backlog.md), which tracks work on the reference material, and [GLOSSARY.md](GLOSSARY.md), a near-empty root vocabulary file — partly to have them, partly to dogfood the format.

## Getting started

Installing this into a repo of your own:

1. **Check the prerequisites** — a git remote, a declared integration target branch, and an
   authenticated forge CLI (`gh`). Ticket status is derived from pull request records, so the forge
   CLI is not optional. Details in
   [skills/setup/references/prerequisites.md](skills/setup/references/prerequisites.md).
2. **Install the plugin**, then run [`/setup`](skills/setup/SKILL.md) in the target repo — a
   placeholder today, so do these by hand for now. It writes:

   | Path                      | What it is                                                                          |
   | ------------------------- | ----------------------------------------------------------------------------------- |
   | `work/config.conf`        | settings the scripts read — from [the template](skills/setup/templates/config.conf) |
   | `docs/conventions/git.md` | commit and PR conventions a human follows                                           |
   | `work/backlog.md`         | empty; unpicked follow-ups and noticed drift accumulate here                        |
   | `GLOSSARY.md`             | empty; your domain's canonical terms, added as they're settled                      |
   | `AGENTS.md`               | one pointer line naming the workflow                                                |
   | `.gitignore`              | your `WORKTREE_DIR`, so ticket worktrees stay untracked                             |

3. **Commit `work/config.conf`.** A clone without it silently falls back to the
   [defaults](#config) — which means work landing on `main` when your integration target is `dev`.

4. Read [docs/walkthrough.md](docs/walkthrough.md) for how a day actually runs.

## The workflow

The contract lives in [workflow/](workflow/) — normative, and what the skills and agents load:

- [lifecycle.md](workflow/lifecycle.md) — the five stages, human gates, and coordination rules
- [artifacts.md](workflow/artifacts.md) — which artifact owns which question, and for how long
- [bundle.md](workflow/bundle.md) — how intent, plan, and tickets cooperate inside a bundle
- [shaping-routes.md](workflow/shaping-routes.md) — which artifacts a given piece of work needs
- [git-mechanics.md](workflow/git-mechanics.md) — worktree basing, ticket claiming, race-safe bundle branches
- [finding-rules](skills/finding-rules/SKILL.md) — what Critic and Reviewer may report, and what survives a round

Prose for humans lives in [docs/](docs/) and is never loaded by an agent:

- [walkthrough.md](docs/walkthrough.md) — running it day to day: which skill, which session tab
- [tool-setup.md](docs/tool-setup.md) — configuring Claude Code for a consuming repo

## Skills

The planned set. Sixteen exist under [skills/](skills/) today — `setup`, `backlog`, `pick`, `interview-me`, `shape`, `critique`, `implement`, `review`, `land`, `bundle-git`, `record-decision`, `glossary`, `handoff`, `recap`, `judge`, and `writing-for-agents`; the rest are named here because the workflow docs refer to them, and are tracked in the backlog. Each name is a pointer — the authoritative description lives in that skill's `SKILL.md` frontmatter.

### Workflow skills

Stage-bound — each realizes one role of the [workflow](workflow/lifecycle.md):

| Name            | Stage     | Purpose                              |
| --------------- | --------- | ------------------------------------ |
| `scan-codebase` | Discover  | Sweeps the repo for drift            |
| `research`      | Discover  | Investigates one topic               |
| `interview-me`  | Discover  | Grills intent until settled          |
| `pick`          | Discover  | Presents candidates; the human picks |
| `shape`         | Shape     | Drafts the bundle, runs critique     |
| `critique`      | Shape     | Attacks the draft bundle             |
| `implement`     | Implement | Executes one ticket to a PR          |
| `review`        | Review    | Judges a ticket's PR                 |
| `land`          | Land      | Absorbs and deletes bundle           |

### Supporting skills

Not stage-bound — they serve any session:

| Name                 | Purpose                                    |
| -------------------- | ------------------------------------------ |
| `setup`              | Installs the workflow                      |
| `bundle-git`         | Claims tickets, reports status, merges PRs |
| `backlog`            | Maintains the backlog file                 |
| `glossary`           | Maintains the domain glossary              |
| `record-decision`    | Writes decision records                    |
| `judge`              | Rules on open design questions             |
| `handoff`            | Compacts a dying session                   |
| `recap`              | Reports the session back to the human      |
| `writing-for-agents` | Reviews agent-facing documents             |

## Agents

The subagents forked skills run in, under [agents/](agents/):

| Name       | Purpose                                                                               |
| ---------- | ------------------------------------------------------------------------------------- |
| `arbiter`  | Rules on an open design question, in a fresh read-only context                        |
| `critic`   | Read-only spec attacker, before the Plan gate                                         |
| `reviewer` | Judges a ticket's PR. Run read-only in a fresh context with no authorship of the diff |

## Output style

One, under [output-styles/](output-styles/). `crisp` keeps responses short and high-level by
default, caps a decision at 3 options plus a recommendation, and applies to the main conversation
only, never to a forked agent. Select it with `"outputStyle": "crisp"` in `.claude/settings.json`.

## Status

Work in progress — the workflow stages are still being designed, and the docs and skills have drifted in places (tracked in the backlog).

## Important

Three things are fixed by the workflow rather than declared by your repo: branch names, branch
strategy, and how a finished bundle branch lands on the integration target. See
[git-mechanics.md](workflow/git-mechanics.md) for each rule and why it is not a setting.

## Config

Three settings, in `work/config.conf`: `INTEGRATION_TARGET`, `TICKET_MERGE_METHOD`, and
`WORKTREE_DIR`. [The template](skills/setup/templates/config.conf) documents what each controls and
its default, and is the copy to read — nothing else restates those values.
