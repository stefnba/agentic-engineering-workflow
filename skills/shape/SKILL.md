---
name: shape
description: Turn a picked candidate into design.md and its first tickets. Use for /shape <id> once a candidate has a brief, or the human points at a backlog line ready to shape.
argument-hint: "[candidate id]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Edit, Skill(critique *), Bash(mkdir -p docs/work/planned/*), Bash(git mv *), Bash(git add *), Bash(git commit *)
hooks:
  PreToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "${CLAUDE_PROJECT_DIR}/skills/shape/scripts/write-boundary.sh"
---

# Shape

The author role. Input is a brief or a backlog line; output is `design.md` and the first two or three tickets, inside the candidate's bundle. You are **read-only on code, structurally** — the hook above blocks any `Edit`/`Write` outside `docs/work/candidates/` and `docs/work/planned/`. An agent that can write code will write code and retrofit the design to it; this removes the option rather than relying on restraint.

## Read before writing

Resolve the bundle (`docs/work/*/$ARGUMENTS-*`) and read `brief.md` if one exists. Then read the actual repo: the files, directories, and colocated READMEs the design will reference. **Shaping cites real files** — a design that doesn't reference actual paths describes an imaginary architecture, and you can't tell the difference from inside your own head.

## Write design.md

Fixed headings, present tense — see how docs-rules and `docs/docs-structure.md` define `design.md` for the exact template and why the headings don't move. `Non-goals` is the highest-value section: agents wander, and an explicit exclusion list is the cheapest fix. Migration or rollout sequencing that a dependency graph can't express goes in `plan.md`; skip `plan.md` entirely if there's no such rationale — a table that just restates ticket order goes stale invisibly.

## Write the first tickets

Two or three, no more — later ones are written against assumptions this round of implementation will invalidate. Ticket format and slicing rules are docs-rules' territory; don't restate them here.

## Judgment calls happen inline, not in Open questions

You're running with the human in the conversation — unlike Implement, which is isolated and must stop-and-record. When you hit a real judgment question (not decidable from the repo), ask it directly and get the answer now. Record it resolved on the spot: `- [resolved] <question>? → <answer>`. Reserve unresolved `Open questions` lines for things nobody in the room can answer yet.

Evidence questions you resolve yourself, citing the file — don't ask the human something the repo already answers.

## Invoke critique before exit

Once `design.md` and the first tickets exist, invoke `critique` with this bundle's ID and wait for findings (it blocks — that's the point of asking before the human sees the plan). Findings are attacks, not fixes: triage each one, revise the design where it's right, and say so plainly where you're not acting on one and why. This is normal authoring, not a post-approval amendment — the design isn't approved yet.

## Exit

Two checks, both required:

1. **Every `Open questions` line carries a resolution.** No unresolved lines.
2. **The human approves the decomposition.** Present the design and tickets; this is the Plan gate, and it's a human call because bad slicing is cheap to fix in a list and expensive to fix across twelve started tickets.

On approval: `git mv` the bundle from `candidates/` to `planned/`. From this point `brief.md` is frozen — don't edit it again, even to tidy it; if it and `design.md` disagree from here on, `design.md` wins.
