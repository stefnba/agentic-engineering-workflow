#!/usr/bin/env bash
# Deterministic git for Land. Three verbs, because what happens between them is judgment the `land`
# skill owns: absorbing durable knowledge, draining the backlog, deleting the bundle, and re-running
# the repository's canonical checks.
#
#   land-bundle.sh start   <bundle-id>  detached worktree on the integration target, bundle merged in
#   land-bundle.sh push    <bundle-id>  publish that worktree's tip on the integration target
#   land-bundle.sh cleanup <bundle-id>  delete the bundle's branches, remove its worktrees
#
#   exit: 2 no such bundle          3 a ticket is not done
#         4 nothing to land         5 stale land worktree
#         6 the target moved — re-run the canonical checks, then push again
#         7 merge conflict left in the land worktree, for the human to resolve
set -euo pipefail

verb="${1:-}"
bundle="${2:-}"
[ -n "$verb" ] && [ -n "$bundle" ] || { echo "usage: land-bundle.sh start|push|cleanup <bundle-id>" >&2; exit 64; }

here="$(cd "$(dirname "$0")" && pwd)"
. "$here/_config.sh"
target="$INTEGRATION_TARGET"
bb=$(bundle_branch "$bundle")
land="$WORKTREE_DIR/land/$bundle"

[ -d "work/bundles/$bundle" ] || { echo "no such bundle: $bundle" >&2; exit 2; }

# work/backlog.md is append-mostly and written from several branches at once — a Shape session adding
# a Critic candidate on the integration target, Land draining leftovers here — so a conflict in it is
# two lines that both belong. Keeping both sides is the rule either way
# (workflow/git-mechanics.md); resolving it here is what keeps that rule from stopping a land, and
# costs nothing outside this merge. A .gitattributes would buy the same thing by changing merge
# behaviour for every person and tool in the repository, which is not this workflow's to change.
resolve_backlog() { # <worktree> -> 0 when nothing is left unmerged
  local wt=$1 f=work/backlog.md tmp
  git -C "$wt" ls-files --unmerged -- "$f" | grep -q . || return 1
  tmp=$(mktemp -d)
  git -C "$wt" show ":1:$f" > "$tmp/base" 2>/dev/null || : > "$tmp/base" # add/add has no base
  git -C "$wt" show ":2:$f" > "$tmp/ours"
  git -C "$wt" show ":3:$f" > "$tmp/theirs"
  git merge-file --union "$tmp/ours" "$tmp/base" "$tmp/theirs"
  cp "$tmp/ours" "$wt/$f"
  rm -rf "$tmp"
  git -C "$wt" add -- "$f"
  [ -z "$(git -C "$wt" diff --name-only --diff-filter=U)" ]
}

land_merge() { # <worktree> <message> <ref> -> 0 merged, 1 conflicts left for the human
  if git -C "$1" merge --no-ff -m "$2" "$3"; then return 0; fi
  if resolve_backlog "$1"; then
    git -C "$1" commit -q --no-edit
    echo "resolved work/backlog.md by keeping both sides" >&2
    return 0
  fi
  return 1
}

case "$verb" in
start)
  # A single-ticket bundle's only PR already merged into the target, so there is no branch to land.
  # Land still runs — its reconcile, drain and delete commits go to the session's own checkout.
  if ! git ls-remote --exit-code --heads origin "$bb" >/dev/null 2>&1; then
    echo "no bundle branch for $bundle — reconcile, drain and delete on $target in this checkout" >&2
    exit 4
  fi

  # Report the status actually observed, exactly as the claim gate does: a failed query is unknown,
  # not done. Landing on a ticket whose PR record could not be read would land unreviewed work.
  while read -r nn _; do
    [ -n "$nn" ] || continue
    st=$("$here/ticket-status.sh" "$bundle" "$nn") || st=unknown
    [ "$st" = done ] || { echo "not landable: ticket $nn is $st — land only when every ticket is done (unknown means the forge, not the ticket)" >&2; exit 3; }
  done <<<"$(ticket_names "$bundle")"

  [ -e "$land" ] && { echo "stale land worktree at $land — a previous land left it; have it removed, then retry" >&2; exit 5; }

  git fetch -q origin
  # Detached, and it has to be: the session's own checkout already holds the integration target, and
  # git gives a branch to one worktree at a time. It is also what makes an abandoned land free —
  # nothing is named until the push, so a failed check is a directory to delete.
  git worktree add -q --detach "$land" "origin/$target"
  if ! land_merge "$land" "chore(land): land bundle $bundle" "origin/$bb"; then
    echo "conflict landing $bb onto $target — resolve in $land, then re-run push" >&2
    exit 7
  fi
  echo "landing $bundle in $land — $bb merged onto $target"
  ;;

push)
  [ -d "$land" ] || { echo "no land worktree at $land — run start first" >&2; exit 2; }

  # The target can move between start and here, and again between this check and the push itself.
  # Either way the answer is the same: merge it in and stop, because the merged state is one no check
  # has run against. The caller re-runs the canonical checks and calls push again.
  reconcile_and_stop() {
    if ! land_merge "$land" "chore(land): merge $target into the land" "origin/$target"; then
      echo "conflict reconciling with $target — resolve in $land, then re-run push" >&2
      exit 7
    fi
    echo "$target moved and was merged in — re-run the canonical checks, then push again" >&2
    exit 6
  }

  git fetch -q origin
  git -C "$land" merge-base --is-ancestor "origin/$target" HEAD || reconcile_and_stop
  git -C "$land" push -q origin "HEAD:$target" || { git fetch -q origin; reconcile_and_stop; }
  echo "landed $bundle on $target"
  ;;

cleanup)
  # Land's own worktree goes last and from outside it; removing the tree a step is standing in fails.
  # A linked worktree has its own git dir under the main one's, which is how this tells them apart —
  # a path comparison would not, since every path here is relative to wherever the caller stands.
  if [ "$(git rev-parse --git-dir)" != "$(git rev-parse --git-common-dir)" ]; then
    echo "run cleanup from the main checkout, not from inside a worktree" >&2
    exit 2
  fi

  while read -r nn _; do
    [ -n "$nn" ] || continue
    tb=$(ticket_branch "$bundle" "$nn")
    git worktree remove --force "$WORKTREE_DIR/$tb" 2>/dev/null || true
    git push -q origin --delete "$tb" 2>/dev/null || true # already gone when the forge deletes on merge
  done <<<"$(ticket_names "$bundle")"

  git push -q origin --delete "$bb" 2>/dev/null || true
  git worktree remove --force "$land" 2>/dev/null || true
  git worktree prune
  git fetch -q --prune origin
  echo "cleaned up $bundle — branches and worktrees removed"
  ;;

*)
  echo "unknown verb: $verb (start|push|cleanup)" >&2
  exit 64
  ;;
esac
