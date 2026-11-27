---
question: "What does GitHub itself offer today to classify issues and track their status, and how can an agent read and set each of these by command?"
researched: "2026-11-27"
versions: "gh 2.98.0 (installed, tested) to gh 2.106.0 (release notes only); GitHub REST API versions 2022-11-28 and 2026-03-10; GitHub GraphQL API as of 2026-11-27"
---

# Native GitHub issue classification and status, read and set by command

## Answer

- Every native feature in the table exists for a repository owned by a personal account. "Relates to", repository boards and Projects lack a live check on such a repository, and repository boards have no command at all.
- gh covers labels, milestones on an issue, assignees, close reason, issue type, sub-issues, dependencies and Projects with its own flags. Issue fields, issue statuses, "Relates to", milestone definitions and sub-issue order need `gh api` with REST or GraphQL.
- The table is built from gh 2.98.0 help output, the REST and GraphQL docs, and live schema introspection, all on 2026-11-27. The gh releases from 2.99.0 to 2.106.0 change none of these commands, by a keyword scan of their notes (tested 2026-11-27: `gh release view <tag> -R cli/cli`).

| Feature | Defined at | Status | Read | Set |
|---|---|---|---|---|
| Labels | Repository | GA | `gh label list`; `gh issue view --json labels` | `gh label create/edit/delete`; `gh issue edit --add-label/--remove-label` |
| Milestones | Repository | GA | REST `GET …/milestones`; `--json milestone` | Define: REST `…/milestones` only. On an issue: `gh issue edit --milestone` |
| Assignees | Repository (users who can be assigned) | GA | `--json assignees` | `gh issue edit --add-assignee/--remove-assignee` |
| State and close reason | GitHub (fixed reasons) | GA | `--json state,stateReason` | `gh issue close --reason [--duplicate-of]`; `gh issue reopen` |
| Issue types | Account, inherited by its repositories | GA for personal accounts since 2026-11-11 | `--json issueType`; REST `GET /repos/…/issue-types` | `gh issue edit --type`. Define: REST `/user/issue-types` or GraphQL, scope `user` |
| Issue fields | Account, inherited by its repositories | GA for personal accounts since 2026-11-11 | REST `issue_field_values`; GraphQL `issueFieldValues` | REST `issue_field_values` or GraphQL `setIssueFieldValue`. Define: REST `/user/issue-fields` or GraphQL, scope `user` |
| Issue statuses | GitHub (fixed seven) | Public preview since 2026-11-23 | REST and GraphQL `status`; `gh issue list --search 'status:…'` | REST `status` or GraphQL `setIssueStatus` |
| Repository boards | Repository saved views | Public preview since 2026-11-23 | None | None; dragging a card sets the status |
| Sub-issues | Issue | GA | `--json parent,subIssues,subIssuesSummary` | `gh issue edit --parent/--add-sub-issue/--remove-sub-issue`; reorder only by REST or GraphQL |
| Dependencies | Issue | GA since 2025-08-21 | `--json blockedBy,blocking` | `gh issue edit --add-blocked-by/--add-blocking` and their `--remove-` forms |
| "Relates to" | Issue | GA since 2026-09-25 | REST `…/relates_to`; GraphQL `relatesTo` | REST `POST/DELETE …/relates_to` or GraphQL `addRelatesTo/removeRelatesTo` |
| Project item and fields | The Project, owned by the account | GA | `gh project item-list`, scope `read:project` | `gh project item-add`, `item-edit`, scope `project` |

The sections below hold the evidence for each row.

- The `repo` scope covers every repository-level read and every issue write in the table. Account-level types and fields need `read:user` or `user`. Projects need `read:project` or `project`.
- Issue statuses carry the most risk. They are a four-day-old preview that the REST docs limit to "accounts enrolled in the preview", and the test repository is enrolled. The discussion's author, who writes for the team building the feature, wrote on 2026-11-27 that statuses will become customizable per team within fixed categories ([discussion #212151][d212151]).
- The evidence is thin in three places. The test repository has no issues, so no issue-level value was read there. No write was run, so every "Set" route rests on docs and schema alone. No Project was read, because the token lacks `read:project`.

## Which native features classify an issue or track its status in a personal-account repository, where is each defined, is each available to personal accounts, and what limits apply?

