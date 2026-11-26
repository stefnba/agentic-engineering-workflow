# Harness-agnostic skills: learnings and decisions

Findings from making the workflow skills work outside Claude Code, recorded 2026-09-30. The skills
were reworked and proven first in a consuming repository, `gm_gca_ai` (commits `19bce8a5` and
`738b0f9f` on `app/business-performance-studio`), and are to be ported back here. The general
cross-harness research, covering manifests, discovery paths and variables, lives in the
`plugin-small-starter` repository's `docs/README.md`; this file records only what we tested and
decided on top of it.

## How we tested

- **Harnesses:** Claude Code 2.1.247, GitHub Copilot CLI 1.0.78, and Codex CLI 0.159.2 (model
  `gpt-6.1-sol`), each run headless with a fresh session per scenario.
- **Setup:** throwaway git repositories with a member directory (`apps/member`). Every file carried
  a random token, so a correct answer proves the file was read, and every script logged its own
  runs, so a script run can't be faked.
- **The hard case:** sessions started **inside the member directory**, not at the repository root.
- **Checks:** results were judged from the tool-call traces, not only the final answer (see
  Learnings: agents hide broken setups).
- **Coverage:** one run per harness and scenario, with toy files. Where the real skills were
  checked, it was 18 read-only sessions on the reworked skills in `gm_gca_ai`.

## Decisions

| #   | Decision                                                                                                                                       | Instead of                                                                   |
| --- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| 1   | Distribute the skills by copying them into each repository: `npx skills add <repo> --skill '*'`, or a plain copy of `skills/`                  | a plugin install                                                             |
| 2   | Files that several skills share, and none owns, live in a lightweight reference skill, `workflow-references`                                   | a non-skill `_shared/` folder, the consuming repo's `docs/`, the plugin root |
| 3   | A file that belongs to one skill stays with it; a dependent skill reaches it by sibling path (e.g. `review-pr` → `../review-changes/prompts/`) | moving it to the reference skill, or loading the owner skill                 |
| 4   | Reference another skill's file by the **hybrid** pattern: sibling path, a "Requires the `<skill>` skill" line, fallback to loading by name     | always loading by name; a bare sibling path                                  |
| 5   | Scripts with human gates stay in `workflow-manager`, and callers use that skill by name                                                        | calling its scripts by path                                                  |
| 6   | A skill that hands a prompt to a subagent fills in absolute paths through placeholders (`{{rules}}`, like `{{bundle}}`)                        | relative paths in the prompt                                                 |
| 7   | Every skill that refers to a path has a `## Path conventions` section                                                                          | an implicit convention                                                       |
| 8   | Skill text uses no `${CLAUDE_*}` variables and no repository-root paths into a skill (`.agents/skills/<skill>/…`)                              | —                                                                            |
| 9   | Values a repository owns (integration target, worktree directory, conventions) stay in its docs, written by `setup-workflow`                   | —                                                                            |
| 10  | No automated path lint                                                                                                                         | a `lint-skills.sh` wired into `make lint`: too complex for the value         |

Why each one holds is in the Learnings below.

## Learnings

### Distribution: why not a plugin (decision 1), verified

The requirement is "installed for one project, not globally".

| Harness     | Plugin installed for one project only                                                                                            | Skills copied into the repo |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------- | --------------------------- |
| Claude Code | works (`--scope project`), **but only loads when the session starts at the repo root**; from a member it listed no plugin skills | found from a member         |
| Copilot CLI | no scope option: installs are global (`--plugin-dir` is per session only)                                                        | found from a member         |
| Codex CLI   | global only (`~/.codex/plugins/cache`)                                                                                           | found from a member         |

`npx skills` gives per-project installs, `skills update`, and a `skills-lock.json`, with the same
layout as a manual copy: `.agents/skills/`, plus `.claude/skills/` as copies or symlinks.

### Where shared files can live (decision 2), verified

| Home                                                    | Plugin install                                                             | Copied skills       | `npx skills add` |
| ------------------------------------------------------- | -------------------------------------------------------------------------- | ------------------- | ---------------- |
| Reference skill                                         | works                                                                      | works               | installed        |
| Non-skill folder next to the skills (`skills/_shared/`) | works                                                                      | works (manual copy) | **dropped**      |
| Plugin-level folder (`<plugin>/references/`, `../../`)  | works                                                                      | missing             | missing          |
| `${CLAUDE_PLUGIN_ROOT}/…`                               | Claude only; Copilot and Codex saw the literal text and _guessed_ the path | —                   | —                |

