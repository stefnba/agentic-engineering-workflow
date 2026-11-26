#!/usr/bin/env bash
# Deterministic bundle and ticket branch transitions. Sources lib.sh for the statuses.
#   <target> is the bundle's integration target, read by the agent from its scope's AGENTS.md.
#   usage: branch.sh cut <ref> <target>   cut bundle/<ref> from <target> and check it out in a worktree
#          branch.sh claim <ref> <NN>     create ticket/<ref>/<NN> from the bundle branch, in a worktree
#          branch.sh abandon <ref> [--execute]   list, or with --execute delete, every branch and
#                                         worktree of the bundle; a landed bundle loses leftovers only
#          branch.sh complete <pr> <sha>  squash-merge an accepted ticket PR only at the accepted head,
#                                         refusing a branch that is stale against its bundle branch
#          branch.sh check-land <ref> <target>   exit 2 naming any commit on the bundle branch, counted
#                                         from <target>, that no ticket PR made
#   Raw commands, for reading when a step fails:
#     cut:     git push origin origin/<target>:refs/heads/bundle/<ref>
#              git worktree add -b bundle/<ref> <wt>/bundle/<ref> origin/bundle/<ref>
#     claim:   git push --porcelain origin origin/bundle/<ref>:refs/heads/ticket/<ref>/<NN>   ('*' = ours)
#              git worktree add -b ticket/<ref>/<NN> <wt>/ticket/<ref>/<NN> origin/ticket/<ref>/<NN>
#     complete: git merge-base --is-ancestor origin/bundle/<ref> origin/ticket/<ref>/<NN>
#              gh pr merge <pr> --squash --match-head-commit <sha>
#     abandon: git worktree remove --force; git branch -D; git push origin --delete
#   cut, claim, complete, and abandon refuse to run from inside a worktree. Nothing is ever force-pushed.
#   exit:  0 done   1 outside a git work tree   2 an unmet precondition, named in one line on stderr
set -uo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

die() { echo "$*" >&2; exit 2; }

# Bundle references are <bundle-id> or <member>/<bundle-id>; refuse anything that could leave the tree.
valid_ref() {
  case "$1" in ''|/*|*/|*..*) die "not a bundle reference: '$1' — expected <bundle-id> or <member>/<bundle-id>" ;; esac
}

# A target must be a plain branch name that exists on the remote: cut pushes from it and check-land
# counts from it, so a typo would cut from nothing or count every commit of another branch.
valid_target() {
  case "$1" in ''|-*|*..*|refs/*|origin/*) die "not a branch name: '$1' — pass the integration target from the scope's AGENTS.md, such as main" ;; esac
  [ -n "$remote_ok" ] || die "remote unreachable: cannot check that $1 exists on origin"
  [ -n "$(git ls-remote --heads origin "refs/heads/$1" 2>/dev/null)" ] ||
    die "no branch $1 on origin — check the Integration target line in the scope's AGENTS.md"
}

# Every first-parent commit between the target and the bundle branch must be the merge or squash
# commit of a merged ticket PR, a target sync merge, or a `bundle:` commit that touches only the
# bundle's own folder and its work folder's backlog.md. Anything else was written to the bundle branch without a ticket PR.
check_land() { # <ref> <target>
  local ref="$1" target="$2" work id sha subj bad=() merged parents p files
  valid_ref "$ref"
  [ -n "$remote_ok" ] || die "remote unreachable: cannot read origin/bundle/$ref"
  valid_target "$target"
  git fetch -q origin "+refs/heads/$target:refs/remotes/origin/$target" 2>/dev/null ||
    die "cannot fetch $target from origin"
  git rev-parse -q --verify "origin/bundle/$ref" >/dev/null || die "no bundle/$ref on the remote"
  merged=$(merged_commits "bundle/$ref") || die "forge unreachable: cannot list merged ticket PRs"
  work=$(work_dir_of "$ref"); id="${ref##*/}"
  for sha in $(git rev-list --first-parent "origin/$target..origin/bundle/$ref"); do
    grep -Fxq "$sha" <<<"$merged" && continue
    parents=$(git rev-list --parents -n1 "$sha" | awk '{for (i = 3; i <= NF; i++) print $i}')
    if [ -n "$parents" ]; then # a merge of the target into the bundle branch keeps it current
      local all=y
      for p in $parents; do git merge-base --is-ancestor "$p" "origin/$target" || all=; done
      [ -n "$all" ] && continue
    fi
    subj=$(git log -1 --format=%s "$sha")
    case "$subj" in
      bundle:*)
        files=$(git show --name-only --format= "$sha")
        if grep -qvE "^($work/bundles/$id/.*|$work/backlog\.md)\$" <<<"$files"; then
          bad+=("$sha $subj (touches paths outside $work/bundles/$id/ and $work/backlog.md)")
        fi ;;
      *) bad+=("$sha $subj") ;;
    esac
  done
  [ "${#bad[@]}" -eq 0 ] || die "commits on bundle/$ref not from a merged ticket PR: $(printf '%s; ' "${bad[@]}")"
}

