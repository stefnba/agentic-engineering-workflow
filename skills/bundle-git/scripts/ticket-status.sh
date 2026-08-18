#!/usr/bin/env bash
# Print a ticket's status: todo | doing | done. Status is derived, never stored.
#   usage: ticket-status.sh <bundle-id> <NN>
set -uo pipefail

bundle="$1"
nn="$2"
. "$(cd "$(dirname "$0")" && pwd)/_config.sh"
target="$INTEGRATION_TARGET"
branch=$(ticket_branch "$bundle" "$nn")

if [ "$(ls "work/bundles/$bundle/tickets" 2>/dev/null | wc -l)" -gt 1 ]; then
  base=$(bundle_branch "$bundle")
else
  base="$target"
fi

# done means merged into this ticket's own target, not merged anywhere. The PR record survives the
# head branch being deleted on merge, so this still answers after cleanup. Fail loudly rather than
# reporting todo, which would let a dependent ticket start early.
if ! merged=$(gh pr list --head "$branch" --state merged --json number,baseRefName \
  -q ".[] | select(.baseRefName==\"$base\") | .number"); then
  echo "cannot query pull requests — status unknown for $branch" >&2
  exit 1
fi

if [ -n "$merged" ]; then
  echo done
elif git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
  echo doing
else
  echo todo
fi
