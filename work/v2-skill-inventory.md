# v2 skill inventory

Input for rewriting this repo from scratch. For each skill it names the variant to port, why
that variant won, the strongest objection raised against it, and what to cut while porting.

Compared on 2026-11-26. Each pick came from one analyst agent and was then attacked by a second
agent in a fresh context. Claims are **verified** (an agent read the deciding line or ran the
command) unless marked **suspected**. Re-read a cited line before acting on it: only the
overturned picks (`review-changes`, `tdd`), the `codebase-design` diff, and the commits and PR
history under "How it was used" were checked a second time. Line targets are estimates, not
limits.

## Sources

Read variants at these paths, on the branch checked out there. Do not switch branches.

| Short name | Path                                                         | Branch                    | Skills in                |
| ---------- | ------------------------------------------------------------ | ------------------------- | ------------------------ |
| GCA        | `/Users/stebau/Developer/analytics/smg/gm_gca_ai`             | `app/root-cause-analysis` | `.agents/skills/<name>/` |
| TAB        | `/Users/stebau/Developer/analytics/smg/tableau-builder`       | `dev`                     | `.agents/skills/<name>/` |
| GMCA       | `/Users/stebau/Developer/analytics/smg/gm-commercial-analytics` | `main`                  | `.agents/skills/<name>/` |
| REF        | this repo at tag `v1-final`                                  | `main`                    | `skills/<name>/`         |

**The baseline on branch `v2` holds these variants as unchanged copies** in `skills/<name>/`,
taken at GCA `984d2db5`, TAB `5596b2b`, GMCA `49a4985`, and REF `v1-final`. It holds every GCA
skill, including those this file marks for cutting, so each cut is its own diff.

**GCA is the default base.** It is the most complete, it ran real work (17 merged bundle PRs,
37 ticket PRs), and it already runs under Codex as well as Claude Code. REF is the first draft:
no skill, workflow doc, or script there changed after 2026-09-01. Port from another repo only
where the table below names one.

## Rules for every port

**Strip Claude-only mechanics.** Remove `context: fork`, `agent:`, `model:`, `allowed-tools`,
`background`, skill-frontmatter `hooks:`, and every `${CLAUDE_*}` variable. Keep `name` and
`description`. Other harnesses read `${CLAUDE_PLUGIN_ROOT}` as a literal string.

**Write a sub-agent role as a prompt file in the owning skill.** The skill fills the
placeholders and passes the text as the sub-agent's entire prompt, and tells the human to run
the prompt in a new session when the harness cannot spawn one. GCA `review-pr/SKILL.md:111-113`
is the pattern.

**Run `git status` before and after every read-only dispatch.** A prompt file cannot restrict
tools, so the check replaces enforcement. REF's named agents enforced less than they appear to:
`reviewer`, `critic`, and `scanner` all carry `Bash`.

**Remove repo-specific terms.** A ported skill names no real package, product, or path from its
source repo. GCA test files name `bigquery_client` and "Business Performance Studio"; TAB
prompts name workbooks and `.twb` files.

**Remove references to skills that will not exist.** `setup-workflow`, `workflow-manager`,
`workflow-references`, `sweep-bundle`, and `implement-bundle` appear across GCA skills.

**Make a link to another skill conditional.** Write "if the `glossary` skill is installed, use
it; otherwise define the term inline". TAB had to rewrite `write-architecture-doc` because a
hard link pointed at a skill it lacked.

**Reach a sibling skill's file by relative path** (`../writing/references/explain.md`), and
install the suite as a whole. This removes the per-skill "Path conventions" section, repeated in
20 GCA files, and the fallback prose around it.

## Picks

| Skill                    | Port from                                    | Target lines |
| ------------------------ | -------------------------------------------- | ------------ |
| `writing`                | TAB                                          | 325          |
| `write-architecture-doc` | GCA                                          | 225          |
| `write-code-readme`      | GCA, with TAB's template                     | 250          |
| `record-decision`        | GCA                                          | 160          |
| `glossary`               | GCA                                          | 55           |
| `backlog`                | GCA                                          | 60           |
| `codebase-design`        | GCA                                          | 110          |
| `review-changes`         | GCA                                          | 250          |
| `review-pr`              | GCA                                          | 110          |
| `write-pr`               | GCA, plus two rules from GMCA `create-pr`    | not sized    |
| `scan-codebase`          | GCA                                          | 90           |
| `tdd`                    | REF                                          | 35           |
| `interview-me`           | GCA                                          | as is        |
| `pick`, `handoff`, `recap`, `research` | REF                            | not sized    |

### writing

- **Why TAB.** The three consumer copies are identical except three example names, and TAB's
  are the generic ones (`skill-mechanics.md:32`, `:65`). All three descend from REF's
  `writing-for-agents`: `references/steer.md` is that skill's body almost word for word.
