---
name: write-repo-readme
description: Use when creating, rewriting, updating or reviewing the README at the root of a repository — when the user says "create a README", "write the README", "update the README" or "review the README", when a repository has no root README, and when someone says the README is too long, bloated, outdated or unhelpful. Also use before adding or changing a section of a root README while doing other work. Not for a README inside a subfolder, or for other documentation files.
---

# Write the repository README

The repository has one root README that tells its reader what this is, whether it concerns them, how to run it and where to go next, and holds nothing they would skip.

## Guardrails

**Write only the root README.** Content that belongs elsewhere goes into a file that already exists, or into the report. A new file created to hold moved content spreads the bloat instead of removing it.

**State only what you observed in the repository or the owner confirmed.** A planned feature or a guessed command reads exactly as true as a real one. The age of the last commit and the tags shape a question to the owner; they never become a status line.

**Name in the outline every piece of an existing README you plan to remove, before removing it.** It may be the only place that fact is written down.

**Leave text between generator markers untouched**, and name the generator in the report. A tool rewrites that block on its next run.

## Process

### 1. Find the README and size the request

**List every README at the root, in any format, and any under the host's special folders such as `.github/`.** Edit the one that exists, in its format. Create `README.md` only when none exists. List translated siblings in the report as now out of date.

**If the request names one change, such as adding a section or fixing a command, skip the outline step.** Test the new content against "What goes in", run its commands as the run step says, change only that part, and report problems you saw in the lines you touched without fixing them.

Done when your reply names the file you will edit or create, and whether this is one change or the whole README.

### 2. Read to fill the slots

**Read these in full: the existing README, the agent instruction files and the top-level listing.**

**For everything else, read to answer a slot, and stop when it is answered.** A file read without a question turns into a section nobody asked for.

| Slot                 | Look first at                                                                                          |
| -------------------- | ------------------------------------------------------------------------------------------------------ |
| What it is, for whom | The manifest description, the entry point's help output, the opening lines of the docs index           |
| Status and limits    | The existing README, deprecation notices, the manifest; otherwise a question to the owner              |
| Prerequisites        | The manifest and toolchain version files                                                               |
| Install and run      | The task or build file, the manifest scripts, the container file                                       |
| Minimal example      | In this order: the existing README if it still runs, the examples folder, a documented example, a test |
| Development commands | The task or build file, then the CI job that runs the tests                                            |
| Pointers             | The docs folder and subfolder READMEs: titles and opening lines only, enough to link them              |
| Owner and license    | Whether a license file exists at the root; the owner or help channel is a question to the owner        |

**Open a source file only for a slot nothing else answers, and then only the entry point.** Run the tool's help output before reading its definition.

**Do the reading yourself, in one context.** It is small when it stops at the slots, and judging what a newcomer needs depends on having seen all of it.

**In a monorepo, read the workspace manifest and each package's manifest description.** The root README gets one line per package, linking to that package's README.

**With no manifest and no entry point, plan only the name, one sentence and the status**, and ask the owner for the sentence.

**Name the kind of repository and the reader you assume.** The kind decides what the README leads with:

| Kind                             | Reader                                         | Leads with                             |
| -------------------------------- | ---------------------------------------------- | -------------------------------------- |
| Library or package               | A developer deciding whether to use it         | Install and one minimal usage example  |
| Command-line tool or application | A user who wants to run it                     | Install and the first command          |
| Service                          | A teammate who has to run, change or deploy it | Owner, status, local run, deploy       |
| Collection, template, docs       | Someone deciding what to take from it          | What is in it and how to use one piece |

Done when every slot shows a source path, "ask owner" or "does not apply".

### 3. Outline and get it cut

**Open the outline with the reader you assume, in one sentence**, so the owner can overrule it before anything is written.

**List the sections you plan, one line each: what the section holds and where each fact comes from.** Choose them from "What goes in".

**Apply the deletion test to every line of the outline: if this were gone, what would the reader get wrong or be unable to do?** Nothing: cut it.

**For an existing README, add one line per existing section: keep, cut, move with the place it moves to, or "cut, no home" with its first line quoted.** Existing content passes the same deletion test as new content; being there already is not a reason to stay. The owner picks keep or drop for each "cut, no home".

**Keep an existing claim that passes the deletion test and that you cannot check, such as a warning about old input, and list it in the report as unchecked.** Remove a claim only when the repository contradicts it. The second guardrail limits what you add, not what the owner already wrote.

**Before renaming or cutting a heading, search the repository for links to it, and say in the outline which links break.**

**Close the outline with the questions only the owner can answer:** status, the owner or help channel, and commands you cannot run, such as a deploy.

**Send the outline and wait for the answer.** The owner cuts faster from an outline than from a finished draft.

