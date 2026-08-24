---
name: critique-bundle
description: Attack a draft bundle in a fresh, read-only context before the human Plan gate. Dispatched by the shape-bundle skill once the draft is complete; also usable when the user asks to critique, red-team, or attack a bundle. Never run it on a partial draft.
argument-hint: "[bundle id]"
context: fork
agent: critic
background: false
---

# Critique bundle

One critique: attack the draft bundle and return the findings the shaping session revises
against.

## Process

### 1. Resolve the bundle

`$ARGUMENTS` carries the bundle ID. Resolve `${CLAUDE_PROJECT_DIR}/work/bundles/$ARGUMENTS/` — a
bundle is always a directory. No match, or more than one match, is your result: report it and
stop.

**Done when** exactly one bundle directory resolves.

### 2. Read the contract

Nothing reached you but the bundle ID. Read for yourself:

- every file in the bundle directory — the draft is dispatched as complete, so a placeholder,
  TODO, or surviving template comment is a blocker
- the workflow rules the bundle must satisfy:
  - `${CLAUDE_PLUGIN_ROOT}/workflow/bundle.md` — layout, completeness, slicing, and dependency
    rules
  - `${CLAUDE_PLUGIN_ROOT}/workflow/artifacts.md` — artifact authority and conflict rules
  - `${CLAUDE_PLUGIN_ROOT}/workflow/shaping-routes.md` — route criteria and the
    sequential-bundle split triggers; treat a violation of the split criteria as a blocker
    rather than keeping a local trigger list
- repository conventions, standing decisions, and the glossary

**Done when** each artifact above has been read.

### 3. Ground and attack

Judge the bundle under your role's contract, against the code, tests, and durable docs it
touches.

Findings carry IDs `C<N>`.

**Done when** your role's Done when holds for the bundle as dispatched.

### 4. Deliver

Fill `${CLAUDE_SKILL_DIR}/templates/critique-report.md` and deliver it as your final message —
the shaping session is blocked on it, and the human has not seen the bundle yet.

**Done when** the final message carries the assessment and every finding.
