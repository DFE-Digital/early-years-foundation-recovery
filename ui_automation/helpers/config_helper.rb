# frozen_string_literal: true

# module Helpers
module Helpers
  # Configuration helper utility
  class ConfigHelper
    # include Singleton

=begin
    def initialize
    end

    def config_file_path(file_name)
    end
=end

    def self.config_file_contents(file_name)
      config_yaml = File.join(File.expand_path(Dir.pwd, '..'), "/ui_automation/config_files/#{file_name}.yml")
      raise 'the config yaml file could not be found' unless File.exist?(config_yaml)

      YAML.load_file(File.open(config_yaml))[ENV['ENV']]
    end
  end
end
