# Shared Module

Low-level shell execution helpers and project property access used by rake tasks and other modules throughout the project.

## Files

| File | Namespace | Purpose |
|------|-----------|---------|
| `shell.rb` | `Shared::Shell` | Shell command execution with logging and output capture |
| `properties.rb` | `Shared::Properties` | Read and cache `properties.yml` project configuration |

---

## `Shared::Properties`

Reads `properties.yml` from the repository root (searches upward from `Dir.pwd`). Results are cached in-process.

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `get` | `Hash` | Full parsed properties hash |
| `repo_local` | `String` | Local repo path (`repo.local`), falls back to `Dir.pwd` |
| `repo_remote` | `String\|nil` | Remote repo URL (`repo.remote`) |

### Usage

```ruby
Shared::Properties.repo_local    # => "/Users/levon/Development/levonbecker/my-repo"
```

### Configuration (`properties.yml`)

```yaml
repo:
  local: "/Users/you/Development/org/my-repo"
  remote: "github.com/org/my-repo"
```

---

## `Shared::Shell`

Cross-platform shell utilities wrapping `Open3` with structured `$logger` output.

### Methods

| Method | Returns | Use When |
|--------|---------|----------|
| `run_command(cmd)` | `nil` | Run a command; log stdout, stderr, exit status |
| `run_command_no_output(cmd)` | `Boolean` | Run a command; return `true`/`false` success only |
| `run_command_strout(cmd)` | `String` | Run a command; return stdout as a string |
| `clear_screen` | `nil` | Clear terminal (cross-platform) |

### Usage

```ruby
Shared::Shell.run_command('bundle exec rubocop')
success = Shared::Shell.run_command_no_output('git push')
output  = Shared::Shell.run_command_strout('git status --short')
Shared::Shell.clear_screen
```