- The owner of the test repository is a personal account (tested 2026-11-27: `gh api --method GET users/stefnba --jq .type` returned `User`).
- Issue types and issue fields are "now generally available on repositories owned by personal accounts". They are configured in the account's settings under Planning ([GitHub Changelog, 2026-11-11][cl-1111]).
  - The default types are Bug, Task and Feature. The default fields are Priority, Effort, Start date and Target date.
  - Each allows up to 25. Field types are text, number, date, single-select and multi-select.
- The test repository shows the default types and fields (tested 2026-11-27: GraphQL `repository{issueTypes{…} issueFields{…}}`). Inferred: types and fields are defined on the account and every repository it owns inherits them, from this read and the Settings location above.
- Since 2026-11-23 any field can be added to an issue of any type. A field shows by default only when it is pinned to that type ([GitHub Changelog, 2026-11-23][cl-1123]).
- Issue statuses and repository boards are in public preview ([GitHub Changelog, 2026-11-23][cl-1123]). The seven statuses are fixed by GitHub, and each maps to a state and a close reason (tested 2026-11-27: GraphQL `repository{planningStatuses{nodes{name category{key state stateReason}}}}`):

  | Status | Category key | State | Close reason |
  |---|---|---|---|
  | Backlog | `backlog` | OPEN | none |
  | Todo | `planned` | OPEN | none |
  | In progress | `started` | OPEN | none |
  | In review | `started` | OPEN | none |
  | Done | `completed` | CLOSED | `COMPLETED` |
  | Not planned | `not_planned` | CLOSED | `NOT_PLANNED` |
  | Duplicate | `duplicate` | CLOSED | `DUPLICATE` |

- A reply of 2026-11-19 by a GitHub collaborator says "The issue statuses are fixed to this set." The 2026-11-27 reply by the author of #212151, cited in the Answer, says custom statuses per team are coming. Both are in community discussions ([discussion #212171][d212171]; [discussion #212151][d212151]).
- Statuses change on their own when a user is assigned (to Todo) or a pull request is linked (to In progress or In review) ([GitHub Changelog, 2026-11-23][cl-1123]).
- A repository board is a board layout of a repository's saved issue views. Grouped by status, dragging an issue between columns changes its status. The entry names API support for statuses only ([GitHub Changelog, 2026-11-23][cl-1123]).
- The close reasons are `COMPLETED`, `NOT_PLANNED` and `DUPLICATE` (tested 2026-11-27: introspection of `IssueClosedStateReason`).
- Labels belong to one repository. Organization owners can customize the default labels for their organization's repositories ([GitHub Docs, Managing labels][docs-labels]). The docs list ten defaults including `accessibility`. The test repository has nine, without `accessibility` (tested 2026-11-27: `gh label list --json name,isDefault`).
- Label archiving is GA since 2026-08-27 ([GitHub Changelog, 2026-08-27][cl-0827]).
- Sub-issues allow "up to 100 sub-issues per parent issue" and "up to eight levels of nested sub-issues" ([GitHub Docs, Adding sub-issues][docs-subissues]).
- Dependencies are GA, and "You can link up to 50 issues for each relationship type" ([GitHub Changelog, 2025-08-21][cl-dep]). The docs page states no limit ([GitHub Docs, Creating issue dependencies][docs-deps]).
- The only user who can be assigned in the test repository is its owner (tested 2026-11-27: `gh api --method GET repos/stefnba/agentic-engineering-workflow/assignees`).

## How does an agent read and set labels, milestones, assignees, and open or closed state with close reason by command, including defining the labels and milestones themselves?

- `gh issue view` and `gh issue list` expose `labels`, `milestone`, `assignees`, `state` and `stateReason` as `--json` fields. `gh issue list` filters with `--label`, `--milestone`, `--assignee` and `--state` (tested 2026-11-27: `gh issue view --help`, `gh issue list --help`, gh 2.98.0).
- `gh issue edit` sets the milestone by name and accepts several issue numbers at once. The assignee flags take `@me` and `@copilot` (tested 2026-11-27: `gh issue edit --help`, gh 2.98.0).
- `gh issue close --reason` takes `completed`, `not planned` or `duplicate`, plus `--duplicate-of`. `gh issue reopen` takes no reason (tested 2026-11-27: `gh issue close --help`, `gh issue reopen --help`, gh 2.98.0).
- REST `PATCH /repos/{owner}/{repo}/issues/{issue_number}` takes `state`, `state_reason` and `duplicate_issue_id` ([REST docs, Issues, 2026-03-10][rest-issues]).
  - `state_reason` is `completed`, `not_planned`, `duplicate`, `reopened` or `null`, and is "Ignored unless state is changed".
  - `labels` and `assignees` replace the whole set. `milestone` takes a number, or `null`.
