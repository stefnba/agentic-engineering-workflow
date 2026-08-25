#!/usr/bin/env bash
# Test the bundle scripts against a real git remote.
#
# No network and nothing touched outside a temp dir: a local `git daemon` serves the smart protocol
# (the same family GitHub serves over HTTPS), and `gh` is stubbed by a file listing merged PRs.
#
#   usage: scripts/tests/run.sh  exits non-zero if any check fails
set -uo pipefail

scripts="$(cd "$(dirname "$0")/.." && pwd)"
pass=0
fail=0

ok() {
  if [ "$2" = "$3" ]; then
    pass=$((pass + 1)); printf '  PASS %s\n' "$1"
  else
    fail=$((fail + 1)); printf '  FAIL %s (got "%s" want "%s")\n' "$1" "$2" "$3"
  fi
}

# Later sections push to main from worktrees other than this checkout (land, the "landed" abandon
# simulation), which leaves this checkout's local main behind or diverged. Call before publishing
# another bundle here, or the push is a non-fast-forward — silently, since this file has no `set -e`.
sync_main() {
  git fetch -q origin
  git merge -q -m "test: sync before publishing another bundle" origin/main 2>/dev/null || true
  git push -q origin main
}

command -v git >/dev/null || { echo "git required" >&2; exit 2; }
git daemon --help >/dev/null 2>&1 || { echo "git daemon required" >&2; exit 2; }

root=$(mktemp -d)
port=$((20000 + RANDOM % 20000))
trap 'kill "$(cat "$root/daemon.pid" 2>/dev/null)" 2>/dev/null; rm -rf "$root"' EXIT

export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@local
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@local
export MERGED="$root/merged" # "<branch> <base> [merge-sha]" per line: the PRs the stub reports merged
: > "$MERGED"

# gh stub: answers the queries the scripts make, from $MERGED.
mkdir -p "$root/bin"
cat > "$root/bin/gh" <<'STUB'
#!/usr/bin/env bash
args="$*"
case "$args" in
  "pr list"*)
    if grep -q 'mergeCommitOid' <<<"$args"; then
      base=""; prev=""
      for a in "$@"; do [ "$prev" = "--base" ] && base="$a"; prev="$a"; done
      [ -f "$MERGED" ] || exit 0
      awk -v b="$base" '$2==b && NF>=3 {print $1, $3}' "$MERGED"
      exit 0
    fi
    head=""; prev=""
    for a in "$@"; do [ "$prev" = "--head" ] && head="$a"; prev="$a"; done
    base=$(sed -n 's/.*baseRefName=="\([^"]*\)".*/\1/p' <<<"$args")
    [ -f "$MERGED" ] || exit 0
    awk -v h="$head" -v b="$base" '$1==h && $2==b {print NR}' "$MERGED"
    ;;
  "pr view"*) echo "${GH_STUB_BRANCH:-ticket/x/01} ${GH_STUB_BASE:-main}" ;;
  "repo view"*) echo "https://forge.test/acme/widgets" ;;
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
printf '# Backlog\n\n- [idea] something nobody has picked up\n' > work/backlog.md
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
"$scripts/claim-ticket.sh" "$multi" 02 > "$root/dep.out" 2>&1
ok "unmet dependency blocks (3)"    "$?" 3
ok "names the status it saw"        "$(grep -c 'ticket 01 is doing' "$root/dep.out")" 1
"$scripts/claim-ticket.sh" "$multi" 99 >/dev/null 2>&1
ok "unknown ticket refuses (2)"     "$?" 2
echo "ticket/$multi/01 bundle/$multi" > "$MERGED"
ok "merged PR reads as done"        "$("$scripts/ticket-status.sh" "$multi" 01)" done
"$scripts/claim-ticket.sh" "$multi" 02 >/dev/null 2>&1
ok "met dependency allows claim"    "$?" 0

echo "== a single-ticket bundle gets a bundle branch too"
"$scripts/claim-ticket.sh" "$solo" 01 >/dev/null 2>&1
ok "solo claim exits 0"             "$?" 0
ok "solo bundle branch created"     "$(git ls-remote --heads origin "bundle/$solo" | wc -l | tr -d ' ')" 1
"$scripts/claim-ticket.sh" "$solo" ticket >/dev/null 2>&1
ok "slug instead of NN refuses (2)" "$?" 2
"$scripts/claim-ticket.sh" "$solo" 07 >/dev/null 2>&1
ok "wrong NN on a solo bundle refuses (2)" "$?" 2

echo "== listing"
ok "lists every bundle"             "$("$scripts/bundle-status.sh" | wc -l | tr -d ' ')" 2
ok "per-ticket listing"             "$("$scripts/bundle-status.sh" "$multi" | tr -s ' ' | tr '\n' '|')" \
                                    "active $multi| done 01-persistence| doing 02-api| todo 03-ui|"

echo "== pr links pin to the published bundle, not to the ticket branch"
published=$(git rev-parse origin/main)
( cd ".claude/worktrees/ticket/$multi/02" &&
  printf 'depends_on: [01]\n---\napi, amended while implementing\n' > "work/bundles/$multi/tickets/02-api.md" &&
  git commit -qam "docs(bundle): reconcile the ticket" )
"$scripts/pr-links.sh" "$multi" 02 > "$root/links.out" 2>&1
ok "pr-links exits 0"               "$?" 0
ok "bundle link is a tree permalink" "$(sed -n 1p "$root/links.out")" \
                                    "- Bundle: [\`$multi\`](https://forge.test/acme/widgets/tree/$published/work/bundles/$multi)"
ok "ticket link is a blob permalink" "$(sed -n 2p "$root/links.out")" \
                                    "- Ticket: \`02\` — [\`tickets/02-api.md\`](https://forge.test/acme/widgets/blob/$published/work/bundles/$multi/tickets/02-api.md)"
