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
      first_choice = page.has_field?('Very confident') ? 'Very confident' : 'Strongly agree'
      second_choice = page.has_field?('Not very confident') ? 'Not very confident' : 'Disagree'

      3.times do
        choose first_choice
        click_on 'Next'
      end

      visit first_question_path
      expect(page).to have_checked_field first_choice
      choose second_choice
      click_on 'Next'
      click_on 'Previous'
      expect(page).to have_checked_field second_choice
    end
  end
end
