# Agentic engineering workflow: design draft, remainder

## 1. Problem

Existing workflows (Elephant-Goldfish Model, Matt Pocock's skills, Spec Kit, OpenSpec, Superpowers) work at feature level and assume the repo already gives the agent something to anchor on. In a greenfield repo that anchor is missing, so:

- agents make structural choices nobody decided, and those choices constrain later work;
- side observations turn into a long, unstructured backlog;
- temporary documents reference each other, go stale, and mislead later agents.

Goal: one workflow with two entry points. A greenfield repo writes the anchor; an existing repo extracts it from code. After that, both run the same loop.

## 2. Principles

Principles 2, 3, 4 and 7 assume work state in local files. They need a second look once the tracker is chosen.

1. **Undecided is a state.** Agents never resolve an open question implicitly. They stop and ask, or take the cheapest reversible option and log it.
2. **Knowledge and work state are separate.** `docs/` says what the project is. `work/` says what is undecided and what is next.
3. **References go one way.** Work state may reference docs. Docs never reference work state. Nothing outside a bundle references into it.
4. **Reference by ID, not by path.** `UC-3`, `Q-4`, `D-0007`. Paths are set once, in `work/config.yaml`; setup writes them into the `AGENTS.md` block and they appear nowhere else.
5. **Detail is written just in time.** Only work that is starting gets a full spec.
6. **Distill, then delete.** When work merges, lasting knowledge moves into `docs/` and the bundle is deleted.
7. **Agents capture, humans commit.** Agents may append to the inbox within limits (section 9). Only triage puts something in the backlog.
8. **Code is not precedent.** An agent may follow a pattern only if a decision record or the reviewed walking skeleton backs it.
9. **Procedure lives in the skills, facts live in the repo.** Workflow documentation is never copied into a consuming repo.

## 3. Repository artifacts

The `docs/` half is the knowledge layer that `workflow-design.md` assumes. The `work/` half applies only if work tracking stays in local files.

```text
README.md                  how to run and use it
AGENTS.md                  short managed block: paths, hard rules, which skill when
CLAUDE.md                  contains `@AGENTS.md` (Claude Code does not read AGENTS.md itself)
docs/                      knowledge: slow-changing, safe to publish
  PRODUCT.md               users, problem, core use cases (UC-n), non-goals
  GLOSSARY.md              domain terms
  ARCHITECTURE.md          current shape of the system
  decisions/NNNN-slug.md   decision records (D-n), append-only
work/                      work state: churns constantly
  BACKLOG.md               Next and Later
  INBOX.md                 raw one-line notes from agents
  OPEN_QUESTIONS.md        open questions (Q-n) and working assumptions (A-n)
  config.yaml              repo settings read by every skill
  bundles/<id>-<slug>/     one folder per piece of work in progress
    SPEC.md                problem, acceptance criteria, out of scope
    tickets/               vertical slices of the spec
```

| Artifact            | Kind        | How it evolves                                                                                                                                                                                                                                    |
| ------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `PRODUCT.md`        | living      | Shrinks to about half a page as architecture moves to decision records and use case detail moves into tests. Users, the one-line use case list and non-goals stay forever. May later become a Scope section in the README, keeping the `UC-` IDs. |
| `GLOSSARY.md`       | living      | Edited in place. Git holds the history.                                                                                                                                                                                                           |
| `ARCHITECTURE.md`   | living      | Starts near-empty. Describes the current state only.                                                                                                                                                                                              |
| `decisions/`        | append-only | Never edited. A new record supersedes an old one.                                                                                                                                                                                                 |
| `OPEN_QUESTIONS.md` | work state  | A question or assumption leaves when you decide it: it becomes a decision record if it passes the bar in section 9, and is simply removed otherwise.                                                                                              |
| `BACKLOG.md`        | work state  | Later: one line each, uncapped. Next: a paragraph each, max ~10.                                                                                                                                                                                  |
| `INBOX.md`          | work state  | Empty after every triage.                                                                                                                                                                                                                         |
| `bundles/`          | work state  | Exists only while the work is in progress. Max ~5 at once.                                                                                                                                                                                        |

"Now" is not a list. It is whatever folders exist in `work/bundles/`, so there is no shared index to keep in sync.

In a monorepo there is one `work/` at the root. A package gets its own `docs/` only if it has its own glossary or architecture.

## 4. Lifecycle

The steps that `workflow-design.md` does not yet cover in this detail:

| Step      | Trigger                 | What happens                                                                                                                                                                                                                                | Output                        |
| --------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| docs-init | once per repo           | Greenfield: the agent interviews you. Existing repo: the agent extracts from code and you correct it. Ends with a fresh-context check: a new session reads only `docs/` and must say what is being built, what is decided and what is open. | `docs/`, first open questions |
| capture   | any time, by agents     | Append one line about a side issue, within the limits in section 9. No fixing outside scope, no ticket.                                                                                                                                     | line in `INBOX.md`            |
| triage    | regularly, by you       | Each inbox line is deleted (the default), moved to Later or Next with a UC link, or turned into an open question.                                                                                                                           | empty inbox                   |
| kickoff   | when a Next item starts | Check active bundles for overlap. Interview. Confirm or change assumptions in the area. Resolve blocking questions into decisions. Write the spec and slice tickets.                                                                        | bundle, decision records      |
| close     | in the merging PR       | Distill lasting knowledge into `docs/`. Delete the bundle. Run the ID check.                                                                                                                                                                | updated docs, no bundle       |

A walking skeleton comes before feature work in a greenfield repo: one thin end-to-end slice, reviewed by hand, because agents copy its patterns. Undecided areas get throwaway spikes on branches; only the resulting decision record merges.

## 5. Multi-developer visibility with local files

This section applies only if work tracking stays in local files. With an issue tracker, the tracker gives the visibility.

The problem: a bundle that exists only on your machine or your branch is invisible to everyone else, unlike a GitHub issue.

Proposed solution: announce first, then work.

1. **Claim commit.** The first act of kickoff is a small commit pushed straight to `main` (or an auto-merged PR if the branch is protected). It contains only `work/bundles/<id>-<slug>/SPEC.md` as a stub with front matter: `owner`, `started`, `uc`, `status: claimed`.
2. **Draft PR.** The feature branch opens a draft PR at once. The spec evolves on the branch, so the PR shows its latest state, and the PR list is the live board.
3. **Status check.** A `status` skill, run by you or by kickoff, runs `git fetch` and lists the bundles on `origin/main` with owner and age. Kickoff runs it first and stops if a new bundle overlaps an active one.
4. **Collision-free IDs.** Use `YYMMDD-slug` or owner initials, not sequential numbers, since two developers would pick the same next number.
5. **Fewer merge conflicts.** `INBOX.md` and `BACKLOG.md` are line-based and use `merge=union` in `.gitattributes`. "Now" is derived from folders, so nobody edits a shared list.
6. **Removal.** The feature PR deletes the bundle, including the stub on `main`, when it merges.

Trade-off: `main` shows that a bundle exists and who owns it, but the current spec is on the branch. That is acceptable for one to a few developers.

Checks in CI:

- every `UC-`, `Q-`, `A-` and `D-` ID that is referenced exists, including `ASSUMPTION(A-n)` markers in code;
- nothing in `docs/` links into `work/`;
- no more than ~5 bundles, and none older than an agreed age.

## 6. Terminology review (challenged by a fresh-context subagent)

| Term                                                                            | Subagent verdict                                            | Recommendation                                                                                                                 | Status   |
| ------------------------------------------------------------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ | -------- |
| `work/`                                                                         | keep                                                        | keep                                                                                                                           | settled  |
| `bundles/`                                                                      | change to `active/`, call the unit an "item"                | keep `bundles/`: distinctive, easy to search, and it collides with nothing in GitHub or Claude Code. Define it in `AGENTS.md`. | **open** |
| `BRIEF.md`                                                                      | change to `PRODUCT.md`                                      | adopt: removes the clash with "work brief"                                                                                     | **open** |
| work brief                                                                      | drop; make it a Problem section in the spec                 | adopt                                                                                                                          | **open** |
| `adr/`                                                                          | change to `docs/decisions/`                                 | adopt: resolved questions include product decisions                                                                            | **open** |
| spec                                                                            | keep, name the file `SPEC.md`                               | adopt                                                                                                                          | settled  |
| ticket                                                                          | keep; state that tickets are local files, not GitHub issues | adopt                                                                                                                          | settled  |
| `BACKLOG.md`, `INBOX.md`, `OPEN_QUESTIONS.md`, `GLOSSARY.md`, `ARCHITECTURE.md` | keep                                                        | keep                                                                                                                           | settled  |
| Now / Next / Later                                                              | keep                                                        | keep, with Now derived from bundles                                                                                            | settled  |
| use case (UC)                                                                   | keep                                                        | keep                                                                                                                           | settled  |
| bootstrap                                                                       | change to `docs-init`                                       | adopt: avoids `script/bootstrap` and Claude Code's `/init`                                                                     | **open** |
| promote (Next to Now)                                                           | change to `kickoff`                                         | adopt, or `refine` if you prefer the Scrum word                                                                                | **open** |
| promote (knowledge into docs)                                                   | change to "distill"                                         | adopt, as a named step inside close                                                                                            | **open** |
| capture, triage, close                                                          | keep                                                        | keep                                                                                                                           | settled  |
| "temporary docs", "horizon"                                                     | change to "work state", "backlog section"                   | adopt                                                                                                                          | settled  |

Collisions the subagent found: "brief" used twice, "promote" used twice, "bundle" versus build bundles, "Now item" versus "bundle" as two names for one thing, "bootstrap" versus setup scripts, "spec" versus test spec files.

## 8. Reference repositories

The repository tables moved to `research/`. Three learnings are not yet reflected in `workflow-design.md`:

1. **None of them deletes work files.** OpenSpec archives and merges into living specs; the rest keep or accumulate. Spec drift after implementation is a common complaint. "Distill, then delete" is a deliberate departure, and OpenSpec's archive step is the alternative to weigh.
2. **Every tool uses a folder named after itself** (`.specify/`, `openspec/`, `.planning/`, `_bmad-output/`). Generic `docs/` and `work/` keep the repo independent of any one tool.
3. **Agents ignore long rule files.** Reported for Spec Kit's constitution. Keep `AGENTS.md` rules few and enforce the important ones in CI.

## 9. Settled, assumed, open: and keeping agents restrained

### Three states

| State           | Where                    | Who creates it                                     |
| --------------- | ------------------------ | -------------------------------------------------- |
| Decided (`D-n`) | `docs/decisions/`        | You approve; agents only propose                   |
| Assumed (`A-n`) | `work/OPEN_QUESTIONS.md` | Agent or you, to keep work moving; may change soon |
| Open (`Q-n`)    | `work/OPEN_QUESTIONS.md` | Anyone; blocks the work it names                   |

Each assumption records what was chosen, why, and what it would cost to change.

### Making hidden choices visible

- **Unspecified choices in every PR.** Each agent hand-back lists the choices it made that the spec did not cover, sorted by how hard they are to reverse. You mark each one accepted, assumed or rejected.
- **Marker in code.** `ASSUMPTION(A-12)` at the site. CI checks that the ID exists.
- **No building on assumptions.** Code marked as an assumption must not be extended or copied without asking.
- **Confirm at kickoff.** A new bundle that touches an area with assumptions makes you confirm or change them first.

### Limits on decision records

Agents never write a decision record. A record needs all three: it is hard to reverse, it affects more than one bundle, and a real alternative existed. Everything else is just code.

### Limits on the inbox

- A side issue inside the files being touched is fixed or dropped, not captured.
- A follow-up for the same use case becomes a ticket in the bundle, not a backlog item.
- Capture only a bug, a risk, or something that needs real effort. Cap: about two per ticket.
- Triage defaults to delete. Inbox lines expire after a set number of days.

## 10. Skill structure and distribution

The harness table, the shared-knowledge table and the `shared/` layout were removed. `research/cross-harness-support.md` and `research/knowledge-across-skills.md` replace them, and the second argues against a `shared/` build step.

### Distribution

- **Primary: one repo that is a plugin for both harnesses.** EGM and Superpowers already ship this way. Updates arrive through a version bump.
- **Fallback: `npx skills add`.** It works because every skill is self-contained.
- **Not a template repo.** A template cannot be updated after it is copied.
- Skill names carry a unique prefix, since Matt Pocock's repo records name collisions with harness built-ins.

### What setup writes into a consuming repo

1. Folders and stub files.
2. The config file: target branch, branch naming, ID format, caps, local files or GitHub issues, test, lint and typecheck commands, workflow version.
3. The managed block in `AGENTS.md`, and `CLAUDE.md` with the import if it is missing.
4. The CI check and `.gitattributes` entries.

It then detects greenfield or existing code and hands over to `docs-init`. Rerunning it repairs the repo and migrates it when the workflow version changes.

## 11. Decisions

### Settled

- Supported harnesses: Claude Code and Codex.

### Open: naming and structure

1. `bundles/`, `active/` or `changes/` (the OpenSpec term).
2. Delete bundles after distilling, or archive them as OpenSpec does.
3. `PRODUCT.md` or keep `BRIEF.md`.
4. `kickoff` or `refine` or keep `promote`.
5. Claim commit direct to `main`, or always through an auto-merged PR.
6. Bundle ID format.
7. Skill name prefix and the workflow's name.

### Open: still to brainstorm

1. **Verification.** What proves a ticket is done; which fast checks every agent runs; where non-functional requirements live.
2. **Human gates.** Which steps need approval; a budget for how much review you read.
3. **Routing by size.** Thresholds for trivial fix, single ticket and full bundle; a path for bugs and hotfixes.
4. **Greenfield specifics.** Reversible versus irreversible decisions; spikes; when a repo leaves greenfield mode.
5. **Git and parallel work.** Branch per bundle or per ticket; worktrees; slicing tickets so agents do not collide.
6. **Drift and learning.** Keeping `ARCHITECTURE.md` true; where repeated agent mistakes get fixed; a retro at close.
7. **Cadence and limits.** When triage happens; expiry for Later items; bundle age.
8. **Distribution details.** Update and migration policy; how much of the workflow the `AGENTS.md` block must carry.
9. **Measuring.** Rework after merge, bundle age, inbox growth, how often agents hit an open question.
