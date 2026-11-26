---
name: implement-ticket
description: Use when the user asks to implement, build, start, or pick up a ticket of an approved work bundle — "implement ticket 02 of <bundle>", a paste-ready prompt from shape-bundle — or when a session opens on a `ticket/` branch. Takes a bundle reference and a two-digit ticket number. Not for shaping a bundle, and not for work no bundle backs.
argument-hint: '[bundle reference] [NN]'
---

# Implement ticket

Build one approved ticket to a verified, reviewed pull request into its bundle branch, and stop at
the human's Accept gate. Everything decidable was decided at the Plan gate: the bundle, the ticket,
and the code in front of you are the whole input.

## Path conventions

- `references/` and `templates/` paths are relative to this skill's directory, the folder holding
  this file.
- The PR body template is `../write-pr/templates/pr-body.md`, relative to the same directory.
  Requires the `write-pr` skill: if that path is missing, load that skill by name only to find its
  directory; if that fails too, stop and tell the human to install it.
- Every other path is relative to the repository root, `git rev-parse --show-toplevel`, not the
  current directory.

## Guardrails

- **One ticket, one branch, one worktree, one PR.** A second ticket is a new session the human
  starts, or that the `implement-bundle` session the human dispatched starts.
- **Build the approved ticket and nothing else** — no redesign, no unrelated refactor, no future
  ticket, no opportunistic cleanup. Decide local details only inside the ticket's Autonomy
  boundaries; what you notice outside scope is offered as a backlog line at hand-back.
- **Stop and ask the human when a change would alter behavior, architecture another ticket shares,
  the ticket split, security, migration, compatibility, or acceptance criteria.** Those return to
  the Plan gate. The same holds for a review finding or alternative whose resolution would cross
  that line: escalate it, never design around it.
- **Correct a repository fact that drifted without changing intent** — a moved path, a renamed
  symbol — in the affected ticket or spec in this branch, and list it under the PR body's
  Corrections.
- **Never merge, approve, or review your own diff.** Accept is the human's gate; the review loop
  stops in front of it.
- **Write no status anywhere.** `doing` and `done` are derived from the ticket's branch and its
  merged PR.

## Process

### 1. Claim the ticket

The argument is a bundle reference — `<bundle-id>` for the root, `<member>/<bundle-id>` for a
member — and a two-digit ticket number. Ask when either is ambiguous; never guess.

**When the current branch is already `ticket/<bundle-reference>/<NN>`, the claim happened**; go to
the orient step.

Claim it with the `workflow-manager` skill's `claim`, from the main checkout. A non-zero exit is a stop: report its message and leave what it names to the human. Never pick a
different ticket to get around a refusal.

**Done when** the claim printed the ticket worktree's path as its last line; run every later
command from that worktree. The PR's base is `bundle/<reference>`.

### 2. Orient

In the worktree, read in one batch: the ticket, the spec and plan its `intent:` and `plan:`
frontmatter point to, the files its Scope names, the `AGENTS.md` of every member it touches, and the
`docs/decisions/` records covering that area.

**Read the bundle from this worktree, never from the main checkout.** This copy carries the
corrections earlier tickets' PRs made to the spec and the remaining tickets.

**Where a colocated README or `AGENTS.md` and the bundle disagree about the current system, the
README wins**: it describes what is, and the bundle owns only what this change makes true.

**Done when** every path, ID, and current-state claim the ticket cites has been checked against the
code. What does not hold is drift: take it through the Guardrails before writing a line, because
code written against a wrong claim entrenches it.

### 3. Build

**Produce the ticket's `Pre-change evidence` first**, and record the command, the commit it ran at,
and what it showed — the PR body needs it, and no reviewer can reproduce it once the change exists.
It binds: never skip it because the change looks obvious.

**When the ticket adds or changes behavior, read `references/tdd.md` and build by its loop.**

**Run a locked acceptance test unchanged.** One that cannot pass unmodified is drift, not a test to
adjust.

**When the ticket introduces or reshapes a module seam, read the `codebase-design` skill before
placing it.**

**Take one Done when condition at a time**, running that condition's own command as you go, and
make the smallest coherent change that satisfies the ticket.

**Commit as you go**, messages per `docs/conventions/git.md`.

**Done when** every Done when condition holds by its own command.

### 4. Verify and reconcile

Run the ticket's Commands and `make lint typecheck test`; fix what fails.

Update, in this branch, every document this diff made false: colocated READMEs and `AGENTS.md`
files, glossary entries through the `glossary` skill, `ARCHITECTURE.md` through the
`write-architecture-doc` skill, the spec where the implementation corrected it, and the remaining
tickets this one invalidated. Land reconciles only what no ticket owned; what you defer to it is
lost.

