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

# A multi-ticket bundle shares one bundle branch; a single-ticket bundle's PR targets the
# integration target directly. Defined once for the same reason as the branch names above: claim and
# status must agree, or a claimed ticket reads as todo and unblocks its dependents early.
#
# The remote branch outranks the file count, and has to: the count is a mutable file. A bundle
# revised from two tickets to one would otherwise re-derive `main` as the base, and every ticket
# already merged into `bundle/<id>` would read `todo` — unblocking dependents on work that is done
# and re-targeting the PRs that remain. Once the branch exists it is the answer; the count decides
# only before the first claim, when no PR can be pointing anywhere yet. Count NN-<slug>.md entries
# only — a stray file in tickets/ must not flip the strategy.
ticket_base() { # <bundle-id> -> the branch this bundle's ticket PRs target
  local n=0 f
  if git ls-remote --exit-code --heads origin "$(bundle_branch "$1")" >/dev/null 2>&1; then
    bundle_branch "$1"
    return
  fi
  for f in "work/bundles/$1/tickets/"[0-9][0-9]-*.md; do
    if [ -f "$f" ]; then n=$((n + 1)); fi
  done
  if [ "$n" -gt 1 ]; then bundle_branch "$1"; else echo "$INTEGRATION_TARGET"; fi
}
