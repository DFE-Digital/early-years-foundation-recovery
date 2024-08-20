require 'rails_helper'

RSpec.describe 'Feedback' do
  it 'links from the footer' do
    visit '/'
    within '.govuk-footer' do
      expect(page).to have_link 'Feedback', href: '/feedback'
    end
  end

  describe 'questions' do
    context 'with guest' do
      it 'has previous/next buttons' do
        visit '/feedback/feedback-radio-only'
        expect(page).to have_text 'Feedback radio buttons only'
        expect(page).to have_link 'Previous', href: '/feedback'
        expect(page).to have_button 'Next'
      end
    end

    context 'with user' do
      include_context 'with user'

      it 'has previous/next buttons' do
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
        it 'has a save button' do
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
end
