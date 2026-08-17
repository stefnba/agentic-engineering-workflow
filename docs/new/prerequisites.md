## Git

- A remote repository with a local clone.
- A declared integration target branch — the branch bundles commit to, ticket branches and
  worktrees are cut from, and Ship lands on.
- If the default branch is protected (required reviews, no direct push), declare a separate
  integration target such as `dev`. Promoting it to the protected branch is a separate release
  process this workflow doesn't own or verify.
