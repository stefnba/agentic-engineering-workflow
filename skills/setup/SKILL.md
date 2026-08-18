---
name: setup
description: Install the agentic coding workflow into a repository — check prerequisites, interview the three settings, then write work/config.conf, docs/conventions/git.md, and the AGENTS.md pointer. Run once per repo, before any bundle work.
disable-model-invocation: true
model: haiku
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git remote:*), Bash(git branch:*), Bash(git rev-parse:*), Bash(gh auth status:*), Bash(ls:*), Bash(cat:*)
---

# setup

Installs the workflow into a consuming repo. Explore, present, confirm, then write — nothing is
written before the human says yes.

`${CLAUDE_PLUGIN_ROOT}/workflow/git-mechanics.md` owns what the settings mean and why branch names
and the land are not among them.

## What a run writes

| Path                                            | From                                               | Contents                                              |
| ----------------------------------------------- | -------------------------------------------------- | ----------------------------------------------------- |
| `${CLAUDE_PROJECT_DIR}/work/config.conf`        | `${CLAUDE_SKILL_DIR}/templates/config.conf`        | the settings the scripts read                         |
| `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md` | `${CLAUDE_SKILL_DIR}/templates/git-conventions.md` | commit and PR conventions a human follows             |
| `${CLAUDE_PROJECT_DIR}/AGENTS.md`               | `${CLAUDE_SKILL_DIR}/templates/agents-pointer.md`  | one pointer block naming the workflow                 |
| `${CLAUDE_PROJECT_DIR}/.gitignore`              | appended                                           | the `WORKTREE_DIR` value, so worktrees stay untracked |

Two rules the writes must honour:

- **`${CLAUDE_PROJECT_DIR}/work/config.conf` is committed, not ignored.** A clone without it falls
  back to the defaults in the template — which silently lands work on `main` when the integration
  target is `dev`.
- **The `${CLAUDE_PROJECT_DIR}/.gitignore` entry has to match `WORKTREE_DIR`.** They are one decision
  written twice; a non-default `WORKTREE_DIR` with the default ignore line leaves worktrees staged
  for commit.

## Process

Every step reports the same way: a bold heading, then one bullet per item —
`` `name` — value, then the reason ``. Never a table; the human reads these blocks in sequence, and a
shape change reads as a different kind of information. The examples below are the format.

### 1. Check prerequisites

Read `${CLAUDE_SKILL_DIR}/references/prerequisites.md` and check each
one: `git remote -v`, the candidate integration target branch exists, `gh auth status` succeeds.

Report all three lines in this order every run, whatever the outcome — a check the human can't see
is one they'll assume passed. Name the value found, not just the verdict. A check that couldn't run
because an earlier one failed is still `❌`, with the reason it couldn't run.

```markdown
**Prerequisites**

- ✅ Remote — `origin` → `git@github.com:acme/billing.git`
- ✅ Integration target — `main` exists on `origin`
- ✅ Forge CLI — `gh` authenticated as `dana-k`

All three pass. Reading what's already in the repo.
```

**Stop and report if any is missing.** A repo without an authenticated forge CLI cannot derive ticket
status at all, so installing the workflow into it produces a system that reports `unknown` for
everything. Say which check failed, why it blocks the workflow, and give copy-pasteable commands that
fix it — in dependency order when more than one failed, since authenticating precedes creating a
repository and creating one precedes pushing to it. Print the commands; never run them.

````markdown
**Prerequisites**

- ❌ Remote — none configured; `git remote -v` is empty
- ❌ Integration target — can't check, no remote to check against
- ✅ Forge CLI — `gh` authenticated as `dana-k`

**Stopped — nothing written.** Ticket and bundle status are derived from pull request records,
so a repo with no remote reports `unknown` for everything the workflow asks.

If the repository doesn't exist on the forge yet, create it and push:

```bash
git add -A && git commit -m "Initial commit"
gh repo create <name> --private --source=. --remote=origin --push
```

If it already exists, wire up the remote instead:

```bash
git remote add origin <url> && git push -u origin <branch>
```

Then re-run `/setup`.
````

### 2. Explore

Read what exists; don't assume. Report under a **Repository** heading, one bullet per item in the
order below, each naming what was found — `absent` is the normal case for a first run, not a failure:

- `${CLAUDE_PROJECT_DIR}/work/config.conf` — present means this is a re-run; read its current values
  so the settings question offers them rather than the template defaults.