ok "base is the bundle branch"      "$(sed -n 3p "$root/links.out")" "- Base: \`bundle/$multi\`"
( cd ".claude/worktrees/ticket/$multi/02" && "$scripts/pr-links.sh" "$multi" 02 | sed -n 1p ) \
  > "$root/links-wt.out" 2>&1
ok "same answer from the worktree"  "$(cat "$root/links-wt.out")" "$(sed -n 1p "$root/links.out")"
"$scripts/pr-links.sh" "$solo" 01 | sed -n 2,3p > "$root/links-solo.out" 2>&1
ok "solo bundle links ticket.md"    "$(sed -n 1p "$root/links-solo.out")" \
                                    "- Ticket: \`01\` — [\`ticket.md\`](https://forge.test/acme/widgets/blob/$published/work/bundles/$solo/ticket.md)"
"$scripts/pr-links.sh" "$solo" 07 >/dev/null 2>&1
ok "pr-links wrong solo NN refuses (2)" "$?" 2
ok "and targets its bundle branch"  "$(sed -n 2p "$root/links-solo.out")" "- Base: \`bundle/$solo\`"
"$scripts/pr-links.sh" "$multi" 99 >/dev/null 2>&1
ok "unknown ticket refuses (2)"     "$?" 2
"$scripts/pr-links.sh" 2026-01-01-nope 01 >/dev/null 2>&1
ok "unknown bundle refuses (2)"     "$?" 2
mkdir -p "work/bundles/2026-01-01-local"
printf 'depends_on: []\n---\nnever published\n' > "work/bundles/2026-01-01-local/ticket.md"
"$scripts/pr-links.sh" 2026-01-01-local 01 >/dev/null 2>&1
ok "unpublished bundle refuses (3)" "$?" 3
rm -rf "work/bundles/2026-01-01-local"

echo "== a stray file in tickets/ is not a ticket"
stray=2026-08-17-stray
mkdir -p "work/bundles/$stray/tickets"
printf 'depends_on: []\n---\nthe only ticket\n' > "work/bundles/$stray/tickets/01-only.md"
printf 'scratch\n'                             > "work/bundles/$stray/tickets/notes.txt"
git add -A && git commit -qm "docs(bundle): a bundle with a stray file" && git push -q origin main
"$scripts/claim-ticket.sh" "$stray" 01 >/dev/null 2>&1
ok "stray-file claim exits 0"       "$?" 0
ok "its PRs target the bundle branch" "$(git ls-remote --heads origin "bundle/$stray" | wc -l | tr -d ' ')" 1
printf 'ticket/%s/01 bundle/%s\n' "$stray" "$stray" >> "$MERGED"
ok "status agrees on the base"      "$("$scripts/ticket-status.sh" "$stray" 01)" done
ok "status lists exactly one ticket" "$("$scripts/bundle-status.sh" "$stray" | wc -l | tr -d ' ')" 2

echo "== a ticket file the listing cannot see is not claimable"
pad=2026-08-17-pad
mkdir -p "work/bundles/$pad/tickets"
printf 'depends_on: []\n---\nunpadded\n' > "work/bundles/$pad/tickets/1-unpadded.md"
git add "work/bundles/$pad" && git commit -qm "docs(bundle): publish a mis-named ticket" && git push -q origin main
"$scripts/claim-ticket.sh" "$pad" 1 >/dev/null 2>&1
ok "unpadded NN refuses (2)"        "$?" 2

echo "== a malformed depends_on refuses rather than mis-parses"
bad=2026-08-17-bad-deps
mkdir -p "work/bundles/$bad/tickets"
printf 'depends_on: ["01"]\n---\nquoted\n'        > "work/bundles/$bad/tickets/01-quoted.md"
printf 'depends_on: [1]\n---\nunpadded\n'         > "work/bundles/$bad/tickets/02-unpadded.md"
printf 'depends_on: [01] # x\n---\ncommented\n'   > "work/bundles/$bad/tickets/03-commented.md"
printf 'depends_on:\n  - 01\n---\nblock\n'        > "work/bundles/$bad/tickets/04-block.md"
git add "work/bundles/$bad" && git commit -qm "docs(bundle): publish malformed depends_on" && git push -q origin main
"$scripts/claim-ticket.sh" "$bad" 01 >/dev/null 2>&1
ok "quoted number refuses (6)"      "$?" 6
"$scripts/claim-ticket.sh" "$bad" 02 >/dev/null 2>&1
ok "unpadded number refuses (6)"    "$?" 6
"$scripts/claim-ticket.sh" "$bad" 03 >/dev/null 2>&1
ok "trailing comment refuses (6)"   "$?" 6
"$scripts/claim-ticket.sh" "$bad" 04 >/dev/null 2>&1
ok "block-sequence refuses (6)"     "$?" 6

echo "== a stale bundle branch with no work of its own is recreated"
stale=2026-08-17-stale
git push -q origin "origin/main:refs/heads/bundle/$stale" # leaked before the publish
mkdir -p "work/bundles/$stale"
printf 'depends_on: []\n---\nstale\n' > "work/bundles/$stale/ticket.md"
git add -A && git commit -qm "docs(bundle): publish after the branch leaked" && git push -q origin main
"$scripts/claim-ticket.sh" "$stale" 01 > "$root/stale.out" 2>&1
ok "claim heals and exits 0"        "$?" 0
ok "says it recreated the branch"   "$(grep -c "recreated stale bundle/$stale" "$root/stale.out")" 1
ok "recreated branch carries the bundle" \
   "$(git cat-file -e "origin/bundle/$stale:work/bundles/$stale" 2>/dev/null && echo yes)" yes
ok "worktree carries the ticket"    "$([ -f ".claude/worktrees/ticket/$stale/01/work/bundles/$stale/ticket.md" ] && echo yes)" yes

