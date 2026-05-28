---
description: "Use when writing, editing, or reviewing Ruby code in this project. Covers Ruby version, style, module conventions, and RuboCop configuration."
applyTo: "**/*.rb"
---
# Ruby Instructions

## Ruby Version
Target: `~> 4.0.0` (defined in `Gemfile`, pinned to `4.0.5` in `.ruby-version`)
- Managed via `rbenv`; install with `arch -arm64 rbenv install 4.0.5` (Apple Silicon native)
- `.rubocop.yml` `TargetRubyVersion: 4.0`

## VS Code Tooling
- **Ruby LSP** (`Shopify.ruby-lsp`) provides language features and runs RuboCop from the project bundle
- Configured in `.vscode/settings.json` to use `rbenv` + the project's `Gemfile`
- Do **not** install `lorankloeze.ruby-rubocop-revived` — it duplicates Ruby LSP's RuboCop integration
- `Shopify.theme-check-vscode` handles Liquid linting (separate from Ruby tooling)

## Style & Linting
- **RuboCop** enforces all style rules — run `rake test:ruby:rubocop` to check
- Run `rake test:ruby:rubocop:autocorrect` (or `rake fix`) to auto-correct offenses
- RuboCop plugins in use: `rubocop-rake`, `code-scanning-rubocop`
- Disable cops inline only when necessary, using `# rubocop:disable`/`# rubocop:enable` block comments (not end-of-line)

## Module & File Conventions
- Use nested module syntax: `module Outer; module Inner; end; end`
- Files under `modules/shared/` define modules under the `Shared` namespace (e.g. `Shared::Shell`)
- Files under `modules/repo/` define modules under the `Repo` namespace (e.g. `Repo::Push`)
- All methods on shared modules are defined as `self.method_name` (module-level methods, no instances)

## Logging
- Use the global `$logger` for all output — do not use `puts` or `print` in tasks
- Log levels: `$logger.info(...)`, `$logger.debug(...)`, `$logger.error(...)`
- Prefix log messages with the module path: `[Module::Class.method_name]`

## Shell Commands
- Use `Shared::Shell` methods from `modules/shared/shell.rb` for all shell execution in both modules and tasks
- `run_command(cmd)` — fire-and-forget; logs stdout/stderr via `$logger`
- `run_command_no_output(cmd)` — returns `true`/`false`; use when you need to branch on success
- `run_command_strout(cmd)` — returns stdout as a string; use when you need to read command output
- Only use `system()` directly for interactive CLI commands that require a live TTY (e.g. `shopify theme pull`); add a comment explaining why
- Always use `Shellwords.escape` when interpolating variables into shell command strings
- Do not `require 'open3'` in modules — `Shared::Shell` handles it internally; only `require 'shellwords'` when building command strings

## Example Module Pattern
```ruby
module Shared
  module MyModule
    def self.do_something(arg)
      $logger.info("[Shared::MyModule.do_something] Starting")
      # ...
    end
  end
end
```
