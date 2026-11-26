# Agentic engineering workflow: design summary

Status: working draft, updated 2026-11-26. Terms follow the recommendations in section 6; the ones still open are marked there.

## 1. Problem

Existing workflows (Elephant-Goldfish Model, Matt Pocock's skills, Spec Kit, OpenSpec, Superpowers) work at feature level and assume the repo already gives the agent something to anchor on. In a greenfield repo that anchor is missing, so:

- agents make structural choices nobody decided, and those choices constrain later work;
- side observations turn into a long, unstructured backlog;
- temporary documents reference each other, go stale, and mislead later agents.

Goal: one workflow with two entry points. A greenfield repo writes the anchor; an existing repo extracts it from code. After that, both run the same loop.

## 2. Principles

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

```
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

| Artifact | Kind | How it evolves |
|---|---|---|
| `PRODUCT.md` | living | Shrinks to about half a page as architecture moves to decision records and use case detail moves into tests. Users, the one-line use case list and non-goals stay forever. May later become a Scope section in the README, keeping the `UC-` IDs. |
| `GLOSSARY.md` | living | Edited in place. Git holds the history. |
| `ARCHITECTURE.md` | living | Starts near-empty. Describes the current state only. |
| `decisions/` | append-only | Never edited. A new record supersedes an old one. |
| `OPEN_QUESTIONS.md` | work state | A question or assumption leaves when you decide it: it becomes a decision record if it passes the bar in section 9, and is simply removed otherwise. |
| `BACKLOG.md` | work state | Later: one line each, uncapped. Next: a paragraph each, max ~10. |
| `INBOX.md` | work state | Empty after every triage. |
| `bundles/` | work state | Exists only while the work is in progress. Max ~5 at once. |

"Now" is not a list. It is whatever folders exist in `work/bundles/`, so there is no shared index to keep in sync.

In a monorepo there is one `work/` at the root. A package gets its own `docs/` only if it has its own glossary or architecture.

## 4. Lifecycle

| Step | Trigger | What happens | Output |
|---|---|---|---|
| 0a. setup | once per repo; rerun to repair or migrate | Create folders, stubs, config, the `AGENTS.md` block and the CI check (section 10). | repo scaffold |
| 0b. docs-init | once per repo | Greenfield: the agent interviews you. Existing repo: the agent extracts from code and you correct it. Ends with a fresh-context check: a new session reads only `docs/` and must say what is being built, what is decided and what is open. | `docs/`, first open questions |
| 1. capture | any time, by agents | Append one line about a side issue, within the limits in section 9. No fixing outside scope, no ticket. | line in `INBOX.md` |
| 2. triage | regularly, by you | Each inbox line is deleted (the default), moved to Later or Next with a UC link, or turned into an open question. | empty inbox |
| 3. kickoff | when a Next item starts | Check active bundles for overlap. Interview. Confirm or change assumptions in the area. Resolve blocking questions into decisions. Write the spec and slice tickets. Announce the bundle (section 5). | bundle, decision records |
| 4. review | before coding | Fresh-context agents read only `docs/` and the bundle, and challenge the spec. | revised `SPEC.md` |
| 5. implement | per ticket | A fresh agent reads `docs/` plus its bundle. The hand-back lists every choice the spec did not cover (section 9). | code, tests, list of choices |
| 6. close | in the merging PR | Distill lasting knowledge into `docs/`. Delete the bundle. Run the ID check. | updated docs, no bundle |

A walking skeleton comes before feature work in a greenfield repo: one thin end-to-end slice, reviewed by hand, because agents copy its patterns. Undecided areas get throwaway spikes on branches; only the resulting decision record merges.

## 5. Multi-developer visibility with local files

The problem: a bundle that exists only on your machine or your branch is invisible to everyone else, unlike a GitHub issue.

Proposed solution: announce first, then work.

1. **Claim commit.** The first act of kickoff is a small commit pushed straight to `main` (or an auto-merged PR if the branch is protected). It contains only `work/bundles/<id>-<slug>/SPEC.md` as a stub with front matter: `owner`, `started`, `uc`, `status: claimed`.
2. **Draft PR.** The feature branch opens a draft PR at once. The spec evolves on the branch, so the PR shows its latest state, and the PR list is the live board.
3. **Status check.** A `status` skill, run by you or by kickoff (not by a hook, see section 10), runs `git fetch` and lists the bundles on `origin/main` with owner and age. Kickoff runs it first and stops if a new bundle overlaps an active one.
4. **Collision-free IDs.** Use `YYMMDD-slug` or owner initials, not sequential numbers, since two developers would pick the same next number.
5. **Fewer merge conflicts.** `INBOX.md` and `BACKLOG.md` are line-based and use `merge=union` in `.gitattributes`. "Now" is derived from folders, so nobody edits a shared list.
6. **Removal.** The feature PR deletes the bundle, including the stub on `main`, when it merges.

Trade-off: `main` shows that a bundle exists and who owns it, but the current spec is on the branch. That is acceptable for one to a few developers. Move coordination to GitHub issues when the team passes about four developers or when non-developers need to follow the work.

### Local files or GitHub issues

| | Bundles as local files | GitHub issues |
|---|---|---|
| For | Agents read them with no API, login or network. The spec is versioned with the code and shows in the same PR. A folder suits a spec plus tickets. | Closing removes them from view. Assignment and discussion are built in. Nothing goes stale in the repo. |
| Against | Nothing closes by itself, so deletion must be enforced. No assignment or notifications. Shared files can conflict. | Agents need GitHub access, which sandboxed runs often lack. Spec edits are not diffable with the code. Long specs in issue bodies get messy. |

Current choice: local files, made visible by the claim commit and draft PR. An earlier idea, one thin issue per bundle holding only title, owner and bundle ID, remains an option if the PR list proves too weak as a board.

Checks in CI:
- every `UC-`, `Q-`, `A-` and `D-` ID that is referenced exists, including `ASSUMPTION(A-n)` markers in code;
- nothing in `docs/` links into `work/`;
- no more than ~5 bundles, and none older than an agreed age.

## 6. Terminology review (challenged by a fresh-context subagent)

| Term | Subagent verdict | Recommendation | Status |
|---|---|---|---|
| `work/` | keep | keep | settled |
| `bundles/` | change to `active/`, call the unit an "item" | keep `bundles/`: distinctive, easy to search, and it collides with nothing in GitHub or Claude Code. Define it in `AGENTS.md`. | **open** |
| `BRIEF.md` | change to `PRODUCT.md` | adopt: removes the clash with "work brief" | **open** |
| work brief | drop; make it a Problem section in the spec | adopt | **open** |
| `adr/` | change to `docs/decisions/` | adopt: resolved questions include product decisions | **open** |
| spec | keep, name the file `SPEC.md` | adopt | settled |
| ticket | keep; state that tickets are local files, not GitHub issues | adopt | settled |
| `BACKLOG.md`, `INBOX.md`, `OPEN_QUESTIONS.md`, `GLOSSARY.md`, `ARCHITECTURE.md` | keep | keep | settled |
| Now / Next / Later | keep | keep, with Now derived from bundles | settled |
| use case (UC) | keep | keep | settled |
| bootstrap | change to `docs-init` | adopt: avoids `script/bootstrap` and Claude Code's `/init` | **open** |
| promote (Next to Now) | change to `kickoff` | adopt, or `refine` if you prefer the Scrum word | **open** |
| promote (knowledge into docs) | change to "distill" | adopt, as a named step inside close | **open** |
| capture, triage, close | keep | keep | settled |
| "temporary docs", "horizon" | change to "work state", "backlog section" | adopt | settled |

Collisions the subagent found: "brief" used twice, "promote" used twice, "bundle" versus build bundles, "Now item" versus "bundle" as two names for one thing, "bootstrap" versus setup scripts, "spec" versus test spec files.

## 7. Skills

| Skill | Purpose | Borrowed from |
|---|---|---|
| router | Explain the workflow map and point to the right skill for a situation | Superpowers' and OpenSpec's router skills |
| `setup` | Create folders, stubs, config and the `AGENTS.md` block; safe to rerun for repair and migration | Pocock's setup skill |
| `docs-init` | Create or extract `docs/` | Pocock's grilling skills |
| `capture` | Append to the inbox, nothing else | new |
| `triage` | Empty the inbox into delete / Later / Next / open question | Pocock's triage |
| `status` | Fetch and list active bundles with owner and age | new |
| `kickoff` | Next item to bundle: interview, decisions, spec, tickets, claim commit | Pocock's to-spec and to-tickets |
| `review-spec` | Fresh-context reviewers challenge the spec | EGM goldfish review |
| `implement` | One ticket, one fresh agent, tests first | Pocock's tdd |
| `close` | Distill, delete the bundle, run the ID check | new |

The new parts are small: `capture`, `status`, `close`, and the rules in `AGENTS.md`. The rest wraps skills that already exist.

## 8. Reference repositories

Researched by a subagent on 2026-11-25. Star counts are the rounded figures it read from each GitHub page that day; I have not re-checked them.

| Repo | Stars | Core idea | Where work files live | After merge | Greenfield / existing |
|---|---|---|---|---|---|
| mattpocock/skills | 329k | Small composable skills: grill, spec, tickets, TDD, review | Issue tracker chosen at setup (GitHub, GitLab or local files); `GLOSSARY.md` and ADRs in repo | Nothing long-lived in repo | Leans existing code |
| obra/superpowers | 321k | Auto-triggering skills that force design, plan, TDD and review | `docs/superpowers/specs/` and `plans/`, dated files | Accumulate (inferred) | No separate modes |
| github/spec-kit | 146k | Constitution, spec, plan and tasks as chained markdown | `.specify/` plus one folder per feature | Kept; team picks a persistence model | Greenfield first |
| Fission-AI/OpenSpec | 73k | One folder per change, folded into living specs on archive | `openspec/specs/` and `openspec/changes/<name>/` | Moved to `changes/archive/`, main specs updated | Existing code first |
| get-shit-done (archived June 2026; continues as open-gsd/gsd-core, 11.8k) | 64k | Phase loop with fresh-context subagents | `.planning/` with project, requirements, roadmap, state, phases | Phase archived | Greenfield first |
| bmad-code-org/BMAD-METHOD | 55k | Role-based agents running an agile lifecycle | `_bmad-output/` with PRD, architecture, epics, stories | No archive step documented | Both |
| google/elephant-goldfish-model | 22.6k | Context-rich session drafts, fresh subagents review | `docs/designs/` for approved specs | Kept, checked for drift | Leans existing code |

Runners-up: claude-task-master (28.3k), EveryInc compound-engineering-plugin (26.2k).

Two corrections to what we assumed earlier: Matt Pocock's skills now use `GLOSSARY.md` (formerly `CONTEXT.md`) and the skills are named `to-spec` and `to-tickets` (formerly `to-prd` and `to-issues`).

### Learnings for this design

1. **None of them deletes work files.** OpenSpec archives and merges into living specs; the rest keep or accumulate. Spec drift after implementation is a common complaint. "Distill, then delete" is a deliberate departure, and OpenSpec's archive step is the alternative to weigh.
2. **OpenSpec's `changes/<name>/` is our bundle.** That makes "change" a third candidate name alongside `bundles/` and `active/`, and one that developers may already know.
3. **Multi-developer visibility is the weakest area everywhere.** Work in progress is visible only through committed folders, branches or PRs. OpenSpec's open change folders come closest, which supports the claim-commit idea in section 5.
4. **The greenfield / existing-code split is real.** Spec Kit, GSD and BMAD start greenfield and add a "document the codebase" step. OpenSpec, EGM and Pocock assume code exists. No repo treats both as entry points to one loop.
5. **Every tool uses a folder named after itself** (`.specify/`, `openspec/`, `.planning/`, `_bmad-output/`). Generic `docs/` and `work/` keep the repo independent of any one tool.
6. **Shared complaints: token cost and too much ceremony for small changes.** This design needs a small-change path that skips the bundle, as EGM's lite mode and BMAD's Quick Flow do.
7. **Agents ignore long rule files.** Reported for Spec Kit's constitution. Keep `AGENTS.md` rules few and enforce the important ones in CI.
8. **GSD has a capture step** that writes todos and seeds to local files, which is the same idea as the inbox.

### How they install and share knowledge

From a second subagent report (2026-11-25), which read each repo's files directly but ran no installer.

| Repo | Distribution | Writes to your repo | How skills share knowledge |
|---|---|---|---|
| mattpocock/skills | Plugin on both harnesses; `npx skills add` as fallback | Only via its setup skill: `docs/agents/*.md` and a block in `AGENTS.md` or `CLAUDE.md` | Repo docs written by setup; small skills called by name |
| obra/superpowers | Plugin on both; the Codex copy is produced by a sync script | Nothing at install | A bootstrap skill, injected by a session-start hook on Claude Code only |
| github/spec-kit | CLI (`specify init` with an integration flag) | `.specify/` plus generated skills | Templates, scripts and the constitution copied into the repo |
| Fission-AI/OpenSpec | CLI (`openspec init`) | `openspec/` plus generated skills | The CLI serves instructions at run time; a router skill |
| google/elephant-goldfish-model | Plugin on both, several manifests in one repo | Nothing at install | Plugin-root `resources/` read by relative path; breaks under skills-only installers |
| open-gsd/gsd-core | `npx` installer with a flag per harness; also a Claude plugin | `.planning/` created by its workflows | Thin skills that include shared workflow files; paths rewritten per harness |
| BMAD-METHOD | v7: `npx skills add`; v6: its own installer | `_bmad/` config and scripts | A shared render script in the repo |

What this adds to the design:

- Every one of them has a setup step that writes a small config file into the repo.
- Hooks are the least portable part: Superpowers ships none on Codex and GSD ships one.
- Managed blocks in `AGENTS.md` are falling out of favour; OpenSpec removed its own. Ours must stay very short.
- OpenSpec once had skills stall on other agents because they named Claude-only tools, so skill text must be harness-neutral.
- Only tools that write files into the repo need a migration step. That applies to this design because of `work/config.yaml` and the `AGENTS.md` block.

Sources: github.com/mattpocock/skills, github.com/obra/superpowers, github.com/github/spec-kit, github.com/Fission-AI/OpenSpec, github.com/gsd-build/get-shit-done, github.com/open-gsd/gsd-core, github.com/bmad-code-org/BMAD-METHOD, github.com/google/elephant-goldfish-model.

## 9. Settled, assumed, open: and keeping agents restrained

### Three states

| State | Where | Who creates it |
|---|---|---|
| Decided (`D-n`) | `docs/decisions/` | You approve; agents only propose |
| Assumed (`A-n`) | `work/OPEN_QUESTIONS.md` | Agent or you, to keep work moving; may change soon |
| Open (`Q-n`) | `work/OPEN_QUESTIONS.md` | Anyone; blocks the work it names |

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

Supported harnesses: Claude Code and Codex. Findings below are from two subagent reports of 2026-11-25, based on the official docs and the repos' own files; I have not re-verified them.

### What the harnesses allow

| Capability | Claude Code | Codex | Consequence |
|---|---|---|---|
| `SKILL.md` with `name`, `description` | yes, plus many extra fields | yes; extras go in `agents/openai.yaml` | Front matter is limited to `name` and `description` |
| Project skill path | `.claude/skills/` | `.agents/skills/` | No shared path; the installer handles it |
| Files outside the skill folder | only inside the plugin root | not documented | Skills must be self-contained |
| Always-loaded file | `CLAUDE.md` | `AGENTS.md` | `CLAUDE.md` imports `AGENTS.md` |
| Session-start hooks | yes | yes, but need user trust; plugins with hooks are kept out of the public directory | No hooks in the core |
| Subagent definitions | Markdown | TOML | Not portable; ask for a fresh subagent in prose |
| Explicit invocation | `/name` | `$name` | Skill text says "run the X skill", never a slash command |
| `npx skills add` | copies each skill folder only | same | Anything shared between skills is lost |

### Where shared knowledge lives

There is no common base that skills reference at run time. Each kind of shared knowledge has one home:

| Kind | Home | Why |
|---|---|---|
| Repo facts (paths, target branch, commands) | `work/config.yaml` in the consuming repo | Read by every skill; nothing to duplicate |
| Rules that apply even when no skill is running | Managed block in `AGENTS.md`, about 15 lines | The only place that reaches an agent doing ad hoc work |
| Artifact formats (spec, ticket, decision record) | The one skill that writes that artifact | Readers need only the file itself |
| Workflow map | A small router skill | Each other skill states only its own inputs, outputs and next step |
| Text that two or more skills truly need | `shared/` in the workflow repo, copied into each skill's `references/` by a build step | One place to edit; every skill stays self-contained |

The generated copies are committed, and a CI test fails if they differ from `shared/`. OpenSpec and EGM both guard against drift this way.

### Workflow repo layout

```
shared/                       single source for text used by several skills
skills/<prefix>-<name>/
  SKILL.md                    name + description only in front matter
  references/                 includes generated copies from shared/
  templates/                  only in the skill that writes that artifact
  agents/openai.yaml          Codex policy, e.g. no implicit invocation for setup
.claude-plugin/plugin.json, marketplace.json
plugin.json, .agents/plugins/marketplace.json     Codex
scripts/sync-shared           build step + parity test
```

- Skill names carry a unique prefix, since Matt Pocock's repo records name collisions with harness built-ins.
- Skills point to each other by name in prose. Plugin namespacing differs between the harnesses, so no skill depends on calling another.
- The spec review asks for "a fresh subagent that reads only these files". Reviewer personas are files in that skill's `references/`.

### Distribution

- **Primary: one repo that is a plugin for both harnesses.** EGM and Superpowers already ship this way. Updates arrive through a version bump.
- **Fallback: `npx skills add`.** It works because every skill is self-contained.
- **Not a template repo.** A template cannot be updated after it is copied.

### What setup writes into a consuming repo

1. Folders and stub files.
2. `work/config.yaml`: target branch, branch naming, ID format, caps, local files or GitHub issues, test, lint and typecheck commands, workflow version.
3. The managed block in `AGENTS.md`, and `CLAUDE.md` with the import if it is missing.
4. The CI check and `.gitattributes` entries.

It then detects greenfield or existing code and hands over to `docs-init`. Rerunning it repairs the repo and migrates it when the workflow version changes. All seven reference repos have a setup step of this kind.

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
7. Whether Next and Later stay in `BACKLOG.md` or move to GitHub issues with several developers.
8. Skill name prefix and the workflow's name.
9. Config file format and location.

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