echo "== a stale bundle branch carrying its own commits refuses"
salvage=2026-08-17-salvage
orphan=$(git commit-tree "origin/main^{tree}" -p "$(git rev-parse origin/main)" -m "orphan ticket work")
git push -q origin "$orphan:refs/heads/bundle/$salvage"
mkdir -p "work/bundles/$salvage"
printf 'depends_on: []\n---\nsalvage\n' > "work/bundles/$salvage/ticket.md"
git add -A && git commit -qm "docs(bundle): publish beside an orphaned branch" && git push -q origin main
"$scripts/claim-ticket.sh" "$salvage" 01 >/dev/null 2>&1
ok "own commits refuse (7)"         "$?" 7
ok "the branch is left untouched"   "$(git ls-remote origin "refs/heads/bundle/$salvage" | awk '{print $1}')" "$orphan"

echo "== a bundle not published on the target is not claimable"
unpub=2026-08-17-unpub
mkdir -p "work/bundles/$unpub"
printf 'depends_on: []\n---\nunpublished\n' > "work/bundles/$unpub/ticket.md" # local only, no push
"$scripts/claim-ticket.sh" "$unpub" 01 >/dev/null 2>&1
ok "unpublished bundle refuses (7)" "$?" 7
rm -rf "work/bundles/$unpub"
git push -q origin ":refs/heads/bundle/$unpub" 2>/dev/null # the ensure step created it before the refusal

echo "== an unreachable forge never reads as todo"
mv "$root/bin/gh" "$root/bin/gh.real"
printf '#!/usr/bin/env bash\nexit 1\n' > "$root/bin/gh" && chmod +x "$root/bin/gh"
"$scripts/ticket-status.sh" "$multi" 01 >/dev/null 2>&1
ok "ticket status exits non-zero"   "$?" 1
ok "bundle status says unknown"     "$("$scripts/bundle-status.sh" "$multi" 2>/dev/null | head -1 | awk '{print $1}')" unknown
"$scripts/claim-ticket.sh" "$multi" 02 > "$root/unknown.out" 2>&1
ok "unqueryable dependency blocks"  "$?" 3
ok "and says unknown, not todo"     "$(grep -c 'ticket 01 is unknown' "$root/unknown.out")" 1
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
export GH_STUB_LOG="$root/merge.log" GH_STUB_BRANCH="ticket/$multi/01" GH_STUB_BASE="bundle/$multi"
"$scripts/complete-ticket.sh" 42 deadbeef >/dev/null 2>&1
ok "squash merge requested"         "$(grep -c -- '--squash' "$root/merge.log")" 1
ok "head branch deleted"            "$(grep -c -- '--delete-branch' "$root/merge.log")" 1
ok "accepted sha is enforced"       "$(grep -c -- '--match-head-commit deadbeef' "$root/merge.log")" 1
ok "scaffolding stays while siblings live" "$([ -d ".claude/worktrees/ticket/$multi" ] && echo yes)" yes
"$scripts/complete-ticket.sh" 42 >/dev/null 2>&1
ok "missing accepted sha refuses (64)" "$?" 64

echo "== completing from inside the worktree it removes"
inw=2026-08-17-inside
mkdir -p "work/bundles/$inw"
printf 'depends_on: []\n---\ninside\n' > "work/bundles/$inw/ticket.md"
git add "work/bundles/$inw" && git commit -qm "docs(bundle): publish inside probe" && git push -q origin main
"$scripts/claim-ticket.sh" "$inw" 01 >/dev/null 2>&1
export GH_STUB_LOG="$root/merge-inside.log" GH_STUB_BRANCH="ticket/$inw/01" GH_STUB_BASE="bundle/$inw"
( cd ".claude/worktrees/ticket/$inw/01" && "$scripts/complete-ticket.sh" 45 f00dcafe ) > "$root/inside.out" 2>&1
ok "completes from inside (0)"      "$?" 0
ok "worktree removed"               "$([ ! -e ".claude/worktrees/ticket/$inw/01" ] && echo yes)" yes
ok "warns about the lost cwd"       "$(grep -c 'removed with the worktree' "$root/inside.out")" 1

echo "== work/config.conf overrides the defaults"
cfg=2026-08-17-config
mkdir -p "work/bundles/$cfg"
printf 'depends_on: []\n---\nconfig probe\n' > "work/bundles/$cfg/ticket.md"
git add "work/bundles/$cfg" && git commit -qm "docs(bundle): publish config probe" && git push -q origin main
# Written the way the shipped template is: aligned inline comments, not bare KEY=value.
printf 'TICKET_MERGE_METHOD=merge   # ticket PR merge method\nWORKTREE_DIR=.wt            # where worktrees go\n' > work/config.conf
"$scripts/claim-ticket.sh" "$cfg" 01 >/dev/null 2>&1
ok "worktree honours WORKTREE_DIR"  "$([ -d ".wt/ticket/$cfg/01" ] && echo yes)" yes
export GH_STUB_LOG="$root/merge2.log" GH_STUB_BRANCH="ticket/$cfg/01" GH_STUB_BASE="bundle/$cfg"
"$scripts/complete-ticket.sh" 43 cafef00d >/dev/null 2>&1
ok "merge honours TICKET_MERGE_METHOD" "$(grep -c -- '--merge' "$root/merge2.log")" 1
ok "no --squash when overridden"    "$(grep -c -- '--squash' "$root/merge2.log")" 0
ok "empty worktree scaffolding removed" "$([ ! -e .wt ] && echo yes)" yes

echo "== an unsupported merge method stops at config read, not at land"
printf 'TICKET_MERGE_METHOD=rebase\n' > work/config.conf
"$scripts/ticket-status.sh" "$cfg" 01 > "$root/rebasecfg.out" 2>&1
ok "rebase refuses (1)"             "$?" 1
ok "and names the supported set"    "$(grep -c 'use squash or merge' "$root/rebasecfg.out")" 1

