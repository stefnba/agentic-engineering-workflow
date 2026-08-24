<!-- Critic report, delivered as the final message. Fill every slot; delete these comments as
you fill. One line per bullet. Drop any section with nothing to put in it. -->

## Critique — <bundle id>

### Findings

<!-- Blockers before concerns; one block per finding, in finding-rules' record form. Admissible
referents at plan time: a spec BR-n/INV-n/AC-n or named binding constraint, a decision record, a
rule in bundle.md / artifacts.md / shaping-routes.md, or a concrete failure mechanism. -->

❌ C<N> [verified|suspected] <axis> — <artifact:section or repository path>

- **Violates**: <the referent>
- **Claim**: <what the bundle says or assumes>
- **Evidence**: <what you inspected>
- **Impact**: <what becomes wrong, unsafe, or unexecutable>
- **Required outcome**: <the property Shape must establish, without writing the fix>

### Coverage

✅ intent · plan · decomposition · testability · gates — or name any axis you could not reach

### Assessment

✅ ready for human Plan review | ❌ not ready

### Residual uncertainty

- <only material areas the available evidence could not settle>

### Backlog candidates

- <evidence-backed, non-gating; never a finding>
