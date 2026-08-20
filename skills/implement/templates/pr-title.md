<!--
The implementation PR's title — one line, and the only part of this PR that reaches the integration
target's history. Under `TICKET_MERGE_METHOD=squash` it becomes the squashed commit's subject, and
once Land deletes the bundle, that subject plus the `(#<pr>)` the forge appends is how a reader gets
from a landed line of code back to the pull request that carries the permalinks.

${CLAUDE_PROJECT_DIR}/docs/conventions/git.md owns the shape — the type vocabulary, the scope, the
imperative mood, the length cap. This file owns only how a ticket PR fills it. Pass the line as
`gh pr create --title`; nothing in this comment reaches the PR.

- Type follows the ticket's outcome, not the shape of the diff. A ticket that adds a limiter is
  `feat` even when most of its lines are tests.
- Scope is a term this repository already uses. Read `git log --oneline` and reuse one; a scope
  coined per ticket makes the log unsearchable exactly where it matters.
- The summary is the ticket's Outcome in one clause, present tense, written for someone who will
  read it years from now with no bundle to open. Not the ticket's heading verbatim — that one was
  written for a planner who had the spec in front of them.
- No ticket number and no bundle ID. Neither fits the length cap, the conventional shape has no slot
  for them, and the back-reference already exists twice over: the `(#<pr>)` on the subject and the
  permalinks in the body. Twelve tickets should land as twelve changes, not as a numbered work log.
- If a fix round changes what the ticket delivers, the title changes with it.

Examples:
  feat(auth): rate-limit failed logins per IP
  fix(api): return 404 rather than 500 for a missing export
  refactor(billing): extract the retry policy behind an interface
  test(server): pin current transaction behavior before the refactor
-->

<type>(<scope>): <what this ticket makes true>