**If the owner asked for a review only, stop here.** The outline is the review.

**If the owner said to proceed without questions, go on and put the outline in the final report.** Leave out every line an unanswered question would have filled.

Done when the owner has answered, or a branch above applies.

### 4. Run the commands

**Run every command the new README will show, in the order a newcomer would, and keep the output.** Use it for the "expected result" lines. Commands in sections marked cut are not checked.

**Include a command you could not run only when the owner confirmed it.** Leave an unconfirmed command out and name it in the report.

Done when every command in the outline is marked ran, confirmed, or dropped.

### 5. Write

**For a new README, fill `templates/README.md`, deleting each comment as you fill its slot.** Its headings are placeholders: rename them to fit the repository, order them by the "Leads with" column, and delete a slot that does not apply.

**For an existing README, edit in place.** Leave a section marked keep as written, except for a fact that is wrong. Rewrite it only when the owner asked for a rewrite.

**REQUIRED: use the `writing` skill for the prose.** This skill decides what the README contains; `writing` decides how each sentence reads.

**Give a heading only to content of more than one line, except a license section.** Status is a single line under the description. A license section, when the table in "Only when true for this repository" calls for one, gets its own closing heading, because a rendered page shows a line without one as part of the section above it.

Done when no template comment remains and every section traces to a line of the outline.

### 6. Cut and report

**Apply the deletion test again, sentence by sentence, to what you wrote.**

**Past about 150 lines, justify each section in the report or cut it.** A library whose README is its whole documentation can run longer; a line count alone is not a reason to cut specifics.

**Report these, in this order:**

- The reader sentence.
- What was left out and where it lives instead.
- Commands dropped as unverified, and questions left unanswered.
- Content removed from the old README that now has no home, and claims kept unchecked.
- Facts that the README and an agent instruction file both state.
- Translated READMEs now out of date, and generated blocks left untouched.

Done when the report holds each of those items, with "none" where empty.

## What goes in

**The rule behind every table here: the README holds what the reader needs to start and what the repository cannot tell them by itself.** The setup, run and test commands stay even though a manifest lists them, because the reader needs them before knowing where to look.

### Always, when it applies

The template carries these as slots:

- Name and one or two sentences: what it does and for whom.
- Status and limits, when a reader would otherwise assume wrong.
- Quick start: prerequisites with versions, install, one minimal example, the output that shows it worked.
- Development commands, when readers change the code: set up, run, test, and deploy for a service.
- Pointers: docs that exist, and where to get help or who owns it.

### Only when true for this repository

| Content                                     | Include when                                                                                                                                          |
| ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| One screenshot or short recording           | The result is visual                                                                                                                                  |
| "Why this and not X", or when not to use it | A well-known alternative exists and the reader will ask                                                                                               |
| Configuration values                        | Needed to get through the quick start; the rest belongs in reference                                                                                  |
| Folder map                                  | A top-level name misleads or hides a rule, such as a frozen folder                                                                                    |
| Known pitfalls or common tasks              | Each one traces to a failure that happened                                                                                                            |
| Install table                               | Several install paths exist and all work                                                                                                              |
| Badges                                      | Each one states a fact the reader acts on: build, version, license                                                                                    |
| Table of contents                           | The file is longer than about 150 lines                                                                                                               |
| License section                             | No license file sits at the root, the licensing differs by part, or the README is published where the license file is not, such as a package registry |

### Belongs elsewhere

**Link the place when it exists; when it does not, leave the content out and name it in the report.**

| Content                                              | Place                                                   |
| ---------------------------------------------------- | ------------------------------------------------------- |
| Full API, option or configuration reference          | The docs folder, generated docs, or the help output     |
| Full directory tree, description of the code layout  | The repository shows it                                 |
| Changelog, release history, roadmap                  | A changelog file, the releases page, the issue tracker  |
| Architecture and design history                      | An architecture doc or decision records                 |
| Rules for changing the code, instructions for agents | The agent instruction file or a contributing file       |
| Contribution process                                 | A contributing file; one sentence here when none exists |
| Full license text                                    | The license file                                        |

### Fails the deletion test in most repositories

A features list that restates the description, a tech-stack list, emoji in headings, generic "fork, branch, pull request" steps, acknowledgements, placeholder sections, and marketing adjectives.

### Commands the agent instruction file also states

**Keep the setup, run and test commands in the README, and name the duplicate in the report.** A human newcomer does not open the agent instruction file. The owner decides whether that file points to the README instead.

## Checklist

- [ ] The first lines say what it is and for whom.
- [ ] Every command shown was run or confirmed by the owner.
- [ ] Every link resolves to a file or page that exists.
- [ ] No heading other than a license section sits over a single line, and no section is empty or a placeholder.
- [ ] No file other than the root README changed.
