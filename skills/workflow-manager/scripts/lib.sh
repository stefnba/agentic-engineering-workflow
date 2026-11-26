# Shared by bundles.sh and branch.sh; sourced, never executed. Sourcing resolves the checkout root,
# reads the worktree directory from docs/conventions/git.md, and lists and fetches the workflow refs.
# Exits 1 outside a git work tree. Every value a status needs comes from the remote's branches and the
# forge's PR records; nothing is stored. The integration target is never read here: the commands that
# need it, cut and check-land, take it as an argument from the agent, which reads it from AGENTS.md.

root=$(git rev-parse --show-toplevel 2>/dev/null) ||
  { echo "not inside a git work tree" >&2; exit 1; }
cd "$root"

# The Worktrees section's "Worktree directory" line names the in-repo directory the listing must not
# descend into. Absent, only .claude/worktrees is skipped, with a warning; status does not need it.
wt=$(awk '/^## Worktrees[[:space:]]*$/ {inside=1; next}
          inside && /^#/ {inside=0}
          inside' docs/conventions/git.md 2>/dev/null |
  sed -n 's/^- \(\*\*\)\{0,1\}Worktree directory\(\*\*\)\{0,1\}: `\([^`]*\)`.*/\3/p' | head -1)
wt="${wt#./}"; wt="${wt%/}"

# Status reads the remote's branch list with ls-remote, which writes nothing under .git, so it works
# in sandboxes that keep .git read-only; its success is what makes the remote known. The fetch after
# it is best effort: it refreshes the origin/* refs branch.sh reads, and fails harmlessly read-only.
remote_ok=y
remote_refs=$(git ls-remote --heads origin 'refs/heads/bundle/*' 'refs/heads/ticket/*' 2>/dev/null) || remote_ok=""
remote_refs=$(sed -n 's#^[0-9a-f]*[[:space:]]refs/heads/#origin/#p' <<<"$remote_refs")
git fetch -q --prune origin '+refs/heads/bundle/*:refs/remotes/origin/bundle/*' \
                           '+refs/heads/ticket/*:refs/remotes/origin/ticket/*' 2>/dev/null || true

remote_has() { # <branch> -> 0 exists, 1 absent, 2 unknown; exact name, never a substring
  [ -n "$remote_ok" ] || return 2
  grep -Fxq "origin/$1" <<<"$remote_refs"
}

merged_pr() { # <head> [<base>] -> 0 a merged PR exists, 1 none, 2 forge unreachable
  local out
  out=$(gh pr list --head "$1" ${2:+--base "$2"} --state merged --json number -q '.[].number' 2>/dev/null) || return 2
  [ -n "$out" ]
}

# Landed is a merged PR from the bundle branch into any base: only Land opens a PR from it, and
# keying on the head keeps a landed bundle landed when its scope's integration target later changes.
bundle_status() { # <ref>
  local rc
  [ -n "$remote_ok" ] || { echo unknown; return; }
  merged_pr "bundle/$1"; rc=$?
  [ "$rc" -eq 0 ] && { echo landed; return; }
  [ "$rc" -eq 2 ] && { echo unknown; return; }
  remote_has "bundle/$1"; rc=$?
  case "$rc" in 0) echo active ;; 1) echo draft ;; *) echo unknown ;; esac
}

ticket_status() { # <ref> <NN>
  local rc
  merged_pr "ticket/$1/$2" "bundle/$1"; rc=$?
  [ "$rc" -eq 0 ] && { echo done; return; }
  [ "$rc" -eq 2 ] && { echo unknown; return; }
  remote_has "ticket/$1/$2"; rc=$?
  case "$rc" in 0) echo doing ;; 1) echo todo ;; *) echo unknown ;; esac
}

# The ticket-naming rule, applied to the bundle folder's file paths on stdin, from whichever source
# listed them: a lone ticket.md is "01 ticket"; otherwise each tickets/NN-*.md is "NN name".
ticket_names() { # <bundle dir>, file paths on stdin -> "NN name" per line
  local paths f name
  paths=$(sort)
  grep -Fxq "$1/ticket.md" <<<"$paths" && { echo "01 ticket"; return 0; }
  grep "^$1/tickets/[0-9][0-9]-[^/]*\.md\$" <<<"$paths" |
    while read -r f; do name=$(basename "$f" .md); echo "${name%%-*} $name"; done
  return 0
}

