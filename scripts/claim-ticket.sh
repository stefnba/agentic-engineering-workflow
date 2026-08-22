#!/usr/bin/env bash
# Claim one ticket by creating its branch and worktree. A second claim on the same ticket fails.
#   usage: claim-ticket.sh <bundle-id> <NN>
#   exit:  2 no such ticket   3 dependency not done   4 already claimed   5 stale worktree
set -euo pipefail

bundle="$1"
nn="$2"
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/_config.sh"
target="$INTEGRATION_TARGET"
branch=$(ticket_branch "$bundle" "$nn")
worktree="$WORKTREE_DIR/$branch"

git fetch -q origin

if [ -f "work/bundles/$bundle/ticket.md" ]; then
  ticket="work/bundles/$bundle/ticket.md"
else
  ticket=$(ls "work/bundles/$bundle/tickets/$nn-"*.md 2>/dev/null | head -1 || true)
fi
[ -n "$ticket" ] || { echo "no such ticket: $bundle/$nn" >&2; exit 2; }

# A base that is not the target means a multi-ticket bundle, whose shared branch the first claim
# creates.
base=$(ticket_base "$bundle")
if [ "$base" != "$target" ]; then
  git ls-remote --exit-code --heads origin "$base" >/dev/null 2>&1 ||
    git push -q origin "origin/$target:refs/heads/$base" ||
    true # another ticket's claim won the race and created it first
  git fetch -q origin "+refs/heads/$base:refs/remotes/origin/$base"
fi

# Report the status actually observed. A failed query prints nothing and is unknown, not todo — the
# gate is closed either way, but "couldn't tell" and "not finished yet" need different responses.
for dep in $(sed -n 's/^depends_on: *\[\(.*\)\]/\1/p' "$ticket" | tr -d ' ' | tr ',' '\n'); do
  dep_status=$("$here/ticket-status.sh" "$bundle" "$dep") || dep_status=""
  [ -n "$dep_status" ] || dep_status=unknown
  [ "$dep_status" = done ] ||
    { echo "blocked: ticket $dep is $dep_status" >&2; exit 3; }
done

if [ -e "$worktree" ]; then
  echo "stale worktree at $worktree — remove it first" >&2
  exit 5
fi

# The porcelain '*' flag means this push created the branch, so the claim is ours. A racer that
# pushed the same commit sees '=' and must stop. Capture the output instead of piping it: under
# pipefail, `grep -q` exits early and SIGPIPEs the push.
result=$(git push --porcelain origin "origin/$base:refs/heads/$branch" 2>&1) ||
  { echo "ticket $bundle/$nn is already claimed" >&2; exit 4; }
grep -q '^\*' <<<"$result" ||
  { echo "ticket $bundle/$nn is already claimed" >&2; exit 4; }

git fetch -q origin "+refs/heads/$branch:refs/remotes/origin/$branch"
git worktree add -q "$worktree" "$branch"
echo "claimed $branch from $base — worktree at $worktree"
