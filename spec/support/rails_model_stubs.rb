# Stub Trainee and Trainee::Setting for test environment
unless defined?(Trainee)
  module Trainee
    class Setting; end
  end
end
# frozen_string_literal: true

# This file is loaded before any models to stub Rails/ActiveModel/ActiveRecord methods
# that are referenced in models but not needed for unit tests with mocks.

unless defined?(ActiveModel)
  module ActiveModel; end
end
unless defined?(ActiveRecord)
  module ActiveRecord; end
end

# Stub ContentfulModel and ContentfulModel::Base for test environment
unless defined?(ContentfulModel)
  module ContentfulModel
    class Base
      # Add minimal stub methods if needed
    end
  end
end
unless defined?(ActiveJob)
  module ActiveJob; end
end
unless defined?(ActiveJob::Serializers)
  module ActiveJob::Serializers; end
end
unless defined?(ActiveJob::Serializers::ObjectSerializer)
  class ActiveJob::Serializers::ObjectSerializer
    def serialize(obj); obj; end
    def deserialize(hash); hash; end
  end
end


# Stub validates_presence_of only for Training::Module if needed (handled in mock_contentful_service.rb)

# Prevent accidental modification of Rails autoload/eager_load paths if frozen
if defined?(Rails) && Rails.respond_to?(:application) && Rails.application
  %i[autoload_paths eager_load_paths].each do |path|
    paths = Rails.application.config.send(path) rescue nil
    if paths && paths.frozen?
      # Do not attempt to modify if frozen
      # Optionally, log or warn here if needed
    end
  end
end