- `${CLAUDE_PROJECT_DIR}/AGENTS.md` and `${CLAUDE_PROJECT_DIR}/CLAUDE.md` — which the repo uses, and
  whether either already carries a pointer block from a prior run.
- `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md` — present means the repo already owns its
  conventions; never overwrite one without asking.
- `${CLAUDE_PROJECT_DIR}/.gitignore` — whether a worktree line is already there.
- The repository's default branch, as the natural `INTEGRATION_TARGET` candidate.

```markdown
**Repository**

- `work/config.conf` — absent; first run, so the settings below start from the template defaults
- `AGENTS.md` — absent, and no `CLAUDE.md` either; the pointer block needs a new `AGENTS.md`
- `docs/conventions/git.md` — absent
- `.gitignore` — found, no worktree line
- Default branch — `main`
```

### 3. Ask the three settings

Ask all three in one round, each with its recommended answer. The template documents what each
controls; don't restate its wording.

- **`INTEGRATION_TARGET`** — the branch bundles land on and ticket branches are cut from. Recommend
  the default branch, **unless** it's protected: required reviews, no direct push, or required linear
  history make it unusable as an integration target, and the repo needs a separate branch such as
  `dev`. Say which case you found.
- **`TICKET_MERGE_METHOD`** — `squash | merge | rebase`, for ticket PRs only.
- **`WORKTREE_DIR`** — where ticket worktrees go.

Branch names and how a finished bundle lands are **not** questions. The workflow fixes both.

### 4. Confirm

**Confirm the decisions, not the file bodies.** The three answered values and which existing files
get touched are what the human is being asked to approve; a pasted template is text they can read in
the plugin any time, and it buries the values inside its own commented defaults.

Report four parts in order, then wait for a yes:

1. **Settings** — the three answered values, one bullet each, with the reason it was chosen. On a
   re-run, name the current value each one replaces.
2. **Writes** — one bullet per path, each with its action: create from template, append the block
   below, or skip with the reason (an existing `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md` is
   theirs and stays).
3. **The appended block, verbatim** — only for files the repo already owns, which is where a wrong
   line actually costs something. Show the lines instead of counting them.
4. **`Proceed?`**

````markdown
**Settings**

- `INTEGRATION_TARGET` — `dev`; `main` is protected (required reviews), so bundles land on `dev`
- `TICKET_MERGE_METHOD` — `squash` (default)
- `WORKTREE_DIR` — `.claude/worktrees` (default)

**Writes**

- `work/config.conf` — create from template, carrying the values above
- `docs/conventions/git.md` — create from template
- `AGENTS.md` — create; repo uses neither AGENTS.md nor CLAUDE.md today
- `.gitignore` — append the block below

Appended to `.gitignore`:

```gitignore
# Agentic workflow worktrees
.claude/worktrees/
```

Proceed?
````

### 5. Write

1. Copy the config template to `${CLAUDE_PROJECT_DIR}/work/config.conf`, substituting the three
   answered values. Keep its comments — they are what a later reader consults.
2. Copy the git-conventions template to `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md`. Skip
   entirely when one already exists; never overwrite it.
3. Append the pointer block to `${CLAUDE_PROJECT_DIR}/AGENTS.md`, or to
   `${CLAUDE_PROJECT_DIR}/CLAUDE.md` when that's what the repo uses — never both. Replace a block
   from a prior run rather than appending a duplicate.
4. Append the `WORKTREE_DIR` value to `${CLAUDE_PROJECT_DIR}/.gitignore` if no matching line is
   there.

### 6. Report

Report an **Installed** bullet per path — written, appended, or skipped with its reason — then the
two things the human owns from here. **Commit
`${CLAUDE_PROJECT_DIR}/work/config.conf`**, and `${CLAUDE_PROJECT_DIR}/docs/conventions/git.md` is
now theirs to edit — a re-run won't overwrite it.

```markdown
**Installed**

- `work/config.conf` — written: `INTEGRATION_TARGET=dev`, `TICKET_MERGE_METHOD=squash`,
  `WORKTREE_DIR=.claude/worktrees`
- `docs/conventions/git.md` — skipped; already present, left untouched
- `AGENTS.md` — created, carrying the pointer block
- `.gitignore` — appended `.claude/worktrees/`

Two things are yours from here:

- **Commit `work/config.conf`.** A clone without it falls back to the template defaults silently —
  which lands work on `main` instead of `dev`.
- `docs/conventions/git.md` is yours to edit. A re-run of `/setup` won't overwrite it.
```
