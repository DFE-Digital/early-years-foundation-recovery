require 'rails_helper'

RSpec.describe 'Event log' do
  include_context 'with events'
  include_context 'with progress'
  include_context 'with user'

  let(:module_name) { alpha.name }

  describe 'confidence check' do
    before do
      start_confidence_check(alpha)
      visit '/modules/alpha/content-pages/1-3-3'
      click_on 'Next'
    end

    context 'when viewing the first question' do
      it 'tracks start' do
        expect(events.where(name: 'confidence_check_start').size).to eq 1
      end
    end

    context 'when all questions are answered' do
      before do
        visit '/modules/alpha/content-pages/what-to-expect'

        # OPTIMIZE: the setup for this context leverages the AST schema which supports future changes to content
        ContentTestSchema.new(mod: alpha).call(pass: true).each do |content|
          content[:inputs].each { |args| send(*args) }
        end
      end

      it 'tracks answers and completion' do
        # TODO: type will change to 'confidence' when CMS 'page_type' is updated
        expect(events.where(name: 'questionnaire_answer').where_properties(type: 'confidence_check').size).to eq 4
        expect(events.where(name: 'confidence_check_complete').size).to eq 1
      end
    end
  end

  describe 'first module page' do
    before do
      visit '/modules/alpha/content-pages/what-to-expect'
      click_on 'Next'
    end

    it 'tracks start' do
      expect(events.where(name: 'module_start').size).to eq 1
    end
  end

  describe 'summative assessment' do
    before do
      start_summative_assessment(alpha)
      visit '/modules/alpha/content-pages/1-3-2'
      click_on 'Start test'
    end

    context 'when viewing the first question' do
      it 'tracks start' do
        expect(events.where(name: 'summative_assessment_start').size).to eq 1
      end
    end

    context 'when all questions are answered correctly' do
      before do
        visit '/modules/alpha/content-pages/what-to-expect'

        # OPTIMIZE: the setup for this context leverages the AST schema which supports future changes to content
        ContentTestSchema.new(mod: alpha).call(pass: true).each do |content|
          content[:inputs].each { |args| send(*args) }
        end
      end

      it 'tracks answers and successful attempt' do
        expect(events.where(name: 'questionnaire_answer').where_properties(success: true, type: 'summative_assessment').size).to eq 10
        expect(events.where(name: 'summative_assessment_complete').where_properties(score: 100, success: true).size).to eq 1
      end
    end

    context 'when all questions are answered incorrectly' do
      before do
        visit '/modules/alpha/content-pages/what-to-expect'

        # OPTIMIZE: the setup for this context leverages the AST schema which supports future changes to content
        ContentTestSchema.new(mod: alpha).call(pass: false).compact.each do |content|
          content[:inputs].each { |args| send(*args) }
        end
      end

      it 'tracks answers and failed attempt' do
        # TODO: type will change to 'summative' when CMS 'page_type' is updated
        expect(events.where(name: 'questionnaire_answer').where_properties(success: false, type: 'summative_assessment').size).to eq 10
        expect(events.where(name: 'summative_assessment_complete').where_properties(score: 0, success: false).size).to eq 1
      end
    end
  end

  describe 'formative question' do
    before do
      visit '/modules/alpha/content-pages/what-to-expect'

      # OPTIMIZE: the setup for this context leverages the AST schema which supports future changes to content
      ContentTestSchema.new(mod: alpha).call(pass: true).each do |content|
        content[:inputs].each { |args| send(*args) }
      end
    end

    it 'tracks answers' do
      # TODO: type will change to 'formative' when CMS 'page_type' is updated
      expect(events.where(name: 'questionnaire_answer').where_properties(success: true, type: 'formative_assessment').size).to eq 3
    end
  end

  describe 'visiting every page' do
    before do
      alpha.content.each { |item| visit "/modules/alpha/content-pages/#{item.name}" }
    end

    it 'tracks start and completion' do
      expect(events.where(name: 'module_start').size).to be 1
      expect(events.where(name: 'module_content_page').size).to be 38
      expect(events.where(name: 'module_complete').size).to eq 1
    end
  end
end
