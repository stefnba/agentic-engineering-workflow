# Agentic Engineering Workflow: design and current state

Each item starts with its state. **Decided** means the owner confirmed it. **Assumed** means it is good enough to build on and may change. **Open** means it still needs a decision, and the item says what would settle it.

## 1. Goal and users

- **Decided.** The product is a set of agent skills, installed into other repositories, for one loop: shape work, implement, review, ship.
- **Decided.** The main user is a solo developer. A team of up to about five must be able to use it without a redesign.
- **Decided.** It follows the practices larger teams use, such as pull requests, review and tests, without their overhead. It is not enterprise grade.
- **Decided.** The skills run under Claude Code and Codex.
- **Decided.** The main references are Matt Pocock's skills and the Elephant Goldfish Model.
- **Assumed.** The design joins the two: Pocock's implement and code review loop, a light form of Elephant Goldfish's fresh-context spec review, and a knowledge layer neither has.
- **Assumed.** The knowledge layer solves this problem. The reference workflows assume the repository already gives the agent something to anchor on. In a greenfield repository that anchor is missing, so:
  - agents make structural choices nobody decided, and those choices constrain later work;
  - side observations turn into a long, unstructured backlog;
  - temporary documents reference each other, go stale, and mislead later agents.
- **Decided.** One loop has two entry points. A greenfield repository writes its knowledge docs, and an existing one extracts them from code.

## 2. Scripts and deterministic logic

- **Decided.** No scripts that encode the workflow itself, such as claim, publish or land. Version 1 had 10 such scripts with 944 lines, and 28 of their 30 commits fell within five days.
- **Decided.** A script is allowed where it clearly helps.
- **Assumed.** A step starts as prose with a few shell commands. Both main references run their whole workflow this way, with no code at workflow time.
- **Assumed.** A step earns a script only when all four conditions hold. The test is a proposal of this document, drawn from practices reported in `research/archive/scripts-and-deterministic-logic.md`.
  1. It has one right answer per input, and a unit test can check it.
  2. An agent was seen getting it wrong, or working it out again on every run.
  3. It reads state or guards a gate. The agent still makes the edit.
  4. It fits one file in one language and uses no harness variable.
- **Decided.** The workflow uses no hooks. Three of the reference repositories removed or sidelined theirs.
- **Open.** Whether a static check of the skills runs in CI: front matter parses, no tool names, no harness variables, links resolve.

## 3. Work tracking

- **Decided.** GitHub issues hold the backlog and the work items. `research/archive/work-tracking-options.md` keeps the arguments and the consequences.
- **Open.** Whether local files are supported later. Section 11 keeps that option's design.
- **Assumed.** No skill names a tracker. Skills say "the work item", and `docs/workflow/tracker.md` says how to create, list, claim and close one.
- **Assumed.** Issues carry a small classification: a type (Feature, Bug, Task), a priority (P0 to P3), `area:*` labels, and the flags `needs-decision` and `blocked`.
- **Assumed.** A value that can hold only one thing at a time is an issue type or an issue field. Things that can overlap are labels.
- **Open.** Whether type and priority are issue fields or labels. The GitHub draft used issue types and fields. GitHub ships Priority (Urgent, High, Medium, Low), Effort, Start date and Target date as default fields. The `setup-workflow` templates write `P0` to `P3` as labels, with type labels as a fallback when the account has no issue types. Since 2026-11-11 every account, personal or organization, has issue types and fields.
- **Assumed.** Issue types and issue fields are defined on the account, personal or organization, under Settings → Planning. Labels are defined per repository. Field visibility matters only in public repositories. [`research/0001-github-native-issue-tracking.md`](research/0001-github-native-issue-tracking.md) holds the facts about each GitHub feature, researched on 2026-11-27.