**When you changed any bundle file and the bundle holds a `brief.md`, rewrite the brief lines the
change made false**, in the same commit; the human judges the bundle from the brief.

**Done when** every check passes and every stale document is updated and committed.

### 5. Open the PR

Push the branch, then **run the `write-pr` skill with base `bundle/<reference>` and this
ticket**.

**Check the body as the correctness reviewer will, before every review round** — it treats a
missing or stale slot as a blocker, raised before it judges the diff.

**Judge each slot against the head, never against the previous body** — a fix round that adds a
file or a check makes slots stale that it never touched. Hold
`git diff --name-only origin/bundle/<reference>...HEAD` and `gh pr view <pr> --json body -q .body`,
and confirm against the PR body template:

- no `<!--` survives, and the Summary's Checks line names `git rev-parse --short=8 HEAD`;
- every slot the template keeps for a ticket PR is present;
- Scope names, with its reason, every listed path the ticket's Scope does not, and the Door and
  Blast radius lines hold for every listed path;
- Delivered carries a fenced view unless the template's view comment exempts the listed files;
- every Checks bullet is one verbatim command in backticks with its result — a sentence describing
  a comparison is a retelling, so write the command that ran it;
- Requires names everything a check needs that a fresh clone lacks — a gitignored file, an absolute
  path, a credential, a running service; better, rewrite the check to run without it;
- the Checks count equals the number of Checks bullets.

When one fails, fix the body file, refresh it with `gh pr edit <pr> --body-file <file>`, and check
again.

**Done when** the PR is open against `bundle/<reference>` and its body passes the body check.

### 6. Review until ready

Each round is the `review-pr` skill with the PR number — plus `design` when the previous fix round
adopted an alternative. It posts its reviews on the PR and replies with the assessment.

Read the round's comments with `gh pr view <pr> --comments`, then act on the words of each
review's verdict, the first bullet under its `### Summary`; the glyph before them is for the human:

- **Human escalation required** in either review → stop the loop and hand back, carrying both
  positions.
- **Ready for human review**, with no alternative left undisposed → the hand-back step.
- **Fixes required**, or a design verdict of "💡 <N> alternative(s) raised" → a fix round, below.
- **a stop before judging** — the PR conflicts with its base: resolve it with the human, then rerun
  the same round.
- **incomplete** — a reviewer did not post: rerun the same round once; when it is incomplete again,
  stop and report it to the human.

**When the human asks for a change between rounds**, make it in the next fix round and list it under
that fix response's Changes you asked for.

**Fix round.** Re-read the ticket and the round's comments first; what you remember writing is not
what was approved.

1. **Confirm every `suspected` alternative and finding** — read the line or run the case it rests
   on, and record whether it holds.
2. **Dispose of the alternatives before the findings** — an adopted alternative reshapes the code,
   and findings against the old shape become moot. Adopt one that stays inside the Autonomy
   boundaries and costs less than it saves; otherwise reject it.
3. **Escalate an alternative or finding whose resolution would cross the Guardrails.**
4. **Give every other finding one disposition:** fix it when the evidence holds and the fix stays
   inside approved intent; rebut it when the claim is wrong or already satisfied.
5. **Carry every design question to the hand-back unanswered** — only the human settles it.
6. Make the smallest fixes, rerun the verify-and-reconcile step in full, push, rerun the
   `write-pr` skill so the body describes the new head, and run the open-the-PR step's body check.
7. Post `templates/fix-response.md`, filled, with `gh pr comment <pr> --body-file <file>`, then run
   the next round.

**Stop after round 3 with blockers still open.** Report each open blocker and what its fix round
showed, and offer the human three moves: direct one more round, return the ticket to Shape, or
abandon it. A further round runs only on the human's explicit direction, one at a time.

**Before handing back, check currency:** `git merge-base --is-ancestor origin/bundle/<reference>
HEAD`. When it fails, a sibling ticket merged first: merge `origin/bundle/<reference>` in, rerun
step 4, push, rerun the `write-pr` skill and the body check, and run another round.

**Done when** a round reports ready for human review at a current head, or the loop stopped for the
human.

### 7. Hand back at the Accept gate

**Fill `templates/hand-back.md` and post it as one plain chat message.** Follow it with what you
noticed outside scope, offered through the `backlog` skill.

Then stop. The human reads the PR and runs that command from the main checkout, or asks a session
to run it through the `workflow-manager` skill; it merges only that head, and the merge makes the
ticket `done`. Starting the next ticket is the human's dispatch, in a new session, or the
`implement-bundle` session's when the human dispatched that.

## Checklist

- [ ] Every alternative, question, and finding ID of every round has a disposition in a
      fix-response comment.
- [ ] Before every review round, the PR body passed the open-the-PR step's body check against the
      current head.
