# frozen_string_literal: true

# module Helpers
module Helpers
  # Configuration helper utility
  class ConfigHelper
    include Singleton

    class << self
      attr_accessor :project_root
    end

    def self.env_config
      full_parent_dir_path = File.expand_path(Dir.pwd, '..')
      config_yaml = File.join(full_parent_dir_path, '/ui_automation/config_files/environment.yml')
      raise 'the config yaml file could not be found' unless File.exist?(config_yaml)

      YAML.load_file(File.open(config_yaml))[ENV['ENV']]
    end
  end
end