- **Open.** Whether the classification grows. The GitHub draft proposed:
  - the types Spike (time-boxed research ending in a decision) and Chore (maintenance with no user-facing change);
  - the fields Effort (S, M, L, where L means split it), Agent mode (Autonomous, Assisted, Human only) and an optional Target date;
  - an agent works only on an item whose Agent mode is Autonomous, or Assisted with the owner present;
  - each field pinned only to the types where it matters, such as Effort, Priority and Agent mode on a Task;
  - the flag `needs-info`, and the risk labels `breaking-change`, `security`, `tech-debt` and `performance` for extra review attention.
- **Assumed.** No blocked status and no won't-do status. Order between tickets uses blocked-by links, an outside blocker gets the `blocked` label, and dropped work closes as _not planned_ or _duplicate_.
- **Assumed.** Milestones only for releases or real deadlines.
- **Assumed.** The owner chooses the work. An agent never picks up a work item on its own.
- **Decided.** Status is derived from the state of the issue and its pull request. It is never stored a second time.
- **Open.** Whether the tracker reads GitHub's native issue status instead, in public preview since 2026-11-23. Its fixed set has no Shaping or Ready, and `gh` cannot set it yet. [`research/0001-github-native-issue-tracking.md`](research/0001-github-native-issue-tracking.md) has the facts, in its sections on issue status.
- **Open.** Whether "spec in progress" and "ready for work" need a label, a Project board, or nothing.
  - The GitHub draft proposed a Project Status field: Backlog, Shaping, Ready, In progress, In review, Done. It would store status a second time.
  - Project workflows would then set Backlog when an issue is added, In review when a pull request links, and Done on close.
  - Another proposal: the feature issue body says "Spec in progress on `feature/123-<slug>`" during shaping.
- **Open.** Which GitHub account agents use. For now it is the owner's. Revisit when a team joins, or when GitHub itself should enforce approvals.
- **Assumed.** Docs never link to a work item. A work item may link to docs.
- **Open.** Whether `setup` writes issue forms (Backlog item, Task, Bug, with blank issues disabled), a pull request template, and `.github/labels.yml` synced by an Action. The proposed template holds `Closes #N`, what changed, whether spec sections changed, and how it was verified.
- **Open.** How an agent records a side finding. Proposed and not yet discussed: a new work item labelled `triage`, at most two per work item. Only the owner's triage moves it into the backlog, linked to a use case. GSD's capture step, which writes todos to local files, is a precedent. The first draft added these limits:
  - A side issue inside the files being touched is fixed or dropped, not recorded.
  - A follow-up for the same use case becomes a ticket of the current feature.
  - Only a bug, a risk, or something that needs real effort is recorded.
  - Triage deletes by default, and an untriaged finding expires after a set number of days.
- **Assumed.** Discussion before shaping happens in the comments of the work item. Agent scratch notes stay in an ignored local file or in pull request comments, never on the target branch.

## 4. Work items, branches and worktrees

The branch model for a feature, with the spec as a file on the feature branch, which is still open below:

```text
main (or dev)
  ▲
  │  final pull request · merge commit · closes the feature issue
  │
feature/123-slug  ◄── spec commit (intent.md + plan.md), removed before the final merge
  ▲
  ├── task/124-slug   pull request · squash   (bottom of a stack, if stacks are used)
  │     ▲
  │     └── task/125-slug                    (stacked on 124)
  │
  └── task/126-slug   pull request · squash   (parallel, merges in any order)
```

