<!-- Reviewer report for local changes, delivered as the final message. Fill every slot; delete
these comments as you fill. One line per bullet. Drop any section with nothing to put in it. A
check that passed and raised no finding appears only in the verification table. -->

## Review — local changes

Baseline: `<SHA>` (<HEAD | merge-base with `<base ref>`>) — fingerprint <✅ unchanged | ⚠️ tree
moved during review>

Judged against: <the stated intent | repository conventions and decision records only — no
stated intent>

### Findings

<!-- Blockers before concerns; one block per finding, in finding-rules' record form. Admissible
referents here: a decision record, a repository convention or canonical check, the stated
intent, or a concrete failure mechanism. -->

❌ F<N> [verified|suspected] <axis> — <file:line or command>

- **Violates**: <the referent>
- **Claim**: <what the change does or asserts>
- **Evidence**: <what you ran or read, and the result>
- **Impact**: <the concrete failure or risk>
- **Required outcome**: <the property a fix must establish, without writing the fix>

### Verification

| check       | result                                       |
| ----------- | -------------------------------------------- |
| `<command>` | ✅ / ❌ <failure, and the finding it raised> |

### Assessment

✅ ready for human review | ❌ fixes required | ⚠️ human escalation required

### Residual risk

- <only what could change the human's decision>

### Backlog candidates

- <evidence-backed, non-gating; never a finding>

<!-- An escalation carries both positions and a concern carries only yours; finding-rules owns
the difference. -->
