require 'rails_helper'

RSpec.describe 'Questionnaires', type: :request do
  let(:questionnaire) { Questionnaire.find_by(name: :test, training_module: :test) }

  before do
    sign_in create(:user, :registered)
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
    let(:correct_answers) do
      questionnaire.questions.transform_values do |question|
        question[:multi_select] ? question[:correct_answers] : question[:correct_answers].first
      end
    end

    let(:incorrect_answers) do
      questionnaire.questions.transform_values { |_a| :foo }
    end

    let(:module_item) { ModuleItem.find_by(training_module: questionnaire.training_module, name: questionnaire.name) }

    it 'does something without error' do
      patch training_module_questionnaire_path(:test, questionnaire), params: { questionnaire: correct_answers }
      expect(response).to redirect_to(training_module_content_page_path(module_item.training_module, module_item.next_item))
    end

    context 'with incorrect answers' do
      it 'renders page with errors' do
        patch training_module_questionnaire_path(:test, questionnaire), params: { questionnaire: incorrect_answers }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('class="errors"')
      end
    end
  end
end
