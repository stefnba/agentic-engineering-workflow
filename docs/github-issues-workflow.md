# GitHub Issues Workflow for Agentic Engineering

Nov 25, 2026 · Stefan Bauer

## Summary

We use GitHub Issues as the backlog and lifecycle tracker, and temporary Markdown specs on feature branches for reviewable design work. Agents implement one task each, on task branches that merge into a feature branch, which merges into main.

**Settled so far:**

- One issue per work item, kept from backlog to done. No new issue is created for the final spec.
- A work item is a parent issue (type Feature); tickets are sub-issues (type Task), one PR each.
- The spec and plan live as Markdown on the feature branch only, and are deleted before the merge to main.
- The final spec is posted as a comment on the parent issue before the merge.
- Issue types and issue fields are available on the personal account and are used instead of type, priority and size labels.
- Stage is tracked in a Project Status field; labels only for things that can overlap.

Status of this doc: working assumptions, to be refined once the setup is in use.

## Operating model

One human orchestrates; one context-heavy agent per feature runs context-free sub-agents; nothing merges without human approval.

| Topic | Decision |
| --- | --- |
| Team size | Solo today; the workflow must also work for a small team without redesign |
| Agents | Codex and Claude Code, running locally |
| Worktrees | One git worktree per task branch, plus one for the feature branch |
| Choosing work | Human-led: triage backlog → choose → specify → critique the spec → approve spec and tickets → hand to an orchestrator. Agents never pick up work on their own |
| Implementation | Elephant/goldfish: one orchestrator agent per feature holds the context (elephant) and sends context-free sub-agents (goldfish) to implement or review one task each |
| Review | Agentic review with a review skill first, then human approval |
| Merge | Human gate: nothing merges without explicit human approval; a guardrail in the agent skills makes agents report back instead of merging |

## Where information lives

Status, ownership and discussion go in Issues; specs that describe the code go next to the code, temporarily.

| Information | Lives in | Why |
| --- | --- | --- |
| Backlog item, status, owner, priority | GitHub Issue + Project | Shared, mutable, no merge conflicts |
| Discussion before shaping | Issue comments | Searchable, tied to the item |
| Spec + plan while work is active | `specs/<issue#>-<slug>/` on the feature branch | Reviewable diffs, versioned with the code |
| Spec review and critique | Local review with the agent | Diffs of the committed spec on the feature branch |
| Final spec after merge | Comment on the parent issue | Permanent, searchable record |
| Durable design decisions | Short ADR or code comment | Closed issues are rarely read |
| Agent scratch notes | Ignored local file or PR comments | Never on main |

The Markdown spec is the source of truth only while the feature branch is alive. Before and after, the issue is.

## Work item lifecycle

