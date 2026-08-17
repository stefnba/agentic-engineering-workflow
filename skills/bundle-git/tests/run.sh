#!/usr/bin/env bash
# Test the bundle-git scripts against a real git remote.
#
# No network and nothing touched outside a temp dir: a local `git daemon` serves the smart protocol
# (the same family GitHub serves over HTTPS), and `gh` is stubbed by a file listing merged PRs.
#
#   usage: tests/run.sh          exits non-zero if any check fails
set -uo pipefail

scripts="$(cd "$(dirname "$0")/../scripts" && pwd)"
pass=0
fail=0

ok() {
  if [ "$2" = "$3" ]; then
    pass=$((pass + 1)); printf '  PASS %s\n' "$1"
  else
    fail=$((fail + 1)); printf '  FAIL %s (got "%s" want "%s")\n' "$1" "$2" "$3"
  fi
}

command -v git >/dev/null || { echo "git required" >&2; exit 2; }
git daemon --help >/dev/null 2>&1 || { echo "git daemon required" >&2; exit 2; }

root=$(mktemp -d)
port=$((20000 + RANDOM % 20000))
trap 'kill "$(cat "$root/daemon.pid" 2>/dev/null)" 2>/dev/null; rm -rf "$root"' EXIT

export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@local
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@local
export MERGED="$root/merged" # "<branch> <base>" per line: the pull requests the stub reports merged
: > "$MERGED"

# gh stub: answers the two queries the scripts make, from $MERGED.
mkdir -p "$root/bin"
cat > "$root/bin/gh" <<'STUB'
#!/usr/bin/env bash
args="$*"
case "$args" in
  "pr list"*)
    head=""; prev=""
    for a in "$@"; do [ "$prev" = "--head" ] && head="$a"; prev="$a"; done
    base=$(sed -n 's/.*baseRefName=="\([^"]*\)".*/\1/p' <<<"$args")
    [ -f "$MERGED" ] || exit 0
    awk -v h="$head" -v b="$base" '$1==h && $2==b {print NR}' "$MERGED"
    ;;
  "pr view"*) echo "${GH_STUB_BRANCH:-ticket/x/01}" ;;
  "pr merge"*) echo "$args" > "$GH_STUB_LOG" ;;
  *) exit 1 ;;
esac
STUB
chmod +x "$root/bin/gh"
export PATH="$root/bin:$PATH"

git init -q --bare -b main "$root/remote.git"
touch "$root/remote.git/git-daemon-export-ok"
git daemon --port="$port" --base-path="$root" --export-all --enable=receive-pack \
  --reuseaddr --detach --pid-file="$root/daemon.pid" "$root" 2>/dev/null
for _ in $(seq 30); do (echo > "/dev/tcp/127.0.0.1/$port") 2>/dev/null && break; sleep 0.1; done

url="git://127.0.0.1:$port/remote.git"
git clone -q "$url" "$root/repo" 2>/dev/null
cd "$root/repo" || exit 2

multi=2026-08-17-invites
solo=2026-08-17-typo
mkdir -p "work/bundles/$multi/tickets" "work/bundles/$solo"
printf 'depends_on: []\n---\npersistence\n'   > "work/bundles/$multi/tickets/01-persistence.md"
printf 'depends_on: [01]\n---\napi\n'         > "work/bundles/$multi/tickets/02-api.md"
printf 'depends_on: []\n---\nui\n'            > "work/bundles/$multi/tickets/03-ui.md"
printf 'depends_on: []\n---\nfix the typo\n'  > "work/bundles/$solo/ticket.md"
git add -A && git commit -qm "docs(bundle): publish test bundles" && git push -q origin main

echo "== derived status before any claim"
ok "unclaimed ticket is todo"       "$("$scripts/ticket-status.sh" "$multi" 01)" todo
ok "unclaimed bundle is shaped"     "$("$scripts/bundle-status.sh" "$multi" | head -1 | awk '{print $1}')" shaped

