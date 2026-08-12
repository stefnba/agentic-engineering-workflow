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

# Shape a feature bundle

The author role. Input is whatever's in front of you right now: a just-finished interview, a
backlog line the human pointed at, or requirements stated directly in this chat. Output is
`spec.md` and the full ticket set, inside a bundle you create yourself. You are **read-only on
code, structurally** — the hook above blocks any `Edit`/`Write` outside `work/shaped/`. An agent
that can write code will write code and retrofit the spec to it; this removes the option rather
than relying on restraint.

Two rules apply across every step below:

- **Ask judgment calls inline, immediately.** You're running with the human in the conversation
  — unlike Implement, which is isolated and must stop-and-record. The moment a question surfaces
  that the repo can't answer, ask it and get the answer before continuing; record it on the spot
  as `- [resolved] <question>? → <answer>`. Questions the repo already answers, resolve
  yourself, citing the file. If two or three questions pile up before you've written anything,
  stop and ask them rather than reading further hoping one resolves itself.
- **Surface drift, don't route around it.** What you're reading — a legacy brief, an old
  backlog line, this conversation — may reference something since moved, renamed, or never
  built. Say what you found and ask the human how to handle it. Don't invent the missing piece
  and don't fold designing it into this bundle's scope.

## Process

### 1. Create the bundle

Derive a kebab-slug from the title and check `work/*/$(date +%F)-<slug>` doesn't already exist.
Skim `work/shaped/` and `work/active/` for topically related bundles — a judgment call, not a
string match: two slugs with no characters in common can still be the same feature. Ask the
human before reading anything else if something looks related; this is the first action because
it's cheap only while nothing has been written yet.

There's no separate claim step or shared counter: work locally under
`work/shaped/<date>-<slug>/` through every step below. Nothing is committed or pushed until
Exit.

### 2. Read the codebase

Read the modules the change touches, their colocated READMEs, and the `docs/decisions/` records
for those areas — a spec that contradicts a standing decision re-litigates it by accident.
Ground every claim in the real codebase: the spec must name real modules and observed behavior,
tickets must cite exact paths. A spec written without reading the code describes an imaginary
architecture indistinguishable from the real one until someone tries to build it.

### 3. Sketch the test seams

Pick the seams the acceptance tests will attach to — the boundaries where behavior gets
observed. Prefer seams that already exist; place any new one as high as possible; fewer is
better, one is ideal. This choice is upstream of everything else: Behavioral Requirements and
Acceptance Criteria are phrased at an observable boundary, and the seam is that boundary — pick
it late and the spec gets rewritten around it. Confirm the sketch with the human before drafting;
the answer lands in the spec's `Testing Decisions` section.

### 4. Write spec.md

Start from [spec-template.md](spec-template.md), which owns section order, per-section rules,
and the `BR-`/`ID-`/`AC-` ID scheme — headings never vary between specs so tickets and tooling
can deep-link. `Out of Scope` is the highest-value section: agents wander, and an explicit
exclusion list is the cheapest fix. Sequencing rationale a dependency graph can't express — "03
ships behind a flag so we can measure before 04" — is one line in the `Tickets` section, next to
the order it explains. There is no separate plan document.

Done when every required section is filled and every sentence constrains behavior — nothing
restates what a reader could look up elsewhere.

### 5. Write the tickets

Full decomposition, every ticket with a concrete `Done when` — writing that check is a test of
the spec, and a ticket whose check you can't write yet is a spec hole found while it's still
cheap to fix. Start from [ticket-template.md](ticket-template.md) for structure and slicing:
each ticket is a vertical slice, independently testable, sized for one agent session. Later
tickets invalidated by landed work get amended at reconcile, not re-shaped — expect that, don't
pad against it.

Done when every acceptance criterion maps to at least one ticket's done-when; a criterion with
no ticket is bad slicing and must be fixed before moving on.

### 6. Invoke critique

Invoke `critique` with this bundle's ID and wait for findings (it blocks — that's the point of
asking before the human sees the plan). Findings are attacks, not fixes: triage each one, revise
the spec where it's right, and say plainly where you're not acting on one and why. This is
normal authoring, not a post-approval amendment — the spec isn't approved yet.

### 7. Exit

Two checks, both required:

1. **Every `Open questions` line carries a resolution.** No unresolved lines.
2. **The human approves the decomposition.** Present the spec and tickets; this is the Plan
   gate, and it's a human call because bad slicing is cheap to fix in a list and expensive to
   fix across twelve started tickets.

On approval: fold each resolved answer into the section it constrains and delete its line — the
implementing agent must receive a spec whose `Open questions` section is empty or absent (the
answer survives in the section it now constrains; git keeps the Q&A trail). Then commit and push
the whole bundle at once: `git add work/shaped/<date>-<slug>/`, commit, push. If the push is
rejected, someone else's bundle landed on the same date and slug — `git mv` to a disambiguated
slug and retry; this is the only point a collision can still occur, and it costs a rename, not a
rewrite.
