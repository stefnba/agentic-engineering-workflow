# Settings a script reads are not prose

Date: 2026-08-18
Status: accepted
Supersedes: the `docs/conventions/git.md` row of
[2026-08-18-consuming-repo-layout.md](./2026-08-18-consuming-repo-layout.md), which put this repo's
git *values* there.

## Decision

`docs/conventions/git.md` declared five things as if a repository could change them. Four were
hardcoded in the scripts instead — branch names, worktree location, and the squash flag in two
places each — and the fifth, the integration target, came from an environment variable nothing set
from the file. Editing the file changed nothing except the documentation.

So: **anything a script consumes is machine-readable config, never prose.** Anything no script reads
stays prose.

- `work/config.conf` — `INTEGRATION_TARGET`, `MERGE_METHOD`, `WORKTREE_DIR`. The scripts source it;
  `skills/setup/templates/config.conf` is the template `setup` copies. Not a `.env` file: those are
  conventionally gitignored as secrets, and this one must be committed or a clone silently reverts to
  the defaults. It sits beside `work/backlog.md`, so the workflow's footprint in a consuming repo
  stays one directory plus an `AGENTS.md` pointer.
- `docs/conventions/git.md` — commit messages, PR titles, the plain-git worktree rule. Things a human
  follows and no script parses.

**Branch naming is neither.** It moves to `workflow/git-mechanics.md` as fixed workflow machinery.
Status is derived by reconstructing those names, so consumers must agree byte for byte; a repository
that changed the prefix would see a claimed ticket read as `todo` and let a dependent ticket start
early. Nobody types these names by hand, so the knob buys nothing and costs a silent failure. If CI
branch filters ever force a prefix, it becomes another key in `work/config.conf` — not prose.

## Consequences

- `scripts/_config.sh` is the single definition of every setting and of both branch names. The three
  scripts that need a value source it instead of repeating literals; `bundle-status.sh` holds none of
  its own and delegates to `ticket-status.sh`.
- It validates the file before sourcing it. The file is shell, so `KEY = value` would otherwise run
  as a command and abort a claim with `command not found`; a rejected line is named instead.
- An environment variable of the same name outranks the file, so a one-off override needs no edit.
- `tests/run.sh` covers all three settings' override paths and the rejection, so "configurable" is
  proven rather than claimed.
- `setup` must write `work/config.conf` from the template, not only install documentation — and must
  write `WORKTREE_DIR` into `.gitignore`, since the two are one decision recorded twice.
- Branch *strategy* moves with branch naming: `workflow/bundle.md` no longer offers `bundle-branch`
  or `trunk` as declared options, because the scripts derive it from the ticket count.
