---
name: setup-workflow
description: Use when a repository has no `docs/workflow/` folder, when another workflow skill reports a file in it missing or incomplete, or when the user says "set up the workflow", "install the workflow here" or "rerun setup". Also use when the target branch, a check command, an app or package of a monorepo, the tracker labels or the models for the workflow change.
---

# Set up the workflow

The repository has a `docs/workflow/` folder that holds the facts the workflow skills read, a `docs/conventions/` folder that holds its own git and naming rules, and both instruction files point to them.

## Guardrails

**Write only these:** the files in `docs/workflow/`, the files the next rule allows in `docs/conventions/`, the workflow block in `AGENTS.md`, and the import line in `CLAUDE.md`. Every other line of those files belongs to the owner.

**In `docs/conventions/`, create a missing file and leave an existing one as it is.** An existing file holds the owner's rules, which outlive the workflow. Report a conflict with `docs/workflow/` instead of editing it.

**Record a value only when you observed it or the owner confirmed it.** Every later skill runs the commands and uses the models in `docs/workflow/` as written, so a guessed value fails far from here. Write a gap as `TODO: <question for the owner>`.

**Write nothing and create no label before the owner answers yes in the confirm step.** Labels are visible to everyone with access to the repository.

**Leave every change uncommitted.** The owner reviews the diff first.

## Process

**Report each step in the shape of its example:** a bold heading, then one bullet per item, written as `item — value, then the reason`. The examples are the format; the values in them are invented.

### 1. Check the prerequisites

**Run these from the folder the owner named, or the current folder, and keep the output:**

```bash
git rev-parse --show-toplevel
git remote get-url origin
git symbolic-ref --short refs/remotes/origin/HEAD
gh auth status
```

**If `git symbolic-ref` fails, read the default branch from `git remote show origin`.**

**Report every line of the example below on every run, whatever the outcome**, each with the value found. The git repository line is `❌` when `git rev-parse` fails. The remote line is `❌` when there is no remote or it is not on GitHub. A check that could not run because an earlier one failed is still `❌`, with the reason it could not run.

```markdown
**Prerequisites**

- ✅ Git repository — root at `/home/dana/billing`
- ✅ Remote — `origin` → `git@github.com:acme/billing.git`
- ✅ Default branch — `main` on `origin`
- ✅ GitHub CLI — `gh` logged in as `dana-k`

All pass. Reading what is already in the repository.
```

**If any line is `❌`, stop and write nothing.** Say why the workflow needs it: work items are GitHub issues, and status is read from issues and pull requests. Then print the commands that fix it, in the order they must run, and leave running them to the owner.

| Failure                                        | Commands to print                                                                                              |
| ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| Not a git repository                           | `git init`, `git add -A`, `git commit -m "Initial commit"`, then the commands of the next failure that applies |
| `gh` not logged in                             | `gh auth login`                                                                                                |
| No remote, and no repository on GitHub yet     | `gh repo create <name> --private --source=. --remote=origin --push`                                            |
| No remote, and the repository exists on GitHub | `git remote add origin <url>`, then `git push -u origin <branch>`                                              |
| Remote not on GitHub                           | None. Say that only GitHub issues are supported as a tracker so far.                                           |

**Close a stop with "Then rerun `setup-workflow`."**

Done when every line is `✅`, or the owner has the report and the commands.

### 2. Read the repository

**Report each item below under a Repository heading, in this order, naming what you found.** `absent` is the normal value on a first run, not a failure.

- **`docs/workflow/`:** present means a rerun. Read its files and offer their values as the proposal in the confirm step.
- **`docs/conventions/`:** name each file. Note each fact that a `docs/workflow/` file would also state, such as a branch name for workflow work or a worktree path.
- **`AGENTS.md` and `CLAUDE.md`:** which exist, whether `AGENTS.md` holds the workflow markers, and whether `CLAUDE.md` holds `@AGENTS.md`.
- **Default branch protection:** run both commands below, with the default branch in place of `<branch>`. For an unprotected branch the first returns HTTP 404 with "Branch not protected", and the second returns `[]`. Confirm: what the first returns for a caller without admin rights was not verified when this skill was written. When a call fails in any other way, report `unknown` and ask the owner in the confirm step.

  ```bash
  gh api "repos/{owner}/{repo}/branches/<branch>/protection"
  gh api "repos/{owner}/{repo}/rules/branches/<branch>"
  ```

