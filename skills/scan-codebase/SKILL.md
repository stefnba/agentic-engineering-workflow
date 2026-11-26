---
name: scan-codebase
description: Survey working code for improvement candidates the human triages — misplaced seams and types, modules that fail the deletion test, code that disagrees with ARCHITECTURE.md, GLOSSARY.md, or a decision record, and the module that ignores the pattern its neighbours follow. Use when the user asks to scan, survey, or audit a member or directory, asks what in the code is worth cleaning up, or asks whether the code still matches its architecture doc or decisions. Takes a scope path and an optional lens. Not for reviewing a change or a PR, and not for prose drift between documents.
argument-hint: '[scope path] [design | simplification | conformance | consistency]'
disable-model-invocation: true
---

# Scan codebase

Runs one read-only scanner per lens over a scope, in parallel from one prompt file, writes their
replies verbatim to a scan file, posts a digest of the top themes in chat, and turns what the human
picks into a bundle prompt or backlog lines. Written for any agent harness; use your harness's own
sub-agent mechanism.

## Path conventions

- `prompts/` and `templates/` paths are relative to this skill's directory, the folder holding this
  file.
- Every other path is relative to the repository root, `git rev-parse --show-toplevel`, not the
  current directory.

## Lenses

| Lens             | ID prefix | Sweep instructions                 | Finds                                                                            |
| ---------------- | --------- | ---------------------------------- | -------------------------------------------------------------------------------- |
| `design`         | `DE`      | `prompts/lenses/design.md`         | seams, types, dependencies, and names that sit in the wrong place                |
| `simplification` | `SI`      | `prompts/lenses/simplification.md` | modules, wrappers, options, and generality that fail the deletion test           |
| `conformance`    | `CF`      | `prompts/lenses/conformance.md`    | code that disagrees with the architecture doc, glossary, decisions, or AGENTS.md |
| `consistency`    | `CS`      | `prompts/lenses/consistency.md`    | the module that ignores a pattern the rest of the scope follows                  |

## Process

### 1. Resolve the scope

The argument optionally carries a scope path and a lens, in either order. A token that names a
directory under the repository root is the scope path; a token that is a lens name selects that
lens alone; every other token is reported back as unrecognized and ignored.

- **No scope path** — the scope is the repository root; the sweep covers every workspace member.
- **A scope path** — the sweep covers that directory and nothing outside it.
- **No lens** — every lens runs.

Resolve the work folder the scan belongs to: the narrowest work folder whose scope contains the
path, by the Which work folder rule of the `workflow-manager` skill, loaded by name. Record its
`work/backlog.md` path and the scan file path, `<work folder>/scans/<date>-<lens or all>.md`,
with `-2`, `-3`, … appended while the name is taken. `work/scans/` is gitignored: a scan is a
snapshot that goes stale as tickets merge, so it stays on the developer's disk and never in
history. Stop and say so if `git check-ignore <scan file path>` does not confirm the ignore; the
`setup-workflow` skill adds the line.

Record `git status --porcelain`, so the write step can show the scanners wrote nothing.

**Done when** the scope directory exists, the lens set is known, the scan file path is ignored, and
the backlog path and the status are recorded.

### 2. Dispatch one scanner per lens

For each lens in the set, read `prompts/scanner.md` and replace every placeholder:

- `{{checkout}}` — the absolute path of the repository root
- `{{scope}}` — the scope path relative to the repository root, or `.` for the root
- `{{backlog}}` — the backlog path from the resolve step
- `{{lens}}` — the lens name
- `{{prefix}}` — the lens's ID prefix from the Lenses table
- `{{sweep}}` — the full text of the lens's sweep instructions file
- `{{template}}` — the absolute path of `templates/lens-report.md`

Spawn one sub-agent per filled prompt, with that text as its entire prompt, on the model the Scan
row of `docs/conventions/models.md` names for this harness. Add no session context and no extra
instructions. Spawn them together: no scanner reads another's reply. In Claude Code that is the
Agent tool with the `general-purpose` type, every call in one message, in the foreground and
without worktree isolation.

**Done when** every scanner has replied. If the harness cannot spawn sub-agents, stop and ask the
human to run each filled prompt in a new session and paste the replies back.

### 3. Write the scan file

Fill `templates/report.md` with each reply verbatim, in the table's order, and the Same file list
as its comment says, then write it to the scan file path. Create `work/scans/` when missing.

Then confirm the scanners wrote nothing: `git status --porcelain` shows the same lines as at the
resolve step. A new or changed file is reverted and reported in the digest.

**Done when** the scan file holds every reply unchanged and the tree is otherwise as recorded.

### 4. Post the digest

Fill `templates/digest.md` from the scan file and post it as one chat message. Its comments carry
the theme rule, the order, the cap of five, and the recommendation rule; follow them exactly, so
the digest adds grouping and nothing else. Link every theme ID to its heading line in the scan
file: `grep -n '^### <ID> ' <scan file path>` gives the line. A `path:line` link opens at that
line in Claude Code and opens the file elsewhere. IDs under Below the line have no heading and
stay plain.

**Spot-check every theme you recommend 🎯 before posting**: open the file at its Where and read
the surrounding code. The recommendation is the one claim in the digest that is yours, so it
rests on a line you read. When the claim holds, post it as is. When the line moved or the claim
overreaches, recommend 📋 instead and say in one line what you found. When the claim is wrong,
drop the theme and say so. Never reword a finding; the scan file stays as the scanner wrote it.

**Done when** the digest is in chat, every 🎯 theme was read at its Where, and every theme ID
opens its finding in the scan file.

### 5. Triage with the human

Talk the digest through with the human, in whatever order they choose. Quote any finding in full
from the scan file when asked for its ID. Then act on each theme the human names:

- **🎯 Pick now** — give one paste-ready prompt for a fresh session:

    ```text
    Run the shape-bundle skill for <scope>: <theme title>. Read findings <IDs> in <scan file path> first and state their evidence in the spec; the scan file is not in history.
    ```

    Nothing goes to the backlog for a picked theme, since the bundle's own commit would delete
    the line.

- **📋 Follow-up** — add one line per theme to the backlog from the resolve step through the
  `backlog` skill, tagged `[drift] [<area>]` for a conformance theme and `[follow-up] [<area>]`
  otherwise, reusing the file's areas, stating the problem and its `path:line`, never the
  possible fix. The scan file is not in history, so the line carries its own evidence.
- **🗑️ Drop with a load-bearing reason** — a reason the next scan would need in order not to
  raise the theme again. Offer the `record-decision` skill once, in one line, and record only when
  the human says yes.
- **🗑️ Drop otherwise, or not named** — nothing happens. The theme stays in the scan file, and a
  rerun raises it again if it still holds. Ask once, never twice.

A line under a reply's Docs that lag the code goes to the caretaker it names, `glossary` or
`write-architecture-doc`, only when the human asks for it.

**Done when** every named theme has its prompt or its backlog line and nothing else has been
written. Then stop: shaping is the human's separate dispatch.
