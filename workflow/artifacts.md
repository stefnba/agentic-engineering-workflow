# Artifacts

Artifacts have one owner, answer one question, and live only as long as that question remains
useful. A bundle contains the minimum artifact set its shaping route requires.

## Authority

| Artifact                  | Question it owns                                                                    | It does not own                                           |
| ------------------------- | ----------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `work/backlog.md`         | What candidate work or follow-up remains unpicked?                                  | Priority, approval, or implementation scope               |
| Discovery evidence        | What did we observe or learn?                                                       | Commitment, priority, or implementation scope             |
| Intent artifact           | What outcome, behavior, constraints, and invariants did the human approve?          | Current implementation facts or interior design           |
| Engineering plan          | How will this repository realize and decompose the approved intent?                 | Behavior or requirements absent from intent               |
| Ticket                    | What may one agent change, what does it depend on, and what evidence makes it done? | Cross-ticket architecture or unapproved product decisions |
| PR and CI                 | What changed, what checks ran, what was reviewed, and what is the current state?    | Intent, decomposition, or durable system truth            |
| Durable system docs       | How is the shipped system intended to work now?                                     | In-flight plans or historical feature state               |
| Decision record           | Which durable, consequential choice was made and why?                               | Work status or step-by-step implementation                |
| `GLOSSARY.md`             | Which project-domain terms and rejected synonyms are canonical?                     | General programming or workflow-artifact terminology      |
| `AGENTS.md`               | Which repository or package conventions and gotchas must every agent follow?        | Domain behavior or workflows owned by linked documents    |
| `docs/conventions/git.md` | Which git conventions must a human follow here?                                     | Anything a script reads — that is `work/config.conf`      |
| `work/config.conf`        | Which settings do the workflow's scripts run with?                                  | Conventions no script consumes                            |
| `docs/research/`          | What durable reference did investigation establish?                                 | Evidence for one bundle, which lives with that bundle     |
| Git mechanics             | How are worktrees based, tickets claimed, and bundle branches created race-safely?  | Any value a repository declares for itself                |
| Agent prompt              | How does one role judge, act, escalate, and report within the loaded workflow?      | Lifecycle, artifact authority, or repository conventions  |

“Intent artifact” is a role, not one mandatory filename. It may be a feature spec, bug statement,
target architecture and invariants, migration objective, security requirements, or a ticket that
contains the complete intent for a small change. When one file plays both intent and ticket roles,
its sections must still keep approved behavior separate from execution instructions.

Discovery evidence is not always a file: a codebase scan's findings may live only in chat, triaged
live into a backlog line (accepted) or a decision record (rejected, so the same finding doesn't
resurface next scan) — see [Running the workflow](../docs/walkthrough.md) for the concrete mechanics.

## Conflict rules

Authority is axis-specific, not one global document hierarchy:

- **Approved outcome and observable behavior:** the intent artifact wins. A plan or ticket cannot
  override it.
- **Binding technical direction and decomposition:** the approved plan wins. A ticket may narrow the
  plan to one slice but cannot contradict it.
- **One slice's scope, dependencies, autonomy, and evidence:** the ticket wins within the approved
  intent and plan.
- **Execution and review state:** the PR and CI system win. Do not copy transient PR states into spec
  or plan metadata.
- **Candidate work:** the backlog owns unpicked follow-ups, but a line there grants no approval or
  priority; the Pick gate owns selection.
- **Repository operation:** `AGENTS.md` points agents to owning instructions, and the applicable
  convention document wins for its operation — see the Authority table above for each document's
  scope. In a monorepo, the nearest package `AGENTS.md` adds area-specific instructions to the root
  file. Tool-specific instruction files reference `AGENTS.md` rather than duplicating it.
- **Terminology:** the applicable `GLOSSARY.md` owns canonical project-domain terms and avoided
  synonyms. Agent prose and code identifiers use its canonical terms and never an avoided synonym;
  Review judges adherence without a separate mechanical gate. Workflow and artifact terms remain
  owned by their defining documents. If output and a glossary conflict, surface both readings instead
  of silently choosing one. A rename or redefinition edits the mutable glossary in place in the same
  PR and moves the former term to its Avoid list. In a monorepo, the closest domain glossary applies
  and the root glossary owns cross-domain vocabulary and links the domain glossaries. A repository
  without a glossary does not need one created solely for this workflow.
