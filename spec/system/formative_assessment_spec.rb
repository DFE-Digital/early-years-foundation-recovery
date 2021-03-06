require 'rails_helper'

RSpec.describe 'Formative assessment' do
  include_context 'with progress'

  before do
    view_pages_before_formative_assessment(alpha)
  end

  include_context 'with user'

  context 'when a user has visited each page up to and including a formative assessment' do
    it 'call to action resumes the assessment at the furthest visited page' do
      visit '/modules/alpha'
      click_on 'Resume training'
      expect(page).to have_current_path '/modules/alpha/formative-assessments/1-1-4', ignore_query: true
    end
  end

  context 'when a user has passed the formative assessment' do
    before do
      visit '/modules/alpha/formative-assessments/1-1-4'
      choose 'Correct answer 1'
      2.times { click_on 'Next' }
    end

    it 'can navigate to next submodule intro' do
      visit '/modules/alpha'

      expect(page).to have_link('1-2-1')
    end

    it 'is not able to retake the assessment' do
      visit '/modules/alpha/formative-assessments/1-1-4'

      expect(page).to have_selector('.govuk-radios__input:disabled')
    end
  end

  context 'when a user has failed the formative assessment' do
    before do
      visit '/modules/alpha/formative-assessments/1-1-4'
      choose 'Wrong answer 1'
      2.times { click_on 'Next' }
    end

    it 'can navigate to next submodule intro' do
      visit '/modules/alpha'

      expect(page).to have_link('1-2-1')
    end

    it 'is not able to retake the assessment' do
      visit '/modules/alpha/formative-assessments/1-1-4'

      expect(page).to have_selector('.govuk-radios__input:disabled')
    end
  end
end
