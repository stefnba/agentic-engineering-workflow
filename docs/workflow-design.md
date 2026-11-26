# Agentic Engineering Workflow: design and current state

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
- **Assumed.** A step starts as prose with a few shell commands. Both main references run their whole workflow this way, with no code at workflow time.
- **Assumed.** A step earns a script only when all four conditions hold. The test is a proposal of this document, drawn from practices reported in `research/scripts-and-deterministic-logic.md`.
  1. It has one right answer per input, and a unit test can check it.
  2. An agent was seen getting it wrong, or working it out again on every run.
  3. It reads state or guards a gate. The agent still makes the edit.
  4. It fits one file in one language and uses no harness variable.
- **Decided.** The workflow uses no hooks. Three of the reference repositories removed or sidelined theirs.
- **Open.** Whether a static check of the skills runs in CI: front matter parses, no tool names, no harness variables, links resolve.

## 3. Work tracking

- **Open.** GitHub issues or local Markdown files. The owner leans towards GitHub. A trial of one real feature and a few backlog items on plain issues would settle it.
  - For GitHub: labels, filtering, closing and assignment are built in, and nothing has to be synced between branches.
  - For local files: no network or login, and less to learn.
  - Against local files: the version 1 backlog was one Markdown file that grew fast and could not be labelled.
- **Assumed.** No skill names a tracker. Skills say "the work item", and `docs/workflow/tracker.md` says how to create, list, claim and close one.
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
- **Assumed.** A worktree is made and removed by two `git worktree` commands written in the skill. The branch naming rule sits in `docs/workflow/git.md`.
- **Assumed.** Claiming a work item means assigning it. None of the seven reference repositories scripts a claim.
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
- **Assumed.** A first draft of `setup` exists as `skills/setup-workflow/`. It is untested, and it supports GitHub issues only.

| Skill         | Job                                                                                  |
| ------------- | ------------------------------------------------------------------------------------ |
| `setup`       | Writes `docs/workflow/`, seeds `docs/conventions/`, and writes the `AGENTS.md` block |
| `docs-init`   | Creates the knowledge docs by interview, or extracts them from code                  |
| `interview`   | Questions the owner; used by `docs-init` and `shape`                                 |
| `shape`       | Turns the answers into a spec and tickets                                            |
| `review-spec` | Reviews the spec before any code is written                                          |
| `implement`   | Builds one ticket in its own worktree, tests first                                   |
| `review-code` | Reviews the diff of one ticket or one feature                                        |
| `ship`        | Opens the pull request, moves lasting knowledge into `docs/`, merges after approval  |

One skill text serves both harnesses. Five of the seven reference repositories work this way, and the rules below are proposals of this document, drawn from practices reported in `research/cross-harness-support.md`.

- **Assumed.** Front matter relies only on `name` and `description`, in strict YAML.
- **Assumed.** Skill text names the action and never a harness tool. It asks the user in plain chat.
- **Assumed.** A skill asks for a sub-agent in prose, as "a fresh context window", and ships no agent definition file.
- **Assumed.** A skill refers to another skill by bare name. Every skill stays callable by the model, because a user-only flag blocks calls from other skills.
- **Assumed.** Everything a skill reads sits inside its own folder, and no path uses a harness variable.
- **Open.** Whether Codex needs its own plugin manifest, and how it treats unknown front matter keys. The repositories disagree, so only a test run settles it.
- **Open.** Distribution: a plugin for both harnesses, `npx skills add`, or both.
- **Open.** Whether skill wording draws on the `v2-baseline` tag once the structure is settled. `AGENTS.md` allows reading the tags only when the owner asks.
  - `v1-final` holds the first version. `v2-baseline` holds the skill variants that evolved in three consuming repositories.
  - The `v2-baseline` wording was corrected against real agent failures.
  - `work/v2-skill-inventory.md` at that tag compares the variants and names what to cut.
  - To read it beside this tree: `git worktree add ../aew-baseline v2-baseline`.
- **Open.** Whether a session started inside a git worktree finds its skills. `research/harness-tests.md` lists it as untested, and the worktree per ticket depends on it.

## 6. Review and verification

