require 'rails_helper'

RSpec.describe 'Questionnaires', type: :request do
  let(:questionnaire) { Questionnaire.find_by(name: :test, training_module: :test) }
  let(:user) { create(:user, :registered) }

  before do
    sign_in user
  end

  describe 'GET /questionnaires/:id' do
    it 'returns http success' do
      get training_module_questionnaire_path(:test, questionnaire)
      expect(response).to have_http_status(:success)
    end

    it 'does not display an error' do
      get training_module_questionnaire_path(:test, questionnaire)
      expect(response.body).not_to include("class='errors'")
    end

    context 'with unknown name' do
      it 'raises error' do
        expect { get training_module_questionnaire_path(:test, :unknown) }.to raise_error(ActiveHash::RecordNotFound)
      end
    end
  end

  describe 'PATCH /questionaires/:id' do
    subject(:submit_questionnaire) do
      patch training_module_questionnaire_path(:test, questionnaire), params: { questionnaire: answers }
    end

    let(:answers) do
      questionnaire.questions.transform_values do |question|
        question[:multi_select] ? question[:correct_answers] : question[:correct_answers].first
      end
    end

    let(:module_item) { ModuleItem.find_by(training_module: questionnaire.training_module, name: questionnaire.name) }

    it 'does something without error' do
      submit_questionnaire
      expect(response).to redirect_to(training_module_content_page_path(module_item.training_module, module_item.next_item))
    end

    it 'creates a record of the answer' do
      expect { submit_questionnaire }.to change(UserAnswer, :count).by(questionnaire.questions.size)
    end

    it 'flags the stored answer as correct' do
      submit_questionnaire
      expect(UserAnswer.last).to be_correct
    end

    context 'with incorrect answers' do
      let(:answers) { questionnaire.questions.transform_values { |_a| :foo } }

      it 'renders page with errors' do
        submit_questionnaire
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('class="errors"')
      end

      it 'creates a record of the answer' do
        expect { submit_questionnaire }.to change(UserAnswer, :count).by(questionnaire.questions.size)
      end

      it 'flags the stored answer as not correct' do
        submit_questionnaire
        expect(UserAnswer.last).not_to be_correct
      end
    end

    context 'with an existing user answer' do
      let!(:user_answer) { create :user_answer, user: user, questionnaire: questionnaire }

      it 'archives the existing user answer' do
        submit_questionnaire
        expect(user_answer.reload).to be_archived
      end

      it 'does not archive the new user answers' do
        submit_questionnaire
        expect(UserAnswer.last).not_to be_archived
      end
    end
  end
end