- **Decided.** Large work is a feature split into tickets. Each ticket is a vertical slice that can be tested and reviewed alone.
- **Decided.** Ticket pull requests merge into a feature branch. One final pull request lands the feature on the target branch, `main` or `dev`.
- **Open.** Whether agent work targets `dev`, with releases going from `dev` to `main`. If so, `dev` becomes the default branch, or the release pull request closes the issues.
- **Decided.** The reason is abandonment: dropping a feature deletes one branch and leaves the target untouched.
- **Assumed.** Trunk-based work behind feature flags is rejected. A feature touches the target only when it is complete.
- **Decided.** Small work has a shortcut that skips the spec and the feature branch. The reference tools draw complaints about token cost and ceremony on small changes. Elephant Goldfish's lite mode and BMAD's Quick Flow are precedents.
- **Assumed.** One ticket is one branch, one worktree and one pull request, so tickets can run in parallel.
- **Assumed.** The feature branch has its own worktree too.
- **Assumed.** One issue carries a work item from backlog to done. Its number names the branch, the spec folder and the final pull request, and no new issue is created for the final spec.
- **Assumed.** A ticket is the agent's work order. It names its parent, what to build, the acceptance criteria as a checklist, the likely files, how to verify, and its spec section.
- **Assumed.** A worktree is made and removed by two `git worktree` commands written in the skill. The branch naming rule sits in `docs/workflow/git.md`.
- **Assumed.** A ticket branch never nests under its feature branch, as `feature/123/124` would. Git cannot hold both refs.
- **Assumed.** A ticket squashes into the feature branch. The feature lands with a merge commit, which keeps one commit per ticket.
- **Open.** Whether dependent tickets use stacked pull requests (`gh stack`), with the bottom of the stack on the feature branch. Its availability is not verified.
- **Assumed.** Claiming a work item means assigning it. None of the seven reference repositories scripts a claim.
- **Assumed.** Tickets are sub-issues of the feature issue. The skill closes a ticket by command after its pull request merges, because `Closes #N` works only on the default branch.
- **Assumed.** Each ticket edits only its own section of the spec, so spec conflicts between tickets stay rare.
- **Assumed.** When shaping shows that a work item is several features, each extra feature gets a new issue. The original issue links to them, as "split into #140, #141", and stays open or closes.
- **Assumed.** The shortcut is one work item, one branch and one pull request straight to the target. The issue body is its spec.
- **Assumed.** The feature branch takes in the target before each new ticket starts. A feature older than about two weeks is split.
- **Open.** Whether the owner approves every ticket pull request or only the final one. The GitHub draft had every merge wait for the owner.
- **Open.** Whether rulesets protect the target and `feature/*`: a pull request, green checks, and one approval for the final pull request.
- **Decided.** The spec gets no pull request of its own. The owner's approval is recorded on the feature issue.
- **Open.** Where the spec lives: the body of the feature issue, or a file on the feature branch that is removed before the final merge. The GitHub draft proposed the file:
  - The spec sits in `specs/123-<slug>/`, as `intent.md` and `plan.md`.
  - The owner reviews the diffs of the spec's commits.
  - The file is the source of truth only while the branch lives. Before and after, the issue is.
  - Before the final merge, the spec is posted on the feature issue as "Final spec, as implemented". An optional Action could post it.
  - An Action fails a pull request into the target while `specs/` still exists.

## 5. Skills

The loop end to end, as the items below assume it. The issue state is derived, never stored.

| Step                | Trigger                     | Skill                  | Result                                                    | Issue state      |
| ------------------- | --------------------------- | ---------------------- | --------------------------------------------------------- | ---------------- |
| Set up              | once per repository         | `setup`                | `docs/workflow/`, `docs/conventions/`, instruction blocks | —                |
| Write the knowledge | once, after setup           | `docs-init`            | `docs/`, first open questions                             | —                |
| Capture             | any time                    | the owner, or `triage` | a feature, bug or task issue                              | Backlog          |
| Choose and shape    | the owner picks an item     | `interview`, `shape`   | spec, ticket sub-issues                                   | Claimed          |
| Review the spec     | spec written                | `review-spec`          | findings; the owner approves the spec                     | Claimed          |
| Build a ticket      | per ticket, in parallel     | `implement`            | code, tests, the list of choices the spec did not cover   | Claimed          |
| Review the code     | per ticket, and per feature | `review-code`          | findings                                                  | In review        |
| Ship                | review passed               | `ship`                 | lasting knowledge in `docs/`; merge after the owner's yes | Done when merged |

