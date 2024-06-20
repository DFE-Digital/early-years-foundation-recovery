require 'rails_helper'

RSpec.describe 'Event log' do
  include_context 'with events'
  include_context 'with user'
  include_context 'with automated path'

  describe 'confidence check' do
    context 'when viewing the first question' do
      it 'tracks start' do
        expect(events.where(name: 'confidence_check_start').size).to eq 1
      end
    end

    context 'when all questions are answered' do
      it 'tracks answers and completion' do
        expect(events.where(name: 'questionnaire_answer').where_properties(type: 'confidence').size).to eq 4
        expect(events.where(name: 'confidence_check_complete').size).to eq 1
      end
    end
  end

  describe 'first module page' do
    it 'tracks start' do
      expect(events.where(name: 'module_start').size).to eq 1
    end
  end

  describe 'summative assessment' do
    context 'when viewing the first question' do
      it 'tracks start' do
        expect(events.where(name: 'summative_assessment_start').size).to eq 1
      end
    end

    context 'when all questions are answered correctly' do
      it 'tracks answers and successful attempt' do
        expect(events.where(name: 'questionnaire_answer').where_properties(success: true, type: 'summative').size).to eq 10
        expect(events.where(name: 'summative_assessment_complete').where_properties(score: 100, success: true).size).to eq 1
      end
    end

    context 'when all questions are answered incorrectly' do
      # let(:fixture) { 'spec/support/ast/alpha-fail-response.yml' }
      let(:happy) { false }

      it 'tracks answers and failed attempt' do
        expect(events.where(name: 'questionnaire_answer').where_properties(success: false, type: 'summative').size).to eq 10
        expect(events.where(name: 'summative_assessment_complete').where_properties(score: 0, success: false).size).to eq 1
      end
    end
  end

  describe 'formative question' do
    it 'tracks answers' do
      expect(events.where(name: 'questionnaire_answer').where_properties(success: true, type: 'formative').size).to eq 3
    end
  end

  describe 'visiting every page' do
    it 'tracks start and completion' do
      expect(events.where(name: 'module_start').size).to be 1
      expect(events.where(name: 'module_content_page').size).to be 34
      expect(events.where(name: 'module_complete').size).to eq 1
    end
  end
end