- `npx skills add` installs only folders that contain a `SKILL.md`, in copy and in symlink mode, so
  a `_shared/` folder silently disappears. After `npx skills update`, a hand-copied `_shared/` would
  also go stale next to updated skills, and a check that the folder exists can't detect that.
- Repo docs are the wrong owner for workflow rules: every repo gets a copy that drifts with each
  skill update.

### Referencing another skill's file (decisions 3–6), verified

The same scenarios passed in all three harnesses:

- **Own files** by a path relative to the skill's folder: works.
- **Another skill loaded by name:** the harness then gives its directory. This works, including
  inside a subagent.
- **Sibling path** (`../<skill>/…`): works whenever skills are installed side by side, which
  `npx skills`, a plugin, and a manual copy all do.
- **The hybrid fallback:** with the reference skill installed in a _different_ skills folder than
  the caller, all three detected the missing sibling path and fell back to loading the skill by
  name.
- **Subagents:** the calling skill filled in the absolute path, and only the subagent read the file.

Token cost, verified in Claude Code and **suspected** as a general pattern: the ~100 tokens of a
reference skill's `SKILL.md` don't matter. The extra round trip does: each extra step re-sends the
whole context (~50k tokens, mostly cached). The sibling path saves that round trip. Codex totals
were flat noise. The real lever is the size of the shared file itself: `bundle-rules.md` is ~3.7k
tokens and is read up to three times per shaping.

Loading an owner skill only to find a path costs its whole `SKILL.md` (~2k tokens for
`workflow-manager`) and can bring in conflicting instructions (`review-changes`' local-review
steps inside `review-pr`). The hybrid pattern avoids both, except in the fallback.

### Repository-root paths fail on script runs (decision 8), verified

With `.agents/skills/<skill>/…` paths and a session started in a member:

- **File reads:** all three agents quietly resolved them against the repo root.
- **Script runs:** Claude Code and Codex failed on the first try (exit 127). Copilot only succeeded
  because it added `cd <root> &&` on its own. A subagent in real use did the same `cd`.

### Agents hide broken setups, verified

When a skill or plugin wasn't loaded, agents often searched the disk, found the files, and reported
success. The project-scoped Claude plugin started from a member "worked" this way. **Judge a probe
by its tool trace, not its answer.**

### Smaller findings

- **The red "Failed" subagent reads were not path errors** (verified). The `cat` worked; a trailing
  `ls` of a missing `docs/decisions/` made the command exit 1. The reviewer prompts now say "check
  which exist before reading or listing them".
- **Codex needs a real install to test plugins** (verified). An isolated `CODEX_HOME` can't reuse the
  login, which lives in the macOS keychain, not in `auth.json`. `codex plugin remove` and
  `claude plugin uninstall` both leave a copy in their plugin caches.
- **Only some skills need path rules** (decision 7). The section covers only the bullets a skill
  needs: its own bundled folders, a sibling skill's file, and repository paths resolved from
  `git rev-parse --show-toplevel`. A skill with none (`interview-me`) gets no section.

## Patterns

A skill using a shared reference file:

```markdown
## Path conventions

- `templates/` paths are relative to this skill's directory, the folder holding this file.
- The bundle rules are `../workflow-references/references/bundle-rules.md`, relative to the same
  directory. Requires the `workflow-references` skill: if that path is missing, load that skill by
  name to find its directory; if that fails too, stop and tell the human to install it.
- Every other path is relative to the repository root, `git rev-parse --show-toplevel`, not the
  current directory.
```

A wrapper using its owner's files, with protection against conflicting instructions:

```markdown
- The prompts are `../review-changes/prompts/`, relative to this skill's directory, the folder
  holding this file. Requires the `review-changes` skill: if that path is missing, load that skill
  by name only to find its directory, and keep following this skill's process, not its steps; if
  that fails too, stop and tell the human to install it.
```

The reference skill itself:

```markdown
---
name: workflow-references
description: Reference files shared by the agentic workflow skills. Load it only when another skill names it; it is not a task on its own.
---

# Workflow references

## Path conventions

- `references/` paths are relative to this skill's directory, the folder holding this file.

## Files

| File                         | Holds                                                                                            |
| ---------------------------- | ------------------------------------------------------------------------------------------------ |
| `references/bundle-rules.md` | a bundle's lifecycle, shaping routes, layout, completeness, slicing, dependencies, and authority |
```

