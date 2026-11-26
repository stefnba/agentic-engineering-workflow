---
name: setup-workflow
description: Use when a repository has no `docs/workflow/` folder, when another workflow skill reports a file in it missing or incomplete, or when the user says "set up the workflow", "install the workflow here" or "rerun setup". Also use when the target branch, a check command, an app or package of a monorepo, the tracker labels or the models for the workflow change.
---

# Set up the workflow

The repository has a `docs/workflow/` folder that holds the facts the workflow skills read, a `docs/conventions/` folder that holds its own git and naming rules, and both instruction files point to them.

## Guardrails

**Write only these:** the files in `docs/workflow/`, the files the next rule allows in `docs/conventions/`, the workflow block in `AGENTS.md`, the import line in `CLAUDE.md`, and the `/.worktrees/` line in `.gitignore`. Every other line of those files belongs to the owner.

**In `docs/conventions/`, create a missing file and leave an existing one as it is.** An existing file holds the owner's rules, which outlive the workflow. Report a conflict with `docs/workflow/` instead of editing it.

**Record a value only when you observed it or the owner confirmed it.** Every later skill runs the commands and uses the models in `docs/workflow/` as written, so a guessed value fails far from here. Write a gap as `TODO: <question for the owner>`. In a table cell, write `TODO` alone and put the question in the report.

**Write nothing and create no label before the owner answers yes in the confirm step.** Labels are visible to everyone with access to the repository.

**Delete an existing label only in the step "Ask about existing labels", and only a label the owner named there.** Deleting a label removes it from every issue and pull request that carries it, and cannot be undone.

**Leave every change uncommitted.** The owner reviews the diff first.

## Process

**Report each step in the shape of its example:** a bold heading, then one bullet per item, written as `item — value, then the reason`. The examples are the format; the values in them are invented. Questions and next steps are plain sentences.

### 1. Check the prerequisites

**Run these from the folder the owner named, or the current folder, and keep the output:**

```bash
git rev-parse --show-toplevel
git remote get-url origin
git symbolic-ref --short refs/remotes/origin/HEAD
gh auth status
```

**If `git symbolic-ref` fails, read the default branch from `git remote show origin`.** It fails in a fresh clone or a repository created by `gh repo create --push`; say in the default branch line which command gave the value.

**Report every line of the example below on every run, whatever the outcome**, each with the value found. The git repository line is `❌` when `git rev-parse` fails. The remote line is `❌` when there is no remote or it is not on GitHub. A check that could not run because an earlier one failed is still `❌`, with the reason it could not run. A line whose fallback gave the value is `✅`.

