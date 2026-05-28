module Shared
  module Properties
    @cache = nil

    def self.get
      return @cache if @cache

      props_file = find_properties_file
      raise 'properties.yml not found — run from repository root or any subdirectory' unless props_file

      require 'yaml'
      @cache = YAML.safe_load_file(props_file) || {}
    end

    def self.repo_local
      get.dig('repo', 'local') || Dir.pwd
    end

    def self.repo_remote
      get.dig('repo', 'remote')
    end

    def self.shopify_store
      get.dig('shopify', 'store') || 'fireballenterprise.myshopify.com'
    end

    def self.find_properties_file
      require 'pathname'
      # Search upward from current working directory
      current = Pathname.new(Dir.pwd).expand_path
      ([current] + current.ascend.to_a).each do |dir|
        candidate = dir.join('properties.yml')
        return candidate.to_s if candidate.exist?
      end
      nil
    end
  end
end
