require 'rails_helper'

RSpec.describe 'Check ahoy tracking' do
  include_context 'with progress'
  include_context 'with user'
  include AlphaAssessmentShared

  let(:alpha_event) do
    Ahoy::Event.where(user_id: user.id).where_properties(training_module_id: 'alpha')
  end
  let(:bravo_event) do
    Ahoy::Event.where(user_id: user.id).where_properties(training_module_id: 'bravo')
  end

  context 'when a user has visited the first page of the module (after interruption page)' do
    it 'ahoy tracks the starting of a module - track(module_start)' do
      start_module(alpha)
      visit '/modules/alpha/content-pages/before-you-start'
      click_on 'Next'
      expect(page).to have_current_path '/modules/alpha/content-pages/intro', ignore_query: true
      expect(alpha_event.where(name: 'module_start').size).to eq 1
    end
  end

  context 'when a user has visited the first page of the confidence check' do
    it 'ahoy tracks the starting of the confidence check - track(confidence_check_start)' do
      view_pages_before_confidence_check(alpha)
      visit '/modules/alpha/content-pages/1-3-3'
      click_on 'Next'
      expect(page).to have_current_path '/modules/alpha/confidence-check/1-3-3-1', ignore_query: true
      expect(alpha_event.where(name: 'confidence_check_start').size).to eq 1
    end
  end

  context 'when a user has answered a confidence check question' do
    it 'ahoy tracks when a confidence check question has been answered correctly - track(questionnaire_answer)' do
      view_pages_before_confidence_check(alpha)
      visit '/modules/alpha/confidence-check/1-3-3-1'
      check 'Correct answer 1'
      check 'Correct answer 2'
      click_on 'Next'

      expect(page).to have_current_path '/modules/alpha/confidence-check/1-3-3-2', ignore_query: true
      expect(alpha_event.where(name: 'questionnaire_answer').where_properties(success: true, type: 'confidence_check').size).to eq 1
    end
  end

  context 'when a user has finished the confidence check (at the thank you page)' do
    it 'ahoy tracks the completion of the confidence check - track(confidence_check_complete)' do
      view_pages_before_confidence_check(alpha)
      visit '/modules/alpha/content-pages/1-3-3'
      click_on 'Next'
      complete_confidence_check

      expect(page).to have_current_path '/modules/alpha/content-pages/1-3-3-4', ignore_query: true
      expect(alpha_event.where(name: 'confidence_check_complete').size).to eq 1
    end
  end

  context 'when a user has visited the first page of the summative assessment' do
    it 'ahoy tracks the starting of the summative assessment - track(summative_assessment_start)' do
      view_pages_before_summative_assessment(alpha)
      visit '/modules/alpha'
      click_on 'Resume training'

      expect(page).to have_current_path '/modules/alpha/summative-assessments/1-3-2-1', ignore_query: true
      expect(alpha_event.where(name: 'summative_assessment_start').size).to eq 1
    end
  end

  context 'when a user has answered a summative assessment question' do
    it 'ahoy tracks when a summative assessment question has been answered - track(questionnaire_answer)' do
      view_pages_before_summative_assessment(alpha)
      visit '/modules/alpha/summative-assessments/1-3-2-1'
      check 'Correct answer 1'
      check 'Correct answer 2'
      click_on 'Save and continue'

      expect(page).to have_current_path '/modules/alpha/summative-assessments/1-3-2-2', ignore_query: true
      expect(alpha_event.where(name: 'questionnaire_answer').where_properties(type: 'summative_assessment').size).to eq 1
    end
  end

  context 'when a user has completed the summative assessment (submitted results and at results page)' do
    it 'ahoy tracks the completion of the summative assessment - track(summative_assessment_complete)' do
      view_pages_before_summative_assessment(alpha)
      visit '/modules/alpha'
      click_on 'Resume training'
      complete_summative_assessment_correct

      expect(page).to have_current_path '/modules/alpha/assessment-result/1-3-2-5', ignore_query: true
      expect(alpha_event.where(name: 'summative_assessment_complete').where_properties(score: 100).size).to eq 1
    end
  end

  context 'when a user has answered a formative assessment question' do
    it 'ahoy tracks when a formative assessment question has been answered- track(questionnaire_answer)' do
      view_pages_before_formative_assessment(alpha)
      visit '/modules/alpha'
      click_on 'Resume training'
      complete_formative_assessment_correct

      expect(page).to have_current_path '/modules/alpha/content-pages/1-2-1-2', ignore_query: true
      expect(alpha_event.where(name: 'questionnaire_answer').where_properties(success: true, type: 'formative_assessment').size).to eq 2
    end
  end

  context 'when a user has finished alpha module (at the certificate page)' do
    before do
      visit '/modules/alpha/content-pages/intro'
      view_pages_before(alpha, 'sub_module_intro', 7)
      visit 'modules/alpha/content-pages/1-3-3-4'
      click_on 'Finish'
    end

    it 'ahoy tracks the completion of a module - track(module_complete)' do
      expect(page).to have_current_path '/modules/alpha/certificate', ignore_query: true
      expect(alpha_event.where(name: 'module_complete').size).to eq 1
    end

    context 'when user starts the second module' do
      it 'ahoy tracks the starting of a module - track(module_start)' do
        start_module(bravo)
        visit '/modules/bravo/content-pages/before-you-start'
        click_on 'Next'
        expect(page).to have_current_path '/modules/bravo/content-pages/intro', ignore_query: true
        expect(alpha_event.where(name: 'module_start').size).to eq 1
        expect(bravo_event.where(name: 'module_start').size).to eq 1
      end
    end
  end
end
