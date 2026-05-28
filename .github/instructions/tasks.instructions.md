---
description: "Use when creating, editing, or reviewing Rake tasks in this project. Covers namespace conventions, task structure, logging patterns, and alias tasks."
applyTo: "**/*.rake"
---
# Tasks Instructions

## File Location
- All rake files live under `tasks/` and are auto-loaded by `Rakefile`
- Group related tasks in a subdirectory: `tasks/tests/`, `tasks/deploy/`, etc.
- Shared Ruby helpers go in `modules/shared/*.rb` (not `.rake`)

## Namespace Conventions
- Nest tasks under meaningful namespaces: `namespace :test do; namespace :ruby do`
- Namespace depth mirrors the directory structure (e.g. `tasks/tests/ruby.rake` → `test:ruby:*`)
- Top-level alias tasks in `tasks/aliases.rake` — no namespace, short names (`test`, `fix`)

## Task Structure Pattern
```ruby
namespace :category do
  namespace :subcategory do
    desc 'Short description'
    task :task_name do
      $logger.info('')
      $logger.info('Task Display Name')
      $logger.info('----------------------------------')
      command = 'shell-command --flag'
      Shared::Shell.run_command(command)
    end
  end
end

desc 'Alias (category:subcategory:task_name)'
task alias_name: %w[category:subcategory:task_name]
```

## Logging in Tasks
- Always log a blank line, a title, and a separator before running a command
- Use `$logger.info('')` for blank lines, not empty `puts`
- Separator line: `$logger.info('----------------------------------')`

## Alias Tasks
- Define aliases in `tasks/aliases.rake` using prerequisite array syntax
- Include the full task path in the `desc`: `'Alias (test:ruby:rubocop test:yaml:lint)'`
- Also add a snake_case alias at the bottom of each `.rake` file for convenience

## Shell Execution
- Prefer `Shared::Shell.run_command(command)` — logs output and errors automatically
- Use `Shared::Shell.run_command_no_output(command)` when only the exit status matters
- Use `Shared::Shell.run_command_strout(command)` when you need to capture stdout as a string
- Build commands as plain strings; use `Shellwords.escape` if interpolating variables
