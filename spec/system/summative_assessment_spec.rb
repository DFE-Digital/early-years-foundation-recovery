require 'rails_helper'

RSpec.describe 'Summative assessment' do
  include_context 'with progress'

  before do
    view_pages_before_summative_assessment(alpha)
  end

  include_context 'with user'

  context 'when a user has visited each module up to and including a summative assessment' do
    it 'can click to resume training to visit the summative assessment page' do
      visit training_module_path('alpha')
      click_on 'Resume training'
      expect(page).to have_current_path training_module_summative_assessment_path('alpha', '1-3-2-1'), ignore_query: true
    end
  end

  context 'when a user has passed the summative assessment' do
    # Pass the summative assessment
    before do
      visit training_module_summative_assessment_path('alpha', '1-3-2-1')
      2.times do
        choose '5'
        click_on 'Save and continue'
      end
      choose '5'
      click_on 'Finish test'
    end

    it 'can navigate to confidence check from module overview page' do
      visit training_module_path('alpha')

      expect(page).to have_link('Reflect on your learning')
    end

    it 'is not able to retake the assessment' do
      visit training_module_summative_assessment_path('alpha', '1-3-2-1')

      expect(page).to have_selector('.govuk-radios__input:disabled')
    end
  end

  context 'when a user has failed the summative assessment' do
    # Fail the summative assessment
    before do
      visit training_module_summative_assessment_path('alpha', '1-3-2-1')
      2.times do
        choose '4'
        click_on 'Save and continue'
      end
      choose '4'
      click_on 'Finish test'
    end

    it 'cannot navigate to confidence check from module overview page' do
      visit training_module_path('alpha')

      expect(page).to have_content('Reflect on your learning')
      expect(page).not_to have_link('Reflect on your learning')
    end

    it 'is able to retake the assessment' do
      visit training_module_summative_assessment_path('alpha', '1-3-2-1')

      expect(page).to have_selector('.govuk-radios__input')
    end
  end
end