One issue (e.g. #123) carries the work item from idea to merge; its number names the branch, the spec folder and the final PR.

1. **Backlog.** Issue created from the Backlog item form: type Feature, status Backlog, a few lines on the problem or goal. Loose brainstorming happens in issue comments.
2. **Shaping.** Create `feature/123-<slug>` and commit `specs/123-<slug>/intent.md` and `plan.md`. Critique and revisions happen locally with the agent; the spec gets no PR. Add "Spec in progress on feature/123-<slug>" to the issue body, keeping the original brief.
3. **Ready.** Spec approved, noted as a comment on the parent issue. Create one Task sub-issue per ticket from the plan, with blocked-by links where order matters.
4. **In progress.** Agents pick up Tasks, one branch and one PR each, targeting the feature branch.
5. **In review.** All tasks merged; the final PR `feature/123 → main` is open. Before merging: post the final spec as a comment on #123 ("Final spec, as implemented"), extract any durable decisions into an ADR, delete `specs/123-<slug>/`.
6. **Done.** The final PR merges and closes #123 and its sub-issues.

**Exceptions:**

- Small items skip Shaping: the issue body is the spec, and it goes straight to one PR.
- If shaping shows the item is really several features, create new issues for the extras and close or keep #123 with links ("split into #140, #141").

## Branching and PR model

Each task gets its own branch and PR into the feature branch; one final PR takes the feature to main.

```
main (or develop)
  ▲
  │  final PR · merge commit · closes the parent issue
  │
feature/123-slug  ◄── spec commit (intent.md + plan.md)
  ▲                    spec + plan live here, temporary
  │
  ├── task/124-slug   PR · squash   (bottom of a stack)
  │     ▲
  │     └── task/125-slug           (stacked on 124)
  │
  └── task/126-slug   PR · squash   (parallel to the stack)
```

The spec is committed first, tasks merge one by one into the feature branch, and the spec is gone before the final PR merges.

| Topic | Decision |
| --- | --- |
| Ticket → PR | One Task sub-issue = one branch = one PR, by one agent in its own worktree |
| Parallel tasks | Each branches off the feature branch and merges in any order |
| Sequential tasks | Native stacked PRs (`gh stack`, GA since Oct 2026); the bottom of the stack targets the feature branch |
| Task → feature merge | Squash: one clean commit per task |
| Feature → main merge | Merge commit: keeps one commit per task under the feature |
| Spec conflicts | Rare: each agent edits only its own section of the spec |
| Long-lived features | Merge or rebase main into the feature branch regularly; more than 1–2 weeks suggests splitting |

**Gotcha:** `Closes #N` only auto-closes when a PR merges into the default branch. Task PRs into the feature branch need an Action, a manual close, or all `Closes` lines repeated in the final PR.

**Alternative considered:** trunk-based, with task PRs straight to main behind feature flags. Rejected for now because features should not touch main until complete.

## Issue metadata

Rule of thumb: a value that can only be one thing at a time is a type, an issue field or the Status; things that can overlap are labels.

### Where each piece is defined

| Feature | Defined at | Per issue | Customizable |
| --- | --- | --- | --- |
| Issue types | Personal account (Settings → Planning) | One | Rename, add, color, pin fields per type; defaults Task, Bug, Feature |
| Issue fields | Personal account (Settings → Planning) | One value per field | Name, type (text, single select, number, date), visibility, pinned types |
| Status | Project field | One | Options fully editable; drives board columns and automations |
| Labels | Per repo | Many | Fully custom names, colors, descriptions |
| Milestones | Per repo | One | Title, description, due date only |
| Sub-issues, dependencies, assignees | Built in | — | Not configurable |

### Issue types

| Type | Description | Pinned fields |
| --- | --- | --- |
| Feature | Parent work item: owns spec and feature branch | Priority, Target date (optional) |
| Task | One ticket = one agent = one PR | Effort, Priority, Agent mode |
| Bug | Something is broken | Priority, Effort, Agent mode |
| Spike (new) | Time-boxed research ending in a decision, not code | Effort |
| Chore (new) | Maintenance, dependencies, CI; no user-facing change | Effort, Agent mode |

### Issue fields

| Field | Type | Options | Status |
| --- | --- | --- | --- |
| Priority | Single select | P0, P1, P2, P3 | Exists (default) |
| Effort | Single select | S, M, L (L = split it) | Exists (default); check options |
| Agent mode | Single select | Autonomous, Assisted, Human only | To create |
| Target date | Date | — | Optional; only if planning by dates |

Set field visibility so everyone with repo access (and agent tokens) can see the values. Pin each field only to the types where it matters.

### Status (Project field)

| Status | Meaning | Applies to |
| --- | --- | --- |
| Backlog | Idea captured, brief only | Features |
| Shaping | Spec and plan being written or reviewed | Features |
| Ready | Spec approved and broken down, can be picked up | Features, Tasks |
| In progress | Branch exists, work underway | Features, Tasks |
| In review | PR open, waiting for review | Features, Tasks |
| Done | Merged and closed | All |

No Blocked status: use blocked-by dependencies, plus the `blocked` label for external blockers. No Won't-do status: close as *not planned* or *duplicate*. Tasks are created directly in Ready.

### Labels (per repo)

| Family | Labels | Use |
| --- | --- | --- |
| Area | `area:api`, `area:ui`, `area:db`, `area:infra`, `area:auth` (mirror real components) | Which part of the codebase; can combine |
| Workflow flags | `needs-decision`, `needs-info`, `blocked` | States on top of a stage; can stack |
| Nature / risk | `breaking-change`, `security`, `tech-debt`, `performance` | Extra review attention |

Not labels: type, priority, size, agent mode (fields), status (Project), resolution (close reason), dependencies (links).

### Milestones

Only for releases or real deadlines (e.g. `v2.4`). Skipped if deploying continuously.

## Repo conventions

These live in the repo and make every issue, branch and PR predictable for people and agents.

| Convention | Value |
| --- | --- |
| Feature branch | `feature/123-<slug>` |
| Task branch | `task/124-<slug>` (never nest as `feature/123/124`: Git refs conflict) |
| Spec location | `specs/123-<slug>/intent.md` and `plan.md`, feature branch only |
| Issue forms | `.github/ISSUE_TEMPLATE/`: Backlog item, Task, Bug; `config.yml` disables blank issues |
| PR template | `Closes #N`, what changed, spec sections updated (yes/no), how it was verified |
| Rulesets | Protect `main` and `feature/*`: PR required, CI green, 1 approval for feature → main |
| Label definitions | `.github/labels.yml`, synced by an Action |
| Agent instructions | Workflow written in `AGENTS.md` / `CLAUDE.md` |

**Task issue form fields:** parent issue, what to build, acceptance criteria (checklist), likely files or areas, how to verify, related spec section. This is the agent's work order.

**AGENTS.md should state:**

- Branch naming and where the spec lives.
- Only pick up issues whose Agent mode is Autonomous (or Assisted with a human).
- Set status to In progress when starting.
- Update only your own spec section if the plan changes.
- Open the PR against the feature branch, never main.

## Automations

These automations remove the manual steps that are easy to forget.

| Automation | Trigger | Effect |
| --- | --- | --- |
| Project workflow: add | Issue added to Project | Status = Backlog |
| Project workflow: review / done | PR linked / item closed | Status = In review / Done |
| Close task on feature merge (Action) | PR merged into `feature/*` | Closes the linked sub-issue (`Closes #N` only works on the default branch) |
| Block specs on main (Action) | PR into `main` | Fails if `specs/` still exists |
| Post final spec (Action, optional) | Feature → main PR ready | Posts the spec as a comment on the parent issue |
| Label sync (Action) | Change to `.github/labels.yml` | Creates and updates repo labels |

## Decisions and open questions

Two questions are decided, two run on working assumptions, two are open and two are postponed.

**1. Which steps need a PR?** *Decided*

- Task → feature branch: PR.
- Feature → target branch: PR.
- Spec: no PR. It is committed to the feature branch, and its approval is noted on the parent issue.

**2. Which GitHub account do agents use?** *Postponed*

- For now, agents use your own account.
- Revisit when a team joins, or if GitHub itself should enforce approvals.

**3. How is "merge only after my approval" enforced?** *Decided*

- A guardrail in the agent skills: agents never merge on their own. They report back and wait for explicit approval.
- Fallback if the guardrail ever fails: a tool-level block on merge commands.

**4. What does spec approval mean, and how are later changes handled?** *Open, for later*

- Recommendation: approval = a comment on the parent issue + Status set to Ready + sub-issues created.
- Plan changes are allowed but must be noted. Intent changes pause the work until approved again.

**5. What does each agent get and hand back (elephant/goldfish)?** *Working assumption*

- A goldfish gets only its task issue, its spec section and its branch, and returns a PR or a review.
- The elephant holds spec, plan and dependencies, hands out tasks, integrates the work, and records progress in GitHub.

**6. What is the path for small work?** *Working assumption*

- One Task issue → one branch → one PR straight to the target branch.
- No spec file. For bugs, chores and small features that fit in one PR.

**7. Which branches: `dev` and `main`, or `main` only?** *Open*

- Likely setup: agent work goes to `dev`, releases go to `main`.
- `Closes #N` only works on the default branch. Either make `dev` the default, or let the release PR (`dev` → `main`) close the issues.

**8. What is the definition of done?** *Postponed*
