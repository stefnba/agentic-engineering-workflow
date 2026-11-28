# Work tracking: GitHub issues or local files

For a reader revisiting the tracker decision, or adding local-file support later: the arguments for and against each option, and what each choice implies for the rest of the design. The rules and open questions of the local-files option are in `workflow-design.md`, section "Local-files option". The owner chose GitHub issues on 2026-11-26, for the backlog and for the work items. Local-file support is open.

Sources: the first design draft and the GitHub issues draft of 2026-11-25, the version 1 backlog, and the design session of 2026-11-26. Facts about GitHub features come from the note `github-planning-features.md`, checked on 2026-11-26 and since folded into [`0001-github-native-issue-tracking.md`](../0001-github-native-issue-tracking.md). No trial has run yet.

## GitHub issues

For:

- Labels, filtering, closing and assignment are built in.
- Nothing has to be synced between branches, and nothing goes stale in the repository.
- Discussion and notifications come with the issue.
- The first draft, which chose local files, planned to move to GitHub past about four developers, or once people who do not code follow the work.

Against:

- Agents need GitHub access. Sandboxed agent runs often have no network or GitHub login.
- A long spec in an issue body gets messy, and its edits cannot be diffed with the code.
- The work state sits outside the repository, so it is not versioned with the code.

## Local files

For:

- Agents read the files with no network, login or API.
- A spec in a file is versioned with the code and shows in the same pull request.
- A folder suits a spec plus its tickets.
- There is less to learn.

Against:

- The version 1 backlog was one Markdown file that grew fast and could not be labelled.
- Nothing closes by itself, so deleting finished work must be enforced.
- Nothing assigns or notifies.
- Shared files such as a backlog or an inbox conflict on merge.
- A bundle on one developer's branch is invisible to everyone else. Making it visible needs a claim commit on `main` and a draft pull request.
- Multi-developer visibility is the weakest area in every reference repository that keeps work in files (from a subagent survey of 2026-11-25).

## Consequences of choosing GitHub

- The skills need a working `gh` login. A sandboxed run without it cannot claim, list or close work items.
- `Closes #N` works only on the default branch, so a ticket that merges into a feature branch must be closed by command or by an Action.
- Each issue has a native status that GitHub moves when people assign the issue, link a pull request, or close it. No file has to be kept in sync.
- Where the spec lives stays open: the issue body, or a file on the feature branch.
- Open questions become work items flagged `needs-decision`. Side findings and assumptions still need a GitHub home instead of `INBOX.md` and `OPEN_QUESTIONS.md`.
- The local-files material (`work/`, bundles, inbox, claim commit, ID checks in CI) is not built. `workflow-design.md` keeps its rules as an open option.

## How the GitHub option could be built

What each GitHub feature offers, and one way to combine them. The values are examples, not choices for this repository. `workflow-design.md` holds the decisions and the open proposals.

### Example flow of one work item

The example uses one issue, #123, from idea to merge. Its number names the branch, the spec folder and the final pull request. The spec is a file on the feature branch, and a Project board tracks the stage. GitHub's native status has no Shaping or Ready, so the example needs the board for those two stages.

1. **Backlog.** Issue created from the Backlog item form: type Feature, status Backlog, a few lines on the problem or goal. Loose brainstorming happens in issue comments.
2. **Shaping.** Create `feature/123-<slug>` and commit `specs/123-<slug>/intent.md` and `plan.md`. Critique and revisions happen locally with the agent; the spec gets no PR. Add "Spec in progress on feature/123-<slug>" to the issue body, keeping the original brief.
3. **Ready.** Spec approved, noted as a comment on the parent issue. Create one Task sub-issue per ticket from the plan, with blocked-by links where order matters.
4. **In progress.** Each Task gets one branch and one PR, targeting the feature branch.
5. **In review.** All tasks merged; the final PR `feature/123 → main` is open. Before merging: post the final spec as a comment on #123 ("Final spec, as implemented"), extract any durable decisions into an ADR, delete `specs/123-<slug>/`.
6. **Done.** The final PR merges and closes #123 and its sub-issues.

**Exceptions:**

- Small items skip Shaping: the issue body is the spec, and it goes straight to one PR.
- If shaping shows the item is really several features, create new issues for the extras and close or keep #123 with links ("split into #140, #141").

### What each GitHub feature allows

| Feature                             | Defined at                    | Per issue           | Customizable                                                                           |
| ----------------------------------- | ----------------------------- | ------------------- | -------------------------------------------------------------------------------------- |
| Issue types                         | Account (Settings → Planning) | One                 | Rename, add, color, pin fields per type; defaults Task, Bug, Feature                   |
| Issue fields                        | Account (Settings → Planning) | One value per field | Name, type (text, single select, multi-select, number, date), visibility, pinned types |
| Issue status                        | GitHub, one fixed set         | One                 | Not customizable; GitHub moves it on assignment, linked pull requests and close        |
| Project Status                      | Project field                 | One                 | Options fully editable; drives board columns; syncs with issue status by name          |
| Labels                              | Per repo                      | Many                | Fully custom names, colors, descriptions                                               |
| Milestones                          | Per repo                      | One                 | Title, description, due date only                                                      |
| Sub-issues, dependencies, assignees | Built in                      | —                   | Not configurable                                                                       |

### Issue types

An account starts with Task, Bug and Feature and can add more. Each type can pin the fields that matter to it. Examples:

