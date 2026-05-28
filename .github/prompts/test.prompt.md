---
name: test
description: Run all tests and linters. Use when you want to run rubocop and yamllint.
argument-hint: no arguments required
agent: agent
---

Run all tests:

!`bundle exec rake test`

If all tests pass, report success and stop.

If any tests fail:
- For RuboCop offenses: attempt to auto-fix by running `bundle exec rake fix`, then re-run `bundle exec rake test` to confirm. If offenses remain after auto-fix, show the remaining failures and ask the user how they would like to proceed.
- For YAML lint failures: show the offending lines and ask the user how they would like to proceed.
- For actionlint failures: show the offending workflow file and line, and ask the user how they would like to proceed.
- For any other failures: show the full error output and ask the user how they would like to approach fixing it.