- **Objection.** REF's single 237-line file costs one read; the router costs two on every use.
- **Why the pick held.** The skill finalizes every markdown file, and the router lets an
  explanatory document skip the 136 lines of steering rules. `tests/explain-baseline.md:16-35`
  records rewrites that grew without `explain.md` (671 words to 773 and 790) and shrank with it
  (662).
- **Cut.** Fold the router to about 10 lines with the steer-or-explain test as its first line.
  Merge `skill-roles-and-structures.md` into `skill-mechanics.md`. Keep the baseline tests file.

### write-architecture-doc

- **Why GCA.** It hands decisions to `record-decision` and terms to `glossary`
  (`SKILL.md:89`), and v2 ships both.
- **Objection.** The first pick was TAB, as the standalone variant.
- **Why TAB lost.** TAB is not standalone: it is wired to its own `docs/brief/` and
  `docs/backlog.md` (`SKILL.md:60`, `:79`, `:87`). TAB commit `f78725b` says it cut the
  hand-offs only because TAB has no `record-decision` skill.
- **Cut.** Reduce the monorepo member-and-root rules (`:48`, `:77`) to one scope line.

### write-code-readme

- **Why GCA.** Two steps carry the value: running the worked example and pasting its output
  (`SKILL.md:54-65`), and the fresh-reader review (`:96-112`).
- **Objection.** 399 lines to write a README.
- **Cut.** Use TAB's template, which has no Code map section. GCA's own
  `tests.md:9` found one pass described four times, "diagram, prose, a table, and the code
  map". Carry TAB's matching rewording in `notation.md` and `prompts/review.md`. Fold the Report
  step and the one-detailed-explanation step into two lines.

### record-decision

- **Why GCA.** The "earns a record" bar and the "belongs instead" table sit in the skill
  (`:13-30`). REF points at `workflow/artifacts.md`, which v2 deletes.
- **Objection.** Inlining made it longer than REF, 192 lines against 150.
- **Cut.** Placement rules (`:39-50`), the handed-over-at-Land paragraph (`:65-68`), and the
  ARCHITECTURE link step (`:90-92`) unless `write-architecture-doc` is installed.

### glossary

- **Why GCA.** It states the entry form with a code name (`:14-23`) and greps for the old term
  after a rename (`:56-59`).
- **Objection.** GCA writes the entry form twice, in `SKILL.md:17` and `template:15`.
- **Cut.** Drop the template file. Restore REF's concrete exclusions, "timeouts, error types,
  utility patterns" (REF `glossary/SKILL.md:14`), in place of GCA's "Known technical terms are
  excluded".

### backlog

- **Why GCA.** The bar, kinds, and area tags sit in the skill (`:24-56`).
- **Objection.** Without bundles a backlog is a file format that fits in `AGENTS.md`.
- **Why the pick held.** What survives is behavior: the three-part bar (`:29-34`), propose and
  never write, batched at the end of a task (`:58-81`), read the file in full and add no
  duplicate (`:95-96`). GCA's backlogs kept the one-line tagged format across 103 commits. TAB
  has no backlog skill and its backlog drifted to 123 lines of prose. Suspected, not shown: that
  the skill caused the difference.
- **Cut.** About 60 lines of bundle coupling: `:12-13`, `:22`, `:36-39`, `:91`, `:98`,
  `:108-110`, `:117-128`.

### codebase-design

- **Why GCA.** Other prompts cite its over-engineering guards (`:65-73`) and three tests
  (`:75-79`); the scan lens `prompts/lenses/simplification.md` names them. Its finding shape
  (`:93-97`) gives the design reviewer something to apply. REF's `code-design` has neither.
- **Objection.** REF carries the core idea in 89 lines, and GCA is not a superset: it drops
  REF's rejected framings (REF `code-design/SKILL.md:83-89`) and reverses REF's rule on testing
  past an interface (REF `:63-64` against GCA `:45`).
- **Cut.** Drop `kinds/http-backend.md`, 11 lines holding one rule. Keep `kinds/pipeline.md` and
  `languages/python.md` as optional profiles. Restore REF's rejected framings.
- **Confirm with the owner:** which testing rule is intended, REF `:63-64` or GCA `:45`.

### review-changes

- **Why GCA.** Its two prompts, design then correctness, are the ones `review-pr` reuses
  (GCA `review-pr/SKILL.md:19`).
- **Objection.** The first pick was TAB, as the generic variant.
- **Why TAB lost.** TAB carries workbook rules (`prompts/02-correctness.md:53`, `SKILL.md:87`)
  and unused PR-round machinery copied from GCA: it has no `review-pr` skill, and its
  `SKILL.md:63-64` hardwires round 1.
- **Why two prompts.** Only the design prompt looks for a cheaper shape
  (`prompts/01-design.md:27-39`). REF's reviewer forbids it (`agents/reviewer.md:39-40`).
  Design alternatives were adopted in real reviews, for example PR 62.
