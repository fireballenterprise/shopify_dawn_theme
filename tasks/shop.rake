namespace :shopify do
  desc 'Pull live theme from Shopify store to local development branch. Pass THEME=<name_or_id> to specify theme.'
  task :pull do
    $logger.info('')
    $logger.info('Shopify Theme Pull')
    $logger.info('----------------------------------')
    Shopify::Pull.run(theme: ENV.fetch('THEME', nil))
  end

  desc 'Upgrade dawn_vanilla from upstream Shopify/dawn, then merge into development'
  task :upgrade do
    $logger.info('')
    $logger.info('Shopify Dawn Upgrade')
    $logger.info('----------------------------------')
    Shopify::Upgrade.run
  end
end

desc 'Alias (shopify:pull)'
task shopify_pull: %w[shopify:pull]

desc 'Alias (shopify:upgrade)'
task shopify_upgrade: %w[shopify:upgrade]
