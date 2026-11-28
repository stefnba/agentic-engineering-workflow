---
question: "How do the seven reference repositories, the Claude Code code-review plugin, the Codex review prompt and published human code-review guidance review a spec or plan, and how do they review code: what each review step checks, how reviewers are isolated, how findings are labelled by severity, how findings are resolved and over how many rounds, what the human decides, and which weaknesses of these steps are reported?"
researched: "2026-11-28"
versions: "obra/superpowers 22f0b46 (v7.0.2); mattpocock/skills bbadaa6; google/elephant-goldfish-model 4693375; github/spec-kit f201054; Fission-AI/OpenSpec dff0188; open-gsd/gsd-core e9c3e54 (branch next); bmad-code-org/BMAD-METHOD e435a22; anthropics/claude-plugins-official 0fbfda5 (code-review plugin 1.0.1); openai/codex 065e18b; Google eng-practices review guide, content as of 2024-05-10; Claude Code and OpenAI docs pages undated, read 2026-11-28"
---

# Spec, plan and code review in agent workflows and human guidance

## Answer

Every source except the Claude plugin and Codex has a spec or plan review step, and every source except Google's guide ships a code review step. What they check converges; how they label, loop and hand off to the human does not. All commits are default-branch heads read on 2026-11-28.

| Source | Spec or plan review | Code review | What the human decides |
|---|---|---|---|
| superpowers 22f0b46 | Builder check: one fresh subagent, questions ranked by importance, one round. Plan: the author's own checklist, one pass | Fresh read-only subagent per task and one for the whole branch. Critical / Important / Minor. Fix loop capped per task, one final fix wave | Approves design and plan; reads the agent's "Rulings I made" at the end |
| mattpocock/skills bbadaa6 | No reviewer: `grilling` interviews the user until the question frontier is empty | Two parallel fresh subagents, Standards and Spec. No severity. One fix round, no re-review | Every design decision; the base point and the spec for review |
| elephant-goldfish-model 4693375 | Five-stage persona review by fresh subagents. Blocker / Major / Nit. Converged after two clean rounds, cap 5. `egm-lite`: one fresh reviewer, P0–P3, no cap | Drift report against design docs, no labels. `egm-lite` diff review: one fresh reviewer, P0–P3, no cap | Approves fixes; chooses at the cap; overrides PROPOSE FIX or CONTEST |
| spec-kit f201054 | Same agent. `specify` self-check up to 3 iterations; `clarify` up to 5 questions; read-only `analyze`, CRITICAL / HIGH / MEDIUM / LOW, one pass | `converge`, same session, same four labels, appends tasks, no cap | Whether to proceed past `analyze` findings |
| OpenSpec dff0188 | A human reading guide; `openspec validate` checks structure only | `/opsx:verify`, same session, CRITICAL / WARNING / SUGGESTION, advisory and experimental, no loop | Does the plan review; decides `apply` and archive |
| gsd-core e9c3e54 | Separate `gsd-plan-checker` agent, BLOCKER / WARNING / INFO, 3 iterations. Optional cross-AI review loop, 3 cycles | `gsd-code-reviewer` agent, Critical / Warning / Info, `--auto` fix loop capped at 3 | Starts review and fixes; at a cap, force proceed, retry with guidance, or abandon |
| BMAD-METHOD e435a22 | `validate` by fresh subagents; `bmad-review` lenses with no severity; no cap found | Lenses as context-free subagents; a triage step grades high / medium / low and routes to patch, defer or decision needed | Each decision-needed fix, whether to apply patches, a reason per defer, and ticket done |
| Claude Code plugin 0fbfda5 | None | Four parallel subagents (two CLAUDE.md, two bug) plus a validation subagent per bug-agent finding. No severity. One pass | Whether to post (`--comment`), what to fix, merge |
| Codex 065e18b | None | One sub-agent thread with no history and the rubric as system prompt. P0–P3 plus a correctness verdict. One pass | The review target; what to fix, by follow-up prompt |
| Google guide, 2024-05-10 | None in the guide | Human reviewer. Nit / Optional / FYI mark non-required comments. No round limit; one business day per response | Reviewer approves; author decides advisory comments; a lead or manager breaks a deadlock |

- **Where they agree.** Inferred: checks of code against a spec use the same three categories: missing, extra and wrong. Superpowers, mattpocock, spec-kit, OpenSpec and BMAD all use them (see Code review in the seven reference repositories). Inferred: most sources send fresh, read-only subagents and tell them to distrust the author's account, and several record settled findings so later rounds do not reopen them (see the first two sections).
- **Where they split.** Labels run from none to four levels, and BMAD strips lens labels and grades in a separate triage step. Round rules run from one pass, to caps of 3 or 5, to uncapped human re-runs. Finding quotas pull against high-signal filters: BMAD's lenses must find a minimum number, while the plugin and Codex prefer no findings to uncertain ones. Superpowers lets the agent rule on disputed findings and report afterwards; BMAD halts for the human.
- **Reported weaknesses.** Inferred: the most-reported failure in the trackers is reviewing the wrong thing, silently: a wrong base, an empty diff, a stale head or an overwritten report. A second pattern is findings lost between reviewer and human through thresholds, unreadable input reported clean, or replaced reports. Judgement limits are reported less: fixed axes miss runtime bugs, and a weak fresh reviewer invents ambiguity. Review loops without a convergence test run to budget (see Reported weaknesses).
- **Evaluations.** 2026 preprints report noisy exhaustive reviewers, false rejections of correct code, decline over many rounds, and false consensus between agents. In that last study, a prompt that adds disagreement scored the best F1. One test found no detectable self-preference in same-model review. All were read as abstracts only, with no precision or recall numbers.
- **Evidence strength.** The repository behaviour is read from prompt text, not run. Most tracker weaknesses were not reproduced, and several were found by reading source, not from sessions. The human guidance predates AI review. The one evaluation of LLM design-document review found is a 2025 study of GPT checking consistency across design documents (see Evaluations).

## Spec and plan review in the seven reference repositories

**obra/superpowers**

