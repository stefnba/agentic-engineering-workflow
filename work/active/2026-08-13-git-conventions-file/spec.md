# 2026-08-13-git-conventions-file — Per-repo git conventions file

## 1. Problem Statement

A developer installing the workflow gets agents whose git behavior is baked into the skills:
branches cut from the default branch, PRs per ticket into it, no commit-message standard at
all. Repos differ — some deploy the default branch's head on every merge, some release
deliberately — and a repo that needs whole-feature merges has no way to say so. Anything the
developer does write down about git today lands in AGENTS.md, bloating the always-loaded
context.

## 2. Solution

At setup, the repo chooses its branch strategy from two named options and the choice is
recorded, alongside commit and PR conventions, in one agent-facing file. Every agent doing
git work reads that file and behaves accordingly — branch targets, PR targets, merge
semantics, commit-message format. A repo that never made the choice gets the recommended
default. The always-loaded instructions carry only a pointer.

## 3. Behavioral Requirements

BR-1: Setup asks which branch strategy the repo uses, presenting `trunk` (recommended
default) and `bundle-branch` with a cost description of two lines each; accepting the
default needs no further input.

BR-2: Setup scaffolds `docs/agents/git.md` from a shipped template with the chosen strategy
declared, and adds a pointer to the repo's agent-instructions file (AGENTS.md, or CLAUDE.md
where that's what the repo uses). An existing `docs/agents/git.md` is never overwritten; on
a re-run with the file present, setup reports the existing declaration and skips the
question — it never solicits an answer it would discard.

BR-3: Agents performing git operations follow `docs/agents/git.md`: ticket branches and PR
targets match the declared strategy, and commit messages follow the file's commit
convention.

BR-4: With no `docs/agents/git.md`, or none containing a valid declaration, agents behave
as `trunk`.

BR-5: In `trunk` mode, each ticket branch cuts from the default branch's head and its PR
targets the default branch.

BR-6: In `bundle-branch` mode, a directory bundle's tickets branch from and PR into that
bundle's integration branch; ship merges the integration branch into the default branch and
confirms the repo's checks pass there. A single-file bundle behaves as `trunk` in either
mode — its one PR is already a whole feature.

BR-7: Shape orders a feature bundle's tickets so user-visible wiring lands in the final
ticket (expose-last); under `trunk`, this is what keeps unfinished features invisible to
users of a continuously deployed default branch.

BR-8: Every owned concept has exactly one home, per ID-6's ownership split: the
declaration-line format and commit-type vocabulary in the template, branching procedures
in the implement skill, landing procedures in the ship skill, the expose-last rationale in
the shape skill, the artifact entry in the workflow doc; everything else points instead of
restating. The mode tokens and the `trunk` fallback are shared keys, not owned concepts —
each skill states them where its steps branch on them (AC-4 requires this), and one-home
applies to definitions and procedures only. Instantiated per-repo
copies of the template — including this repo's dogfood `docs/agents/git.md` — are
instances, not second owners, and are exempt from the one-copy checks.

BR-9: This repo dogfoods the artifact: its own `docs/agents/git.md` declares `trunk` and
Conventional Commits, and its AGENTS.md carries the pointer.

## 4. Implementation Decisions

ID-1: The declaration is one line matching `^Branch strategy: (trunk|bundle-branch)` in
`docs/agents/git.md`. Skills key on this line and nothing else in the file.

ID-2: A missing file or absent declaration line means `trunk`. The fallback is silent by
design (decision 0015 records the cost).

ID-3: The integration branch in `bundle-branch` mode is named `<bundle-id>/integration`,
created from the default branch's head when the bundle's first ticket starts. A bare
`<bundle-id>` ref would collide with `<bundle-id>/NN-<slug>` ticket refs in git's ref
namespace.

ID-4: The commit convention shipped in the template is Conventional Commits:
`type(scope): subject` — types exactly `feat`, `fix`, `refactor`, `docs`, `test`, `chore`,
`ci`; subject imperative, lowercase after the colon, ≤ 72 characters; body only when the
why isn't obvious from the diff; one logical change per commit. The template is the sole
owner of this vocabulary (BR-8); consuming repos edit their copy freely.

ID-5: The template ships as a setup asset, bare scaffold with slot guidance in HTML
comments per the skill-mechanics asset rules — no preamble, nothing outside comments that
can't land verbatim in a consuming repo.

