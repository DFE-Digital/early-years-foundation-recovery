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
        3.times do
          choose 'Strongly agree'
          click_on 'Next'
        end
      end

      it 'tracks answers and completion' do
        expect(events.where(name: 'questionnaire_answer').where_properties(type: 'confidence_check').size).to eq 3
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

    context 'when all questions are answered correctly' do
      before do
        3.times do
          check 'Correct answer 1'
          check 'Correct answer 2'
          click_on 'Save and continue'
        end
        choose 'Correct answer 1'
        click_on 'Finish test'
      end

      it 'tracks answers and successful attempt' do
        expect(events.where(name: 'questionnaire_answer').where_properties(success: true, type: 'summative_assessment').size).to eq 4
        expect(events.where(name: 'summative_assessment_complete').where_properties(score: 100, success: true).size).to eq 1
      end
    end

    context 'when all questions are answered incorrectly' do
      before do
        3.times do
          check 'Wrong answer 1'
          check 'Wrong answer 2'
          click_on 'Save and continue'
        end
        choose 'Wrong answer 1'
        click_on 'Finish test'
      end

      it 'tracks answers and failed attempt' do
        expect(events.where(name: 'questionnaire_answer').where_properties(success: false, type: 'summative_assessment').size).to eq 4
        expect(events.where(name: 'summative_assessment_complete').where_properties(score: 0, success: false).size).to eq 1
      end
    end
  end

  describe 'formative assessment' do
    before do
      view_pages_upto_formative_question(alpha)
      visit '/modules/alpha'
      click_on 'Resume module'

      choose 'Correct answer 1'
      4.times { click_on 'Next' }

      check 'Correct answer 1'
      check 'Correct answer 2'
      click_on 'Next'
    end

    it 'tracks answers' do
      expect(events.where(name: 'questionnaire_answer').where_properties(success: true, type: 'formative_assessment').size).to eq 2
    end
  end

  describe 'visiting every page' do
    before do
      alpha.module_items.each { |item| visit "/modules/alpha/content-pages/#{item.name}" }
    end

    it 'tracks start and completion' do
      expect(events.where(name: 'module_start').size).to be 1
      expect(events.where(name: 'module_content_page').size).to be 28
      expect(events.where(name: 'module_complete').size).to eq 1
    end
  end
end