- That endpoint drops changes from a user without push access with no error: "milestone changes are silently dropped". The page says labels and assignees behave the same ([REST docs, Issues][rest-issues]).
- REST adds and removes single labels on `/repos/{owner}/{repo}/issues/{issue_number}/labels` ([REST docs, Labels][rest-labels]). It adds up to 10 assignees on `…/issues/{n}/assignees` ([REST docs, Assignees][rest-assignees]).
- GraphQL has `closeIssue` (with `stateReason` and `duplicateIssueId`), `reopenIssue` and `updateIssue`. It also has `addLabelsToLabelable`, `removeLabelsFromLabelable`, `addAssigneesToAssignable`, `removeAssigneesFromAssignable` and `replaceActorsForAssignable` (tested 2026-11-27: introspection of `Mutation`, `CloseIssueInput` and `UpdateIssueInput`).
- `gh label` has `list`, `create`, `edit`, `delete` and `clone`. `create --force` updates the label if it exists (tested 2026-11-27: `gh label <sub> --help`, gh 2.98.0). GraphQL has `createLabel`, `updateLabel` and `deleteLabel` (tested 2026-11-27: introspection).
- No gh subcommand and no GraphQL field archives a label (tested 2026-11-27: `gh label <sub> --help` and introspection of `Label`). REST `PATCH /repos/{owner}/{repo}/labels/{name}` lists `archived` ([REST docs, Labels][rest-labels]). The live REST label carries `archived_at` and `archived_by` (tested 2026-11-27: `gh api --method GET repos/stefnba/agentic-engineering-workflow/labels/bug`).
- A third-party write-up of 2026-09-01 reports no public API for label archiving. It was seen only as a search summary ([Classmethod, 2026-09-01][classmethod]). The REST docs and the live response above are newer and closer to the fact.
- Milestones have no gh command (tested 2026-11-27: `gh milestone --help` returned `unknown command "milestone"`) and no GraphQL mutation (tested 2026-11-27: introspection of `Mutation`). REST lists, creates, updates and deletes them on `/repos/{owner}/{repo}/milestones[/{milestone_number}]` ([REST docs, Milestones][rest-milestones]).
- REST version 2026-03-10 removes the singular `assignee` field from issue endpoints. GitHub advises "Use the `assignees` array parameter instead" ([REST docs, Breaking changes][rest-breaking]). gh 2.98.0 `gh api` gets version 2022-11-28 when it sends no version header (tested 2026-11-27: `gh api -i … | grep -i x-github-api-version`).

## How does an agent read and set issue types, issue fields, and issue statuses (and repository boards) by command, including defining them, or is there no command for some of them?

- gh 2.98.0 sets an issue's type with `gh issue edit --type` and `--remove-type`, and on creation with `gh issue create --type`. It filters with `gh issue list --type` and reads with `--json issueType`. It has no flag for issue fields or issue status (tested 2026-11-27: `gh issue create|edit|list --help`).
- REST create and update take `type` by name and `issue_field_values` as `{field_id, value}` pairs. Setting `type` "requires push access" ([REST docs, Issues, 2026-03-10][rest-issues]). REST issue objects carry `issue_field_values`, `status` and `type` (tested 2026-11-27: `gh api --method GET repos/cli/cli/issues/14467 --jq keys`).
- GraphQL `Issue` has `issueType`, `issueFieldValues` and `status`. Mutations include `updateIssueIssueType`, `setIssueFieldValue`, `createIssueFieldValue`, `updateIssueFieldValue`, `deleteIssueFieldValue` and `setIssueStatus` (tested 2026-11-27: introspection of `Issue` and `Mutation`).
- REST `GET /repos/{owner}/{repo}/issue-types` lists the repository's types with their IDs. REST `GET /repos/{owner}/{repo}/issue-fields` returns 404, while GraphQL `repository.issueFields` lists the fields (tested 2026-11-27: both `gh api` reads).
- Defining types and fields at the account level is covered under the sub-question on issue-type and issue-field endpoints.
- No command creates or changes a status. REST planning statuses has only a GET ([REST docs, Planning statuses][rest-planning]). The schema has no mutation that creates or updates a `PlanningStatus` (tested 2026-11-27: introspection of `Mutation`).
- Reading and setting a status is covered under the sub-question on issue status.
- Repository boards have no command. The live schema has no type whose name contains "Board" (tested 2026-11-27: `__schema{types{name}}` grepped for `board`). The 2026-11-23 entry names no board API ([GitHub Changelog, 2026-11-23][cl-1123]).

