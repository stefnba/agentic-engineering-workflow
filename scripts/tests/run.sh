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
"$scripts/complete-ticket.sh" 43 >/dev/null 2>&1
ok "merge honours TICKET_MERGE_METHOD" "$(grep -c -- '--merge' "$root/merge2.log")" 1
ok "no --squash when overridden"    "$(grep -c -- '--squash' "$root/merge2.log")" 0

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
"$scripts/complete-ticket.sh" 44 > "$root/stale.out" 2>&1
ok "stale branch refuses (2)"        "$?" 2
ok "and no merge was requested"      "$([ -f "$root/stale.log" ] && echo yes || echo no)" no
ok "and it names the cure"           "$(grep -c 're-verify, re-Accept' "$root/stale.out")" 1

echo "== merging the base in makes it mergeable again"
wt=".claude/worktrees/ticket/$multi/01"
[ -d "$wt" ] || git worktree add -q "$wt" "ticket/$multi/01"
( cd "$wt" && git merge -q --no-ff -m "chore: merge the base in" "origin/bundle/$multi" &&
  git push -q origin "HEAD:ticket/$multi/01" )
git fetch -q origin
"$scripts/complete-ticket.sh" 44 >/dev/null 2>&1
ok "current branch merges (0)"       "$?" 0

echo "== an unreadable PR record is unknown, not stale"
mv "$root/bin/gh" "$root/bin/gh.real"
printf '#!/usr/bin/env bash\nexit 1\n' > "$root/bin/gh" && chmod +x "$root/bin/gh"
"$scripts/complete-ticket.sh" 44 > "$root/nopr.out" 2>&1
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

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
