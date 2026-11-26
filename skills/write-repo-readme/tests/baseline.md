# write-repo-readme: test prompts, failures and decisions

The skill's main gain is true content: commands that were run, and no option or command the repository lacks. On small fixtures, current models already cut filler without it.

Run each prompt on a fresh sub-agent, once without the skill and once told to read the skill first. Without the skill, forbid the Skill tool and reading the skills directory. With the skill, add "proceed without questions; nobody can answer". Judge the README files and `git status`, not the reports. Results below are from 2026-11-26, one sample per cell, on the `sonnet` and `haiku` aliases of that date.

## Fixtures

**Fixture A, no README.** A command-line tool of about 60 lines in one package: a manifest, a task file with install, test and lint targets, one test, one sample input, two docs files, a changelog, a license, an agent instruction file that states the test commands, and a frozen folder marked only by a comment in its one file.

**Fixture B, a bloated README.** Fixture A plus a 127-line README and a short translated sibling. Seed the README with these, since each one tests a rule:

| Seeded content                                                                 | Rule it tests                         |
| ------------------------------------------------------------------------------ | ------------------------------------- |
| Emoji headings, badges, features, tech stack, tree, roadmap, fork steps, thanks | What goes in                          |
| An install command and a test command that do not work                         | Run the commands                      |
| An option in the options table that the tool does not have                     | Run the commands                      |
| A warning about old input that exists nowhere else and cannot be checked       | Keep an unchecked claim               |
| A table between generator markers                                              | Leave generated text untouched        |
| A docs file linking to a README heading                                        | Search for links before cutting       |

## T1: create a README (fixture A)

> Create a README for this repository.

- **Without the skill:** Sonnet 46 lines, Haiku 68. Sonnet ran no command and wrote the sample output from reading the code. Haiku added a code-layout section, an example for an input it never ran, and one-line "Changes" and "License" headings.
- **With the skill:** Sonnet 52 lines, Haiku 51. Both ran every command shown, added a status line naming the supported inputs, and closed with a one-line license. Both reports list the facts the agent instruction file also states.
- **Not fixed at the time:** Haiku restated a rule for changing the code ("add no third-party dependencies") under Development. Countered afterwards in the template's Development comment and the "Belongs elsewhere" table. Not rerun.

## T2: shorten a bloated README (fixture B)

> The README of this repository is too long and nobody reads it. Fix it.

- **Without the skill (Sonnet):** 127 to 52 lines. Cut all the filler unprompted. Replaced the broken commands by reading the task file. Kept the option that does not exist, and a one-line "License" heading.
- **With the skill (Sonnet):** 127 to 52 lines. Removed the missing option, ran the replacements for both broken commands, added verified output, kept the warning and the generated block.
- **With the skill (Haiku), first run:** 127 to 57 lines. Deleted the warning because it "cannot be verified from the repo". The guardrail "state only what you observed" caused it. Rule added: keep an existing claim that passes the deletion test and cannot be checked, and report it as unchecked.
- **With the skill (Haiku), rerun after that rule:** 127 to 62 lines. Warning kept and reported as unchecked.
- **Accepted, not countered:** every skill run cut the linked heading and reported the broken link instead of fixing it. The skill may write only the root README.

## T3: one change (fixture B)

> Add a note to the README that `<input kind>` uses `<a format detail the docs already state>`.

- **Without the skill (Haiku):** a two-line diff, placed after the generated block.
- **With the skill (Haiku):** the same two-line diff, no outline, and a report naming the broken install command it left alone.
- **Not fixed:** the note repeats a docs file. The skill run did not say so. The request asked for the note, so the duplicate is the owner's call.

## Not tested

- The outline round trip with an owner who answers.
- A review-only request.
- A monorepo, a repository with no manifest, and a README in another format.
- A fixture large enough to tempt a features list or a directory tree in T1.
