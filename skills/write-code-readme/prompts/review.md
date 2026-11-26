Review a README critically. Change no file; report findings only.

The document is `{{readme}}`. It explains the source files in the same directory to a human engineer who finds the code hard to follow. Its goal: a reader understands which function does what, in which order, and why, without first reading every file. {{related}}

The rules for explanatory documents in this repository are in `{{explain_rules}}`. Read them and judge against them, but weigh a newcomer's understanding above matching rules. The README follows the template `{{template}}`; where the template and those rules disagree, the template wins. The written form of names and the diagram shapes are fixed in `{{notation}}`.

Attack it on:

1. **Intuitive for a human.** Read it as a newcomer first, before the code. Where do you get lost? Where does a term appear before it is explained? Where does a diagram confuse instead of help? Check that each Mermaid diagram is valid syntax a code host renders — quoting, `&`, `<` and `>` in labels, edge labels, `<br/>` — that each node is declared inside exactly one subgraph, and that you can tell each node's kind and module from its shape and subgraph alone.
2. **Concise.** Which sentences, rows or sections could go without the reader getting anything wrong? Where does one fact appear in two places, such as diagram, prose and code map?
3. **Comprehensive and true.** Then read the code. What does a reader need that is missing? What is wrong or out of date against the code: names, signatures, which rule lives where, claimed behaviour, example outputs? Verify each claim against the code instead of trusting it; an example output must be one the code can produce. Run only code that calls no network, warehouse, or model.
4. **Structure.** Is the section order right for the reader's question? Do Responsibilities and Not here tell you what this directory does and does not do before you read on? Does each section keep within the sentence and bullet caps its template comment sets? Does the code map earn its length?
5. **Read as an agent.** Pick two sections and read each alone. Does every name in them resolve with one grep, and does each say enough to act on without the rest of the document?
6. **Notation.** List every name or node whose written form breaks `{{notation}}`.

Report a verdict in two sentences, then findings ordered by severity — wrong, then confusing, then missing, then verbose — each with the line or section, what is wrong, and a concrete fix. Keep it under 700 words, with no praise.
