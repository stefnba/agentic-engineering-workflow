# Explain branch: baseline prompts, failures and decisions

Run each prompt on a fresh Sonnet and a fresh Haiku sub-agent, once without the skill and once told to read
the skill first. Without the skill, forbid the Skill tool and reading the skills directory, through any
symlink to it included. Judge the files, not the reports. A script counting words, paragraph and sentence
length, and the share of text in lists and tables is enough to compare runs. Results below are from
2026-10-13 on a fixture of one Python package of about 1,900 lines and a 5,800-word explainer about it;
substitute a package and a dense explainer of the repository at hand.

## T1 — write an explainer from code

> Write a document for a new team member (an analyst who has not seen this code) explaining how `<package>`
> turns its input into its output. Read `<package>` to learn how it works; do not read `<the existing
explainer>`. Cover: what goes in, what comes out, the main mechanism, and `<one named edge case>`. Write
> the document to `<OUT>`. Keep every rule the code enforces.

Without the skill (Sonnet 2,093 words, Haiku 2,142): no reader or question stated; every error and parser
rejection listed inline; config keys, column suffixes and internal variable names in the prose; two examples
with different numbers; a closing section on a neighbouring package nobody asked for; paragraphs up to 131
words. Rules that fix it: name the reader; explainer or reference; open with the answer; one example reused;
delete a section the reader never asked for.

With the skill, two-skill draft (Sonnet 1,153, Haiku 1,170): reader and question in line two, one running
example, code identifiers down from 16 to 1 (Sonnet), rules moved to one reference table at the end, no
paragraph over 82 words. With the merged skill (Haiku 1,719, one sample): kind judged correctly, explain
branch only, one paragraph over 80 words; the extra length is a reference appendix of every code-enforced
rule, which the prompt's last sentence invites. Accepted, not countered: the prompt asks for it.

Rerun on 2026-11-26, after the reader sentence moved to the reply. Fixture: a standard-library package of
about 1,400 lines with no existing explainer. One sample per cell, on the `sonnet` and `haiku` aliases of
that date.

- Without the skill: Sonnet 2,669 words, Haiku 3,087. Both open with a "this guide is for" sentence. About
  80% of the words sit in lists and tables.
- With the skill: Sonnet 1,892, Haiku 2,151. Both replies state the kind and the reader. Both documents open
  with the answer, then a sources line. No paragraph runs over 100 words.
