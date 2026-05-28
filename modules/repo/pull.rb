module Repo
  module Pull
    def self.run
      require 'open3'
      require 'shellwords'

      repo_path = Shared::Properties.repo_local

      $logger.info('Checking working directory status...')
      stashed = stash_changes?(repo_path)

      $logger.info('')
      $logger.info('Pulling latest changes from git remote...')
      branch_out, _err, _s = Open3.capture3("git -C #{Shellwords.escape(repo_path)} rev-parse --abbrev-ref HEAD")
      branch = branch_out.strip
      pull_ok = system("git -C #{Shellwords.escape(repo_path)} pull --rebase origin #{Shellwords.escape(branch)}")

      unless pull_ok
        if stashed
          $logger.info('Restoring stash before exiting...')
          restore_stash(repo_path)
        end
        $logger.error('Git pull failed. Check network or merge conflicts.')
        exit(1)
      end

      $logger.info('Git pull completed')
      $logger.info('')

      if stashed
        $logger.info('Restoring stashed changes...')
        restore_stash(repo_path)
        $logger.info('')
      end

      show_status(repo_path)
    end

    def self.stash_changes?(repo_path)
      require 'open3'
      require 'shellwords'

      out, _err, _status = Open3.capture3("git -C #{Shellwords.escape(repo_path)} status --porcelain")
      return false if out.strip.empty?

      $logger.info('Uncommitted changes detected — stashing...')
      stash_ok = system(
        "git -C #{Shellwords.escape(repo_path)} stash push --all -m 'auto-stash before pull'"
      )

      unless stash_ok
        $logger.error('Failed to stash changes.')
        exit(1)
      end

      $logger.info('Changes stashed')
      true
    end

    def self.restore_stash(repo_path)
      require 'shellwords'

      success = system("git -C #{Shellwords.escape(repo_path)} stash pop")
      if success
        $logger.info('Stashed changes restored')
      else
        $logger.error('Stash pop failed — your changes are still in the stash. Run: git stash pop')
      end
    end

    def self.show_status(repo_path)
      require 'open3'
      require 'shellwords'

      $logger.info('Checking for changes from pull...')
      out, _err, _status = Open3.capture3("git -C #{Shellwords.escape(repo_path)} status --short")

      if out.strip.empty?
        $logger.info('No new changes from pull')
      else
        $logger.info('')
        $logger.info('Changes detected from pull:')
        $logger.info(out)
        $logger.info('Review changes above. Commit when ready.')
      end
    end
  end
end
