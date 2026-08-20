require 'rails_helper'

RSpec.describe Training::ResponsesController, type: :controller do
  let(:user) { create(:user, :registered) }
  let(:records) { Response.count }

  before do
    sign_in user
  end

  describe '#update' do
    context 'with formative' do
      let(:text_input) { 'Text input' }

      before do
        patch :update, params: {
          training_module_id: 'alpha',
          id: question_name,
          response: { answers: answers, text_input: text_input },
        }
      end

      context 'when single choice (radio buttons)' do
        let(:question_name) { '1-1-4-1' }

        context 'with correct answer' do
          let(:answers) { [1] }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end

        context 'with incorrect answer' do
          let(:answers) { [2] }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end

        context 'and no answer' do
          let(:answers) { nil }

          specify { expect(response).to have_http_status(:unprocessable_content) }
          specify { expect(records).to be 0 }
        end
      end

      context 'when multiple choice (check boxes)' do
        let(:question_name) { '1-2-1-1' }

        context 'with correct answers' do
          let(:answers) { [1, 3] }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end

        context 'with incorrect answers' do
          let(:answers) { [1, 2] }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end

        context 'and no answers' do
          let(:answers) { nil }

          specify { expect(response).to have_http_status(:unprocessable_content) }
          specify { expect(records).to be 0 }
        end
      end

      context 'when the question expects text and is answered' do
        let(:question_name) { 'feedback-textarea-only' }
        let(:answers) { [] }

        context 'with text input' do
          let(:text_input) { 'Text input for feedback question' }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end

        context 'with no text input' do
          let(:text_input) { nil }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end
      end
    end

    context 'with summative' do
      let(:question_name) { '1-3-2-1' } # First summative question
      let(:last_question_name) { '1-3-2-10' } # Last summative question
      let(:answers) { [1] } # Correct answer for these questions
      let(:submission_nonce) { SecureRandom.uuid }

      context 'when nonce is blank' do
        it 'redirects immediately without creating response' do
          patch :update, params: {
            training_module_id: 'alpha',
            id: question_name,
            response: { answers: answers, submission_nonce: nil },
          }
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(training_module_question_path('alpha', question_name))
          expect(records).to be 0
        end

        it 'logs the duplicate/invalid submission' do
          allow(Rails.logger).to receive(:error)
          patch :update, params: {
            training_module_id: 'alpha',
            id: question_name,
            response: { answers: answers, submission_nonce: nil },
          }
          expect(Rails.logger).to have_received(:error).with(/Duplicate or invalid submission/)
        end
      end

      context 'when nonce does not match session' do
        before do
          # Set a different nonce in session
          session[:form_nonce] = SecureRandom.uuid
          patch :update, params: {
            training_module_id: 'alpha',
            id: question_name,
            response: { answers: answers, submission_nonce: 'wrong-nonce' },
          }
        end

        it 'redirects immediately without creating response' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(training_module_question_path('alpha', question_name))
          expect(records).to be 0
        end
      end

      context 'when nonce is valid and submission succeeds' do
        before do
          session[:form_nonce] = submission_nonce
        end

        context 'and it is not the last assessment question' do
          before do
            patch :update, params: {
              training_module_id: 'alpha',
              id: question_name,
              response: { answers: answers, submission_nonce: submission_nonce },
            }
          end

          it 'creates response and redirects' do
            expect(response).to have_http_status(:redirect)
            expect(records).to be 1
          end

          it 'preserves nonce in session for next question' do
            expect(session[:form_nonce]).to eq(submission_nonce)
          end
        end

        context 'and it is the last assessment question' do
          before do
            patch :update, params: {
              training_module_id: 'alpha',
              id: last_question_name,
              response: { answers: answers, submission_nonce: submission_nonce },
            }
          end

          it 'creates response and redirects' do
            expect(response).to have_http_status(:redirect)
            expect(records).to be 1
          end

          it 'consumes nonce from session' do
            expect(session[:form_nonce]).to be_nil
          end
        end
      end

      context 'when nonce is valid but submission fails validation' do
        before do
          session[:form_nonce] = submission_nonce
        end

        it 'renders form with unprocessable_entity status' do
          patch :update, params: {
            training_module_id: 'alpha',
            id: question_name,
            response: { answers: nil, submission_nonce: submission_nonce },
          }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(records).to be 0
        end

        it 'stores new nonce in session for resubmission' do
          # Initial request with invalid answers
          patch :update, params: {
            training_module_id: 'alpha',
            id: question_name,
            response: { answers: nil, submission_nonce: submission_nonce },
          }
          expect(response).to have_http_status(:unprocessable_entity)

          # Verify a new nonce was generated and stored in session
          new_nonce = session[:form_nonce]
          expect(new_nonce).to be_present
          expect(new_nonce).not_to eq(submission_nonce)
        end
      end
    end
  end
end
