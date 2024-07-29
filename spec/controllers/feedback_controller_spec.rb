require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do
  context 'when user is a guest' do
    describe 'GET #show' do
      it 'returns a success response' do
        get :show, params: { id: 'feedback-radio-only' }
        expect(response).to have_http_status(:success)
      end
    end
  end

  context 'when user is signed in' do
    let(:user) { create :user, :registered }

    before { sign_in user }

    describe 'GET #show' do
      context 'with last page' do
        it 'is tracked as complete' do
          expect(controller).to receive(:track_feedback_complete)
          get :show, params: { id: 'thank-you' }
        end
      end

      it 'returns a success response' do
        get :show, params: { id: 'feedback-radio-only' }
        expect(response).to have_http_status(:success)
      end

      context 'when the shared question was answered during a training module' do
        let(:answer) do
          create :response,
                 user: user,
                 training_module: 'alpha',
                 question_name: 'feedback-skippable',
                 question_type: 'feedback',
                 answers: [1] # yes / participate
        end

        it 'moved to the main form' do
          expect {
            get :show, params: { id: 'feedback-skippable' }
          }.to change {
            answer.reload.training_module
          }.from('alpha').to('course')
        end
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
            id: 'feedback-skippable',
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

        context 'and first response' do
          it 'redirects to the next feedback content' do
            post :update, params: params
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to feedback_path('thank-you')
          end
        end

        context 'and subsequent responses' do
          it 'redirects to the profile page' do
            create :event, user: user, name: 'profile_page'
            post :update, params: params
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to user_path
          end
        end

        it 'is tracked as started' do
          expect(controller).to receive(:track_feedback_start)
          expect(cookies[:course_feedback]).not_to be_present
          post :update, params: params
          expect(cookies[:course_feedback]).to be_present
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
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'is not persisted' do
          expect {
            post :update, params: params
          }.not_to change(Response, :count)
        end

        it 'is not tracked as started' do
          expect(controller).not_to receive(:track_feedback_start)
          post :update, params: params
          expect(cookies[:course_feedback]).not_to be_present
        end
      end
    end
  end
end
