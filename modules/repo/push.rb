module Repo
  module Push
    def self.run(confirm: true)
      require 'open3'
      require 'shellwords'

      repo_path = Shared::Properties.repo_local
      timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')

      run_tests
      $logger.info('')

      if confirm && $stdin.tty?
        print 'Tests passed! Push to GitHub? [Y/n]: '
        answer = $stdin.gets.chomp
        if answer.downcase == 'n'
          $logger.info('Push cancelled.')
          return
        end
      end

      push_git(repo_path, timestamp)
    end

    def self.run_tests
      $logger.info('Running automated code fixes...')
      system('bundle exec rake fix')
      $logger.info('')

      $logger.info('Running tests...')
      test_ok = system('bundle exec rake test')
      return if test_ok

      $logger.error('Tests failed! Fix all offenses before pushing.')
      $logger.info('Push stopped. Address the issues above and run /push again.')
      exit(1)
    end

    def self.push_git(repo_path, timestamp)
      require 'open3'
      require 'shellwords'

      $logger.info('Checking working directory status...')
      out, _err, _status = Open3.capture3("git -C #{Shellwords.escape(repo_path)} status --porcelain")

      stashed = false

      unless out.strip.empty?
        $logger.info('Stashing local changes before pull...')
        stash_ok = system(
          "git -C #{Shellwords.escape(repo_path)} stash push -u -m 'auto-stash before push'"
        )
        unless stash_ok
          $logger.error('Failed to stash changes.')
          exit(1)
        end
        $logger.info('Changes stashed')
        stashed = true
      end

      $logger.info('')
      $logger.info('Pulling latest changes from remote...')
      branch_out, _err, _s = Open3.capture3("git -C #{Shellwords.escape(repo_path)} rev-parse --abbrev-ref HEAD")
      branch = branch_out.strip
      pull_ok = system("git -C #{Shellwords.escape(repo_path)} pull --rebase origin #{Shellwords.escape(branch)}")

      unless pull_ok
        if stashed
          $logger.info('Restoring stash before exiting...')
          system("git -C #{Shellwords.escape(repo_path)} stash pop")
        end
        $logger.error('Git pull failed. Stopping.')
        exit(1)
      end

      $logger.info('Pull completed')

      if stashed
        $logger.info('')
        $logger.info('Restoring stashed changes...')
        system("git -C #{Shellwords.escape(repo_path)} stash pop")
        $logger.info('Stash restored')
      end

      $logger.info('')
      out, _err, _status = Open3.capture3("git -C #{Shellwords.escape(repo_path)} status --porcelain")

      if out.strip.empty?
        $logger.info('No local changes to commit')
        return
      end

      $logger.info('Found local changes. Committing...')
      system("git -C #{Shellwords.escape(repo_path)} add .")
      commit_msg = "Push repository: Automated commit #{timestamp}"
      system("git -C #{Shellwords.escape(repo_path)} commit -m #{Shellwords.escape(commit_msg)}")

      $logger.info('Pushing to remote...')
      push_ok = system("git -C #{Shellwords.escape(repo_path)} push")
      if push_ok
        $logger.info('Push completed')
      else
        $logger.error('Git push failed.')
      end
    end
  end
end