| Type    | Description                                          | Pinned fields                    |
| ------- | ---------------------------------------------------- | -------------------------------- |
| Feature | Parent work item: owns spec and feature branch       | Priority, Target date (optional) |
| Task    | One ticket = one agent = one PR                      | Effort, Priority, Agent mode     |
| Bug     | Something is broken                                  | Priority, Effort, Agent mode     |
| Spike   | Time-boxed research ending in a decision, not code   | Effort                           |
| Chore   | Maintenance, dependencies, CI; no user-facing change | Effort, Agent mode               |

### Issue fields

Every account starts with Priority, Effort, Start date and Target date. Other fields have to be created. The defaults below show GitHub's options; Agent mode is an example:

| Field       | Type          | Options                          |
| ----------- | ------------- | -------------------------------- |
| Priority    | Single select | Urgent, High, Medium, Low        |
| Effort      | Single select | High, Medium, Low                |
| Agent mode  | Single select | Autonomous, Assisted, Human only |
| Target date | Date          | —                                |

Field visibility matters only in public repositories, where a field is Restricted by default or Public.

### Project Status

Every issue has a native status, from a fixed set: Backlog, Todo, In progress and In review while open, and Done, Not planned or Duplicate once closed. A Project board adds its own Status field with editable options.

The two sync both ways when a Project option has the same name as an issue status, unless the Project turns the sync off. In the example columns below, Backlog, In progress, In review and Done would sync with the issue. Shaping and Ready exist only on the board. Example columns:

| Status      | Meaning                                         | Applies to      |
| ----------- | ----------------------------------------------- | --------------- |
| Backlog     | Idea captured, brief only                       | Features        |
| Shaping     | Spec and plan being written or reviewed         | Features        |
| Ready       | Spec approved and broken down, can be picked up | Features, Tasks |
| In progress | Branch exists, work underway                    | Features, Tasks |
| In review   | PR open, waiting for review                     | Features, Tasks |
| Done        | Merged and closed                               | All             |

A board can do without Blocked and Won't-do columns. Blocked-by links and a `blocked` label can mark blockers, and closing as _not planned_ or _duplicate_ records dropped work. Tasks can start directly in Ready.

### Label families

Labels suit values that can overlap. Example families:

| Family         | Labels                                                                               | Use                                     |
| -------------- | ------------------------------------------------------------------------------------ | --------------------------------------- |
| Area           | `area:api`, `area:ui`, `area:db`, `area:infra`, `area:auth` (mirror real components) | Which part of the codebase; can combine |
| Workflow flags | `needs-decision`, `needs-info`, `blocked`                                            | States on top of a stage; can stack     |
| Nature / risk  | `breaking-change`, `security`, `tech-debt`, `performance`                            | Extra review attention                  |

In this example, values that hold one thing at a time sit elsewhere: type and the fields on the issue, status on the issue and in the Project, resolution in the close reason, and dependencies in links. Since 2026-11-11 every account has issue types and fields, so type and priority need no labels.

### Automations

What GitHub does on its own, and what Actions can take over. Examples:

| Automation                           | Trigger                                                    | Effect                                                                     |
| ------------------------------------ | ---------------------------------------------------------- | -------------------------------------------------------------------------- |
| Native issue status (built in)       | Issue created / person assigned / PR linked / issue closed | Status = Backlog / Todo / In progress or In review / Done                  |
| Close task on feature merge (Action) | PR merged into `feature/*`                                 | Closes the linked sub-issue (`Closes #N` only works on the default branch) |
| Block specs on main (Action)         | PR into `main`                                             | Fails if `specs/` still exists                                             |
| Post final spec (Action, optional)   | Feature → main PR ready                                    | Posts the spec as a comment on the parent issue                            |
| Label sync (Action)                  | Change to `.github/labels.yml`                             | Creates and updates repo labels                                            |

## How the local-files option could be built

One way to keep work state in files, as the first draft of 2026-11-25 proposed it, limits and defaults included. `workflow-design.md`, section "Local-files option", holds its rules and open questions.

### The `work/` folder

```text
work/                      work state: churns constantly
  BACKLOG.md               Next and Later
  INBOX.md                 raw one-line notes from agents
  OPEN_QUESTIONS.md        open questions (Q-n) and working assumptions (A-n)
  bundles/<id>-<slug>/     one folder per piece of work in progress
    SPEC.md                problem, acceptance criteria, out of scope
    tickets/               vertical slices of the spec
```

| Artifact            | How it evolves                                                                                                                           |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `OPEN_QUESTIONS.md` | A question or assumption leaves when you decide it. It becomes a decision record if it passes the bar for one, and is removed otherwise. |
| `BACKLOG.md`        | Later: one line each, uncapped. Next: a paragraph each, at most about 10.                                                                |
| `INBOX.md`          | Empty after every triage.                                                                                                                |
| `bundles/`          | Exists only while the work is in progress. At most about 5 at once.                                                                      |

### Steps of this option

| Step    | Trigger                 | What happens                                                                                                                                      | Output                   |
| ------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| capture | any time, by agents     | Append one line about a side issue. No fixing outside scope, no ticket.                                                                           | line in `INBOX.md`       |
| triage  | regularly, by you       | Each inbox line is deleted (the default), moved to Later or Next with a UC link, or turned into an open question.                                 | empty inbox              |
| kickoff | when a Next item starts | Claim the bundle, then shape it as `workflow-design.md` describes.                                                                                | bundle, decision records |
| close   | in the merging PR       | Distill lasting knowledge into `docs/`. Delete the bundle, or archive it if `workflow-design.md`, section "Skills", decides so. Run the ID check. | updated docs, no bundle  |
