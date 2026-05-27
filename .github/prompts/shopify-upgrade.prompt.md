---
name: shopify-upgrade
description: Upgrade Dawn theme from upstream Shopify/dawn. Checks version, prompts to confirm, updates dawn_vanilla, then merges into development. Use when Shopify releases a new Dawn version.
argument-hint: no arguments required
agent: agent
---

!`bundle exec rake shopify:upgrade`