- **Layout:** check these in order and stop at the first that hits. Name the signal and the directories it found, or say single area and name what you checked.
  1. A workspace declaration: `pnpm-workspace.yaml`, `workspaces` in the root `package.json`, `[workspace]` in `Cargo.toml`, `[tool.uv.workspace]` in `pyproject.toml`, `go.work`.
  2. A monorepo build tool at the root: `turbo.json`, `nx.json`, `lerna.json`, `rush.json`, `moon.yml`.
  3. More than one manifest below the root, by the globs `*/<manifest>` and `*/*/<manifest>` for `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `build.gradle*`, `pom.xml`.
- **Areas and checks:** one bullet per area, with its path and its check commands. Take the commands as written in the area's manifest, its task runner file and the CI configuration, and name the file each came from. When CI runs an area's checks from another directory, such as the root, name that directory.
- **Commit style**, only when `docs/conventions/git.md` is missing: whether the last 30 subjects of `git log --format=%s` follow the `type(scope): summary` shape, and the merge methods `gh repo view --json squashMergeAllowed,mergeCommitAllowed,rebaseMergeAllowed` reports.

**Treat the layout as a reading the owner confirms.** A vendored dependency or an examples folder trips the manifest glob.

```markdown
**Repository**

- `docs/workflow/` — absent; first run
- `docs/conventions/` — `git.md` found; it names worktrees `.worktrees/`, which `docs/workflow/git.md` would also state
- `AGENTS.md` — found, no workflow markers; `CLAUDE.md` absent
- Protection of `main` — required reviews, from the branch protection call
- Layout — monorepo; `pnpm-workspace.yaml` declares `apps/web`, `apps/api`, `packages/ui`
- `web` — `apps/web`; `pnpm test`, `pnpm lint`, from `apps/web/package.json` and `.github/workflows/ci.yml`
- `api` — `apps/api`; `pnpm test`, from `apps/api/package.json`
- `ui` — `packages/ui`; no checks found
- Commit style — 27 of the last 30 subjects follow `type(scope): summary`; squash merges only
```

Done when each slot of the templates in `templates/workflow/` in this skill's folder has an observed value or a named gap.

### 3. Confirm with the owner

**Confirm the decisions, not the file bodies.** The owner can read the templates any time; pasted whole, they bury the values.

**Send one message in plain chat with these parts in order, then wait for a yes:**

1. **Settings:** one bullet per value, with its source. On a rerun, name the value it replaces.
2. **Questions:** one bullet per gap, with your proposal.
3. **Writes:** one bullet per path, with its action, which is create from template, update, skip with the reason, or add the block below.
4. **Labels:** the labels to create. Compare `gh label list --limit 200` with the labels in `templates/workflow/tracker.md` and one `area:<name>` label per area.
5. **Verbatim text:** the workflow block and the `@AGENTS.md` line, shown in full, only for an instruction file that already exists.
6. **`Proceed?`**

**Ask in the questions part:**

- **The target branch.** Propose the default branch. If it requires reviews, blocks direct pushes or requires linear history, or its protection is `unknown`, ask whether feature branches may merge into it or whether work lands on another branch such as `dev`.
- **The models.** Ask for each cell of `templates/workflow/models.md`. Models cannot be observed in the repository.
- **Each conflict** noted under `docs/conventions/`: which value `docs/workflow/` should hold.
- **The issue types** in `templates/workflow/tracker.md`: whether they exist on the account. `gh issue create --type` sets a type, but `gh` has no command that lists them.
- **The commit style**, when the history does not follow `type(scope): summary`: whether `docs/conventions/git.md` should describe the history's style instead.

```markdown
**Settings**

- Target branch — `dev`; you said `main` requires reviews
- Areas — `web`, `api`, `ui`, from `pnpm-workspace.yaml`

**Questions**

- Models — Claude Code `opus` for shape and both reviews, `sonnet` for implement? Which Codex model and effort?
- Checks for `ui` — none found. Is `pnpm test` right, or none?

**Writes**

