#!/usr/bin/env bash
# Test bundles.sh against a local bare remote and a gh stub. No network, nothing outside a temp dir.
#   usage: scripts/tests/run.sh   exits non-zero if any check fails
set -uo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
pass=0; fail=0
ok() { if [ "$2" = "$3" ]; then pass=$((pass+1)); printf '  PASS %s\n' "$1"; else fail=$((fail+1)); printf '  FAIL %s (got "%s" want "%s")\n' "$1" "$2" "$3"; fi; }

root=$(cd "$(mktemp -d)" && pwd -P); trap 'rm -rf "$root"' EXIT
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@local GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@local
export MERGED="$root/merged"; : > "$MERGED"   # "<head> <base>" per line: PRs the stub reports merged
export MERGED_COMMITS="$root/merged-commits"; : > "$MERGED_COMMITS"   # "<base> <sha>" per line: their merge commits
export PRS="$root/prs"; : > "$PRS"   # "<number> <head> <base>" per line: open PRs the stub can view and merge
mkdir -p "$root/bin"
cat > "$root/bin/gh" <<'STUB'
#!/usr/bin/env bash
[ -n "${GH_DOWN:-}" ] && exit 1
head=""; base=""; prev=""
for a in "$@"; do [ "$prev" = "--head" ] && head="$a"; [ "$prev" = "--base" ] && base="$a"; prev="$a"; done
case "$*" in *mergeCommit*) awk -v b="$base" '$1==b {print $2}' "$MERGED_COMMITS"; exit 0 ;; esac
if [ "$1 $2" = "pr view" ]; then awk -v n="$3" '$1==n {print $2" "$3}' "$PRS"; exit 0; fi
if [ "$1 $2" = "pr merge" ]; then # merge only when --match-head-commit is the branch's current head
  read -r h b < <(awk -v n="$3" '$1==n {print $2" "$3}' "$PRS"); want=""; prev=""
  for a in "$@"; do [ "$prev" = "--match-head-commit" ] && want="$a"; prev="$a"; done
  [ "$(git ls-remote origin "refs/heads/$h" | cut -f1)" = "$want" ] || exit 1
  echo "$h $b" >> "$MERGED"; exit 0
fi
awk -v h="$head" -v b="$base" '$1==h && (b=="" || $2==b) {print NR}' "$MERGED"
STUB
chmod +x "$root/bin/gh"; export PATH="$root/bin:$PATH"

git init -q --bare -b main "$root/remote.git"
git clone -q "$root/remote.git" "$root/repo" 2>/dev/null; cd "$root/repo" || exit 2
git commit -q --allow-empty -m init && git push -q origin main

echo "== git.md"
mkdir -p docs/conventions work/bundles
"$here/bundles.sh" >/dev/null 2>&1; ok "no git.md still lists: the target is not read" "$?" 0
printf '## Agentic engineering workflow\n\n- Integration target: `main`\n' > docs/conventions/git.md
ok "missing worktree line warns, exit 0" "$("$here/bundles.sh" 2>&1 >/dev/null | grep -c '^warning'):$?" "1:0"
ok "the warning names the Worktree directory" "$("$here/bundles.sh" 2>&1 >/dev/null | grep -c 'Worktree directory')" 1
printf '## Agentic engineering workflow\n\n- Worktree directory: `.worktrees`\n' > docs/conventions/git.md
ok "a worktree line under the workflow heading warns" "$("$here/bundles.sh" 2>&1 >/dev/null | grep -c 'Worktree directory')" 1
printf '## Other\n\n- Worktree directory: `.worktrees`\n\n## Worktrees\n\nNone.\n' > docs/conventions/git.md
ok "a worktree line under another heading warns" "$("$here/bundles.sh" 2>&1 >/dev/null | grep -c 'Worktree directory')" 1
cat > docs/conventions/git.md <<'MD'
## Worktrees

- **Worktree directory**: `.worktrees`
MD
ok "a bold worktree line is read" "$("$here/bundles.sh" 2>&1 >/dev/null | grep -c '^warning')" 0