- **Assumed.** The loop has the skills in the table below. The names and the split are not settled.
- **Assumed.** Most skills wrap existing ones: `docs-init` and `interview` come from Pocock's grilling skills, `shape` from his `to-spec` and `to-tickets`, `implement` from his `tdd`, and `review-spec` from the Elephant Goldfish review. Pocock's skills now use `GLOSSARY.md`, formerly `CONTEXT.md`.
- **Open.** Where the map of the workflow lives. The first draft had a small router skill, so each other skill stated only its own inputs, outputs and next step. Its `capture`, `triage` and `status` skills are not in the table either.
- **Assumed.** `setup` detects greenfield or existing code and hands over to `docs-init`.
- **Assumed.** `docs-init` ends with a fresh-context check. A new session reads only `docs/` and must say what is being built, what is decided and what is open.
- **Decided.** `docs-init` is in scope from the start, for greenfield and for existing code.
  - A subagent survey of 2026-11-25 found no reference repository that treats the two as entry points to one loop. It is not in `research/`.
  - Spec Kit, GSD and BMAD start greenfield and add a step that documents existing code. OpenSpec, the Elephant Goldfish Model and Pocock assume code exists.
- **Assumed.** Both modes write the same files. Only the source of each file differs, and brownfield still needs the interview, because code cannot show the vision, the users or the reasons behind a choice.
- **Assumed.** Greenfield interviews, then writes. Brownfield reads the existing docs, extracts from code, then interviews to fill the gaps and confirm what it extracted.
- **Assumed.** A decision found in code stays marked as observed until the owner confirms it, because code is not precedent.

| File              | Greenfield                                    | Brownfield                                                               |
| ----------------- | --------------------------------------------- | ------------------------------------------------------------------------ |
| `PROJECT.md`      | Interview                                     | Interview, with existing READMEs and docs as a first draft to confirm    |
| `ARCHITECTURE.md` | Near-empty; filled after the walking skeleton | Extracted from code, each claim citing `[file:symbol]`                   |
| `GLOSSARY.md`     | Interview, as terms come up                   | Terms from code names; the interview confirms what they mean             |
| Decision records  | Interview; only the choices the owner settles | Proposed from code and existing docs, marked as observed until confirmed |
| `research/`       | Not written by `docs-init`                    | Not written by `docs-init`                                               |

- **Assumed.** Only work that is starting gets a full spec.
- **Assumed.** Before writing the spec, `shape` checks the work in progress for overlap. It has the owner confirm or change the assumptions in the area, and turns blocking questions into decisions.
- **Open.** Whether `ship` deletes the spec after moving lasting knowledge into `docs/`, or archives it as OpenSpec does. The first draft chose deletion.
  - None of the reference repositories deletes work files. OpenSpec moves a change to `changes/archive/` and updates its living specs, and GSD archives each phase.
  - The Elephant Goldfish Model keeps approved specs and checks them for drift. Spec Kit lets the team choose, and BMAD documents no archive step.
  - Spec drift after implementation is a common complaint.
- **Decided.** A human approves the spec and the merge.
- **Decided.** Agents never merge on their own. They report back and wait for approval. If that guardrail fails, a tool-level block on merge commands is the fallback.
- **Open.** What spec approval means. Proposed in the GitHub draft: a comment on the feature issue, and the tickets created. A change to the plan is noted. A change to the intent pauses the work until the owner approves again.
- **Open.** Whether one orchestrator session per feature holds the context and hands each ticket to a fresh sub-agent, as the GitHub draft proposed. The orchestrator would hold spec, plan and dependencies, integrate the work and record progress on GitHub. A sub-agent would return a pull request or a review.
- **Open.** What `implement` reads. The first draft gave it `docs/` and its bundle. The GitHub draft gave it only its ticket, its spec section and its branch.
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

One skill text serves both harnesses. Five of the seven reference repositories work this way, and the rules below are proposals of this document, drawn from practices reported in `research/archive/cross-harness-support.md`.

