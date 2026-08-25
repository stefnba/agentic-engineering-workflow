# Agentic Engineering Workflow

A **reference repo** for agentic engineering: workflow design, documentation structure, tool setup, and reusable skills. It collects the practices — it is not a codebase that follows them.

That distinction matters when reading anything here:

- The docs describe conventions for a _real_ product repo (workspace packages, CI gates, feature bundles). None of that infrastructure exists here, so don't expect the layouts they describe to be present in this tree.
- The skills under `skills/` are meant to be copied into (or eventually installed by) other repos. Their instructions reference paths and structures of a target repo, not this one.
- The conventions this repo does apply to itself are [work/backlog.md](work/backlog.md), which tracks work on the reference material, and [GLOSSARY.md](GLOSSARY.md), a near-empty root vocabulary file — partly to have them, partly to dogfood the format.
- It's work in progress: the workflow stages are still being designed, and the docs and skills have drifted in places, tracked in that same backlog.

## How the workflow works

Five stages, three human gates:

| Stage       | What happens                                         | Gate after |
| ----------- | ---------------------------------------------------- | ---------- |
| `Discover`  | Pick, research, or scan your way to a settled intent | Pick       |
| `Shape`     | Draft a bundle (spec, plan, tickets), critique it    | Plan       |
| `Implement` | Build one ticket to a PR                             | —          |
| `Review`    | A fresh, independent reviewer judges the PR          | Accept     |
| `Land`      | Merge every ticket, fold in docs, delete the bundle  | —          |

The contract behind that table lives in [workflow/](workflow/) — normative, and what the skills and
agents load. Its files split on one axis: [lifecycle.md](workflow/lifecycle.md) owns sequencing,
every other file owns one subject. A rule that is both stage-bound and subject-bound would
otherwise have two legitimate homes and end up written in both, so it lives with its subject and
the stage links to it.

- [lifecycle.md](workflow/lifecycle.md) — the five stages, human gates, and coordination rules
- [artifacts.md](workflow/artifacts.md) — which artifact owns which question, and for how long
- [bundle.md](workflow/bundle.md) — the bundle container: layout, completeness, slicing, revision
- [shaping-routes.md](workflow/shaping-routes.md) — which artifacts a given piece of work needs
- [git-mechanics.md](workflow/git-mechanics.md) — worktree basing, ticket claiming, race-safe bundle branches
- [components.md](workflow/components.md) — how a role becomes a skill or agent, and the plugin rules
- [finding-rules](skills/finding-rules/SKILL.md) — what a Critic or Reviewer may report, and what
  survives a round; a preloaded skill rather than a `workflow/` doc, per the split components.md owns

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
   | `work/bundles/.gitkeep`   | keeps `work/bundles/` tracked before the first bundle                               |
   | `GLOSSARY.md`             | empty; your domain's canonical terms, added as they're settled                      |
   | `AGENTS.md`               | one pointer line naming the workflow                                                |
   | `.gitignore`              | your `WORKTREE_DIR`, so ticket worktrees stay untracked                             |

