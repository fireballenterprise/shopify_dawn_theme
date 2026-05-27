namespace :repo do
  desc 'Pull updates from git remote (stash → pull --rebase → restore)'
  task :pull do
    $logger.info('')
    $logger.info('Repo Pull')
    $logger.info('----------------------------------')
    Repo::Pull.run
  end

  desc 'Push to git remote (fix → test → commit → push)'
  task :push do
    $logger.info('')
    $logger.info('Repo Push')
    $logger.info('----------------------------------')
    Repo::Push.run(confirm: false)
  end

  desc 'Save a session log to logs/'
  task :log do
    $logger.info('')
    $logger.info('Repo Log')
    $logger.info('----------------------------------')
    Repo::Log.run
  end

  desc 'Anchored squash of all commits to root with optional force push'
  task :squash do
    $logger.info('')
    $logger.info('Repo Squash')
    $logger.info('----------------------------------')
    Repo::Squash.run
  end

  desc 'Rebase onto remote default branch (optionally squash first)'
  task :rebase do
    $logger.info('')
    $logger.info('Repo Rebase')
    $logger.info('----------------------------------')
    Repo::Rebase.run
  end
end

desc 'Alias (repo:pull)'
task repo_pull: %w[repo:pull]

desc 'Alias (repo:push)'
task repo_push: %w[repo:push]

desc 'Alias (repo:log)'
task repo_log: %w[repo:log]

desc 'Alias (repo:squash)'
task repo_squash: %w[repo:squash]

desc 'Alias (repo:rebase)'
task repo_rebase: %w[repo:rebase]
