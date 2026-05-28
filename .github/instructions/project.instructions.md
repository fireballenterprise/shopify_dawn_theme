---
description: "Use when working on overall project structure, conventions, dependencies, or setup. Covers project layout, Gemfile, Rakefile, and general organization."
---
# Project Instructions

## Overview
Shopify Dawn theme fork for Fireball Enterprise (fireballenterprise.com). Uses Rake for local task automation. Targets Ruby `~> 3.4.0`. Theme files are synced to Shopify via `shopify theme pull/push`; tooling files (modules/, tasks/, .github/) are local-only.

## Project Structure
```
Gemfile           # Gem dependencies
Rakefile          # Entry point — loads modules/**/*.rb and tasks/**/*.rake
setup.sh          # Shell-based setup script
properties.yml    # Repo path + remote config used by modules
assets/           # Theme JS, CSS, images (synced to Shopify)
config/           # Theme settings schema (synced to Shopify)
layout/           # Theme layout files (synced to Shopify)
locales/          # Translation files (synced to Shopify)
sections/         # Theme sections (synced to Shopify)
snippets/         # Theme snippets (synced to Shopify)
templates/        # Theme templates (synced to Shopify)
modules/
  shared/         # Shared Ruby modules used by rake tasks
    shell.rb      # Shared::Shell module
    properties.rb # Shared::Properties module (reads properties.yml)
  repo/           # Git workflow modules
    pull.rb       # Repo::Pull module
    push.rb       # Repo::Push module
    log.rb        # Repo::Log module
    squash.rb     # Repo::Squash module
    rebase.rb     # Repo::Rebase module
tasks/
  aliases.rake    # Top-level alias tasks (e.g. `rake test`, `rake fix`)
  repo.rake       # repo:pull, repo:push, repo:log, repo:squash, repo:rebase
  tests/          # Namespaced test rake tasks
    ruby.rake     # test:ruby:rubocop, test:ruby:rubocop:autocorrect
    shopify.rake  # test:shopify:theme_check, test:shopify:fix
    yaml.rake     # test:yaml:lint
    actions.rake  # test:actions:lint
.github/
  instructions/   # Copilot instruction files
  prompts/        # Copilot prompt files (/push, /pull, /test, /fix, etc.)
  workflows/      # GitHub Actions CI workflows
```

## Key Conventions
- Shopify theme dirs (`assets/`, `sections/`, etc.) are synced via Shopify CLI — do not add Ruby tooling there
- All `.rb` files under `modules/` are auto-loaded by `Rakefile` via `Dir.glob('modules/**/*.rb')`
- All `.rake` files under `tasks/` are auto-loaded by `Rakefile` via `Dir.glob('tasks/**/*.rake')`
- Global logger: `$logger` (stdout, message-only format) — use for all task output
- Global flag: `$VERBOSE = nil` suppresses Ruby warnings

## Dependencies (Gemfile)
- `rake` — task runner
- `rubocop`, `rubocop-rake`, `code-scanning-rubocop` — Ruby linting
- `theme-check` — Shopify theme linter
- `colorize` — terminal color output
- `highline`, `tty-prompt` — interactive CLI prompts
- `logger` — logging (`~> 1.7`)
- `benchmark`, `base64`, `ostruct` — stdlib gems

## Git Branch Architecture
```
upstream/main (Shopify/dawn)
      │
      ▼
dawn_vanilla      # Tracks upstream Shopify Dawn — never customized
      │
      ▼
development       # Integration branch — custom work merged here
      │
      ▼
main              # Production branch — only promoted from development
```
- `dawn_vanilla` — local branch that pulls from `upstream/main` (Shopify's repo). Keeps Shopify's history separate from custom code.
- `development` — active development branch. PRs merge here; deploys to the dev Shopify theme on merge.
- `main` — production branch. Only updated via `promote_to_prd` workflow (manual, requires confirmation). Deploys to live store.
- `feature/*` — short-lived feature branches; PR targets `development`.
- Upstream Dawn upgrades: `rake shopify:upgrade` fetches `upstream/main` → merges into `dawn_vanilla` → merges into `development`. No manual branch switching needed.

## Running Tasks
```sh
rake                      # List all tasks (default)
rake test                 # RuboCop + theme-check + yamllint + actionlint
rake fix                  # RuboCop autocorrect + theme-check autocorrect
rake repo:pull            # Pull from git remote (stash → pull → restore)
rake repo:push            # Push to git remote (fix → test → commit → push)
rake repo:log             # Save a session log to logs/
shopify theme pull        # Sync live theme → local repo
shopify theme push        # Push local theme → Shopify store
```
