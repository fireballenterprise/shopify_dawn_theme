---
description: "Use when adding, editing, or running tests and linters in this project. Covers RuboCop, yamllint, actionlint, and Shopify theme-check rake task conventions."
applyTo: "tasks/tests/**"
---
# Tests Instructions

## Test Tooling
| Tool | Covers | Run With |
|------|--------|----------|
| RuboCop | Ruby style & lint | `rake test:ruby:rubocop` |
| theme-check | Shopify theme lint | `rake test:shopify:theme_check` |
| yamllint | YAML files | `rake test:yaml:lint` |
| actionlint | GitHub Actions workflows | `rake test:actions:lint` |

## Running Tests
```sh
rake test               # All: rubocop + theme-check + yamllint + actionlint
rake test_ruby          # Ruby only
rake test_theme         # Shopify theme-check only
rake test_yaml          # YAML only
rake test_actions       # GitHub Actions lint only
rake fix                # Auto-correct: rubocop + theme-check --auto-correct
```

## File Structure
```
tasks/tests/
  ruby.rake     # test:ruby:rubocop, test:ruby:rubocop:autocorrect
  shopify.rake  # test:shopify:theme_check, test:shopify:fix
  yaml.rake     # test:yaml:lint
  actions.rake  # test:actions:lint
```

## Adding a New Test Task
1. Create `tasks/tests/<tool>.rake`
2. Namespace as `test:<tool>:<action>`
3. Add to the `test` alias in `tasks/aliases.rake`
4. Add a snake_case alias at the bottom of the new file

## RuboCop
- Config lives in `.rubocop.yml` at project root
- Use `RuboCop::RakeTask.new` for standard integration (see `tasks/tests/ruby.rake`)
- Pass `--display-cop-names` to show which cop triggered each offense
- Autocorrect: `rake test:ruby:rubocop:autocorrect`

## theme-check
- Lints Shopify theme files (`assets/`, `sections/`, `snippets/`, `templates/`, etc.)
- Runs: `theme-check .`
- Auto-correct: `theme-check . --auto-correct`
- Config: `.theme-check.yml` at project root (if present)

## yamllint
- Config lives in `.yamllint` at project root
- Runs: `yamllint -c .yamllint .`

## actionlint
- Lints GitHub Actions workflow files under `.github/workflows/`
- Install: `brew install actionlint`
- Runs: `actionlint`
