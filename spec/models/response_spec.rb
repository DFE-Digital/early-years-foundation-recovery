require 'rails_helper'

RSpec.describe Response, type: :model do

    describe 'dashboard' do
        before do
            create(:response, answers: [1])
        end

        let(:headers) do
            ["user_id", "training_moduless", "question_name", "answers", "archived", "correct", "user_assessment_id", "created_at", "updated_at"]
        end
        let(:rows) do
            [1, 'alpha', '1-1-4', [1]]
        end

        
        
        it_behaves_like("a data export model")
    end
end