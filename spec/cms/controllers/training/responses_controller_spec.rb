require 'rails_helper'

RSpec.describe Training::ResponsesController, type: :controller do
  before do
    skip 'CMS ONLY' unless Rails.application.cms?
    sign_in create(:user, :registered)

    if ENV['DISABLE_USER_ANSWER'].present?
      patch :update, params: {
        training_module_id: 'alpha',
        id: question_name,
        response: { answers: answers },
      }
    else
      patch :update, params: {
        training_module_id: 'alpha',
        id: question_name,
        user_answer: { answers: answers },
      }
    end
  end

  let(:records) do
    if ENV['DISABLE_USER_ANSWER'].present?
      Response.count
    else
      UserAnswer.count
    end
  end

  describe '#update' do
    context 'with formative' do
      context 'when single choice (radio buttons)' do
        let(:question_name) { '1-1-4' }

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

          specify { expect(response).to have_http_status(:unprocessable_entity) }
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

          specify { expect(response).to have_http_status(:unprocessable_entity) }
          specify { expect(records).to be 0 }
        end
      end
    end
  end
end
