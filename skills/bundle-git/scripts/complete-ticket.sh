#!/usr/bin/env bash
# Merge an accepted ticket PR and clean up its worktree. The merge is the last write — the ticket
# reads as done because its PR is merged, so nothing is recorded afterward.
#   usage: complete-ticket.sh <pr-number> [accepted-head-sha]
#   exit:  2 the ticket branch is stale against its base
set -euo pipefail

. "$(cd "$(dirname "$0")" && pwd)/_config.sh"

pr="$1"
accepted="${2:-}"

# Process substitution hides a failed query from set -e, and empty refs would then read as stale
# rather than as unknown — the same distinction the status scripts keep.
read -r branch base < <(gh pr view "$pr" --json headRefName,baseRefName \
  -q '.headRefName + " " + .baseRefName') || true
[ -n "${branch:-}" ] && [ -n "${base:-}" ] ||
  { echo "cannot read pull request #$pr — refusing to merge on an unknown base" >&2; exit 1; }

# A sibling ticket that merged first moved this branch's base out from under the reviewed diff. The
# two states can merge cleanly and still be broken — nothing here is a text conflict — so what was
# verified is not what would land. Refuse: the cure is to merge the base in and review again, and
# that moves the head, which is why it cannot happen after Accept.
git fetch -q origin
if ! git merge-base --is-ancestor "origin/$base" "origin/$branch"; then
  echo "stale: $branch was verified against an older $base — merge $base in, re-verify, re-Accept" >&2
  exit 2
fi

args=("--$TICKET_MERGE_METHOD" --delete-branch)
# Accept applies to the exact reviewed head SHA; let the forge enforce that rather than trusting it.
[ -n "$accepted" ] && args+=(--match-head-commit "$accepted")

gh pr merge "$pr" "${args[@]}"

git worktree remove --force "$WORKTREE_DIR/$branch" 2>/dev/null || true
git fetch -q --prune origin
echo "merged PR #$pr ($branch)"
