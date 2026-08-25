#!/usr/bin/env bash
# Merge an accepted ticket PR and clean up its worktree. The merge is the last write — the ticket
# reads as done because its PR is merged, so nothing is recorded afterward. The accepted SHA is
# required, never resolved here: silently trusting "whatever is at the head right now" is exactly
# how a commit pushed straight to the branch, outside Review, would get merged as if it had been
# reviewed.
#   usage: complete-ticket.sh <pr-number> <accepted-head-sha>
#   exit:  2 the ticket branch is stale against its base
set -euo pipefail

# Captured before _config.sh anchors the CWD, so the lost-cwd warning at the end judges where the
# caller's shell actually stood.
invoked_from=$(pwd -P)

. "$(cd "$(dirname "$0")" && pwd)/_config.sh"

# The invoker often sits inside the very worktree this script removes — the implement session's
# shell lives there. Work from the main checkout so the removal and the relative $WORKTREE_DIR
# resolve either way, and warn at the end when the caller's shell lost its cwd.
cd "$(git worktree list --porcelain | head -1 | sed 's/^worktree //')"

pr="${1:-}"
accepted="${2:-}"
[ -n "$pr" ] && [ -n "$accepted" ] ||
  { echo "usage: complete-ticket.sh <pr-number> <accepted-head-sha> — the SHA from the last Reviewer round's final summary, never guessed" >&2; exit 64; }

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

# Accept applies to the exact reviewed head SHA; let the forge enforce that rather than trusting it.
gh pr merge "$pr" "--$TICKET_MERGE_METHOD" --delete-branch --match-head-commit "$accepted"

git worktree remove --force "$WORKTREE_DIR/$branch" 2>/dev/null || true
git worktree prune
# git worktree remove deletes only the leaf it was given; drop the scaffolding directories it
# leaves, each only if empty — never a tree, and never anything above $WORKTREE_DIR.
rmdir "$WORKTREE_DIR/$(dirname "$branch")" "$WORKTREE_DIR/ticket" "$WORKTREE_DIR" 2>/dev/null || true
git fetch -q --prune origin
echo "merged PR #$pr ($branch)"

wt="$WORKTREE_DIR/$branch"
case "$wt" in /*) : ;; *) wt="$(pwd -P)/$wt" ;; esac
case "$invoked_from/" in
  "$wt/"*) echo "note: your shell's directory was removed with the worktree — cd to the repository root" ;;
esac
