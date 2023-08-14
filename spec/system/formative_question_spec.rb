require 'rails_helper'

RSpec.describe 'Formative question' do
  include_context 'with progress'
  include_context 'with user'

  before do
    view_pages_upto_formative_question(alpha)
  end

  context 'when a user has visited each page up to and including a formative question' do
    it 'call to action resumes the module at that question' do
      visit '/modules/alpha'
      click_on 'Resume module'
      expect(page).to have_current_path '/modules/alpha/questionnaires/1-1-4', ignore_query: true
    end
  end

  context 'when a user has answered correctly' do
    before do
      visit '/modules/alpha/questionnaires/1-1-4'
      choose 'Correct answer 1'
      2.times { click_on 'Next' }
    end

    it 'is not able to be changed' do
      visit '/modules/alpha/questionnaires/1-1-4'

      expect(page).to have_selector('.govuk-radios__input:disabled')
    end
  end

  context 'when a user has answered wrongly' do
    before do
      visit '/modules/alpha/questionnaires/1-1-4'
      choose 'Wrong answer 1'
      2.times { click_on 'Next' }
    end

    it 'is not able to be changed' do
      visit '/modules/alpha/questionnaires/1-1-4'
      expect(page).to have_selector('.govuk-radios__input:disabled')
    end
  end

  context 'when on a question page' do
    specify do
      visit 'modules/alpha/questionnaires/1-1-4'
      expect(page).to have_link 'Back to Module 1 overview', href: '/modules/alpha'
    end
  end

  context 'when no answer is submitted' do
    it 'displays an error message' do
      visit 'modules/alpha/questionnaires/1-1-4'
      click_on 'Next'
      expect(page).to have_content 'Please select an answer'
    end
  end
end
