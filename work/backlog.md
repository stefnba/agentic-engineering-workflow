# Backlog

Candidate work and follow-ups nobody has picked yet.

## Items

- [follow-up] [agents] Structurally enforce the read-only agents. `agents/reviewer.md` and `agents/critic.md`
  now carry a `tools:` allowlist, which withholds file editing only — both keep `Bash` because
  verification and repository reading need it, so nothing stops a push, approve, or merge except the
  prompt. Both prompts and `workflow/lifecycle.md`'s Shape and Review run conditions say so plainly
  rather than overclaiming. Close it with a hook or a permission rule, and the same question applies to the
  Architect's "write access only to the draft bundle" boundary.
- [follow-up] [skills] `shape-bundle` publishes the approved bundle by hand — `git add`/`commit`/`push` from the
  prompt, sourcing `scripts/_config.sh` for `INTEGRATION_TARGET`. Every other state
  transition is a script; this one is prose, so a collision retry or a wrong target branch depends
  on the model following instructions. Consider `scripts/publish-bundle.sh`.
- [follow-up] [skills] `claim-ticket.sh` is verified over the `git://` smart protocol, never against
  github.com over HTTPS, and the chain claim → PR → `/complete-ticket` → derived `done` has never run
  joined — only its two halves separately. One real push settles both. Smaller gaps:
  `--match-head-commit` was confirmed to exist but never exercised against a mismatched head, and
  everything ran on darwin with git 2.52.
- [idea] [skills] A doc-drift sweep skill (`audit` on the `old-workflow` tag: stale READMEs, broken
  references, glossary violations, contradicted decisions). `scan-codebase` deliberately excludes
  drift; port `audit` fresh against `workflow/` if ambient capture — reconcile steps plus noticed
  drift routed to the backlog — proves insufficient.
- [follow-up] [skills] A consuming repo has no read path into `workflow/` at all. The installed `AGENTS.md`
  pointer deliberately stops at naming the plugin, `docs/conventions/git.md`, `work/config.conf`, and the
  two caretaker skills: no placeholder resolves in project instructions, and the line routing every stage
  through its own skill was dropped on purpose. So a session that wants to read the contract — or
  `docs/walkthrough.md` — has nowhere to go, and an agent that never invokes a stage skill never learns
  the lifecycle exists. Ship a reference skill that loads `workflow/lifecycle.md` on demand, or accept
  that the stage skills are the only entry.
- [drift] [docs] `skills/record-decision/templates/decision-record.md` mandates YAML frontmatter with
  `areas:`, and `workflow/artifacts.md` reads the area vocabulary from records' frontmatter — but
  `2026-08-18-consuming-repo-layout.md` and `2026-08-18-script-read-settings.md` use a prose byline and
  `2026-08-18-fixed-bundle-land.md` has frontmatter without `areas:`. All three are immutable, so the fix
  is not an edit: either supersede them or accept that the vocabulary reads from the rest.
- [idea] [skills] `shape-bundle` picks the test seam while filling `spec.md`'s Test intent in step 4 and confirms
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
- [follow-up] [workflow] A ticket PR merged from the forge UI bypasses `complete-ticket.sh`'s currency
  gate and `--match-head-commit`. Observed on PR #11, merged at `9f5537b` with `0c40854` not an
  ancestor. `land-bundle.sh start` now catches the direct-push case — a bundle-branch commit matching
  no merged ticket PR refuses the land (exit `8`) — but a UI-merged PR has a record and passes. Closing
  the remainder needs the accepted head SHA recorded somewhere durable at Accept time so the land can
  compare against it; today it exists only in the `/complete-ticket` invocation.
- [idea] [workflow] Canonical checks as a `work/config.conf` key, so scripts — Land's re-check loop
  first — can run them instead of relying on the skill's judgment to. Flagged as the shared
  prerequisite for automating the land loop when uniform bundle branches were ruled; today no script
  consumes such a key, which is why it wasn't added with them
  (`docs/decisions/2026-08-18-script-read-settings.md` gates config on a script reader).
- [idea] [skills] [docs] `work/backlog.md`'s bullet format could move to a markdown table (`id`,
  `topic`, `areas`, `details`)
- [follow-up] [skills] An ad-hoc `review-pr` on a non-ticket PR leaves its round comment's Backlog
  candidates unswept — `land-bundle`'s sweep reads only a bundle's merged ticket PRs, and no other
  path reads PR comments back.