echo "== listing"
mkdir -p apps/billing/work/bundles libs/deep/nested/work/bundles apps/nofolder/work
mkdir -p work/bundles/2026-09-01-root/tickets apps/billing/work/bundles/2026-09-02-invoices libs/deep/nested/work/bundles/2026-09-04-deep
printf 'depends_on: []\n' > work/bundles/2026-09-01-root/tickets/01-first.md
printf 'depends_on: [01]\n' > work/bundles/2026-09-01-root/tickets/02-second.md
printf 'depends_on: []\n' > apps/billing/work/bundles/2026-09-02-invoices/ticket.md
printf 'depends_on: []\n' > libs/deep/nested/work/bundles/2026-09-04-deep/ticket.md
printf '# Backlog\n' > apps/nofolder/work/backlog.md
out=$("$here/bundles.sh")
ok "root folder listed"          "$(grep -c '^== root (work/)' <<<"$out")" 1
ok "member folder listed"        "$(grep -c '^== apps/billing (apps/billing/work/)' <<<"$out")" 1
ok "deep member folder listed"   "$(grep -c '^== libs/deep/nested ' <<<"$out")" 1
ok "backlog-only work/ is not a work folder" "$(grep -c 'nofolder' <<<"$out")" 0
ok "no branch is draft"          "$(awk '$2=="2026-09-01-root"{print $1}' <<<"$out")" draft
ok "member ref carries member"   "$(awk '$2=="apps/billing/2026-09-02-invoices"{print $1}' <<<"$out")" draft

echo "== worktree directories are pruned"
mkdir -p .worktrees/bundle/x/work/bundles/y .claude/worktrees/s/work/bundles/z
out=$("$here/bundles.sh")
ok "worktree directory not listed"  "$(grep -c '\.worktrees' <<<"$out")" 0
ok ".claude/worktrees not listed"   "$(grep -c 'claude' <<<"$out")" 0
ok "real folders still listed"      "$(grep -c '^==' <<<"$out")" 3

echo "== one bundle, tickets"
out=$("$here/bundles.sh" 2026-09-01-root)
ok "ticket todo"                 "$(awk '$2=="01-first"{print $1}' <<<"$out")" todo
git push -q origin main:refs/heads/bundle/2026-09-01-root-2
ok "a prefix-matching branch does not count" "$("$here/bundles.sh" 2026-09-01-root | head -1 | awk '{print $1}')" draft
git push -q origin main:refs/heads/bundle/2026-09-01-root
git push -q origin main:refs/heads/ticket/2026-09-01-root/01
out=$("$here/bundles.sh" 2026-09-01-root)
ok "branch on remote is active"  "$(head -1 <<<"$out" | awk '{print $1}')" active
ok "claimed ticket doing"        "$(awk '$2=="01-first"{print $1}' <<<"$out")" doing
echo "ticket/2026-09-01-root/01 bundle/2026-09-01-root" >> "$MERGED"
ok "merged ticket done"          "$("$here/bundles.sh" 2026-09-01-root | awk '$2=="01-first"{print $1}')" done
echo "bundle/2026-09-01-root main" >> "$MERGED"
git push -q origin --delete bundle/2026-09-01-root
ok "merged PR is landed even after the branch is gone" "$("$here/bundles.sh" 2026-09-01-root | head -1 | awk '{print $1}')" landed

ok "landed shows in list-all"    "$("$here/bundles.sh" | awk '$2=="2026-09-01-root"{print $1}')" landed
git push -q origin main:refs/heads/bundle/2026-09-01-elsewhere
echo "bundle/2026-09-01-elsewhere dev" >> "$MERGED"
ok "a bundle PR merged into any base is landed" "$("$here/bundles.sh" | awk '$2=="2026-09-01-elsewhere"{print $1}')" landed
git push -q origin --delete bundle/2026-09-01-elsewhere