- **Decision history:** decision records are immutable. Supersede a decision with a new record; never
  edit the old record to make history look current.
- **Process versus prompt:** workflow, artifact, and repository convention documents outrank agent
  prompts. Prompts load those owners and contain only role-specific judgment, escalation, and output
  instructions.
- **Current system claims during active work:** durable colocated system docs outrank the bundle. If
  code or tests contradict those docs, surface the drift and reconcile it; never silently choose the
  bundle's version.
- **Shipped system:** code, tests, and durable docs replace the bundle. The bundle is not permanent
  documentation.

Correct factual drift in the artifact that owns the fact. A correction that changes approved
behavior, binding architecture, decomposition, security, migration, compatibility, or acceptance
criteria returns to the Plan gate.

## Bundle contents

A bundle is the disposable container for one coherent approved outcome. [Work bundles](./bundle.md)
owns Shape-completion criteria and ticket identity; [Shaping routes](./shaping-routes.md) owns which
artifacts a route requires and when to split sequential bundles.

## Status ownership

Under `work/`, commit artifact content — spec, plan, and ticket text. Derive execution state; never
store it.

```text
bundle: local draft → shaped → active → deleted at Ship
ticket: todo → doing → done
PR/CI:  implementation, checks, review, and merge state
```

- ticket `done`: its PR is merged into that ticket's target branch — the bundle branch for a
  multi-ticket bundle, otherwise the configured integration target.
- ticket `doing`: its ticket branch exists on the remote. It stays `doing` through Implement, Review,
  fixes, and human review.
- ticket `todo`: neither.
- bundle `shaped`: it exists under `work/bundles/` on the integration target with no ticket claimed.
  `active`: at least one ticket is no longer `todo`.

Claiming a ticket _is_ creating its branch, so git serializes parallel claims and a second claim on
the same ticket fails. Deleting an unmerged ticket branch and its worktree un-claims the ticket.
Nothing is written after a merge, so a human who merges the PR directly leaves exactly the state a
skill script would.

Do not persist `ready`, `implemented`, `verifying`, `blocked`, or `changes_requested` either. Unmet
ticket dependencies are derived from `depends_on`; an external blocker is raised on the PR or
escalated to the human, never recorded as ticket metadata that can go stale.

## Lifetime

- **Local draft:** unapproved and not shared as committed work.
- **Shaped:** critic-reviewed and human-approved; implementation may start.
- **Active:** at least one ticket has started.
- **Shipped:** every ticket is done, the outcome is on the integration target, and the bundle is
  deleted.

There is no `done/` or shipped-bundle archive. Git history preserves temporary artifacts.

Each implementation PR is the permanent historical bridge from the shipped change to its temporary
planning context. Its body must contain immutable commit permalinks to the complete approved bundle
and the exact ticket it implements. A branch-relative URL is not a permalink: it can drift or break
when Ship removes the bundle branch. The linked commit must remain reachable through merged PR or
integration-target history after branch cleanup. If a material change passes the Plan gate again,
update the PR links to that newly approved bundle version. On the direct ticket route, the bundle and
ticket links may intentionally point to the same file.

The PR is the main surface for implementation evidence, review findings, fix responses, and review
state. Its links do not transfer authority: the linked intent, plan, and ticket remain authoritative
while the work is active. PR comments are an execution log, not a second specification or durable
system documentation.

At Ship:

1. Move currently true system behavior into the owning durable documentation.
2. Move durable, consequential rationale into a decision record when it meets that bar.
3. Move unfinished or newly discovered work into the backlog.
4. Delete the complete bundle: intent/spec, plan, tickets, and bundle-local evidence.

**Never reference a disposable bundle from code, durable documentation, or comments — it will not
exist once Ship deletes it.**
