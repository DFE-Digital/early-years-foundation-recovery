require 'rails_helper'

RSpec.describe ContentfulAssessmentProgress do
  subject(:assessment) { described_class.new(user: user, mod: alpha) }

  before do
    skip 'WIP' unless Rails.application.cms?
    answers.each do |answer|
      create :response, user: user,
                        training_module: 'alpha',
                        question_name: "1-3-2-#{answers.index(answer) + 1}",
                        answer: answer
    end
  end

  include_context 'with progress'

  context 'with all correct user responses' do
    let(:answers) { [[1, 3], [2, 3], [3, 4], 3] }

    it 'passes' do
      expect(assessment).to be_passed
    end

    it 'does not fail' do
      expect(assessment).not_to be_failed
    end
  end

  context 'with incorrect answers below threshold' do
    # questions 3 and 4 correct
    let(:answers) { [[2, 3], [2, 4], [3, 4], 3] }

    it 'does not pass' do
      expect(assessment).not_to be_passed
    end

    it 'fails' do
      expect(assessment).to be_failed
    end
  end

  describe '#score' do
    context 'with no answers' do
      let(:answers) { [] }

      it 'defaults to zero' do
        expect(assessment.score).to be 0.0
      end
    end

    context 'with some answers' do
      let(:answers) { [[1, 3], [2, 3], [3, 4], 2] }

      it 'calculates a percentage (3 out of 4)' do
        expect(assessment.score).to be 75.0
      end
    end
  end
end
