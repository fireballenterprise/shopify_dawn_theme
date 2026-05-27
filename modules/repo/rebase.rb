module Repo
  module Rebase
    def self.run
      require 'open3'
      require 'shellwords'

      repo_path = Shared::Properties.repo_local

      if squash_first?
        $logger.info('')
        Repo::Squash.run
        return
      end

      $logger.info('')
      stashed = stash_changes?(repo_path)

      $logger.info('')
      $logger.info('Fetching remote changes...')
      system("git -C #{Shellwords.escape(repo_path)} fetch --prune")

      $logger.info('')
      base = detect_base_branch(repo_path)
      $logger.info("Rebasing onto #{base}...")

      unless system("git -C #{Shellwords.escape(repo_path)} rebase #{base}")
        if stashed
          $logger.info('Restoring stash before exiting...')
          system("git -C #{Shellwords.escape(repo_path)} stash pop")
        end
        $logger.error('Rebase failed. Resolve conflicts then run: git rebase --continue')
        exit(1)
      end

      $logger.info('Rebase complete!')
      $logger.info('')

      return unless stashed

      $logger.info('Restoring stashed changes...')
      pop_ok = system("git -C #{Shellwords.escape(repo_path)} stash pop")
      if pop_ok
        $logger.info('Stash restored — no conflicts')
      else
        $logger.info('Stash pop has conflicts — starting resolution...')
        $logger.info('')
        resolve_conflicts(repo_path)
      end
    end

    def self.stash_changes?(repo_path)
      require 'open3'
      require 'shellwords'

      out, _err, _status = Open3.capture3("git -C #{Shellwords.escape(repo_path)} status --porcelain")
      return false if out.strip.empty?

      $logger.info('Uncommitted changes detected — stashing...')
      stash_ok = system(
        "git -C #{Shellwords.escape(repo_path)} stash push --all -m 'auto-stash before rebase'"
      )

      unless stash_ok
        $logger.error('Failed to stash changes.')
        exit(1)
      end

      $logger.info('Changes stashed')
      true
    end

    def self.resolve_conflicts(repo_path)
      require 'open3'
      require 'shellwords'

      conflicted = conflicted_files(repo_path)

      if conflicted.empty?
        $logger.info('No conflict markers detected')
        system("git -C #{Shellwords.escape(repo_path)} stash drop")
        return
      end

      $logger.info("Conflicted files (#{conflicted.size}):")
      conflicted.each { |f| $logger.info("  #{f}") }
      $logger.info('')

      conflicted.each { |file| resolve_file(repo_path, file) }

      system("git -C #{Shellwords.escape(repo_path)} stash drop")
      $logger.info('')
      $logger.info('Conflict resolution complete')
    end

    def self.conflicted_files(repo_path)
      require 'open3'
      require 'shellwords'

      out, _err, _status = Open3.capture3("git -C #{Shellwords.escape(repo_path)} status --porcelain")
      conflict_codes = %w[UU AA AU UA DD DU UD]
      out.lines.filter_map do |line|
        xy = line[0, 2]
        line[3..].strip if conflict_codes.include?(xy)
      end
    end

    def self.resolve_file(repo_path, file)
      return unless $stdin.tty?

      $logger.info("Conflict: #{file}")
      print '  Resolve with [o]urs (local), [t]heirs (remote), or [s]kip (resolve manually)? [o/t/s]: '
      answer = $stdin.gets&.chomp&.downcase || 's'

      case answer
      when 'o'
        system("git -C #{Shellwords.escape(repo_path)} checkout --ours -- #{Shellwords.escape(file)}")
        system("git -C #{Shellwords.escape(repo_path)} add -- #{Shellwords.escape(file)}")
        $logger.info("  #{file} resolved with ours (local)")
      when 't'
        system("git -C #{Shellwords.escape(repo_path)} checkout --theirs -- #{Shellwords.escape(file)}")
        system("git -C #{Shellwords.escape(repo_path)} add -- #{Shellwords.escape(file)}")
        $logger.info("  #{file} resolved with theirs (remote)")
      else
        $logger.info("  #{file} skipped — resolve manually, then: git add #{file} && git stash drop")
      end
    end

    def self.squash_first?
      return false unless $stdin.tty?

      print 'Run squash before rebasing? [y/N]: '
      answer = $stdin.gets&.chomp || ''
      answer.downcase == 'y'
    end

    def self.detect_base_branch(repo_path)
      require 'open3'
      require 'shellwords'

      out, _err, _status = Open3.capture3(
        "git -C #{Shellwords.escape(repo_path)} branch -r"
      )
      branches = out.lines.map(&:strip)
      return 'origin/main' if branches.any? { |b| b == 'origin/main' }
      return 'origin/master' if branches.any? { |b| b == 'origin/master' }

      'origin/HEAD'
    end
  end
end
