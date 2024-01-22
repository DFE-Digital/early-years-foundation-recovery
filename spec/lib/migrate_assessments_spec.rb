require 'rails_helper'
require 'migrate_assessments'

RSpec.describe MigrateAssessments do
  describe 'migration' do
    let(:assessment) do
      create :user_assessment, user_id: create(:user).id, module: 'alpha'
    end

    before do
      create :user_answer, name: 'ans1', module: 'alpha', user_assessment_id: assessment.id, questionnaire_id: 0, created_at: Time.zone.local(2023, 1, 1)
      create :user_answer, name: 'ans2', module: 'alpha', user_assessment_id: assessment.id, questionnaire_id: 0, created_at: Time.zone.local(2024, 1, 1)
      described_class.new.call
    end

    it 'migrates all assessments' do
      expect(Assessment.count).to be 1
      expect(Assessment.first).to eq []
    end
  end

  describe 'transaction' do
    before do
      ENV['test'] = 'foo'
    end

    it 'migrates no assessments' do
      described_class.new.call
      expect(Assessment.count).to be 0
    end
  end

  describe 'truncation' do
    before do
      create :assessment, :passed
    end

    it 'empties before migration' do
      expect(Assessment.count).to be 1
      described_class.new.call
      expect(Assessment.count).to be 0
    end
  end
end