3. **Commit `work/config.conf`.** A clone without it silently falls back to the
   [defaults](#configuration) — which means work landing on `main` when your integration target is `dev`.
4. **Optional: turn on the output style.** `/setup` doesn't write this — see
   [Output style](#output-style) below. For everything else about configuring Claude Code itself in
   a consuming repo, see [docs/tool-setup.md](docs/tool-setup.md).
5. Continue with [Using it day to day](#using-it-day-to-day) below for how a session actually runs.

## Using it day to day

You'd normally use two kinds of agent sessions:

- **One tab for the entire bundle lifecycle** — runs Discover, Shape, and later Land.
- **One tab per ticket** — runs Implement, and dispatches that ticket's own Review → fix loop.

You dispatch each stage by hand; each stage's inner loop (critique, review rounds) runs itself
without you retriggering it.

Full walkthrough — entry points, what each gate looks like in practice, the review → fix loop,
landing, and edge cases like abandoning a bundle or a sibling ticket conflict — lives in
[docs/walkthrough.md](docs/walkthrough.md).

## Skills

Skills live under [skills/](skills/), grouped by role below. Each name is a pointer — the
authoritative description lives in that skill's `SKILL.md` frontmatter.

### Workflow skills

Stage-bound — each realizes one role of the [workflow](workflow/lifecycle.md):

| Name               | Stage     | Purpose                              |
| ------------------ | --------- | ------------------------------------ |
| `scan-codebase`    | Discover  | Surveys code design and quality      |
| `research`         | Discover  | Investigates one topic               |
| `interview-me`     | Discover  | Grills intent until settled          |
| `pick`             | Discover  | Presents candidates; the human picks |
| `shape-bundle`     | Shape     | Drafts the bundle, runs critique     |
| `critique-bundle`  | Shape     | Attacks the draft bundle             |
| `implement-ticket` | Implement | Executes one ticket to a PR          |
| `review-pr`        | Review    | Judges a ticket's PR                 |
| `complete-ticket`  | Review    | Merges the accepted ticket PR        |
| `land-bundle`      | Land      | Absorbs and deletes bundle           |

### Bundle & ticket skills

Not stage-bound — query or change bundle/ticket state from any session:

| Name             | Purpose                                       |
| ---------------- | --------------------------------------------- |
| `bundle-state`   | Reports bundle/ticket status; claims a ticket |
| `abandon-bundle` | Abandons a bundle that won't land             |

### Reference skills

Knowledge, not procedure — loaded on demand by other skills or invoked directly:

| Name                 | Purpose                                             |
| -------------------- | --------------------------------------------------- |
| `code-design`        | Vocabulary for module and seam design               |
| `tdd`                | Red–green loop for building behavior                |
| `writing-for-agents` | Reviews agent-facing documents                      |
| `finding-rules`      | What a finding may claim, and what survives a round |

### Supporting skills

Not stage-bound, not a bundle/ticket or reference skill — everything else that serves any session:

| Name              | Purpose                               |
| ----------------- | ------------------------------------- |
| `setup`           | Installs the workflow                 |
| `backlog`         | Maintains the backlog file            |
| `glossary`        | Maintains the domain glossary         |
| `record-decision` | Writes decision records               |
| `judge`           | Rules on open design questions        |
| `review-changes`  | Reviews local changes without a PR    |
| `handoff`         | Compacts a dying session              |
| `recap`           | Reports the session back to the human |

## Agents

The subagents forked skills run in, under [agents/](agents/):

| Name         | Purpose                                                                               |
| ------------ | ------------------------------------------------------------------------------------- |
| `arbiter`    | Rules on an open design question, in a fresh read-only context                        |
| `critic`     | Read-only spec attacker, before the Plan gate                                         |
| `researcher` | Gathers topic evidence into docs/research/ plus backlog lines, in the background      |
| `reviewer`   | Judges a ticket's PR. Run read-only in a fresh context with no authorship of the diff |
| `scanner`    | Surveys code for design and quality findings, read-only in a fresh context            |

## Output style

One, under [output-styles/](output-styles/). `crisp` keeps responses short and high-level by
default, caps a decision at 3 options plus a recommendation, and applies to the main conversation
only, never to a forked agent. Select it with `"outputStyle": "crisp"` in `.claude/settings.json`.

## Configuration

Fixed by the workflow, not your repo: branch names, branch strategy, and how a finished bundle
branch lands on the integration target. See [git-mechanics.md](workflow/git-mechanics.md) for each
rule and why it isn't a setting.

Yours to set, in `work/config.conf`: `INTEGRATION_TARGET`, `TICKET_MERGE_METHOD`, and
`WORKTREE_DIR`. [The template](skills/setup/templates/config.conf) documents what each controls and
its default — the copy to read; nothing else restates those values.