## How does an agent read and set sub-issues and issue dependencies by command?

- `gh issue create --parent` and `gh issue edit --parent`, `--remove-parent`, `--add-sub-issue` and `--remove-sub-issue` take numbers or URLs. gh has no reorder flag (tested 2026-11-27: `gh issue create|edit --help`, gh 2.98.0).
- gh support dates from v2.94.0 ([GitHub Changelog, 2026-06-10][cl-0610]). That entry, read through a summarizing fetch, names a `--set-parent` flag, which gh 2.98.0 does not have. The installed help is newer and closer to the fact.
- REST sub-issue endpoints ([REST docs, Sub-issues, 2026-03-10][rest-subissues]):
  - Get the parent: `GET …/issues/{issue_number}/parent`.
  - List: `GET …/sub_issues`.
  - Add: `POST …/sub_issues` with `sub_issue_id` and `replace_parent`.
  - Remove: `DELETE …/sub_issue`, singular.
  - Reorder: `PATCH …/sub_issues/priority` with `after_id` or `before_id`.
- REST requires "The sub-issue must belong to the same repository owner as the parent issue" ([REST docs, Sub-issues][rest-subissues]). The UI docs let a user add issues from other repositories ([GitHub Docs, Adding sub-issues][docs-subissues]).
- GraphQL has `addSubIssue` (with `replaceParent`), `removeSubIssue` and `reprioritizeSubIssue`, and `Issue.subIssuesSummary` with `total`, `completed` and `percentCompleted` (tested 2026-11-27: introspection).
- `GET …/issues/1/sub_issues` returned `[]` for an issue that does not exist, while `…/issues/1/parent` returned 404 (tested 2026-11-27: `gh api` on the test repository).
- `gh issue create --blocked-by/--blocking` and `gh issue edit --add-blocked-by`, `--add-blocking`, `--remove-blocked-by` and `--remove-blocking` set dependencies (tested 2026-11-27: `gh issue create|edit --help`, gh 2.98.0). GitHub Docs advise reading with `gh issue view N --json blockedBy,blocking` ([GitHub Docs, Creating issue dependencies][docs-deps]).
- cli/cli#14467 (2026-09-17) lists the blocked-by flags as present "As of v2.101.0", which does not date their arrival ([cli/cli#14467][cli-14467]). The tested help shows them in 2.98.0.
- REST lists both directions but writes only "blocked by": `POST …/dependencies/blocked_by` with `issue_id`, and `DELETE …/dependencies/blocked_by/{issue_id}` ([REST docs, Issue dependencies][rest-deps]). GraphQL likewise has only `addBlockedBy` and `removeBlockedBy` (tested 2026-11-27: introspection).
- The REST sub-issue and dependency endpoints take the issue's numeric `id`, not its number ([REST docs, Sub-issues][rest-subissues]; [REST docs, Issue dependencies][rest-deps]).

## How does an agent read and set an issue's place and field values in a GitHub Project owned by a personal account by command, and which token scopes does that need?

