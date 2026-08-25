#!/usr/bin/env bash
# Deterministic git for Land. Three verbs, because what happens between them is judgment the `land`
# skill owns: absorbing durable knowledge, draining the backlog, deleting the bundle, and re-running
# the repository's canonical checks.
#
#   land-bundle.sh start   <bundle-id>  detached worktree on the integration target, bundle merged in
#   land-bundle.sh push    <bundle-id>  publish that worktree's tip on the integration target
#   land-bundle.sh cleanup <bundle-id>  delete the bundle's branches, remove its worktrees
#
#   exit: 1 cleanup could not verify a branch — it and its worktree stay
#           (a fully unreachable forge stops earlier, at the fetch, with git's own exit)
#         2 no such bundle, push before start, or cleanup from inside a worktree
#         3 a ticket is not done, or its PR record could not be queried
#         4 no bundle branch        5 stale land worktree
#         6 the target moved — re-run the canonical checks, then push again
#         7 merge conflict left in the land worktree, for the human to resolve
#         8 a commit on the bundle branch matches no merged ticket PR
#         9 the bundle branch is not landed — cleanup deletes nothing
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
  # Every bundle lands through its bundle branch — the first claim creates it, and nothing merges
  # into the target except this stage. A missing branch means no ticket was ever claimed, or a
  # cleanup already deleted it.
  if ! git ls-remote --exit-code --heads origin "$bb" >/dev/null 2>&1; then
    echo "no bundle branch for $bundle — nothing to land: no ticket was ever claimed, or cleanup already removed the branch" >&2
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
  # Content reaches a bundle branch only through an accepted ticket PR
  # (workflow/git-mechanics.md, Bundle-branch writes). Enforce it structurally: every first-parent
  # commit the branch adds over the target must be the merge record of one of this bundle's ticket
  # PRs — the same set the done-gate above iterated. A merged PR from any other head is no license:
  # its content passed no Accept gate. One with no record at all was pushed directly. Either way,
  # landing it would publish work no review ever saw.
  if ! pairs=$(gh pr list --base "$bb" --state merged --json headRefName,mergeCommitOid \
      -q '.[] | .headRefName + " " + .mergeCommitOid'); then
    echo "cannot query pull requests — refusing to land commits that cannot be matched to a PR" >&2
    exit 3
  fi
  allowed=""
  while read -r nn _; do
    [ -n "$nn" ] || continue
    allowed+="$(awk -v h="$(ticket_branch "$bundle" "$nn")" '$1==h {print $2}' <<<"$pairs")"$'\n'
  done <<<"$(ticket_names "$bundle")"
  for sha in $(git rev-list --first-parent "origin/$target..origin/$bb"); do
    grep -qx "$sha" <<<"$allowed" ||
      { echo "unrecorded commit on $bb: $sha matches no merged ticket PR — take it to the human before landing" >&2; exit 8; }
  done

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

  git fetch -q origin

  # exists | absent | unknown. ls-remote's --exit-code is 2 for "no matching ref" specifically;
  # anything else — an unreachable forge included — is unknown, and couldn't tell is not
  # permission to delete (workflow/git-mechanics.md, Status is derived). abandon-bundle.sh
  # draws the same line.
  branch_state() { # <ref>
    local rc=0
    git ls-remote --exit-code --heads origin "$1" >/dev/null 2>&1 || rc=$?
    case "$rc" in 0) echo exists ;; 2) echo absent ;; *) echo unknown ;; esac
  }

  # The bundle branch is the only copy of accepted work until the land publishes it — squashed
  # ticket branches never held it. Deleting an unlanded one is data loss, so refuse everything.
  case "$(branch_state "$bb")" in
  exists)
    if ! git merge-base --is-ancestor "origin/$bb" "origin/$target"; then
      echo "not landed: $bb carries work $target does not have — land it first; cleanup deletes nothing until then" >&2
      exit 9
    fi
    ;;
  unknown)
    echo "cannot reach the forge to check $bb — nothing is deleted; fix the connection, then retry" >&2
    exit 1
    ;;
  esac

  unverified=""
  while read -r nn _; do
    [ -n "$nn" ] || continue
    tb=$(ticket_branch "$bundle" "$nn")
    # A ticket branch whose PR is not merged is a live claim — deleting it cancels work another
    # session owns. unknown skips too: couldn't tell is not permission.
    case "$(branch_state "$tb")" in
    exists)
      st=$("$here/ticket-status.sh" "$bundle" "$nn") || st=unknown
      if [ "$st" != done ]; then
        echo "kept $tb — ticket $nn is $st, so its branch and worktree stay" >&2
        continue
      fi
      ;;
    unknown)
      echo "kept $tb — the forge could not be queried, so its branch and worktree stay" >&2
      unverified="$unverified $tb"
      continue
      ;;
    esac
    git worktree remove --force "$WORKTREE_DIR/$tb" 2>/dev/null || true
    git push -q origin --delete "$tb" 2>/dev/null || true # already gone when the forge deletes on merge
  done <<<"$(ticket_names "$bundle")"

  git push -q origin --delete "$bb" 2>/dev/null || true
  git worktree remove --force "$land" 2>/dev/null || true
  git worktree prune
  # git worktree remove deletes only the leaf it was given; drop the scaffolding directories it
  # leaves, each only if empty — never a tree, and never anything above $WORKTREE_DIR.
  rmdir "$WORKTREE_DIR/ticket/$bundle" "$WORKTREE_DIR/ticket" "$WORKTREE_DIR/land" "$WORKTREE_DIR" 2>/dev/null || true
  # Pruning stale remote-tracking refs is cosmetic; a failure here must not eat the summary below.
  git fetch -q --prune origin || true
  if [ -n "$unverified" ]; then
    echo "could not verify:$unverified — their branches and worktrees stay; fix the connection, then retry" >&2
    exit 1
  fi
  echo "cleaned up $bundle — branches and worktrees removed"
  ;;

*)
  echo "unknown verb: $verb (start|push|cleanup)" >&2
  exit 64
  ;;
esac