echo "== member bundle"
git push -q origin main:refs/heads/bundle/apps/billing/2026-09-02-invoices
ok "member bundle active"        "$("$here/bundles.sh" apps/billing/2026-09-02-invoices | head -1 | awk '{print $1}')" active
ok "single ticket is 01"         "$("$here/bundles.sh" apps/billing/2026-09-02-invoices | awk 'NR==2{print $2}')" ticket
git push -q origin main:refs/heads/x/bundle/apps/billing/2026-09-02-invoices
git push -q origin --delete bundle/apps/billing/2026-09-02-invoices
ok "a suffix-matching branch does not count" "$("$here/bundles.sh" apps/billing/2026-09-02-invoices | head -1 | awk '{print $1}')" draft

echo "== empty fetch is not unknown"
git push -q origin --delete bundle/2026-09-01-root-2 ticket/2026-09-01-root/01
ok "no matching refs is draft, not unknown" "$("$here/bundles.sh" apps/billing/2026-09-02-invoices | head -1 | awk '{print $1}')" draft

echo "== check-land"
B=2026-09-05-land; mkdir -p "work/bundles/$B"
git checkout -q -b "bundle/$B" main
land() { "$here/branch.sh" check-land "$B" main 2>"$root/err" >/dev/null; echo $?; }
printf 'x\n' > "work/bundles/$B/spec.md"; git add "work/bundles/$B"; git commit -q -m "bundle: draft $B"; git push -q origin "bundle/$B"
ok "bundle: commit inside the work folder passes" "$(land)" 0
printf 'y\n' > src.txt; git add src.txt; git commit -q -m "feat: direct on the bundle branch"; git push -q origin "bundle/$B"
ok "a direct feat commit exits 2"  "$(land)" 2
ok "the reason names the commit"   "$(grep -c 'feat: direct' "$root/err")" 1
echo "bundle/$B $(git rev-parse HEAD)" >> "$MERGED_COMMITS"
ok "a merged ticket PR commit passes" "$(land)" 0
printf 'z\n' >> "work/bundles/$B/spec.md"; printf 'z\n' >> src.txt; git add "work/bundles/$B" src.txt
git commit -q -m "bundle: revise $B"; git push -q origin "bundle/$B"
ok "bundle: commit touching source exits 2" "$(land)" 2
ok "forge down exits 2"            "$(GH_DOWN=1 "$here/branch.sh" check-land "$B" main >/dev/null 2>&1; echo $?)" 2
ok "check-land without a target exits 2" "$("$here/branch.sh" check-land "$B" >/dev/null 2>&1; echo $?)" 2
ok "check-land with a target not on the remote exits 2" "$("$here/branch.sh" check-land "$B" nope 2>"$root/err" >/dev/null; echo $?)" 2
ok "the reason names the AGENTS.md line" "$(grep -c 'Integration target line' "$root/err")" 1
git checkout -q main
B2=2026-09-12-sync; mkdir -p "work/bundles/$B2" work/bundles/other
git checkout -q -b "bundle/$B2" main
printf 'x\n' > "work/bundles/$B2/spec.md"; git add "work/bundles/$B2"; git commit -q -m "bundle: draft $B2"
git checkout -q main; printf 'm\n' > moved.txt; git add moved.txt; git commit -q -m "chore: move the target"; git push -q origin main
git checkout -q "bundle/$B2"; git merge -q --no-ff -m "Merge main into bundle" main; git push -q origin "bundle/$B2"
land2() { "$here/branch.sh" check-land "$B2" main 2>"$root/err" >/dev/null; echo $?; }
ok "a merge of the target into the bundle branch passes" "$(land2)" 0
printf 'b\n' > work/backlog.md; printf 'y\n' >> "work/bundles/$B2/spec.md"; git add work/backlog.md "work/bundles/$B2"
git commit -q -m "bundle: retire lines"; git push -q origin "bundle/$B2"
ok "bundle: commit touching backlog.md and the bundle folder passes" "$(land2)" 0
printf 'o\n' > work/bundles/other/spec.md; git add work/bundles/other; git commit -q -m "bundle: stray folder"; git push -q origin "bundle/$B2"
ok "bundle: commit touching another bundle's folder exits 2" "$(land2)" 2
ok "the reason names the commit" "$(grep -c 'bundle: stray folder' "$root/err")" 1
git checkout -q main

