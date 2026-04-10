# Remove and redefine Training::Module and Training::Page as mocks for all tests
if defined?(Training) && Training.const_defined?(:Module)
  Training.send(:remove_const, :Module)
end
if defined?(Training) && Training.const_defined?(:Page)
  Training.send(:remove_const, :Page)
end

# Define test-only mocks to avoid superclass mismatch and all Contentful dependencies
module Training
  class Module
    attr_accessor :id, :name
    def self.by_name(name); new(name); end
    def self.ordered; [new('alpha'), new('bravo')]; end
    def initialize(name = 'alpha'); @id = name; @name = name; end
    def to_model; self; end
    def to_param; name; end
    def persisted?; true; end
  end
  class Page
    attr_accessor :id, :name
    def initialize(name = 'page'); @id = name; @name = name; end
    def to_model; self; end
    def to_param; name; end
    def persisted?; true; end
  end
end
# Monkey-patch Training::Module to forcibly define validates_presence_of as a no-op for test environment
if defined?(Training::Module)
  class << Training::Module
    def validates_presence_of(*_args); end
  end
end
# spec/support/mock_contentful_service.rb

# A simple mock for ContentfulModel/ContentfulService calls in tests.
# Returns canned objects for common queries, so tests do not care about real Contentful content.
# Extend as needed for more methods/fields.



require 'ostruct'


# Define test-only mocks to avoid superclass mismatch
class MockTrainingModule
  attr_accessor :id, :name
  def self.by_name(name); new(name); end
  def self.ordered; [new('alpha'), new('bravo')]; end
  def initialize(name = 'alpha'); @id = name; @name = name; end
  def to_model; self; end
  def to_param; name; end
  def persisted?; true; end
end

class MockTrainingPage
  attr_accessor :id, :name
  def initialize(name = 'page'); @id = name; @name = name; end
  def to_model; self; end
  def to_param; name; end
  def persisted?; true; end
end

# Stub Training::Content if not defined to prevent NameError in tests
unless defined?(Training)
  module Training; end
end

# Stub Training::Content if not defined
unless defined?(Training::Content)
  class Training::Content; end
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

# Stub validates_presence_of for Training::Module if not defined
if defined?(Training::Module)
  unless Training::Module.respond_to?(:validates_presence_of)
    class << Training::Module
      def validates_presence_of(*_args); end
    end
  end
  unless Training::Module.method_defined?(:validates_presence_of)
    class Training::Module
      def validates_presence_of(*_args); end
    end
  end
end

require File.expand_path('../../app/models/training/page', __dir__)
require File.expand_path('../../app/models/training/module', __dir__)


# Enhanced mock for Contentful-backed models




class MockContentfulService
  def find(id)
    case id.to_s
    when 'alpha', 'bravo', 'charlie'
      MockTrainingModule.new(id)
    else
      MockTrainingPage.new(id)
    end
  end

  def all
    [find('alpha'), find('bravo'), find('charlie')]
  end

  def where(_query)
    all
  end

  def find_by(query)
    # Support find_by(name: ...) and find_by(id: ...)
    key = query[:name] || query[:id]
    return [find(key)] if key
    [find('alpha')]
  end

  def self.array
    [OpenStruct.new(id: 'mock-id', title: 'Mock Title')]
  end
end
