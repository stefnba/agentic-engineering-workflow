#!/usr/bin/env bash
# Publish or revise a bundle: commit the working tree's approved work/bundles/<id>/ bytes, plus
# this session's work/backlog.md edit, onto the integration target — built in a detached worktree,
# never in the session's own checkout, whose index and files belong to the human.
#   usage: publish-bundle.sh [--allow-diverged] <bundle-id> [<body-line>]
#   exit:  2 no such bundle in the working tree   3 bundle moved on the target mid-session
#          4 local target ahead of origin (sync, or rerun with --allow-diverged)
#          5 stale publish worktree   6 push retries exhausted
set -euo pipefail

allow_diverged=
[ "${1:-}" = "--allow-diverged" ] && { allow_diverged=1; shift; }
bundle="${1:-}"
body="${2:-}"
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/_config.sh"
target="$INTEGRATION_TARGET"
wt="$WORKTREE_DIR/publish/$bundle"

# Every path here is built as work/bundles/$bundle — the copy source, the scratch worktree's
# target, and the rm -rf that settles the human's own checkout. A traversal id passes the directory
# test below and resolves that rm to the checkout root, so refuse anything that is not a plain
# directory name before a byte is read or removed.
case "$bundle" in
  '' | . | .. | */*)
    echo "bundle id '$bundle' is not a bundle directory name — expected <date>-<slug>, no path separators" >&2
    exit 2
    ;;
esac

[ -d "work/bundles/$bundle" ] ||
  { echo "no work/bundles/$bundle in this working tree — run from the shaping session's checkout" >&2; exit 2; }
[ -e "$wt" ] &&
  { echo "stale publish worktree at $wt — an earlier publish left it; have it removed, then retry" >&2; exit 5; }

git fetch -q origin
session_head=$(git rev-parse HEAD)

# The commit is built on origin/$target, so commits a local $target holds beyond it are not
# carried and the checkout ends diverged from the branch the bundle now lives on. That is the
# human's call, not the script's: stop before writing anything and let them push, drop, or accept
# the divergence — --allow-diverged is that acceptance.
if git rev-parse -q --verify "refs/heads/$target" >/dev/null 2>&1 &&
   ! git merge-base --is-ancestor "refs/heads/$target" "origin/$target"; then
  if [ -z "$allow_diverged" ]; then
    ahead=$(git rev-list --count "origin/$target..refs/heads/$target")
    behind=$(git rev-list --count "refs/heads/$target..origin/$target")
    if [ "$behind" -gt 0 ]; then
      fix="a plain push will be rejected as non-fast-forward — pull or rebase onto origin/$target first, then push"
    else
      fix="push them"
    fi
    echo "local $target has $ahead commit(s) origin/$target lacks;" \
         "the publish builds on origin/$target and would leave the two diverged —" \
         "$fix, or drop them, and rerun; or rerun with --allow-diverged to publish anyway" >&2
    exit 4
  fi
  echo "note: publishing with local $target ahead of origin/$target — the publish carries only origin's side" >&2
fi

tries=0
while :; do
  base=$(git rev-parse "origin/$target")

  # A bundle already on the target is a revision. One whose target copy differs from what this
  # session's HEAD knows moved after this session last synced — a sibling's revise, a fresh publish
  # that took the same id, or a publish of this checkout's own that could not fast-forward it — and
  # overwriting it silently would discard bytes a human approved elsewhere. Which of the three it is
  # cannot be told from here, so name them rather than sending the human after a sibling.
  if git rev-parse -q --verify "$base:work/bundles/$bundle" >/dev/null 2>&1; then
    verb=revise
    if ! git rev-parse -q --verify "$session_head:work/bundles/$bundle" >/dev/null 2>&1 ||
       [ "$(git rev-parse "$base:work/bundles/$bundle")" != "$(git rev-parse "$session_head:work/bundles/$bundle")" ]; then
      echo "work/bundles/$bundle on $target is not the copy this session shaped against — a sibling" \
           "published or revised it, or an earlier publish from this checkout never synced back into" \
           "it; sync, re-check the approved bytes (or pick a new slug), retry" >&2
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

# Return work/ to HEAD's state: the pushed commit holds the draft's exact bytes and the
# union-merged backlog, so nothing under work/ is the only copy — while a leftover untracked
# draft or modified backlog would block every later pull (git's overwrite guards check
# existence, not content) and keep the shape-session write fence armed.
settle_work() {
  git reset -q -- work/
  rm -rf "work/bundles/$bundle"
  git checkout -q HEAD -- "work/bundles/$bundle" 2>/dev/null || true
  rm -f work/backlog.md
  git checkout -q HEAD -- work/backlog.md 2>/dev/null || true
}

# A publish that cannot fast-forward leaves work/ back at HEAD, so the bytes just pushed live on
# origin/$target alone — and ticket_names reads the working tree, so bundle-status.sh and
# claim-ticket.sh would both report the bundle missing in the very session that published it. Name
# the sync that makes it claimable instead of reporting a bare branch state.
unsynced() { # <branch state> <the sync that fixes it>
  echo "$1 — work/ is back at HEAD, so this checkout does not hold the published $bundle;" \
       "$2 before claiming a ticket"
}

# Fast-forward the session's checkout only in the provably clean case: it sits on the target at
# the very base the commit was built on, so after the ref moves, refreshing work/'s index entries
# leaves a clean status — the pushed bytes are the working bytes — and touches nothing else.
if [ "$(git rev-parse --abbrev-ref HEAD)" = "$target" ] && [ "$(git rev-parse "refs/heads/$target")" = "$base" ]; then
  git update-ref "refs/heads/$target" "$new"
  git reset -q -- work/
  synced="local $target synced"
elif [ "$(git rev-parse --abbrev-ref HEAD)" = "$target" ] &&
     git merge-base --is-ancestor "refs/heads/$target" "$new"; then
  # Behind the base: settle first so the overwrite guards have nothing to refuse, then
  # fast-forward; if the merge still refuses, work/ at least stays clean for the later pull.
  settle_work
  if git merge -q --ff-only "origin/$target" >/dev/null 2>&1; then
    synced="local $target synced"
  else
    synced=$(unsynced "local $target is behind origin/$target" "pull")
  fi
elif [ "$(git rev-parse --abbrev-ref HEAD)" = "$target" ]; then
  settle_work
  synced=$(unsynced "local $target and origin/$target have diverged and the publish carries only origin's side" "merge or rebase")
else
  settle_work
  synced=$(unsynced "this checkout is not on $target" "switch to $target and pull")
fi
echo "bundle: $verb $bundle -> $target ($new); $synced"