```markdown
**Prerequisites**

- ✅ Git repository — root at `/home/dana/billing`
- ✅ Remote — `origin` → `git@github.com:acme/billing.git`
- ✅ Default branch — `main` on `origin`, from `git remote show origin`; `git symbolic-ref` failed
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

**Report each item below under a Repository heading, in this order, naming what you found.** Send it as a message of its own and go on to the confirm step without waiting. `absent` is the normal value on a first run, not a failure.

- **`docs/workflow/`:** present means a rerun. Read its files and offer their values as the proposal in the confirm step.
- **`docs/conventions/`:** name each file. Note each fact that a `docs/workflow/` file would also state, such as a branch name for workflow work or a worktree path.
- **`AGENTS.md` and `CLAUDE.md`:** which exist, whether `AGENTS.md` holds the workflow markers, and whether `CLAUDE.md` holds `@AGENTS.md`.
- **Repository and owner:** the repository name and the owner type from the commands below. Use them for the tracker line of `docs/workflow/tracker.md`, not the folder or the manifest name. An owner type of `User` means a personal account, which has no issue types.

  ```bash
  gh repo view --json name,owner --jq '.owner.login + "/" + .name'
  gh api "repos/{owner}/{repo}" --jq .owner.type
  ```

- **Issue types:** for a `User` owner, report none, because a personal account has no issue types. For an `Organization` owner, report the names the query below returns. Confirm: this query was not verified when this skill was written; when it fails, ask the owner in the confirm step.

  ```bash
  gh api graphql -f query='{ organization(login: "<owner>") { issueTypes(first: 20) { nodes { name } } } }'
  ```

- **Default branch protection:** run both commands below, with the default branch in place of `<branch>`. Read the result from this table. Confirm: what the first returns for a caller without admin rights was not verified when this skill was written.

  ```bash
  gh api "repos/{owner}/{repo}/branches/<branch>/protection"
  gh api "repos/{owner}/{repo}/rules/branches/<branch>"
  ```

  | Result                                                                           | Report                                                                    |
  | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
  | HTTP 404 "Branch not protected", and `[]`                                        | Not protected                                                             |
  | HTTP 403 "Upgrade to GitHub Pro or make this repository public" from either call | Not protected; a private repository on a free plan cannot have protection |
  | A protection object, or a non-empty rule list                                    | The rules it names, such as required reviews                              |
  | Any other failure                                                                | `unknown`; ask the owner in the confirm step                              |

- **Layout:** check these in order and stop at the first that hits. Name the signal and the directories it found, or say single area and name what you checked.
  1. A workspace declaration: `pnpm-workspace.yaml`, `workspaces` in the root `package.json`, `[workspace]` in `Cargo.toml`, `[tool.uv.workspace]` in `pyproject.toml`, `go.work`.
  2. A monorepo build tool at the root: `turbo.json`, `nx.json`, `lerna.json`, `rush.json`, `moon.yml`.
  3. More than one manifest below the root, by the globs `*/<manifest>` and `*/*/<manifest>` for `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `build.gradle*`, `pom.xml`.
- **Areas and checks:** one bullet per area, with its path, its check commands, the directory each runs from, and the file each came from. Also name the area's own docs folder, such as `apps/web/docs/`, or `none`. A check is a command that tests, lints or type-checks. Judge a script by what it runs, not by its name: a `build` script that runs only `tsc` type-checks.
  - Take the commands CI runs for the area, as written in the CI configuration.
  - When CI runs none, take the checking scripts of the area's manifest or task runner file, and say that CI runs none. Write each as the command that runs the script from the area's folder, such as `pnpm build` for a `build` script, and give that folder as where it runs.
  - When neither has one, the area has no checks: write `none` for its checks and for where they run.
  - Leave out a script of the root manifest that CI does not run, because it belongs to no area. Name each one left out in a Root scripts bullet, so the owner sees it was dropped.
- **Commit style**, only when `docs/conventions/git.md` is missing: how many of the last 30 subjects of `git log --format=%s` match `type(scope): summary` or `type: summary`, and the merge methods `gh repo view --json squashMergeAllowed,mergeCommitAllowed,rebaseMergeAllowed` reports. The history follows the template's style when at least 80% match. With fewer than 10 commits, report it as too short to judge, such as `6 commits, too short to judge`, and use the template's style.
- **File names**, only when `docs/conventions/naming.md` is missing: the case style of the directory and file names in `git ls-files`, leaving out names a tool requires, such as `package.json`.
- **Skills:** whether any `SKILL.md` file exists in the repository. Only then do the `<skill>` and `skills` scope rows of `templates/conventions/git.md` apply.
- **Worktrees:** whether `git check-ignore -q .worktrees/x` reports `.worktrees/` as ignored. Also name each test, lint or type-check config whose file patterns reach `.worktrees/` and do not respect `.gitignore`. A pattern resolves from its config's folder, so only a config at the repository root, or one whose pattern climbs to it with `../`, can reach it. An example is a root `tsconfig.json` whose `include` is `**/*.ts` and whose `exclude` lacks `.worktrees`. Such a tool scans every worktree's copy of the code. Also name each area whose type-check has no config in the area's own folder: the tool then falls back to a parent config, such as `tsc` in a folder without `tsconfig.json` using the root one.

**Treat the layout as a reading the owner confirms.** A vendored dependency or an examples folder trips the manifest glob.

```markdown
**Repository**

