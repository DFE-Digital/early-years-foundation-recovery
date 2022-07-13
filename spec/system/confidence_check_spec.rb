require 'rails_helper'

RSpec.describe 'Confidence check' do
  include_context 'with progress'
  include_context 'with user'

  let(:first_question_path) { '/modules/alpha/confidence-check/1-3-3-1' }

  before do
    view_pages_before_confidence_check(alpha)
    visit first_question_path
  end

  it 'is not multi-select' do
    expect(page).to have_selector '.govuk-radios__input'
  end

  context 'when a user has reached the confidence check' do
    it 'can resume from the module overview page' do
      visit '/modules/alpha'
      click_on 'Resume training'
      expect(page).to have_current_path(first_question_path, ignore_query: true)
    end
  end

  context 'when a user has completed the questionnnaire' do
    it 'is able to be retaken' do
      3.times do
        choose 'Strongly agree'
        click_on 'Next'
      end

      visit first_question_path
      expect(page).to have_checked_field 'Strongly agree'
      choose 'Disagree'
      click_on 'Next'
      click_on 'Previous'
      expect(page).to have_checked_field 'Disagree'
    end
  end
end
