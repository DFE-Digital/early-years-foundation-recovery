require 'rails_helper'
require 'migrate_training'

RSpec.describe MigrateTraining do

  let(:user) { create(:user, :registered) }

  before do
    # Alpha (finished)
    alpha_assessment = create :user_assessment, user_id: user.id, module: 'alpha'

    create :user_answer,
          user_id: user.id,
          name: 'alpha_1',
          module: 'alpha',
          user_assessment_id: alpha_assessment.id,
          questionnaire_id: 0,
          created_at: Time.zone.local(2023, 1, 1)

    create :user_answer,
          user_id: user.id,
          name: 'alpha_2',
          module: 'alpha',
          user_assessment_id: alpha_assessment.id,
          questionnaire_id: 0,
          created_at: Time.zone.local(2024, 1, 1)



    # Bravo (started therefore no association)
    create :user_answer,
          user_id: user.id,
          name: 'bravo_1',
          module: 'bravo',
          user_assessment_id: nil,
          questionnaire_id: 0,
          created_at: Time.zone.local(2024, 1, 1)

    create :user_answer,
          user_id: user.id,
          name: 'bravo_2',
          module: 'bravo',
          user_assessment_id: nil,
          questionnaire_id: 0,
          created_at: Time.zone.local(2024, 1, 1)

  end

  it 'migrates everything' do
    expect(Assessment.count).to be 0
    expect(Response.count).to be 0

    described_class.new.call

    # NB: needs to create assessments for module tests in progress
    expect(Assessment.count).to be 2
    expect(Response.count).to be 4

    Response.all.each do |response|
      expect(response.training_module).to eq response.assessment.training_module
    end

    assessment = Assessment.find_by(training_module: 'bravo')

    expect(assessment.score).to be_nil
    expect(assessment.passed).to be_nil
    expect(assessment.completed_at).to be_nil

    # NB: should be creation timestamp of first question
    expect(assessment.started_at).to_not be_nil
  end

  # assessment has:
  #   - more than 10 questions
  #   - a score greater than 100%
  #
  context 'when invalid data is found' do
  end

end
