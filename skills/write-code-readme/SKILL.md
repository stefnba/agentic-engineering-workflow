---
name: write-code-readme
description: Use when asked to document or explain a source directory, module, or package, or told its code is hard to follow — including a flow chart or local README of it — and when a rename or deletion leaves such a README naming old code. Not for top-level READMEs, ARCHITECTURE.md, or format references.
---

# Write code README

Leave the directory with a `README.md` that tells a newcomer, before they read the code, which function does what, in which order, and why. Every name and output in it holds at this commit.

## Path conventions

- `templates/`, `prompts/` and `references/` paths are relative to this skill's directory, the folder holding this file.
- `../writing/` is the sibling `writing` skill, in the same skills directory as this one.
- Every other path is relative to the repository root, `git rev-parse --show-toplevel`, not the current directory.

## Guardrails

**Name the code exactly: functions, classes, modules, private helpers.** Names are what this README is for, unlike an architecture doc.

**Change the README in the same change as any name, rule, step, or output it describes.** A refactor makes it false otherwise, often within the hour.

**Show only outputs and values you produced by running the code**, including a single return value or object written inline. A hand-written one reads as authoritative and can be one the code never emits.

**Run only code that calls no external service and reads no secrets file: no network, warehouse, model, or `.env`.** Build its input and configuration in memory instead.

**Place the worked example right after the main mechanism's section**, so every later section can refer back to it.

## Process

### 1. Locate the README and pick the mode

The README explains one directory: the deepest one holding the entry point and the modules it calls. The entry point is the function that does the directory's main job, not a runner or handler that only wraps it. When no single function does the job, because a caller outside the directory calls several of its functions in sequence, that sequence is the main mechanism and the caller is its Entry. A subpackage with its own entry point gets its own README. The file lives at `<directory>/README.md`.

Pick the mode:

- **Write**: the directory has no README.
- **Update**: this task's change renames, moves, or removes a name the README mentions, reorders a flow it draws, or changes an output it shows.
- **Review**: the user asks whether the README is accurate or says it is hard to follow, or it contradicts the code you are reading.

**Done when** you can name the README's path and the mode.

### 2. Gather the facts

Read, in one batch:

- every source file in the directory, in full
- the callers of the directory's entry point, up to the outermost entry point a person runs: a command, a route, a job
- what the directory exports to other code: its `__init__.py`, `index` file, or equivalent
- the nearest `AGENTS.md` and architecture doc above the directory, and every other doc that already explains this code, such as a walkthrough or a user-facing format reference
- in update and review mode, the current README in full

**Done when** you can state the entry point, its steps in order, the public surface, and every other doc that explains the same code.

### 3. Run the worked example

1. **Take the input.** In write mode, build one small, complete input in memory. In update and review mode, reuse the README's existing example.
2. **Run it.** Write a script outside the repository that calls the entry point on the input. Run it the way the repository's instructions or task runner run code.
3. **Run at least one variation** that breaks or exercises the main mechanism.
4. **Capture every output verbatim.** When one is too long to show, keep an excerpt of whole lines and say in the README that it is one.

**When the entry point needs an external service, run the pure function beneath it**, and say in the README which function the example calls.

**When nothing beneath it runs without one, hand the script to the user**, as the repository's instructions require, and leave the outputs out until they return.

**Done when** every output the README will show is pasted from a run.

### 4. Draft or correct the README

**Read `../writing/references/explain.md` and `references/notation.md` before drafting or correcting**; the first holds the prose rules for a document that explains, the second the written form of every name and the diagram shapes. Where `explain.md` and `templates/README.md` disagree, the template wins.

- **Write mode:** copy `templates/README.md` to the README's path, fill each section from its comment, drop the sections its comments allow you to drop, and delete every `<!-- -->` comment.
- **Update mode:** change the sections the change affects, and fix any other stale name you find on the way.
- **Review mode:** check each section against what the gather step found, and fix each mismatch or unclear passage inline.

**Done when** every section states only what the gather and worked-example steps confirmed, and no comment or placeholder remains.

### 5. Keep one detailed explanation and make it reachable

**Cut every other doc that explains the same mechanism in detail to a summary of a few lines that links to the README.** A user-facing format reference stays as it is: it answers what may be written, and the README answers how the code enforces it.

**In write mode, point to the README from its directory's line in the architecture doc's codebase map**, when the doc has one. Use a link, or `see README.md` when the map is a fenced tree.

**Done when** no other doc repeats the README's step-by-step detail, each doc you cut links to the README, and the codebase map points to it.

### 6. Verify every name

1. **Grep each function, class, and constant the README names** in the module the README places it in.
2. **Check that each path the README names exists.**
3. **Check the written form of each name and each diagram node against `notation.md`**, its sections Names in prose and tables, and Diagrams.
4. **Count the summary's sentences and each section's bullets against the caps in the template's comments.**
5. **Fix or delete every miss.**
6. **Rerun the worked example** when the code changed since you last ran it.

**Done when** every name resolves in the module the README gives it, and every output matches a fresh run.

### 7. Have a fresh reader attack it

Run this step in write and review mode, and in update mode when a diagram or the worked example changed.

Fill `prompts/review.md`:

- `{{readme}}`: the README's absolute path
- `{{related}}`: one sentence per other doc the gather step found, naming its path and what it covers, or nothing
- `{{explain_rules}}`: the absolute path of `../writing/references/explain.md`
- `{{notation}}`: the absolute path of `references/notation.md`
- `{{template}}`: the absolute path of `templates/README.md`

**Spawn one sub-agent with that text as its entire prompt and no session context.** Use the model the repository's model conventions assign to review sub-agents, when it has any.

**Check each finding against the code, then apply it or reject it.** Where a finding contradicts the template, the template wins unless the finding shows a statement is false.

**Done when** every finding is applied, or rejected with a reason you can state.

### 8. Report

Report:

- the README's path and mode
- every other file you edited
- each reviewer finding you rejected, and why
- any code problem you noticed, such as a stale docstring or a dead branch; fixing code is outside this skill
- the example script's path, with an offer to commit it as a test so a reader can rerun the example

**When a task had you read most files of a directory without a README, offer to write one.**
