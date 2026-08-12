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

**Author role**: take the current conversation context and codebase understanding and produce a
complete spec and ticket set. Synthesize — don't re-interview the human on what's already
settled; new questions follow the judgment-call rule below.

**Read-only on code**: the hook above blocks any `Edit`/`Write` outside `work/shaped/`. Shape
never writes code — an agent that can will, and retrofit the spec to it.

Two rules apply across every step below:

- **Ask judgment calls inline, immediately.** You're running with the human in the
  conversation. The moment a question surfaces that the repo can't answer, ask it and get the
  answer before continuing; record it on the spot as `- [resolved] <question>? → <answer>`.
  Questions the repo already answers, resolve yourself, citing the file. If two or three
  questions pile up before you've written anything, stop and ask them rather than reading
  further hoping one resolves itself.
- **Surface drift, don't route around it.** What you're reading — a legacy brief, an old
  backlog line, this conversation — may reference something since moved, renamed, or never
  built. Say what you found and ask the human how to handle it. Don't invent the missing piece
  and don't fold designing it into this bundle's scope.

## Process

### 1. Check for overlap

Skim `work/shaped/` and `work/active/` for bundles topically related to what's being shaped —
a judgment call, not a string match: two slugs with no characters in common can still be the
same feature. If something looks related, ask the human — same effort, follow-up, or
unrelated? — before reading anything else: duplicate shaping is cheapest to catch before any
work has been spent.

### 2. Read the codebase

Read the modules the change touches, their colocated READMEs, and the `docs/decisions/` records
for those areas — a spec that contradicts a standing decision re-litigates it by accident.
**Ground every claim in the real codebase**: the spec must name real modules and observed
behavior, tickets must cite exact paths — a spec written from memory describes an imaginary
architecture.

### 3. Sketch the test seams and confirm with user

Pick the seams the acceptance tests will attach to — the boundaries where behavior gets
observed. Prefer seams that already exist; place any new one as high as possible; fewer is
better, one is ideal. Behavioral Requirements and Acceptance Criteria are phrased at the seam —
pick it late and the spec gets rewritten around it. Confirm the sketch with the human before
drafting; the answer lands in the spec's `Testing Decisions` section.

### 4. Create the bundle

Decide the form — the size is known now: if the whole change fits one agent session, the
bundle is a **single file** `work/shaped/<date>-<slug>.md` — the spec plus the ticket's
operational parts in one document (the single-file variant in spec-template.md); skip the
tickets step. Anything larger is a directory `work/shaped/<date>-<slug>/` with `spec.md` and
`tickets/`.

Derive the kebab-slug from the title and check nothing matches `work/*/$(date +%F)-<slug>*` —
an existing bundle could be a directory or a single file. Everything stays local; nothing is
committed or pushed before the human approves at Exit.

### 5. Write the spec

Copy the skeleton from [spec-template.md](spec-template.md) and fill it — section rules and
the `BR-`/`ID-`/`AC-` ID scheme live there. `Out of Scope` is the highest-value section:
agents wander, and an explicit exclusion list is the cheapest fix. There is no separate plan
document.

Done when every required section is filled and every sentence constrains behavior — nothing
restates what a reader could look up elsewhere.

### 6. Write the tickets (directory bundles only)

Full decomposition, every ticket with a concrete `Done when` — writing that check is a test of
the spec, and a ticket whose check you can't write yet is a spec hole found while it's still
cheap to fix. Copy the skeleton from [ticket-template.md](ticket-template.md) per ticket:
**each ticket is a vertical slice**, independently testable, sized for one agent session.
Enabling work comes first — make the change easy, then make the easy change. Wide refactors are
the one exception to vertical slicing: sequence them expand → migrate → contract (add the new
form, migrate in batches, delete the old form). Later tickets invalidated by landed work get
amended at reconcile, not re-shaped — expect that, don't pad against it.

Done when every acceptance criterion maps to at least one ticket's done-when; a criterion with
no ticket is bad slicing and must be fixed before moving on. (For a single-file bundle this
check collapses into its `Done when` section: every AC listed there.)

### 7. Critique and fix

Invoke the `critique` skill with this bundle's ID and wait for findings (it blocks — that's the
point of asking before the human sees the plan). Findings are attacks, not fixes: triage each
one, revise the spec where it's right, and say plainly where you're not acting on one and why.

### 8. Check

Self-verification before anything is presented:

- Every `Open questions` line carries a resolution — no unresolved lines.
- AC coverage still holds after critique revisions.
- No skeleton guidance comments survive in the spec or tickets.

### 9. Exit — present for approval

Present the decomposition for the human's OK — one numbered line per ticket:

```text
    NN — <title> — blocked by: <NN, NN | none> — delivers: <one line>
```

plus the spec's key parts — solution, seam, out of scope — and how each critique finding was
dispositioned. Then ask three things: is the granularity right, are the blocking edges correct,
should any ticket merge or split. This is the Plan gate, and it's a human call because bad
slicing is cheap to fix in a list and expensive to fix across twelve started tickets. **Do not
commit before the OK.**

On approval: fold each resolved answer into the section it constrains and delete its line — the
implementing agent must receive a spec whose `Open questions` section is empty or absent (the
answer survives in the section it now constrains; git keeps the Q&A trail). Then commit and push
the whole bundle at once — `git add` the directory or the single file — commit, push. If the push is
rejected, someone else's bundle landed on the same date and slug — `git mv` to a disambiguated
slug and retry; this is the only point a collision can still occur, and it costs a rename, not a
rewrite.