echo "== a non-default INTEGRATION_TARGET is what bundle branches are cut from"
tgt=2026-08-17-target
mkdir -p "work/bundles/$tgt"
printf 'depends_on: []\n---\ntarget probe\n' > "work/bundles/$tgt/ticket.md"
git add "work/bundles/$tgt" && git commit -qm "docs(bundle): publish target probe"
git push -q origin main main:refs/heads/dev
printf 'INTEGRATION_TARGET=dev\n' > work/config.conf
# Advance dev past main, so which branch the bundle branch was cut from is observable in its tip.
git worktree add -q --detach "$root/devadv" origin/dev
( cd "$root/devadv" && printf 'dev moved\n' > dev.txt && git add dev.txt &&
  git commit -qm "chore: advance dev" && git push -q origin HEAD:dev )
git worktree remove --force "$root/devadv"
git fetch -q origin
"$scripts/claim-ticket.sh" "$tgt" 01 >/dev/null 2>&1
ok "claim exits 0"                  "$?" 0
ok "bundle branch cut from the target" "$(git ls-remote --heads origin "bundle/$tgt" | cut -f1)" "$(git rev-parse origin/dev)"
echo "ticket/$tgt/01 bundle/$tgt" > "$MERGED"
ok "merged into the bundle branch is done" "$("$scripts/ticket-status.sh" "$tgt" 01)" done
echo "ticket/$tgt/01 main" > "$MERGED"
ok "merged elsewhere is not done"   "$("$scripts/ticket-status.sh" "$tgt" 01)" doing
env=2026-08-17-env
mkdir -p "work/bundles/$env"
printf 'depends_on: []\n---\nenv probe\n' > "work/bundles/$env/ticket.md"
git add "work/bundles/$env" && git commit -qm "docs(bundle): publish env probe"
INTEGRATION_TARGET=main "$scripts/claim-ticket.sh" "$env" 01 >/dev/null 2>&1
ok "environment outranks the file"  "$(git ls-remote --heads origin "bundle/$env" | cut -f1)" "$(git rev-parse origin/main)"

echo "== a malformed config line stops instead of running as a command"
printf 'INTEGRATION_TARGET = dev\n' > work/config.conf
"$scripts/ticket-status.sh" "$tgt" 01 > "$root/badcfg.out" 2>&1
ok "malformed config exits 1"       "$?" 1
ok "malformed config names the line" "$(grep -c 'expected KEY=value' "$root/badcfg.out")" 1
rm -f work/config.conf

echo "== a stale ticket branch is refused, not merged"
git fetch -q origin
git worktree add -q --detach "$root/adv" "origin/bundle/$multi"
( cd "$root/adv" && printf 'landed\n' > sibling.txt && git add sibling.txt &&
  git commit -qm "feat: a sibling ticket landed first" && git push -q origin "HEAD:bundle/$multi" )
git worktree remove --force "$root/adv"
git fetch -q origin
export GH_STUB_LOG="$root/stale.log" GH_STUB_BRANCH="ticket/$multi/01" GH_STUB_BASE="bundle/$multi"
"$scripts/complete-ticket.sh" 44 cafef00d > "$root/stale.out" 2>&1
ok "stale branch refuses (2)"        "$?" 2
ok "and no merge was requested"      "$([ -f "$root/stale.log" ] && echo yes || echo no)" no
ok "and it names the cure"           "$(grep -c 're-verify, re-Accept' "$root/stale.out")" 1

echo "== merging the base in makes it mergeable again"
wt=".claude/worktrees/ticket/$multi/01"
[ -d "$wt" ] || git worktree add -q "$wt" "ticket/$multi/01"
( cd "$wt" && git merge -q --no-ff -m "chore: merge the base in" "origin/bundle/$multi" &&
  git push -q origin "HEAD:ticket/$multi/01" )
git fetch -q origin
"$scripts/complete-ticket.sh" 44 cafef00d >/dev/null 2>&1
ok "current branch merges (0)"       "$?" 0

echo "== an unreadable PR record is unknown, not stale"
mv "$root/bin/gh" "$root/bin/gh.real"
printf '#!/usr/bin/env bash\nexit 1\n' > "$root/bin/gh" && chmod +x "$root/bin/gh"
"$scripts/complete-ticket.sh" 44 cafef00d > "$root/nopr.out" 2>&1
ok "unreadable PR exits 1"           "$?" 1
ok "and does not claim staleness"    "$(grep -c 'unknown base' "$root/nopr.out")" 1
mv -f "$root/bin/gh.real" "$root/bin/gh"

echo "== land: the gate refuses an unfinished bundle"
printf 'ticket/%s/01 bundle/%s\n' "$multi" "$multi" > "$MERGED"
"$scripts/land-bundle.sh" start "$multi" > "$root/land3.out" 2>&1
ok "an unfinished ticket blocks (3)"  "$?" 3
ok "and names which one"              "$(grep -cE 'ticket 0[23] is (todo|doing)' "$root/land3.out")" 1
"$scripts/land-bundle.sh" start "$solo" >/dev/null 2>&1
ok "solo's unfinished ticket blocks (3)" "$?" 3
unclaimed=2026-08-17-unclaimed
mkdir -p "work/bundles/$unclaimed"
printf 'depends_on: []\n---\nnever claimed\n' > "work/bundles/$unclaimed/ticket.md"
"$scripts/land-bundle.sh" start "$unclaimed" >/dev/null 2>&1
ok "never-claimed bundle refuses (4)" "$?" 4
rm -rf "work/bundles/$unclaimed"
"$scripts/land-bundle.sh" start no-such-bundle >/dev/null 2>&1
ok "unknown bundle refuses (2)"       "$?" 2