no_worktree() {
  ! in_worktree || die "run from the main checkout at $(main_checkout), not from inside a worktree"
}

need_wt() { [ -n "$wt" ] || die "no worktree directory: docs/conventions/git.md has no Worktree directory line"; }

tidy() { # remove empty scaffolding directories above a removed worktree, never $wt itself
  local d
  d=$(dirname "$1")
  while [ "$d" != "$root/$wt" ] && [ "$d" != "/" ] && rmdir "$d" 2>/dev/null; do d=$(dirname "$d"); done
}

fetch_one() { git fetch -q origin "+refs/heads/$1:refs/remotes/origin/$1" 2>/dev/null || die "cannot fetch $1 from origin"; }

cut_bundle() { # <ref> <target>
  local ref="$1" target="$2" st out path="$root/$wt/bundle/$1"
  no_worktree; valid_ref "$ref"; need_wt; valid_target "$target"
  st=$(bundle_status "$ref")
  [ "$st" = draft ] || die "cannot cut bundle/$ref: its status is $st, not draft"
  git show-ref --verify --quiet "refs/heads/bundle/$ref" && die "local branch bundle/$ref already exists"
  [ ! -e "$path" ] || die "worktree $path already exists"
  fetch_one "$target"
  out=$(git push --porcelain origin "origin/$target:refs/heads/bundle/$ref" 2>&1) ||
    die "push of bundle/$ref rejected: $(tr '\n' ' ' <<<"$out")"
  grep -q '^\*' <<<"$out" || die "another session created bundle/$ref first; stop"
  fetch_one "bundle/$ref"
  git worktree add -q -b "bundle/$ref" "$path" "origin/bundle/$ref" || die "git worktree add failed for $path"
  echo "cut bundle/$ref from $target"
  echo "$path"
}

claim() { # <ref> <NN>
  local ref="$1" nn="$2" st file dep out path="$root/$wt/ticket/$1/$2"
  no_worktree; valid_ref "$ref"; need_wt
  [[ "$nn" =~ ^[0-9]{2}$ ]] || die "not a ticket number: '$nn' — expected two digits like 01"
  st=$(bundle_status "$ref")
  [ "$st" = active ] || die "cannot claim in bundle $ref: its status is $st, not active"
  file=$(ticket_file "$ref" "$nn")
  [ -n "$file" ] || die "no ticket $nn in bundle $ref on origin/bundle/$ref"
  out=$(ticket_depends "$ref" "$file") || exit 2
  for dep in $out; do
    st=$(ticket_status "$ref" "$dep")
    [ "$st" = done ] || die "cannot claim $nn: dependency $dep is $st, not done"
  done
  st=$(ticket_status "$ref" "$nn")
  [ "$st" = todo ] || die "cannot claim $nn: its status is $st, not todo"
  [ ! -e "$path" ] || die "worktree $path already exists"
  git show-ref --verify --quiet "refs/heads/ticket/$ref/$nn" && die "local branch ticket/$ref/$nn already exists"
  out=$(git push --porcelain origin "origin/bundle/$ref:refs/heads/ticket/$ref/$nn" 2>&1) ||
    die "push of ticket/$ref/$nn rejected: $(tr '\n' ' ' <<<"$out")"
  grep -q '^\*' <<<"$out" || die "ticket $nn was claimed by another session first; stop"
  fetch_one "ticket/$ref/$nn"
  git worktree add -q -b "ticket/$ref/$nn" "$path" "origin/ticket/$ref/$nn" || die "git worktree add failed for $path"
  echo "$path"
}

