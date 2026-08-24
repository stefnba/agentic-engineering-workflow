<!-- Reviewer round comment, posted on the PR at the reviewed head SHA. Fill every slot; delete
these comments as you fill. One line per bullet. Drop any section with nothing to put in it. A
check that passed and raised no finding appears only in the verification table. -->

## Review — round <N>

Head: `<SHA>` ✅ PR head, tree clean at that SHA

### Findings

<!-- Blockers before concerns; one block per finding, in finding-rules' record form. Admissible
referents at PR time: a spec BR-n/INV-n/AC-n, a ticket Done when condition, a decision record, a
canonical check, or a concrete failure mechanism. -->

❌ R<round>-F<N> [verified|suspected] <axis> — <file:line or command>

- Violates: <the referent>
- Claim: <what the change does or asserts>
- Evidence: <what you ran or read, and the result>
- Impact: <the concrete failure or risk>
- Required outcome: <the property a fix must establish, without writing the fix>

### Verification at head

| check       | result                                       |
| ----------- | -------------------------------------------- |
| `<command>` | ✅ / ❌ <failure, and the finding it raised> |

### Prior findings

<!-- Round 2 and later only. -->

| id          | disposition                                                     |
| ----------- | --------------------------------------------------------------- |
| `R<n>-F<n>` | ✅ closed, verified at `<SHA>` / ❌ open / ⚠️ carried to Accept |

### Assessment

✅ ready for human review | ❌ fixes required | ⚠️ human escalation required | 🛑 stopped before judging

### Residual risk

- <only what could change the Accept decision>

### Backlog candidates

- <evidence-backed, non-gating; never a finding>

<!-- An escalation carries both positions and a concern carries only yours; finding-rules owns
the difference. -->
