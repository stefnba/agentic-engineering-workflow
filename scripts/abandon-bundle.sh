#!/usr/bin/env bash
# Abandon a bundle that will never land: delete every ticket branch and worktree, then the bundle
# branch and its worktree scaffolding. Every ticket PR merges only into the bundle branch — never
# the integration target — until Land, so nothing this deletes has ever reached the target, whatever
# mix of done, doing, and todo tickets the bundle holds. Deleting the published `work/bundles/<id>`
# directory is not this script's job: that is a content commit on the integration target, the same
# kind of write Shape's publish and Land's delete already are, and belongs with the skill that makes
# it, not with branch mechanics.
#   usage: abandon-bundle.sh <bundle-id>
#   exit: 1 a branch refused to delete   2 no such bundle, or run from inside a worktree
#         9 already landed — run land-bundle.sh cleanup instead
set -euo pipefail

bundle="${1:-}"
[ -n "$bundle" ] || { echo "usage: abandon-bundle.sh <bundle-id>" >&2; exit 64; }

here="$(cd "$(dirname "$0")" && pwd)"
. "$here/_config.sh"
target="$INTEGRATION_TARGET"
bb=$(bundle_branch "$bundle")
land="$WORKTREE_DIR/land/$bundle"

# Every delete below is `git worktree remove --force`, and forcing the removal of the tree the
# process is standing in fails the rest silently. land-bundle.sh cleanup guards the same hazard.
if [ "$(git rev-parse --git-dir)" != "$(git rev-parse --git-common-dir)" ]; then
  echo "run abandon-bundle.sh from the main checkout, not from inside a worktree" >&2
  exit 2
fi

[ -d "work/bundles/$bundle" ] || { echo "no such bundle: $bundle" >&2; exit 2; }

git fetch -q origin

# A bundle already landed leaves a "chore(land): land bundle <id>" merge commit in the target's
# history — the exact message land-bundle.sh's `start` writes when it merges the bundle branch in.
# That is the only reliable "already landed" signal: the bundle branch's own ancestry can't tell a
# landed bundle from one nothing has ever merged into (both read as "an ancestor of the target"), and
# work/bundles/<id>'s absence on the target can't tell a landed bundle from one never published at
# all — a pre-Plan-gate draft has no directory on the target either, and abandoning that is exactly
# what this script is for.
# Anchored at the end: unanchored, a bundle id that is a strict prefix of another (2026-08-17-search
# vs. 2026-08-17-search-ui) would match the longer bundle's land commit too.
if git log -q --grep="chore(land): land bundle ${bundle}\$" "origin/$target" | grep -q .; then
  echo "$bundle already landed on $target — run land-bundle.sh cleanup, not abandon" >&2
  exit 9
fi

# Unlike land-bundle.sh cleanup, every ticket branch goes regardless of status. Cleanup keeps a
# not-yet-merged branch because it is a live claim another session still owns; abandon is the human
# choosing to discard the whole bundle, in-flight tickets included, and nothing outside this bundle
# can depend on keeping any of it — none of it ever reached the target.
delete_branch() { # <ref> -> 0 confirmed gone, now or already; 1 still there, or unresolved
  git push -q origin --delete "$1" 2>/dev/null && return 0
  # --exit-code is 2 for "no matching ref" specifically — anything else (including an unreachable
  # remote) is not a confirmed deletion, so it must not read as one (workflow/git-mechanics.md,
  # Status is derived: a query that cannot reach the forge reports unknown, never a guess).
  local rc=0
  git ls-remote --exit-code --heads origin "$1" >/dev/null 2>&1 || rc=$?
  [ "$rc" -eq 2 ]
}

refused=""
while read -r nn _; do
  [ -n "$nn" ] || continue
  tb=$(ticket_branch "$bundle" "$nn")
  git worktree remove --force "$WORKTREE_DIR/$tb" 2>/dev/null || true
  delete_branch "$tb" || refused="$refused $tb"
done <<<"$(ticket_names "$bundle")"

delete_branch "$bb" || refused="$refused $bb"
git worktree remove --force "$land" 2>/dev/null || true
git worktree prune
# git worktree remove deletes only the leaf it was given; drop the scaffolding directories it leaves,
# each only if empty — never a tree, and never anything above $WORKTREE_DIR.
rmdir "$WORKTREE_DIR/ticket/$bundle" "$WORKTREE_DIR/ticket" "$WORKTREE_DIR/land" "$WORKTREE_DIR" 2>/dev/null || true
git fetch -q --prune origin

if [ -n "$refused" ]; then
  echo "refused to delete:$refused — branch protection or a permissions gap; everything else was removed" >&2
  exit 1
fi
echo "abandoned $bundle — ticket and bundle branches and worktrees removed"
