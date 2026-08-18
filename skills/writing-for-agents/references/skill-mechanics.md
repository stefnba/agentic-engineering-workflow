# Skill mechanics

What changes when the document is a skill. Everything about the writing itself is in `SKILL.md`; this file covers packaging.

## Anatomy

```text
skill-name/
├── SKILL.md            # frontmatter + body
├── references/         # disclosed reference, loaded on demand
├── scripts/            # executable steps, run without loading
└── assets/             # files used in output (templates, fonts)
```

Three loading tiers: the description is always in context; the body loads when the skill triggers (keep it under ~500 lines); everything else loads only when pointed to.

## Bundled files

Route each file by how the agent consumes it:

- Read into context for knowledge → `references/`
- Copied or filled into the output → `assets/`
- Executed without loading → `scripts/`
- Imitated but never copied → an example: inline in SKILL.md when short, a reference file when long or numerous (the example rules in `SKILL.md` apply)

Internal structure follows the same split:

- **Reference files open with one or two lines** stating what the file covers — enough for the agent to confirm it opened the right one. The _when to read it_ condition lives in the SKILL.md pointer; don't repeat it here. Body is plain markdown; fence only blocks meant to be reproduced character-for-character.
- **Asset files carry no preamble.** Anything in the file can land verbatim in the deliverable, so an explanatory intro leaks into the output. Ship a bare scaffold with placeholder markers (`{{CLIENT_NAME}}`); usage instructions live next to the SKILL.md pointer, and slot-level guidance rides in comment syntax per SKILL.md's template rules.

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

Verb-first, active, named for what you do or the core insight: `condition-based-waiting` beats `async-test-helpers`; `creating-skills` beats `skill-creation`. Letters, numbers, hyphens only.

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
