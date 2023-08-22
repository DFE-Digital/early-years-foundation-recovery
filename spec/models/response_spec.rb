require 'rails_helper'

RSpec.describe Response, type: :model do
  describe 'dashboard' do
    let(:response) { create(:response, answers: [1]) }

    let(:headers) do
      %w[
        id
        user_id
        training_module
        question_name
        answers
        archived
        correct
        user_assessment_id
        created_at
        updated_at
      ]
    end

    let(:rows) do
      [response]
    end

    it_behaves_like 'a data export model'
  end
end
