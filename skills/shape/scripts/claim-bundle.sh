#!/bin/bash
# Allocates the next work-item id and creates its bundle directory under
# work/candidates/. Split out from spec/ticket authoring on purpose: this is
# the one contested, multi-agent-racy step (read next-id, increment, commit,
# push, retry on conflict) — small and fast, so the collision window stays
# short regardless of how long the spec that follows takes to write.
set -euo pipefail

TITLE="${1:?usage: claim-bundle.sh "<title>"}"

slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g'
}

SLUG=$(slugify "$TITLE")
if [[ -z "$SLUG" ]]; then
  echo "claim-bundle: title slugified to nothing: '$TITLE'" >&2
  exit 1
fi

MAX_ATTEMPTS=5
for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
  ID=$(cat work/next-id)
  # 10# forces base-10 so leading zeros (0008, 0009) don't get read as octal.
  NEXT=$(printf '%04d' $((10#$ID + 1)))
  echo "$NEXT" >work/next-id
  git add work/next-id
  git commit -m "claim $ID-$SLUG" >/dev/null

  if git push >/dev/null 2>&1; then
    BUNDLE="work/candidates/${ID}-${SLUG}"
    mkdir -p "$BUNDLE"
    echo "id: $ID"
    echo "bundle: $BUNDLE"
    exit 0
  fi

  # Someone else claimed first: undo our own just-made commit (not anyone
  # else's work — nothing but work/next-id was touched) and retry.
  git reset --hard HEAD~1 >/dev/null
  git pull >/dev/null
done

echo "claim-bundle: gave up after $MAX_ATTEMPTS attempts — repeated push conflicts on work/next-id" >&2
exit 1
