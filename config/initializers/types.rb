unless defined?(::Types)
  require 'dry-types'

  module Types
    include Dry.Types()
    include Dry::Core::Constants
  end
end
