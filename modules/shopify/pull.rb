module Shopify
  module Pull
    def self.run(theme: nil)
      require 'shellwords'

      ensure_shopify_env!

      repo_path = Shared::Properties.repo_local
      store     = Shared::Properties.shopify_store

      confirm_branch(repo_path)
      confirm_clean(repo_path)

      theme_flag = theme ? " --theme=#{Shellwords.escape(theme)}" : ''

      $logger.info('')
      $logger.info("Pulling theme#{" '#{theme}'" if theme} from #{store}...")
      $logger.info('')

      # shopify CLI requires a live TTY for auth and progress output — system() is intentional
      success = system("shopify theme pull --store=#{Shellwords.escape(store)}#{theme_flag}")

      unless success
        $logger.error('shopify theme pull failed.')
        exit(1)
      end

      $logger.info('')
      show_changes(repo_path)
      $logger.info('')
      $logger.info('Review changes above, then run /push to commit and push to git.')
    end

    def self.ensure_shopify_env!
      store_set = ENV['SHOPIFY_FLAG_STORE'].to_s.strip
      token_set = ENV['SHOPIFY_CLI_THEME_TOKEN'].to_s.strip

      return if store_set.length.positive? && token_set.length.positive?

      $logger.warn('SHOPIFY_FLAG_STORE and/or SHOPIFY_CLI_THEME_TOKEN are not set.')

      unless $stdin.tty?
        $logger.error('Cannot prompt for Shopify credentials in a non-interactive session. Set env vars and retry.')
        exit(1)
      end

      $logger.info('These values are used by shopify theme pull and are exported for this session only.')
      $logger.info('')

      if store_set.empty?
        print 'Enter your Shopify store domain (e.g. mystore.myshopify.com): '
        store_set = $stdin.gets.to_s.chomp.strip
      end

      if token_set.empty?
        print 'Enter your Shopify Theme Access token (from Shopify Admin > Apps > Theme Access): '
        token_set = $stdin.gets.to_s.chomp.strip
      end

      if store_set.empty? || token_set.empty?
        $logger.error('Store domain and token are required. Pull cancelled.')
        exit(1)
      end

      ENV['SHOPIFY_FLAG_STORE']       = store_set
      ENV['SHOPIFY_CLI_THEME_TOKEN']  = token_set
      $logger.info('Shopify env vars set for this session.')
      $logger.info('')
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
