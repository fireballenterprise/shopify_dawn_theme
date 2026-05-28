module Shopify
  module Upgrade
    VANILLA_BRANCH    = 'dawn_vanilla'.freeze
    DEV_BRANCH        = 'development'.freeze
    UPSTREAM_REMOTE   = 'upstream'.freeze
    UPSTREAM_BRANCH   = 'main'.freeze

    def self.run
      repo_path = Shared::Properties.repo_local

      confirm_prerequisites(repo_path)

      original_branch = current_branch(repo_path)
      stashed = stash_changes?(repo_path, original_branch)

      upgrade_dawn_vanilla(repo_path)
      merge_into_development(repo_path, stashed, original_branch)

      $logger.info('')
      $logger.info('Upgrade complete!')
      $logger.info("dawn_vanilla and development are now at #{latest_local_version(repo_path)}.")
      $logger.info('Run /push or repo:push to push development to origin.')
    end

    # ── Version check + user confirmation ───────────────────────────────────

    def self.confirm_prerequisites(repo_path)
      require 'shellwords'

      $logger.info('Fetching upstream Shopify/dawn...')
      fetch_ok = Shared::Shell.run_command_no_output(
        "git -C #{Shellwords.escape(repo_path)} fetch #{UPSTREAM_REMOTE} --tags --quiet"
      )
      unless fetch_ok
        $logger.error("Failed to fetch from #{UPSTREAM_REMOTE}. Check network and remote config.")
        $logger.info('Run: git remote -v   to verify upstream remote exists.')
        exit(1)
      end
      $logger.info('Fetch complete.')
      $logger.info('')

      current = current_dawn_version(repo_path)
      latest  = latest_upstream_version(repo_path)

      if current.nil? || latest.nil?
        $logger.warn('Could not detect Dawn version tags.')
        $logger.warn("current=#{current.inspect}  latest=#{latest.inspect}")
      elsif current == latest
        $logger.info("dawn_vanilla is already at #{current} (latest upstream).")
        return unless $stdin.tty?

        print 'No upgrade available. Proceed anyway to re-merge into development? [y/N]: '
        answer = $stdin.gets.chomp
        unless answer.downcase == 'y'
          $logger.info('Upgrade skipped.')
          exit(0)
        end
      else
        $logger.info("dawn_vanilla is at : #{current}")
        $logger.info("Upstream latest is : #{latest}")
        $logger.info('')
        return unless $stdin.tty?

        print "Upgrade dawn_vanilla #{current} → #{latest} and merge into development? [Y/n]: "
        answer = $stdin.gets.chomp
        if answer.downcase == 'n'
          $logger.info('Upgrade cancelled.')
          exit(0)
        end
      end

      $logger.info('')
    end

    # ── Version helpers ──────────────────────────────────────────────────────

    def self.current_dawn_version(repo_path)
      require 'shellwords'

      out = Shared::Shell.run_command_strout(
        "git -C #{Shellwords.escape(repo_path)} describe --tags --abbrev=0 #{VANILLA_BRANCH}"
      ).strip
      out.empty? ? nil : out
    end

    def self.latest_upstream_version(repo_path)
      require 'shellwords'

      # Tags reachable from upstream/main, sorted newest-first by semver
      out = Shared::Shell.run_command_strout(
        "git -C #{Shellwords.escape(repo_path)} tag --merged #{UPSTREAM_REMOTE}/#{UPSTREAM_BRANCH} " \
        '--sort=-version:refname'
      )
      out.lines.map(&:strip).reject(&:empty?).first
    end

    def self.latest_local_version(repo_path)
      require 'shellwords'

      Shared::Shell.run_command_strout(
        "git -C #{Shellwords.escape(repo_path)} describe --tags --abbrev=0 #{VANILLA_BRANCH}"
      ).strip
    end

    # ── Stash helpers ────────────────────────────────────────────────────────

    def self.stash_changes?(repo_path, branch)
      require 'shellwords'

      out = Shared::Shell.run_command_strout("git -C #{Shellwords.escape(repo_path)} status --porcelain")
      return false if out.strip.empty?

      $logger.info("Uncommitted changes on '#{branch}' detected — stashing...")
      stash_ok = Shared::Shell.run_command_no_output(
        "git -C #{Shellwords.escape(repo_path)} stash push --all -m 'auto-stash before shopify upgrade'"
      )
      unless stash_ok
        $logger.error('Failed to stash changes. Commit or stash manually before upgrading.')
        exit(1)
      end
      $logger.info('Changes stashed.')
      $logger.info('')
      true
    end

    def self.restore_stash(repo_path)
      require 'shellwords'

      $logger.info('Restoring stashed changes...')
      success = Shared::Shell.run_command_no_output("git -C #{Shellwords.escape(repo_path)} stash pop")
      if success
        $logger.info('Stash restored.')
      else
        $logger.warn('Stash pop had conflicts. Run: git stash pop   to restore manually.')
      end
    end

    # ── Branch helpers ───────────────────────────────────────────────────────

    def self.current_branch(repo_path)
      require 'shellwords'

      Shared::Shell.run_command_strout(
        "git -C #{Shellwords.escape(repo_path)} rev-parse --abbrev-ref HEAD"
      ).strip
    end

    def self.checkout(repo_path, branch)
      require 'shellwords'

      $logger.info("Switching to #{branch}...")
      ok = Shared::Shell.run_command_no_output(
        "git -C #{Shellwords.escape(repo_path)} checkout #{Shellwords.escape(branch)}"
      )
      return if ok

      $logger.error("Failed to checkout #{branch}.")
      exit(1)
    end

    # ── Core upgrade steps ───────────────────────────────────────────────────

    def self.upgrade_dawn_vanilla(repo_path)
      require 'shellwords'

      checkout(repo_path, VANILLA_BRANCH)

      $logger.info("Merging #{UPSTREAM_REMOTE}/#{UPSTREAM_BRANCH} into #{VANILLA_BRANCH}...")
      merge_ok = Shared::Shell.run_command_no_output(
        "git -C #{Shellwords.escape(repo_path)} merge #{UPSTREAM_REMOTE}/#{UPSTREAM_BRANCH} --no-edit"
      )
      unless merge_ok
        $logger.error("Merge of upstream/#{UPSTREAM_BRANCH} into #{VANILLA_BRANCH} failed.")
        $logger.error("#{VANILLA_BRANCH} should track upstream cleanly — check for unexpected commits.")
        $logger.info("Resolve conflicts, then: git merge --continue && git push origin #{VANILLA_BRANCH}")
        exit(1)
      end

      $logger.info("Pushing #{VANILLA_BRANCH} to origin...")
      push_ok = Shared::Shell.run_command_no_output(
        "git -C #{Shellwords.escape(repo_path)} push origin #{Shellwords.escape(VANILLA_BRANCH)}"
      )
      unless push_ok
        $logger.error("Failed to push #{VANILLA_BRANCH} to origin.")
        exit(1)
      end
      $logger.info("#{VANILLA_BRANCH} updated and pushed.")
      $logger.info('')
    end

    def self.merge_into_development(repo_path, stashed, original_branch)
      require 'shellwords'

      checkout(repo_path, DEV_BRANCH)

      $logger.info("Merging #{VANILLA_BRANCH} into #{DEV_BRANCH}...")
      merge_ok = Shared::Shell.run_command_no_output(
        "git -C #{Shellwords.escape(repo_path)} merge #{Shellwords.escape(VANILLA_BRANCH)} --no-edit"
      )

      unless merge_ok
        restore_stash(repo_path) if stashed
        show_conflicts(repo_path)
        $logger.info('')
        $logger.info('Next steps after resolving conflicts:')
        $logger.info('  git add .  &&  git merge --continue')
        $logger.info('  Then run /push or bundle exec rake repo:push')
        exit(1)
      end

      $logger.info("#{DEV_BRANCH} updated with #{VANILLA_BRANCH} changes.")

      # Restore stash if we had changes on development
      restore_stash(repo_path) if stashed && original_branch == DEV_BRANCH
    end

    def self.show_conflicts(repo_path)
      require 'shellwords'

      out = Shared::Shell.run_command_strout(
        "git -C #{Shellwords.escape(repo_path)} diff --name-only --diff-filter=U"
      )
      conflicted = out.lines.map(&:strip).reject(&:empty?)

      $logger.error("Merge conflicts in #{DEV_BRANCH}. Resolve the following files:")
      conflicted.each { |f| $logger.error("  #{f}") }
    end
  end
end
