#!/usr/bin/env bash
# Abandon a bundle that will never land: delete every ticket branch and worktree, then the bundle
# branch and its worktree scaffolding. Every ticket PR merges only into the bundle branch — never
# the integration target — until Land, so nothing this deletes has ever reached the target, whatever
# mix of done, doing, and todo tickets the bundle holds. Deleting the published `work/bundles/<id>`
# directory is not this script's job: that is a content commit on the integration target, the same
# kind of write Shape's publish and Land's delete already are, and belongs with the skill that makes
# it, not with branch mechanics.
#   usage: abandon-bundle.sh <bundle-id>
#   exit: 2 no such bundle   9 bundle branch already landed — run land-bundle.sh cleanup instead
set -euo pipefail

bundle="${1:-}"
[ -n "$bundle" ] || { echo "usage: abandon-bundle.sh <bundle-id>" >&2; exit 64; }

here="$(cd "$(dirname "$0")" && pwd)"
. "$here/_config.sh"
target="$INTEGRATION_TARGET"
bb=$(bundle_branch "$bundle")

[ -d "work/bundles/$bundle" ] || { echo "no such bundle: $bundle" >&2; exit 2; }

git fetch -q origin

# Land is the only thing that ever deletes work/bundles/<id> (workflow/bundle.md, Lifetime), so its
# absence from the target is what "already landed" actually means. The bundle branch's own ancestry
# can't tell the two cases apart: a bundle branch nothing has merged into yet is still trivially "an
# ancestor" of the target, because it was cut from it and never diverged.
if ! git cat-file -e "origin/$target:work/bundles/$bundle" 2>/dev/null; then
  echo "$bundle already landed on $target (its directory is gone there) — run land-bundle.sh cleanup, not abandon" >&2
  exit 9
fi

# Unlike land-bundle.sh cleanup, every ticket branch goes regardless of status. Cleanup keeps a
# not-yet-merged branch because it is a live claim another session still owns; abandon is the human
# choosing to discard the whole bundle, in-flight tickets included, and nothing outside this bundle
# can depend on keeping any of it — none of it ever reached the target.
while read -r nn _; do
  [ -n "$nn" ] || continue
  tb=$(ticket_branch "$bundle" "$nn")
  git worktree remove --force "$WORKTREE_DIR/$tb" 2>/dev/null || true
  git push -q origin --delete "$tb" 2>/dev/null || true
done <<<"$(ticket_names "$bundle")"

git push -q origin --delete "$bb" 2>/dev/null || true
git worktree prune
# git worktree remove deletes only the leaf it was given; drop the scaffolding directories it leaves,
# each only if empty — never a tree, and never anything above $WORKTREE_DIR.
rmdir "$WORKTREE_DIR/ticket/$bundle" "$WORKTREE_DIR/ticket" "$WORKTREE_DIR" 2>/dev/null || true
git fetch -q --prune origin
echo "abandoned $bundle — ticket and bundle branches and worktrees removed"
