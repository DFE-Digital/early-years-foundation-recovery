require 'rails_helper'

RSpec.describe 'Confidence check' do
  include_context 'with progress'

  before do
    view_pages_before_confidence_check(alpha)
  end

  include_context 'with user'

  context 'when a user has visited each module up to and including a confidence check' do
    it 'can click to resume training to visit the confidence check page' do
      visit '/modules/alpha'
      click_on 'Resume training'
      expect(page).to have_current_path '/modules/alpha/confidence-check/1-3-3-1', ignore_query: true
    end
  end

  context 'when a user has passed the confidence check' do
    # Pass the confidence check
    before do
      visit '/modules/alpha/confidence-check/1-3-3-1'
      2.times do
        check 'Correct answer 1'
        check 'Correct answer 2'
        click_on 'Next'
      end
      choose 'Correct answer 1'
      click_on 'Next'
    end

    it 'is able to retake the assessment' do
      visit '/modules/alpha/confidence-check/1-3-3-1'

      expect(page).to have_selector('.govuk-checkboxes__input')
    end
  end

  context 'when a user has failed the confidence check' do
    # Fail the confidence check
    before do
      visit '/modules/alpha/confidence-check/1-3-3-1'
      2.times do
        check 'Wrong answer 1'
        check 'Wrong answer 2'
        click_on 'Next'
      end
      choose 'Wrong answer 1'
      click_on 'Next'
    end

    it 'is able to retake the assessment' do
      visit '/modules/alpha/confidence-check/1-3-3-1'

      expect(page).to have_selector('.govuk-checkboxes__input')
    end
  end
end
