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

    it 'saves all answers' do
      expect(Response.course_feedback.count).to be 8
      expect(Response.course_feedback.first).to be_persisted
      expect(Response.course_feedback.first.visit).to be_present
    end

    describe 'additional text input' do
      let(:response) do
        Response.course_feedback.find_by(question_name: 'feedback-radio-other-more')
      end

      it 'is persisted' do
        expect(response.text_input).to eq 'other text'
      end
    end

    context 'when already completed' do
      it 'can be updated' do
        visit '/feedback'
        click_on 'Update my feedback'
        expect(page).to have_current_path '/feedback/feedback-radio-only'
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

    it 'saves all answers' do
      expect(Response.course_feedback.count).to be 8
      expect(Response.course_feedback.first).to be_persisted
      expect(Response.course_feedback.first.user).to be_present
    end

    describe 'additional text input' do
      let(:response) do
        Response.course_feedback.find_by(question_name: 'feedback-radio-other-more')
      end

      it 'is persisted' do
        expect(response.text_input).to eq 'other text'
      end
    end

    context 'when already completed' do
      it 'can be updated' do
        visit '/feedback'
        click_on 'Update my feedback'
        expect(page).to have_current_path '/feedback/feedback-radio-only'
      end
    end
  end

  describe 'one-off questions' do
    include_context 'with user'

    context 'when already answered' do
      before do
        create :response,
               question_name: 'feedback-skippable',
               training_module: 'alpha',
               answers: [1],
               correct: true,
               user: user,
               question_type: 'feedback'
      end

      it 'skips the question' do
        visit '/feedback/feedback-checkbox-other-or'
        check 'response-answers-1-field'
        click_on 'Next'
        expect(page).to have_current_path '/feedback/thank-you'
      end
    end
  end
end
