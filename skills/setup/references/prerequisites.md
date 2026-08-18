# Prerequisites

What a repository needs before the workflow can run.

## Git

- A remote repository with a local clone.
- A declared integration target branch — the branch bundles commit to, ticket branches and
  worktrees are cut from, and Ship lands on.
- If the default branch is protected (required reviews, no direct push), declare a separate
  integration target such as `dev`. Promoting it to the protected branch is a separate release
  process this workflow doesn't own or verify.

## Forge

- An authenticated CLI for the host holding the pull requests (`gh` for GitHub). Ticket and bundle
  status are derived from pull request records, so status queries, the dependency gate, and the Ship
  gate all need it. A query that cannot reach the forge reports `unknown`, never `todo`.
