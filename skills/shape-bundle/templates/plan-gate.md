<!--
The Plan gate message, posted as one chat message. The human judges the bundle from brief.md; this
message points there and carries only what the commit will do besides adding the bundle. Fill every
slot and delete the comments as you fill; a surviving comment is an unfilled slot.
-->

## Plan gate: <bundle-id>

<!-- The goal's first sentence from brief.md, verbatim. -->

<goal sentence>

**Read the brief**: [brief.md](<brief path relative to the working directory>)

<!-- One line. Name every round and its result: design "no better shape found" or "N alternatives";
executability "ready", "all disposed", or "blocker open". -->

**Critique**: <N> rounds; <round results>

- **Integration target**: `<target>`, from `<AGENTS.md path>`; the bundle branch is cut from it
  and lands on it
- **Backlog lines the commit deletes**: <each line verbatim, with the ticket that covers it, or
  "none">
- **Open risks**: <one line each, only for risks the brief does not carry. A blocker fixed in the
  last round without a fresh critique is always one. Omit the bullet when there is none.>

### Your call

<!-- Add ", or run another critique round first" to question 6 when the last round found a
blocker. -->

1. Does the brief's before-and-after show what you picked?
2. Can you live with every call under "Calls you might disagree with"?
3. Is the granularity right, or should a ticket merge or split?
4. Delete the backlog lines above?
5. Is `<target>` the branch this bundle should be cut from and land on?
6. Approve and commit?