- **Assumed.** Front matter relies only on `name` and `description`, in strict YAML.
- **Assumed.** Skill text names the action and never a harness tool. It asks the user in plain chat.
- **Assumed.** A skill asks for a sub-agent in prose, as "a fresh context window", and ships no agent definition file.
- **Assumed.** A skill refers to another skill by bare name. Every skill stays callable by the model, because a user-only flag blocks calls from other skills. This drops the first draft's plan to keep Codex from running `setup` unasked.
- **Open.** Whether a skill may depend on invoking another. The first draft ruled it out, because plugin namespaces differ between the harnesses. The rule on shared text in section 7 relies on it.
- **Assumed.** Everything a skill reads sits inside its own folder, and no path uses a harness variable.
- **Open.** Whether Codex needs its own plugin manifest, and how it treats unknown front matter keys. The repositories disagree, so only a test run settles it.
- **Open.** Distribution: a plugin for both harnesses, `npx skills add`, or both. The first draft made the plugin primary, with updates through a version bump, and `npx skills add` the fallback.
- **Assumed.** The workflow is not a template repository. A template cannot be updated after it is copied.
- **Open.** The skill name prefix, the workflow's name, and step names such as "distill" for moving lasting knowledge into `docs/`. A unique prefix avoids collisions with harness built-ins, which Pocock's repository records.
- **Open.** Whether skill wording draws on the `v2-baseline` tag once the structure is settled. `AGENTS.md` allows reading the tags only when the owner asks.
  - `v1-final` holds the first version. `v2-baseline` holds the skill variants that evolved in three consuming repositories.
  - The `v2-baseline` wording was corrected against real agent failures.
  - `work/v2-skill-inventory.md` at that tag compares the variants and names what to cut.
  - To read it beside this tree: `git worktree add ../aew-baseline v2-baseline`.
- **Open.** Whether a session started inside a git worktree finds its skills. `research/archive/harness-tests.md` lists it as untested, and the worktree per ticket depends on it.

## 6. Review and verification

- **Decided.** The spec gets a review and the code gets a review. They are separate skills.
- **Decided.** A review is done by a fresh sub-agent that sees only the artifact. If the harness has no sub-agents, the skill stops.
- **Open.** Which angles each review covers. The candidate below is a proposal of this document, drawn from the practices reported in `research/archive/review-angles.md`. The owner has not reviewed it. The first draft kept each reviewer persona as a file in the review skill's `references/`.
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

A consuming repository after `setup` and `docs-init`:

```text
AGENTS.md                  block naming the files in docs/workflow/ and docs/conventions/
CLAUDE.md                  the same block, for Claude Code
docs/                      knowledge: slow-changing, safe to publish
  PROJECT.md               vision, users, problem, constraints, core use cases (UC-n), non-goals
  GLOSSARY.md              domain terms
  ARCHITECTURE.md          current shape of the system
  decisions/NNNN-slug.md   decision records (D-n), append-only
  research/                research notes on outside facts
  workflow/                facts the workflow skills read: git.md, areas.md, tracker.md, models.md
  conventions/             the repository's own rules: git.md, naming.md
.worktrees/                one worktree per ticket, ignored by git
```

- **Assumed.** The repository keeps a small knowledge layer in `docs/`, in the files below.
- **Assumed.** Docs name a use case or a decision by its ID, such as `UC-3` or `D-0007`, not by its path.
- **Assumed.** The folders have generic names, `docs/` and not a name of this workflow. Every reference tool uses a folder named after itself, such as `.specify/` or `openspec/`, which ties the repository to that tool.
- **Decided.** The knowledge files are `PROJECT.md`, `GLOSSARY.md`, `ARCHITECTURE.md`, the decision records and `research/`. GSD's `REQUIREMENTS.md` and `STATE.md` are left out. Status is derived from GitHub, and the detailed plan lives in its issues and milestones.
- **Decided.** The project file is named `PROJECT.md`. The name fits a library, a tool or a service as well as an app, and GSD uses it for the same content. `PRODUCT.md` reads oddly outside apps, and `BRIEF.md` clashed with "work brief".
- **Assumed.** `PROJECT.md` may end with a high-level roadmap of a few lines: Now, Next and Later. A separate `ROADMAP.md` would repeat the milestones and drift from them.
- **Open.** The folder name `docs/decisions/` or `adr/`. A fresh-context terminology review recommended `docs/decisions/`, because decisions include product decisions. The same review renamed bootstrap to `docs-init`, to avoid `script/bootstrap` and Claude Code's `/init`. It also flagged "spec" as clashing with test spec files.

