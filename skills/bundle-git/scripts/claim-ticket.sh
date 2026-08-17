#!/usr/bin/env bash
# Claim one ticket by creating its branch and worktree. A second claim on the same ticket fails.
#   usage: claim-ticket.sh <bundle-id> <NN>
#   exit:  2 no such ticket   3 blocked by a dependency   4 already claimed   5 stale worktree
set -euo pipefail

bundle="$1"
nn="$2"
target="${INTEGRATION_TARGET:-main}"
here="$(cd "$(dirname "$0")" && pwd)"
branch="ticket/$bundle/$nn"
worktree=".claude/worktrees/$branch"

git fetch -q origin

if [ -f "work/bundles/$bundle/ticket.md" ]; then
  ticket="work/bundles/$bundle/ticket.md"
else
  ticket=$(ls "work/bundles/$bundle/tickets/$nn-"*.md 2>/dev/null | head -1 || true)
fi
[ -n "$ticket" ] || { echo "no such ticket: $bundle/$nn" >&2; exit 2; }

# A multi-ticket bundle shares one bundle branch; a single-ticket bundle PRs into the target directly.
if [ "$(ls "work/bundles/$bundle/tickets" 2>/dev/null | wc -l)" -gt 1 ]; then
  base="bundle/$bundle"
  git ls-remote --exit-code --heads origin "$base" >/dev/null 2>&1 ||
    git push -q origin "origin/$target:refs/heads/$base" ||
    true # another ticket's claim won the race and created it first
  git fetch -q origin "+refs/heads/$base:refs/remotes/origin/$base"
else
  base="$target"
fi

for dep in $(sed -n 's/^depends_on: *\[\(.*\)\]/\1/p' "$ticket" | tr -d ' ' | tr ',' '\n'); do
  [ "$("$here/ticket-status.sh" "$bundle" "$dep")" = done ] ||
    { echo "blocked: ticket $dep is not done" >&2; exit 3; }
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
