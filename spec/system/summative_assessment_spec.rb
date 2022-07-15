require 'rails_helper'

RSpec.describe 'Summative assessment' do
  include_context 'with progress'

  before do
    view_pages_before_summative_assessment(alpha)
  end

  include_context 'with user'

  context 'when a user has visited each module up to and including a summative assessment' do
    it 'can click to resume training to visit the summative assessment page' do
      visit '/modules/alpha'
      click_on 'Resume training'
      expect(page).to have_current_path '/modules/alpha/summative-assessments/1-3-2-1', ignore_query: true
    end
  end

  context 'when a user has passed the summative assessment' do
    # Pass the summative assessment
    before do
      visit '/modules/alpha/summative-assessments/1-3-2-1'
      2.times do
        check 'Correct answer 1'
        check 'Correct answer 2'
        click_on 'Save and continue'
      end
      choose 'Correct answer 1'
      click_on 'Finish test'
    end

    it 'displays the correct score' do
      expect(page).to have_content 'You scored 100%'
    end

    it 'can navigate to confidence check from module overview page' do
      visit '/modules/alpha'

      expect(page).to have_link('Reflect on your learning')
    end

    it 'is not able to retake the assessment' do
      visit '/modules/alpha/summative-assessments/1-3-2-1'

      expect(page).to have_selector('.govuk-checkboxes__input:disabled')
    end
  end

  context 'when a user has failed the summative assessment' do
    # Fail the summative assessment
    before do
      visit '/modules/alpha/summative-assessments/1-3-2-1'
      2.times do
        check 'Wrong answer 1'
        check 'Wrong answer 2'
        click_on 'Save and continue'
      end
      choose 'Wrong answer 1'
      click_on 'Finish test'
    end

    it 'displays the correct score' do
      expect(page).to have_content 'You scored 0%'
    end

    it 'cannot navigate to confidence check from module overview page' do
      visit '/modules/alpha'

      expect(page).to have_content('Reflect on your learning')
      expect(page).not_to have_link('Reflect on your learning')
    end

    it 'is able to retake the assessment' do
      visit '/modules/alpha/summative-assessments/1-3-2-1'

      expect(page).to have_selector('.govuk-checkboxes__input')
    end
  end
end
