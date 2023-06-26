require 'rails_helper'

#
# First formative question 1-2-1-1 in alpha
#
# 1: Draft
# 2: Changed
# 3: Published
# 4: All of the above
#
RSpec.describe 'Formative question' do
  include_context 'with progress'
  include_context 'with user'

  before do
    # when a user has visited each page up to and including the first formative question
    view_pages_upto_formative_question(alpha)
  end

  describe 'module overview page' do
    it 'resumes the furthest visited page' do
      visit '/modules/alpha'
      click_on 'Resume module'
      expect(page).to have_current_path '/modules/alpha/questionnaires/1-2-1-1', ignore_query: true
    end
  end

  context 'when answered correctly' do
    before do
      visit '/modules/alpha/questionnaires/1-2-1-1'
      choose 'All of the above'
      2.times { click_on 'Next' }
    end

    it 'is not able to be retaken' do
      visit '/modules/alpha/questionnaires/1-2-1-1'

      expect(page).to have_selector('.govuk-radios__input:disabled')
    end
  end

  context 'when answered incorrectly' do
    before do
      visit '/modules/alpha/questionnaires/1-2-1-1'
      choose 'Published'
      2.times { click_on 'Next' }
    end

    it 'is not able to be retaken' do
      visit '/modules/alpha/questionnaires/1-2-1-1'
      expect(page).to have_selector('.govuk-radios__input:disabled')
    end
  end

  context 'when on a question page' do
    specify do
      visit 'modules/alpha/questionnaires/1-2-1-1'
      expect(page).to have_link 'Back to Module 1 overview', href: '/modules/alpha'
    end
  end

  context 'when no answer is selected' do
    it 'displays error message' do
      visit 'modules/alpha/questionnaires/1-2-1-1'
      click_on 'Next'
      expect(page).to have_content 'Please select an answer'
    end
  end
end
