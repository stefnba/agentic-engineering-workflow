# Shared settings for the bundle scripts. Sourced, not executed; run from the repository root.
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

# squash and merge record one merge commit per PR, which is what the land gate matches first-parent
# commits against. A rebase merge records only the tip of the commits it adds, so the rest would
# read as unrecorded and no bundle could ever land. Refuse here, at read time — not at land time,
# with the bundle already done.
case "$TICKET_MERGE_METHOD" in
  squash | merge) ;;
  *)
    echo "TICKET_MERGE_METHOD=$TICKET_MERGE_METHOD: use squash or merge — rebase records only its tip commit, which the land gate cannot match to the rest" >&2
    exit 1
    ;;
esac

ticket_branch() { echo "ticket/$1/$2"; } # <bundle-id> <NN>
bundle_branch() { echo "bundle/$1"; }    # <bundle-id>

# The tickets a bundle has, as "NN name" per line. One definition because status, the claim gate and
# the land gate must iterate the same set.
ticket_names() { # <bundle-id>
  local f name
  if [ -f "work/bundles/$1/ticket.md" ]; then
    echo "01 ticket"
    return
  fi
  for f in "work/bundles/$1/tickets/"[0-9][0-9]-*.md; do
    [ -f "$f" ] || continue
    name=$(basename "$f" .md)
    echo "${name%%-*} $name"
  done
}

# One ticket's file, resolved through ticket_names so a ticket is claimable exactly when the
# status listing and the land gate can see it. An NN the listing does not print — unpadded, a
# slug, a wrong number on a single-ticket bundle — resolves to nothing here instead of matching
# a file no derived status would ever cover.
ticket_file() { # <bundle-id> <NN> -> the ticket's path, or nothing when there is no such ticket
  local nn name
  while read -r nn name; do
    if [ "$nn" = "$2" ]; then
      if [ "$name" = ticket ]; then
        echo "work/bundles/$1/ticket.md"
      else
        echo "work/bundles/$1/tickets/$name.md"
      fi
      return 0
    fi
  done <<<"$(ticket_names "$1")"
  return 0
}

# Every bundle's ticket PRs target its bundle branch, whatever the ticket count. Uniform, so
# nothing is derived and nothing can flip: no ticket PR targets the integration target —
# implementation content reaches it only through the land. Kept as a function because claim,
# status and links must share one definition of the base.
ticket_base() { bundle_branch "$1"; } # <bundle-id> -> the branch this bundle's ticket PRs target
