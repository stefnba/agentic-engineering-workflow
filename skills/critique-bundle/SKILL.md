---
name: critique-bundle
description: Use before the human Plan gate on a finished draft work bundle — when shape-bundle's self-check passes, or when the user asks to critique, red-team, or attack a bundle, or asks whether one is over-engineered, should have been a spike or a spec, or could be sliced differently. Not for a partial draft, and not for reviewing implemented code.
argument-hint: '[bundle reference, id, or path] [shape record from an earlier round]'
---

# Critique bundle

Runs two critics in order from prompt files and delivers one report. Written for any agent
harness; use your harness's own sub-agent mechanism.

## Path conventions

- `prompts/` and `template/` paths are relative to this skill's directory, the folder holding this
  file.
- The bundle rules are `../workflow-references/references/bundle-rules.md`, relative to the same
  directory. Requires the `workflow-references` skill: if that path is missing, load that skill by
  name to find its directory; if that fails too, stop and tell the human to install it.
- The shaping routes are `../shape-bundle/references/shaping-routes.md`, relative to the same
  directory. Requires the `shape-bundle` skill; resolve a missing path the same way.
- Every other path is relative to the repository root, `git rev-parse --show-toplevel`, not the
  current directory.

## Process

### 1. Resolve the bundle

The argument is a bundle reference, a bundle ID, or a bundle directory path. List the bundles in
this checkout with the `workflow-manager` skill's bundle listing.

Each bundle line reads `<status> <reference>`. Match the reference that equals the argument or ends
in `/<argument>`; for a path, match on its last directory. The bundle directory is
`<scope>/work/bundles/<bundle-id>`, where a root reference has no scope.

**Done when** exactly one reference matches, and you hold its directory as a path relative to the
repository root. None or several, or a non-zero exit, is your result: report it and stop.

### 2. Run the critics

The executability critic attacks only a settled shape, recorded in a shape record: the design
critic's reply, verbatim, plus the disposition of each alternative it raised.

**When the caller hands you a shape record, skip the design critic** and run only
`prompts/02-executability.md` with that record — the shape is already settled, and a fresh design
critic would reopen it.

Otherwise, run `prompts/01-design.md` and branch on its Shape verdict:

- **"no better shape found"** — its reply is the shape record. Run `prompts/02-executability.md`.
- **Alternatives raised** — stop here. Findings against a shape that an adopted alternative then
  replaces are moot.

To run a critic:

1. Read its file. Replace `{{bundle}}` with the resolved bundle path, `{{rules}}` with the absolute
   path of the bundle rules, in `01-design.md` `{{routes}}` with the absolute path of the shaping
   routes, and in `02-executability.md` `{{shape_record}}` with the shape record, verbatim.
2. Spawn one sub-agent with that text as its entire prompt, on the model the Critique row of
   `docs/conventions/models.md` names for this harness. Add no session context and no extra
   instructions. In Claude Code that is the Agent tool with the `general-purpose` type, in the
   foreground and without worktree isolation — a worktree would not contain the uncommitted draft.
3. Wait for its reply. Never run the two critics in parallel; the second reads the first.

**Done when** the executability critic has replied, or the design critic raised an alternative. If
the harness cannot spawn sub-agents, stop and ask the human to run each prompt in a new session,
in order, and paste the replies back.

### 3. Assemble the report

Fill `template/report.md`: paste each critic's reply verbatim into its slot, then derive the
Assessment line as the template's comment says.

**When the design critic stopped the run and no skill invoked you, end the report by asking the
human to adopt or reject each alternative.** Rerun this skill with the design reply and their
dispositions as the shape record.

**Done when** the report is delivered as your final message — or, when `shape-bundle` invoked you,
as the result it continues from.
