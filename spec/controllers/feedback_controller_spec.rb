require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do
  context 'when user is signed in' do
    let(:user) { create :user, :registered }
    let(:valid_attributes) do
      { id: 1, answers: %w[Yes], answers_custom: 'Custom answer', training_module: nil, question_name: 'feedback-radiobutton' }
    end

    before { sign_in user }

    describe 'GET #show' do
      it 'returns a success response' do
        get :show, params: { id: 1 }
        expect(response).to be_successful
      end
    end

    describe 'GET #index' do
      it 'returns a success response' do
        get :index
        expect(response).to be_successful
      end
    end

    describe 'POST #update' do
      context 'with valid params' do
        it 'creates a new Response' do
          expect {
            post :update, params: valid_attributes
          }.to change(Response, :count).by(1)
        end

        it 'redirects to the next feedback path' do
          post :update, params: valid_attributes
          expect(response).to redirect_to(feedback_path(2))
        end
      end

      context 'with invalid params' do
        let(:invalid_attributes) do
          { id: 1, answers: [''] }
        end

        it 'does not create a new Response' do
          expect {
            post :update, params: invalid_attributes
          }.not_to change(Response, :count)
        end

        it 'redirects to the current feedback path' do
          post :update, params: invalid_attributes
          expect(response).to redirect_to(feedback_path(1))
        end
      end
    end
  end
end
