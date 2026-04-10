# spec/support/mock_contentful_service.rb

# A simple mock for ContentfulModel/ContentfulService calls in tests.
# Returns canned objects for common queries, so tests do not care about real Contentful content.
# Extend as needed for more methods/fields.


require 'ostruct'
# Ensure Training and Training::Page are loaded before defining mocks
require File.expand_path('../../app/models/training/page', __dir__)
require File.expand_path('../../app/models/training/module', __dir__)


# Enhanced mock for Contentful-backed models


# Real Ruby classes for mocks to satisfy type constraints
MockTrainingPageBase = Object.const_defined?("Training") && Training.const_defined?("Page") ? Training::Page : Object
class MockTrainingPage < MockTrainingPageBase
  attr_reader :id, :name, :page_type, :schema, :parent, :description, :correct_answers, :debug_summary

  def initialize(name, parent: nil)
    @id = name
    @name = name
    @parent = parent
    @page_type = name == 'feedback-intro' ? 'feedback' : 'text_page'
    @schema = [name, 'text_page', 'text_page', {}]
    @description = nil
    @correct_answers = [1]
    @debug_summary = nil
  end

  def title
    # For sitemap, match test expectation
    return 'Mock Title' if name == 'sitemap'
    "Mock Title #{name}"
  end

  def interruption_page?; name == 'interruption'; end
  def summary_intro_page?; name == 'summary-intro'; end
  def certificate?; name == 'certificate'; end
  def formative_question?; false; end
  def summative_question?; name == 'summative1'; end
  def skippable?; false; end
  def next_item; nil; end
  def text; 'Mock text'; end
  def to_model; self; end
  def to_param; name; end
  def persisted?; true; end

  # Decorator/section helpers
  def section?; false; end
  def subsection?; false; end
  def feedback_question?; name.include?('feedback'); end
  def pre_confidence_question?; name.include?('pre-confidence'); end
  def pre_confidence_intro?; name == 'pre-confidence-intro'; end
end

MockTrainingModuleBase = Object.const_defined?("Training") && Training.const_defined?("Module") ? Training::Module : Object
class MockTrainingModule < MockTrainingModuleBase
  attr_reader :id, :name, :pages, :content, :content_sections, :summary_intro_page, :certificate_page, :interruption_page, :summative_questions

  def initialize(name)
    @id = name
    @name = name
    # For module, match test expectation
    @pages = [
      '1-1-1-1', 'feedback-intro', 'certificate', 'feedback-textarea-only',
      'summary-intro', 'interruption', 'summative1',
      '1-1-3-1', '1-1', 'what-to-expect', '1-1-1',
      'sitemap', 'footer1', 'footer2', 'footer3', 'footer4', 'test.resource'
    ].map { |n| MockTrainingPage.new(n, parent: self) }
    @content = @pages
    @content_sections = []
    @summary_intro_page = page_by_name('summary-intro') || MockTrainingPage.new('summary-intro', parent: self)
    @certificate_page = page_by_name('certificate') || MockTrainingPage.new('certificate', parent: self)
    @interruption_page = page_by_name('interruption') || MockTrainingPage.new('interruption', parent: self)
    @summative_questions = [page_by_name('summative1') || MockTrainingPage.new('summative1', parent: self)]
  end

  def title
    "Mock Module #{@name}"
  end

  def answers_with(_str); []; end
  def page_by_name(n); @pages.find { |p| p.name == n } || MockTrainingPage.new(n, parent: self); end
  def pages_by_type(t); @pages.select { |p| p.page_type == t }; end
  def to_model; self; end
  def to_param; name; end
  def persisted?; true; end
end

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
