require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do
  context 'when user is signed in' do
    let(:user) { create :user, :registered }

    before { sign_in user }

    describe 'GET #show' do
      it 'tracks feedback start' do
        expect(controller).to receive(:track_feedback_start)
        get :show, params: { id: 'feedback-radiobutton' }
      end

      it 'returns a success response' do
        get :show, params: { id: 'feedback-radiobutton' }
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #index' do
      it 'returns a success response' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST #update' do
      context 'with valid params' do
        let(:params) do
          {
            id: 'feedback-radiobutton',
            response: {
              answers: %w[Yes],
              answers_custom: 'Custom answer',
            },
          }
        end

        it 'is persisted' do
          expect {
            post :update, params: params
          }.to change(Response, :count).by(1)
        end

        it 'redirects to the next question' do
          post :update, params: params
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to feedback_path('feedback-yesnoandtext')
        end

        it 'tracks feedback complete' do
          expect(controller).to receive(:track_feedback_complete)
          post :update, params: params
        end
      end

      context 'with invalid params' do
        let(:params) do
          {
            id: 'feedback-radiobutton',
            response: {
              answers: [''],
            },
          }
        end

        it 'is not processed' do
          post :update, params: params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'is not persisted' do
          expect {
            post :update, params: params
          }.not_to change(Response, :count)
        end
      end
    end
  end

  describe '#feedback_exists?' do
    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context 'with registered user' do
      let(:user) { create :user, :registered }

      before do
        allow(user).to receive(:completed_main_feedback?).and_return(completed)
        get :index
      end

      context 'and form started' do
        let(:completed) { true }

        specify { expect(controller).to be_feedback_exists }
      end

      context 'and form not started' do
        let(:completed) { false }

        specify { expect(controller).not_to be_feedback_exists }
      end
    end

    context 'with guest' do
      let(:user) { Guest.new(visit: create(:visit)) }

      before do
        allow(controller).to receive(:cookies).and_return(cookie)
        get :index
      end

      context 'and form started' do
        let(:cookie) { { feedback_complete: 'some-token' } }

        specify { expect(controller).to be_feedback_exists }
      end

      context 'and form not started' do
        let(:cookie) { {} }

        specify { expect(controller).not_to be_feedback_exists }
      end
    end
  end
end
