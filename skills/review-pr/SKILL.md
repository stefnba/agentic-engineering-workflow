---
name: review-pr
description: Use when the user asks to review or re-review a pull request — "review PR 42", "review my PR", "run another review round" — and for every review round the implement-ticket skill runs. Takes an optional PR number, defaulting to the current branch's PR, and the word `design` to rerun the design reviewer after round 1. The review lands on the pull request as comments. Not for local changes no PR carries.
argument-hint: '[PR number] [design]'
---

# Review PR

Runs one review round on a pull request with the `review-changes` skill's two reviewers — design,
then correctness — and has each post its own reply on the PR as a comment. The chat gets only the
assessment and the links. Written for any agent harness; use your harness's own sub-agent
mechanism.

Each reviewer posts its own comment so the verdict reaches the PR in the reviewer's words, never
relayed by the session that asked for it — often the session that wrote the change.

## Path conventions

- The prompts are `../review-changes/prompts/` and the reply templates
  `../review-changes/templates/`, relative to this skill's directory, the folder holding this
  file. Requires the `review-changes` skill: if that path is missing, load that skill by name only
  to find its directory, and keep following this skill's process, not its steps; if that fails too,
  stop and tell the human to install it.
- The PR body template is `../write-pr/templates/pr-body.md`, relative to the same directory.
  Requires the `write-pr` skill: if that path is missing, load that skill by name only to find its
  directory; if that fails too, stop and tell the human to install it.
- Every other path is relative to the repository root, `git rev-parse --show-toplevel`, not the
  current directory.

## Process

### 1. Resolve the pull request and the round

Take the PR number from the argument, or from the current branch with
`gh pr view --json number -q .number`. No PR is your result: report it and stop.

Read `gh pr view <pr> --json number,url,headRefName,headRefOid,baseRefName,mergeable,comments`
and derive:

- **Head** — `headRefOid`, the SHA this round judges.
- **Round** — one more than the number of comments whose first line starts with
  `## Correctness Review: Round`; `1` when there is none.
- **Design runs** — when no `## Design Review: Round <round>` comment is on the PR yet, and the
  round is 1 or the argument carries `design`.

`mergeable` of `CONFLICTING` stops the round: report that the PR conflicts with its base and stop —
a diff that cannot merge as judged wastes the round. `UNKNOWN` means the forge is still computing
it; wait a few seconds and read it once more.

**Done when** you hold the PR, the head, the round number, and whether design runs, and the PR does
not conflict.

### 2. Put a checkout at the head

Use the current checkout when `git rev-parse HEAD` equals the head and
`git status --porcelain --untracked-files=no` prints nothing. Otherwise create a detached one under
the worktree directory named in `docs/conventions/git.md`, Worktrees:

```bash
git worktree remove --force <worktree dir>/review/pr-<pr> 2>/dev/null
git fetch -q origin <headRefName> && git worktree add --detach <worktree dir>/review/pr-<pr> <head>
```

The first line clears a worktree an interrupted earlier round left behind.

The merge base the reviewers diff against is `git merge-base origin/<baseRefName> <head>`, after
`git fetch -q origin <baseRefName>`.

**Change nothing in the checkout until step 4 ends.** The reviewers read and run checks in it.

**Done when** a clean checkout sits at the head, and you hold its absolute path and the merge base.

### 3. Resolve the contract

The head branch name decides:

- **`ticket/<bundle-reference>/<NN>`** — the contract is ``the ticket at `<path>` and the spec and
plan its frontmatter points to, plus the pull request's body``, the ticket read from the bundle
  folder in the checkout.
- **Any other name** — the contract is `the pull request's title and body`.

End either with ``; the PR body template is `<path>` ``, the PR body template's absolute path: the
reviewer runs with no session context and cannot resolve a skill name.

**Done when** the contract is one of the two.

### 4. Run the reviewers in order

For `01-design.md`, when design runs, then `02-correctness.md`:

1. Read the file and replace every placeholder:
    - `{{reply_template}}` — the absolute path of `design-reply.md` for `01-design.md`, of
      `correctness-reply.md` for `02-correctness.md`
    - `{{target}}` — ``pull request #<pr> (<url>) at head `<head>`, in the checkout at
      `<absolute path>`, which sits at that head: the change is `git diff <merge base>..<head>` ``
    - `{{contract}}` — the step-3 contract
    - `{{history}}` — on round 1, `none — this is round 1.`; later, ``rounds 1 to <round − 1>:
      read every `## Design Review`, `## Correctness Review`, and `## Fix Response` comment with
      `gh pr view <pr> --comments`.``
    - `{{round}}` — the round number
    - `{{head}}` — `git rev-parse --short=8` of the head
    - `{{prefix}}` — `` `R<round>-`, so IDs read `R2-A1`, `R2-Q1`, or `R2-F1` ``, unique across rounds
    - `{{deliver}}` — ``Before your final message, post the filled template as one comment on
      pull request #<pr>: write it to a file made with `mktemp`, then run
      `gh pr comment <pr> --body-file <that file>`. That comment is your only write. Then give the
      same text as your final message.``
    - `{{previous}}`, in `02-correctness.md` only — the design reviewer's reply, verbatim; when
      design did not run, `not run this round — the design review of an earlier round is on the
      PR`

2. Spawn one sub-agent with that text as its entire prompt, on the model the Review row of
   `docs/conventions/models.md` names for this harness. Add no session context and no extra
   instructions. In Claude Code that is the Agent tool with the `general-purpose` type, in the
   foreground and without worktree isolation — the prompt names the checkout.
3. Wait for its reply before starting the next. Never run the two in parallel; the second reads the
   first.

**Done when** each reviewer that runs has replied and its comment is on the PR — check with
`gh pr view <pr> --json comments`. A reviewer that replied without posting is rerun once; never
post its reply yourself. When the rerun does not post either, the round is incomplete: go to the
report step and report `Review round <round> of PR #<pr> incomplete — <reviewer> did not post`. No
correctness comment means the next run reuses this round number, which is correct: nothing was
judged. If the harness cannot spawn sub-agents, stop and ask the human to run each
filled prompt in a new session, in order, and paste the replies back; the prompts post the
comments themselves.

### 5. Report

Remove the worktree step 2 created, if any, whether or not the round finished:
`git worktree remove --force <path>`.

Derive the assessment from the replies: the design verdict, or `design not rerun`, then the
correctness verdict on its own line, glyphs included. A verdict is the first bullet under the
reply's `### Summary`, without its `- `; a reply with no such bullet is reported as
`<reviewer> reply incomplete`.

Reply in chat with exactly this, and nothing of the reviews themselves — they are on the PR:

```text
Review round <round> of PR #<pr> at `<head>`
<design verdict, or design not rerun>
<correctness verdict>
<URL of each comment this round posted, one per line>
```

**When the PR is not a ticket's and the correctness comment lists Backlog candidates**, offer them
through the `backlog` skill after that reply; nothing else carries them forward.

**Done when** the reply is in chat — or, when another skill invoked you, is the result it continues
from.
