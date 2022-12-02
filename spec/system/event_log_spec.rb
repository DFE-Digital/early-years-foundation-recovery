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

    context 'when answering the first question' do
      before do
        choose 'Strongly agree'
        click_on 'Next'
      end

      it 'tracks question answer' do
        expect(events.where(name: 'questionnaire_answer').where_properties(success: true, type: 'confidence_check').size).to eq 1
      end
    end

    context 'when answering the final question' do
      before do
        3.times do
          choose 'Strongly agree'
          click_on 'Next'
        end
      end

      it 'tracks completion' do
        expect(events.where(name: 'confidence_check_complete').size).to eq 1
      end
    end
  end

  describe 'first module page' do
    before do
      visit '/modules/alpha/content-pages/before-you-start'
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

    context 'when answering first question' do
      before do
        check 'Correct answer 1'
        check 'Correct answer 2'
        click_on 'Save and continue'
      end

      it 'tracks question answered' do
        expect(events.where(name: 'questionnaire_answer').where_properties(type: 'summative_assessment').size).to eq 1
      end
    end

    context 'when answering final question correctly' do
      before do
        complete_summative_assessment_correct
      end

      it 'tracks successful attempt' do
        expect(events.where(name: 'summative_assessment_complete').where_properties(score: 100, success: true).size).to eq 1
      end
    end

    context 'when answering final question incorrectly' do
      before do
        complete_summative_assessment_incorrect
      end

      it 'tracks failed attempt' do
        expect(events.where(name: 'summative_assessment_complete').where_properties(score: 0, success: false).size).to eq 1
      end
    end
  end

  describe 'formative assessment' do
    before do
      view_pages_before_formative_questionnaire(alpha)
      visit '/modules/alpha'
      click_on 'Resume training'
      complete_formative_assessment_correct
    end

    it 'tracks completion' do
      expect(events.where(name: 'questionnaire_answer').where_properties(success: true, type: 'formative_assessment').size).to eq 2
    end
  end

  describe 'complete first module' do
    before do
      visit '/modules/alpha/content-pages/intro'  # record dependent event of 'module_start'
      view_pages_before(alpha, 'certificate')     # visit all but last page
      visit 'modules/alpha/content-pages/1-3-4'   # visit last page (certificate)
    end

    it 'tracks completion' do
      expect(events.where(name: 'module_complete').size).to eq 1
    end
  end
end
