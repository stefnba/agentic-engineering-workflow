#!/bin/bash
# PreToolUse hook shared by the research and audit skills: Edit/Write may
# only touch docs/research/ plus work/backlog.md — the researcher gathers
# evidence, it never turns a finding into work. Paths outside the repo are
# left alone: this boundary guards the repo, not the machine (the shape
# hook's blanket denial blocked legitimate out-of-repo writes).
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(jq -r '.tool_input.file_path // empty' <<<"$INPUT")

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

REL_PATH="$FILE_PATH"
if [[ "$FILE_PATH" == /* ]]; then
  if [[ -n "${CLAUDE_PROJECT_DIR:-}" && "$FILE_PATH" == "$CLAUDE_PROJECT_DIR"/* ]]; then
    REL_PATH="${FILE_PATH#"$CLAUDE_PROJECT_DIR"/}"
  else
    exit 0
  fi
fi

if [[ "$REL_PATH" == docs/research/* || "$REL_PATH" == work/backlog.md ]]; then
  exit 0
fi

jq -n --arg reason "the researcher writes only docs/research/ and work/backlog.md — denied: $REL_PATH" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }
}'
exit 0
