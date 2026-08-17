## Discovery

### Option A: From backlog item

- User can use /pick skill

### Option B: Interview

- User starts /interview-me

### Option C: Codebase audit

- user starts /audit skill which (the current skill is wrong) does a full or narrow audit of the codebase, suggests improvements, simplifications, best practices, etc.

**Open question**:

- is the audi report already a bundle artifcat?

## Shape

- User triggers /shape skill, agent creates bundle, triggers critique skill

- Agent provides brief summary of what will be built and tickets as well as a suggetstion on the sequence (what must be single, what be be implement in parallel)
  - Also users gets prompts for building the next ticket

**Open question**:

- Does user trigger /to-tickets skill themselves?
- Is there a /to-plan skill that is user-triggered or automatically?
- How do we decide which bundle it will be (including spec, plan, multiple tickets)?
- Which skill involves understanding of the codebase, which doesn't?
- To which branch do we commit the bundle? (a new PR into main would be a bit much no?)?

## Implement (for each ticket)

- User uses suggested prompt or writes one for the implementation skill to get started (most liekly new chat session)
  - Sub-agent in main conversation tbd if that is feasible
- If first ticket, a new worktree and branch must be created (if mutiple tickets) as the target bundle branch
- Implement skill and corresponding agents
  - Creates worktree and branch for this ticket
  - builds the ticket and does it's check
  - Once done and everything is green, opens PR with summary (based on template, including checks, what deviated from spec and why, etc.)

## Review - fix loop

- Same implementation session kicks off review agent to review with prompt to specifally work on that PR and review diff
  - review agent posts comment in structured format based on template into PR
    - Blockers
    - Concerns
  - also returns summary back to implementation
  - Mayebe we even do review based on two axes like mattpott skills (does it meet spec? and does it meet codebase requirement and conventions?)
- Same implementation sessions validates these findings (tbd if that is good practice) and fixes blockers and maybe concerns too?
- Once done, posts fixes done to PR and starts new review session
  - Starts from beginning
  - Max 3 loops for now
- Implemenation session gives final summary of what was built and fixes and recommends view

- Users reviews the PR and diff in detail and would either a) call a /complete-ticket skill to merge the PR into target branch or b) merges PR themselves

**Open question**:

- What if users wants to make some changes themselves (minor or major changes)?

## Ship

- Once all tickets are done, user goes back to main conversation (can be basically any session but the previous main one is good since it has context about which bundle) and triggers /ship skill on that bundle

- Bundle gets deleted from git
