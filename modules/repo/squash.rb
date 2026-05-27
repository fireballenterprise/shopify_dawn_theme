module Repo
  module Squash
    def self.run
      require 'open3'
      require 'shellwords'

      repo_path = Shared::Properties.repo_local

      $logger.info('Finding root commit...')
      root_sha = find_root_commit(repo_path)
      root_msg = commit_subject(repo_path, root_sha)
      $logger.info("Root commit: #{root_sha[0..6]} — #{root_msg}")
      $logger.info('')

      $logger.info('Collecting commits to squash...')
      commits = commits_after_root(repo_path, root_sha)

      if commits.empty?
        $logger.info('Nothing to squash — only one commit exists.')
        return
      end

      $logger.info("Found #{commits.length} commit(s) after root")
      $logger.info('')

      message = build_message(commits)

      $logger.info('Squash commit message:')
      $logger.info('──────────────────────────────────')
      message.each_line { |line| $logger.info(line.chomp) }
      $logger.info('──────────────────────────────────')
      $logger.info('')

      unless confirm?('Proceed with this commit message?')
        $logger.info('Squash cancelled.')
        return
      end

      $logger.info('')

      unless confirm?('Squash all commits locally? This rewrites history and cannot be undone.')
        $logger.info('Squash cancelled.')
        return
      end

      $logger.info('')
      execute_squash(repo_path, root_sha, message)
      $logger.info('')

      if confirm?('Force push to remote?')
        $logger.info('')
        force_push(repo_path)
      else
        $logger.info('Skipping force push. Run manually when ready: git push --force-with-lease')
      end
    end

    def self.find_root_commit(repo_path)
      require 'open3'
      require 'shellwords'

      out, _err, status = Open3.capture3(
        "git -C #{Shellwords.escape(repo_path)} rev-list --max-parents=0 HEAD"
      )

      unless status.success?
        $logger.error('Failed to find root commit.')
        exit(1)
      end

      out.lines.first&.strip
    end

    def self.commit_subject(repo_path, sha)
      require 'open3'
      require 'shellwords'

      out, _err, _status = Open3.capture3(
        "git -C #{Shellwords.escape(repo_path)} log -1 --format=%s #{sha}"
      )
      out.strip
    end

    def self.commits_after_root(repo_path, root_sha)
      require 'open3'
      require 'shellwords'

      out, _err, _status = Open3.capture3(
        "git -C #{Shellwords.escape(repo_path)} log --format=%s --reverse HEAD ^#{root_sha}"
      )
      out.lines.map(&:strip).reject(&:empty?)
    end

    def self.build_message(commits)
      bullets = commits.map { |msg| "- #{msg}" }.join("\n")
      "SQUASHED:\n\n#{bullets}"
    end

    def self.execute_squash(repo_path, root_sha, message)
      $logger.info('Resetting to root commit (staging all subsequent changes)...')
      unless system('git', '-C', repo_path, 'reset', '--soft', root_sha)
        $logger.error('git reset --soft failed.')
        exit(1)
      end

      $logger.info('Creating squashed commit...')
      unless system('git', '-C', repo_path, 'commit', '--amend', '-m', message)
        $logger.error('git commit --amend failed.')
        exit(1)
      end

      $logger.info('Squash complete!')
    end

    def self.force_push(repo_path)
      $logger.info('Force pushing to remote...')
      unless system('git', '-C', repo_path, 'push', '--force-with-lease')
        $logger.error('Force push failed. Try manually: git push --force-with-lease')
        exit(1)
      end

      $logger.info('Force push complete!')
    end

    def self.confirm?(question)
      return true unless $stdin.tty?

      print "#{question} [Y/n]: "
      answer = $stdin.gets&.chomp || ''
      answer.downcase != 'n'
    end
  end
end
