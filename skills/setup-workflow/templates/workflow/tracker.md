<!-- Fill every slot; delete these comments as you fill. -->

# Tracker

How the workflow skills create, find, claim and close work items. Written by the `setup-workflow` skill; edit by hand or rerun that skill.

Work items are GitHub issues in `{{OWNER}}/{{REPO}}`.

## Commands

| Action                                                               | Command                                                                                                                                       |
| -------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Create a feature or a small item                                     | `gh issue create --title "<title>" --body "<body>" --type "<type>" --label "<labels>"`                                                        |
| Create a ticket of a feature                                         | `gh issue create --title "<title>" --body "<body>" --type Task --label "<labels>" --parent <feature number>`                                  |
| List open work items                                                 | `gh issue list --state open`                                                                                                                  |
| Read a work item                                                     | `gh issue view <number> --comments`                                                                                                           |
| Claim a work item                                                    | `gh issue edit <number> --add-assignee @me`                                                                                                   |
| Find the open pull request of a work item                            | `gh pr list --state open --json number,headRefName`, then the one whose branch has the work item's number, as named in `docs/workflow/git.md` |
| Close a ticket after its pull request merges into the feature branch | `gh issue close <number>`                                                                                                                     |
| Close a feature or a small item                                      | `Closes #<number>` in the body of the pull request to the target branch                                                                       |

## Classification

- Type: Feature (work split into tickets), Task (one ticket or one small item), Bug.
- Priority label: `P0` drops other work, `P1` is next, `P2` is planned, `P3` is when time allows.
- Area label: one per row of `docs/workflow/areas.md`.
- Flag labels: `needs-decision` waits on an owner's decision, `blocked` waits on other work or an outside party.
<!-- Remove a line the owner declined, and drop `--type` from the commands
when the account has no issue types. Add labels the repository already uses
for the same purpose in place of these names, and confirm each meaning with
the owner. -->

## Status

Status is read from the tracker and never written anywhere else. **Take the first row that matches.**

| State     | How to tell                    |
| --------- | ------------------------------ |
| Done      | Closed                         |
| In review | Open, has an open pull request |
| Claimed   | Open, has an assignee          |
| Backlog   | Open, no assignee              |
