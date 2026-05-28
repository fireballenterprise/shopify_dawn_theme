module Shopify
  module Pull
    def self.run
      require 'shellwords'

      repo_path = Shared::Properties.repo_local
      store     = Shared::Properties.shopify_store

      confirm_branch(repo_path)
      confirm_clean(repo_path)

      $logger.info('')
      $logger.info("Pulling theme from #{store}...")
      $logger.info('')

      # shopify CLI requires a live TTY for auth and progress output — system() is intentional
      success = system("shopify theme pull --store=#{Shellwords.escape(store)}")

      unless success
        $logger.error('shopify theme pull failed.')
        exit(1)
      end

      $logger.info('')
      show_changes(repo_path)
      $logger.info('')
      $logger.info('Review changes above, then run /push to commit and push to git.')
    end

    def self.confirm_branch(repo_path)
      require 'shellwords'

      branch = Shared::Shell.run_command_strout(
        "git -C #{Shellwords.escape(repo_path)} rev-parse --abbrev-ref HEAD"
      ).strip

      return if branch == 'development'

      $logger.warn("Current branch is '#{branch}', expected 'development'.")
      return unless $stdin.tty?

      print "Continue theme pull onto '#{branch}'? [y/N]: "
      answer = $stdin.gets.chomp
      return if answer.downcase == 'y'

      $logger.info('Pull cancelled. Switch to development branch first.')
      exit(0)
    end

    def self.confirm_clean(repo_path)
      require 'shellwords'

      out = Shared::Shell.run_command_strout(
        "git -C #{Shellwords.escape(repo_path)} status --porcelain"
      )
      return if out.strip.empty?

      $logger.warn('Uncommitted changes detected. Theme pull may overwrite local edits.')
      return unless $stdin.tty?

      print 'Continue anyway? [y/N]: '
      answer = $stdin.gets.chomp
      return if answer.downcase == 'y'

      $logger.info('Pull cancelled. Commit or stash your changes first.')
      exit(0)
    end

    def self.show_changes(repo_path)
      require 'shellwords'

      out = Shared::Shell.run_command_strout(
        "git -C #{Shellwords.escape(repo_path)} status --short"
      )
      if out.strip.empty?
        $logger.info('No changes — store and local are already in sync.')
      else
        $logger.info('Changes pulled from store:')
        out.each_line { |line| $logger.info("  #{line.chomp}") }
      end
    end
  end
end
