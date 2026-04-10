# frozen_string_literal: true

# This file is loaded before any models to stub Rails/ActiveModel/ActiveRecord methods
# that are referenced in models but not needed for unit tests with mocks.

unless defined?(ActiveModel)
  module ActiveModel; end
end
unless defined?(ActiveRecord)
  module ActiveRecord; end
end
unless defined?(ContentfulModel)
  module ContentfulModel; end
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

# Stub validates_presence_of for any class (esp. Training::Module)
class << Object
  def validates_presence_of(*_args); end
end