| File                     | Holds                                                                                        | How it changes                                                                                                                                                                                                     |
| ------------------------ | -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `PROJECT.md`             | Vision, users, problem, constraints, core use cases (`UC-n`), non-goals, an optional roadmap | Shrinks to about half a page as architecture moves to decision records and use case detail into tests. Users, the one-line use case list and non-goals stay. May become a README section that keeps the `UC-` IDs. |
| `GLOSSARY.md`            | Domain terms                                                                                 | Edited in place. Git holds the history.                                                                                                                                                                            |
| `ARCHITECTURE.md`        | The current shape of the system                                                              | Starts near-empty and describes the current state only.                                                                                                                                                            |
| `decisions/NNNN-slug.md` | Decision records (`D-n`)                                                                     | Never edited. A new record supersedes an old one.                                                                                                                                                                  |
| `research/`              | Research notes on outside facts, such as other tools or platform features                    | One note per question, with its sources and the date it was checked.                                                                                                                                               |

- **Decided.** The facts the workflow skills read live in `docs/workflow/`, as Markdown, one file per topic: `git.md`, `areas.md`, `tracker.md` and `models.md`. `setup` writes them. They mean nothing without the workflow, and `work/` is not used for them.
- **Assumed.** Procedure lives in the skills, and facts live in the repository. Workflow documentation is never copied into a consuming repository.
- **Assumed.** A repository fact, such as a path or a check command, is set once in `docs/workflow/`. Skills name the file that holds it, not the value.
- **Decided.** The repository's own rules live in `docs/conventions/`: `git.md` for commits, scopes, pull request titles and ordinary branches, and `naming.md` for files and folders. They outlive the workflow. `setup` writes a file there only when it is missing and never changes an existing one.
- **Assumed.** Each fact lives in one of the two folders. Workflow branch names sit in `docs/workflow/git.md`, and `docs/conventions/git.md` defers to it.
- **Assumed.** `models.md` has one row per kind of work and one column per harness, because Claude Code and Codex name models differently.
- **Assumed.** Each skill that needs a file in `docs/workflow/` says what to do when it is missing: tell the user to run `setup`.
- **Assumed.** A short block in `AGENTS.md` names each file in both folders with the work it covers. `CLAUDE.md` imports `AGENTS.md` with the line `@AGENTS.md`, because Claude Code does not read `AGENTS.md` itself.
- **Open.** Whether the block also carries the rules that hold when no skill runs. The first draft gave it about 15 lines. Agents ignore long rule files, as reported for Spec Kit's constitution, so the important rules belong in CI.
- **Assumed.** The skill that writes an artifact owns its format. Other skills name the artifact and do not restate the format.
- **Assumed.** No shared folder beside the skills and no build step that copies text into them. Text two skills need sits in one skill, and the other invokes that skill. `research/archive/knowledge-across-skills.md` shows shared folders breaking under skills-only installs in four repositories.
- **Open.** How `setup` migrates a repository after the workflow changes. No prose-driven setup among the references does. Migration needs a recorded workflow version, and no file in `docs/workflow/` holds one yet.

A monorepo needs no logic of its own in any skill. These items cover it:

