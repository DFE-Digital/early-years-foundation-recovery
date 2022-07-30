require 'rails_helper'

RSpec.describe 'Check ahoy tracking' do
  include_context 'with progress'

  include_context 'with user'

  context 'when a user has visited the first page of the module (after interruption page)' do
    before do
      start_module(alpha)
    end

    it 'ahoy tracks the starting of a module - track(module_start)' do
      visit '/modules/alpha/content-pages/before-you-start'
      click_on 'Next'
      expect(page).to have_current_path '/modules/alpha/content-pages/intro', ignore_query: true
      # check ahoy is tracking
      events = Ahoy::Event.where(user_id: user.id, name: 'module_start').where_properties(training_module_id: 'alpha')
      expect(events.size).to eq 1
    end
  end

  context 'when a user has finished the module (at the certificate page)' do
    before do
      view_pages_before_confidence_check(alpha)
    end

    it 'ahoy tracks the completion of a module - track(module_complete)' do
      visit '/modules/alpha/content-pages/intro'
      visit '/modules/alpha/content-pages/1-3-3'
      click_on 'Next'
      2.times do
        check 'Correct answer 1'
        check 'Correct answer 2'
        click_on 'Next'
      end
      choose 'Correct answer 1'
      click_on 'Next'
      click_on 'Finish'
      expect(page).to have_current_path '/modules/alpha/certificate', ignore_query: true
      # check ahoy is tracking the event
      events = Ahoy::Event.where(user_id: user.id, name: 'module_complete').where_properties(training_module_id: 'alpha')
      expect(events.size).to eq 1
    end
  end

  context 'when a user has visited the first page of the confidence check' do
    before do
      view_pages_before_confidence_check(alpha)
    end

    it 'ahoy tracks the starting of the confidence check - track(confidence_questionnaire_start)' do
      visit '/modules/alpha/content-pages/1-3-3'
      click_on 'Next'
      expect(page).to have_current_path '/modules/alpha/confidence-check/1-3-3-1', ignore_query: true
      # check ahoy is tracking the event
      events = Ahoy::Event.where(user_id: user.id, name: 'confidence_questionnaire_start').where_properties(training_module_id: 'alpha')
      expect(events.size).to eq 1
    end
  end

  context 'when a user has answered a confidence check question' do
    before do
      view_pages_before_confidence_check(alpha)
      visit '/modules/alpha/confidence-check/1-3-3-1'
      check 'Correct answer 1'
      check 'Correct answer 2'
      click_on 'Next'
    end

    it 'ahoy tracks when a confidence check question has been answered - track(questionnaire_answer)' do
      expect(page).to have_current_path '/modules/alpha/confidence-check/1-3-3-2', ignore_query: true
      # check ahoy is tracking the event
      events = Ahoy::Event.where(user_id: user.id, name: 'questionnaire_answer').where_properties(training_module_id: 'alpha')
      expect(events.size).to eq 1
    end
  end

  context 'when a user has finished the confidence check (at the thank you page)' do
    before do
      view_pages_before_confidence_check(alpha)
    end

    it 'ahoy tracks the completion of the confidence check - track(confidence_questionnaire_complete)' do
      visit '/modules/alpha/content-pages/1-3-3'
      click_on 'Next'
      2.times do
        check 'Correct answer 1'
        check 'Correct answer 2'
        click_on 'Next'
      end
      choose 'Correct answer 1'
      click_on 'Next'
      expect(page).to have_current_path '/modules/alpha/content-pages/1-3-3-4', ignore_query: true
      # check ahoy is tracking the event
      events = Ahoy::Event.where(user_id: user.id, name: 'confidence_questionnaire_complete').where_properties(training_module_id: 'alpha')
      expect(events.size).to eq 1
    end
  end

  context 'when a user has visited the first page of the summative assessment' do
    before do
      view_pages_before_summative_assessment(alpha)
      visit '/modules/alpha'
      click_on 'Resume training'
    end

    it 'ahoy tracks the starting of the summative assessment - track(summative_assessment_start)' do
      expect(page).to have_current_path '/modules/alpha/summative-assessments/1-3-2-1', ignore_query: true
      # check ahoy is tracking the event
      events = Ahoy::Event.where(user_id: user.id, name: 'summative_assessment_start').where_properties(training_module_id: 'alpha')
      expect(events.size).to eq 1
    end
  end

  context 'when a user has answered a summative assessment question' do
    before do
      view_pages_before_summative_assessment(alpha)
      visit '/modules/alpha/summative-assessments/1-3-2-1'
      check 'Correct answer 1'
      check 'Correct answer 2'
      click_on 'Save and continue'
    end

    it 'ahoy tracks when a summative assessment question has been answered - track(questionnaire_answer)' do
      expect(page).to have_current_path '/modules/alpha/summative-assessments/1-3-2-2', ignore_query: true
      # check ahoy is tracking the event
      events = Ahoy::Event.where(user_id: user.id, name: 'questionnaire_answer').where_properties(training_module_id: 'alpha')
      expect(events.size).to eq 1
    end
  end

  context 'when a user has completed the summative assessment (submitted results and at results page)' do
    before do
      view_pages_before_summative_assessment(alpha)
      visit '/modules/alpha'
      click_on 'Resume training'
      3.times do
        check 'Correct answer 1'
        check 'Correct answer 2'
        click_on 'Save and continue'
      end
      choose 'Correct answer 1'
      click_on 'Finish test'
    end

    it 'ahoy tracks the completion of the summative assessment - track(summative_assessment_complete)' do
      expect(page).to have_current_path '/modules/alpha/assessment-result/1-3-2-5', ignore_query: true
      # check ahoy is tracking the event
      events = Ahoy::Event.where(user_id: user.id, name: 'summative_assessment_complete').where_properties(training_module_id: 'alpha')
      expect(events.size).to eq 1
    end
  end

  context 'when a user has visited & answered formative assessment questions' do
    before do
      view_pages_before_formative_assessment(alpha)
      visit '/modules/alpha'
      click_on 'Resume training'
      choose 'Correct answer 1'
      4.times { click_on 'Next' }
      check 'Correct answer 1'
      check 'Correct answer 2'
      2.times { click_on 'Next' }
    end

    it 'ahoy tracks when a formative assessment question has been answered- track(questionnaire_answer)' do
      expect(page).to have_current_path '/modules/alpha/content-pages/1-2-1-2', ignore_query: true
      # check ahoy is tracking the event
      events = Ahoy::Event.where(user_id: user.id, name: 'questionnaire_answer').where_properties(training_module_id: 'alpha')
      expect(events.size).to eq 2
    end
  end
end
