---
name: research
description: Investigate one topic for the Discover stage — evidence from the web and the repo gathered into a docs/research/ file plus backlog lines, in a background fork. Invoke with the topic; the result arrives when the fork completes.
argument-hint: "[topic]"
disable-model-invocation: true
context: fork
agent: researcher
background: true
hooks:
  PreToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/write-boundary.sh --reason 'the researcher writes only docs/research/ and work/backlog.md' 'docs/research/*' work/backlog.md"
---

# Research

Research this topic: **$ARGUMENTS**

Gather from the web and from the repo — what exists today, what the options are, what the
trade-offs look like.

**Deliverable — exactly one file under `docs/research/`**, named `research-<YYYY-MM>-<slug>.md`,
filled from `${CLAUDE_SKILL_DIR}/templates/research-doc.md`; the template carries its own fill
guidance. The doc holds what the investigation established as durable reference — evidence for
one specific bundle does not belong in it; that lives with the bundle
(`${CLAUDE_PLUGIN_ROOT}/workflow/artifacts.md` owns the split).

**Then the backlog**: turn each actionable finding into one `work/backlog.md` line pointing at
the doc, following the preloaded backlog skill's entry rules — the problem, not a proposed
solution. Findings that aren't actionable stay in the doc only; padding the backlog to look
productive defeats the Pick gate it feeds.

Deliver the doc's path plus the added backlog lines as your final message.
