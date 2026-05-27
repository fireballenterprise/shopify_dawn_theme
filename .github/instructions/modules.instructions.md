---
description: "Use when creating or editing shared Ruby library modules used by rake tasks or prompts. Covers modules/ structure, module patterns, and helper conventions."
applyTo: "modules/**/*.rb"
---
# Lib Instructions

## Purpose
Library modules provide reusable Ruby logic consumed by rake tasks, prompts, and scripts. They contain no task definitions — only module-level methods.

## Locations
| Path | Namespace | Purpose |
|------|-----------|---------|
| `modules/shared/` | `Shared::*` | Helpers tightly coupled to rake tasks |
| `modules/repo/` | `Repo::*` | Git workflow logic (pull, push, log) |
| `modules/shopify/` | `Shopify::*` | Shopify CLI and Dawn upgrade workflows |

## Module Conventions
- All modules use `self.method_name` — no class instantiation
- Nest under a namespace matching the directory: `modules/shared/shell.rb` → `module Shared; module Shell`
- `modules/repo/*.rb` → `module Repo; module <Name>`
- One module per file; filename matches the innermost module name in snake_case

## Method Patterns
```ruby
module Shared
  module Shell
    def self.method_name(arg)
      require 'some_stdlib'           # require inside method if not always needed
      $logger.debug("[Shared::Shell.method_name] ...")
      # implementation
    end
  end
end

module Repo
  module Pull
    def self.run
      # implementation
    end
  end
end
```

## Shell Helper Methods (Shared::Shell)
| Method | Use When |
|--------|----------|
| `run_command(cmd)` | Run a command; log stdout, stderr, and status |
| `run_command_no_output(cmd)` | Run a command; return boolean success only |
| `run_command_strout(cmd)` | Run a command; return stdout as a string |
| `clear_screen` | Clear the terminal (cross-platform) |

## Guidelines
- Use `Open3.capture3` for shell execution — never backticks or `system` in lib code
- Always escape shell arguments with `Shellwords.escape`
- Use `$logger` for all logging; never `puts`
- Keep methods focused and single-purpose
- `require` stdlib dependencies inside the method body to avoid eager loading
