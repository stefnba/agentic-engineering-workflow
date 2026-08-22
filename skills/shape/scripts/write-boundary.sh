#!/bin/bash
# PreToolUse hook for the shape skill: Edit/Write may only touch the draft bundle tree
# (work/bundles/) plus work/backlog.md — the promoted line is deleted in the same commit that
# publishes the bundle. Everything else, source code above all, is denied. This is the mechanical
# form of the Architect's "write access only to the draft bundle" in workflow/lifecycle.md.
#
# It binds Edit and Write only. A shell can still write, so this closes the common path, not every
# path — the same gap workflow/lifecycle.md records for the Critic and Reviewer.
#
# A skill's hooks persist for the rest of the session (workflow/components.md, Permissions), so the
# fence scopes itself: it denies only while an uncommitted draft exists under work/bundles/. Before
# the draft exists shape writes nothing, and the publish commit leaves that tree clean — at which
# point the fence lifts instead of outliving the skill.
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(jq -r '.tool_input.file_path // empty' <<<"$INPUT")

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# The boundary only restricts writes inside this project — a path outside it (a handoff document
# under ~/.claude, say) is none of shape's business.
if [[ -z "${CLAUDE_PROJECT_DIR:-}" || "$FILE_PATH" != "$CLAUDE_PROJECT_DIR"/* ]]; then
  exit 0
fi

REL_PATH="${FILE_PATH#"$CLAUDE_PROJECT_DIR"/}"

if [[ "$REL_PATH" == work/bundles/* || "$REL_PATH" == work/backlog.md ]]; then
  exit 0
fi

# No uncommitted draft under work/bundles/ means shape is not mid-draft: the fence has lifted.
if [[ -z "$(git -C "$CLAUDE_PROJECT_DIR" status --porcelain -- work/bundles/ 2>/dev/null)" ]]; then
  exit 0
fi

jq -n --arg reason "shape writes only inside work/bundles/ (plus work/backlog.md) — denied: $REL_PATH" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }
}'
exit 0
