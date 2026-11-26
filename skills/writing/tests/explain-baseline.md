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

## Rules carried by a decision, not a failure

The 25-word sentence limit, active voice and present tense, and the three-word noun chain follow the
human's decision on 2026-10-13 to take the writing rules of ASD-STE100 (Simplified Technical English)
without its dictionary. No baseline failure motivates them; cut them only with that decision reversed.