- `docs/workflow/` — absent; first run
- `docs/conventions/` — `git.md` found; it names worktrees `.claude/worktrees/`, which `docs/workflow/git.md` would also state
- `AGENTS.md` — found, no workflow markers; `CLAUDE.md` absent
- Repository — `acme/billing`, owned by an organization
- Issue types — `Feature`, `Task`, `Bug`, from the GraphQL query
- Protection of `main` — required reviews, from the branch protection call
- Layout — monorepo; `pnpm-workspace.yaml` declares `apps/web`, `apps/api`, `packages/ui`
- `web` — `apps/web`; `pnpm --filter web test`, `pnpm --filter web lint`, run from the root, from `.github/workflows/ci.yml`
- `api` — `apps/api`; `pnpm test`, run from `apps/api`, from `apps/api/package.json`; CI runs no check for it
- `ui` — `packages/ui`; none; its `build` script runs `vite build`, which does not check
- Root scripts — `pnpm -r lint` left out; CI does not run it
- Commit style — 27 of the last 30 subjects match; squash merges only
- File names — kebab-case throughout
- Skills — none found; the `<skill>` and `skills` scope rows do not apply
- Worktrees — `.worktrees/` not ignored yet; the root `tsconfig.json` includes `**/*.ts` with no exclude
```

Done when each slot of the templates in `templates/workflow/` in this skill's folder has an observed value or a named gap.

### 3. Confirm with the owner

**Confirm the decisions, not the file bodies.** The owner can read the templates any time; pasted whole, they bury the values.

**Send one message in plain chat with these parts in order, then wait for a yes:**

1. **Settings:** one bullet each for the target branch, each area with its checks and where they run, the tracker repository, the issue types, or for a personal account `none` with the type labels that replace them, and, when a convention file will be created, the commit style, the pull request title limit and the file-name style. Give each its source. Say in the target branch bullet whether it is protected, or that it waits on the target branch question. On a rerun, name the value it replaces.
2. **Questions:** one bullet per gap, with your proposal.
3. **Writes:** one bullet per path, with its action, which is create from template, update, skip with the reason, or add the block below.
4. **Labels:** the labels to create, each with its description. Compare `gh label list --limit 200` with the labels in `templates/workflow/tracker.md`, the type labels when the account has no issue types, and one `area:<name>` label per area. Take each description from the text after the label's dash in `templates/workflow/tracker.md`, with the area's path filled in for an area label. Leave existing labels out of this message; the step "Ask about existing labels" covers them.
5. **Verbatim text:** the workflow block and the `@AGENTS.md` line, shown in full in a code fence, only for an instruction file that already exists. List in the block the convention files that will exist after the seed step.
6. **`Proceed?`**

**Ask in the questions part:**

- **The target branch**, only when the default branch requires reviews, blocks direct pushes, requires linear history, or its protection is `unknown`: whether feature branches may merge into it or whether work lands on another branch such as `dev`. Otherwise the default branch is a setting.
- **The models.** Ask for each cell of `templates/workflow/models.md`. Models cannot be observed in the repository. Propose the cells from `references/model-tiers.md`, and name the Codex models the CLI listed.
- **Each conflict** noted under `docs/conventions/`: which value `docs/workflow/` should hold.
- **The issue types**, only when the query for them failed: whether the organization has `Feature`, `Task` and `Bug`.
- **The commit style**, when fewer than 80% of at least 10 subjects match: whether `docs/conventions/git.md` should describe the history's style instead.
- **The file-name style**, when it differs from `templates/conventions/naming.md`: which style the file should state.
- **Checks taken from a manifest** because CI runs none for the area: whether they count.
- **Each config that scans worktrees:** whether to add `.worktrees` to its exclusions. Name in the same bullet each area whose type-check falls back to that config, because its check then scans every worktree too. Leave that edit to the owner; it is outside what this skill writes.

```markdown
**Settings**

- Target branch — `main`, the default branch, pending the question below
- `web` — `apps/web`; `pnpm --filter web test`, `pnpm --filter web lint`, run from the root, from `.github/workflows/ci.yml`
- `api` — `apps/api`; `pnpm test`, run from `apps/api`, from `apps/api/package.json`
- `ui` — `packages/ui`; none
- Tracker — GitHub issues in `acme/billing`
- Issue types — `Feature`, `Task`, `Bug`, from the GraphQL query; for a personal account, none, with `type:feature`, `type:task`, `type:bug` instead
- Pull request titles — 65 characters, because squash merges are allowed
- Commit style — `type(scope): summary`, the template's; 27 of the last 30 subjects match
- File names — the template's rules; the repository uses kebab-case throughout

**Questions**

- Target branch — `main` requires reviews. May feature branches merge into it, or does work land on `dev`?
- Models — Claude Code `opus` for shape and both reviews, `sonnet` for implement; Codex `gpt-6.1-sol`, `high` for shape and both reviews, `gpt-6.1-terra`, `medium` for implement, the newest of each family `codex debug models` lists?
- Checks for `api` — CI runs none. Does `pnpm test` from `apps/api/package.json` count?
- Root `tsconfig.json` — it would type-check every worktree, and so would `ui`'s `tsc`, which falls back to it. Will you add `.worktrees` to its `exclude`?

**Writes**

- `docs/workflow/` — create `git.md`, `areas.md`, `tracker.md`, `models.md` from template
- `docs/conventions/git.md` — skip; it exists and is yours
- `docs/conventions/naming.md` — create from template
- `AGENTS.md` — add the block below at the end
- `CLAUDE.md` — create with the single line `@AGENTS.md`
- `.gitignore` — add the line `/.worktrees/`

**Labels**

- `P0` — Drops other work
- `area:web` — Work in apps/web
- `needs-decision` — Waits on an owner's decision

Added to `AGENTS.md`:

<the workflow block from the step "Point the instruction files to them", in a code fence>

