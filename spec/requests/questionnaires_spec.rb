require 'rails_helper'

RSpec.describe "Questionnaires", type: :request do
  let(:questionnaire) { Questionnaire.find_by(name: :simple) }

  describe "GET /questionnaires/:id" do
    it "returns http success" do
      get questionnaire_path(questionnaire)
      expect(response).to have_http_status(:success)
    end

    it "does not display an error" do
      get questionnaire_path(questionnaire)
      expect(response.body).not_to include("class='errors'")
    end

    context "with unknown name" do
      it "raises error" do
        expect { get questionnaire_path(:unknown) }.to raise_error(ActiveHash::RecordNotFound)
      end
    end
  end

  describe "PATCH /questionaires/:id" do
    let(:correct_answers) do
      questionnaire.questions.transform_values do |question|
        question[:multi_select] ? question[:correct_answers] : question[:correct_answers].first
      end
    end

    let(:incorrect_answers) do
      questionnaire.questions.transform_values { |_a| :foo }
    end
    
    # This behaviour should change to redirecting to next page
    it "does something without error" do
      patch questionnaire_path(questionnaire), params: { questionnaire: correct_answers }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).not_to include("class='errors'")
    end

    context "with incorrect answers" do
      it "renders page with errors" do
        patch questionnaire_path(questionnaire), params: { questionnaire: incorrect_answers }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("class='errors'")
      end
    end
  end
end
