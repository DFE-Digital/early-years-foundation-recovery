require 'rails_helper'

RSpec.describe 'Feedback' do
  before do
    visit '/'
  end

  describe 'in beta banner' do
    specify do
      within '.govuk-phase-banner' do
        expect(page).to have_text 'This is a new service, your feedback will help us improve it.'
        expect(page).to have_link 'feedback', href: '/feedback'
      end
    end
  end

  describe 'in footer' do
    specify do
      within '.govuk-footer' do
        expect(page).to have_link 'Feedback', href: '/feedback'
      end
    end
  end

  describe 'questions' do
    include_context 'with user'

    it 'have previous/next buttons' do
      visit '/my-account'
      visit '/feedback'
      click_on 'Next'
      expect(page).to have_current_path '/feedback/feedback-radio-only'
      expect(Event.last.name).to eq 'feedback_intro'
      expect(page).to have_link 'Previous', href: '/feedback'
      expect(page).to have_button 'Next'
      expect(page).not_to have_button 'Save'
    end

    context 'when updated from account profile' do
      it 'have a save button' do
        visit '/my-account'
        click_on 'Change research preferences'
        expect(page).to have_current_path '/feedback/feedback-skippable'
        expect(Event.last.name).to eq 'profile_page'
        expect(page).not_to have_link 'Previous'
        expect(page).not_to have_button 'Next'
        expect(page).to have_button 'Save'
      end
    end
  end
end
