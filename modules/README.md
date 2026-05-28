# Modules

Reusable Ruby modules auto-loaded by the `Rakefile` via `Dir.glob('modules/**/*.rb')`. All modules use module-level `self` methods — no instantiation required.

## Structure

```
modules/
  shared/       # Shared::Shell, Shared::Properties
  repo/         # Repo::Pull, Repo::Push, Repo::Log, Repo::Squash, Repo::Rebase
```

## Submodules

| Directory | Namespace | Purpose |
|-----------|-----------|----------|
| [`shared/`](shared/README.md) | `Shared::Shell`, `Shared::Properties` | Shell execution helpers and `properties.yml` config reader |
| [`repo/`](repo/README.md) | `Repo::Pull`, `Repo::Push`, `Repo::Log`, `Repo::Squash`, `Repo::Rebase` | Git workflow, session logging, squash, and rebase |

## Convention

- One Ruby module per file; filename matches the innermost module name in snake_case
- Namespace mirrors directory: `modules/repo/pull.rb` → `module Repo; module Pull`
- All methods defined as `self.method_name` on the module
- `require` stdlib dependencies inside the method body (lazy loading)
- Use `$logger` for all output — never `puts`