echo "== cut"
br="$here/branch.sh"; C=2026-09-06-claim
rc() { "$@" >"$root/out" 2>"$root/err"; echo $?; }
heads() { git ls-remote --heads origin | awk '{print $2}' | grep -Fxc "refs/heads/$1"; }
headsm() { git ls-remote --heads origin | awk '{print $2}' | grep -Fc "$1"; }
ok "cut succeeds"                   "$(rc "$br" cut "$C" main)" 0
ok "cut prints the worktree path"   "$(tail -1 "$root/out")" "$root/repo/.worktrees/bundle/$C"
ok "cut names the target it used"   "$(grep -c "^cut bundle/$C from main\$" "$root/out")" 1
ok "cut created the remote branch"  "$(heads "bundle/$C")" 1
ok "cut created the local branch"   "$(git branch --list "bundle/$C" | wc -l | tr -d ' ')" 1
ok "a second cut exits 2"           "$(rc "$br" cut "$C" main)" 2
git branch "bundle/2026-09-08-stale" main
ok "cut with only a stale local branch exits 2" "$(rc "$br" cut 2026-09-08-stale main)" 2
git branch -q -D "bundle/2026-09-08-stale"
ok "cut of a bad reference exits 2" "$(rc "$br" cut ../x main)" 2
ok "cut without a target exits 2"   "$(rc "$br" cut 2026-09-08-notarget)" 2
ok "cut from a target not on the remote exits 2" "$(rc "$br" cut 2026-09-08-notarget nope)" 2
ok "cut of a remote-tracking name exits 2" "$(rc "$br" cut 2026-09-08-notarget origin/main)" 2
ok "a refused cut created no branch" "$(heads bundle/2026-09-08-notarget)" 0
# A git wrapper that, on the first push, first creates $RACE_REF on the bare remote at $RACE_FROM, as
# another session would between the precondition check and the push.
mkdir -p "$root/racebin"; export REAL_GIT; REAL_GIT=$(command -v git)
cat > "$root/racebin/git" <<'WRAP'
#!/usr/bin/env bash
if [ "${1:-}" = push ] && [ -n "${RACE_REF:-}" ] && [ ! -e "$RACE_FLAG" ]; then
  : > "$RACE_FLAG"
  "$REAL_GIT" --git-dir="$RACE_REMOTE" update-ref "refs/heads/$RACE_REF" "$("$REAL_GIT" --git-dir="$RACE_REMOTE" rev-parse "$RACE_FROM")"
fi
exec "$REAL_GIT" "$@"
WRAP
chmod +x "$root/racebin/git"
race() { # <ref to pre-create> <its source> <command...> -> exit code
  local r="$1" f="$2"; shift 2; rm -f "$root/raced"
  ( export PATH="$root/racebin:$PATH" RACE_REF="$r" RACE_FROM="$f" RACE_FLAG="$root/raced" RACE_REMOTE="$root/remote.git"; rc "$@" )
}
R=2026-09-10-race
ok "cut that loses the race exits 2"     "$(race "bundle/$R" refs/heads/main "$br" cut "$R" main)" 2
ok "the reason names the other session"  "$(grep -c 'another session created bundle/' "$root/err")" 1
ok "a lost cut leaves no local branch"   "$(git branch --list "bundle/$R" | wc -l | tr -d ' ')" 0
git push -q origin --delete "bundle/$R"

echo "== depends_on and claim"
W="$root/repo/.worktrees/bundle/$C"; T="work/bundles/$C/tickets"
mkdir -p "$W/$T"
printf -- '---\ndepends_on: []\n---\n' > "$W/$T/01-first.md"
printf -- '---\ndepends_on: [01]\n---\n' > "$W/$T/02-second.md"
printf -- '---\ndepends_on: [01, 02]\n---\n' > "$W/$T/03-third.md"
printf -- '---\ndepends_on: [1]\n---\n' > "$W/$T/04-bad.md"
printf -- '---\ndepends_on: 01\n---\n' > "$W/$T/05-bad.md"
printf -- '---\nname: x\n---\n' > "$W/$T/06-none.md"
git -C "$W" add . && git -C "$W" commit -q -m "bundle: tickets" && git -C "$W" push -q origin "bundle/$C"