Commands a human pastes, such as `implement-ticket`'s accept command, get the absolute path of the
owning skill's script: `<workflow-manager dir>/scripts/branch.sh complete <pr> <sha>`.

## Best practices from plugin-small-starter

Rules from the starter's research that still apply to copied skills. Its `docs/README.md` has the
sources and the full harness tables; plugin manifests and marketplaces are left there, since we no
longer ship a plugin.

### The skill format every harness reads

- **Follow the Agent Skills specification** ([agentskills.io](https://agentskills.io/specification)):
  - `name` is `[a-z0-9-]`, 1–64 characters, and **must match the directory name**.
  - `description` is at most 1024 characters and says _when_ to use the skill.
  - The only other standard fields are `license`, `compatibility`, `metadata` (a string map), and
    the experimental `allowed-tools`.
- **Keep `SKILL.md` under ~500 lines and ~5k tokens.** Put detail in `references/`, linked one
  level deep: a reference must not point to further references.
- **Treat `.agents/skills/` as the universal location.** Codex, Gemini, OpenCode, Amp and
  VS Code/Copilot read it; Claude Code reads `.claude/skills/`. Codex looks for `.agents/skills/`
  in the current directory and every parent up to the repo root.

### Claude-only features are extras, never dependencies

**In Claude Code only:**

- `` !`cmd` `` shell injection in `SKILL.md`
- `${CLAUDE_*}` substitution in skill text
- a plugin's `bin/` added to `PATH`
- plugin `settings.json`

Hooks exist in Claude Code, Codex, VS Code and Gemini, but each uses its own format.

The old workflow depends on more Claude-only mechanisms than the starter covered, counted across
this repo's `skills/`:

- **Frontmatter:** `disable-model-invocation` (11 skills), `model` (10), `context: fork` with
  `agent` (6), `background` (6), `hooks` (2), `argument-hint` (17)
- **Folders:** `agents/` (5 subagent definitions) and `output-styles/`

**Suspected, not tested:** other harnesses ignore these fields. If so:

- a user-only skill becomes one the model can trigger itself
- a forked skill runs inline
- a write boundary enforced by a hook becomes prose only

Each one needs a portable replacement or an accepted loss when porting back.

### Scripts

- **A script finds its own location** (`BASH_SOURCE`, `__file__`) and **treats the current directory
  as the user's repo**, never as the skill's.
- **Find the workspace root by walking up:** the nearest ancestor with a marker folder, then
  `git rev-parse --show-toplevel`, then `pwd`. The marker matters when the workspace sits inside
  another git repo or a monorepo.
- **Treat harness variables as hints.** `CLAUDE_PLUGIN_ROOT` and `PLUGIN_ROOT` are missing from the
  environment of commands the model runs.
- **Never write into the skill's own folder.** An install or update replaces it. Write state to a
  dot-folder in the repo.
- **Where a script lives:**
  - used by one skill: that skill's `scripts/`
  - tools for one area: a manager skill that other skills use by name (our `workflow-manager`)
  - maintainer tooling (copy, sync, release): the source repo's top-level `scripts/`, never
    referenced by a skill
- **A small helper that several skills' scripts need** is copied into each skill's `scripts/` from
  one canonical copy in the source repo, which a sync script checks (the starter's `shared/` and
  `sync-shared.sh --check`). Unlike a `_shared/` folder, this survives `npx skills add`, because
  each copy sits inside a skill. Reference _docs_ still go to a reference skill (decision 2), which
  keeps one copy instead of several.

### Settings a repository can override

Resolve each setting in layers, highest priority first:

1. a file in the repo (this workflow uses `docs/conventions/`)
2. an environment variable
3. a default bundled in the skill's `references/` or `assets/`

The skill reads the layers; it never writes the repo's file.

### Monorepos

- **Resolve workspace paths from the repo root, never the current directory**, which is what the
  repository-path bullet under Path conventions enforces.
- **Keep app-specific paths out of the skills.** The consuming repo owns them. The starter's
  pattern is a map in the repo plus a fallback convention (`find-context.sh`): per-package docs are
  listed in a repo file, and anything unlisted is found by walking up for `AGENTS.md`, `README.md`
  and `docs/ARCHITECTURE.md`.
- **Let a folder's existence decide ownership.** A member with its own `work/` owns its work;
  otherwise the root's `work/` does. A per-member folder is created only on an explicit request.
  A line in the member's `AGENTS.md` is a hint to the model, never the mechanism. `workflow-manager`
  already follows this. The alternatives the starter rejected:
  - parsing a pointer out of `AGENTS.md`
  - a root marker inside the member
  - a config list of folders

### Symlink or copy `.claude/skills`

Only Claude Code needs `.claude/skills/`; every other harness we tested reads `.agents/skills/`. The
starter's rule "copies, not symlinks" was overstated. Reviewed on 2026-10-05:

- **Symlinks are the default choice**, because they keep one copy and nothing drifts.
  - Git stores a symlink as a link (mode `120000`), and macOS/Linux clones get a working link
    (verified).
  - Claude Code loads skills through both layouts (verified): the single folder link in `gm_gca_ai`
    (`.claude/skills → ../.agents/skills`), and one link per skill, which `npx skills add` creates
    by default (`.claude/skills/<skill> → ../../.agents/skills/<skill>`).
  - Sibling paths such as `../workflow-references/…` resolve through either layout (verified).
- **Copy when a repo has Windows contributors using Claude Code.** Git for Windows usually checks
  out with `core.symlinks=false`. The link then becomes a small text file holding its target path
  (verified by simulating that setting), so Claude Code finds no skills (suspected; not run on
  Windows). Turning symlinks on there needs Developer Mode or admin rights plus
  `core.symlinks=true`.
- **Copies drift on hand edits.** `npx skills add --copy` writes both folders and `npx skills update`
  refreshes both. An edit made directly in one copy is not mirrored.
- **"Codex drops symlinks when it installs a plugin"** (starter, unverified) is about symlinks inside
  an installed plugin. It has no bearing on skills copied into a repo.
- **A copy script must only replace a folder that already holds a `SKILL.md`,** never an unrelated
  folder (the starter's `vendor-skills.sh` does this).

### Starter questions our tests answered

- **Codex installs from the root `plugin.json` and finds `skills/` by convention** (verified).
- **A Codex marketplace accepts `path: "./"`**, a plugin that is its own marketplace (verified).
- **Started inside a monorepo member:** copied skills load in all three harnesses. A plugin loads in
  Codex (global) and Copilot (`--plugin-dir`), but a project-scoped Claude Code plugin does not
  (verified).

## When porting back

- **Replace the plugin-level material.** This repo's `workflow/` docs, reached via
  `${CLAUDE_PLUGIN_ROOT}`, become files in reference skills: `workflow-references` for shared
  rules, or the owning skill for a single owner. The same goes for the top-level `scripts/`
  (`${CLAUDE_PLUGIN_ROOT}/scripts/…`), which moves into the skill that owns it, as
  `workflow-manager` does in `gm_gca_ai`.
- **Decide each Claude-only mechanism** listed under "Claude-only features are extras, never
  dependencies": replace it with something portable, keep it as a Claude-only extra, or accept the
  loss in other harnesses.
- **Rewrite the install section** of `README.md`: `npx skills add <repo> --skill '*'` and
  `npx skills update` as the primary route, a plain copy of `skills/` as the fallback, and a note
  that the skills form a suite.
- **Drop "plugin" from the repository's self-description** once nothing depends on a plugin install.

## Open

- `land-bundle` hard-codes `make lint typecheck test`; each repository needs a place to name its
  own checks.
- A suite-completeness check in `setup-workflow`: every required skill installed, optionally with
  matching `metadata.version`.
- `npx skills update` from a git source (only a local path was tested).
- The "keep following this skill's process" fallback wording against a real conflicting
  `SKILL.md` (the mechanics are verified, the wording is not).
- Sessions started inside a git worktree.
- How other harnesses treat the Claude-only frontmatter above (`disable-model-invocation`,
  `context: fork`, `hooks`); only Claude Code's behavior is known.
- Gemini CLI, OpenCode, Cursor and Amp: none were tested. Their discovery paths come from
  documentation, some of it secondary.
- Whether harnesses pick up a member's `AGENTS.md` hint (e.g. "this app's notes live in its own
  `work/`") and act on it without being told. This is still open from the starter.
- Skill triggering: Copilot twice searched the disk instead of loading a named skill. That is about
  the skill descriptions, not the paths.