- **Cut.** Most of the 217 lines of reply templates, which are round and escalation
  scaffolding. Mark the remaining round slots "PR only". Put the shared finding rules (two
  severities, confidence, record form, about 20 lines) in one file every prompt reads by path;
  the confidence rule already differs in wording across four GCA prompts.
- **Keep.** The fingerprint that hashes untracked file contents (GCA `SKILL.md:39`).

### review-pr

- **Why GCA.** It builds its own detached worktree at the PR head (`:55-62`) and derives the
  round from existing comments (`:41-42`).
- **Objection.** GCA dropped REF's passed-SHA cross-check (REF `review-pr/SKILL.md:28-30`), so
  a push after dispatch is reviewed without notice (suspected, low impact).
- **Cut.** Ticket and bundle routing. Add one line: an optional expected-SHA check.

### write-pr

- **Why GCA.** `implement-ticket`, `review-pr`, `land-bundle`, and two `setup-workflow` templates
  reference it, and its bundle and ticket labels fit the staged workflow v2 ships. The owner
  chose it as the one PR skill (2026-11-26); `create-pr` was removed from the baseline.
- **Objection.** The first pick was GMCA `create-pr`: 53 lines against 287, with no bundle
  coupling. That counted only while the small workflow was an option.
- **Add from `create-pr`** (GMCA `49a4985`, `.agents/skills/create-pr/SKILL.md`):
  - Split mixed history (`:22`): when the branch holds independent changes, ask the user to
    choose one PR or several before writing.
  - Drafting is not publishing (`:14`, `:42-44`): a request for a title or description returns
    text only; push or open the PR only on an explicit request to create or publish it.
- **Cut.** Shorten the 177-line body template. In GCA's templated review format, most blocker
  titles concerned the PR body and template slots, not code (suspected: an agent's regex count,
  17 of 21, classification approximate). Keep the two slots the correctness reviewer audits:
  pre-change evidence and checks at the head SHA.

### scan-codebase

- **Why GCA.** Four lens scanners produce distinct findings: a real scan,
  `apps/root_cause_analysis/work/scans/2026-10-25-all.md`, holds 39 findings with about three
  overlaps. Its scanner prompt drops unconfirmed claims (`prompts/scanner.md:29`).
- **Objection.** The first pick replaced the scan file with REF's single in-chat report.
- **Why that lost.** The scan file is the hand-off: the pick-now prompt sends a fresh session to
  read it (GCA `SKILL.md:113`), and the real scan runs 242 lines.
- **Cut.** The digest template, replaced by a five-line instruction. The triage and work-folder
  steps tied to `workflow-manager`.

### tdd

- **Why REF.** It works without a ticket: "with no ticket, agree the seam with the user before
  writing the first test" (`skills/tdd/SKILL.md:10-11`). GCA's copy, in
  `implement-ticket/references/tdd.md:3-4`, assumes a ticket.
- **Cut.** The `code-design` cross-reference (`:28-29`). Fix the description, which promises
  anti-patterns while the file holds one.

### pick, handoff, recap, research

- **Why REF.** The owner keeps them (decided 2026-11-26), and REF holds the only variant.
- **Objection.** No consumer ported them, so none has run outside Claude Code.
- **Cut.** These were not compared or challenged; read each in full before porting. Known
  Claude-only parts: `research` forks into `agents/researcher.md` and fences writes with a
  frontmatter hook (`skills/research/SKILL.md:9-14`); `recap` carries a `disallowed-tools` list.
  Turn the researcher into a prompt file under `research`.

## Not ported

- **REF `judge` and `agents/arbiter.md`.** No consumer kept them.
- **REF `finding-rules`.** Replaced by the shared rules file under `review-changes`.
- **REF `agents/reviewer.md`, `critic.md`, `scanner.md`, `researcher.md`.** Replaced by prompt
  files.
- **GMCA `document-data-domain`, `create-initiative`, `publish-initiative`,
  `write-bigquery-query`.** Specific to that repo.
- **GMCA `document-sql`.** Leave local until a second repo writes SQL. Its reusable core is
  about 60 lines: comments-only edits, a header of purpose, grain, approach, and caveats, and a
  diff with comments excluded.
- **GMCA marimo skills.** Vendored from `marimo-team/skills` through `skills-lock.json`.
- **An `AGENTS.md` template.** Only "Purpose" recurs in all three consumers.

## The workflow

GCA's workflow skills are `shape-bundle`, `critique-bundle`, `implement-ticket`,
`implement-bundle`, `sweep-bundle`, `land-bundle`, `workflow-manager`, `workflow-references`,
and `setup-workflow`. GCA is the base here too, but it is no smaller than REF: about 4,800
lines against about 5,900. It dropped git machinery and added shaping and review ceremony.