echo "== a committed bundle is read from its branch, not the checkout"
ok "the main checkout holds no folder for it"  "$(test -d "work/bundles/$C" && echo dir || echo none)" none
out=$("$here/bundles.sh")
ok "listing shows it from the remote branch"   "$(awk -v r="$C" '$2==r{print $1}' <<<"$out")" active
ok "it is listed once, under the root folder"  "$(grep -c " $C\$" <<<"$out"):$(awk -v r="$C" '/^==/{s=$2} $2==r{print s}' <<<"$out")" "1:root"
out=$("$here/bundles.sh" "$C")
ok "its tickets come from the branch"          "$(awk '$2=="01-first"{print $1}' <<<"$out")" todo
ok "every ticket file on the branch is listed" "$(grep -c '^  ' <<<"$out")" 6
ok "claim with an unmet dependency exits 2" "$(rc "$br" claim "$C" 02)" 2
ok "the reason names the dependency" "$(grep -c 'dependency 01 is todo' "$root/err")" 1
ok "claim of an unknown ticket exits 2"     "$(rc "$br" claim "$C" 09)" 2
ok "malformed depends_on [1] exits 2"       "$(rc "$br" claim "$C" 04)" 2
ok "malformed depends_on names the file"    "$(grep -c '04-bad.md' "$root/err")" 1
ok "scalar depends_on exits 2"              "$(rc "$br" claim "$C" 05)" 2
ok "missing depends_on exits 2"             "$(rc "$br" claim "$C" 06)" 2
ok "claim with no dependency succeeds"      "$(rc "$br" claim "$C" 01)" 0
ok "claim prints the worktree path"         "$(tail -1 "$root/out")" "$root/repo/.worktrees/ticket/$C/01"
ok "claim created the ticket branch"        "$(heads "ticket/$C/01")" 1
ok "claiming a claimed ticket exits 2"      "$(rc "$br" claim "$C" 01)" 2
echo "ticket/$C/01 bundle/$C" >> "$MERGED"
ok "claim after the dependency merged"      "$(rc "$br" claim "$C" 02)" 0
ok "a two-dependency list is parsed"        "$(rc "$br" claim "$C" 03)" 2
ok "the unmet one of two is named"          "$(grep -c 'dependency 02 is doing' "$root/err")" 1
ok "claim on a draft bundle exits 2"        "$(rc "$br" claim 2026-09-01-nope 01)" 2
printf -- '---\ndepends_on: []\n---\n' > "$W/$T/07-race.md"
git -C "$W" add . && git -C "$W" commit -q -m "bundle: race ticket" && git -C "$W" push -q origin "bundle/$C"
ok "claim that loses the race exits 2"      "$(race "ticket/$C/07" "refs/heads/bundle/$C" "$br" claim "$C" 07)" 2
ok "the reason names the other session"     "$(grep -c 'claimed by another session' "$root/err")" 1
ok "a lost claim leaves no local branch"    "$(git branch --list "ticket/$C/07" | wc -l | tr -d ' ')" 0
git push -q origin --delete "ticket/$C/07"

echo "== claim of a lone ticket.md"
L=apps/billing/2026-09-02-invoices
ok "member bundle cut"              "$(rc "$br" cut "$L" main)" 0
LW="$root/repo/.worktrees/bundle/$L"; mkdir -p "$LW/apps/billing/work/bundles/2026-09-02-invoices"
printf -- '---\ndepends_on: []\n---\n' > "$LW/apps/billing/work/bundles/2026-09-02-invoices/ticket.md"
git -C "$LW" add . && git -C "$LW" commit -q -m "bundle: ticket" && git -C "$LW" push -q origin "bundle/$L"
ok "lone ticket.md claims as 01"    "$(rc "$br" claim "$L" 01)" 0

