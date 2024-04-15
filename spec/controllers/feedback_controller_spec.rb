require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do
  context 'when user is signed in' do
    let(:user) { create :user, :registered }

    before { sign_in user }

    describe 'GET #show' do
      context 'last page' do
        it 'is tracked as complete' do
          expect(controller).to receive(:track_feedback_complete)
          expect(cookies[:course_feedback_completed]).not_to be_present
          get :show, params: { id: 'thank-you' }
          expect(cookies[:course_feedback_completed]).to be_present
        end
      end

      it 'returns a success response' do
        get :show, params: { id: 'feedback-radio-only' }
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
            id: 'feedback-radio-only',
            response: {
              answers: %w[1],
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
          expect(response).to redirect_to feedback_path('feedback-checkbox-only')
        end

        it 'is tracked as started' do
          expect(controller).to receive(:track_feedback_start)
          expect(cookies[:course_feedback_started]).not_to be_present
          post :update, params: params
          expect(cookies[:course_feedback_started]).to be_present
        end
      end

      context 'with invalid params' do
        let(:params) do
          {
            id: 'feedback-radio-only',
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

        it 'is not tracked as started' do
          expect(controller).not_to receive(:track_feedback_start)
          post :update, params: params
          expect(cookies[:course_feedback_started]).not_to be_present
        end
      end
    end
  end

  # xdescribe '#feedback_complete?' do
  #   before do
  #     allow(controller).to receive(:current_user).and_return(user)
  #   end

  #   context 'with registered user' do
  #     let(:user) { create :user, :registered }

  #     before do
  #       allow(user).to receive(:completed_course_feedback?).and_return(completed)
  #       get :index
  #     end

  #     context 'and form completed' do
  #       let(:completed) { true }

  #       specify { expect(controller).to be_feedback_complete }
  #     end

  #     context 'and form not completed' do
  #       let(:completed) { false }

  #       specify { expect(controller).not_to be_feedback_complete }
  #     end
  #   end

  #   context 'with guest' do
  #     let(:user) { Guest.new(visit: create(:visit)) }

  #     before do
  #       allow(controller).to receive(:cookies).and_return(cookie)
  #       get :index
  #     end

  #     context 'and form completed' do
  #       let(:cookie) { { course_feedback_completed: 'some-token' } }

  #       specify { expect(controller).to be_feedback_complete }
  #     end

  #     context 'and form not completed' do
  #       let(:cookie) { {} }

  #       specify { expect(controller).not_to be_feedback_complete }
  #     end
  #   end
  # end
end
