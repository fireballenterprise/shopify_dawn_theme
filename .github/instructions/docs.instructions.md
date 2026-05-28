---
description: "Use when writing or updating project documentation including README, setup guides, or inline code comments."
applyTo: "*.md"
---
# Docs Instructions

## Files
| File | Purpose |
|------|---------|
| `README.md` | Project overview, setup, and usage |
| `setup.sh` | Shell setup script (self-documenting via comments) |
| `.github/instructions/` | Copilot instruction files for each concern |

## README Conventions
- Lead with a short one-sentence project description
- Include: Prerequisites, Installation/Setup, Usage (rake commands), and Contributing sections
- Show rake commands in fenced `sh` code blocks
- Keep it concise — link out rather than duplicating content

## Inline Code Comments
- Comment the *why*, not the *what*
- Reference external docs or issue numbers when a workaround is non-obvious
- Use `# rubocop:disable Cop/Name` with an explanation comment on the same or preceding line

## Instruction Files (`.github/instructions/`)
- One file per concern (ruby, tasks, lib, tests, docs, prompts, project)
- Always include a `description` in YAML frontmatter using the "Use when..." pattern
- Use `applyTo` glob only when the instruction is relevant to a specific file type or directory
- Keep instructions actionable and example-driven — prefer short code blocks over prose
