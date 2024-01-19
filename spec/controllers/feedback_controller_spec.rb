require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do
  let(:user) { User.create!(/* user attributes */) }
#   let(:question)
#   let(:feedback)
#   let(:course) { Course.create!(feedback: feedback) }
# TODO: create feedback and question

  before do
    sign_in user
    allow(controller).to receive(:find_course).and_return(course)
    allow(controller).to receive(:find_question).and_return(question)
  end

  describe 'PUT #update' do
    context 'when answer is provided' do
      it 'saves the answer and redirects to the next question' do
        put :update, params: { id: question.id, answer: 'Some answer' }

        expect(response).to redirect_to(feedback_path(assigns(:next_question)))
      end
    end

    context 'when no answer is provided' do
      it 'does not save the answer and re-renders the show view with an alert' do
        put :update, params: { id: question.id, answer: nil }

        expect(response).to render_template(:show)
        expect(flash[:alert]).to eq('You must select an answer.')
      end
    end
  end
end