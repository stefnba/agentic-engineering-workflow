#!/usr/bin/env bash
# Merge an accepted ticket PR and clean up its worktree. The merge is the last write — the ticket
# reads as done because its PR is merged, so nothing is recorded afterward.
#   usage: complete-ticket.sh <pr-number> [accepted-head-sha]
set -euo pipefail

. "$(cd "$(dirname "$0")" && pwd)/_config.sh"

pr="$1"
accepted="${2:-}"

args=("--$TICKET_MERGE_METHOD" --delete-branch)
# Accept applies to the exact reviewed head SHA; let the forge enforce that rather than trusting it.
[ -n "$accepted" ] && args+=(--match-head-commit "$accepted")

gh pr merge "$pr" "${args[@]}"

branch=$(gh pr view "$pr" --json headRefName -q .headRefName)
git worktree remove --force "$WORKTREE_DIR/$branch" 2>/dev/null || true
git fetch -q --prune origin
echo "merged PR #$pr ($branch)"
