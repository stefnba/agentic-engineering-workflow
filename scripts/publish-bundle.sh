#!/usr/bin/env bash
# Publish or revise a bundle: commit the working tree's approved work/bundles/<id>/ bytes, plus
# this session's work/backlog.md edit, onto the integration target — built in a detached worktree,
# never in the session's own checkout, whose index and files belong to the human.
#   usage: publish-bundle.sh <bundle-id> [<body-line>]
#   exit:  2 no such bundle in the working tree   3 bundle moved on the target mid-session
#          5 stale publish worktree   6 push retries exhausted
set -euo pipefail

bundle="$1"
body="${2:-}"
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/_config.sh"
target="$INTEGRATION_TARGET"
wt="$WORKTREE_DIR/publish/$bundle"

[ -d "work/bundles/$bundle" ] ||
  { echo "no work/bundles/$bundle in this working tree — run from the shaping session's checkout" >&2; exit 2; }
[ -e "$wt" ] &&
  { echo "stale publish worktree at $wt — an earlier publish left it; have it removed, then retry" >&2; exit 5; }

git fetch -q origin
session_head=$(git rev-parse HEAD)

tries=0
while :; do
  base=$(git rev-parse "origin/$target")

  # A bundle already on the target is a revision. One whose target copy differs from what this
  # session's HEAD knows was moved by someone else — a sibling revise, or a fresh publish that took
  # the same id — and overwriting it silently would discard bytes a human approved elsewhere.
  if git rev-parse -q --verify "$base:work/bundles/$bundle" >/dev/null 2>&1; then
    verb=revise
    if ! git rev-parse -q --verify "$session_head:work/bundles/$bundle" >/dev/null 2>&1 ||
       [ "$(git rev-parse "$base:work/bundles/$bundle")" != "$(git rev-parse "$session_head:work/bundles/$bundle")" ]; then
      echo "work/bundles/$bundle on $target is not the copy this session shaped against — a sibling" \
           "published or revised it; sync, re-check the approved bytes (or pick a new slug), retry" >&2
      exit 3
    fi
  else
    verb=publish
  fi

  git worktree add -q --detach "$wt" "$base"
  rm -rf "$wt/work/bundles/$bundle"
  mkdir -p "$wt/work/bundles"
  cp -R "work/bundles/$bundle" "$wt/work/bundles/$bundle"

  # Re-derive the session's backlog edit against the base rather than copying bytes over it: a
  # sibling session may have appended meanwhile, and the backlog always merges by keeping both
  # sides (git-mechanics.md, Backlog merges).
  if [ -f work/backlog.md ]; then
    git show "$session_head:work/backlog.md" > "$wt.backlog-base" 2>/dev/null || : > "$wt.backlog-base"
    [ -f "$wt/work/backlog.md" ] || : > "$wt/work/backlog.md"
    git merge-file --union "$wt/work/backlog.md" "$wt.backlog-base" work/backlog.md
    rm -f "$wt.backlog-base"
  fi

  git -C "$wt" add -A -- work/
  if [ -n "$body" ]; then
    git -C "$wt" commit -q -m "bundle: $verb $bundle" -m "$body"
  else
    git -C "$wt" commit -q -m "bundle: $verb $bundle"
  fi
  new=$(git -C "$wt" rev-parse HEAD)

  if err=$(git -C "$wt" push -q origin "HEAD:refs/heads/$target" 2>&1); then
    break
  fi
  git worktree remove --force "$wt" 2>/dev/null || true
  git worktree prune
  case "$err" in
    *reject*|*"fetch first"*|*"non-fast-forward"*) : ;;
    *) echo "$err" >&2; exit 1 ;;
  esac
  # Lost the race to a sibling push. Rebuild the commit on the moved base rather than merging —
  # a planning change earns no merge commit — and re-run the moved-bundle guard on that base.
  tries=$((tries + 1))
  if [ "$tries" -ge 3 ]; then
    echo "push to $target lost the race $tries times — the target is moving; retry when it settles" >&2
    exit 6
  fi
  sleep 1
  git fetch -q origin
done

git worktree remove --force "$wt" 2>/dev/null || true
git worktree prune
rmdir "$WORKTREE_DIR/publish" "$WORKTREE_DIR" 2>/dev/null || true
git fetch -q origin

# The published backlog may carry a sibling's line this session's copy lacks; make the working
# copy the published bytes so a later publish can't read the difference as a deletion.
if [ -f work/backlog.md ] && git rev-parse -q --verify "origin/$target:work/backlog.md" >/dev/null 2>&1; then
  git show "origin/$target:work/backlog.md" > work/backlog.md
fi

# Fast-forward the session's checkout only in the provably clean case: it sits on the target at
# the very base the commit was built on, so after the ref moves, refreshing work/'s index entries
# leaves a clean status — the pushed bytes are the working bytes — and touches nothing else.
if [ "$(git rev-parse --abbrev-ref HEAD)" = "$target" ] && [ "$(git rev-parse "refs/heads/$target")" = "$base" ]; then
  git update-ref "refs/heads/$target" "$new"
  git reset -q -- work/
  synced="local $target synced"
elif [ "$(git rev-parse --abbrev-ref HEAD)" = "$target" ] &&
     git merge-base --is-ancestor "refs/heads/$target" "$new"; then
  # Behind the base: the draft's bytes are on the target now, but git's overwrite guards check
  # existence, not content, so the untracked draft and the modified backlog would block the
  # fast-forward — and every later pull. Clear both (their bytes are safe on the target), then
  # fast-forward; if that still refuses, put the draft back and leave the sync to a pull.
  tmpkeep=$(mktemp -d)
  cp -R "work/bundles/$bundle" "$tmpkeep/"
  rm -rf "work/bundles/$bundle"
  git checkout -q HEAD -- work/backlog.md 2>/dev/null || true
  if git merge -q --ff-only "origin/$target" >/dev/null 2>&1; then
    synced="local $target synced"
  else
    cp -R "$tmpkeep/$bundle" "work/bundles/$bundle"
    synced="local $target is behind origin/$target — pull when convenient"
  fi
  rm -rf "$tmpkeep"
else
  synced="local $target is behind origin/$target — pull when convenient"
fi
echo "bundle: $verb $bundle -> $target ($new); $synced"
