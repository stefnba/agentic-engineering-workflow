#!/bin/bash
# PreToolUse hook for the shape skill: Edit/Write may only touch the work
# bundle tree (work/shaped/) plus work/backlog.md — the promoted line is
# deleted in the same commit that lands the bundle. Everything else —
# source code above all — is denied. This is the mechanical form of "shape
# is read-only on code."
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(jq -r '.tool_input.file_path // empty' <<<"$INPUT")

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# The boundary only restricts writes inside this project — a path outside it
# (e.g. ~/.claude/handoffs/*.md from the handoff skill) is none of shape's business.
if [[ -z "${CLAUDE_PROJECT_DIR:-}" || "$FILE_PATH" != "$CLAUDE_PROJECT_DIR"/* ]]; then
  exit 0
fi

REL_PATH="${FILE_PATH#"$CLAUDE_PROJECT_DIR"/}"

if [[ "$REL_PATH" == work/shaped/* || "$REL_PATH" == work/backlog.md ]]; then
  exit 0
fi

jq -n --arg reason "shape writes only inside work/shaped/ (plus work/backlog.md) — denied: $REL_PATH" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }
}'
exit 0
