---
name: shop
description: Run a Shopify theme action. Use when pulling the live theme from the store or upgrading Dawn from upstream. Pass 'pull' to sync down from the store, or 'upgrade' to update from Shopify/dawn upstream.
argument-hint: pull | upgrade
agent: agent
---

Ask the user: what action do you want to run — `pull` or `upgrade`?

If the action is `pull`, also ask: which theme should be pulled? (theme name or ID — leave blank to use the store default)

Then run:

- If action is `upgrade`: `bundle exec rake shopify:upgrade`
- If action is `pull` with no theme: `bundle exec rake shopify:pull`
- If action is `pull` with a theme: `bundle exec rake shopify:pull THEME="<theme>"`