- **Decided.** The spec gets a review and the code gets a review. They are separate skills.
- **Decided.** A review is done by a fresh sub-agent that sees only the artifact. If the harness has no sub-agents, the skill stops.
- **Open.** Which angles each review covers. The candidate below is a proposal of this document, drawn from the practices reported in `research/review-angles.md`. The owner has not reviewed it.
  - Spec review, reviewer with the spec only: can it restate the spec, and where must a builder guess.
  - Spec review, reviewer with the spec and the repository: scope and simplicity, risks and failure modes, fit with the existing code and test coverage of each requirement.
  - Code review: spec compliance, correctness of the diff, tests that prove the behaviour, repository rules, simplicity.
  - Code review, only when the change touches them: security and operations that cannot be undone.
  - Ticket pull request: one fresh reviewer with two separate verdicts, spec first, then quality.
  - Final pull request: one reviewer with the spec, and one blind reviewer with only the diff and the repository.
- **Open.** When small work may skip the spec review. The candidate rule below is a proposal of this document and untested. Every line must hold:
  - It fits one ticket and one pull request.
  - It changes no public interface, data schema or stored format.
  - It touches no authentication, payment, secret or destructive operation, and a revert undoes it.
  - It adds no concurrency.
  - It rests on no unverified assumption about an external system.
  - Its intended behaviour and its check fit in two sentences. The code reviewer treats those sentences as the spec.
- **Open.** The number of review rounds, who sorts the findings, and the severity scale.
- **Open.** The definition of done. Proposed and not yet discussed: tests written first and passing, the repository's checks passing, no open finding of the top two severities, acceptance criteria met, docs updated, human approval.

## 7. Knowledge in the consuming repository

- **Assumed.** The repository keeps a small knowledge layer in `docs/`: product, glossary, architecture and decision records. The design draft describes it.
- **Decided.** The facts the workflow skills read live in `docs/workflow/`, as Markdown, one file per topic: `git.md`, `areas.md`, `tracker.md` and `models.md`. `setup` writes them. They mean nothing without the workflow, and `work/` is not used for them.
- **Decided.** The repository's own rules live in `docs/conventions/`: `git.md` for commits, scopes, pull request titles and ordinary branches, and `naming.md` for files and folders. They outlive the workflow. `setup` writes a file there only when it is missing and never changes an existing one.
- **Assumed.** Each fact lives in one of the two folders. Workflow branch names sit in `docs/workflow/git.md`, and `docs/conventions/git.md` defers to it.
- **Assumed.** `models.md` has one row per kind of work and one column per harness, because Claude Code and Codex name models differently.
- **Assumed.** Each skill that needs a file in `docs/workflow/` says what to do when it is missing: tell the user to run `setup`.
- **Assumed.** A short block in the instruction file of each harness, `AGENTS.md` and `CLAUDE.md`, names each file in both folders with the work it covers. A block in one file alone leaves the other harness without it.
- **Assumed.** The skill that writes an artifact owns its format. Other skills name the artifact and do not restate the format.
- **Assumed.** No shared folder beside the skills and no build step that copies text into them. Text two skills need sits in one skill, and the other invokes that skill. `research/knowledge-across-skills.md` shows shared folders breaking under skills-only installs in four repositories.
- **Open.** How `setup` migrates a repository after the workflow changes. No prose-driven setup among the references does.

A monorepo needs no logic of its own in any skill. These items cover it:

- **Assumed.** One tracker serves the whole repository. Each app has one `area:*` label, and a feature that spans apps is one feature issue whose tickets carry different labels.
- **Assumed.** `docs/workflow/areas.md` has an areas table: one row per app with its path, label, check commands and own docs folder. A single-app repository has one row.
- **Assumed.** `implement` and `review-code` read the row for the area of their ticket.
- **Assumed.** Product and decision records live at the root only. The glossary lives at the root, unless two apps use one word differently.
- **Assumed.** Architecture has a root overview. An app gets its own architecture doc only when it has its own shape.
- **Assumed.** A monorepo gets the skills copied into the repository. `research/harness-tests.md` shows a project plugin in Claude Code loading only from the repository root.

## 8. Material still in the drafts

The drafts were pruned on 2026-11-26 of everything this file covers. They hold detail this file has not yet taken a position on:

- `agentic-workflow-design.md`: the problem statement, the principles, the artifacts of the knowledge layer and of the local-files option, the terminology review, the rules for assumptions, decision records and the inbox, and topics still to brainstorm.
- `github-issues-workflow.md`: the lifecycle on GitHub, merge strategies, the full issue metadata, the repository conventions, the automations, and five open questions.

The former `BRIEF.md` is now `research/harness-tests.md`. It holds the harness behaviour tested here on 2026-09-30, and what stays untested.
