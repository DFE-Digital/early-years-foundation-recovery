# Needed for OpenStruct stub
require 'ostruct'
# Only stub ContentfulModel and ContentfulRails for test
if Rails.env.test?
  # Stub ContentfulModel::Base for test environment to prevent NameError in tests
  module ContentfulModel
    class << self
      attr_accessor :use_preview_api
    end
    class Base
      def self.validates_presence_of(*_args); end
      # Add other minimal stub methods if needed
    end
  end

  # Stub ContentfulRails with a .configure method
  module ContentfulRails
    def self.configure
      yield OpenStruct.new if block_given?
    end
  end

  # Workaround: forcibly dup and reassign autoload/eager_load paths if frozen (test env only)
  if defined?(Rails) && Rails.application
    %i[autoload_paths eager_load_paths].each do |path|
      paths = Rails.application.config.send(path) rescue nil
      if paths && paths.frozen?
        Rails.application.config.public_send("#{path}=", paths.dup)
      end
    end
  end
end
