require 'rails_helper'

RSpec.describe 'Confidence check' do
  include_context 'with progress'
  include_context 'with user'

  let(:first_question_path) { '/modules/alpha/questionnaires/1-3-3-1' }

  before do
    view_pages_upto alpha, 'confidence'
    visit first_question_path
  end

  it 'is not multi-select' do
    expect(page).to have_selector '.govuk-radios__input'
  end

  context 'when started' do
    it 'can be resumed' do
      visit '/modules/alpha'
      click_on 'Resume module'
      expect(page).to have_current_path(first_question_path, ignore_query: true)
    end
  end

  context 'when completed' do
    it 'can be edited' do
      3.times do
        choose 'Very confident'
        click_on 'Next'
      end

      visit first_question_path
      expect(page).to have_checked_field 'Very confident'
      choose 'Not very confident'
      click_on 'Next'
      click_on 'Previous'
      expect(page).to have_checked_field 'Not very confident'
    end
  end
end
