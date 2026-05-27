---
description: "Use when working with Shopify theme files, Shopify CLI, or theme-check. Covers theme structure, sync workflow, Dawn conventions, and Shopify-specific tooling."
applyTo: "{assets,config,layout,locales,sections,snippets,templates}/**"
---
# Shopify Instructions

## Theme Overview
A fork of [Shopify Dawn](https://github.com/Shopify/dawn) customized for Fireball Enterprise (fireballenterprise.com). Dawn is Shopify's reference theme built on Online Store 2.0.

## Shopify Theme Directories
Only these directories are synced to Shopify via CLI — do not put Ruby tooling here:
| Directory | Purpose |
|-----------|---------|
| `assets/` | JS, CSS, images, fonts |
| `config/` | Theme settings schema (`settings_schema.json`, `settings_data.json`) |
| `layout/` | Base layout files (`theme.liquid`) |
| `locales/` | Translation strings (`.json`) |
| `sections/` | Shopify sections (`.liquid` + optional `schema`) |
| `snippets/` | Reusable Liquid snippets |
| `templates/` | Page templates (JSON or Liquid) |

## Shopify CLI Sync Workflow
```sh
# Pull live theme edits from Shopify → local repo
shopify theme pull --store=fireballenterprise.myshopify.com

# Push local changes → Shopify store
shopify theme push --store=fireballenterprise.myshopify.com

# After pulling, commit to keep repo in sync
git add -A && git commit -m "Sync theme edits"
```

## Staging with Unpublished Themes
- Duplicate the live theme in Shopify Admin → edit the duplicate → preview → publish
- No separate dev store needed at this scale

## Theme Linting
```sh
rake test:shopify:theme_check   # Run theme-check linter
rake test_theme                 # Alias
rake test:shopify:fix           # Auto-correct theme-check offenses
```

## Liquid Conventions
- Follow [Dawn's](https://github.com/Shopify/dawn) existing patterns for new sections/snippets
- Use `{{ 'file.css' | asset_url | stylesheet_tag }}` for asset loading
- Prefer `render` over `include` for snippets
- Section schemas go in the same `.liquid` file as a `{% schema %}` block

## settings_schema.json / settings_data.json
- `config/settings_schema.json` — defines theme editor controls
- `config/settings_data.json` — stores current theme editor values (managed by Shopify GUI — do not manually edit)

## .shopifyignore
No `.shopifyignore` is needed — the CLI only syncs the known theme directories above. Use `.shopifyignore` only if you need to exclude specific files *within* those directories from syncing.