- `docs/workflow/` — create `git.md`, `areas.md`, `tracker.md`, `models.md` from template
- `docs/conventions/git.md` — skip; it exists and is yours
- `docs/conventions/naming.md` — create from template
- `AGENTS.md` — add the block below at the end
- `CLAUDE.md` — create with the single line `@AGENTS.md`

**Labels**

- `P0`, `P1`, `P2`, `P3`, `area:web`, `area:api`, `area:ui`, `needs-decision`, `blocked`

Added to `AGENTS.md`:

<the workflow block from the step "Point the instruction files to them">

Proceed?
```

Done when the owner has answered yes, and has confirmed or corrected every setting and answered every question.

### 4. Write `docs/workflow/`

**Fill each template in `templates/workflow/` into the file of the same name in `docs/workflow/`, and delete its comments as you fill.** A comment that survives marks an unfilled slot.

**On a rerun, change only the values that differ.** Keep every line the owner added.

Done when every file in `docs/workflow/` exists, holds no comment and no `{{...}}` marker, and every `TODO` in it is one the owner accepted.

### 5. Seed `docs/conventions/`

**For each template in `templates/conventions/` with no file of the same name in `docs/conventions/`, fill it and write it there.** Delete its comments as you fill. Take the scope rows from `docs/workflow/areas.md`, and the commit style and merge methods from the confirm step.

Done when every template in `templates/conventions/` has a file of the same name in `docs/conventions/`, each file written in this step holds no comment and no `{{...}}` marker, and no file that existed before changed.

### 6. Point the instruction files to them

**Put this block in `AGENTS.md`, and create the file if it is missing.** If the two marker lines already exist, replace what is between them.

```markdown
<!-- workflow:start -->

## Workflow

Read these before the work they cover:

- `docs/workflow/git.md` before creating a branch or a worktree for a work item.
- `docs/workflow/areas.md` before running checks or opening a pull request.
- `docs/workflow/tracker.md` before creating, claiming or closing a work item.
- `docs/workflow/models.md` before spawning a sub-agent.
- `docs/conventions/git.md` before any commit or pull request.
- `docs/conventions/naming.md` before naming a new file or folder.

Merge a pull request only after the owner approves that merge.

<!-- workflow:end -->
```

**List in the block only the convention files that exist.** Add a line for any other file in `docs/conventions/`, with the work it covers.

**Make `CLAUDE.md` import `AGENTS.md`.** If `CLAUDE.md` is missing, create it with the single line `@AGENTS.md`. If it exists without that line, add the line at the top.

Done when `AGENTS.md` holds exactly one pair of markers, the block names every file in `docs/workflow/` and `docs/conventions/`, and `CLAUDE.md` holds the line `@AGENTS.md`.

### 7. Create the tracker labels

**Create each label the owner approved in the confirm step** with `gh label create "<name>" --description "<what it marks>"`.

Done when `gh label list --limit 200` shows every label named in `docs/workflow/tracker.md` and `docs/workflow/areas.md`, or the owner declined it.

### 8. Report

**Report one bullet per path and per label: written, updated, created, or skipped with the reason.** Then list every `TODO` that remains, and the owner's next steps.

```markdown
**Installed**

- `docs/workflow/` — written: `git.md`, `areas.md`, `tracker.md`, `models.md`
- `docs/conventions/git.md` — skipped; it exists and stays as it is
- `docs/conventions/naming.md` — written from template
- `AGENTS.md` — workflow block added at the end
- `CLAUDE.md` — created with `@AGENTS.md`
- Labels — created `P0`, `P1`, `P2`, `P3`, `area:web`, `area:api`, `area:ui`, `needs-decision`, `blocked`

**Open**

- `TODO` in `docs/workflow/models.md` — the Codex model for implement

**Yours from here**

- Review the diff and commit it. Nothing is committed.
- `docs/conventions/` is yours to edit. A rerun never changes it.
```

## Checklist

- [ ] Every file in `docs/workflow/` has no comment and no `{{...}}` marker.
- [ ] Every check command was read from the repository and every model confirmed by the owner.
- [ ] No file in `docs/conventions/` that existed before was changed.
- [ ] `AGENTS.md` has one workflow block naming every file in both folders, and `CLAUDE.md` imports `AGENTS.md`.
- [ ] Every label in `docs/workflow/tracker.md` and `docs/workflow/areas.md` exists in the tracker, or the owner declined it.
- [ ] Nothing is committed.
