<!-- Fill every placeholder and delete this comment before sending. The result is the sub-agent's
entire prompt. {{resume}} is empty for a fresh ticket; when the ticket is already claimed, it is
this one paragraph, with the path filled:

The ticket is already claimed: its worktree is `<absolute worktree path>` on branch
`ticket/{{reference}}/{{NN}}`. Start there, so the skill's claim step sees the branch and
skips to orient; an earlier session may have left commits or an open PR, which the skill's
own steps pick up.

-->

Run the `implement-ticket` skill for ticket {{NN}} of bundle `{{reference}}`.

Invoke it with your harness's skill mechanism — in Claude Code, the Skill tool with name
`implement-ticket` and args `{{reference}} {{NN}}` — and follow it to its last step, including
every skill it names: `workflow-manager` for the claim, `review-pr` for every review round, and the
caretaker skills for the documents reconcile touches. Where one of those skills asks for a
sub-agent, spawn it yourself.

The main checkout is `{{root}}`. The claim runs from there and prints the ticket worktree's path as
its last line; run everything after it from that worktree, with absolute paths. {{resume}}

Nobody can answer a question mid-task, so where the skill says to stop and ask the human:
finish everything that does not depend on the answer, do not build around the question, and carry
it into your final report with both positions. Never run the workflow-manager `complete` command;
stop at the Accept gate as the skill says.

Your final message is the hand-back the skill's last step defines, with the backlog lines listed
in it in the `backlog` skill's `+ [kind] [area] ...` form, proposed only and not written, plus the
ticket worktree's absolute path.
