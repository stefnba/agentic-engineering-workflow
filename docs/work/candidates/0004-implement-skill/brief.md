# 0004 — Implement Skill

## Problem

Design the `implement` skill — the last major unbuilt piece of the workflow skill set (per `skills/README.md`'s status line, only `docs-rules`, `interview`, `critique`, and `shape` exist yet; `implement` is still just a row in the build plan). Two things about its design are genuinely open and are left for shaping to resolve, not decided here:

1. Whether test-driven development (red-green at pre-agreed seams) should be `implement`'s default code-writing methodology — as both the aihero.dev `/implement` skill and mattpocock/skills' standalone `tdd` skill do — or something else. Small lean toward TDD, but undecided.
2. Whether `implement` commits automatically per ticket (aihero's rhythm: "implement one ticket, commit, clear again") or leaves the diff uncommitted until it has been through review — the reviewer agent and a human — with the commit happening after.

## Constraints

- Must fit the Implement stage's already-stated procedure in `skills/README.md`: resolve → read → claim → work → verify evidence → reconcile → PR, and stay artifact-scaled so it also covers the bundle-less light path (`docs/docs-structure.md`'s ~80% no-bundle case).
- Must produce the evidence-block format the `evidence` reference skill and the reviewer agent expect (`docs/agentic-workflow.md`'s "evidence over claims" principle). If TDD is adopted, the red→green transcript is a candidate for *that* evidence, not an addition on top of it.
- The codebase already has implementations with no test coverage at all — whatever methodology is chosen can't assume every ticket starts from a tested baseline, and can't assume every ticket even touches testable behavior (docs, config, and other non-behavioral tickets exist too).
- Whatever commit-timing model is chosen has to reconcile with the gates that already exist — Review (forked reviewer agent) and the human Accept gate per PR before Ship merges (`docs/agentic-workflow.md`, where Plan and Accept are named as the only two gates a human crosses) — without duplicating or bypassing either.
- Two external references are candidate inputs, not decided adoptions:
  - aihero.dev's `/implement` skill — TDD inlined at pre-agreed "seams," typechecks as it goes, full suite once, code-review, commit; its own writeup names seam-agreement as the weak joint, since nothing in the skill itself negotiates seams.
  - mattpocock/skills' `tdd` skill — standalone and reusable (mirrors this repo's reference-layer pattern of `docs-rules`/`evidence`), seams pre-agreed with the user before any test is written, red-before-green, vertical slices only (no writing all tests before any implementation), refactoring kept out of the loop entirely.

## Motivation

`implement` is the backlog's flagship "build the workflow skills end-to-end, one first" item, and it's the stage that actually writes code. Getting its default rigor and commit discipline right now, while nothing downstream depends on it yet, is cheaper than retrofitting a testing/commit discipline onto a codebase that already has untested implementations sitting in it.
