---
description: "Use when creating or editing Copilot prompt files for this project. Covers prompt structure, frontmatter, naming, and how prompts interact with rake tasks and lib modules."
applyTo: ".github/prompts/**"
---
# Prompts Instructions

## Location
All prompt files live in `.github/prompts/*.prompt.md`

## Frontmatter
```yaml
---
description: "Short description of what the prompt does. Use when: <trigger phrase>."
---
```
- `description` is required — it's how the agent discovers and invokes the prompt
- Use the "Use when..." pattern with specific trigger keywords

## Prompt Design Guidelines
- One focused task per prompt — do not combine unrelated workflows
- Parameterize inputs with placeholders: `${input:taskName}`, `${input:description}`
- Reference rake tasks by their full namespace: `rake test:ruby:rubocop`
- Reference shared modules by full path: `Shared::Shell.run_command`
- Keep prompts concise — they share context window with instructions

## Interacting with This Project
- To run linting: `rake test`
- To auto-fix: `rake fix`
- To add a new rake task: follow `tasks.instructions.md` conventions
- To add a new shared module: follow `lib.instructions.md` conventions

## Naming
- Use kebab-case filenames: `create-rake-task.prompt.md`
- Name should describe the action, not the subject: `add-gem.prompt.md` not `gemfile.prompt.md`
