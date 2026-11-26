# Brief for version 2

Constraints for designing this repository from an empty tree. It holds the owner's decisions and
tested facts about agent harnesses. It prescribes no structure: which skills exist, what each
owns, and how files are laid out are the design's to decide.

## What the repository is

A set of agent skills for a staged engineering workflow, installed into other repositories. It
replaces a first version the owner found too complex.

## Harness facts

**Might have changed since we tested it. Needs to be re-verified.**

Tested 2026-09-30 on Claude Code 2.1.247, GitHub Copilot CLI 1.0.78, and Codex CLI 0.159.2, in
throwaway repositories, with each session started inside a monorepo member directory. One run
per harness and scenario, judged from the tool-call trace.

**Installing**

- Skills copied into a repository are found from a member directory in all three harnesses.
- A Claude Code plugin installed for one project loads only when the session starts at the
  repository root. Copilot and Codex plugin installs are global.
- `npx skills add` installs only folders that contain a `SKILL.md`. Any other folder next to the
  skills is dropped without a message.
- Claude Code reads `.claude/skills/`. Codex reads `.agents/skills/` in the current directory
  and every parent up to the repository root.
- Claude Code loads skills through a symlink, either one link for the folder or one per skill.
  Git stores the link as a link on macOS and Linux. With `core.symlinks=false`, the usual Git
  for Windows setting, the link checks out as a text file (simulated, not run on Windows).

**Paths**

- A path relative to the skill's own folder resolves in all three.
- A path to a sibling skill (`../<skill>/…`) resolves in all three when the skills are installed
  side by side.
- A skill loaded by name reports its directory, including inside a sub-agent.
- A sub-agent reads a file reliably when the calling skill puts the absolute path in its prompt.
- A path written from the repository root (`.agents/skills/<skill>/…`) resolves for file reads.
  For script runs it failed with exit 127 in Claude Code and Codex.
- `${CLAUDE_*}` variables are substituted only by Claude Code. Copilot and Codex saw the literal
  text and guessed a path.

**Testing a setup**

- An agent whose skill did not load often searches the disk, finds the files, and reports
  success. Judge a probe by its tool trace, never by its answer.
- A read chained with a listing of a missing directory exits non-zero and looks like a failed
  read. Check that a path exists before reading or listing it.

## From earlier research, not retested

- The Agent Skills specification (agentskills.io) defines `name`, matching the directory name,
  and `description`, at most 1024 characters. Its other fields are `license`, `compatibility`,
  `metadata`, and the experimental `allowed-tools`.
- Only Claude Code has shell injection in `SKILL.md`, a plugin `bin/` on `PATH`, and plugin
  `settings.json`.
- Hooks exist in Claude Code, Codex, VS Code, and Gemini, each in its own format.
- Harness variables such as `CLAUDE_PLUGIN_ROOT` are missing from the environment of commands
  the model runs.
- An install or update replaces a skill's folder, so a script must write state elsewhere.

## Untested

Do not build on these without testing them first.

- `npx skills update` from a git source, and what it does to a locally edited copy.
- How other harnesses treat Claude-only frontmatter such as `disable-model-invocation`,
  `context: fork`, and `hooks`. Suspected: they ignore it, so a forked skill runs inline and a
  hook-enforced write boundary becomes prose.
- Cursor, Gemini CLI, OpenCode, and Amp.
- Sessions started inside a git worktree.

## Earlier versions

Two tags hold earlier material: `v1-final`, the first version, and `v2-baseline`, the skill
variants that evolved in three consuming repositories.

**Design the structure without reading either tag.** The point of the empty tree is a structure
that does not inherit theirs.

**Once the structure is settled, read `v2-baseline` when writing a skill.** Its wording was
corrected against real agent failures. `work/v2-skill-inventory.md` at that tag compares the
variants and names what to cut. Check it out beside this tree with
`git worktree add ../aew-baseline v2-baseline`.
