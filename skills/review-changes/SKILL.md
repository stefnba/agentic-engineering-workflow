---
name: review-changes
description: Use when the user asks to review local work that no pull request carries — the working tree, the current diff, or a branch before its PR is opened — such as "review my changes", "check this before I commit", or "is this ready for a PR", even without naming the skill. Takes an optional base ref and an optional one-line intent to judge against. Not for an open pull request, and not for a draft bundle.
argument-hint: '[base ref] [stated intent]'
---

# Review changes

Runs two independent reviewers in order from prompt files — design, then correctness — against
local changes and delivers one report in chat. Written for any agent harness; use your harness's
own sub-agent mechanism.

## Path conventions

- `prompts/` and `templates/` paths are relative to this skill's directory, the folder holding this
  file.
- Every other path is relative to the repository root, `git rev-parse --show-toplevel`, not the
  current directory.

## Process

### 1. Resolve the change set

The argument optionally carries a base ref, then a one-line stated intent. Treat the first token as
a base ref only when `git rev-parse --verify <token>^{commit}` resolves; everything else is the
stated intent.

- **No base ref** — the baseline is `HEAD`; the change set is the staged, unstaged, and untracked
  work.
- **A base ref** — the baseline is `git merge-base <base> HEAD`; the change set is every commit
  since it, plus the uncommitted work on top.

When the change set is empty, reply in two lines and stop: why it is empty, and a rerun with a base
ref behind `HEAD` that would yield a non-empty set.

Record the fingerprint, so the report can say whether the tree moved while the reviewers read it:

```bash
{ git diff <baseline>; git status --porcelain; git ls-files -oz --exclude-standard | xargs -0 cat; } | shasum
```

**Done when** the baseline resolves, the change set is non-empty, and the fingerprint is recorded.

### 2. Resolve the contract

Pick the first that applies:

1. **The current branch is `ticket/<bundle-reference>/<NN>`** — the contract is that ticket's file
   in the bundle folder of this checkout, and the spec and plan its frontmatter points to. A
   stated intent is added to it.
2. **An intent was stated** — the contract is that intent, verbatim.
3. **Neither** — the contract is the repository's conventions and decision records only.

**Done when** the contract is one of the three.

### 3. Run the reviewers in order

For each file in `prompts/` in filename order (`01-design.md`, `02-correctness.md`):

1. Read the file and replace every placeholder:
    - `{{reply_template}}` — the absolute path of `templates/design-reply.md` for `01-design.md`,
      of `templates/correctness-reply.md` for `02-correctness.md`
    - `{{target}}` — ``the local changes in the checkout at `<absolute path>`: everything from
      commit `<baseline SHA>` to the working tree, committed or not — read them with
      `git diff <baseline SHA>` and `git status --porcelain`, and treat an untracked file as an
      addition``
    - `{{contract}}` — the step-2 contract: ``the ticket at `<path>` and the spec and plan its
      frontmatter points to``, `this stated intent: "<intent>"`, or `the repository's
      conventions and decision records only — no intent was stated`
    - `{{history}}` — `none — this review has no earlier rounds.`
    - `{{round}}` — `1`
    - `{{head}}` — `<baseline SHA> plus the working tree`
    - `{{prefix}}` — `empty, so IDs read A1, Q1, or F1`
    - `{{deliver}}` — `Give the filled template as your final message.`
    - `{{previous}}`, in `02-correctness.md` only — the design reviewer's reply, verbatim

2. Spawn one sub-agent with that text as its entire prompt, on the model the Review row of
   `docs/conventions/models.md` names for this harness. Add no session context and no extra
   instructions. In Claude Code that is the Agent tool with the `general-purpose` type, in the
   foreground and without worktree isolation — a worktree would not contain the uncommitted work.
3. Wait for its reply before starting the next. Never run the two in parallel; the second reads the
   first.

**Done when** both reviewers have replied. If the harness cannot spawn sub-agents, stop and ask the
human to run each filled prompt in a new session, in order, and paste the replies back.

### 4. Deliver the report

Recompute the fingerprint. A changed one does not void the review; the report says the tree moved.

Fill `templates/report.md`: paste each reviewer's reply verbatim into its slot, then derive the
Verdicts as the template's comment says. Deliver it as your final message, in full.

**When no ticket backs the change and the correctness reply lists Backlog candidates**, offer them
through the `backlog` skill after the report; nothing else carries them forward.

**Done when** the report is in chat — or, when another skill invoked you, is the result it
continues from.
