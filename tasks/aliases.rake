desc 'Alias (test:ruby:rubocop test:shopify:theme_check test:yaml:lint test:actions:lint)'
task test: %w[test:ruby:rubocop test:shopify:theme_check test:yaml:lint test:actions:lint]

desc 'Alias (test:ruby:rubocop:autocorrect test:shopify:fix)'
task fix: %w[test:ruby:rubocop:autocorrect test:shopify:fix]
