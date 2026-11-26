<!-- Copy to docs/conventions/git.md when the repository has none, after filling every slot named
here: the worktree directory from the answered question; the scope
table's `<component>` row, in a monorepo one row per member and in a single project one row for
the code itself, each named the way its code is imported or invoked with the directory it lives
in as the condition, deleting the placeholder row once real rows replace it; and the example's
`<component>` with one of those names; table alignment after filling does not matter. When the
repository already has the file, append only the last section, from `## Agentic engineering
workflow` to the end, and the worktree line under `## Worktrees`, creating that heading with only
that line immediately before the section when absent. Drop this comment when copying. -->

# Git conventions

Conventions for branches, commits, pull requests, and worktrees in this repository.

## Branches

**Commit on the current branch.** Create a branch only when the user or a skill step asks for one, or when the current branch is the default branch; the names below apply then.

**Name a branch `<scope>/<kebab-case-topic>`**, with the scope its commits will carry as the first segment, such as `docs/git-conventions`.

## Commit strategy

**Keep one logical change per commit.**

**Give each commit exactly one scope.** A change that spans two components becomes two commits, the one the other depends on first, so it stands on its own.

**When one file holds hunks for two commits, stage only the hunks of the current commit.** In a terminal, `git add -p` selects them. In a session without a terminal, `git add -p` cannot run: make the edits for one commit, commit, then make the next edits. When both hunks are already in the working tree, copy the file aside, remove the later commit's hunks, commit, then restore the copy and commit again.

**Before amending or rebasing, run `git branch -r --contains HEAD`.** Empty output means the commit is local only and may be rewritten. Any output means it is on the remote: add a new commit instead, because rewriting a pushed commit diverges the branch and requires a force-push.

## Commit messages

Skeleton:

```text
type(scope): summary in lowercase imperative, 72 characters or fewer

Body only when the diff does not show why.
```

### Type

Pick the row whose condition matches the diff. A diff with source changes takes the type of the source change even when tests, docs, or manifests change alongside it.

| Type       | Use when the diff contains                                                   |
| ---------- | ---------------------------------------------------------------------------- |
| `feat`     | New behavior a user or other code can call                                   |
| `fix`      | A correction to behavior that was wrong                                      |
| `refactor` | Code moved or restructured with behavior unchanged                           |
| `test`     | Tests only                                                                   |
| `docs`     | Markdown, docstrings, or agent instructions only                             |
| `build`    | Manifests, lock files, makefile, editor or agent settings files only         |
| `ci`       | CI configuration only                                                        |
| `chore`    | Housekeeping that fits no row above, such as renames or `.gitignore` entries |

**Four workflow paths have reserved, scopeless types**, listed in the Agentic engineering workflow section below; a diff on one of them uses that type and no row here.

### Scope

Pick the row whose condition matches the diff. Every file inside a component, including its docs, tests, and manifest, takes that component's scope, except the reserved workflow paths, which take none. Ripple in other components, such as call sites or links updated because the component changed, adds no scope.

| Scope         | Use when the change touches                                                                                             |
| ------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `<component>` | `<its directory>/`                                                                                                      |
| `docs`        | `docs/`, root `README.md`                                                                                               |
| `agents`      | Root `AGENTS.md`, root `CLAUDE.md`, `.claude/settings.json`                                                             |
| `<skill>`     | One skill's directory under `.agents/skills/` or `.claude/skills/`, named by that directory, such as `workflow-manager` |
| `skills`      | Several skills, or skill files outside any one skill's directory                                                        |

### Example

Retrying a flaky export in one component:

```text
fix(<component>): retry the export once when the api returns 429

The api throttles bursts; one retry after a second clears it.
```

## PR conventions

**Title**: same shape as a commit subject — `type(scope): summary`, imperative, 65 characters or fewer, because a squash merge appends ` (#<n>)` and the commit subject it produces must stay within 72. It describes what the PR adds to the integration target and need not match any branch commit; put in the summary what the scope does not say. The type follows the outcome, not the diff's shape: a PR that adds a limiter is `feat` even when most of its lines are tests. The scope is a row of the Scope table above. No ticket number and no bundle ID in the title; the PR body carries the back-reference.

## Worktrees

- **Worktree directory**: `<WORKTREE_DIR>`

**Always create worktrees with plain git** — never a harness hook.

## Agentic engineering workflow

**Let the `workflow-manager` skill name and create every bundle and ticket branch**; the repository's branch rule does not apply to them. Invoke it for bundle state and for cutting, claiming, landing, or abandoning one.

**Label every PR from a `bundle/` branch `bundle` and every PR from a `ticket/` branch `ticket`**, so each kind can be filtered across the repository; the `write-pr` skill applies the label when it opens the PR. A bundle's PRs are found by the id its PR bodies carry, `gh pr list --state all --search "<bundle-id> in:body"`, and its ticket PRs by `gh pr list --base bundle/<reference> --state all`.

**Four workflow paths have reserved commit types.** A commit touching one uses that type, scopeless, and touches nothing else:

- `bundle` — bundle artifacts under `work/bundles/<bundle-id>/`. One exception to "touches nothing else": the publish commit also carries its `work/backlog.md` edit, so the lines a bundle covers retire atomically with it.
- `decision` — adding or superseding a record in `docs/decisions/`.
- `backlog` — `work/backlog.md`.
- `research` — research reports under `docs/research/`.

The path decides wherever it sits; the reserved types never take a scope.
