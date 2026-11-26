# Writing a document that explains

Rules for a document a reader opens once, looking for one thing, whether that reader is a person or an agent.

## Before drafting

**Name the reader and the one question they bring, in one sentence, before drafting.** "For an engineer joining the team: how a request becomes a stored order." Every later choice — what to include, how deep to go — is settled against that sentence. Without it, a doc drifts into everything the author knows.

**State that sentence in your reply, after the kind you judged; the document itself opens with the answer.** The human sees the choice in the reply and can overrule it. Printed in the document, it repeats what the opening paragraph says.

**Put the sources read and the method on their own line after the opening paragraph**, so the opening holds only the answer.

**Write an explainer or a reference, and keep the other out.** An explainer answers "how does this work, and why": the mechanism, one worked example, the reasons. A reference answers "what exactly is the rule": every rule, value and edge case, in tables. An explainer that needs precise rules — error lists, config keys, defaults, internal names — links to a reference section or appendix.

## Shape

**Open with the answer.** The first paragraph after the title states what the thing does and the one fact a reader must leave with. Details follow; a reader who stops after the first paragraph still has the point.

**Give each paragraph one idea, at most five sentences and 100 words.** A paragraph that carries two rules or more than two numbers is two paragraphs.

**Split any sentence over 25 words.** A sentence holds one claim and at most one number.

**Write in the active voice and the present tense**: "the loader reads each file", not "each file is read".

**Keep a noun chain to three words.** "The previous month's order count" reads; "previous month order count baseline" does not.

**Choose the form by the content, not by the wish to look scannable:**

| Content                                      | Form                                     |
| -------------------------------------------- | ---------------------------------------- |
| Reasoning, a cause and its effect            | Prose, two to four sentences             |
| Three or more items with the same attributes | A table, introduced by one sentence      |
| Parallel items, each one line                | A bulleted list, with a lead-in sentence |
| Steps in order                               | A numbered list                          |
| A quantity a reader will look up             | Its own line or a table cell             |

A bullet holds a complete parallel item; an argument broken into bullets loses the "because" that joined it.

**Let the headings carry the document's map; where a map paragraph is needed, write it as a list, one part per line.** "Part A lists the rules, Part B the contradictions, Part C the decisions" is a list in disguise; as a paragraph it is the first thing a reader skips.

**Give repeated items — findings, cases, decisions — the same slots, one line or bullet per slot**: the claim in bold as the lead line, then what the sources say, the options, the recommendation, each on its own line. A 150-word paragraph holding four slots hides three of them.

**Give one worked example per mechanism, with real numbers, and reuse it through the document.** A second example costs the reader a second setup for no new rule.

## Length

**Make a rewrite shorter than the original.** Start from what the reader needs, not from the old text; a rewrite that keeps every sentence and adds headings is longer and no clearer. Keep every rule and number; drop restatements, hedges, and meta-sentences such as "in short" or "as noted above".

**Delete a section the named reader never asked for.** The test for a sentence: if it were gone, what would the reader get wrong? Nothing wrong — cut it.

**Give a heading only to an idea spanning three or more paragraphs.** A subheading over a single paragraph is a bold lead-in wearing a hat.

**Keep existing section numbers and anchors when rewriting.** Other documents cite this one by number; a merged section renumbers everything after it and breaks every such citation silently.

**Cite a section by its title**, which survives a renumbering.
