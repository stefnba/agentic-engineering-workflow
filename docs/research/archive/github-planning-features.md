# GitHub's native planning features, as of 2026-11-26

For a reader designing the GitHub tracker file and the `setup-workflow` skill: what GitHub itself offers to classify issues and track their status, where each feature is defined, and how an agent reads and sets it by command. The report states facts and gives no design advice.

GitHub issues now carry a native status, set mostly by GitHub itself, beside issue types and issue fields that personal accounts have too. Statuses are in public preview, cannot be customized, and have no `gh` flag yet. Types and fields belong to the account, not to one repository. Statuses appear to be one set that GitHub shares across every account.

Sources and method: on 2026-11-26, two research sub-agents read the GitHub Changelog, GitHub Docs, a GitHub community discussion and the cli/cli repository. They also ran read-only GraphQL and REST calls with gh 2.98.0 against `stefnba/agentic-engineering-workflow`, a personal-account repository with no issues. Nothing was written, so no write command was tested. Two more sub-agents, running on Opus, then checked every claim against the same sources on the same day. The main session then rechecked the key claims against the docs page "About issue statuses", the REST reference, the changelog pages, cli/cli and the API. This version holds the corrections from both checks. Tags:

- `[tested]` marks a result of a live API call.
- `[docs]` marks a claim from GitHub Docs or the GitHub Changelog.
- `[reported]` marks a claim from the community discussion, relayed by users or GitHub staff.
- `[read]` marks a claim read in an issue or pull request of cli/cli.
- `[unverified]` marks a claim no source confirmed.

## Overview

| Feature                             | Defined at                               | Per issue           | Status of the feature                                                                   | `gh` support in 2.98.0                                                                                                                                    |
| ----------------------------------- | ---------------------------------------- | ------------------- | --------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Issue status                        | GitHub; one set, owners cannot change it | One                 | Public preview since 2026-11-23                                                         | Filter only, through `--search`                                                                                                                           |
| Issue types                         | Account, Settings → Planning             | One                 | Generally available: organizations since April 2025, personal accounts since 2026-11-11 | `--type` on create, edit and list; `issueType` in `--json`                                                                                                |
| Issue fields                        | Account, Settings → Planning             | One value per field | Generally available: organizations since 2026-07-02, personal accounts since 2026-11-11 | None                                                                                                                                                      |
| Labels                              | Repository                               | Many                | Generally available                                                                     | `--label`                                                                                                                                                 |
| Sub-issues                          | Built in                                 | One parent          | Generally available since April 2025                                                    | `--parent`; `parent`, `subIssues`, `subIssuesSummary` in `--json`                                                                                         |
| Dependencies (blocked by, blocking) | Built in                                 | Many                | Generally available since August 2025                                                   | `--blocked-by`, `--blocking` on create; `--add-` and `--remove-blocked-by`, `--add-` and `--remove-blocking` on edit; `blockedBy`, `blocking` in `--json` |

## Issue status

