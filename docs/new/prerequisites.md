## Git

- remote repo
- local git init
- declared integration target branch — where bundles commit, ticket branches/worktrees get cut
  from, and Ship lands. Defaults to the repo's default branch. If that branch is protected (required
  reviews, no direct push), declare a separate integration target instead (e.g. `dev`); promoting it
  to the protected branch is a separate release process this workflow doesn't own or verify.
