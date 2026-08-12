---
name: research
description: Investigate one topic for the Discover stage — evidence from the web and the repo gathered into a docs/research/ file plus backlog lines, in a background fork. Invoke with the topic; the result arrives when the fork completes.
argument-hint: "[topic]"
disable-model-invocation: true
context: fork
agent: researcher
hooks:
  PreToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/skills/research/scripts/write-boundary.sh"
---

# Research

Research this topic: **$ARGUMENTS**

Gather from the web and from the repo — what exists today, what the options are, what the
trade-offs look like. Weigh; don't choose. Write the doc and the backlog lines as your
agent instructions define them, and deliver the doc's path plus the added lines as your
final message.
