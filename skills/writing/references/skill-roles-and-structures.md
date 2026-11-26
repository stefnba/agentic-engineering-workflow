# Skill roles and structures

Choose the role from the behavior the skill must produce, not from whether it has a `references/` directory. Every skill can disclose reference files.

## Reference skill

A reference skill gives the agent standing domain knowledge to apply while doing another task. Use it for conventions, data definitions, style rules, API patterns, and decision criteria. It should change how work is performed, but should not direct the agent through a multi-step action.

Reference skills do not have a prescribed body shape. Organize each one around the domain concepts an agent needs to consult, using headings that make those concepts easy to find. Keep the main body a flat, scannable set of rules and facts. Put conditional or unusually detailed material in `references/` and point to it from the rule that needs it.

Do not add `## Process`, numbered steps, or a completion checklist unless the skill has become a task skill.

## Task skill

A task skill carries out a bounded, repeatable procedure: for example documenting SQL, preparing a pull request, or cutting a release. It has a clear result and a point at which the agent can stop.

Use this body shape:

```markdown
# <Title>

<One-sentence statement of the outcome.>

## Guardrails

<!-- Use only when applicable -->

<non-negotiable constraints>

## Process

### 1. <Action-oriented step name>

<What to do, how to handle a relevant branch or failure, and the observable completion criterion.>

### 2. <Action-oriented step name>

...

## Checklist

<!-- Use only when applicable -->

- [ ] <Outcome or verification that must be true before handoff.>
```

**Every task skill has exactly one `## Process`.** Make every procedural action a numbered `###` heading, beginning at `### 1.` and ordered as the agent should perform it. Put branches and failure handling immediately under the affected step. End each step with an observable completion criterion.

## Boundary test

Ask: “Could an agent apply this correctly while completing many different tasks?” If yes, make it a reference skill. Ask: “Does success require doing named actions in a particular order and checking a result?” If yes, make it a task skill.

When both are true, keep the reusable rules in a reference skill and let the task skill point to it. Keep them together only when the reference is meaningful exclusively within that one procedure.