### How it was used

- **2026-09-30 to 2026-10-09.** Run as designed: nearly every ticket PR got a design review and
  a correctness review, two to five rounds each.
- **From 2026-10-12.** Run loosely. One bundle had seven tickets and one ticket PR. Commit
  `a9c23eef`: "Built directly by sub-agents without ticket branches". Commit `584d519b` dropped
  a bundle "instead of landed" after seven critique rounds.
- **Concurrency observed.** One bundle at a time, at most two tickets in parallel.
- **Bundle PRs.** Merged with no reviews. The review happened on ticket PRs.

### Keep or cut

| Part                              | Added because                                               | Used                        | v2                                    |
| --------------------------------- | ----------------------------------------------------------- | --------------------------- | ------------------------------------- |
| Route gate                        | Simple intents collected a spec and plan anyway (`7e9de6dc`) | Yes                         | Keep as one shaping question          |
| `brief.md`                        | The Plan gate gave the human nothing to judge (`0428f803`)   | 2 bundles                   | Keep as the spec's first section      |
| Two-pass critique, shape record   | No failure cited (`aef9fa12`)                                | 7 rounds on a dropped bundle | One pass, capped at 2 rounds          |
| Design and correctness reviewers  | No reason recorded (`97d0428d`)                              | 36 of 37 ticket PRs         | Keep both prompts                     |
| `sweep-bundle`                    | Small review findings had no home (`3ae6ec6f`)               | Once                        | Cut; a fix ticket covers it           |
| Staleness re-critique             | (`f8d77d16`)                                                 | Once                        | Cut                                   |
| Reply templates and glyphs        | (`8f47887e`, `82ea2408`)                                     | Every PR                    | Cut to a short reply form             |
| `workflow-references` skill       | `npx skills` drops non-skill folders                         | Read by 2 skills            | Move `bundle-rules.md` under the shape skill |
| Publish-to-target, lazy branch, detached land worktree (REF) | REF design                          | Never in a consumer         | Cut                                   |

### Two shapes for v2

The evidence supports either. The owner picks; see Open decisions.

- **Small.** Three skills: shape (intent, brief, route question, tickets as a checklist in one
  `spec.md`, one capped critique), implement (one ticket or all, on one feature branch), review
  (`review-changes`). No scripts. Status is checkboxes in `spec.md`. Human stops: approve the
  brief, merge the PR. This matches how the workflow ran from 2026-10-12.
- **Staged.** Four skills: shape, implement-ticket, land, and a state skill with one script
  (`status`, `claim`, `complete`, `abandon`, `check-land`), plus per-ticket PRs. This matches how
  it ran before 2026-10-12, when per-ticket review found real defects.

## Layout and distribution

- **Put skills in `skills/<name>/`**, each with its own `references/`, `templates/`, and
  `prompts/`. Each shared file has one owning skill.
- **Consumers hold skills in `.agents/skills/`** with one folder symlink,
  `.claude/skills -> ../.agents/skills`. GCA uses this.
- **Keep repo-specific values in the consumer's `docs/conventions/*.md`**, never in an edited
  skill copy. Hand-edited copies are why three variants of each skill exist today.
- **Replace the plugin.** `docs/decisions/2026-08-08-distribute-as-claude-code-plugin.md` is
  still `accepted` and contradicts `HARNESS-AGNOSTIC-SKILLS.md`. Write a superseding record.
- **Given up without the plugin:** per-role model pinning, preloaded skills, write-boundary
  hooks, the `crisp` output style, plugin version numbers. The consumers' `.claude/settings.json`
  sets `outputStyle: crisp` with no such file present (suspected dangling).

## Untested

Test each before v2 depends on it.

- **`npx skills update` from a git source onto a locally edited copy.** Listed as open at
  `HARNESS-AGNOSTIC-SKILLS.md:314`. No lockfile in any consumer covers the owner's own skills,
  so the update path has never run.
- **Cursor.** Named as a target and never probed (`HARNESS-AGNOSTIC-SKILLS.md:320`).
- **How Claude-only frontmatter degrades in other harnesses** (`:205`, `:318`).

## Open decisions

1. **The testing rule in `codebase-design`.** Deferred by the owner; port GCA's wording until
   decided.

## Decided

Owner, 2026-11-26.

- **A bundle is deleted at land.** The spec, plan, and tickets are working files, not durable
  records. Whatever must outlive the bundle moves out before deletion: a decision into a
  decision record, a term into the glossary, a follow-up into the backlog. This rules out REF's
  publish-to-target model.
- **`pick`, `handoff`, `recap`, and `research` are ported.**
- **v2 ships the staged workflow as the standard**, for large work. The small shape is a later
  version's quick path; build nothing for it in v2, and keep shape and review usable without the
  state skill so it can be added on top.
