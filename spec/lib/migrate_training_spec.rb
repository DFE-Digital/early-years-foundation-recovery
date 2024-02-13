require 'rails_helper'
require 'migrate_training'

RSpec.describe MigrateTraining do
  subject(:operation) { described_class.new(verbose: false) }

  let(:user) { create(:user, :registered) }

  context 'with an error' do
    subject(:operation) { described_class.new(verbose: false, simulate: true) }

    before do
      create_list :response, 10
      operation.call
    rescue MigrateTraining::Error
    end

    it 'reverts changes' do
      expect(Response.count).to eq 10
    end
  end

  context 'with valid data' do
    before do

      create :user_answer,
             user_id: user.id,
             name: '1-1-4-1', # genuine key
             module: 'alpha',
             correct: false,
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
             assessments_type: 'summative_assessment',
             user_assessment_id: alpha_assessment.id,
             questionnaire_id: 0,
             created_at: Time.zone.local(2023, 1, 1)

      create :user_answer,
             user_id: user.id,
             name: '1-3-2-2', # genuine key
             module: 'alpha',
             correct: true,
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
             assessments_type: 'summative_assessment',
             user_assessment_id: nil,
             questionnaire_id: 0,
             created_at: Time.zone.local(2024, 2, 1)

      create :user_answer,
             user_id: user.id,
             name: '1-3-2-2', # genuine key
             module: 'bravo',
             correct: true,
             assessments_type: 'summative_assessment',
             user_assessment_id: nil,
             questionnaire_id: 0,
             created_at: Time.zone.local(2024, 2, 2)
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

    it 'preserves keys' do
      operation.call

      user_assessment = UserAssessment.find_by(module: 'alpha')
      assessment = Assessment.find_by(training_module: 'alpha')

      expect(assessment.id).to eq user_assessment.id

      user_answer = UserAnswer.find_by(name: '1-3-2-1')
      response = Response.find_by(question_name: '1-3-2-1')

      expect(response.id).to eq user_answer.id
    end
  end

  context 'with invalid score' do
    before do
      # Charlie (inconsistent)
      charlie_assessment =
        create :user_assessment,
               user_id: user.id,
               module: 'charlie',
               completed: true,
               status: 'passed',
               score: '150'

      20.times.each do |num|
        create :user_answer,
               user_id: user.id,
               name: '1-3-2-1', # genuine key
               module: 'charlie',
               user_assessment_id: charlie_assessment.id,
               questionnaire_id: 0,
               created_at: Time.zone.now
      end

      operation.call
    end

    it 'is corrected' do
      expect(UserAssessment.count).to eq 1
      expect(Assessment.count).to be 1

      expect(UserAnswer.count).to be 20
      expect(Response.count).to be 20

      expect(UserAssessment.first.user_answers.count).to eq 20
      expect(Assessment.first.responses.count).to eq 20

      expect(Assessment.first.score).to eq 100.0
    end
  end
end
