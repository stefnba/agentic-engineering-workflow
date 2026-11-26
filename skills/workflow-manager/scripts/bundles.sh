#!/usr/bin/env bash
# List every work folder and its bundles with a derived status, or one bundle with its tickets.
# Runs from any directory inside the checkout. A bundle counts when its folder is in this checkout or
# its branch is on the remote; tickets are read from origin/bundle/<reference> when that branch exists,
# since a committed bundle's folder lives only there, and from the checkout's folder otherwise.
#   usage: bundles.sh                      every work folder, every bundle
#          bundles.sh <bundle-reference>   one bundle plus each of its tickets
#   exit:  1 outside a git work tree   2 no work folder, no such bundle, or a bundle on the remote whose
#          folder cannot be read here
set -uo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

[ -n "$wt" ] ||
  echo "warning: docs/conventions/git.md has no '## Worktrees' section with a 'Worktree directory' line;" \
       "worktree checkouts under it may be listed twice" >&2

if [ $# -eq 0 ]; then
  found=
  while read -r wf; do
    [ -n "$wf" ] || continue
    found=y
    scope="${wf%work}"; scope="${scope%/}"
    echo "== ${scope:-root} ($wf/)"
    any=
    while read -r id; do
      [ -n "$id" ] || continue
      any=y
      ref="${scope:+$scope/}$id"
      printf '  %-8s %s\n' "$(bundle_status "$ref")" "$ref"
    done <<<"$(bundle_ids "$wf" "$scope")"
    [ -n "$any" ] || echo "  (no bundles)"
  done <<<"$(work_folders)"
  [ -n "$found" ] || { echo "no work folder: no work/bundles/ at the root or in any member — run setup-workflow" >&2; exit 2; }
  exit 0
fi

ref="$1"
case "$ref" in ''|/*|*/|*..*) echo "not a bundle reference: '$ref' — expected <bundle-id> or <member>/<bundle-id>" >&2; exit 2 ;; esac
id="${ref##*/}"
scope="${ref%"$id"}"; scope="${scope%/}"
dir="${scope:+$scope/}work/bundles/$id"
tickets=$(bundle_ticket_names "$ref") || {
  if remote_has "bundle/$ref"; then
    echo "cannot read bundle $ref: bundle/$ref is on the remote, but no fetched origin/bundle/$ref holds $dir/" \
         "and this checkout has none — fetch the branch, or commit the bundle folder on it" >&2
  else
    echo "no such bundle: $ref (no $dir/ on origin/bundle/$ref or in this checkout)" >&2
  fi
  exit 2
}
printf '%-8s %s\n' "$(bundle_status "$ref")" "$ref"
while read -r nn name; do
  [ -n "$nn" ] || continue
  printf '  %-8s %s\n' "$(ticket_status "$ref" "$nn")" "$name"
done <<<"$tickets"