echo "== land: an unrecorded commit on the bundle branch refuses the land"
# The sibling commit was pushed directly, so no merged PR's record carries its SHA yet.
for nn in 01 02 03; do printf 'ticket/%s/%s bundle/%s\n' "$multi" "$nn" "$multi" >> "$MERGED"; done
"$scripts/land-bundle.sh" start "$multi" > "$root/land8.out" 2>&1
ok "unrecorded commit refuses (8)"    "$?" 8
ok "and names the commit"             "$(grep -c 'unrecorded commit' "$root/land8.out")" 1
ok "and no worktree was opened"       "$([ -d ".claude/worktrees/land/$multi" ] && echo yes || echo no)" no

echo "== land: a merged PR from a non-ticket branch is no license"
# The direct-pushed commit now has a merged PR record — but from a head no ticket owns, so its
# content passed no Accept gate and the land must still refuse it.
printf 'feature/rogue bundle/%s %s\n' "$multi" "$(git rev-parse "origin/bundle/$multi")" >> "$MERGED"
"$scripts/land-bundle.sh" start "$multi" > "$root/land8b.out" 2>&1
ok "non-ticket PR refuses (8)"        "$?" 8
ok "and names the commit"             "$(grep -c 'unrecorded commit' "$root/land8b.out")" 1

echo "== land: start opens a detached worktree with the bundle merged in"
git fetch -q origin
printf 'ticket/%s/01 bundle/%s %s\n' "$multi" "$multi" "$(git rev-parse "origin/bundle/$multi")" > "$MERGED"
for nn in 02 03; do printf 'ticket/%s/%s bundle/%s\n' "$multi" "$nn" "$multi" >> "$MERGED"; done
"$scripts/land-bundle.sh" start "$multi" >/dev/null 2>&1
ok "start exits 0"                    "$?" 0
land=".claude/worktrees/land/$multi"
ok "land worktree exists"             "$([ -d "$land" ] && echo yes)" yes
ok "it is detached, on no branch"     "$(git -C "$land" symbolic-ref -q HEAD || echo detached)" detached
ok "the bundle branch came with it"   "$([ -f "$land/sibling.txt" ] && echo yes)" yes
ok "and it carries the bundle"        "$([ -d "$land/work/bundles/$multi" ] && echo yes)" yes
"$scripts/land-bundle.sh" start "$multi" >/dev/null 2>&1
ok "a second start refuses (5)"       "$?" 5

echo "== land: push re-verifies when the target moved, and unions the backlog"
# Both sides append to work/backlog.md, which is the collision this exists for: Land drains here
# while another session adds a Critic candidate on the target.
( cd "$land" && printf -- '- [followup] drained by the land\n' >> work/backlog.md &&
  git commit -qam "chore(land): drain the leftovers" &&
  git rm -rq "work/bundles/$multi" && git commit -qm "chore(land): delete the bundle" )
git worktree add -q --detach "$root/other" origin/main
( cd "$root/other" && printf -- '- [idea] from another session\n' >> work/backlog.md &&
  git commit -qam "chore(backlog): another session" && git push -q origin HEAD:main )
git worktree remove --force "$root/other"
"$scripts/land-bundle.sh" push "$multi" > "$root/push6.out" 2>&1
ok "a moved target returns 6"         "$?" 6
ok "and says to re-run the checks"    "$(grep -c 're-run the canonical checks' "$root/push6.out")" 1
ok "the backlog conflict resolved"    "$(grep -c 'keeping both sides' "$root/push6.out")" 1
ok "no conflict markers survive"      "$(grep -c '<<<<<<<' "$land/work/backlog.md")" 0
ok "both backlog lines are kept"      "$(grep -c 'drained by the land\|from another session' "$land/work/backlog.md")" 2
ok "nothing is left unmerged"         "$(git -C "$land" diff --name-only --diff-filter=U | wc -l | tr -d ' ')" 0
ok "target not published yet"         "$(git ls-remote origin main | cut -f1)" "$(git rev-parse origin/main)"
"$scripts/land-bundle.sh" push "$multi" >/dev/null 2>&1
ok "push after re-verifying exits 0"  "$?" 0
git fetch -q origin
ok "the bundle is gone from main"     "$(git ls-tree -r --name-only origin/main | grep -c "work/bundles/$multi")" 0
ok "ticket commits survive the land"  "$(git log --oneline origin/main | grep -c 'a sibling ticket landed first')" 1
ok "the land is a first-parent merge" "$(git log --first-parent --oneline origin/main | grep -c "land bundle $multi")" 1

