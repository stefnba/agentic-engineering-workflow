# Harness tests: what we ran ourselves

For an agent writing or installing a skill: which behaviour of Claude Code and Codex was tested here, and what is still unknown.

Sources and method: tests of 2026-09-30 on Claude Code 2.1.247 and Codex CLI 0.159.2, in throwaway repositories, with each session started inside a monorepo member directory. One run per harness and scenario, judged from the tool-call trace. This file was `docs/BRIEF.md` until 2026-11-26.

**These results might have changed since the tests and need to be re-verified.** The reports in `docs/research/` read sources and ran no harness, so they neither confirm nor replace these results.

## Tested

**Installing**

- Skills copied into a repository are found from a member directory in both harnesses.
- A Claude Code plugin installed for one project loads only when the session starts at the repository root. Codex plugin installs are global.
- `npx skills add` installs only folders that contain a `SKILL.md`. Any other folder next to the skills is dropped without a message.
- Claude Code reads `.claude/skills/`. Codex reads `.agents/skills/` in the current directory and every parent up to the repository root.
- Claude Code loads skills through a symlink, either one link for the folder or one per skill. Git stores the link as a link on macOS and Linux. With `core.symlinks=false`, the usual Git for Windows setting, the link checks out as a text file (simulated, not run on Windows).

**Paths**

- A path relative to the skill's own folder resolves in both.
- A path to a sibling skill (`../<skill>/…`) resolves in both when the skills are installed side by side. [`knowledge-across-skills.md`](../research/archive/knowledge-across-skills.md) reports it breaking under partial installs.
- A skill loaded by name reports its directory, including inside a sub-agent.
- A sub-agent reads a file reliably when the calling skill puts the absolute path in its prompt.
- A path written from the repository root (`.agents/skills/<skill>/…`) resolves for file reads. For script runs it failed with exit 127 in both.
- `${CLAUDE_*}` variables are substituted only by Claude Code. Codex saw the literal text and guessed a path.

**Testing a setup**

- An agent whose skill did not load often searches the disk, finds the files, and reports success. Judge a probe by its tool trace, never by its answer.
- A read chained with a listing of a missing directory exits non-zero and looks like a failed read. Check that a path exists before reading or listing it.

## From earlier research, not retested

- An install or update replaces a skill's folder, so a script must write state elsewhere.

## Untested

Do not build on these without testing them first.

- Sessions started inside a git worktree. The design assumes one worktree per ticket, so this test comes first.
- How Codex treats Claude-only front matter such as `disable-model-invocation`, `context: fork` and `hooks`. [`cross-harness-support.md`](../research/archive/cross-harness-support.md) found one data point: `disable-model-invocation` alone does not stop Codex from invoking a skill.
- Whether Codex needs its own plugin manifest. Two reference repositories report opposite results.
- Whether Codex keeps symlinks when it copies a plugin into its cache. One reference repository reports that it drops them.
- `npx skills update` from a git source, and what it does to a locally edited copy.
