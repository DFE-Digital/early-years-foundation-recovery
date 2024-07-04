require 'rails_helper'
require 'migrate_training'

# UserAnswer names like '1-3-2-1' must be genuine and exist in the CMS env
#
RSpec.xdescribe MigrateTraining do
  subject(:operation) { described_class.new(verbose: false) }

  let(:user) { create(:user, :registered) }

  context 'with truncate' do
    subject(:operation) { described_class.new(verbose: false, truncate: true) }

    let(:assessment) { create :assessment, user: user }

    before do
      create_list :response, 10, user: user, question_type: 'summative', assessment: assessment
      operation.call
    end

    it 'preserves user records' do
      expect(Assessment.count).to eq 0
      expect(Response.count).to eq 0
      expect(User.count).to eq 1
    end

    it 'resets primary keys' do
      create :assessment, user: user
      create :response, user: user
      expect(Assessment.last.id).to eq 1
      expect(Response.last.id).to eq 1
    end
  end

  context 'when data is invalid' do
    before do
      create :user_answer, user_id: user.id, name: 'foo', questionnaire_id: 0
    end

    it 'is ignored' do
      expect { described_class.new.call }.to output(/Invalid UserAnswer/).to_stdout
      expect(Response.count).to eq 0
    end
  end

  context 'when data is valid' do
    before do
      create :user_answer,
             user_id: user.id,
             name: '1-1-4-1', # genuine key
             module: 'alpha',
             correct: false,
             answer: %w[1 2 3],
             assessments_type: 'formative_assessment',
             user_assessment_id: nil,
             questionnaire_id: 0,
             created_at: Time.zone.local(2023, 1, 1)

      # Alpha (finished)
      alpha_assessment =
        create :user_assessment,
               user_id: user.id,
               module: 'alpha',
               completed: true,
               status: 'passed',
               score: '70',
               created_at: Time.zone.local(2023, 1, 2) # matches last question (approx)

      create :user_answer,
             user_id: user.id,
             name: '1-3-2-1', # genuine key
             module: 'alpha',
             correct: true,
             answer: %w[1 2 3],
             assessments_type: 'summative_assessment',
             user_assessment_id: alpha_assessment.id,
             questionnaire_id: 0,
             created_at: Time.zone.local(2023, 1, 1)

      create :user_answer,
             user_id: user.id,
             name: '1-3-2-2', # genuine key
             module: 'alpha',
             correct: true,
             answer: %i[1 2 3],
             assessments_type: 'summative_assessment',
             user_assessment_id: alpha_assessment.id,
             questionnaire_id: 0,
             created_at: Time.zone.local(2023, 1, 2)

      # Bravo (started therefore no association)
      create :user_answer,
             user_id: user.id,
             name: '1-3-2-1', # genuine key
             module: 'bravo',
             correct: true,
             answer: [1, 2, 3],
             assessments_type: 'summative_assessment',
             user_assessment_id: nil,
             questionnaire_id: 0,
             created_at: Time.zone.local(2024, 2, 1)

      create :user_answer,
             user_id: user.id,
             name: '1-3-2-2', # genuine key
             module: 'bravo',
             correct: true,
             answer: ['', '1', :'2', 3],
             assessments_type: 'summative_assessment',
             user_assessment_id: nil,
             questionnaire_id: 0,
             created_at: Time.zone.local(2024, 2, 2)
    end

    it 'coerces errant answers to numbers' do
      operation.call
      expect(Response.all.map(&:answers)).to eq(Array.new(5) { [1, 2, 3] })
    end

    it 'migrates everything' do
      expect(Assessment.count).to be 0
      expect(Response.count).to be 0

      operation.call

      expect(Assessment.count).to be 2
      expect(Response.formative.count).to be 1
      expect(Response.summative.count).to be 4

      # ALPHA
      alpha_assessment = Assessment.find_by(training_module: 'alpha')

      expect(alpha_assessment.training_module).to eq 'alpha'
      expect(alpha_assessment.score).to eq 70.0
      expect(alpha_assessment.passed).to eq true

      # first question
      expect(alpha_assessment.started_at.year).to eq 2023
      expect(alpha_assessment.started_at.month).to eq 1
      expect(alpha_assessment.started_at.day).to eq 1

      # last question
      expect(alpha_assessment.completed_at.year).to eq 2023
      expect(alpha_assessment.completed_at.month).to eq 1
      expect(alpha_assessment.completed_at.day).to eq 2

      # BRAVO
      bravo_assessment = Assessment.find_by(training_module: 'bravo')

      expect(bravo_assessment.training_module).to eq 'bravo'
      expect(bravo_assessment.score).to be_nil
      expect(bravo_assessment.passed).to be_nil

      # first question
      expect(bravo_assessment.started_at.year).to eq 2024
      expect(bravo_assessment.started_at.month).to eq 2
      expect(bravo_assessment.started_at.day).to eq 1

      # last question
      expect(bravo_assessment.completed_at).to be_nil
    end
  end

  context 'when assessment score exceeds 100' do
    before do
      charlie_assessment =
        create :user_assessment,
               user_id: user.id,
               module: 'charlie',
               completed: true,
               status: 'passed',
               score: '150'

      create_list :user_answer, 20,
                  user_id: user.id,
                  name: '1-3-2-1', # genuine key
                  module: 'charlie',
                  assessments_type: 'summative_assessment',
                  user_assessment_id: charlie_assessment.id,
                  questionnaire_id: 0,
                  created_at: Time.zone.now

      operation.call
    end

    it 'is corrected' do
      expect(Assessment.count).to be 1
      expect(Assessment.first.score).to eq 100.0
    end
  end

  context 'when resuming' do
    before do
      assessment_1 =
        create :user_assessment,
               user_id: user.id,
               module: 'alpha'

      create_list :user_answer, 10,
                  user_id: user.id,
                  name: '1-3-2-1',
                  module: 'alpha',
                  assessments_type: 'summative_assessment',
                  user_assessment_id: assessment_1.id,
                  questionnaire_id: 0,
                  created_at: Time.zone.local(2023, 1, 1)

      operation.call
    end

    it 'migrates remaining data' do
      # in progress
      create_list :user_answer, 3,
                  user_id: user.id,
                  name: '1-3-2-1',
                  module: 'bravo',
                  assessments_type: 'summative_assessment',
                  user_assessment_id: nil,
                  questionnaire_id: 0,
                  created_at: Time.zone.now

      # completed
      assessment_2 =
        create :user_assessment,
               user_id: user.id,
               module: 'charlie'

      create_list :user_answer, 10,
                  user_id: user.id,
                  name: '1-3-2-1',
                  module: 'charlie',
                  assessments_type: 'summative_assessment',
                  user_assessment_id: assessment_2.id,
                  questionnaire_id: 0,
                  created_at: Time.zone.now

      described_class.new(verbose: false).call

      expect(UserAssessment.count).to eq 2
      expect(Assessment.count).to be 3

      expect(UserAnswer.count).to be 23
      expect(Response.count).to be 23

      expect(Assessment.all.map(&:training_module)).to eq %w[alpha bravo charlie]
      expect(Assessment.all.map(&:score)).to eq [0.0, nil, 0.0]
    end
  end
end
