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

Each label below has the meaning after its dash; that meaning is also its description on GitHub.

- Type: `Feature` — Work split into tickets. `Task` — One ticket or one small item. `Bug` — Behavior that is wrong.
<!-- When the account has no issue types, replace the Type line with these
type labels:
- `type:feature` — Work split into tickets
- `type:task` — One ticket or one small item
- `type:bug` — Behavior that is wrong
  and in the create commands replace `--type "<type>"` with
  `--label "<type label>,<labels>"` and `--type Task` with
  `--label "type:task,<labels>"`. -->
- `P0` — Drop other work and do this first
- `P1` — Next up after P0
- `P2` — Planned, after P1
- `P3` — When time allows
- `area:<area>` — Work in `<path>`, one per row of `docs/workflow/areas.md`
- `needs-decision` — Waits on a decision by the owner
- `blocked` — Waits on other work or an outside party
<!-- Remove a label the owner declined. Where the owner agreed to reuse an
existing label for the same purpose, write its name in place of the
template's. -->

**Give every work item one type, one priority and one area label.** Add a flag label only while the flag holds.

## Status

Status is read from the tracker and never written anywhere else. **Take the first row that matches.**

| State     | How to tell                    |
| --------- | ------------------------------ |
| Done      | Closed                         |
| In review | Open, has an open pull request |
| Claimed   | Open, has an assignee          |
| Backlog   | Open, no assignee              |