GitHub announced issue statuses and repository boards on 2026-11-23, as a public preview with no date for general availability `[docs]` ([changelog](https://github.blog/changelog/2026-11-23-issue-statuses-and-repository-boards-are-in-public-preview/)). A repository board groups the issues of a saved view by status, and dragging a card changes the status. The community discussion starts on 2026-11-05, so some users may have seen statuses before the announcement `[reported]`.

The test repository has these statuses `[tested]`. Each belongs to a category, and the category decides whether the issue is open or closed:

| Status      | Category key  | Issue state | Close reason |
| ----------- | ------------- | ----------- | ------------ |
| Backlog     | `backlog`     | open        | —            |
| Todo        | `planned`     | open        | —            |
| In progress | `started`     | open        | —            |
| In review   | `started`     | open        | —            |
| Done        | `completed`   | closed      | completed    |
| Not planned | `not_planned` | closed      | not planned  |
| Duplicate   | `duplicate`   | closed      | duplicate    |

Rules for a reader of statuses, from the docs page "About issue statuses" unless tagged otherwise ([docs](https://docs.github.com/en/issues/tracking-your-work-with-issues/learning-about-issues/about-issue-statuses)):

- Owners cannot add, rename or remove statuses. No docs page describes customizing them `[docs]`.
- Users relay that customization will come with team-level ownership, with no date. No staff post says so `[reported]` ([discussion](https://github.com/orgs/community/discussions/212151)).
- An issue's status can be changed but not removed `[docs]`.
- Choosing a closed status closes the issue, and choosing an open status reopens it. Choosing Duplicate also requires the issue it duplicates `[docs]`.
- Match a status on its `id` or category, not its name, because names may change and categories may be added `[docs]` ([docs](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/issue-status-webhooks-and-workflows)).
- An issue created before its repository had statuses has none, and the field is `null`, until someone or GitHub sets one `[docs]`.
- The status set appears on the repository, the user and the organization in GraphQL. It has the same IDs for `stefnba`, this repository and the organization `github`, which suggests one global set `[tested]`. Whether a set can ever differ is `[unverified]`.

### Who can set a status

- People with triage access or higher `[docs]`.
- GitHub Apps with Issues write access, including workflows whose `GITHUB_TOKEN` has `issues: write` `[docs]`.
- Choosing a status that closes or reopens an issue also needs permission to close or reopen it `[docs]`.
- People who cannot choose a status can still close or reopen an issue they may close. That sets the default status for the new state `[docs]`.

### What GitHub sets automatically

New and reopened issues get Backlog unless the person chooses another status. Closing an issue sets the status matching its close reason: Done, Not planned or Duplicate `[docs]`.

For open issues, GitHub also moves the status on these triggers `[docs]`:

| Trigger                                                                                  | From                                    | To          |
| ---------------------------------------------------------------------------------------- | --------------------------------------- | ----------- |
| A person is assigned                                                                     | No status or Backlog                    | Todo        |
| An agent, such as Copilot, is assigned                                                   | No status, Backlog or Todo              | In progress |
| An open draft pull request is linked, or a linked draft is reopened                      | No status, Backlog or Todo              | In progress |
| A pull request ready for review is linked or reopened, or a linked draft is marked ready | No status, Backlog, Todo or In progress | In review   |
| A person or agent is assigned while a linked pull request is ready for review            | No status, Backlog, Todo or In progress | In review   |
| The last linked ready pull request becomes a draft, closes unmerged, or is unlinked      | In review                               | In progress |

Rules for these automatic changes `[docs]`:

- They only move an issue forward, and never close or reopen it. The last row is the one exception to moving forward.
- No trigger fires when a pull request merges. An issue reaches Done only by being closed, for example by a closing keyword.
- Only pull requests in the issue's repository, or in a public repository, change its status.
- A change does not happen when the person or app behind it cannot choose a status.
- A pull request counts as linked through a closing keyword or the Development section of the issue.

Closing keywords such as `Closes #12` still work only for a pull request whose base is the default branch `[docs]` ([docs](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue)). For any other base, GitHub ignores the keyword and creates no link. Such a pull request triggers none of the automations above unless it is linked through the Development section.

### Projects

GitHub syncs an issue's status with the Status field of its Project items when the Project belongs to the same account or organization as the repository `[docs]`:

- Issue to Project: the item moves to the option with the same name. Matching ignores case, extra spaces and emoji. With no matching option, the item stays.
- Project to issue: moving an item to an option named like a status sets that status, which can close or reopen the issue. Adding an issue to a Project in a column counts as a move. A Duplicate option does not change the issue.
- Built-in Project workflows that set Status set the option matching the issue's status instead of their configured one.
- Each Project can turn the sync off, as the docs page on built-in automations describes.

Users report on the community discussion that the sync overrides Project workflows and that turning it off is unreliable. No staff reply confirms this `[reported]`.

### Webhooks

The `issues` webhook event has an action `status_changed` `[docs]`. Delivery is best effort and can arrive out of order. A status change that also closes or reopens the issue sends two deliveries. The docs mark these webhooks as preview.

### Reading and setting status by command

No `gh` version up to 2.106.0, released 2026-11-25, has a status flag: neither the release notes nor the source of `gh issue create`, `edit`, `list` and `view` mention one `[read]`. `gh issue view --json` cannot return status `[tested]`. cli/cli#14996, "Add granular issue status support to GitHub CLI", is open and backlogged. It waits until GitHub publishes "supported public read, write, and repository-scoped discovery APIs" `[read]`. Commands that work today:

| Action                   | Command                                                                                                                                                 |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Filter issues by status  | `gh issue list --search 'status:"In progress"'`                                                                                                         |
| Read one issue's status  | `gh api graphql -F n=12 -f query='query($n:Int!){repository(owner:"OWNER",name:"REPO"){issue(number:$n){status{id name category{key state}}}}}'`        |
| List the status IDs      | `gh api graphql -f query='{repository(owner:"OWNER",name:"REPO"){planningStatuses(first:50){nodes{id name category{key}}}}}'`                           |
| List the statuses (REST) | `gh api repos/OWNER/REPO/planning-statuses`                                                                                                             |
| Set a status (REST)      | `gh api -X PATCH repos/OWNER/REPO/issues/N -f status="In progress"`                                                                                     |
| Set a status             | `gh api graphql -f query='mutation($i:ID!,$s:ID!){setIssueStatus(input:{issueId:$i,statusId:$s}){clientMutationId}}' -f i=ISSUE_NODE_ID -f s=STATUS_ID` |

Notes on these commands:

- The `status:` search qualifier takes a status name, case-insensitive. An unknown name returns HTTP 422 `[tested]`.
- `status:started` was rejected, although the error message says "Use an exact status name or category key" `[tested]`. The docs say to write `not-planned` for the `not_planned` category in search, so another syntax for categories may exist `[unverified]`.
- `setIssueStatus` closes or reopens the issue when the status calls for it, according to the schema `[tested]`. Its `duplicateIssueId` is required when the status closes the issue as a duplicate.
- The REST endpoints that create and update an issue take a `status` parameter, as a status name `[docs]` ([docs](https://docs.github.com/en/rest/issues/issues#update-an-issue)). Creating an issue accepts only the open statuses. Updating accepts all seven and changes the state to match; Duplicate needs `duplicate_issue_id`. The `PATCH` command above is untested. The `planning-statuses` listing returned all seven statuses `[tested]`.
- The docs conflict on who sees `status` in REST responses. The REST reference says only accounts enrolled in the preview. The webhooks page says any request that can read the issue `[docs]`.

## Issue types

Issue types became generally available for personal accounts on 2026-11-11, under Settings → Planning → Issue types `[docs]` ([changelog](https://github.blog/changelog/2026-11-11-issue-types-and-fields-are-available-for-personal-accounts/)). Organizations have had them since April 2025.

An account starts with Task, Bug and Feature and allows up to 25 types `[docs]`. The test repository returns exactly those three `[tested]`. Each type can pin issue fields, which then show by default on an issue of that type.

## Issue fields

| Date       | Milestone                                                                                                                               |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-03-12 | Preview for selected organizations                                                                                                      |
| 2026-05-21 | Preview for all organizations                                                                                                           |
| 2026-07-02 | Generally available for organizations ([changelog](https://github.blog/changelog/2026-07-02-issue-fields-are-now-generally-available/)) |
| 2026-08-07 | Multi-select fields generally available                                                                                                 |
| 2026-11-11 | Generally available for personal accounts                                                                                               |

Every account starts with these fields `[docs]`, and the test repository returns the fields and options `[tested]`. The pinning comes from the docs only: live calls returned no pinned fields per type, and only Priority as pinned for the repository `[tested]`.

| Field       | Type          | Options                   | Pinned to                           |
| ----------- | ------------- | ------------------------- | ----------------------------------- |
| Priority    | Single select | Urgent, High, Medium, Low | Every type, and issues with no type |
| Effort      | Single select | High, Medium, Low         | Bug, Task, Feature                  |
| Start date  | Date          | —                         | Feature                             |
| Target date | Date          | —                         | Feature                             |

Limits and visibility `[docs]`:

- An account holds at most 25 fields, and a type pins at most 10.
- Since 2026-11-23, any field can be set on any issue, whatever its type. Pinning decides only what shows by default.
- Visibility matters only in public repositories. Restricted is the default and Public the alternative. A public Project shows only Public fields ([docs](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/managing-issue-fields-in-your-organization)).

`gh` has no field support yet. Three open pull requests would add parts of it `[read]`:

- cli/cli#13948 adds writing through a new command, `gh issue edit-field`. It is a draft until issue fields are in the public schema as generally available.
- cli/cli#14130 adds reading in `gh issue view`, and field discovery.
- cli/cli#13707 adds `issueFieldValues` to `--json`.

Fields can be read and set through the API:

- REST: `GET`, `POST` and `PUT` on `repos/OWNER/REPO/issues/N/issue-field-values`, with a body `{"issue_field_values":[{"field_id":<int>,"value":…}]}`, and `DELETE` on `…/issue-field-values/FIELD_ID` `[docs]` ([docs](https://docs.github.com/en/rest/issues/issue-field-values)). For a single-select field, `value` is the option name. A returned item holds `issue_field_id`, `issue_field_name`, `node_id`, `data_type`, `value`, and `single_select_option` or `multi_select_options`. The `GET` returned 200 with an empty list even for an issue that does not exist, so it proves little `[tested]`.
- GraphQL: `setIssueFieldValue(input:{issueId, issueFields:[{fieldId, singleSelectOptionId}]})`, with `dateValue`, `textValue`, `numberValue` or `multiSelectOptionIds` for other field types, and `delete` to clear a value `[tested]` (schema only).

## Sub-issues, dependencies and linked pull requests

None of these changed in their core since 2025 `[docs]`. GitHub CLI 2.94.0, released 2026-06-10, added `--type`, `--parent`, `--blocked-by` and `--blocking`, their `--add-` and `--remove-` forms on `gh issue edit`, `--add-sub-issue` and `--remove-sub-issue`, and the matching `--json` fields ([changelog](https://github.blog/changelog/2026-06-10-manage-sub-issues-types-and-dependencies-from-github-cli/)).

Dependencies also have REST and GraphQL forms `[tested]`:

- REST: `POST repos/OWNER/REPO/issues/N/dependencies/blocked_by -F issue_id=<id>`, and `GET` on `blocked_by` and `blocking`. `issue_id` is the issue's database ID, not its number `[docs]` ([docs](https://docs.github.com/en/rest/issues/issue-dependencies)).
- GraphQL: `addBlockedBy(input:{issueId, blockingIssueId})` and `removeBlockedBy`.

A "Relates to" relationship entered preview on 2026-08-07 and became generally available on 2026-09-25 `[docs]` ([changelog](https://github.blog/changelog/2026-09-25-personal-saved-views-for-repository-issues-and-more/)).

## Token scopes

The local token has `repo`, `read:org`, `gist` and `workflow`. That was enough for every read above `[tested]`. For fine-grained tokens, the docs require Issues write access to add a dependency, and Issues write access plus further permissions to write field values `[docs]` ([docs](https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens)). Whether a classic `repo` token is enough to set status, dependencies and fields is `[unverified]`.

## Other recent features

| Feature                           | State, date                                        | Note                                                                                                                                                                                   |
| --------------------------------- | -------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Issue artifacts                   | Preview, 2026-10-28                                | Markdown, link or HTML items attached to an issue, managed with `gh issue artifact` ([changelog](https://github.blog/changelog/2026-10-28-issue-artifacts-are-now-in-public-preview/)) |
| Saved views for repository issues | Preview 2026-06-25, generally available 2026-09-25 | Basis of repository boards                                                                                                                                                             |
| Improved issue search             | Preview 2026-01-29, generally available 2026-04-02 | —                                                                                                                                                                                      |
| Projects hierarchy view           | Preview 2026-01-15, generally available 2026-03-19 | —                                                                                                                                                                                      |

The GitHub MCP server also reads and sets statuses, and status changes can trigger Copilot automations `[docs]`.
