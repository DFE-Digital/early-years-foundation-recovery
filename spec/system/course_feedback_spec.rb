require 'rails_helper'

describe 'Course feedback' do
  context 'with unauthenticated user' do
    include_context 'with automated path'
    let(:fixture) { 'spec/support/ast/course-feedback.yml' }

    it 'returns to homepage once completed' do
      expect(page).to have_current_path '/feedback/thank-you'
      expect(page).to have_content 'Thank you'
      click_on 'Go to home'
      expect(page).to have_current_path '/'
    end

    context 'when already completed' do
      it 'can be updated' do
        visit '/feedback'
        click_on 'Update my feedback'
        expect(page).to have_current_path '/feedback/feedback-radiobutton'
      end
    end
  end

  context 'with authenticated user' do
    include_context 'with user'
    include_context 'with automated path'
    let(:fixture) { 'spec/support/ast/course-feedback.yml' }

    it 'returns to modules page once completed' do
      expect(page).to have_current_path '/feedback/thank-you'
      expect(page).to have_content 'Thank you'
      click_on 'Go to my modules'
      expect(page).to have_current_path '/my-modules'
      expect(page).to have_content 'My modules'
    end

    context 'when already completed' do
      it 'can be updated' do
        visit '/feedback'
        click_on 'Update my feedback'
        expect(page).to have_current_path '/feedback/feedback-radiobutton'
      end
    end
  end
end
