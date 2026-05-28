namespace :test do
  namespace :actions do
    # https://github.com/rhysd/actionlint

    desc 'GitHub Actions linter'
    task :lint do
      $logger.info('')
      $logger.info('Running Actions Linter')
      $logger.info('----------------------------------')

      unless system('which actionlint > /dev/null 2>&1')
        $logger.error('actionlint not found — run: brew install actionlint')
        exit(1)
      end

      success = system('actionlint')
      $logger.info('No Offenses') if success
    end
  end
end

desc 'Alias (test:actions:lint)'
task test_actions: %w[test:actions:lint]
