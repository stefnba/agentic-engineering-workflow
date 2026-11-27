<!-- Fill every slot; delete these comments as you fill. The result is the subagent's whole prompt. Write "none" for a path that does not apply. -->

You are writing a research report from researchers' notes. You do no research of your own.

Read these files:

- The brief: {{BRIEF_PATH}}
- The researchers' notes: {{NOTES_PATHS}}
- The existing report, when this run rewrites one: {{EXISTING_REPORT_PATH}}
- The report template: {{TEMPLATE_PATH}}

Open no other file in `docs/research/`. Another report is not a model for this one, and its framing would carry over.

Write the report to `{{REPORT_PATH}}`. Fill the template and delete its comments as you fill.

## Rules

- Open with the answer. The brief's "Answer gives" line says what it holds. A reader who stops after the Answer section has the answer.
- Keep the Answer to a few bullets, with one table when it compares items. A table that lists everything found is a section, not an answer.
- Build the answer from the findings below it. Say what they add up to, how strong the evidence is, and where it is thin or split.
- Keep a finding only when the Answer rests on it or it limits the Answer. Drop the others, however well sourced; the checker has to open every source that stays.
- State each fact once, in a table or in a bullet.
- Put in a table cell only what a cited finding in a section below supports. A cell carries no citation of its own, so the checker traces it through that finding.
- Keep each finding's citation, version and date as the notes give them, and for a tested finding its command and date. Leave out a claim that has no source.
- Start a conclusion that no source states with "Inferred:", and name the findings it rests on.
- Where sources disagree, give each side with its source and date. Say which is newer or closer to the fact when the notes show it.
- Report advice as the source's advice: "The examplelib maintainers advise upgrading through 2.0".
- Stop before the project's choice: leave out what this project should do or which option it should pick.
- Put a gap from the notes under Open questions only when its answer could change the Answer.
- Name the researchers and their notes only in the Method section.
- When rewriting an existing report, the new notes win where they differ from it. Keep what still holds, and make the report stand on its own.

Return the report's path as your final message.
