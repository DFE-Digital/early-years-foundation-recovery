require 'rails_helper'

RSpec.describe 'Module feedback' do
  include_context 'with progress'
  include_context 'with user'

  before do
    visit '/modules/alpha/questionnaires/feedback-radio-only'
  end

  it 'validates answers' do
    click_on 'Next'
    expect(page).to have_content 'Please select an answer'
  end

  describe 'one-off questions' do
    context 'when not already answered' do
      it 'pagination counts the question' do
        expect(page).to have_content 'Page 1 of 9'
        visit '/modules/alpha/questionnaires/feedback-skippable'
        expect(page).to have_content 'Page 8 of 9'
      end
    end

    context 'when already answered' do
      before do
        create :response,
               question_name: 'feedback-skippable',
               training_module: 'bravo',
               answers: [1],
               correct: true,
               user: user,
               question_type: 'feedback'
      end

      # FeedbackPaginationDecorator#page_total
      it 'pagination does not count the question' do
        visit '/modules/alpha/questionnaires/feedback-radio-only'
        expect(page).to have_content 'Page 1 of 8'
      end

      # Training::ResponsesController#redirect
      it 'skips the question' do
        visit '/modules/alpha/questionnaires/feedback-checkbox-other-or'
        expect(page).to have_content 'Page 7 of 8'
        check 'response-answers-1-field'
        click_on 'Next'
        expect(page).to have_content 'Page 8 of 8'
        expect(page).to have_current_path '/modules/alpha/content-pages/1-3-3-5'
      end
    end
  end
end