echo "== a member bundle that exists only on the remote"
M=apps/billing/2026-09-03-remote; MW="$root/repo/.worktrees/bundle/$M"
ok "member bundle cut"              "$(rc "$br" cut "$M" main)" 0
mkdir -p "$MW/apps/billing/work/bundles/2026-09-03-remote/tickets"
printf -- '---\ndepends_on: []\n---\n' > "$MW/apps/billing/work/bundles/2026-09-03-remote/tickets/01-only.md"
git -C "$MW" add . && git -C "$MW" commit -q -m "bundle: ticket" && git -C "$MW" push -q origin "bundle/$M"
ok "the main checkout holds no folder for it" "$(test -d apps/billing/work/bundles/2026-09-03-remote && echo dir || echo none)" none
ok "it is listed once, under its member only" "$("$here/bundles.sh" | awk -v r="$M" '/^==/{s=$2} $2==r{print s}' | tr '\n' ' ')" "apps/billing "
ok "its ticket comes from the branch"         "$("$here/bundles.sh" "$M" | awk 'NR==2{print $1" "$2}')" "todo 01-only"
"$br" abandon "$M" --execute >/dev/null 2>&1
ok "lone ticket.md has no 02"       "$(rc "$br" claim "$L" 02)" 2

echo "== complete"
TW="$root/repo/.worktrees/ticket/$L/01"
echo "7 ticket/$L/01 bundle/$L" >> "$PRS"; echo "8 feature/x main" >> "$PRS"
ok "complete of a non-ticket PR exits 2"    "$(rc "$br" complete 8 "$(git rev-parse main)")" 2
ok "complete of an unknown PR exits 2"      "$(rc "$br" complete 99 "$(git rev-parse main)")" 2
printf 'amend\n' >> "$LW/apps/billing/work/bundles/2026-09-02-invoices/ticket.md"
git -C "$LW" commit -qam "bundle: amend" && git -C "$LW" push -q origin "bundle/$L"
ok "complete of a stale ticket exits 2"     "$(rc "$br" complete 7 "$(git -C "$TW" rev-parse HEAD)")" 2
ok "the reason says stale"                  "$(grep -c '^stale:' "$root/err")" 1
git -C "$TW" fetch -q origin && git -C "$TW" merge -q --no-edit "origin/bundle/$L" && git -C "$TW" push -q origin "HEAD:ticket/$L/01"
accepted=$(git -C "$TW" rev-parse HEAD~1)   # a head the review judged before the latest push
ok "complete at a moved head exits 2"       "$(rc "$br" complete 7 "$accepted")" 2
ok "a refused merge merged nothing"         "$(grep -c "^ticket/$L/01 " "$MERGED")" 0
ok "complete at the accepted head exits 0"  "$(rc "$br" complete 7 "$(git -C "$TW" rev-parse HEAD)")" 0
ok "the PR is merged"                       "$(grep -c "^ticket/$L/01 bundle/$L\$" "$MERGED")" 1
ok "the ticket worktree is removed"         "$(test -d "$TW" && echo dir || echo gone)" gone
ok "the ticket branch is removed"           "$(heads "ticket/$L/01"):$(git branch --list "ticket/$L/01" | wc -l | tr -d ' ')" "0:0"

echo "== worktrees refuse transitions, listing still works"
before=$(git ls-remote origin | wc -l | tr -d ' ')
cp -R "$root/repo/docs" "$W/"   # docs/ is untracked in this fixture; a real checkout carries it
ok "cut from a worktree exits 2"     "$(cd "$W" && rc "$br" cut 2026-09-09-x main)" 2
ok "the reason names the main checkout" "$(grep -c "$root/repo" "$root/err")" 1
ok "claim from a worktree exits 2"   "$(cd "$W" && rc "$br" claim "$C" 03)" 2
ok "abandon from a worktree exits 2" "$(cd "$W" && rc "$br" abandon "$C" --execute)" 2
ok "complete from a worktree exits 2" "$(cd "$W" && rc "$br" complete 7 "$(git rev-parse main)")" 2
ok "nothing changed on the remote"   "$(git ls-remote origin | wc -l | tr -d ' ')" "$before"
ok "listing from a worktree lists its bundles" "$(cd "$W" && "$here/bundles.sh" | grep -c "$C")" 1

