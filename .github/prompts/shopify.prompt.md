---
name: shopify
description: Run a Shopify theme action. Use when pulling the live theme from the store or upgrading Dawn from upstream. Pass 'pull' to sync down from the store, or 'upgrade' to update from Shopify/dawn upstream.
argument-hint: pull | upgrade
agent: agent
---

!`bundle exec rake shopify:${input:action:pull or upgrade}`
