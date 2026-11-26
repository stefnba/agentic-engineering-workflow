<!-- The design reviewer's reply, posted as one PR comment or returned in chat. Read
`reply-rules.md` in this folder first: it holds the rules every slot follows. Fill every slot and
delete the comments as you fill; a surviving comment is an unfilled slot. -->

## Design Review: Round <round>

<!-- The round and the head your prompt names, the head bare, not in backticks. -->

**Commit:** <head>

### Summary

<!-- The first bullet is the verdict, in exactly these words, because the workflow skills read it:
"⚖️ Human escalation required" when an earlier alternative is escalated; otherwise "💡 <N>
alternative raised" when any alternative is new this round or still open from an earlier one, N
counting both; otherwise "✅ No better shape found". Then one bullet per non-zero count, in this
order: "❓ <N> question for you", "✅ <N> closed this round", "⚖️ <N> escalated"; a still-open earlier
alternative is counted in the verdict only. Last, only for a level you could not answer: "⚠️
<reuse|structure|size> not reached: <why>"; full coverage is the default and goes unsaid. Pluralize
each noun. -->

- <verdict>
- <count>

<!-- Only when an earlier alternative is escalated, one box per escalation. The bold line is the
decision as a question; the bullets name the alternative and the outcomes that would close it. The
two positions are under Earlier alternatives and questions. -->

> [!IMPORTANT]
> **Your call: <the decision as a question>**
>
> - **Alternative:** <title> (`<ID>`)
> - **Either settles it:** <outcome A>, or <outcome B>

<!-- Omit the section when no alternative is raised this round. One block per alternative,
strongest first. -->

### Alternatives

<!-- The title: what the alternative does, in at most eight words, then its ID. The line under it:
the level, your confidence, and where the current shape lives. -->

#### <N>. <title> (`<prefix>A<N>`)

<reuse|structure|size> · <verified|suspected> · `<path:line>`

<!-- Now: what the code does at this level, then the one cost it pays with its one piece of
evidence. -->

**Now:**

- <current shape>
- **Cost:** <cost and evidence>

<!-- Instead: the shape you propose, never the code, then what it pays. -->

**Instead:**

- <alternative shape>
- **Cost:** <what it pays>

<!-- The ticket's Autonomy clause that lets the author adopt it, or, when no ticket backs the
change, "the contract leaves this shape open"; then one bullet per contract condition it puts at
risk, saying why it still holds. -->

**Allowed by:**

- <autonomy clause>
- <condition at risk> (`<ID>`) still holds, because <why>

<!-- Omit the section when no question is raised this round. Questions only the human can settle:
a shape the evidence could not decide, or a cheaper shape that would change something the contract
approved. They are not alternatives: the author leaves each unanswered for the human. -->

### Questions for you

<!-- The title: the topic in at most eight words, then its ID. The line under it: the evidence.
Question: one sentence. Would change: the approved part of the contract a yes would touch. -->

#### <N>. <title> (`<prefix>Q<N>`)

`<path:line>`

**Question:**

- <question>

**Would change:**

- <the approved part it touches>

<!-- Only on a design round after round 1; omit otherwise. One bullet per earlier alternative and
question ID: alternatives first, then questions, each in ID order; glyph, title, ID, the state your
prompt gave it. Closed and still open take their evidence as sub-bullets; escalated takes a
Reviewer and an Author sub-bullet, one sentence each, with each side's evidence nested under it;
closed earlier and with you take nothing more. -->

### Earlier alternatives and questions

- ✅ <title> (`<ID>`) closed
    - <evidence> · <pointer>
- ✅ <title> (`<ID>`) closed earlier
- ❌ <title> (`<ID>`) still open
    - <evidence> · <pointer>
- ⚖️ <title> (`<ID>`) escalated
    - **Reviewer:** <the reviewer's position>
        - <evidence> · <pointer>
    - **Author:** <the author's position, from the fix response>
        - <evidence> · <pointer>
- ❓ <title> (`<ID>`) with you
