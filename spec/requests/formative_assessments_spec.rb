require 'rails_helper'

RSpec.describe 'FormativeAssessments', type: :request do
  let(:module_item) { ModuleItem.find_by(type: :formative_assessment, training_module: :test) }
  let(:questionnaire_data) { module_item.model }
  let(:user) { create(:user, :registered) }

  before do
    sign_in user
  end

  describe 'GET /modules/:training_module_id/formative_assessments/:id' do
    subject(:show_view) { get training_module_formative_assessment_path(:test, questionnaire_data) }

    it 'returns http success' do
      show_view
      expect(response).to have_http_status(:success)
    end

    it 'does not display assessment summary' do
      show_view
      expect(response.body).not_to include(questionnaire_data.questions.dig(:favourite_colour, :assessment_summary))
    end

    context 'with existing correct answers' do
      before do
        user.user_answers.create(
          questionnaire_id: questionnaire_data.id,
          question: :favourite_colour,
          answer: questionnaire_data.questions.dig(:favourite_colour, :correct_answers),
        )
      end

      it 'displays the assessment summary' do
        show_view
        expect(response.body).to include(questionnaire_data.questions.dig(:favourite_colour, :assessment_summary))
      end
    end
  end

  describe 'PATCH /modules/:training_module_id/formative_assessments/:id' do
    subject(:submit_questionnaire) do
      patch training_module_formative_assessment_path(:test, questionnaire_data), params: { questionnaire: answers }
    end

    let(:answers) do
      { favourite_colour: questionnaire_data.questions.dig(:favourite_colour, :correct_answers).first }
    end

    it 'renders the current page' do
      submit_questionnaire
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'displays the assessment summary' do
      submit_questionnaire
      expect(response.body).to include(questionnaire_data.questions.dig(:favourite_colour, :assessment_summary))
    end

    it 'saves the answer' do
      expect { submit_questionnaire }.to change(UserAnswer, :count).by(1)
    end

    context 'when failure' do
      let(:answers) do
        { favourite_colour: :incorrect }
      end

      it 'displays the assessment fail summary' do
        submit_questionnaire
        expect(response.body).to include(questionnaire_data.questions.dig(:favourite_colour, :assessment_fail_summary))
      end
    end

    context 'when nothing has been selected' do
      let(:answers) do
        { favourite_colour: '' }
      end

      it 'displays a message asking the user to make an input' do
        submit_questionnaire
        expect(response.body).to include('Please select an answer')
      end

      it 'does not save the answer' do
        expect { submit_questionnaire }.not_to change(UserAnswer, :count)
      end
    end
  end
end