- A fresh subagent reads the design as its builder and reports "only the questions you'd still need answered before you could plan this well" ([superpowers brainstorming/builder-check-prompt.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/brainstorming/builder-check-prompt.md)).
- The builder check carries no severity; it ranks questions "by importance" or says "nothing important left" ([same file](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/brainstorming/builder-check-prompt.md)).
- Without a subagent tool, the agent should "read the document as that builder yourself" ([superpowers brainstorming/SKILL.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/brainstorming/SKILL.md)).
- Findings go to three piles: answered already, minor ("Settle it yourself and mark it in the document as your call"), and theirs, which only the human can answer ([same file](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/brainstorming/SKILL.md)).
- It runs once: "That's the only round of questions the check produces." ([same file](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/brainstorming/SKILL.md)).
- The human approves: "Nothing gets built until your human partner approves the design doc" ([same file](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/brainstorming/SKILL.md)).
- Plan review is "a checklist you run yourself — not a subagent dispatch", covering spec coverage, step scan, type consistency, Review Focus and proportion ([superpowers writing-plans/SKILL.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/writing-plans/SKILL.md)).
- The plan self-review does not repeat: "No need to re-review — just fix and move on." The human then reviews the plan and picks the execution method ([same file](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/writing-plans/SKILL.md)).

**mattpocock/skills**

- No reviewer step exists for a spec or plan; `grill-me` calls `grilling`, "A relentless interview to sharpen a plan or design" ([mattpocock grill-me/SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa631c37af594e5a05c9cefacd9956136b18/skills/productivity/grill-me/SKILL.md)).
- `grilling` asks numbered questions with a recommended answer each; "The _decisions_ are the user's", and "The session is done when the frontier is empty" ([mattpocock grilling/SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa631c37af594e5a05c9cefacd9956136b18/skills/productivity/grilling/SKILL.md)).

**google/elephant-goldfish-model**

