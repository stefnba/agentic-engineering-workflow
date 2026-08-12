---
name: shape
description: Write spec.md and the full ticket set from this session's settled understanding — a just-finished interview, a backlog line, or requirements stated directly in chat.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Edit, Skill(critique *), Bash(mkdir -p work/shaped/*), Bash(git mv *), Bash(git add *), Bash(git commit *), Bash(git push *)
hooks:
  PreToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "${CLAUDE_PROJECT_DIR}/skills/shape/scripts/write-boundary.sh"
---

# Shape

The author role. Input is whatever's in front of you right now: a just-finished interview, a backlog line the human pointed at, or requirements stated directly in this chat — there's no argument to resolve a bundle by, because none exists yet. Output is `spec.md` and the full ticket set, inside a bundle you create yourself. You are **read-only on code, structurally** — the hook above blocks any `Edit`/`Write` outside `work/shaped/`. An agent that can write code will write code and retrofit the spec to it; this removes the option rather than relying on restraint.

## Create the bundle

Default: create a fresh bundle. Derive a kebab-slug from the settled understanding's title and check `work/*/$(date +%F)-<slug>` doesn't already exist. Then skim `work/shaped/` and `work/active/` for bundles that look topically related — this is a judgment call, not a string match: two slugs with zero characters in common can still be the same feature. If something looks related, say so and ask the human whether it's the same effort, a follow-up, or unrelated, before going further. Do this before any deep reading — it's the first action, not something to reach after research, and it's cheap precisely because nothing has been written yet (decision 0013).

There is no separate claim step and no shared counter. Work locally under `work/shaped/<date>-<slug>/` as you write `spec.md` and the tickets (below); the bundle isn't committed or pushed until it's complete and approved — see Exit.

## Read before writing

Read the actual repo: the modules the change touches, their colocated READMEs, and the `docs/decisions/` records for those areas — a spec that contradicts a standing decision re-litigates it by accident. **Shaping is grounded in the real codebase**: the spec names real modules and observed behavior, tickets cite exact paths (the spec itself carries none — that's the template's rule), and a spec written without reading the code describes an imaginary architecture you can't tell from the real one from inside your own head.

## Surface drift, don't route around it

What you're reading — a legacy brief, an old backlog line, this conversation itself — may reference something that's since moved, been renamed, or never existed: a skill that was removed, a doc that relocated, a component the text assumes but the repo doesn't have. That's a judgment call, not a design problem. Say what you found and ask how to handle it. Don't invent the missing piece, don't quietly fold designing it into this bundle's scope, and don't spend minutes reasoning toward an answer only the human can give — one line, asked now, beats a well-researched guess.

## Sketch the test seams

Before drafting, pick the seams the acceptance tests will attach to — the boundaries where behavior gets observed. Prefer seams that already exist; place any new one as high as you can; the fewer the better, and one is the ideal. The choice is upstream of everything else: Behavioral Requirements and Acceptance Criteria are phrased at an observable boundary, and the seam is that boundary — pick it late and the spec gets rewritten around it. It's a judgment call, so confirm the sketch with the human before writing the spec. The confirmed answer lands in `Testing Decisions`.

## Write spec.md

Start from [spec-template.md](spec-template.md), shipped with this skill — section order, per-section rules, and the `BR-`/`ID-`/`AC-` ID scheme live there, and headings never vary between specs so tickets and tooling can deep-link. `Out of Scope` is the highest-value section: agents wander, and an explicit exclusion list is the cheapest fix. Sequencing rationale a dependency graph can't express — "03 ships behind a flag so we can measure before 04" — is one line in the spec's `Tickets` section, next to the order it explains; `Rollout & Flags` holds the flag mechanics. There is no separate plan document.

## Write all the tickets

The full decomposition, every ticket with a concrete `Done when` — writing that check is a test of the spec, and a ticket whose check you can't write yet is a spec hole you just found while it's cheap. Before exit, verify **coverage**: every acceptance criterion maps to some ticket's done-when; a criterion with no ticket is bad slicing. Start from [ticket-template.md](ticket-template.md), shipped with this skill; slicing rules live in [docs/agentic-workflow.md](../../docs/agentic-workflow.md), don't restate them here. Later tickets invalidated by landed work get amended at reconcile, not re-shaped — expect that, don't pad against it.

## Judgment calls happen inline, not in Open questions

You're running with the human in the conversation — unlike Implement, which is isolated and must stop-and-record. When you hit a real judgment question (not decidable from the repo), ask it directly and get the answer now. Record it resolved on the spot: `- [resolved] <question>? → <answer>`. Reserve unresolved `Open questions` lines for things nobody in the room can answer yet.

Ask as you go, not in a batch at the end. The moment you notice a second or third judgment question piling up before you've written anything, stop and put them to the human right there — don't keep exploring the repo hoping the next file resolves them for you. Minutes of uninterrupted reading with nothing to show is the symptom; asking sooner is the fix.

Evidence questions you resolve yourself, citing the file — don't ask the human something the repo already answers.

## Invoke critique before exit

Once `spec.md` and the tickets exist, invoke `critique` with this bundle's ID and wait for findings (it blocks — that's the point of asking before the human sees the plan). Findings are attacks, not fixes: triage each one, revise the spec where it's right, and say so plainly where you're not acting on one and why. This is normal authoring, not a post-approval amendment — the spec isn't approved yet.

## Exit

Two checks, both required:

1. **Every `Open questions` line carries a resolution.** No unresolved lines.
2. **The human approves the decomposition.** Present the spec and tickets; this is the Plan gate, and it's a human call because bad slicing is cheap to fix in a list and expensive to fix across twelve started tickets.

On approval, two moves in order. First fold each resolved answer into the section it constrains and delete its line — the implementing agent receives a spec whose `Open questions` section is empty or absent (the answer survives in the section it now constrains; git keeps the Q&A trail). Then commit and push the whole bundle at once: `git add work/shaped/<date>-<slug>/`, commit, push. If the push is rejected, someone else's bundle landed on the same date and slug — `git mv` to a disambiguated slug and retry; this is the only point a collision can still occur, and it costs a rename, not a rewrite.
