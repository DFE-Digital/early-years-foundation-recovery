require 'rails_helper'


RSpec.describe Training::ResponsesController, type: :controller do
  let(:user) { create(:user, :registered) }
  let(:records) { Response.count }

  before do
    sign_in user
  end

  def patch_with_nonce(params, summative: false)
    if summative
      session[:form_nonce] = 'test-nonce'
      patch :update, params: params.merge(submission_nonce: 'test-nonce')
    else
      patch :update, params: params
    end
  end



  describe '#update' do
    context 'with formative' do
      context 'when single choice (radio buttons)' do
        let(:question_name) { '1-1-4-1' }

        context 'with correct answer' do
          let(:answers) { [1] }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: 'Text input' } }) }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end

        context 'with incorrect answer' do
          let(:answers) { [2] }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: 'Text input' } }) }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end

        context 'and no answer' do
          let(:answers) { nil }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: 'Text input' } }) }

          specify { expect(response).to have_http_status(:unprocessable_content) }
          specify { expect(records).to be 0 }
        end
      end

      context 'when multiple choice (check boxes)' do
        let(:question_name) { '1-2-1-1' }

        context 'with correct answers' do
          let(:answers) { [1, 3] }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: 'Text input' } }) }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end

        context 'with incorrect answers' do
          let(:answers) { [1, 2] }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: 'Text input' } }) }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end

        context 'and no answers' do
          let(:answers) { nil }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: 'Text input' } }) }

          specify { expect(response).to have_http_status(:unprocessable_content) }
          specify { expect(records).to be 0 }
        end
      end

      context 'when the question expects text and is answered' do
        let(:question_name) { 'feedback-textarea-only' }
        let(:answers) { [] }

        context 'with text input' do
          let(:text_input) { 'Text input for feedback question' }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: text_input } }) }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end

        context 'with no text input' do
          let(:text_input) { nil }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: text_input } }) }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end
      end
    end

    context 'with summative' do
      context 'when single choice (radio buttons)' do
        let(:question_name) { '1-3-2-1' }

        context 'with correct answer' do
          let(:answers) { [1] }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: 'Text input' } }, summative: true) }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end

        context 'with incorrect answer' do
          let(:answers) { [2] }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: 'Text input' } }, summative: true) }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end

        context 'and no answer' do
          let(:answers) { nil }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: 'Text input' } }, summative: true) }

          specify { expect(response).to have_http_status(:unprocessable_content) }
          specify { expect(records).to be 0 }
        end
      end

      context 'when multiple choice (check boxes)' do
        let(:question_name) { '1-3-2-2' }

        context 'with correct answers' do
          let(:answers) { [1, 3] }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: 'Text input' } }, summative: true) }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end

        context 'with incorrect answers' do
          let(:answers) { [1, 2] }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: 'Text input' } }, summative: true) }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end

        context 'and no answers' do
          let(:answers) { nil }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: 'Text input' } }, summative: true) }

          specify { expect(response).to have_http_status(:unprocessable_content) }
          specify { expect(records).to be 0 }
        end
      end

      context 'when the question expects text and is answered' do
        let(:question_name) { 'summative-textarea-only' }
        let(:answers) { [] }

        context 'with text input' do
          let(:text_input) { 'Text input for summative question' }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: text_input } }, summative: true) }

          specify { expect(response).to have_http_status(:redirect) }
          specify { expect(records).to be 1 }
        end

        context 'with no text input' do
          let(:text_input) { nil }

          before { patch_with_nonce({ training_module_id: 'alpha', id: question_name, response: { answers: answers, text_input: text_input } }, summative: true) }

          specify { expect(response).to have_http_status(:unprocessable_content) }
          specify { expect(records).to be 0 }
        end
      end
    end
  end
end