Proceed?
```

Done when the owner has answered yes, and has confirmed or corrected every setting and answered every question.

### 4. Write `docs/workflow/`

**Fill each template in `templates/workflow/` into the file of the same name in `docs/workflow/`, and delete its comments as you fill.** A comment that survives marks an unfilled slot.

**On a rerun, change only the values that differ.** Keep every line the owner added.

**Add the line `/.worktrees/` at the end of `.gitignore`, unless `git check-ignore` already reported `.worktrees/` as ignored.** Create `.gitignore` if it is missing.

Done when every file in `docs/workflow/` exists, holds no comment and no `{{...}}` marker, every `TODO` in it is one the owner accepted, and `git check-ignore -q .worktrees/x` succeeds.

### 5. Seed `docs/conventions/`

**For each template in `templates/conventions/` with no file of the same name in `docs/conventions/`, fill it and write it there.** Delete its comments as you fill. Take the scope rows from `docs/workflow/areas.md`, the skills reading for the `<skill>` and `skills` rows, and the commit style, merge methods and file-name style from the confirm step.

Done when every template in `templates/conventions/` has a file of the same name in `docs/conventions/`, each file written in this step holds no comment and no `{{...}}` marker, and no file that existed before changed.

### 6. Point the instruction files to them

**Put this block at the end of `AGENTS.md`, after a blank line, and create the file if it is missing.** If the two marker lines already exist, replace what is between them where they stand.

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

**Create each label the owner approved in the confirm step** with `gh label create "<name>" --description "<description>"`, using the description shown in the confirm step. Leave the colour to `gh`.

Done when `gh label list --limit 200` shows every label named in `docs/workflow/tracker.md` and `docs/workflow/areas.md`, or the owner declined it.

### 8. Ask about existing labels

**List every label that existed before this run and is not named in `docs/workflow/tracker.md` or `docs/workflow/areas.md`.** For each, count the issues and the pull requests that carry it:

```bash
gh issue list --label "<name>" --state all --limit 1000 --json number --jq length
gh pr list --label "<name>" --state all --limit 1000 --json number --jq length
```

**Send the list as a message of its own, and wait for the answer.** Put nothing else in that message. Propose keeping every label.

```markdown
**Existing labels**

These labels were here before the workflow. The workflow does not use them.

- `bug` — 4 issues, 0 pull requests
- `enhancement` — 0 issues, 0 pull requests
- `wontfix` — 0 issues, 0 pull requests

Deleting a label removes it from every issue and pull request that carries it, and cannot be undone. I propose keeping all of them. Which, if any, should I delete?
```

**Delete only the labels the owner names in the answer**, each with `gh label delete "<name>" --yes`. Keep every label when the answer names none or is unclear.

Done when the owner has answered, and `gh label list --limit 200` no longer shows each label they named and still shows every other one.

### 9. Report

**Report one bullet per path or folder, one for the labels created, and one for the existing labels: written, updated, created, deleted, kept, or skipped with the reason.** Then list every `TODO` that remains with its question, and the owner's next steps.

```markdown
**Installed**

- `docs/workflow/` — written: `git.md`, `areas.md`, `tracker.md`, `models.md`
- `docs/conventions/git.md` — skipped; it exists and stays as it is
- `docs/conventions/naming.md` — written from template
- `AGENTS.md` — workflow block added at the end
- `CLAUDE.md` — created with `@AGENTS.md`
- `.gitignore` — added `/.worktrees/`
- Labels — created `P0`, `P1`, `P2`, `P3`, `area:web`, `area:api`, `area:ui`, `needs-decision`, `blocked`
- Existing labels — deleted `wontfix`, as you asked; kept `bug` and `enhancement`

**Open**

- `TODO` in `docs/workflow/models.md` — which Codex model and reasoning effort for implement?

**Yours from here**

- Review the diff and commit it. Nothing is committed.
- `docs/conventions/` is yours to edit. A rerun never changes a file in it.
```

## Checklist

- [ ] Every file in `docs/workflow/` has no comment and no `{{...}}` marker.
- [ ] Every check command was read from the repository and every model confirmed by the owner.
- [ ] No file in `docs/conventions/` that existed before was changed.
- [ ] `AGENTS.md` has one workflow block naming every file in both folders, and `CLAUDE.md` imports `AGENTS.md`.
- [ ] Every label in `docs/workflow/tracker.md` and `docs/workflow/areas.md` exists in the tracker, or the owner declined it.
- [ ] `.gitignore` ignores `.worktrees/`.
- [ ] Every deleted label was named by the owner in the step "Ask about existing labels".
- [ ] Nothing is committed.

## Path conventions

- `templates/` and `references/` paths are relative to this skill's folder, the folder holding this file.