# A work folder is a work/ directory with bundles/ in it, at any depth outside dependency and
# tool directories. Existence is the signal; no list is consulted.
work_folders() {
  local pp=(-path ./.claude/worktrees)
  [ -n "$wt" ] && pp+=(-o -path "./$wt")
  find . \( -name .git -o -name node_modules -o -name .venv -o -name target -o -name dist -o -name build \
            -o "${pp[@]}" \) -prune \
       -o -type d -path '*/work/bundles' -print 2>/dev/null | sed 's#^\./##; s#/bundles$##' | sort
}

merged_commits() { # <base> -> merge or squash commit ids of merged PRs into <base>, one per line; 2 forge unreachable
  gh pr list --base "$1" --state merged --limit 1000 --json mergeCommit -q '.[].mergeCommit.oid' 2>/dev/null ||
    return 2
}

work_dir_of() { # <ref> -> the bundle's work folder relative to the root: work or <member>/work
  local scope="${1%"${1##*/}"}"
  scope="${scope%/}"
  echo "${scope:+$scope/}work"
}

in_worktree() { # 0 when run from a linked worktree, not the main checkout
  [ "$(cd "$(git rev-parse --git-dir)" && pwd -P)" != "$(cd "$(git rev-parse --git-common-dir)" && pwd -P)" ]
}

main_checkout() { # the main checkout's path, from anywhere in the repository
  dirname "$(cd "$(git rev-parse --git-common-dir)" && pwd -P)"
}

# The bundle folder lives on its bundle branch, so ticket files are read from origin/bundle/<ref>,
# not from whatever checkout the caller stands in.
ticket_file() { # <ref> <NN> -> repository path of the ticket file on the bundle branch, or nothing
  local ref="$1" nn="$2" bd f
  bd="$(work_dir_of "$ref")/bundles/${ref##*/}"
  if [ "$nn" = 01 ] && git cat-file -e "origin/bundle/$ref:$bd/ticket.md" 2>/dev/null; then
    echo "$bd/ticket.md"; return
  fi
  f=$(git ls-tree --name-only "origin/bundle/$ref" -- "$bd/tickets/" 2>/dev/null | grep "/$nn-[^/]*\.md\$" | head -1)
  echo "$f"
}

# depends_on is one line, a flow list of unquoted two-digit numbers, in the leading --- block of the
# ticket file, as shape-bundle's ticket template writes it. Prints one number per line; exits 2 naming
# the file for any other shape. A lone ticket.md has no dependencies by construction.
ticket_depends() { # <ref> <path of the ticket file on the bundle branch>
  local line
  case "$2" in */ticket.md) return 0 ;; esac
  line=$(git show "origin/bundle/$1:$2" 2>/dev/null |
    awk 'NR==1 && $0!="---" {exit} NR>1 && $0=="---" {exit} /^depends_on:/ {print; exit}')
  [[ "$line" =~ ^depends_on:\ *\[(([0-9]{2})(\ *,\ *[0-9]{2})*)?\]\ *$ ]] ||
    { echo "malformed depends_on in $2: '$line' — expected one line like 'depends_on: [01, 02]' in the leading --- block" >&2
      return 2; }
  sed -e 's/^depends_on: *\[//' -e 's/\] *$//' <<<"$line" | tr ',' '\n' | tr -d ' ' | grep .
  return 0
}

# A bundle's tickets as "NN name" per line, read from origin/bundle/<ref> when that fetched ref holds
# the bundle folder, else from the folder in this checkout: a draft has no branch yet, and a landed
# bundle's branch is gone. Prints nothing and returns 2 when neither source exists.
bundle_ticket_names() { # <ref>
  local ref="$1" bd
  bd="$(work_dir_of "$ref")/bundles/${ref##*/}"
  if git cat-file -e "origin/bundle/$ref:$bd" 2>/dev/null; then
    git ls-tree -r --name-only "origin/bundle/$ref" -- "$bd" 2>/dev/null | ticket_names "$bd"; return 0
  fi
  [ -d "$bd" ] || return 2
  find "$bd" -type f 2>/dev/null | ticket_names "$bd"
}

# The bundle ids of one work folder: every bundle folder in this checkout plus every bundle branch on
# the remote whose reference sits in that folder. A committed bundle's folder lives only on its branch,
# so the checkout alone would miss every active bundle.
bundle_ids() { # <work folder> <scope: member path or empty>
  local dir
  {
    for dir in "$1"/bundles/*/; do [ -d "$dir" ] && basename "$dir"; done
    sed -n "s#^origin/bundle/${2:+$2/}\([^/]*\)\$#\1#p" <<<"$remote_refs"
  } | sort -u
}