ID-6: Ownership split: the workflow doc carries a one-sentence artifact entry naming the
file and its four content areas, nothing more; the AGENTS.md pointer owns the
read-before-git-operations trigger; the template owns the declaration format and the
commit vocabulary; mode tokens, procedures (branch sources, PR targets, integration
naming, the single-file exemption), and the missing-file `trunk` fallback live as steps
in the implement/ship skills; `git.md` instances hold the repo's choice plus
repo-specific mechanics. Skills reference, never restate.

ID-7: Ship in `bundle-branch` mode runs absorb and delete on the integration branch, then
lands it by opening a PR from the integration branch to the default branch and merging that
PR immediately — mechanical landing, not a review object: every ticket PR already passed
the Accept gate individually, and the PR form satisfies protected-branch rules that a
direct push would violate. A merge conflict at this step stops ship; resolving it is the
human's, surfaced immediately per ship's existing rule. The green check runs on the
default branch as today. Ship's own absorb/delete commits follow `git.md`'s commit
convention by pointer.

ID-9: Integration-branch hygiene in `bundle-branch` mode: at Activate, implement merges
the default branch into the bundle's integration branch when it is behind, so drift is
paid per ticket, not at ship; a conflict there stops the session and goes to the human —
it is decision drift, not the implementer's to resolve silently.

ID-8: PR conventions in `git.md` are repo-specific additions only (title format, merge
method, labels); the workflow-mandated PR body sections (verify results, reconcile list)
stay owned by the implement skill. The template ships merge method defaulted to squash —
one commit per ticket on the target branch — editable per repo.

## 5. Testing Decisions

Seam: the shipped tree's file content — assertions checkable by `grep`/file-existence
against `skills/`, `docs/`, and this repo's dogfood files. Whether agents *follow* the new
text (setup actually asks, implement actually reads the file) is prompt behavior, not
machine-checkable here; per this repo's convention it is verified by fresh-session reruns
tracked as backlog lines at ship (prior art: every "unverified — rerun per testing.md"
line in `work/backlog.md`).

Good tests assert presence of the owned content in its one home and its absence everywhere
else (BR-8); prior art for a grep gate: the ship skill's bundle-ID absorb check.

## 6. Acceptance Criteria

AC-1 (BR-8, BR-4): Given `docs/agentic-workflow.md`, when read, then its git.md artifact
entry is one sentence naming the file and its four content areas — no mode tokens, no
declaration format, no fallback; those appear only in the implement/ship skills and the
template per ID-6.

AC-2 (BR-1, BR-2): Given `skills/setup/SKILL.md`, when reading its ask and write steps,
then the strategy question appears with both options, two-line costs, and `trunk` marked
recommended; the write step scaffolds `docs/agents/git.md` from the asset and never
overwrites an existing one; the agents-reference block contains the `docs/agents/git.md`
pointer.

AC-3 (ID-4, ID-5): Given the setup asset template, when read, then it contains a line
matching `^Branch strategy: `, the seven commit types, the brevity rules, and the squash
default — all slot guidance in HTML comments, no preamble — and the commit-type list
appears in no shipped file other than the template and template instances
(`docs/agents/git.md`).

AC-4 (BR-3, BR-5, BR-6, ID-1, ID-2, ID-7, ID-9): Given `skills/implement/SKILL.md` and
`skills/ship/SKILL.md`, when grepped, then both contain `docs/agents/git.md` and the
`trunk` fallback phrase; implement's Activate step contains both mode tokens (branch
source and integration sync per ID-9) and its Close-out step both PR targets; ship's land
step contains the integration-branch PR-merge and conflict-stop of ID-7; and `feat` (the
commit-type list's first token) appears in neither skill.

AC-5 (BR-7, BR-3): Given `skills/shape/SKILL.md`, when grepped, then the ticket-writing
step owns the expose-last ordering (user-visible wiring in the final ticket) with its
one-sentence rationale, and the commit-and-push step contains a `docs/agents/git.md`
pointer for its commit messages.

AC-6 (BR-9): Given this repo, when checked, then `docs/agents/git.md` exists with
`Branch strategy: trunk` and the Conventional Commits convention, and `AGENTS.md` contains
the pointer line.

## 7. Out of Scope

- The `ticket-runner` agent and any orchestration skill — its contract consumes this
  bundle's output but is its own build-plan row.
- A third strategy, custom modes, or feature-flag machinery — the mode set is closed at
  two (decision 0015's revisit clause owns reopening it).
- Migration tooling for consuming repos that already ran setup — a re-run of setup is the
  path; build nothing else.
- No changes to the review, critique, or backlog skills.
- No GLOSSARY.md entries — `trunk` and `bundle-branch` are declaration keys defined where
  the skills use them (ID-6), not domain vocabulary.
- Don't restructure the agents-reference block beyond adding the one pointer line.
