<!-- The correctness reviewer's reply, posted as one PR comment or returned in chat. Read
`reply-rules.md` in this folder first: it holds the rules every slot follows. Fill every slot and
delete the comments as you fill; a surviving comment is an unfilled slot. -->

## Correctness Review: Round <round>

<!-- The round and the head your prompt names, the head bare, not in backticks. -->

**Commit:** <head>

### Summary

<!-- The first bullet is the verdict, in exactly these words, because the workflow skills read it:
"⚖️ Human escalation required" when a finding is escalated, whether or not a blocker is open;
otherwise "❌ Fixes required" when a blocker is open; otherwise "✅ Ready for human review". Then, one
bullet per non-zero count, in this order: "❌ <N> blocker", "⚠️ <N> concern", "✅ <N> closed this
round", "❌ <N> earlier still open", "⚖️ <N> escalated"; blockers and concerns count new findings
only, and an earlier finding still open counts under "earlier still open" whatever its severity.
Last, the checks, counting every bullet under Checks: "✅ <N> checks passed" or "❌ <N> of <M> checks
failed". Pluralize each noun. -->

- <verdict>
- <count>
- <count>
- <checks>

<!-- Only when a finding is escalated, one box per escalation. The bold line is the decision as a
question; the bullets name the finding and the outcomes that would close it. The two positions are
under Earlier findings. -->

> [!IMPORTANT]
> **Your call: <the decision as a question>**
>
> - **Finding:** <title> (`<ID>`)
> - **Either settles it:** <outcome A>, or <outcome B>

<!-- Omit the section when there is no new finding. One block per finding, blockers first. -->

### Findings

<!-- The title: ❌ for a blocker or ⚠️ for a concern, then what is wrong in at most eight words,
then its ID. The line under it: the severity, the axis, your confidence, and where it lives. -->

#### <N>. <❌|⚠️> <title> (`<prefix>F<N>`)

<blocker|concern> · <axis> · <verified|suspected> · `<path:line or command>`

<!-- Violates: the rule, spec condition, or failure mechanism, with its ID and words. Evidence: one
bullet per fact, each ending in its pointer. Impact: the concrete failure. Required outcome: the
property a fix must establish, never the fix itself. -->

**Violates:**

- <referent>

**Evidence:**

- <fact> · <pointer>

**Impact:**

- <failure or risk>

**Required outcome:**

- <property a fix must establish>

<!-- Only when earlier rounds exist; omit on round 1. One bullet per earlier finding ID, in ID
order: glyph, title, ID, the state your prompt gave it. Closed and still open take their evidence as
sub-bullets; escalated takes a Reviewer and an Author sub-bullet, one sentence each, with each
side's evidence nested under it; closed earlier takes nothing more. -->

### Earlier findings

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

<!-- Every command rerun at the head, one bullet each: glyph, the command verbatim, an arrow, the
result. ✅ when the result is the expected one, including a pre-change run that fails as the author
claims; ❌ otherwise. A check run at another commit names it first ("at <sha>:"). Something read
rather than run is "read <pointer> → <what it shows>". -->

### Checks

- <✅|❌> `<command>` → <result>

<!-- Only what could change the human's decision, one bullet each. A risk carried from an earlier
round restates its fact in one line, prefixed "Unchanged since round <N>:". Omit when none. -->

### Residual risk

- ⚠️ <risk>

<!-- Evidence-backed improvements that gate nothing, one bullet each: the kind and the area in
brackets, as the backlog skill names them, then the line and its pointer. On a later round, list
only new ones. Omit when none. -->

### Backlog candidates

- [<kind>] [<area>] <line> · `<path:line>`
