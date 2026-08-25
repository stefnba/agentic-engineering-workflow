#!/usr/bin/env bash
# Claim one ticket by creating its branch and worktree. A second claim on the same ticket fails.
#   usage: claim-ticket.sh <bundle-id> <NN>
#   exit:  2 no such ticket   3 dependency not done   4 already claimed   5 stale worktree
#          6 malformed depends_on   7 bundle missing from the branch or target
set -euo pipefail

bundle="$1"
nn="$2"
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/_config.sh"
target="$INTEGRATION_TARGET"
branch=$(ticket_branch "$bundle" "$nn")
worktree="$WORKTREE_DIR/$branch"

git fetch -q origin

ticket=$(ticket_file "$bundle" "$nn")
[ -n "$ticket" ] ||
  { echo "no such ticket: $bundle/$nn — NN is the two-digit number bundle-status.sh prints (e.g. 01)" >&2; exit 2; }

# Every bundle shares one bundle branch; the first claim creates it from the integration target.
base=$(ticket_base "$bundle")
git ls-remote --exit-code --heads origin "$base" >/dev/null 2>&1 ||
  git push -q origin "origin/$target:refs/heads/$base" ||
  true # another ticket's claim won the race and created it first
git fetch -q origin "+refs/heads/$base:refs/remotes/origin/$base"

# An existing bundle branch must carry its published bundle. One that lacks work/bundles/<id>/
# predates the publish — a leftover from an earlier run, a reset integration target, or an abandon
# that skipped branch deletion. With no commits of its own it holds no work, so it is recreated
# from the target; with its own commits, recreating would discard merged ticket work, so stop.
if ! git cat-file -e "origin/$base:work/bundles/$bundle" 2>/dev/null; then
  git cat-file -e "origin/$target:work/bundles/$bundle" 2>/dev/null ||
    { echo "bundle $bundle is not published on $target — publish it, then claim" >&2; exit 7; }
  if git merge-base --is-ancestor "origin/$base" "origin/$target"; then
    git push -q origin --force-with-lease="refs/heads/$base:$(git rev-parse "origin/$base")" \
      "origin/$target:refs/heads/$base" ||
      { echo "stale $base moved while being recreated — another session is active; retry" >&2; exit 7; }
    git fetch -q origin "+refs/heads/$base:refs/remotes/origin/$base"
    echo "note: recreated stale $base from $target — it predated the publish and carried no work"
  else
    echo "stale bundle branch $base: it lacks work/bundles/$bundle yet carries commits of its" \
         "own — reconcile by hand or abandon-bundle.sh, then retry" >&2
    exit 7
  fi
fi

# depends_on must be the one safe form the ticket template documents: a flow list of unquoted
# two-digit numbers, nothing after the closing bracket. Every other form — quoted or unpadded
# numbers, a trailing comment, block-sequence style — is unsafe and gets rejected here rather than
# silently mis-parsed (block-sequence style in particular parses as no dependency at all).
depends_line=$(grep -m1 '^depends_on:' "$ticket") || depends_line=""
[[ "$depends_line" =~ ^depends_on:\ *\[([0-9]{2}(\ *,\ *[0-9]{2})*)?\]\ *$ ]] ||
  { echo "malformed depends_on in $ticket: \"$depends_line\" — must be a flow list of unquoted" \
         "two-digit numbers, e.g. depends_on: [01, 02]" >&2
    exit 6; }

# Report the status actually observed. A failed query prints nothing and is unknown, not todo — the
# gate is closed either way, but "couldn't tell" and "not finished yet" need different responses.
# Consume the line just validated, not a fresh scan of the file: a body line that also starts with
# "depends_on:" must not contribute dependencies the gate above never saw.
for dep in $(sed -n 's/^depends_on: *\[\(.*\)\]/\1/p' <<<"$depends_line" | tr -d ' ' | tr ',' '\n'); do
  dep_status=$("$here/ticket-status.sh" "$bundle" "$dep") || dep_status=""
  [ -n "$dep_status" ] || dep_status=unknown
  if [ "$dep_status" != done ]; then
    echo "blocked: ticket $dep is $dep_status — claim only once every dependency is done" >&2
    [ "$dep_status" = unknown ] &&
      echo "unknown: the forge could not be queried — fix that connection; the dependency may already be done" >&2
    exit 3
  fi
done

if [ -e "$worktree" ]; then
  echo "stale worktree at $worktree — an earlier claim left it; have it removed, then retry" >&2
  exit 5
fi

# The porcelain '*' flag means this push created the branch, so the claim is ours. A racer that
# pushed the same commit sees '=' and must stop. Capture the output instead of piping it: under
# pipefail, `grep -q` exits early and SIGPIPEs the push.
result=$(git push --porcelain origin "origin/$base:refs/heads/$branch" 2>&1) ||
  { echo "ticket $bundle/$nn is already claimed — another session owns it; stop" >&2; exit 4; }
grep -q '^\*' <<<"$result" ||
  { echo "ticket $bundle/$nn is already claimed — another session owns it; stop" >&2; exit 4; }

git fetch -q origin "+refs/heads/$branch:refs/remotes/origin/$branch"
git worktree add -q "$worktree" "$branch"
echo "claimed $branch from $base — worktree at $worktree"