echo "== claiming"
"$scripts/claim-ticket.sh" "$multi" 01 >/dev/null 2>&1
ok "claim exits 0"                  "$?" 0
ok "worktree exists"                "$([ -d ".claude/worktrees/ticket/$multi/01" ] && echo yes)" yes
ok "bundle branch created"          "$(git ls-remote --heads origin "bundle/$multi" | wc -l | tr -d ' ')" 1
ok "claimed ticket is doing"        "$("$scripts/ticket-status.sh" "$multi" 01)" doing
ok "bundle is now active"           "$("$scripts/bundle-status.sh" "$multi" | head -1 | awk '{print $1}')" active

echo "== a second claim never wins"
"$scripts/claim-ticket.sh" "$multi" 01 >/dev/null 2>&1
ok "stale worktree refuses (5)"     "$?" 5
rm -rf ".claude/worktrees/ticket/$multi/01" && git worktree prune
"$scripts/claim-ticket.sh" "$multi" 01 >/dev/null 2>&1
ok "already claimed refuses (4)"    "$?" 4

echo "== dependency gate"
"$scripts/claim-ticket.sh" "$multi" 02 >/dev/null 2>&1
ok "unmet dependency blocks (3)"    "$?" 3
"$scripts/claim-ticket.sh" "$multi" 99 >/dev/null 2>&1
ok "unknown ticket refuses (2)"     "$?" 2
echo "ticket/$multi/01 bundle/$multi" > "$MERGED"
ok "merged PR reads as done"        "$("$scripts/ticket-status.sh" "$multi" 01)" done
"$scripts/claim-ticket.sh" "$multi" 02 >/dev/null 2>&1
ok "met dependency allows claim"    "$?" 0

echo "== single-ticket bundle takes no bundle branch"
"$scripts/claim-ticket.sh" "$solo" 01 >/dev/null 2>&1
ok "solo claim exits 0"             "$?" 0
ok "no bundle branch"               "$(git ls-remote --heads origin "bundle/$solo" | wc -l | tr -d ' ')" 0

echo "== listing"
ok "lists every bundle"             "$("$scripts/bundle-status.sh" | wc -l | tr -d ' ')" 2
ok "per-ticket listing"             "$("$scripts/bundle-status.sh" "$multi" | tr -s ' ' | tr '\n' '|')" \
                                    "active $multi| done 01-persistence| doing 02-api| todo 03-ui|"

echo "== an unreachable forge never reads as todo"
mv "$root/bin/gh" "$root/bin/gh.real"
printf '#!/usr/bin/env bash\nexit 1\n' > "$root/bin/gh" && chmod +x "$root/bin/gh"
"$scripts/ticket-status.sh" "$multi" 01 >/dev/null 2>&1
ok "ticket status exits non-zero"   "$?" 1
ok "bundle status says unknown"     "$("$scripts/bundle-status.sh" "$multi" 2>/dev/null | head -1 | awk '{print $1}')" unknown
mv -f "$root/bin/gh.real" "$root/bin/gh"

echo "== concurrent claims on one ticket"
git push -q origin --delete "ticket/$multi/03" 2>/dev/null
for i in $(seq 10); do
  (
    git clone -q "$url" "$root/racer$i" 2>/dev/null
    cd "$root/racer$i" || exit
    "$scripts/claim-ticket.sh" "$multi" 03 > "$root/race$i.out" 2>&1
  ) &
done
wait
ok "exactly one claim wins"         "$(grep -l '^claimed' "$root"/race*.out 2>/dev/null | wc -l | tr -d ' ')" 1
ok "every other claim is told so"   "$(grep -l 'already claimed' "$root"/race*.out 2>/dev/null | wc -l | tr -d ' ')" 9
ok "one ticket ref on the remote"   "$(git ls-remote --heads origin "ticket/$multi/03" | wc -l | tr -d ' ')" 1

echo "== merging an accepted PR"
export GH_STUB_LOG="$root/merge.log" GH_STUB_BRANCH="ticket/$multi/01"
"$scripts/complete-ticket.sh" 42 deadbeef >/dev/null 2>&1
ok "squash merge requested"         "$(grep -c -- '--squash' "$root/merge.log")" 1
ok "head branch deleted"            "$(grep -c -- '--delete-branch' "$root/merge.log")" 1
ok "accepted sha is enforced"       "$(grep -c -- '--match-head-commit deadbeef' "$root/merge.log")" 1

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
