# Shared settings for the bundle-git scripts. Sourced, not executed; run from the repository root.
#
# Values a repository may change live in work/config.conf, which setup writes from the plugin's
# skills/setup/templates/config.conf. Branch naming is not among them: status is derived by
# reconstructing these names, so two scripts that disagree would report a claimed ticket as todo and
# let a dependent ticket start early.

# An environment variable outranks the file, so a one-off override needs no edit.
_env_target="${INTEGRATION_TARGET:-}"
_env_merge="${TICKET_MERGE_METHOD:-}"
_env_worktree="${WORKTREE_DIR:-}"

if [ -f work/config.conf ]; then
  # The file is sourced, so a malformed line would run as a command. Reject anything that is not a
  # comment or KEY=value, naming the line, instead of failing later as "command not found".
  if _bad=$(grep -nvE '^[[:space:]]*(#|$|[A-Z_][A-Z0-9_]*=)' work/config.conf); then
    echo "work/config.conf: expected KEY=value with no spaces around '='" >&2
    echo "$_bad" >&2
    exit 1
  fi
  . ./work/config.conf
fi

INTEGRATION_TARGET="${_env_target:-${INTEGRATION_TARGET:-main}}"
TICKET_MERGE_METHOD="${_env_merge:-${TICKET_MERGE_METHOD:-squash}}"
WORKTREE_DIR="${_env_worktree:-${WORKTREE_DIR:-.claude/worktrees}}"
unset _env_target _env_merge _env_worktree _bad

ticket_branch() { echo "ticket/$1/$2"; } # <bundle-id> <NN>
bundle_branch() { echo "bundle/$1"; }    # <bundle-id>
