#!/usr/bin/env bash
# Print the Ticket section of a ticket PR's body: commit permalinks to the approved bundle and to
# this ticket, plus the branch the PR targets. Read-only; runs from the repository root or from a
# ticket worktree, since the implementer calls it from the latter.
#   usage: pr-links.sh <bundle-id> <NN>
#   exit:  2 no such ticket   3 the bundle is not on the integration target   4 forge unreachable
set -euo pipefail

bundle="$1"
nn="$2"
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/_config.sh"

if [ -f "work/bundles/$bundle/ticket.md" ]; then
  ticket="work/bundles/$bundle/ticket.md"
else
  ticket=$(ls "work/bundles/$bundle/tickets/$nn-"*.md 2>/dev/null | head -1 || true)
fi
[ -n "$ticket" ] || { echo "no such ticket: $bundle/$nn" >&2; exit 2; }

git fetch -q origin

# Pin to the commit that last published this bundle on the integration target — the approved state.
# Two things rule out the obvious alternative of pinning to this branch: a ticket branch also holds
# reconcile amendments no human approved, and it is deleted at Land, so nothing on it is reachable
# afterwards. A bundle is committed straight to the integration target, so this commit outlives
# every branch. A repeated Plan gate republishes there too, which is why `-1` is the approved
# version and not the original one.
sha=$(git log -1 --format=%H "origin/$INTEGRATION_TARGET" -- "work/bundles/$bundle") || sha=""
[ -n "$sha" ] ||
  { echo "no commit on $INTEGRATION_TARGET touches work/bundles/$bundle" >&2; exit 3; }

# --json url carries the host, so this works against an enterprise forge and not only github.com.
repo=$(gh repo view --json url -q .url) ||
  { echo "cannot reach the forge to resolve the repository URL" >&2; exit 4; }

# Markdown links, not bare URLs: the body is read rendered, and a 100-character permalink in the
# middle of a line is noise a reader has to skip. The link text carries what identifies the target —
# the bundle ID, and the ticket's path within the bundle.
rel="${ticket#work/bundles/$bundle/}"
printf -- '- Bundle: [`%s`](%s/tree/%s/work/bundles/%s)\n' "$bundle" "$repo" "$sha" "$bundle"
printf -- '- Ticket: `%s` — [`%s`](%s/blob/%s/%s)\n' "$nn" "$rel" "$repo" "$sha" "$ticket"
printf -- '- Base: `%s`\n' "$(ticket_base "$bundle")"
