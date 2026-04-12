require 'ostruct'
# Use only plain Ruby objects or doubles in individual specs. No global mocks or monkey-patching here.

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
