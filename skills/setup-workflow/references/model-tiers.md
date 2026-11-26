# Model tiers

The tiers the confirm step proposes for `docs/workflow/models.md`. Names carry no version where the harness allows it, so a new model release needs no change here.

## Tiers

| Tier     | Use for                                | Claude Code | Codex family |
| -------- | -------------------------------------- | ----------- | ------------ |
| Strong   | Shaping, spec review, code review      | `opus`      | Sol          |
| Balanced | Implementing a shaped ticket           | `sonnet`    | Terra        |
| Fast     | High-volume or simple, mechanical work | `haiku`     | Luna         |

**Write a Claude Code cell as the alias alone.** Claude Code resolves `opus`, `sonnet` and `haiku` to the newest model of that family, so the cell stays current.

**Write a Codex cell as the newest model of its family that the Codex CLI lists, with an effort that model supports.** Codex has no aliases, so the cell names a version, and a rerun of `setup-workflow` updates it. List the models with:

```bash
codex debug models | jq -r '.models[] | select(.visibility == "list") | .slug + "  " + ([.supported_reasoning_levels[].effort] | join(","))'
```

Take the slug with the highest version for each family, such as `gpt-6.1-sol` over `gpt-6-sol`. When `codex` is not installed, or no listed slug names a family, write the cell as `TODO` and ask the owner.

Confirm: `codex debug models` renders the catalog bundled with the installed CLI, which can lag the models an account can pick in `/model`. A newer CLI lists newer models.

## Proposal

Propose the Strong tier for every kind of work except Implement, which gets the Balanced tier, so every review runs on a model at least as strong as the work it judges. For Codex, propose `high` for the Strong tier and `medium` for the Balanced tier. Use a model above the Strong tier, such as Fable in Claude Code or Astra in Codex, only when the owner names it.

| Work                | Claude Code | Codex                  |
| ------------------- | ----------- | ---------------------- |
| Interview and shape | `opus`      | newest Sol, `high`     |
| Spec review         | `opus`      | newest Sol, `high`     |
| Implement           | `sonnet`    | newest Terra, `medium` |
| Code review         | `opus`      | newest Sol, `high`     |
