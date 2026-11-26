<!-- Fill every slot; delete these comments as you fill. This file belongs to
the owner once written; setup writes it only when it is missing. -->

# Git conventions

Conventions for branches, commits and pull requests in this repository.

## Branches

**Commit on the current branch.** Create a branch only when the user or a skill step asks for one, or when the current branch is the default branch.

**Let the workflow skills name the branches they create.** `docs/workflow/git.md` holds those names; the rule below covers every other branch.

**Name any other branch `<scope>/<kebab-case-topic>`**, where scope is a row of the Scope table below: `docs/git-conventions`.

## Commit strategy

**Keep one logical change per commit.**

**Give each commit exactly one scope.** A change that spans two scopes becomes two commits, the shared code first, so it stands on its own.

**When one file holds hunks for two commits, stage only the hunks of the current commit.** In a terminal, `git add -p` selects them. Without a terminal, make the edits for one commit, commit, then make the next edits.

**Commit a lock file together with the manifest change that produced it**, under that manifest's scope, so every commit resolves on its own.

**Before amending or rebasing, run `git branch -r --contains HEAD`.** Empty output means the commit is local only and may be rewritten. Any output means it is on the remote: add a new commit instead, because rewriting a pushed commit requires a force-push.

## Commit messages

Skeleton:

```text
type(scope): summary in lowercase imperative, 72 characters or fewer

Body only when the diff does not show why.
```

### Type

Pick the row whose condition matches the diff. A diff with source changes takes the type of the source change even when tests, docs or manifests change alongside it.

| Type | Use when the diff contains |
| --- | --- |
| `feat` | New behavior a user or other code can call |
| `fix` | A correction to behavior that was wrong |
| `refactor` | Code moved or restructured with behavior unchanged |
| `test` | Tests only |
| `docs` | Markdown, docstrings or agent instructions only |
| `build` | Manifests, lock files, build files, editor or agent settings files only |
| `ci` | CI configuration only |
| `chore` | Housekeeping that fits no row above, such as renames or `.gitignore` entries |

### Scope

Pick the row whose condition matches the diff. Every file inside an area, including its docs, tests and manifest, takes that area's scope. Ripple in other areas, such as call sites updated because the area changed, adds no scope.

<!-- One row per area of docs/workflow/areas.md, plus the rows below that
apply. A repository with one area drops the area row and uses the rest. -->

| Scope | Use when the change touches |
| --- | --- |
| `{{AREA}}` | `{{PATH}}` |
| `docs` | `docs/`, root `README.md` |
| `agents` | Root `AGENTS.md`, root `CLAUDE.md`, harness settings files |
| `<skill>` | One skill's directory, named by that directory |
| `skills` | Several skills, or skill files outside any one skill's directory |

### Example

<!-- Replace with a real change in this repository, in the same shape. -->

```text
refactor(client): move date formatting into a shared helper

Two screens format dates; one copy avoids drift.
```

## Pull requests

<!-- When the repository does not allow squash merges, make the limit in the
next rule 72 characters and drop its second sentence. -->

**Give a pull request title the shape of a commit subject, 65 characters or fewer.** A squash merge appends ` (#<n>)`, and the commit subject it produces must stay within 72.

**Pick the type by the outcome, not by the shape of the diff.** A pull request that adds a limiter is `feat` even when most of its lines are tests.

**Leave work item numbers out of the title.** The body carries the reference.
