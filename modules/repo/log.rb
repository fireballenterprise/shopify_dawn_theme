module Repo
  module Log
    def self.run(title: nil, content: nil)
      repo_path = Dir.pwd
      logs_dir = File.join(repo_path, 'logs')
      FileUtils.mkdir_p(logs_dir)

      title = prompt_title if title.nil? || title.strip.empty?

      if title.nil? || title.strip.empty?
        $logger.error('Log title cannot be empty')
        exit(1)
      end

      now = Time.now
      log_stamp = now.strftime('%Y%m%d%H%M')
      slug = create_slug(title)
      filename = "#{log_stamp}_#{slug}.md"

      body = if content && !content.strip.empty?
               content.strip
             else
               default_body
             end

      file_content = "# #{title}\n\nDate: #{now.strftime('%Y-%m-%dT%H:%M:%S%z')}\n\n#{body}\n"

      log_file = File.join(logs_dir, filename)
      File.write(log_file, file_content)

      $logger.info("Saved log: logs/#{filename}")
    end

    def self.create_slug(text)
      slug = text.downcase.gsub(' ', '_')
      slug = slug.gsub(/[^a-z0-9_\-]/, '')
      slug = slug.gsub(/[_\-]+/, '_')
      result = slug.gsub(/\A[_\-]+|[_\-]+\z/, '')
      result.empty? ? 'log' : result
    end

    def self.prompt_title
      print 'Log title: '
      $stdin.gets&.chomp
    end

    def self.default_body
      <<~BODY.chomp
        ## Summary

        [Repo coding work only]

        ## Code Changes

        - [Files/modules updated]

        ## Validation

        - [Tests/lint run and results]

        ## Notes

        [Exclude unrelated chat/topic detours]
      BODY
    end
  end
end
