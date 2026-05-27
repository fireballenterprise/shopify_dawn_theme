---
name: push
description: Push changes to git remote. Runs rake fix, rake test, then commits and pushes.
argument-hint: no arguments required
agent: agent
---

!`bundle exec rake repo:push`