echo "== abandon"
ok "dry run exits 0"                 "$(rc "$br" abandon "$C")" 0
ok "dry run names the bundle branch" "$(grep -c "remote branch origin/bundle/$C\$" "$root/out")" 1
ok "dry run names a ticket branch"   "$(grep -c "remote branch origin/ticket/$C/02" "$root/out")" 1
ok "dry run names a ticket worktree" "$(grep -c "worktree $root/repo/.worktrees/ticket/$C/01" "$root/out")" 1
ok "dry run names a local branch"    "$(grep -c "local branch bundle/$C\$" "$root/out")" 1
ok "dry run removed nothing"         "$(headsm "/$C"):$(test -d "$W" && echo dir)" "3:dir"
ok "execute exits 0"                 "$(rc "$br" abandon "$C" --execute)" 0
ok "execute removed remote branches" "$(headsm "/$C")" 0
ok "execute removed local branches"  "$(git branch --list "*$C*" | wc -l | tr -d ' ')" 0
ok "execute removed the worktrees"   "$(ls "$root/repo/.worktrees/bundle" "$root/repo/.worktrees/ticket" 2>/dev/null | grep -c "$C")" 0
ok "a later cut of the same ref works" "$(rc "$br" cut "$C" main)" 0
"$br" abandon "$C" --execute >/dev/null 2>&1
G=2026-09-07-gone
ok "cut of a bundle that will land" "$(rc "$br" cut "$G" main)" 0
echo "bundle/$G main" >> "$MERGED"
ok "abandon on landed exits 0"      "$(rc "$br" abandon "$G" --execute)" 0
ok "landed abandon says leftovers"  "$(head -1 "$root/out" | grep -c 'leftovers only')" 1
ok "landed leftovers are removed"   "$(heads "bundle/$G"):$(git branch --list "bundle/$G" | wc -l | tr -d ' ')" "0:0"
ok "abandon with the forge down exits 2" "$(GH_DOWN=1 rc "$br" abandon "$L" --execute)" 2
ok "abandon left the bundle in place" "$(heads "bundle/$L")" 1
ok "abandon of an active bundle"    "$(rc "$br" abandon "$L" --execute)" 0
K=2026-09-11-lock
ok "cut of a bundle to lock"        "$(rc "$br" cut "$K" main)" 0
git worktree lock "$root/repo/.worktrees/bundle/$K"
ok "abandon with a locked worktree exits 2" "$(rc "$br" abandon "$K" --execute)" 2
ok "the reason names the worktree"  "$(grep -c "worktree:$root/repo/.worktrees/bundle/$K" "$root/err")" 1
ok "the reason names the local branch" "$(grep -c "local:bundle/$K" "$root/err")" 1
git worktree unlock "$root/repo/.worktrees/bundle/$K"
ok "abandon succeeds once unlocked" "$(rc "$br" abandon "$K" --execute)" 0
ok "outside a git repo exits 1"     "$(cd / && rc "$br" cut x main)" 1

echo "== errors and unknown"
"$here/bundles.sh" nope >/dev/null 2>&1; ok "no such bundle exits 2" "$?" 2
ok "the reason says no such bundle" "$("$here/bundles.sh" nope 2>&1 | grep -c '^no such bundle')" 1
git push -q origin main:refs/heads/bundle/2026-10-01-empty
ok "a cut branch with no folder is listed active" "$("$here/bundles.sh" | awk '$2=="2026-10-01-empty"{print $1}')" active
"$here/bundles.sh" 2026-10-01-empty >/dev/null 2>&1; ok "reading it exits 2" "$?" 2
ok "the reason says it cannot be read, not that it is missing" "$("$here/bundles.sh" 2026-10-01-empty 2>&1 | grep -c '^cannot read bundle')" 1
git push -q origin --delete bundle/2026-10-01-empty
"$here/bundles.sh" ../x >/dev/null 2>&1; ok "traversal refused" "$?" 2
ok "forge down is unknown"       "$(GH_DOWN=1 "$here/bundles.sh" 2026-09-01-root | head -1 | awk '{print $1}')" unknown
git remote set-url origin /nonexistent
ok "remote down is unknown"      "$("$here/bundles.sh" 2026-09-01-root | head -1 | awk '{print $1}')" unknown

echo; echo "$pass passed, $fail failed"; [ "$fail" -eq 0 ]