- Not fixed: both skill runs keep a command-line section the prompt did not ask for.
- Not fixed: both skill runs count a set that can grow ("a set of three generator functions", "Decoding has
  three steps"). The Sonnet reply reported no counts. The rule's list names files, skills, steps, rules and
  sections; functions are not on it.
- The runs without the skill show one such count between them. T1 does not tempt this failure, so it
  cannot test the count rule. The rule was reworded after this run; T3 tests it.

## T2 — rewrite two dense sections

> Sections `<N>` and `<N+1>` of `<the existing explainer>` are hard for a human to read. Rewrite those two
> sections, for a product manager who reads the doc once, so that they are easy to scan and understand. Keep
> every rule and every number. Write only the rewritten sections to `<OUT>`.

Without the skill (original 671 words; Sonnet 773, Haiku 790): both grew the text; 11 headings for two
sections; reasoning chopped into bullets that lost their "because"; labels such as "In short:" and "Rule:";
Haiku bulleted single prose sentences. Rules that fix it: a rewrite is shorter; form by content, a bullet is
a parallel item; a heading only for three or more paragraphs.

With the skill, two-skill draft (Sonnet 662, Haiku 662): shorter than the original, reasoning in prose,
lists only for parallel items. Sonnet wrote a reader line into a mid-document section; the one-section
rewrite rule now covers it. With the merged skill (Sonnet 681, one sample): explain branch only, no
paragraph over 63 words, ten words longer than the original; the agent reported the overrun itself.

## T3 — hand over a folder (the count rule)

> A maintainer is taking over the folder `<folder>`. It holds a Python package and explainer documents written
> about it. Write a handover document for the maintainer: what is in the folder, what each explainer covers and
> how the explainers differ, and which one to keep. Write it to `<OUT>`.

Run on 2026-11-26 with the `sonnet` and `haiku` aliases of that date, one sample per cell. Fixture: a package
of about 1,400 lines and explainers of 1,900 to 3,100 words about it. Counts were judged by hand: a tally of
a set that can grow is a failure, a measurement is not.

- Without the skill: Sonnet 4 tallies, Haiku 5. Both count the explainers and the package files ("Four
  explainers", "six files", "holds two things"). Haiku puts the count in the title and in a heading.
- With the reworded rule: Sonnet 2 tallies, Haiku 1. Neither counts the files or the explainers in the
  inventory. Sizes appear as measurements with their unit.
- Not fixed: a count in the sentence that introduces a list ("Two facts about the package affect everything
  else:", "Two parts of the others are worth moving into it:"), and "All four cover the same topics".
- Borderline, not counted above: Sonnet describes one explainer as having "three worked examples". The count
  is an attribute under comparison, with no note on how it was counted.

Second run the same day, after the rule named list lead-ins and "all four" phrasing. Skill runs only, one
sample each.

- Sonnet 2 tallies, Haiku 3. The added wording did not bind.
- The inventory stays clean on both. Haiku writes "several explainers".
- Lead-in counts remain: "Three things about the package matter for a maintainer:", "do two things:".
- Counts of the same set return later in the text: "all four explainers state", "the other three
  explainers can go".
- The agent has read the rule and still writes the count. More wording has not fixed it; a search of the
  finished document for number words is the form not yet tried.
- The lead-in and "all four" wording was removed again the same day, since it showed no effect. The rule
  keeps one example pair.

## Trigger test

With every skill available and no hint, on the merged skill's description:

- T1 above: Sonnet invoked `writing` only, judged the document an explainer, read `explain.md` only, and
  opened its reply with the judgement. Output 1,556 words against 2,277 for the same run under the earlier
  steer-only description, which it correctly did not invoke.
- Steer task, "review the agent-instructions file of one package for lines an agent could misread and write
  proposed replacements": Sonnet invoked `writing` only, judged it steering, read `steer.md` only, and
  opened its reply with the judgement.

## Observed in use

Applying the heading rule to a walkthrough (another session, 2026-10-13) merged three short sections; the
agent renumbered the rest and fixed the in-file trace table but checked no other document for citations
by number. Rule added: cite a section by its title and keep existing numbers and anchors when rewriting.

Two findings reports (2026-10-13, written under the skill) opened with an 80-to-115-word paragraph walking
through "Part A lists…, Part B lists…", and wrote each open decision as a 120-to-220-word bold-led paragraph
holding the question, the sources, the options and the recommendation. The paragraph limit was known and
skipped; the shape was wrong. Rules added: the map is a list or the headings; repeated items get the same
slots, one line per slot; the reader line is one sentence with sources on their own line.

Design and research documents written under the skill (2026-11-26) counted sets that grow. Examples: "Of
the four files on `<topic>`", "the eight skills in the table below", a count in three titles. Each count is
wrong after the next addition. Rule added in `SKILL.md`, because steering documents show the failure too:
name the members or point at where they live, and keep a count that is a measurement.

## Rules carried by a decision, not a failure

The 25-word sentence limit, active voice and present tense, and the three-word noun chain follow the
human's decision on 2026-10-13 to take the writing rules of ASD-STE100 (Simplified Technical English)
without its dictionary. No baseline failure motivates them; cut them only with that decision reversed.

The reader sentence goes in the reply, not in the document, by the human's decision on 2026-11-26. Results
above that mention a reader line in the document predate it. The rule against a second reader line in a
section rewrite went with it. T1 has not been rerun without the printed line.
