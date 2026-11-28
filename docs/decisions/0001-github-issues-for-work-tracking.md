---
status: Proposed
date: 2026-11-28
---

# D-0001: GitHub issues for work tracking

## Context

The workflow needs one place for the backlog and the work items, read and changed by agents and by people. The first draft of 2026-11-25 kept work state in local files under `work/`. The GitHub draft of the same day kept it in GitHub issues. The owner chose between them in the design session of 2026-11-26, before any trial of either. The full comparison, with an example flow of one GitHub work item, is `docs/research/archive/work-tracking-options.md` at commit `ca5a8ea`.

## Decision

GitHub issues hold the backlog and the work items.

## Alternatives

**Local files in `work/`.** Agents read them with no network, login or API. A spec in a file is versioned with the code and shows in the same pull request. A folder suits a spec plus its tickets, and there is less to learn. It lost on these points:

- The version 1 backlog was one Markdown file that grew fast and could not be labelled.
- Nothing closes by itself, so deleting finished work must be enforced.
- Nothing assigns or notifies.
- Shared files such as a backlog or an inbox conflict on merge.
- A bundle on one developer's branch is invisible to everyone else. Making it visible needs a claim commit on `main` and a draft pull request.
- A subagent survey of 2026-11-25 found multi-developer visibility the weakest area in every reference repository that keeps work in files.

The first draft itself planned to move to GitHub past about four developers, or once people who do not code follow the work.

## Consequences

Easier:

- Labels, filtering, closing and assignment are built in.
- Discussion and notifications come with the issue.
- Nothing is synced between branches, and nothing goes stale in the repository. GitHub moves each issue's native status on assignment, a linked pull request, or close.

Harder:

- The skills need a working `gh` login. A sandboxed run without network or login cannot claim, list or close work items.
- The work state sits outside the repository, so it is not versioned with the code.
- A long spec in an issue body gets messy, and its edits cannot be diffed with the code. Where the spec lives stays open in `docs/workflow-design.md`, section "Work items, branches and worktrees".
- `Closes #N` works only on the default branch, so a ticket that merges into a feature branch is closed by command or by an Action.
- Side findings and assumptions need a GitHub home instead of `INBOX.md` and `OPEN_QUESTIONS.md`. Open questions become work items flagged `needs-decision`.

Changing this later: no skill names a tracker, so the skills stay as they are. Local-file support would add the `work/` folder, the `capture`, `triage` and `status` skills, the claim commit, and ID checks in CI. `docs/workflow-design.md`, section "Local-files option", keeps that design. Existing issues would have to be moved into files.

## Revisit if

- Agents must claim, list or close work items in runs that have no network or `gh` login.
- Specs outgrow issue bodies, and where the spec lives settles on a file on the feature branch.
- Work items must be versioned with the code they describe.
