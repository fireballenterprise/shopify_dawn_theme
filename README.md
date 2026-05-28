# Fireball Enterprise Shopify Dawn Theme

Shopify Dawn theme fork for [Fireball Enterprise](https://fireballenterprise.com). Customized theme with Ruby Rake tooling for local linting, git workflow automation, and AI Copilot prompts.

[![tests](https://github.com/fireballenterprise/shopify_dawn_theme/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/fireballenterprise/shopify_dawn_theme/actions/workflows/tests.yml?query=branch%3Amain)

## Prerequisites

- [Ruby](https://www.ruby-lang.org/) `~> 3.4.0` (via [rbenv](https://github.com/rbenv/rbenv))
- [Bundler](https://bundler.io/)
- [Homebrew](https://brew.sh/) (for `actionlint`)
- [Shopify CLI](https://shopify.dev/docs/storefronts/themes/tools/cli) (`npm install -g @shopify/cli`)

## Setup

```sh
./setup.sh
```

Installs rbenv Ruby version, Homebrew tools, and gems via Bundler. Update `properties.yml` with the local repo path before running tasks.

## Project Structure

```
Gemfile               # Gem dependencies (Ruby ~> 3.4.0)
Rakefile              # Auto-loads modules/**/*.rb and tasks/**/*.rake
setup.sh              # Initial environment setup
properties.yml        # Project configuration (repo path, remote)
assets/               # Theme JS, CSS, images (synced to Shopify)
config/               # Theme settings schema (synced to Shopify)
layout/               # Theme layout files (synced to Shopify)
locales/              # Translation strings (synced to Shopify)
sections/             # Theme sections (synced to Shopify)
snippets/             # Theme snippets (synced to Shopify)
templates/            # Theme templates (synced to Shopify)
modules/
  shared/             # Shared::Shell, Shared::Properties
  repo/               # Repo::Pull, Push, Log, Squash, Rebase
tasks/
  aliases.rake        # Top-level aliases: rake test, rake fix
  repo.rake           # repo:pull, push, log, squash, rebase
  tests/
    ruby.rake         # RuboCop lint + autocorrect
    shopify.rake      # theme-check lint + autocorrect
    yaml.rake         # yamllint
    actions.rake      # actionlint
.github/
  instructions/       # Copilot instructions per concern
  prompts/            # /push, /pull, /squash, /rebase, /test, /fix prompts
  workflows/
    tests.yml              # CI: RuboCop + theme-check + yamllint + actionlint
    feature_branches.yml   # Run tests on feature branch pushes and PRs
    protected_branches.yml # Run tests on pushes to main
    deploy_dev.yml         # Deploy to Shopify development theme
    deploy_prd.yml         # Deploy to Shopify production theme
    promote_to_prd.yml     # Promote development theme to production
```

## Branch Strategy

This repo is a fork of [Shopify/dawn](https://github.com/Shopify/dawn). All three branches are protected.

| Branch | Purpose |
|--------|---------|
| `dawn_vanilla` | Tracks upstream `Shopify/dawn` — merge upstream releases here first |
| `development` | Active development branch — open PRs targeting this branch |
| `main` | Production — merges from `development` only, triggers prod deploy |

```
upstream/main → dawn_vanilla → development → main (production)
```

## Rake Tasks

```sh
rake                  # List all available tasks
rake test             # RuboCop + theme-check + yamllint + actionlint
rake fix              # RuboCop autocorrect + theme-check autocorrect
rake repo:pull        # Pull from git remote (stash → pull --rebase → restore)
rake repo:push        # Push to git remote (fix → test → commit → push)
rake repo:log         # Save a session log to logs/
rake repo:squash      # Anchored squash all commits to root + optional force push
rake repo:rebase      # Rebase onto remote default branch (optionally squash first)
```

## Shopify CLI

```sh
# Sync live Shopify theme edits → local repo
shopify theme pull --store=fireballenterprise.myshopify.com

# Push local theme changes → Shopify store
shopify theme push --store=fireballenterprise.myshopify.com
```

After pulling, commit to keep the repo in sync with GUI edits made in the Shopify theme editor.

## AI Prompts

| Prompt | Command | Description |
|--------|---------|-------------|
| `/push` | `bundle exec rake repo:push` | Fix, test, commit, and push to git |
| `/pull` | `bundle exec rake repo:pull` | Stash, pull latest, restore stash |
| `/test` | `bundle exec rake test` | Run all linters |
| `/fix` | `bundle exec rake fix` | Auto-correct RuboCop + theme-check offenses |
| `/squash` | `bundle exec rake repo:squash` | Anchored squash all commits to root |
| `/rebase` | `bundle exec rake repo:rebase` | Rebase onto remote default branch |

## Modules

| Module | Namespace | Purpose |
|--------|-----------|---------|
| `modules/shared/` | `Shared::Shell`, `Shared::Properties` | Shell helpers and `properties.yml` config reader |
| `modules/repo/` | `Repo::Pull`, `Repo::Push`, `Repo::Log`, `Repo::Squash`, `Repo::Rebase` | Git workflow automation |

See [modules/README.md](modules/README.md) for full details.

## CI

GitHub Actions runs RuboCop, theme-check, yamllint, and actionlint on every feature branch push and PR via `.github/workflows/tests.yml`. Pushes to `main` trigger the production deploy workflow.

