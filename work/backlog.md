# Backlog

Candidate work and follow-ups nobody has picked yet.

## Items

- [follow-up] [skills] The research split from `docs/decisions/2026-08-18-consuming-repo-layout.md` is now in
  `workflow/artifacts.md`'s authority table, but the research skill that has to honour it is unbuilt.
- [follow-up] [agents] Structurally enforce the read-only agents. `agents/reviewer.md` and `agents/critic.md`
  now carry a `tools:` allowlist, which withholds file editing only — both keep `Bash` because
  verification and repository reading need it, so nothing stops a push, approve, or merge except the
  prompt. Both prompts and `workflow/lifecycle.md`'s Run conditions say so plainly rather than
  overclaiming. Close it with a hook or a permission rule, and the same question applies to the
  Architect's "write access only to the draft bundle" boundary.
- [follow-up] [skills] `land-bundle.sh cleanup` deletes every ticket branch and the bundle branch
  unconditionally, where `git show old-workflow:skills/bundle-git/SKILL.md` classified them first —
  merged, open PR, in flight — and refused to touch anything unmerged. Add that classification:
  `gh pr list --head` rather than ancestry, because a squash merge leaves none.
- [drift] [skills] [docs] `README.md` and `docs/walkthrough.md` name skills that hold nothing yet —
  `scan-codebase`, `research`, and `complete-ticket`. (`land` and `review` now exist.)
  Whoever builds one claims its name from the README table. One constraint is already settled:
  `bundle-git` owns claim, status, and merge, so `/complete-ticket` calls its script rather than
  reimplementing the merge.
- [follow-up] [skills] `shape` publishes the approved bundle by hand — `git add`/`commit`/`push` from the
  prompt, sourcing `bundle-git`'s `_config.sh` for `INTEGRATION_TARGET`. Every other state
  transition is a script; this one is prose, so a collision retry or a wrong target branch depends
  on the model following instructions. Consider `bundle-git/scripts/publish-bundle.sh`.
- [follow-up] [skills] `bundle-git`'s claim is verified over the `git://` smart protocol, never against
  github.com over HTTPS, and the chain claim → PR → `/complete-ticket` → derived `done` has never run
  joined — only its two halves separately. One real push settles both. Smaller gaps:
  `--match-head-commit` was confirmed to exist but never exercised against a mismatched head, and
  everything ran on darwin with git 2.52.
- [follow-up] [skills] Add reference skill `/codebase-design` — supplies shared vocabulary (module, interface,
  depth, seam, adapter, leverage, locality) for other skills to borrow; not a session driver itself.
- [follow-up] [skills] `bundle-git` documents a `depends_on` input rule it doesn't enforce, verified by
  running it: `claim-ticket.sh` parses the line with a `sed` that handles only the flow form
  `[01, 02]`. `skills/shape/templates/ticket.md` names every unsafe form — quoted or unpadded
  numbers block the claim forever, a trailing comment reads as a dependency, block-sequence style
  fails open and lets a dependent ticket start early — so the rule reaches whoever writes a ticket
  from the template, and nothing catches a hand-edit that ignores it. (The sibling `ls tickets`
  count is fixed: `_config.sh`'s `ticket_base` globs `NN-<slug>.md`, with a regression test.)
- [follow-up] [skills] Two skills stay on the `old-workflow` tag because they encode the superseded
  contract: `research` and `audit` (→ `scan-codebase`), along with the `researcher` agent they fork
  into. Write them fresh against `workflow/`, with `git show old-workflow:skills/<name>/SKILL.md` as
  reference, rather than restoring and patching paths; `researcher` preloads `backlog` via its
  `skills:` field, which now exists. Open first: `audit` wrote a `docs/research/audit-*.md` plus
  backlog lines autonomously, but `docs/walkthrough.md` and `workflow/artifacts.md` now say a
  codebase scan's findings stay inline in chat and get triaged live — settle which before writing
  it.
- [follow-up] [skills] A consuming repo has no read path into `workflow/` at all. The installed `AGENTS.md`
  pointer deliberately stops at naming the plugin, `docs/conventions/git.md`, `work/config.conf`, and the
  two caretaker skills: no placeholder resolves in project instructions, and the line routing every stage
  through its own skill was dropped on purpose. So a session that wants to read the contract — or
  `docs/walkthrough.md` — has nowhere to go, and an agent that never invokes a stage skill never learns
  the lifecycle exists. Ship a reference skill that loads `workflow/lifecycle.md` on demand, or accept
  that the stage skills are the only entry.
- [follow-up] [skills] `skills/bundle-git/tests/run.sh` pins that a stray file _inside_ `tickets/` can't flip
  the branch strategy, but nothing pins a sibling directory under `work/bundles/<id>/`. `ticket_base` is
  safe today by inspection; add the case before any design puts a directory there.
- [drift] [docs] `skills/record-decision/templates/decision-record.md` mandates YAML frontmatter with
  `areas:`, and `workflow/artifacts.md` reads the area vocabulary from records' frontmatter — but
  `2026-08-18-consuming-repo-layout.md` and `2026-08-18-script-read-settings.md` use a prose byline and
  `2026-08-18-fixed-bundle-land.md` has frontmatter without `areas:`. All three are immutable, so the fix
  is not an edit: either supersede them or accept that the vocabulary reads from the rest.
- [idea] [skills] `shape` picks the test seam while filling `spec.md`'s Test intent in step 4 and confirms
  it in step 5's batch — after the Behavioral Requirements and Acceptance Criteria above it are already
  written. The `old-workflow` shape had a dedicated step 3, "Sketch the test seams and confirm with
  user", before creating the bundle at all, for the stated reason that AC are phrased at the seam, so
  picking it late means rewriting the spec around it. Restoring that ordering costs one round-trip
  before drafting.
- [drift] [workflow] `workflow/artifacts.md`'s Areas section derives the area vocabulary from use — "read
  the backlog's lines and the records' frontmatter, reuse the closest term, coin one only when none
  fits" — but `setup` installs `work/backlog.md` with an empty `## Items` and creates no
  `docs/decisions/` at all, so in a fresh consuming repo that read returns nothing and the coin branch
  fires on every line with nothing to calibrate against. The deleted
  `skills/backlog/references/entry-format.md` named the failure ("usage is a subset of what's valid");
  nothing does now.
- [follow-up] [skills] Five skills' `allowed-tools` was written against the reading
  `workflow/components.md` now corrects — `backlog`, `glossary`, `pick`, `interview-me` and `setup` list
  tools as though the field withholds what it omits. It only pre-approves; `disallowed-tools` is what
  removes a tool from the pool. The recap bundle's NG-7 deferred the audit to here.
- [follow-up] [skills] `skills/recap/SKILL.md`'s `disallowed-tools` is a snapshot of the built-in tool set
  on 2026-08-20 and nothing re-derives it. Review round 1 already caught the first draft naming four
  tools that no longer exist and missing a dozen that do; the next platform change puts the list back in
  that state silently, and anything added after it stays callable.
- [follow-up] [workflow] A ticket PR merged from the forge bypasses `complete-ticket.sh` entirely — both
  the `merge-base --is-ancestor` currency gate and `--match-head-commit`. Observed on PR #11, merged at
  `9f5537b` with `0c40854` not an ancestor, which the script would have refused with exit `2`. Branch
  protection is not available as a cover: `skills/setup/references/prerequisites.md` routes a protected
  default branch onto an unprotected integration target.
