#!/bin/bash
# PreToolUse hook for the shape skill: Edit/Write may only touch the work
# bundle tree (work/candidates/, work/planned/). Everything else —
# source code above all — is denied. This is the mechanical form of "shape
# is read-only on code."
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(jq -r '.tool_input.file_path // empty' <<<"$INPUT")

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

REL_PATH="$FILE_PATH"
if [[ -n "${CLAUDE_PROJECT_DIR:-}" && "$FILE_PATH" == "$CLAUDE_PROJECT_DIR"/* ]]; then
  REL_PATH="${FILE_PATH#"$CLAUDE_PROJECT_DIR"/}"
fi

if [[ "$REL_PATH" == work/candidates/* || "$REL_PATH" == work/planned/* ]]; then
  exit 0
fi

jq -n --arg reason "shape writes only inside work/candidates/ or work/planned/ — denied: $REL_PATH" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }
}'
exit 0