# The human's Accept covers the exact head the last review round judged. The forge enforces that
# through --match-head-commit, so a commit pushed after the review never merges as reviewed. A
# ticket branch missing a sibling's merge was verified against an older bundle branch; the two can
# merge cleanly and still be broken, so it is refused rather than merged.
complete() { # <pr> <accepted-sha>
  local pr="$1" sha="$2" head="" base="" ref path
  no_worktree
  [[ "$pr" =~ ^[0-9]+$ ]] || die "not a PR number: '$pr'"
  read -r head base < <(gh pr view "$pr" --json headRefName,baseRefName -q '.headRefName + " " + .baseRefName' 2>/dev/null)
  [ -n "$head" ] && [ -n "$base" ] || die "cannot read PR #$pr from the forge; nothing merged"
  case "$head" in ticket/*/[0-9][0-9]) ;; *) die "PR #$pr is from $head, not a ticket branch" ;; esac
  ref="${head#ticket/}"; ref="${ref%/*}"
  [ "$base" = "bundle/$ref" ] || die "PR #$pr targets $base, not bundle/$ref"
  fetch_one "$base"; fetch_one "$head"
  sha=$(git rev-parse -q --verify "$sha^{commit}") || die "unknown commit '$2' — pass the head SHA the last review round judged"
  git merge-base --is-ancestor "origin/$base" "origin/$head" ||
    die "stale: $head does not contain the current $base — merge it in, re-verify, and run another review round"
  gh pr merge "$pr" --squash --match-head-commit "$sha" >/dev/null 2>&1 ||
    die "the forge refused to merge PR #$pr at $sha — the head moved since the review, or a check or protection blocks it; nothing merged"
  if [ -n "$wt" ]; then
    path="$root/$wt/$head"
    [ ! -e "$path" ] || { git worktree remove --force "$path" 2>/dev/null && tidy "$path"; }
  fi
  git branch -D -q "$head" >/dev/null 2>&1
  git push -q origin --delete "$head" 2>/dev/null
  git fetch -q --prune origin "+refs/heads/ticket/*:refs/remotes/origin/ticket/*" 2>/dev/null
  echo "merged PR #$pr ($head) into $base"
}

abandon() { # <ref> [--execute]
  local ref="$1" exec="${2:-}" st lead b w
  local wts=() locals=() remotes=()
  no_worktree; valid_ref "$ref"; need_wt
  [ -z "$exec" ] || [ "$exec" = --execute ] || die "unknown option '$exec' — the only option is --execute"
  st=$(bundle_status "$ref")
  case "$st" in active|draft|landed) ;; *) die "cannot abandon $ref: its status is $st and it may have landed" ;; esac
  # Worktrees of this bundle: its own, and every ticket's, found through git rather than guessed.
  while read -r w; do
    case "$w" in "$root/$wt/bundle/$ref"|"$root/$wt/ticket/$ref/"*) wts+=("$w") ;; esac
  done < <(git worktree list --porcelain | sed -n 's/^worktree //p')
  while read -r b; do locals+=("$b"); done < <(git for-each-ref --format='%(refname:short)' \
    "refs/heads/bundle/$ref" "refs/heads/ticket/$ref/")
  while read -r b; do remotes+=("${b#origin/}"); done < <(git for-each-ref --format='%(refname:short)' \
    "refs/remotes/origin/bundle/$ref" "refs/remotes/origin/ticket/$ref/")
  lead="$ref is $st"; [ "$st" = landed ] && lead="$lead: removing leftovers only"
  if [ "$exec" = --execute ]; then echo "$lead"; else echo "$lead; dry run, pass --execute to remove:"; fi
  for w in ${wts[@]+"${wts[@]}"}; do echo "  worktree $w"; done
  for b in ${locals[@]+"${locals[@]}"}; do echo "  local branch $b"; done
  for b in ${remotes[@]+"${remotes[@]}"}; do echo "  remote branch origin/$b"; done
  [ "$exec" = --execute ] || return 0
  local refused=""
  for w in ${wts[@]+"${wts[@]}"}; do
    if git worktree remove --force "$w" 2>/dev/null; then tidy "$w"; else refused="$refused worktree:$w"; fi
  done
  git worktree prune
  for b in ${locals[@]+"${locals[@]}"}; do git branch -D -q "$b" >/dev/null 2>&1 || refused="$refused local:$b"; done
  for b in ${remotes[@]+"${remotes[@]}"}; do git push -q origin --delete "$b" 2>/dev/null || refused="$refused origin/$b"; done
  git fetch -q --prune origin '+refs/heads/bundle/*:refs/remotes/origin/bundle/*' \
    '+refs/heads/ticket/*:refs/remotes/origin/ticket/*' 2>/dev/null || true
  [ -z "$refused" ] || die "not removed:$refused — a locked worktree, branch protection, or permissions; everything else was removed"
}

case "${1:-}" in
  cut)        [ $# -eq 3 ] || die "usage: branch.sh cut <bundle-reference> <integration-target>"; cut_bundle "$2" "$3" ;;
  claim)      [ $# -eq 3 ] || die "usage: branch.sh claim <bundle-reference> <NN>"; claim "$2" "$3" ;;
  complete)   [ $# -eq 3 ] || die "usage: branch.sh complete <pr> <accepted-head-sha>"; complete "$2" "$3" ;;
  abandon)    [ $# -ge 2 ] && [ $# -le 3 ] || die "usage: branch.sh abandon <bundle-reference> [--execute]"; abandon "$2" "${3:-}" ;;
  check-land) [ $# -eq 3 ] || die "usage: branch.sh check-land <bundle-reference> <integration-target>"; check_land "$2" "$3" ;;
  *) die "usage: branch.sh cut|claim|complete|abandon|check-land ..." ;;
esac
