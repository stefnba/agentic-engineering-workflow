# Workflow design: current state

For the owner and any agent continuing the design: what is decided, assumed and open in the version 2 workflow.

Sources: the design session of 2026-11-26, the two drafts beside this file, an audit of the `v1-final` tag, and a study of the two main reference repositories. The files in `research/` were not yet read when this was written.

Each item starts with its state. **Decided** means the owner confirmed it. **Assumed** means it is good enough to build on and may change. **Open** means it still needs a decision, and the item says what would settle it.

## 1. Goal and users

- **Decided.** The product is a set of agent skills, installed into other repositories, for one loop: shape work, implement, review, ship.
- **Decided.** The main user is a solo developer. A team of up to about five must be able to use it without a redesign.
- **Decided.** It follows the practices larger teams use, such as pull requests, review and tests, without their overhead. It is not enterprise grade.
- **Decided.** The skills run under Claude Code and Codex.
- **Decided.** The main references are Matt Pocock's skills and the Elephant Goldfish Model.
- **Assumed.** The design joins the two: Pocock's implement and code review loop, a light form of Elephant Goldfish's fresh-context spec review, and a knowledge layer neither has.

## 2. Scripts and deterministic logic

- **Decided.** No scripts that encode the workflow itself, such as claim, publish or land. Version 1 had 10 such scripts with 944 lines, and 28 of their 30 commits fell within five days.
- **Decided.** A script is allowed where it clearly helps.
- **Assumed.** A step starts as prose with a few shell commands. It becomes a script only after agents fail at it.
- **Open.** Where exactly the line sits. `research/scripts-and-deterministic-logic.md` reports how seven reference repositories draw it.

## 3. Work tracking

- **Open.** GitHub issues or local Markdown files. The owner leans towards GitHub. A trial of one real feature and a few backlog items on plain issues would settle it.
  - For GitHub: labels, filtering, closing and assignment are built in, and nothing has to be synced between branches.
  - For local files: no network or login, and less to learn.
  - Against local files: the version 1 backlog was one Markdown file that grew fast and could not be labelled.
- **Assumed.** No skill names a tracker. Skills say "the work item", and the config file in the section "Knowledge in the consuming repository" says how to create, list, claim and close one.
- **Assumed.** Issues carry a small classification: a type (Feature, Bug, Task), a priority (P0 to P3), `area:*` labels, and the flags `needs-decision` and `blocked`.
- **Decided.** Status is derived from the state of the issue and its pull request. It is never stored a second time.
- **Open.** Whether "spec in progress" and "ready for work" need a label, a Project board, or nothing.
- **Open.** How an agent records a side finding. Proposed and not yet discussed: a new work item labelled `triage`, at most two per work item.

## 4. Work items, branches and worktrees

- **Decided.** Large work is a feature split into tickets. Each ticket is a vertical slice that can be tested and reviewed alone.
- **Decided.** Ticket pull requests merge into a feature branch. One final pull request lands the feature on the target branch, `main` or `dev`.
- **Decided.** The reason is abandonment: dropping a feature deletes one branch and leaves the target untouched.
- **Decided.** Small work has a shortcut that skips the spec and the feature branch.
- **Assumed.** One ticket is one branch, one worktree and one pull request, so tickets can run in parallel.
- **Assumed.** A worktree is made and removed by two `git worktree` commands written in the skill. The branch naming rule sits in the config file.
- **Assumed.** Claiming a work item means assigning it.
- **Assumed.** With GitHub, tickets are sub-issues of the feature issue. The skill closes a ticket by command after its pull request merges, because `Closes #N` works only on the default branch.
- **Assumed.** The shortcut is one work item, one branch and one pull request straight to the target.
- **Assumed.** The feature branch takes in the target before each new ticket starts. A feature older than about two weeks is split.
- **Open.** Whether the owner approves every ticket pull request or only the final one.
- **Open.** Where the spec lives: the body of the feature issue, or a file on the feature branch that is removed before the final merge.

## 5. Skills

- **Assumed.** The loop has the eight skills in the table below. The names and the split are not settled.
- **Decided.** `docs-init` is in scope from the start, for greenfield and for existing code.
- **Decided.** A human approves the spec and the merge.
- **Open.** Whether the interview and the shaping are two skills or one.

| Skill | Job |
|---|---|
| `setup` | Writes the config file and the `AGENTS.md` block |
| `docs-init` | Creates the knowledge docs by interview, or extracts them from code |
| `interview` | Questions the owner; used by `docs-init` and `shape` |
| `shape` | Turns the answers into a spec and tickets |
| `review-spec` | Reviews the spec before any code is written |
| `implement` | Builds one ticket in its own worktree, tests first |
| `review-code` | Reviews the diff of one ticket or one feature |
| `ship` | Opens the pull request, moves lasting knowledge into `docs/`, merges after approval |

## 6. Review and verification

- **Decided.** The spec gets a review and the code gets a review. They are separate skills.
- **Decided.** A review is done by a fresh sub-agent that sees only the artifact. If the harness has no sub-agents, the skill stops.
- **Open.** Which angles each review covers. `research/review-angles.md` is being written to answer this.
- **Open.** The definition of done. Proposed and not yet discussed: tests written first and passing, the repository's checks passing, no open finding of the top two severities, acceptance criteria met, docs updated, human approval.

## 7. Knowledge in the consuming repository

- **Assumed.** The repository keeps a small knowledge layer in `docs/`: product, glossary, architecture and decision records. The design draft describes it.
- **Assumed.** `setup` writes one config file that every skill reads. It is Markdown, and it holds facts only: target branch, branch naming, check commands, tracker commands, and the classification in use.
- **Assumed.** A short block in `AGENTS.md` points to that file, so an agent working without a skill still finds it.
- **Open.** The name and location of the config file.
- **Open.** How skills share text across harnesses and installers. `research/knowledge-across-skills.md` and `research/cross-harness-support.md` report on this.

## 8. Material still in the drafts

The two drafts hold detail this file has not yet taken a position on:

- `agentic-workflow-design.md`: the principles, the settled, assumed and open states for a consuming repository, the limits on decision records, the terminology review, and the distribution layout.
- `github-issues-workflow.md`: the full issue metadata, the repository conventions, the automations, and the elephant and goldfish hand-off.
- `BRIEF.md`: the tested harness facts. It stays as it is.
