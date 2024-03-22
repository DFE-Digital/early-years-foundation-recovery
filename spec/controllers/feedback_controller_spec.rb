require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do
  context 'when user is signed in' do
    let(:user) { create :user, :registered }
    let(:valid_attributes) do
      {
        id: 'feedback-radiobutton',
        training_module: nil,
        response: {
          answers: %w[Yes],
          answers_custom: 'Custom answer',
        },
      }
    end

    before { sign_in user }

    describe 'GET #show' do
      it 'tracks feedback start' do
        expect(controller).to receive(:track_feedback_start)
        get :show, params: valid_attributes
      end

      it 'returns a success response' do
        get :show, params: valid_attributes
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
          expect(response).to redirect_to(feedback_path('feedback-yesnoandtext'))
        end

        it 'tracks feedback complete' do
          expect(controller).to receive(:track_feedback_complete)
          post :update, params: valid_attributes
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

  describe 'feedback_exists?' do
    let(:user) { create :user, :registered }
    let(:visit) { create :visit }

    context 'when user feedback exists' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        allow(user).to receive(:completed_main_feedback?).and_return(true)
      end

      it 'is true' do
        get :index
        expect(controller.feedback_exists?).to be true
      end
    end

    context 'when user feedback does not exist' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        allow(user).to receive(:completed_main_feedback?).and_return(false)
      end

      it 'is false' do
        get :index
        expect(controller.feedback_exists?).to be false
      end
    end

    context 'when guest feedback exists' do
      before do
        allow(controller).to receive(:current_user).and_return(Guest.new(visit: visit))
        allow(controller).to receive(:cookies).and_return({ feedback_complete: 'some-token' })
      end

      it 'is true' do
        get :index
        expect(controller.feedback_exists?).to be true
      end
    end

    context 'when guest feedback does not exist' do
      before do
        allow(controller).to receive(:current_user).and_return(Guest.new(visit: visit))
        allow(controller).to receive(:cookies).and_return({})
      end

      it 'is false' do
        get :index
        expect(controller.feedback_exists?).to be false
      end
    end
  end
end