echo "== land: cleanup removes the branches and every worktree"
( cd "$land" && "$scripts/land-bundle.sh" cleanup "$multi" >/dev/null 2>&1 )
ok "cleanup refuses from inside (2)"  "$?" 2
"$scripts/land-bundle.sh" cleanup "$multi" >/dev/null 2>&1
ok "cleanup exits 0"                  "$?" 0
ok "bundle branch deleted"            "$(git ls-remote --heads origin "bundle/$multi" | wc -l | tr -d ' ')" 0
ok "ticket branches deleted"          "$(git ls-remote --heads origin "ticket/$multi/*" | wc -l | tr -d ' ')" 0
ok "land worktree removed"            "$([ -d "$land" ] && echo yes || echo no)" no

echo "== the write boundary denies inside the repo whatever the path form"
# Its own repo, not the fixture one: the fence-lift check reads git status, and the fixture repo's
# cleanliness is other blocks' business.
hookrepo="$root/hookrepo"
git init -q "$hookrepo"
mkdir -p "$hookrepo/work/bundles/x"
printf 'draft\n' > "$hookrepo/work/bundles/x/spec.md" # uncommitted draft: the fence is armed
payload() { jq -n --arg p "$1" '{tool_input:{file_path:$p}}'; }
verdict() { # stdin: the hook's output — empty means allowed
  out=$(cat)
  if [ -z "$out" ]; then echo allow; else jq -r '.hookSpecificOutput.permissionDecision' <<<"$out"; fi
}
fence() {
  CLAUDE_PROJECT_DIR="$hookrepo" "$scripts/write-boundary.sh" \
    --reason "shape writes only inside work/bundles/ (plus work/backlog.md)" \
    --lift-when-clean work/bundles/ 'work/bundles/*' work/backlog.md
}
ok "relative path outside the fence denied" "$(payload "src/app.ts" | fence | verdict)" deny
ok "absolute path outside the fence denied" "$(payload "$hookrepo/src/app.ts" | fence | verdict)" deny
ok "allowed path passes"                    "$(payload "$hookrepo/work/bundles/x/spec.md" | fence | verdict)" allow
ok "a path outside the project passes"      "$(payload "/elsewhere/handoff.md" | fence | verdict)" allow
( cd "$hookrepo" && git add -A && git commit -qm "publish" )
ok "the fence lifts once the tree is clean" "$(payload "src/app.ts" | fence | verdict)" allow
ok "worktree scaffolding removed"     "$([ -d ".claude/worktrees/ticket/$multi" ] && echo yes || echo no)" no

echo "== land: a single-ticket bundle lands through the same worktree"
# Give the bundle branch a real ticket commit, as a merged PR would have, so the land below has to
# perform an actual merge — an ancestor branch would let a skipped merge pass unnoticed.
git worktree add -q --detach "$root/soloadv" "origin/bundle/$solo"
( cd "$root/soloadv" && printf 'fixed\n' > typo.txt && git add typo.txt &&
  git commit -qm "fix: the solo ticket landed on its bundle branch" &&
  git push -q origin "HEAD:bundle/$solo" )
git worktree remove --force "$root/soloadv"
git fetch -q origin
printf 'ticket/%s/01 bundle/%s %s\n' "$solo" "$solo" "$(git rev-parse "origin/bundle/$solo")" > "$MERGED"
"$scripts/land-bundle.sh" start "$solo" >/dev/null 2>&1
ok "solo start exits 0"               "$?" 0
sland=".claude/worktrees/land/$solo"
ok "solo land worktree exists"        "$([ -d "$sland" ] && echo yes)" yes
( cd "$sland" && git rm -rq "work/bundles/$solo" && git commit -qm "chore(land): delete the bundle" )
"$scripts/land-bundle.sh" push "$solo" >/dev/null 2>&1
ok "solo push exits 0"                "$?" 0
git fetch -q origin
ok "solo ticket commit reaches main"  "$(git log --oneline origin/main | grep -c 'the solo ticket landed on its bundle branch')" 1
ok "solo land is a first-parent merge" "$(git log --first-parent --oneline origin/main | grep -c "land bundle $solo")" 1
"$scripts/land-bundle.sh" cleanup "$solo" >/dev/null 2>&1
ok "solo cleanup exits 0"             "$?" 0
git fetch -q --prune origin
ok "solo bundle branch deleted"       "$(git ls-remote --heads origin "bundle/$solo" | wc -l | tr -d ' ')" 0
ok "solo bundle gone from main"       "$(git ls-tree -r --name-only origin/main | grep -c "work/bundles/$solo")" 0
ok "land scaffolding removed"         "$([ -d ".claude/worktrees/land" ] && echo yes || echo no)" no

echo "== cleanup refuses an unlanded bundle branch and keeps live claims"
git worktree add -q --detach "$root/strayadv" "origin/bundle/$stray"
( cd "$root/strayadv" && printf 'unlanded\n' > unlanded.txt && git add unlanded.txt &&
  git commit -qm "feat: accepted but not landed" && git push -q origin "HEAD:bundle/$stray" )
git worktree remove --force "$root/strayadv"
"$scripts/land-bundle.sh" cleanup "$stray" > "$root/cleanup9.out" 2>&1
ok "unlanded bundle branch refuses (9)" "$?" 9
git fetch -q origin
ok "and deletes nothing"              "$(git ls-remote --heads origin "bundle/$stray" "ticket/$stray/01" | wc -l | tr -d ' ')" 2
# Roll the branch back to a landed state (its content is on main), leaving the ticket unmerged.
git push -q --force origin "origin/main:refs/heads/bundle/$stray"
"$scripts/land-bundle.sh" cleanup "$stray" > "$root/cleanup0.out" 2>&1
ok "landed branch cleans up (0)"      "$?" 0
ok "but keeps the in-flight ticket"   "$(git ls-remote --heads origin "ticket/$stray/01" | wc -l | tr -d ' ')" 1
ok "and says it kept it"              "$(grep -c "kept ticket/$stray/01" "$root/cleanup0.out")" 1
ok "while the bundle branch goes"     "$(git ls-remote --heads origin "bundle/$stray" | wc -l | tr -d ' ')" 0

echo "== abandon: discards every ticket branch regardless of status, and the bundle branch"
sync_main
aband=2026-08-17-abandon
mkdir -p "work/bundles/$aband/tickets"
printf 'depends_on: []\n---\nfirst\n'  > "work/bundles/$aband/tickets/01-first.md"
printf 'depends_on: []\n---\nsecond\n' > "work/bundles/$aband/tickets/02-second.md"
git add -A && git commit -qm "docs(bundle): publish abandon probe" && git push -q origin main
"$scripts/claim-ticket.sh" "$aband" 01 >/dev/null 2>&1
"$scripts/claim-ticket.sh" "$aband" 02 >/dev/null 2>&1
echo "ticket/$aband/01 bundle/$aband" > "$MERGED"
ok "one ticket reads done"           "$("$scripts/ticket-status.sh" "$aband" 01)" done
ok "the other is still doing"        "$("$scripts/ticket-status.sh" "$aband" 02)" doing
"$scripts/abandon-bundle.sh" "$aband" >/dev/null 2>&1
ok "abandon exits 0"                 "$?" 0
git fetch -q --prune origin
ok "the done ticket branch is gone"  "$(git ls-remote --heads origin "ticket/$aband/01" | wc -l | tr -d ' ')" 0
ok "the doing ticket branch is gone" "$(git ls-remote --heads origin "ticket/$aband/02" | wc -l | tr -d ' ')" 0
ok "the bundle branch is gone"       "$(git ls-remote --heads origin "bundle/$aband" | wc -l | tr -d ' ')" 0
ok "both worktrees are gone"         "$([ -d ".claude/worktrees/ticket/$aband" ] && echo yes || echo no)" no
: > "$MERGED"

echo "== abandon: refuses a bundle already landed"
sync_main
landedb=2026-08-17-landed-abandon
mkdir -p "work/bundles/$landedb"
printf 'depends_on: []\n---\nalready shipped\n' > "work/bundles/$landedb/ticket.md"
git add -A && git commit -qm "docs(bundle): publish landed-abandon probe" && git push -q origin main
"$scripts/claim-ticket.sh" "$landedb" 01 >/dev/null 2>&1
# Simulate a completed land from elsewhere, in its own worktree, never this checkout — the commit
# message is the signal abandon-bundle.sh actually looks for, not the directory going missing: a
# pre-Plan-gate draft has no directory on the target either, and abandoning that is not "landed".
git worktree add -q --detach "$root/landedadv" origin/main
( cd "$root/landedadv" && git rm -rq "work/bundles/$landedb" &&
  git commit -qm "chore(land): land bundle $landedb" && git push -q origin HEAD:main )
git worktree remove --force "$root/landedadv"
git fetch -q origin
"$scripts/abandon-bundle.sh" "$landedb" > "$root/abandon9.out" 2>&1
ok "landed bundle refuses (9)"        "$?" 9
ok "and points at cleanup"            "$(grep -c 'land-bundle.sh cleanup' "$root/abandon9.out")" 1
ok "nothing was deleted"              "$(git ls-remote --heads origin "bundle/$landedb" "ticket/$landedb/01" | wc -l | tr -d ' ')" 2

echo "== abandon: refuses an unknown bundle"
"$scripts/abandon-bundle.sh" no-such-bundle >/dev/null 2>&1
ok "unknown bundle refuses (2)"       "$?" 2

echo "== abandon: refuses to run from inside a worktree"
sync_main
wtg=2026-08-17-abandon-guard
mkdir -p "work/bundles/$wtg"
printf 'depends_on: []\n---\nguard probe\n' > "work/bundles/$wtg/ticket.md"
git add -A && git commit -qm "docs(bundle): publish guard probe" && git push -q origin main
"$scripts/claim-ticket.sh" "$wtg" 01 >/dev/null 2>&1
( cd ".claude/worktrees/ticket/$wtg/01" && "$scripts/abandon-bundle.sh" "$wtg" ) > "$root/guard.out" 2>&1
ok "refuses from inside a worktree (2)" "$?" 2
ok "names the fix"                    "$(grep -c 'main checkout' "$root/guard.out")" 1
git fetch -q origin
ok "nothing was deleted"              "$(git ls-remote --heads origin "bundle/$wtg" "ticket/$wtg/01" | wc -l | tr -d ' ')" 2

echo "== abandon: a refused delete is reported, not swallowed as success"
sync_main
denyd=2026-08-17-abandon-deny
mkdir -p "work/bundles/$denyd"
printf 'depends_on: []\n---\ndeny probe\n' > "work/bundles/$denyd/ticket.md"
git add -A && git commit -qm "docs(bundle): publish deny probe" && git push -q origin main
"$scripts/claim-ticket.sh" "$denyd" 01 >/dev/null 2>&1
git -C "$root/remote.git" config receive.denyDeletes true
"$scripts/abandon-bundle.sh" "$denyd" > "$root/deny.out" 2>&1
ok "refused delete exits 1"           "$?" 1
ok "names what it could not remove"   "$(grep -c "refused to delete" "$root/deny.out")" 1
git -C "$root/remote.git" config receive.denyDeletes false
git fetch -q origin
ok "the branches survive the refusal" "$(git ls-remote --heads origin "bundle/$denyd" "ticket/$denyd/01" | wc -l | tr -d ' ')" 2
"$scripts/abandon-bundle.sh" "$denyd" >/dev/null 2>&1
ok "retrying after the block succeeds" "$?" 0

echo "== abandon: removes an in-progress land worktree instead of leaving it"
sync_main
lw=2026-08-17-abandon-land
mkdir -p "work/bundles/$lw"
printf 'depends_on: []\n---\nland worktree probe\n' > "work/bundles/$lw/ticket.md"
git add -A && git commit -qm "docs(bundle): publish land-worktree probe" && git push -q origin main
"$scripts/claim-ticket.sh" "$lw" 01 >/dev/null 2>&1
printf 'ticket/%s/01 bundle/%s\n' "$lw" "$lw" >> "$MERGED"
"$scripts/land-bundle.sh" start "$lw" >/dev/null 2>&1
ok "land start exits 0"               "$?" 0
ok "land worktree exists"             "$([ -d ".claude/worktrees/land/$lw" ] && echo yes)" yes
"$scripts/abandon-bundle.sh" "$lw" >/dev/null 2>&1
ok "abandon exits 0"                  "$?" 0
ok "land worktree is gone"            "$([ -d ".claude/worktrees/land/$lw" ] && echo yes || echo no)" no
: > "$MERGED"

echo "== abandon: a bundle id that prefixes another landed one is not read as landed"
sync_main
short=2026-08-17-search
long=2026-08-17-search-ui
mkdir -p "work/bundles/$short" "work/bundles/$long"
printf 'depends_on: []\n---\nshort probe\n' > "work/bundles/$short/ticket.md"
printf 'depends_on: []\n---\nlong probe\n'  > "work/bundles/$long/ticket.md"
git add -A && git commit -qm "docs(bundle): publish prefix-collision probes" && git push -q origin main
"$scripts/claim-ticket.sh" "$short" 01 >/dev/null 2>&1
"$scripts/claim-ticket.sh" "$long" 01 >/dev/null 2>&1
# Land only the longer bundle, from its own worktree, never this checkout — an unanchored grep for
# the shorter id's land message would match inside this one too.
git worktree add -q --detach "$root/prefixadv" origin/main
( cd "$root/prefixadv" && git rm -rq "work/bundles/$long" &&
  git commit -qm "chore(land): land bundle $long" && git push -q origin HEAD:main )
git worktree remove --force "$root/prefixadv"
git fetch -q origin
"$scripts/abandon-bundle.sh" "$short" > "$root/prefix.out" 2>&1
ok "the shorter id is not read as landed" "$?" 0
git fetch -q --prune origin
ok "and its branches are gone"        "$(git ls-remote --heads origin "bundle/$short" "ticket/$short/01" | wc -l | tr -d ' ')" 0

echo "== abandon: a never-published local draft is not read as landed"
draft=2026-08-17-abandon-draft
mkdir -p "work/bundles/$draft"
printf 'depends_on: []\n---\nnever pushed\n' > "work/bundles/$draft/ticket.md"
"$scripts/abandon-bundle.sh" "$draft" > "$root/draft.out" 2>&1
ok "a local-only draft is not landed (0)" "$?" 0
ok "and says nothing about landing"   "$(grep -c 'already landed' "$root/draft.out")" 0
rm -rf "work/bundles/$draft"

echo "== abandon: an unreachable forge is not read as already deleted"
sync_main
netdrop=2026-08-17-abandon-netdrop
mkdir -p "work/bundles/$netdrop"
printf 'depends_on: []\n---\nnetwork drop probe\n' > "work/bundles/$netdrop/ticket.md"
git add -A && git commit -qm "docs(bundle): publish netdrop probe" && git push -q origin main
"$scripts/claim-ticket.sh" "$netdrop" 01 >/dev/null 2>&1
# A shim that fails only a delete or a status query naming this bundle's refs, with a network-style
# error rather than "no such ref" — real git handles everything else, including the land-message
# grep and the fetch above it.
realgit=$(command -v git)
mkdir -p "$root/gitbin"
cat > "$root/gitbin/git" <<STUB
#!/usr/bin/env bash
if { [[ "\$*" == *--delete* ]] || [[ "\$*" == *ls-remote* ]]; } && [[ "\$*" == *"$netdrop"* ]]; then
  echo "fatal: unable to access — simulated network drop" >&2
  exit 128
fi
exec "$realgit" "\$@"
STUB
chmod +x "$root/gitbin/git"
PATH="$root/gitbin:$PATH" "$scripts/abandon-bundle.sh" "$netdrop" > "$root/netdrop.out" 2>&1
ok "an unreachable forge refuses (1)"  "$?" 1
ok "names what it could not resolve"  "$(grep -c 'refused to delete' "$root/netdrop.out")" 1
git fetch -q origin
ok "branches survive the network drop" "$(git ls-remote --heads origin "bundle/$netdrop" "ticket/$netdrop/01" | wc -l | tr -d ' ')" 2

echo "== publish-bundle: detached-worktree publish racing a sibling backlog append"
sync_main
pub=2026-08-17-published
mkdir -p "work/bundles/$pub"
printf 'depends_on: []\n---\nshaped\n' > "work/bundles/$pub/ticket.md"
printf -- '- [idea] shaped alongside\n' >> work/backlog.md
# A sibling session appends to the target's backlog after this session last synced.
git worktree add -q --detach "$root/sib" origin/main
printf -- '- [idea] sibling appended meanwhile\n' >> "$root/sib/work/backlog.md"
git -C "$root/sib" commit -qam "chore(backlog): sibling append" && git -C "$root/sib" push -q origin HEAD:main
git worktree remove --force "$root/sib"
"$scripts/publish-bundle.sh" "$pub" > "$root/publish.out" 2>&1
ok "publish exits 0"                "$?" 0
ok "bundle is on the target"        "$(git cat-file -e "origin/main:work/bundles/$pub/ticket.md" 2>/dev/null && echo yes)" yes
ok "subject is the publish form"    "$(git log -1 --format=%s origin/main)" "bundle: publish $pub"
ok "session backlog line survived"  "$(git show origin/main:work/backlog.md | grep -c 'shaped alongside')" 1
ok "sibling backlog line survived"  "$(git show origin/main:work/backlog.md | grep -c 'sibling appended meanwhile')" 1
ok "behind session self-syncs"      "$(git rev-parse main)" "$(git rev-parse origin/main)"
ok "work/ clean after the sync"     "$(git status --porcelain -- work/ | wc -l | tr -d ' ')" 0
ok "publish worktree removed"       "$([ ! -e ".claude/worktrees/publish" ] && echo yes)" yes

echo "== publish-bundle: a clean session revises and fast-forwards"
git pull -q origin main
printf 'amended\n' >> "work/bundles/$pub/ticket.md"
"$scripts/publish-bundle.sh" "$pub" > "$root/revise.out" 2>&1
ok "revise exits 0"                 "$?" 0
ok "subject is the revise form"     "$(git log -1 --format=%s origin/main)" "bundle: revise $pub"
ok "local main synced"              "$(git rev-parse main)" "$(git rev-parse origin/main)"
ok "work/ is clean afterwards"      "$(git status --porcelain -- work/ | wc -l | tr -d ' ')" 0

echo "== publish-bundle: a bundle moved on the target refuses"
git worktree add -q --detach "$root/sib2" origin/main
printf 'sibling rewrite\n' > "$root/sib2/work/bundles/$pub/ticket.md"
git -C "$root/sib2" commit -qam "bundle: revise $pub" && git -C "$root/sib2" push -q origin HEAD:main
git worktree remove --force "$root/sib2"
printf 'mine too\n' >> "work/bundles/$pub/ticket.md"
"$scripts/publish-bundle.sh" "$pub" >/dev/null 2>&1
ok "moved bundle refuses (3)"       "$?" 3

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
