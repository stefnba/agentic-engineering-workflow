#!/usr/bin/env bash
# Show derived status. Every value comes from git refs and the PR record, never from a file.
#   usage: bundle-status.sh              every bundle
#          bundle-status.sh <bundle-id>  one bundle plus each of its tickets
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"

ticket_names() { # <bundle-id> -> "NN name" per line
  if [ -f "work/bundles/$1/ticket.md" ]; then
    echo "01 ticket"
  else
    for f in "work/bundles/$1/tickets/"[0-9][0-9]-*.md; do
      [ -f "$f" ] || continue
      name=$(basename "$f" .md)
      echo "${name%%-*} $name"
    done
  fi
}

bundle_status() { # shaped until a ticket is claimed, then active; unknown if a query failed
  local nn rest st out=shaped
  while read -r nn rest; do
    [ -n "$nn" ] || continue
    st=$("$here/ticket-status.sh" "$1" "$nn") || { echo unknown; return; }
    [ "$st" = todo ] || out=active
  done <<<"$(ticket_names "$1")"
  echo "$out"
}

if [ $# -eq 0 ]; then
  [ -d work/bundles ] || { echo "no work/bundles directory" >&2; exit 2; }
  found=
  for dir in work/bundles/*/; do
    [ -d "$dir" ] || continue
    found=y
    id=$(basename "$dir")
    printf '%-8s %s\n' "$(bundle_status "$id")" "$id"
  done
  [ -n "$found" ] || echo "no bundles"
  exit 0
fi

bundle="$1"
[ -d "work/bundles/$bundle" ] || { echo "no such bundle: $bundle" >&2; exit 2; }
printf '%-8s %s\n' "$(bundle_status "$bundle")" "$bundle"
while read -r nn name; do
  [ -n "$nn" ] || continue
  st=$("$here/ticket-status.sh" "$bundle" "$nn") || st=unknown
  printf '  %-8s %s\n' "$st" "$name"
done <<<"$(ticket_names "$bundle")"