- `gh project item-add` adds an issue by `--url`, with `--owner "@me"` for the current user. `item-list` reads items and filters with `--query` (tested 2026-11-27: `gh project item-add|item-list --help`, gh 2.98.0).
- `gh project item-edit --field "Status" --value "In Progress"` sets a single-select by option name. For an issue it sets one field per call (tested 2026-11-27: `gh project item-edit --help`, gh 2.98.0). Name-based editing arrived in gh 2.97.0 ([cli/cli#13816][cli-13816]).
- `item-edit` sets an iteration only by ID: "setting an iteration field by name is not supported; use `--iteration-id`" ([cli/cli `item_edit.go`, v2.106.0][src-item-edit]).
- GraphQL adds an item with `addProjectV2ItemById` and sets values with `updateProjectV2ItemFieldValue` ([GitHub Docs, Using the API to manage Projects][docs-projects-api]; [GraphQL reference, Projects][gql-projects]).
  - Adding an existing item returns its ID.
  - "You cannot add and update an item in the same call."
  - Assignees, labels, milestone and repository are issue properties, not Project field values.
- REST has `/users/{username}/projectsV2/{project_number}/items` with GET and POST, and GET, PATCH and DELETE on `…/items/{item_id}` ([REST docs, Project items, 2026-03-10][rest-proj-items]).
- gh can list, create and delete Project fields but has no `field-edit` (tested 2026-11-27: `gh project --help`). `field-create` accepts only TEXT, SINGLE_SELECT, DATE and NUMBER ([cli/cli `field_create.go`, v2.106.0][src-field-create]). GraphQL `updateProjectV2Field` changes options, and options sent replace the existing ones ([GraphQL reference, Projects][gql-projects]).
- Scopes: queries need `read:project` and mutations need `project` ([GitHub Docs, Using the API to manage Projects][docs-projects-api]). gh states `project` as the minimum and adds it with `gh auth refresh -s project`, which opens a browser (tested 2026-11-27: `gh project --help`, `gh auth refresh --help`).
- The fine-grained permissions page lists Projects only as an organization permission and no `/users/{username}/projectsV2` endpoint ([GitHub Docs, Fine-grained token permissions][docs-fg]).
- With the test token, `gh project list --owner stefnba` failed with "missing required scopes [read:project]" (tested 2026-11-27). No command in this section was run against a Project.

## What problems do users report when reading or setting these features by command (gh and API issues, community discussions), if any?

- `gh issue create --type` creates the issue before it resolves the type name. When the type does not exist, it exits 1 without printing the URL, so a retry creates a duplicate ([cli/cli#14703, 2026-10-15, open][cli-14703]). The report's premise, that personal repositories have no issue types, is dated by the 2026-11-11 release.
- `gh issue create` also reports failure after creating the issue when the viewer cannot set the type. A comment says the bug "is still present in GitHub CLI v2.103.3" ([cli/cli#13804, open][cli-13804]).
- `gh issue close --reason` on an already closed issue exits 0 and leaves `stateReason` unchanged. The reporter names REST `PATCH` with `state_reason` as the workaround ([cli/cli#14364, open][cli-14364]).
- gh has no status flags or status JSON field. A triage comment cites gh 2.103.3 and gives the workaround `gh issue list --search 'status:"In Progress"'` ([cli/cli#14996, 2026-11-09, open][cli-14996]).
- gh has no "Relates to" flags. The request is labeled `blocked` and `stale` ([cli/cli#14467, open][cli-14467]).
- `gh issue create --project` without `read:project` reports the project as "not found". The triage workaround is `gh auth refresh -s read:project` ([cli/cli#8798, open][cli-8798]).
- One user reports that `subIssuesSummary` may freeze at one total and zero completed, and has not ruled out their own client ([cli/cli#13120, comment 2026-04-24][cli-13120]).
- A user reports that assigning through REST, GraphQL or `gh issue edit --add-assignee` left an issue in Backlog. The same assignment in the web UI moved it to Todo ([discussion #212171, 2026-11-27][d212171]).
- A user reports that issues closed as Not planned or Duplicate load into the Done column of the board ([discussion #212171, 2026-11-27][d212171]).
- A user reports on 2026-11-23 that changing an issue's Status in one Project changes it in every Project that holds it ([discussion #212151][d212151]).
- No release from gh 2.99.0 to 2.106.0 lists a fix for #14703, #13804 or #14364 (tested 2026-11-27: `gh release view <tag> --repo cli/cli --json body`, grepped).
- No reported problem specific to labels or milestones by command turned up in the `cli/cli` searches.

## How does an agent read an issue's status by command, what does setting a status do to the issue's open or closed state and close reason, and how does it sync with a Project's Status field?

Reading:

- REST issue responses carry `status` as `{id, name, category}`, or null. The REST list endpoints have no `status` filter ([REST docs, Issues, 2026-03-10][rest-issues]). A live read returned `"status":{"category":"backlog","id":2,"name":"Backlog"}` (tested 2026-11-27: `gh api --method GET repos/github/docs/issues/47093`).
- GraphQL `Issue.status` is a `PlanningStatus` with a node ID, `name` and `category`, and `viewerCanSetStatus` tells whether the viewer can set it ([GraphQL reference, Issues][gql-issues]).
- Search supports `status:`, `category:`, `-status:`, `has:status` and `no:status` on issues ([GitHub Docs, Searching issues][docs-search]). The search API needs `advanced_search=true`.
  - Multi-word names need quotes.
  - Repeating `status:` means AND.
  - `status:` also filters pull requests by commit status.
- `gh issue list --search 'status:Backlog'` works in gh 2.98.0, and so does the search API (tested 2026-11-27: on `github/docs`). gh 2.98.0 has no `status` JSON field (tested 2026-11-27: `gh issue view --json bogus`).
- Status IDs come from REST `GET /repos/{owner}/{repo}/planning-statuses` as integers, or GraphQL `planningStatuses` as node IDs. On the test account, `repository.planningStatuses` and `user.planningStatuses` returned the same node IDs (tested 2026-11-27: `gh api` REST and GraphQL reads). The REST endpoint returns 404 where statuses are not available ([REST docs, Planning statuses][rest-planning]).
- The webhooks page advises fetching the issue with REST for its latest status, and matching on `id`, not `name` ([GitHub Docs, Issue status webhooks and workflows][docs-status-webhooks]).

Setting, and its effect on state:

- REST update `status` takes any of the seven names. "Setting a status also updates state and state_reason as needed". A `state` sent alongside must match, and Duplicate requires `duplicate_issue_id` ([REST docs, Issues, 2026-03-10][rest-issues]).
- REST create `status` takes only the four open statuses and defaults to Backlog ([REST docs, Issues][rest-issues]).
- GraphQL `setIssueStatus` takes `issueId`, `statusId` and `duplicateIssueId` and closes or reopens the issue "when the status calls for" it ([GraphQL reference, Issues][gql-issues]). `UpdateIssueInput.statusId` does the same, and a status "can't be cleared" (tested 2026-11-27: introspection of `UpdateIssueInput`).
- "Closing an issue sets the status that matches its closing reason." New and reopened issues get Backlog. A status can be changed but not removed. Automatic status changes "never close or reopen" an issue ([GitHub Docs, About issue statuses][docs-status]).
- Setting a status needs triage access or higher, or an app with Issues write permission ([GitHub Docs, About issue statuses][docs-status]).
- One user reports that closing as not planned or duplicate "closes as completed", contrary to the docs ([discussion #212151, 2026-11-24][d212151]). No staff reply confirms it.

Project sync:

- With status sync on, an issue's status and its Project items' Status option update each other by matching names. The Project must have the same owner as the repository ([GitHub Docs, About issue statuses][docs-status]).
- "Sync is off by default for existing and new projects that don't have a saved setting" ([GitHub Docs, About issue statuses][docs-status]). It is turned on or off in the Project's sidebar under Statuses ([GitHub Docs, Using the built-in automations][docs-automations]).
- No source shows an API or command for the sync setting.
- The discussion tells a different story ([discussion #212151][d212151]):
  - On 2026-11-23 users report sync across all Projects with no opt-out.
  - On 2026-11-24 the discussion's author promises a per-project opt-out.
  - On 2026-11-25 a user reports that statuses still drift after turning sync off.
  - The docs read on 2026-11-27 are newer than these reports.

## Which REST endpoints and GraphQL mutations list, create, update and delete a personal account's issue types and issue fields, including multi-select fields, and which token scopes do they need?

- REST issue types: `GET` and `POST /user/issue-types`, and `PUT` and `DELETE /user/issue-types/{issue_type_id}` ([REST docs, Issue types (users)][rest-user-types]).
  - The body takes `name` and `is_enabled` (both required), plus `description` and `color`.
  - Update uses `PUT`.
- REST issue fields: `GET` and `POST /user/issue-fields`, and `PATCH` and `DELETE /user/issue-fields/{issue_field_id}` ([REST docs, Issue fields (users)][rest-user-fields]).
  - `data_type` is `text`, `date`, `single_select`, `multi_select` or `number`.
  - `visibility` is `restricted` (default) or `all`.
  - Select options take `name`, `color` and `priority`.
- `PATCH` on a field cannot change `data_type`. Its `options` array "replaces the entire existing set of options", and options sent without an `id` may be deleted and recreated ([REST docs, Issue fields (users)][rest-user-fields]).
- GraphQL has `createIssueType`, `updateIssueType`, `deleteIssueType`, `createIssueField`, `updateIssueField` and `deleteIssueField`. The create inputs take `ownerId`, and `UpdateIssueFieldInput` has no `dataType`. `User` has `issueTypes`, `issueFields` and `pinnedIssueFields` (tested 2026-11-27: introspection).
- Classic and OAuth tokens need `read:user` for GET and `user` for writes ([REST docs, Issue types (users)][rest-user-types]; [REST docs, Issue fields (users)][rest-user-fields]).
- Fine-grained tokens need the User permissions "Issue Types" or "Issue Fields". `GET /repos/{owner}/{repo}/issue-types` needs only repository Metadata read ([GitHub Docs, Fine-grained token permissions][docs-fg]).
- With the test token, `GET /user/issue-types` and `/user/issue-fields` returned 403 with `X-Accepted-Oauth-Scopes: read:user, user`. The body said "Must have admin rights to Repository." GraphQL `viewer{issueTypes}` returned FORBIDDEN (tested 2026-11-27: `gh api -i` and `gh api graphql`).
- No doc states the scopes for the GraphQL `User` fields or the type and field mutations.
- gh has no subcommand that defines types or fields (tested 2026-11-27: `gh issue --help`, gh 2.98.0).
- `IssueFieldVisibility.ORG_ONLY` "will be removed. Use RESTRICTED instead. Effective 2027-04-01" ([GraphQL changelog, 2026-11-11][gql-changelog]).
- `User.issueTypes` and `User.issueFields` were added on 2026-11-11. `MULTI_SELECT` was added to `IssueFieldDataType` on 2026-05-18 ([GraphQL changelog][gql-changelog]).
- Multi-select fields entered public preview on 2026-07-23 ([GitHub Changelog, 2026-07-23][cl-0723]). The entry of 2026-08-07 says "Multi-select fields in issues and projects are now generally available" ([GitHub Changelog, 2026-08-07][cl-0807]). The later entry wins.

## What is the "Relates to" issue relationship, does a personal-account repository have it, and can it be read and set by gh, REST or GraphQL?

- "Relates to" connects "two issues without implying that one blocks, duplicates, contains, or closes the other". It entered public preview on 2026-08-07 ([GitHub Changelog, 2026-08-07][cl-0807]).
- It became generally available on 2026-09-25 and "now works across the REST API, GraphQL API, webhooks, timeline events, issues search, and projects search". Neither post states a plan or account-type limit ([GitHub Changelog, 2026-09-25][cl-0925]).
- REST lists with `GET /repos/{owner}/{repo}/issues/{issue_number}/relates_to`. It adds with `POST …/relates_to` and a numeric `issue_id`, and removes with `DELETE …/relates_to/{issue_id}` ([REST docs, Issues][rest-issues]). The list endpoint returned 200 with a `repo` token (tested 2026-11-27: `gh api --method GET -i repos/cli/cli/issues/14467/relates_to`).
- GraphQL has `Issue.relatesTo` and the mutations `addRelatesTo` and `removeRelatesTo`, with `issueId` and `relatedIssueId` (tested 2026-11-27: introspection). They were added on 2026-09-28 ([GraphQL changelog][gql-changelog]).
- gh has no flag or JSON field for it, and the request is open ([cli/cli#14467][cli-14467]). Its 2026-09-17 claim that the API lacks the relationship predates the GA and the schema change.
- A `relatesTo` query on the test repository's issues was accepted but had no issues to read (tested 2026-11-27: `gh api graphql`). Inferred: a personal-account repository has the relationship, from the GA post naming no restriction and the accepted query. No issue in such a repository was read.

## Open questions

- Every write route is untested: status, types, fields, sub-issues, dependencies, "Relates to" and Project values. Each rests on docs and schema introspection, because the run sent no writes.
- No issue-level value was read on a personal-account repository, because the test repository has no issues. Status was read only on `github/docs`.
- Whether a fine-grained token can reach a Project owned by a user account: the fine-grained permissions page lists no such endpoint.
- No Project read was tested with `read:project`.
- Whether the gh 2.106.0 help for `gh issue` differs from 2.98.0. Only release notes were scanned, by keyword.
- Which REST API version GitHub applies when no header is sent. Only gh 2.98.0's 2022-11-28 was observed.
- Whether dependencies and "Relates to" may cross repositories or owners. The docs and REST pages read do not say.
- Whether closing as not planned or duplicate sets the matching status, as the docs say, or Done, as one user reports.

## Method

- The user confirmed the brief. Sub-questions 7, 8 and 9 were added after confirmation.
- Notes 1 covered the feature inventory, where each feature is defined, and limits.
- Notes 2 covered labels, milestones, assignees and close reason.
- Notes 3 covered issue types, issue fields, statuses and repository boards.
- Notes 4 covered sub-issues and dependencies.
- Notes 5 covered user-owned Projects and token scopes.
- Notes 6 covered reported problems.
- Notes 7 covered reading status, its effect on state, and Project sync.
- Notes 8 covered the account-level API for issue types and fields.
- Notes 9 covered "Relates to".
- All live checks were read-only `gh` calls on 2026-11-27, with gh 2.98.0 and a token scoped `gist`, `read:org`, `repo` and `workflow`. No write was sent and no Project was read.
- A source check on 2026-11-27 reopened the changelog entries, the REST, GraphQL and Docs pages, both discussions and the cited `cli/cli` issues, and reran the gh help, introspection and test-repository reads, the board-type schema search and the release-note scan. gh 2.106.0 is still the latest release, and the REST versions are unchanged. It narrowed the Answer's live-check claim and the label-defaults claim, said that #212151's author writes for the team rather than calling the author staff, corrected the dates of two discussion reports, and corrected how #14467 dates the blocked-by flags. Every section was covered except four sources that were not reopened: the two `cli/cli` source files at v2.106.0, the REST Project items page and the GraphQL Projects reference.

[cl-1111]: https://github.blog/changelog/2026-11-11-issue-types-and-fields-are-available-for-personal-accounts/
[cl-1123]: https://github.blog/changelog/2026-11-23-issue-statuses-and-repository-boards-are-in-public-preview/
[cl-dep]: https://github.blog/changelog/2025-08-21-dependencies-on-issues/
[cl-0610]: https://github.blog/changelog/2026-06-10-manage-sub-issues-types-and-dependencies-from-github-cli/
[cl-0723]: https://github.blog/changelog/2026-07-23-multi-select-fields-for-projects-and-issues-in-public-preview
[cl-0807]: https://github.blog/changelog/2026-08-06-connecting-issues-and-multi-select-field-support
[cl-0827]: https://github.blog/changelog/2026-08-27-label-archiving-is-generally-available
[cl-0925]: https://github.blog/changelog/2026-09-25-personal-saved-views-for-repository-issues-and-more/
[docs-labels]: https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/managing-labels
[docs-subissues]: https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues
[docs-deps]: https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/creating-issue-dependencies
[docs-status]: https://docs.github.com/en/issues/tracking-your-work-with-issues/learning-about-issues/about-issue-statuses
[docs-status-webhooks]: https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/issue-status-webhooks-and-workflows
[docs-automations]: https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-built-in-automations#enabling-issue-status-sync
[docs-search]: https://docs.github.com/en/search-github/searching-on-github/searching-issues-and-pull-requests#search-by-issue-status
[docs-projects-api]: https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-api-to-manage-projects
[docs-fg]: https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens
[rest-issues]: https://docs.github.com/en/rest/issues/issues
[rest-labels]: https://docs.github.com/en/rest/issues/labels
[rest-milestones]: https://docs.github.com/en/rest/issues/milestones
[rest-assignees]: https://docs.github.com/en/rest/issues/assignees
[rest-subissues]: https://docs.github.com/en/rest/issues/sub-issues
[rest-deps]: https://docs.github.com/en/rest/issues/issue-dependencies
[rest-planning]: https://docs.github.com/en/rest/repos/planning-statuses
[rest-user-types]: https://docs.github.com/en/rest/users/issue-types
[rest-user-fields]: https://docs.github.com/en/rest/users/issue-fields
[rest-proj-items]: https://docs.github.com/en/rest/projects/items
[rest-breaking]: https://docs.github.com/en/rest/about-the-rest-api/breaking-changes
[gql-issues]: https://docs.github.com/en/graphql/reference/issues
[gql-projects]: https://docs.github.com/en/graphql/reference/projects
[gql-changelog]: https://docs.github.com/en/graphql/overview/changelog
[d212171]: https://github.com/orgs/community/discussions/212171
[d212151]: https://github.com/orgs/community/discussions/212151
[classmethod]: https://dev.classmethod.jp/en/articles/github-issues-label-archiving/
[cli-14703]: https://github.com/cli/cli/issues/14703
[cli-13804]: https://github.com/cli/cli/issues/13804
[cli-14364]: https://github.com/cli/cli/issues/14364
[cli-14996]: https://github.com/cli/cli/issues/14996
[cli-14467]: https://github.com/cli/cli/issues/14467
[cli-8798]: https://github.com/cli/cli/issues/8798
[cli-13120]: https://github.com/cli/cli/issues/13120
[cli-13816]: https://github.com/cli/cli/issues/13816
[src-item-edit]: https://github.com/cli/cli/blob/v2.106.0/pkg/cmd/project/item-edit/item_edit.go
[src-field-create]: https://github.com/cli/cli/blob/v2.106.0/pkg/cmd/project/field-create/field_create.go