- **Assumed.** One tracker serves the whole repository. Each app has one `area:*` label, and a feature that spans apps is one feature issue whose tickets carry different labels.
- **Assumed.** `docs/workflow/areas.md` has an areas table: one row per app with its path, label, check commands and own docs folder. A single-app repository has one row.
- **Assumed.** `implement` and `review-code` read the row for the area of their ticket.
- **Assumed.** Product and decision records live at the root only. The glossary lives at the root, unless two apps use one word differently.
- **Assumed.** Architecture has a root overview. An app gets its own architecture doc only when it has its own shape.
- **Assumed.** A monorepo gets the skills copied into the repository. `research/archive/harness-tests.md` shows a project plugin in Claude Code loading only from the repository root.

## 8. Earlier drafts

Two drafts were folded into this file and `research/archive/work-tracking-options.md` on 2026-11-26, then removed. "The first draft" and "the GitHub draft" in this file refer to them. Git keeps both:

- The first draft: `git show 8d178f3:docs/agentic-workflow-design.md`.
- The GitHub draft: `git show 8168e7a:docs/github-issues-workflow.md`.

The former `BRIEF.md` is now `research/archive/harness-tests.md`. It holds the harness behaviour tested here on 2026-09-30, and what stays untested.

## 9. Keeping agents restrained

- **Assumed.** Undecided is a state. An agent never resolves an open question silently. It stops and asks, or takes the cheapest reversible option and records it as an assumption.
- **Assumed.** Code is not precedent. An agent follows a pattern only if a decision record or the reviewed walking skeleton backs it.
- **Assumed.** A greenfield repository builds a walking skeleton before feature work: one thin end-to-end slice, reviewed by hand, because agents copy its patterns.
- **Assumed.** An undecided area gets a throwaway spike on a branch. Only the resulting decision record merges.
- **Assumed.** Every agent hand-back lists the choices it made that the spec did not cover, sorted by how hard they are to reverse. The owner marks each one accepted, assumed or rejected.
- **Assumed.** Agents only propose decision records. A record needs all three: the choice is hard to reverse, it affects more than one feature, and a real alternative existed. Everything else is just code.
- **Assumed.** A durable decision goes into a short decision record or a code comment, not only into an issue, because closed issues are rarely read.
- **Assumed.** Each assumption records what was chosen, why, and what it would cost to change. Code built on an assumption is not extended or copied without asking.
- **Assumed.** An open question that blocks work is a work item flagged `needs-decision`.
- **Open.** Where assumptions live, and how code marks them. The local-files option in section 11 keeps them in `work/OPEN_QUESTIONS.md`, with `ASSUMPTION(A-n)` markers in code.

## 10. Still to brainstorm

- **Open.** Verification: which fast checks every agent runs, and where non-functional requirements live.
- **Open.** Human gates: a budget for how much review the owner reads.
- **Open.** Routing by size: whether a trivial fix needs a work item at all, and a path for bugs and hotfixes. The first draft had three tiers: trivial fix, single ticket, and full feature.
- **Open.** Greenfield specifics: reversible versus irreversible decisions, spikes, and when a repository leaves greenfield mode.
- **Open.** Parallel work: slicing tickets so parallel agents do not collide.
- **Open.** Drift and learning: keeping `ARCHITECTURE.md` true, where repeated agent mistakes get fixed, and a retro when a feature ships.
- **Open.** Cadence and limits: when triage happens, when an old backlog item expires, and a limit on features in progress. The first draft capped work in progress at about 5, with an age check in CI.
- **Open.** Updates: how a consuming repository takes in a new version of the workflow.
- **Open.** Measuring: rework after merge, feature age, growth of untriaged findings, and how often agents hit an open question.

## 11. Local-files option

- **Open.** Whether local files are supported later. This section keeps the first draft's design for that case. It is not built, and nothing below is decided.

The skills that exist would keep working, since they say "the work item" and read `docs/workflow/tracker.md` for the commands. The option would add the `capture`, `triage` and `status` skills and the claim commit.

What support would add:

- `tracker.md` would describe the file operations for create, list, claim and close.
- `setup` would write `work/` and the `.gitattributes` entries, and the CI check for IDs and bundle limits.
- The claim commit and the `status` skill would make bundles visible to other developers.

