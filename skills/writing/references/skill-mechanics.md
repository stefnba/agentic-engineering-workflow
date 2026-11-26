# Skill mechanics

What changes when the document is a skill. Everything about the writing itself is in `SKILL.md`; this file covers packaging.

If the host platform or a plugin imposes packaging constraints, read its current authoring documentation alongside this file. Platform documentation owns runtime-specific details such as skill loading, paths, and compatibility rules.

## Anatomy

```text
skill-name/
├── SKILL.md            # frontmatter + body
├── references/         # disclosed reference, loaded on demand
├── scripts/            # executable steps, run without loading
└── templates/          # files copied or filled into the output
```

Three loading tiers: the description is always in context; the body loads when the skill triggers (keep it under ~500 lines); everything else loads only when pointed to.

## Choose a skill role and structure its body accordingly

Before drafting a skill, classify it as either a **reference skill** or a **task skill**. Read [skill roles and structures](skill-roles-and-structures.md) for the required body shape. Do not make a hybrid by default: split unrelated standing guidance and procedures into separate skills. A task skill may point to narrowly scoped reference material that its procedure needs.

## Bundled files

Route each file by how the agent consumes it:

- Read into context for knowledge → `references/`
- Copied or filled into the output → `templates/`
- Executed without loading → `scripts/`
- Imitated but never copied → an example: inline in SKILL.md when short, a reference file when long or numerous (the example rules in `SKILL.md` apply)

**Name no file, directory, member, product or domain term of a real repository in any skill file**, tests and references included. A skill set is installed into other repositories, where such a name points at nothing and reads as an instruction to find it. Describe a fixture by its shape ("a package of about 2,000 lines and a 6,000-word explainer about it") or invent one (`example_app/`).

Internal structure follows the same split:

- **Reference files open with one or two lines** stating what the file covers — enough for the agent to confirm it opened the right one. The _when to read it_ condition lives in the SKILL.md pointer; don't repeat it here. Body is plain markdown; fence only blocks meant to be reproduced character-for-character.
- **Template files carry no preamble.** Anything in the file can land verbatim in the deliverable, so an explanatory intro leaks into the output. Ship a bare scaffold with placeholder markers (`{{CLIENT_NAME}}`); usage instructions live next to the SKILL.md pointer, and slot-level guidance rides in comment syntax per SKILL.md's template rules.

## The description

The description is the skill's top-level pointer and its only triggering mechanism — the pointer rules in `SKILL.md` apply in full, plus:

- Put _all_ "when to use" information here, none in the body. The body should assume the skill has already fired.
- Describe triggering conditions and symptoms only — never summarize the skill's workflow. A description that sketches the process gets followed _instead of_ the body; the body becomes documentation the agent skips.
- Agents under-trigger skills. Be a little pushy: name concrete user phrasings, symptoms, and file types, "even if they don't explicitly say X".
- Third person, under 1024 characters, and technology-agnostic unless the skill itself is technology-specific.

Example shapes:

```yaml
# Bad — summarizes workflow; agent may follow this and skip the body
description: Use for TDD — write test first, watch it fail, write minimal code

# Bad — too abstract to ever fire
description: For async testing

# Good — conditions and symptoms only
description: Use when tests have race conditions, timing dependencies, or pass/fail inconsistently
```

## Naming

**Verb-first, active, named for what you do or the core insight:** `condition-based-waiting` beats `async-test-helpers`; `creating-skills` beats `skill-creation`. Letters, numbers, hyphens only.

**Two refinements**: when the verb acts on one artifact, name both (`review-changes`, not `review`) so sibling skills stay distinguishable; a caretaker skill takes the name of the artifact or state it owns (`changelog`) — a verb there would misdescribe a skill that answers as often as it acts.

**Citing a skill in prose**: `/name` only where the text tells the human to invoke it — the form they would type; the bare backticked name everywhere else, including where the agent invokes it. The split carries information: a slash in a skill body marks a hand-back to the human.

## Structuring multi-domain skills

When one skill covers several variants (cloud providers, frameworks), keep the workflow and the selection logic in SKILL.md and give each variant its own reference file, so the agent reads only the branch it's on:

```text
cloud-deploy/
├── SKILL.md            # workflow + which reference to read when
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```

## Cross-referencing other skills

Name the skill and mark whether it's required ("REQUIRED: use skill-x for the deploy step"). Don't paste its content — that duplicates a source of truth — and don't use force-loading link syntax that pulls the whole file into context before it's needed.