- `egm-review` runs five stages: "Initial Zoom Out Review, Comprehension Review, Design Critique, Intermediate Zoom Out Review, and Implementation Readiness" ([EGM egm-review/SKILL.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/46933754e63c0424daa9c270d7e0734245d79560/skills/egm-review/SKILL.md)).
- The personas each take one angle ([EGM agents/, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/agents/structural.md)): structural checks the template, style checks claims against evidence, comprehension must paraphrase each section, implementation_readiness flags choices left to the implementer, zoom_out checks YAGNI and reuse, codebase_details checks cited code exists, and the design critic checks "Faulty Assumptions" and "Unmitigated Risks" ([design_critic.md](https://github.com/google/elephant-goldfish-model/blob/46933754e63c0424daa9c270d7e0734245d79560/agents/design_critic.md)).
- Reviewers run "in isolated, fresh context windows", and without a subagent tool the skill stops: "a review in the same context is not a Goldfish review" ([EGM egm-review-loop/SKILL.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/46933754e63c0424daa9c270d7e0734245d79560/skills/egm-review-loop/SKILL.md)).
- Findings carry "🔴 Blocker, 🟡 Major, 🟢 Nit" and a failed reviewer must "Never count" as one with zero findings ([same file](https://github.com/google/elephant-goldfish-model/blob/46933754e63c0424daa9c270d7e0734245d79560/skills/egm-review-loop/SKILL.md)).
- The author agent answers each finding with CONTEST, ESCALATE, PROPOSE FIX or DECLINE, and "A wish to contest is not evidence" ([EGM egm-resolve/SKILL.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/46933754e63c0424daa9c270d7e0734245d79560/skills/egm-resolve/SKILL.md)).
- A round is clean when no unsettled Blocker or Major remains; "Converged" means "Two consecutive clean rounds"; the cap is 5 rounds; and a churn rule catches findings caused by an applied fix ([egm-review-loop/SKILL.md](https://github.com/google/elephant-goldfish-model/blob/46933754e63c0424daa9c270d7e0734245d79560/skills/egm-review-loop/SKILL.md)).
- Settled findings are not reopened, but "An applied fix does not settle a finding" ([same file](https://github.com/google/elephant-goldfish-model/blob/46933754e63c0424daa9c270d7e0734245d79560/skills/egm-review-loop/SKILL.md)).
- The human approves fixes at a gate and, at the cap or on churn, chooses "accept and proceed, continue past the cap, or return the document to drafting" ([same file](https://github.com/google/elephant-goldfish-model/blob/46933754e63c0424daa9c270d7e0734245d79560/skills/egm-review-loop/SKILL.md)).

**github/spec-kit**

- `specify` validates its own spec: "Re-run validation until all items pass (max 3 iterations)" ([spec-kit templates/commands/specify.md, f201054](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/specify.md)).
- `clarify` asks the user "EXACTLY ONE question at a time", at most 5 per session, each with a recommended option, and writes answers into the spec ([spec-kit clarify.md, f201054](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/clarify.md)).
- `analyze` cross-checks `spec.md`, `plan.md` and `tasks.md` for duplication, ambiguity, underspecification, constitution alignment, coverage gaps and inconsistency ([spec-kit analyze.md, f201054](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/analyze.md)).
- `analyze` labels CRITICAL, HIGH, MEDIUM and LOW, is "STRICTLY READ-ONLY", and leaves the user to proceed or ask for edits ([same file](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/analyze.md)).
- Inferred from the files above: no spec-kit command read names a subagent, so the authoring agent reviews its own artifacts.

**Fission-AI/OpenSpec**

- Plan review is a human reading guide, run "After `/opsx:propose` … before `/opsx:apply`", with one question per file and a seven-item checklist ([OpenSpec docs/reviewing-changes.md, dff0188](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/docs/reviewing-changes.md)).
- The guide names gaps as the main catch: "Your job is to notice what you *forgot* to say" ([same file](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/docs/reviewing-changes.md)).
- Rounds are uncapped: "Re-draft until it's a plan you'd sign your name to." ([same file](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/docs/reviewing-changes.md)).
- `openspec validate` checks "structural issues" only ([OpenSpec docs/cli.md, dff0188](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/docs/cli.md)).

**open-gsd/gsd-core**

- `gsd-plan-checker` runs "Goal-backward verification of PLANS before execution" across requirement coverage, dependencies, scope, verification derivation and other dimensions ([gsd-core agents/gsd-plan-checker.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/agents/gsd-plan-checker.md)).
- It is a separate agent; "Independent agent contexts are required" ([gsd-core plan-phase.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/plan-phase.md)).
- BLOCKER means "the phase goal will not be achieved"; WARNING means "execution can proceed"; INFO "alone never forces a revision" ([gsd-plan-checker.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/agents/gsd-plan-checker.md)).
- `review` sends plans to external AI CLIs such as `claude`, `codex` and `coderabbit` ([gsd-core review.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/review.md)).

**bmad-code-org/BMAD-METHOD**

- The PO agent's `validate` runs "Fresh-context subagents" on the draft tickets "before approval" and on refined tickets before execution ([BMAD bmad-agent-po/references/validate.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/method/bmad-agent-po/references/validate.md)).
- Its findings sort into fix, suggest or ask the user, and "the user decides suggestions and scope changes" ([same file](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/method/bmad-agent-po/references/validate.md)).
- Declined items stay declined: "Do not re-raise suggestions declined in a `Decision:` line unless new evidence changes their basis." No round cap was found ([same file](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/method/bmad-agent-po/references/validate.md)).
- `bmad-review` runs lenses on code or documents, one subagent each, with "No severity, priority, or ranking anywhere" ([BMAD bmad-review/SKILL.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/core-tools/bmad-review/SKILL.md)).

**Across the seven**

- Inferred from the findings above: the checked angles cluster into whether a builder can act without guessing, whether the plan covers the spec, internal consistency, scope, and backed assumptions and risks.
- Inferred from the EGM and superpowers isolation findings: EGM refuses to run without subagents, while superpowers falls back to the author reading as the builder.

## Code review in the seven reference repositories

**obra/superpowers**

- A dispatched subagent reviews a git range against the plan, after each task, after a major feature and before merge ([SP requesting-code-review/SKILL.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/requesting-code-review/SKILL.md)).
- The reviewer gets "precisely crafted context ... never your session's history" ([same file](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/requesting-code-review/SKILL.md)).
- The whole-branch prompt checks plan alignment, code quality, architecture, testing and production readiness, and holds that "a spec's silence is not permission" ([SP code-reviewer.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/requesting-code-review/code-reviewer.md)).
- Labels are Critical (Must Fix), Important (Should Fix) and Minor (Nice to Have), with a verdict "**Ready to merge?** [Yes | No | With fixes]" ([same file](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/requesting-code-review/code-reviewer.md)).
- The per-task reviewer returns a spec verdict (Missing, Extra, Misunderstood) and a quality verdict, and "a stated rationale never downgrades a finding's severity" ([SP task-reviewer-prompt.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/subagent-driven-development/task-reviewer-prompt.md)).
- `receiving-code-review` tells the author to verify before acting, bans "You're absolutely right!", and lists when to push back ([SP receiving-code-review/SKILL.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/receiving-code-review/SKILL.md)).
- The task fix loop reads "Five rounds maximum per task"; Minor findings "never enter the loop" ([SP references/fix-loop.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/subagent-driven-development/references/fix-loop.md)).
- At the cap the controller adjudicates each open finding, and "Adjudicate only at the cap" ([same file](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/subagent-driven-development/references/fix-loop.md)).
- The final review gets "exactly one scoped re-review" because "a real session's final-review fix wave cost more than all its tasks combined" ([SP references/final-review.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/subagent-driven-development/references/final-review.md)).
- The run does not stop to ask; the agent lists its decisions under "Rulings I made" for the human ([same file](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/subagent-driven-development/references/final-review.md)).

**mattpocock/skills**

- `code-review` reviews two axes: "**Standards**: does the code conform to this repo's documented coding standards? **Spec**: does the code faithfully implement the originating issue / spec?" ([MP code-review/SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa631c37af594e5a05c9cefacd9956136b18/skills/engineering/code-review/SKILL.md)).
- The axes run "as **parallel sub-agents** so they don't pollute each other's context", each with a fresh context ([same file](https://github.com/mattpocock/skills/blob/bbadaa631c37af594e5a05c9cefacd9956136b18/skills/engineering/code-review/SKILL.md)).
- There is no severity scale, and the aggregator must "**not** merge or rerank findings" ([same file](https://github.com/mattpocock/skills/blob/bbadaa631c37af594e5a05c9cefacd9956136b18/skills/engineering/code-review/SKILL.md)).
- `implement-spec` fixes all findings "in a single fresh **implementer subagent**" and then marks the PR ready, with no re-review ([MP implement-spec/SKILL.md, bbadaa6](https://github.com/mattpocock/skills/blob/bbadaa631c37af594e5a05c9cefacd9956136b18/skills/engineering/implement-spec/SKILL.md)).
- The user supplies the base point and, if none is found, the spec ([MP code-review/SKILL.md](https://github.com/mattpocock/skills/blob/bbadaa631c37af594e5a05c9cefacd9956136b18/skills/engineering/code-review/SKILL.md)).

**google/elephant-goldfish-model**

- `egm-drift-report` compares design documents with the source and reports "ONLY the differences", with no severity labels ([EGM egm-drift-report/SKILL.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/46933754e63c0424daa9c270d7e0734245d79560/skills/egm-drift-report/SKILL.md)).
- For drift, "You decide whether to update the document or the code" ([EGM README.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/46933754e63c0424daa9c270d7e0734245d79560/README.md)).

**github/spec-kit**

- `/speckit.converge` assesses present code against the spec, plan and tasks and "is **not** a diff tool" ([SK templates/commands/converge.md, f201054](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/converge.md)).
- It sorts gaps into `missing`, `partial`, `contradicts` and `unrequested`, labels them CRITICAL to LOW, and appends them as tasks ([same file](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/converge.md)).
- It runs in the current session and repeats until "✅ Converged", with no cap ([same file](https://github.com/github/spec-kit/blob/f2010547121b3351e4923fe467205079e4593a32/templates/commands/converge.md)).

**Fission-AI/OpenSpec**

- `/opsx:verify` checks Completeness, Correctness and Coherence against the change's tasks, specs and design ([OS verify-change.ts, dff0188](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/src/core/templates/workflows/verify-change.ts)).
- Labels are CRITICAL, WARNING and SUGGESTION, and "When uncertain, prefer SUGGESTION over WARNING, WARNING over CRITICAL" ([same file](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/src/core/templates/workflows/verify-change.ts)).
- "Never score a skipped check as passing." ([same file](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/src/core/templates/workflows/verify-change.ts)).
- "Verification is advisory", tagged `experimental`, with no loop; the human chooses whether to archive ([same file](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/src/core/templates/workflows/verify-change.ts)).
- Verify sits in the expanded profile, not the default ([OS reviewing-changes.md, dff0188](https://github.com/Fission-AI/OpenSpec/blob/dff0188f8bfb526cd19390331fc3dfb10381fb88/docs/reviewing-changes.md)).

**open-gsd/gsd-core**

- `/gsd:code-review` reviews a phase's changed files "for bugs, security vulnerabilities, and code quality problems", not against the plan ([GSD commands/gsd/code-review.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/commands/gsd/code-review.md)).
- The reviewer is told "Assume every submitted implementation contains defects" ([GSD agents/gsd-code-reviewer.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/agents/gsd-code-reviewer.md)).
- External lanes such as Codex give "UNVERIFIED input, never ground truth" ([GSD workflows/code-review.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/code-review.md)).
- Labels are Critical, Warning and Info in `classify_findings`, yet the same prompt's adversarial stance requires BLOCKER or WARNING ([GSD gsd-code-reviewer.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/agents/gsd-code-reviewer.md)).
- `--auto` enables a fix and re-review loop "capped at 3 iterations" ([GSD commands/gsd/code-review.md](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/commands/gsd/code-review.md)).
- Review needs the human to start it: "Require explicit user action to ensure review intent is clear." ([GSD code-review-fix.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/code-review-fix.md)).

**bmad-code-org/BMAD-METHOD**

- Thorough depth runs four lenses: Blind Hunter, Edge Case Hunter, Verification Gap Reviewer and Intent Alignment Auditor ([BM bmad-code-review/customize.toml, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/method/bmad-code-review/customize.toml)).
- Each lens is "a context-free subagent" that reviews "by inspection only" ([same file](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/method/bmad-code-review/customize.toml)).
- The Blind Hunter must "find at least N issues" with "N = min(floor(sqrt(kB) + 1), 10)", and must not "stop with an empty list" ([same file](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/method/bmad-code-review/customize.toml)).
- Without a plan, "triage cannot tell a deliberate choice from a mistake" ([BM docs/build/review-a-change.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/docs/build/review-a-change.md)).
- The human picks decision-needed fixes, chooses whether to apply patches, gives a reason per defer, and marks the ticket done ([same file](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/docs/build/review-a-change.md)).
- The skill halts for that choice: "**HALT** — I am waiting for your numbered choice." ([BM step-05-present.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/skills/method/bmad-code-review/step-05-present.md)).
- The human re-runs, and the docs advise: "Non-trivial findings on a third pass of agentic review usually mean something is wrong upstream of this change" ([BM review-a-change.md](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/docs/build/review-a-change.md)).

**Across the seven**

- Inferred from the superpowers, mattpocock, spec-kit, OpenSpec and BMAD findings: every spec check uses missing, extra or unrequested, and wrong or misunderstood.
- Inferred from the same findings: superpowers, mattpocock and BMAD keep the spec check apart from the quality check, as separate verdicts, subagents or lenses.

## The Claude Code code-review plugin and the Codex review prompt

**Claude Code code-review plugin**

- A haiku agent gates the run; it stops if the PR is closed, a draft, or "Claude has already commented on this PR" ([code-review.md, 0fbfda5](https://github.com/anthropics/claude-plugins-official/blob/0fbfda5a91f4adc311daca25acc99132f40f0b6e/plugins/code-review/commands/code-review.md)).
- Four parallel reviewers follow: "Agents 1 + 2: CLAUDE.md compliance sonnet agents" and two Opus bug agents, one of which reads only the diff ([same file](https://github.com/anthropics/claude-plugins-official/blob/0fbfda5a91f4adc311daca25acc99132f40f0b6e/plugins/code-review/commands/code-review.md)).
- Every subagent gets the PR title and description for author intent ([same file](https://github.com/anthropics/claude-plugins-official/blob/0fbfda5a91f4adc311daca25acc99132f40f0b6e/plugins/code-review/commands/code-review.md)).
- The bar is "HIGH SIGNAL issues"; "If you are not certain an issue is real, do not flag it." ([same file](https://github.com/anthropics/claude-plugins-official/blob/0fbfda5a91f4adc311daca25acc99132f40f0b6e/plugins/code-review/commands/code-review.md)).
- Step 5 launches a validation subagent for each issue "found in the previous step by agents 3 and 4", the bug agents, though its examples also cover CLAUDE.md issues. Then "Filter out any issues that were not validated in step 5" ([same file](https://github.com/anthropics/claude-plugins-official/blob/0fbfda5a91f4adc311daca25acc99132f40f0b6e/plugins/code-review/commands/code-review.md)).
- Findings carry a reason ("CLAUDE.md adherence", "bug"), not a severity ([same file](https://github.com/anthropics/claude-plugins-official/blob/0fbfda5a91f4adc311daca25acc99132f40f0b6e/plugins/code-review/commands/code-review.md)).
- Results go to the terminal; only `--comment` posts inline PR comments ([same file](https://github.com/anthropics/claude-plugins-official/blob/0fbfda5a91f4adc311daca25acc99132f40f0b6e/plugins/code-review/commands/code-review.md)).
- The README still describes 0–100 confidence scoring with a threshold of 80 ([README.md, 0fbfda5](https://github.com/anthropics/claude-plugins-official/blob/0fbfda5a91f4adc311daca25acc99132f40f0b6e/plugins/code-review/README.md)). The command was replaced on 2026-10-26 and the README only partly updated (tested 2026-11-28: `gh api --method GET repos/anthropics/claude-plugins-official/commits/c905cd8fec`).
- The README puts human review after the agent: "Review agent findings as a starting point for human review" ([README.md](https://github.com/anthropics/claude-plugins-official/blob/0fbfda5a91f4adc311daca25acc99132f40f0b6e/plugins/code-review/README.md)).

**Codex `/review`**

- The rubric is the review thread's system prompt ([review_request.rs, 065e18b](https://github.com/openai/codex/blob/065e18b04021008e2e7d504db8dc50275f589f73/codex-rs/prompts/src/review_request.rs)).
- A finding must be introduced in the commit, discrete, actionable, and something the author would fix; "pre-existing bugs should not be flagged" ([rubric.md, 065e18b](https://github.com/openai/codex/blob/065e18b04021008e2e7d504db8dc50275f589f73/codex-rs/prompts/templates/review/rubric.md)).
- Speculation is excluded, and the rubric says "prefer outputting no findings" over unqualified ones ([same file](https://github.com/openai/codex/blob/065e18b04021008e2e7d504db8dc50275f589f73/codex-rs/prompts/templates/review/rubric.md)).
- Labels are "[P0] – Drop everything to fix" to "[P3] – Low. Nice to have", plus an "overall correctness" verdict that ignores nits ([same file](https://github.com/openai/codex/blob/065e18b04021008e2e7d504db8dc50275f589f73/codex-rs/prompts/templates/review/rubric.md)).
- The rubric's output schema gives each finding a `confidence_score` ([rubric.md, 065e18b](https://github.com/openai/codex/blob/065e18b04021008e2e7d504db8dc50275f589f73/codex-rs/prompts/templates/review/rubric.md)). The formatter does not read it ([review_format.rs, 065e18b](https://github.com/openai/codex/blob/065e18b04021008e2e7d504db8dc50275f589f73/codex-rs/protocol/src/review_format.rs)).
- The reviewer runs with approval policy Never, web search and multi-agent tools off, and `initial_history` None ([tasks/review.rs, 065e18b](https://github.com/openai/codex/blob/065e18b04021008e2e7d504db8dc50275f589f73/codex-rs/core/src/tasks/review.rs)).
- The result returns to the parent conversation with "User may select one or more comments to resolve." ([exit_success.xml, 065e18b](https://github.com/openai/codex/blob/065e18b04021008e2e7d504db8dc50275f589f73/codex-rs/prompts/templates/review/exit_success.xml)). See What the author or human decides for the TUI side.
- OpenAI's GitHub docs say `@codex review` flags only P0 and P1 and posts a standard GitHub review ([OpenAI docs, GitHub integration, undated, read 2026-11-28](https://learn.chatgpt.com/docs/third-party/github)).
- Inferred from the rubric and the docs page: the open-source rubric (all findings, P0–P3) differs from what the GitHub service posts, and the sources do not say whether the service filters or uses another prompt.

**Anthropic's other review surfaces**

- The bundled `/code-review` "runs as a background subagent with its own context window", with `--fix` and `--comment` ([Claude Code docs, code-review-local, read 2026-11-28](https://code.claude.com/docs/en/code-review-local)).
- The managed Code Review service runs several finding agents, a verification step, dedupe and ranking, and "By itself, a review doesn't approve or block the pull request." ([Claude Code docs, code-review, read 2026-11-28](https://code.claude.com/docs/en/code-review)).
- Inferred from the findings above: neither the plugin nor Codex `/review` runs a fix-and-re-review loop; Anthropic's managed service is where multi-round handling lives.

## Published human code-review guidance

- Google tells reviewers to approve once a change "definitely improves the overall code health of the system", even if imperfect ([Google eng-practices, The Standard of Code Review, content as of 2024-05-10](https://google.github.io/eng-practices/review/reviewer/standard.html)).
- Disagreement goes to consensus first. A face-to-face talk is suggested when consensus is especially hard, and escalation to a tech lead, maintainer or manager is the common resolution ([same page](https://google.github.io/eng-practices/review/reviewer/standard.html)).
- Reviewers check design first, then functionality, complexity, tests, naming, comments, style, consistency and documentation, reading every line ([Google eng-practices, What to look for in a code review](https://google.github.io/eng-practices/review/reviewer/looking-for.html)).
- Google advises labelling severity to separate required changes from suggestions, with "Nit:", "Optional (or Consider):" and "FYI:" ([Google eng-practices, How to write code review comments](https://google.github.io/eng-practices/review/reviewer/comments.html)).
- The comments page warns that without labels, authors may read all comments as mandatory; it does not say an unlabelled comment is required ([same page](https://google.github.io/eng-practices/review/reviewer/comments.html)).
- "One business day is the maximum time it should take to respond to a code review request." ([Google eng-practices, Speed of Code Reviews](https://google.github.io/eng-practices/review/reviewer/speed.html)).
- A reviewer may approve with comments open when the author will address them all, they need not be addressed, or they are minor ([same page](https://google.github.io/eng-practices/review/reviewer/speed.html)).
- On pushback, the reviewer drops the point if the author is right, and otherwise usually insists on cleanup in this change; cleanup that cannot happen now goes into a bug the author files and takes ([Google eng-practices, Handling pushback](https://google.github.io/eng-practices/review/reviewer/pushback.html)).
- Inferred from the standard and speed pages: Google sets no round limit and bounds time instead.
- Conventional Comments separates a comment's type (praise, nitpick, suggestion, issue, question and others) from its blocking status, "(blocking)", "(non-blocking)" or "(if-minor)" ([Conventional Comments, © 2025, no version shown](https://conventionalcomments.org/)).
- Microsoft's playbook names only "Nit:" and advises "Don't block the current PR due to issues that are out of scope" ([Microsoft Playbook, Reviewer Guidance, last updated 2024-08-22](https://microsoft.github.io/code-with-engineering-playbook/code-reviews/process-guidance/reviewer-guidance/)).
- Google's code review guide has no step for reviewing a design before code; design is reviewed inside the change ([Google eng-practices, What to look for](https://google.github.io/eng-practices/review/reviewer/looking-for.html)).
- Malte Ubl's post describes Google design docs reviewed in comment threads or at a formal meeting. The doc records alternatives and trade-offs, and the review most consistently checks cross-cutting concerns such as observability, security and privacy ([Malte Ubl, "Design Docs at Google", 2020-07-06](https://www.industrialempathy.com/posts/design-docs-at-google/)). It is a personal blog, not an official Google page.
- Microsoft front-loads design decisions "before implementation begins" and records them in a decision log ([Microsoft Playbook, Design Reviews, last updated 2024-08-26](https://microsoft.github.io/code-with-engineering-playbook/design/design-reviews/)).
- Bacchelli and Bird found at Microsoft that defect-finding is the main stated motive, while reviews also bring knowledge transfer and awareness; this is a paraphrase of the abstract ([Bacchelli & Bird, ICSE 2013](https://microsoft.com/en-us/research/?p=164195)).
- Inferred from the Google and Microsoft findings: all this guidance assumes human reviewers who can meet or escalate, so its time-based limits have no direct counterpart for an agent reviewer.

## Reported weaknesses in issues and evaluations

**In the sources' trackers**

- superpowers `requesting-code-review` defaults the base to `HEAD~1`, so multi-commit work loses all but the last commit (not tested) ([obra/superpowers #2724, 2026-11-21, open](https://github.com/obra/superpowers/issues/2724)).
- mattpocock's two axes found spec gaps on a ~2,000-line diff but missed three real bugs an ad-hoc review found: "no axis traces runtime behaviour" (not tested) ([mattpocock/skills #1496, 2026-11-28, skills 1.3.1, open](https://github.com/mattpocock/skills/issues/1496)).
- When `implement` calls `code-review` before committing, "the diff is always empty" ([mattpocock/skills #1408, 2026-11-09, open](https://github.com/mattpocock/skills/issues/1408)).
- EGM checks that reviewers are fresh, not able; a weak reader makes a good spec look ambiguous and sends the loop after phantom findings ([google/elephant-goldfish-model #569, 2026-11-28, open](https://github.com/google/elephant-goldfish-model/issues/569)).
- A gsd re-review overwrites REVIEW.md, so `--fix` sees only the newest pass (found by reading the workflow, not tested) ([open-gsd/gsd-core #6699, 2026-11-26, open](https://github.com/open-gsd/gsd-core/issues/6699)).
- gsd documents a fixed loop bug: findings outside the fix scope never reached `clean`, so the fixer re-ran "with nothing to fix until the cap" ([GSD code-review-fix.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e5407be1d89ce2fffe9d1925fa2824fa36bf/gsd-core/workflows/code-review-fix.md)).
- BMAD rewrote triage around forgotten findings, findings rejected for resembling another, misgraded severity, and patched noise ([bmad-code-org/BMAD-METHOD #3105, 2026-10-18, merged](https://github.com/bmad-code-org/BMAD-METHOD/pull/3105)).
- In BMAD 6.12.1, "when the reviewer cannot read the diff, it reports a clean review" ([BMAD-METHOD #3189, 2026-11-12, closed](https://github.com/bmad-code-org/BMAD-METHOD/issues/3189)).
- BMAD warns that when subagents fall back to the main session, it is "far worse for review quality than it sounds" ([BM review-a-change.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22574fe55722841086e5566420178b98df3/docs/build/review-a-change.md)).
- In the plugin, scores of 75 fall below the 80 filter, so "the filter passes only issues scored exactly 100" ([anthropics/claude-plugins-official #1852, 2026-05-14, open](https://github.com/anthropics/claude-plugins-official/issues/1852)).
- A Haiku eligibility agent answered "no" to every disqualifier and still said NOT ELIGIBLE, and "errors at that step silently drop real issues" ([claude-plugins-official #6931, 2026-10-28, open](https://github.com/anthropics/claude-plugins-official/issues/6931)).
- A prior Claude comment exempts a PR "on every subsequent push, forever" ([claude-plugins-official #6026, 2026-09-11, open](https://github.com/anthropics/claude-plugins-official/issues/6026)).
- Inferred from superpowers #2724, mattpocock #1408, plugin #6026 and #6931, and gsd #6699: the most-reported failure is reviewing the wrong thing, and each fails silently.
- Inferred from BMAD #3189, plugin #1852 and #6931, and gsd #6699: findings get lost between reviewer and human.

**Published evaluations**

- CR-Bench reports that agents "designed to identify all hidden issues" show a low signal-to-noise ratio; the abstract gives no numbers ([Pereira et al., arXiv 2603.11078, 2026-03-10](https://arxiv.org/abs/2603.11078)).
- LLMs judging requirement conformance "frequently misclassify correct code", and prompts asking for explanations and fixes raise misjudgement rates ([arXiv 2603.00539, 2026-02-28](https://arxiv.org/abs/2603.00539)).
- Across 85 author-versus-fresh comparisons on four mid-tier model families, "we find no detectable self-preference" (−5.1 pp, 95% CI [−12.9, +2.7]) ([Guey and Bougault, arXiv 2606.20093, 2026-06-18](https://arxiv.org/abs/2606.20093)). The test covers instruction-following edits, not code review.
- A practitioner run with four reviewers stopped at a three-round budget with 7 blocking findings unresolved: "A bounded review loop with no convergence test runs to budget and exits." ([Schisler, Contrast Security, 2026-07-20](https://www.contrastsecurity.com/security-influencers/when-ai-reviewers-cannot-agree)).

## Review steps the first round did not read in full

**EGM `egm-lite`**

- Spec review (2B) and diff review (Section 4) each send one fresh reviewer that answers "`[✅ LGTM]` on zero findings, otherwise report findings only, each tagged `[P0]`–`[P3]`" ([egm-lite SKILL.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/skills/egm-lite/SKILL.md)).
- Diff review gathers every change since the baseline, omits "conversational history and authorial justification", and checks thread safety, boundaries, tests, YAGNI and contract tags ([same file](https://github.com/google/elephant-goldfish-model/blob/4693375/skills/egm-lite/SKILL.md)).
- The author agent sorts each finding as PROPOSE FIX or CONTEST, the user can overrule either, and accepted CONTEST rationales go into the checklist so they are not raised again ([same file](https://github.com/google/elephant-goldfish-model/blob/4693375/skills/egm-lite/SKILL.md)).
- Inferred from the State Transitions and Section 5 text and a grep for round, max, cap and limit: `egm-lite` has no round cap, and each round is a user command.
- The synthesizer may launch "two independent instances, A and B, for each reviewer to maximize finding recall" and retries a failed reviewer once ([EGM synthesizer.md, 4693375](https://github.com/google/elephant-goldfish-model/blob/4693375/agents/synthesizer.md)).

**gsd-core loops**

- The plan checker passes only with "zero issues of any severity. An INFO-only result is NOT `passed`." ([gsd-plan-checker.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/agents/gsd-plan-checker.md)).
- It names a reviewer bias: "Issuing warnings for what are actually blockers to avoid conflict with the planner" ([same file](https://github.com/open-gsd/gsd-core/blob/e9c3e54/agents/gsd-plan-checker.md)).
- The plan-phase loop has "max 3 iterations"; at the cap it offers "1) Force proceed, 2) Provide guidance and retry, 3) Abandon", and a missing severity "counts as a BLOCKER (fail closed)" ([plan-phase.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/plan-phase.md)).
- A stall, where the issue count does not fall, allows "Adjust approach" up to twice, then only proceed or abandon ([same file](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/plan-phase.md)).
- `plan-review-convergence` defaults to 3 cycles, is off by default, and never offers "Proceed anyway" while a plan-revision conflict is open ([plan-review-convergence.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/gsd-core/workflows/plan-review-convergence.md)).
- `gsd-code-fixer` commits each fix on its own, rolls back a fix that breaks syntax, and marks logic fixes "`fixed: requires human verification`" ([gsd-code-fixer.md, e9c3e54](https://github.com/open-gsd/gsd-core/blob/e9c3e54/agents/gsd-code-fixer.md)).
- The fixer leaves out Necessity findings by default, because "removing code is a scope decision for the human" ([same file](https://github.com/open-gsd/gsd-core/blob/e9c3e54/agents/gsd-code-fixer.md)).

**BMAD triage and route**

- Triage verifies each claim beyond the changed lines and grades it high, medium, low, false or maybe-false: "Disregard any severity a lens assigned -- it lacks the context to grade." ([step-03-triage.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-code-review/step-03-triage.md)).
- Triage forbids shortcuts: "Do not decide about finding B because it's similar to finding A", and "If you cannot decide between `medium` and `low`, pick `medium`." ([same file](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-code-review/step-03-triage.md)).
- Route sends ambiguous choices to `decision_needed` "even when running in a non-interactive mode. Do not guess and patch" ([step-04-route.md, e435a22](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-code-review/step-04-route.md)).
- A finding the change caused "is never `defer`", and a failed lens with no entries yields a warning, not a clean review ([same file](https://github.com/bmad-code-org/BMAD-METHOD/blob/e435a22/skills/method/bmad-code-review/step-04-route.md)).

**superpowers re-review and release history**

- The re-review "is not a fresh review"; it marks each prior finding "ADDRESSED | NOT ADDRESSED… 'Attempted' is not addressed" and treats reported test results as "unverified claims" ([re-review-prompt.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b46/skills/subagent-driven-development/re-review-prompt.md)).
- Issues outside the fix diff go under Out-of-Scope Observations, which "does not block this task and does not extend the loop" ([same file](https://github.com/obra/superpowers/blob/22f0b46/skills/subagent-driven-development/re-review-prompt.md)).
- v6.2.0 (2026-07-23) "installs a five-round circuit breaker with controller adjudication when it trips" ([RELEASE-NOTES.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b46/RELEASE-NOTES.md)).
- v6.3.0 (2026-08-12) bars implementers and reviewers from spawning subagents, "which was producing duplicate reviews" ([same file](https://github.com/obra/superpowers/blob/22f0b46/RELEASE-NOTES.md)).
- v6.4.2 (2026-09-25) "Removed `plan-document-reviewer-prompt.md`. Nothing referenced it." ([same file](https://github.com/obra/superpowers/blob/22f0b46/RELEASE-NOTES.md)).
- v7.0.0 (2026-10-09): "A builder check replaces the spec-document reviewer" ([same file](https://github.com/obra/superpowers/blob/22f0b46/RELEASE-NOTES.md)). The January 2026 design it replaced had an iterative reviewer with "**Status:** Approved | Issues Found" ([2026-01-22-document-review-system-design.md, 22f0b46](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/docs/superpowers/specs/2026-01-22-document-review-system-design.md)).

## Weaknesses in sources the first round did not reach

**Codex**

- A branch review returned nine findings, eight already on the target branch, because the local base was 58 commits behind `origin` ([openai/codex #63885, 2026-11-25, open](https://github.com/openai/codex/issues/63885)).
- The base-branch prompt embedded a merge-base SHA computed before the review turn, so "The reviewer may report unrelated findings or miss the actual changes" ([openai/codex #30751, 2026-06-30, closed](https://github.com/openai/codex/issues/30751)).
- In the Codex app, a finding took its line from the PR revision and its path from the local checkout, landing on unrelated code ([openai/codex #59867, 2026-11-06, open](https://github.com/openai/codex/issues/59867)).
- When the review delegate fails to start, `/review` hides the error and reports an interruption, checked in release 0.170.0 ([openai/codex #62457, 2026-11-19, open](https://github.com/openai/codex/issues/62457)).
- At least nine Codex issues from 2026-11-19 to 2026-11-25 report cybersecurity safeguards blocking ordinary reviews; these are safety filters, not the rubric (tested 2026-11-28: `gh search issues --repo openai/codex "review in:title" --sort created --limit 40`; titles only).
- No `/review` report of missed bugs or false positives turned up in relevance searches.

**spec-kit and OpenSpec**

- Running `/analyze` and fixing in a loop never settled: "every new /analyze finds new CRITICAL issues" ([github/spec-kit #543, 2025-09-24, closed as stale](https://github.com/github/spec-kit/issues/543)).
- After about 770 tasks, two were marked done with no code; a commenter says "Phantom completions happen when the same agent marks its own work done" ([github/spec-kit #1865, 2026-03-16, closed](https://github.com/github/spec-kit/issues/1865)).
- On one PR, self-review passed everything, then 28 of 38 Copilot and CodeRabbit comments were rejected: "71% of external comments were rejected" ([github/spec-kit #2054, 2026-04-01, closed](https://github.com/github/spec-kit/issues/2054)). This is one user's count on one PR.
- `/speckit.analyze` misses a closed set of values listed differently across artifacts ([github/spec-kit #4106, 2026-08-13, open](https://github.com/github/spec-kit/issues/4106)).
- When OpenSpec writes all artifacts in one pass, "scope contradictions between artifacts go undetected" ([Fission-AI/OpenSpec #783, 2026-03-01, open](https://github.com/Fission-AI/OpenSpec/issues/783)).
- A fresh agent's adversarial review of an applied change against the spec "~30% of the time it finds something" ([Fission-AI/OpenSpec #1741, 2026-08-28, open](https://github.com/Fission-AI/OpenSpec/issues/1741)).
- `/opsx:verify` "is not a code-quality review", so nothing looks for bugs ([Fission-AI/OpenSpec #2147, 2026-10-25, open](https://github.com/Fission-AI/OpenSpec/issues/2147)).

**Evaluations**

- MCR-Bench reports "performance degrading significantly as the number of interaction rounds increases", with semantically complex or low-salience defects missed more often ([arXiv 2608.27442 v1, 2026-08-27, ISSTA 2026](https://arxiv.org/abs/2608.27442)).
- AACR-Bench reports that "the granularity/level of context and the choice of retrieval methods significantly impact ACR performance" ([arXiv 2601.19494, v3 2026-01-30](https://arxiv.org/abs/2601.19494)).
- Adversarial Review reports "a false-consensus failure mode" in which "agents converge on agreement without sufficient evidence". A prompt that adds disagreement explicitly scores the highest F1 among the methods tested ([arXiv 2608.18167 v1, 2026-08-16, ICML 2026 DL4C workshop](https://arxiv.org/abs/2608.18167)). It appears under two titles at ICML.
- Fukuda et al. had GPT review real business design documents, organised 11 review perspectives, and found that LLMs can flag inconsistencies across design documents ([arXiv 2509.09975, 2025-09-12, SANER 2025](https://arxiv.org/abs/2509.09975)). Read as an abstract only.

## What the author or human decides after a review

**Google's author guide**

- The author answers a confused reviewer by clarifying the code or adding a code comment, replying in the tool only when that seems pointless ([Google eng-practices, How to Handle Reviewer Comments, read 2026-11-28](https://google.github.io/eng-practices/review/developer/handling-comments.html)).
- On disagreement, the author explains trade-offs and seeks consensus on technical facts, then points to the Standard of Code Review ([same page](https://google.github.io/eng-practices/review/developer/handling-comments.html)).
- A reviewer may reject a CL for size alone; about 100 lines is usually reasonable and 1000 usually too large ([Google eng-practices, Small CLs, read 2026-11-28](https://google.github.io/eng-practices/review/developer/small-cls.html)).

**Codex TUI**

- `/review` opens "Select a review preset" with four targets: base branch, uncommitted changes, a commit, or custom instructions (tested 2026-11-28: `gh api --method GET "repos/openai/codex/contents/codex-rs/tui/src/chatwidget/review_popups.rs?ref=065e18b..."`).
- A grep of the TUI source found no UI for selecting findings to fix (tested 2026-11-28: `grep -rn ... codex-rs/tui/src`).
- CLI findings print as unnumbered bullets, so the user cannot say "fix 1,2,7" ([openai/codex #26361, 2026-06-04, open](https://github.com/openai/codex/issues/26361)).
- The sources split on finding selection. The formatter supports `[x]`/`[ ]` markers and the exit template says the user may select comments ([review_format.rs, 065e18b](https://github.com/openai/codex/blob/065e18b04021008e2e7d504db8dc50275f589f73/codex-rs/protocol/src/review_format.rs)). The TUI grep and #26361 show no selection step. Inferred from those findings: the human acts on findings through ordinary follow-up prompts.

**Claude Code managed review and ultrareview**

- Severities are 🔴 Important ("A bug that should be fixed before merging"), 🟡 Nit and 🟣 Pre-existing ([code.claude.com/docs/en/code-review-pull-requests, read 2026-11-28](https://code.claude.com/docs/en/code-review-pull-requests)).
- The author may "merge without responding to a finding"; resolving the thread dismisses it, and "Replying alone doesn't dismiss a finding" ([same page](https://code.claude.com/docs/en/code-review-pull-requests)).
- The next review reads replies and "can resolve the thread or post one follow-up reply"; later automatic reviews focus on new changes ([same page](https://code.claude.com/docs/en/code-review-pull-requests)).
- The team may gate merges themselves using the severity counts on the check run ([same page](https://code.claude.com/docs/en/code-review-pull-requests)).
- A team tunes severity, nit caps and skipped paths in `REVIEW.md`, read only from the base or default branch; the local `/code-review` does not read it ([code.claude.com/docs/en/code-review-customize, read 2026-11-28](https://code.claude.com/docs/en/code-review-customize)).
- Ultrareview, a research preview, runs "a fleet of reviewer agents in a cloud sandbox" that reproduces and verifies every finding ([code.claude.com/docs/en/ultrareview, read 2026-11-28](https://code.claude.com/docs/en/ultrareview)).
- "Claude doesn't start an ultrareview on its own", and "`--no-post` is the default" ([same page](https://code.claude.com/docs/en/ultrareview)).

## Open questions

- **The plugin's scoring.** Issues #1852 (2026-05-14) and #6931 (2026-10-28) describe confidence scores and a Haiku scorer. The command replaced on 2026-10-26 has no numeric score. Which command version #6931 ran is not known, nor whether either issue applies at 0fbfda5.
- **Codex's hosted reviewer.** The prompt behind `@codex review` is not published in openai/codex, so whether it filters the rubric's output to P0 and P1 is unknown.
- **Evaluation numbers.** CR-Bench, MCR-Bench, AACR-Bench and Adversarial Review were read as abstracts only. No precision, recall or false-positive rates were found, and no vendor numbers for the plugin or `/review`.
- **Sycophancy in review.** No measured study of a code reviewer agreeing with the author was found and opened; the trackers' newest 300 titles held none.
- **Discussions.** GitHub Discussions were not searched in any repository; the GraphQL query returned null.
- **gsd at the `--auto` cap.** What `code-review-fix` presents after its third iteration was not read.

## Method

- The owner confirmed the brief in this session.
- A coordinator ran fresh subagents as researchers: five in round one, three in round two.
- Round one: notes 1 covered spec and plan review in the seven repositories; notes 2, their code review; notes 3, the Claude plugin and the Codex rubric; notes 4, Google's guide and other human guidance; notes 5, reported weaknesses and evaluations.
- Round two, sub-questions 6 to 8, added after confirmation: notes 6 read the EGM personas and `egm-lite`, the gsd loops, BMAD triage and route, and superpowers' re-review and release notes; notes 7 read Codex, spec-kit and OpenSpec issues and three benchmark abstracts; notes 8 read Google's author guide, the Codex TUI and the Claude Code review docs.
- The orchestrating session widened Live checks after round one had started, to read-only `gh` calls and shallow clones; the researchers' briefs already allowed these reads.
- Nothing was run beyond read-only GitHub API calls, searches, shallow clones and greps. No review step was executed, so behavioural claims are from source text and are not tested.
- The GitHub search API was rate-limited during part of round one, and several researchers ran out of tool budget; their gaps are under Open questions where they bear on the Answer.
- A fresh checker reread the cited sources on 2026-11-28: the repository files behind the Answer and the first two code and spec sections at their cited commits, every tracker issue, the vendor docs, the Google and Microsoft pages and the paper abstracts, and reran the spec-or-plan evaluation search and a Codex `/review` false-positive search. It narrowed the plugin validation step, the Codex `confidence_score` cite, five human-guidance claims and three abstract paraphrases. It replaced "no evaluation of LLM spec or plan review" with Fukuda et al. and dropped the superpowers fix-loop open question, since "Five rounds maximum per task" is in `fix-loop.md` and a case-sensitive grep for "five" misses it. No release is newer than the versions named. Not rechecked: the EGM persona files, the superpowers re-review prompt, release notes and 2026-01 design doc, and the Codex TUI files.