### Principles of this option

- **Knowledge and work state are separate.** `docs/` says what the project is. `work/` says what is undecided and what is next.
- **References go one way.** Work state may reference docs. Docs never reference work state. Nothing outside a bundle references into it.
- **Agents capture, humans commit.** Agents may append to the inbox. Only triage puts something in the backlog.

### The `work/` folder

`research/archive/work-tracking-options.md` shows the folder tree and how each file evolves.

"Now" is not a list. It is whatever folders exist in `work/bundles/`, so there is no shared index to keep in sync. A monorepo has one `work/` at the root.

Each assumption gets an `ASSUMPTION(A-n)` marker at its site in code. A new bundle that touches an area with assumptions makes you confirm or change them first.

### Steps of this option

The option adds capture, triage, kickoff and close around the loop. `research/archive/work-tracking-options.md` shows them as a table.

### Visibility for several developers

A bundle that exists only on your machine or your branch is invisible to everyone else, unlike a GitHub issue. The proposed solution is to announce first, then work:

1. **Claim commit.** The first act of kickoff is a small commit pushed straight to `main`, the one exception to features touching the target only when complete, or an auto-merged PR if the branch is protected. It contains only `work/bundles/<id>-<slug>/SPEC.md` as a stub with front matter: `owner`, `started`, `uc`, `status: claimed`.
2. **Draft PR.** The feature branch opens a draft PR at once. The spec evolves on the branch, so the PR shows its latest state, and the PR list is the live board.
3. **Status check.** A `status` skill runs `git fetch` and lists the bundles on `origin/main` with owner and age. Kickoff runs it first and stops if a new bundle overlaps an active one.
4. **Collision-free IDs.** Use `YYMMDD-slug` or owner initials, not sequential numbers, since two developers would pick the same next number.
5. **Fewer merge conflicts.** `INBOX.md` and `BACKLOG.md` are line-based and use `merge=union` in `.gitattributes`.
6. **Removal.** The feature PR deletes the bundle, including the stub on `main`, when it merges.

The trade-off: `main` shows that a bundle exists and who owns it, but the current spec is on the branch. That is acceptable for one to a few developers. An earlier idea, one thin issue per bundle holding only title, owner and bundle ID, remains if the PR list proves too weak as a board.

Checks in CI:

- every `UC-`, `Q-`, `A-` and `D-` ID that is referenced exists, including the `ASSUMPTION(A-n)` markers;
- nothing in `docs/` links into `work/`;
- no more than about 5 bundles, and none older than an agreed age.

### Terms of this option

A fresh-context sub-agent reviewed the terms. Its verdicts on the terms only this option uses:

| Term                                          | Verdict                                      | Recommendation                                                                                      | Status   |
| --------------------------------------------- | -------------------------------------------- | --------------------------------------------------------------------------------------------------- | -------- |
| `work/`                                       | keep                                         | keep                                                                                                | settled  |
| `bundles/`                                    | change to `active/`, call the unit an "item" | keep `bundles/`: distinctive, easy to search, and it collides with nothing in GitHub or Claude Code | **open** |
| `BACKLOG.md`, `INBOX.md`, `OPEN_QUESTIONS.md` | keep                                         | keep                                                                                                | settled  |
| Now / Next / Later                            | keep                                         | keep, with Now derived from bundles                                                                 | settled  |
| promote (Next to Now)                         | change to `kickoff`                          | adopt, or `refine` if you prefer the Scrum word                                                     | **open** |
| capture, triage, close                        | keep                                         | keep                                                                                                | settled  |
| "temporary docs", "horizon"                   | change to "work state", "backlog section"    | adopt                                                                                               | settled  |

It also found two collisions: "bundle" versus build bundles, and "Now item" versus "bundle" as two names for one thing.

### Open questions of this option

1. `bundles/`, `active/` or `changes/`, the OpenSpec term.
2. Claim commit straight to `main`, or always through an auto-merged PR.
3. The bundle ID format.
