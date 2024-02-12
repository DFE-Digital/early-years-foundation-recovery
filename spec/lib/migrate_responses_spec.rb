require 'rails_helper'
require 'migrate_responses'

RSpec.describe MigrateResponses do
  context 'without answers' do
    let(:assessment) do
      create :user_assessment, user_id: create(:user).id, module: 'alpha'
    end

    before do
      create :user_answer, name: 'ans1', module: 'alpha', user_assessment_id: assessment.id,
              questionnaire_id: 0, created_at: Time.zone.local(2023, 1, 1)
      create :user_answer, name: 'ans2', module: 'alpha', user_assessment_id: assessment.id,
              questionnaire_id: 0, created_at: Time.zone.local(2024, 1, 1)

      create :assessment, id: assessment.id
      described_class.new.call
    end

    it 'migrates all responses' do
      expect(Response.count).to be 2
      expect(Response.first.question_name).to eq 'ans1'
      expect(Response.first.assessment.id).to eq assessment.id
    end
  end

  context 'when new table is not clean' do
    before do
      create :response
    end

    it 'empties before migration' do
      expect(Response.count).to be 1
      described_class.new.call
      expect(Response.count).to be 0
    end
  end
end
