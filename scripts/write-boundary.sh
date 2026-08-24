#!/bin/bash
# PreToolUse hook shared by every skill with a write boundary: Edit/Write may only touch the
# allowed paths. The skill's hooks frontmatter passes the boundary in; the path handling lives
# here once, so no per-skill copy can drift on it.
#
#   usage: write-boundary.sh --reason <text> [--lift-when-clean <path>] <allowed-glob>...
#
#   --reason           the denial message; the denied path is appended
#   --lift-when-clean  stop denying while `git status` reports nothing under this path — for a
#                      fence that must not outlive its skill (workflow/components.md, Permissions)
#   <allowed-glob>     bash patterns matched against the project-relative path
#
# It binds Edit and Write only. A shell can still write, so this closes the common path, not every
# path — the same gap workflow/lifecycle.md records for the Critic and Reviewer.
set -euo pipefail

reason="" lift=""
while [ $# -gt 0 ]; do
  case "$1" in
  --reason) reason="$2"; shift 2 ;;
  --lift-when-clean) lift="$2"; shift 2 ;;
  *) break ;;
  esac
done

INPUT=$(cat)
FILE_PATH=$(jq -r '.tool_input.file_path // empty' <<<"$INPUT")

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# A relative path is inside the project — the tools resolve it against the project dir — so it is
# checked as-is. An absolute path outside the project is none of the boundary's business: it
# guards the repo, not the machine.
REL_PATH="$FILE_PATH"
if [[ "$FILE_PATH" == /* ]]; then
  if [[ -n "${CLAUDE_PROJECT_DIR:-}" && "$FILE_PATH" == "$CLAUDE_PROJECT_DIR"/* ]]; then
    REL_PATH="${FILE_PATH#"$CLAUDE_PROJECT_DIR"/}"
  else
    exit 0
  fi
fi

for pattern in "$@"; do
  # shellcheck disable=SC2053  # unquoted on purpose: the argument is a pattern
  if [[ "$REL_PATH" == $pattern ]]; then
    exit 0
  fi
done

# A skill's hooks persist for the rest of the session, so a fence scoped to work in flight lifts
# itself: nothing uncommitted under the named path means the skill is not mid-work.
if [[ -n "$lift" ]] &&
  [[ -z "$(git -C "${CLAUDE_PROJECT_DIR:-.}" status --porcelain -- "$lift" 2>/dev/null)" ]]; then
  exit 0
fi

jq -n --arg reason "$reason — denied: $REL_PATH" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }
}'
exit 0
