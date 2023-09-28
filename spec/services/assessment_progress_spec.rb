require 'rails_helper'

RSpec.describe AssessmentProgress do
  subject(:assessment) { described_class.new(user: user, mod: alpha) }

  include_context 'with progress'

  before do
    questions.each do |question_name, answers|
      if ENV['DISABLE_USER_ANSWER'].present?
        create :response, user: user,
                          training_module: 'alpha',
                          question_name: question_name,
                          answers: answers
      else
        create :user_answer, user: user,
                             module: 'alpha',
                             name: question_name,
                             answer: answers,
                             questionnaire_id: 0 # N/A
      end
    end
  end

  context 'with only correct responses' do
    let(:questions) do
      {
        '1-3-2-1' => [1, 3],  # correct
        '1-3-2-2' => [2, 3],  # correct
        '1-3-2-3' => [3, 4],  # correct
        '1-3-2-4' => [3],     # correct
        '1-3-2-5' => [3],     # correct
        '1-3-2-6' => [3],     # correct
        '1-3-2-7' => [3],     # correct
        '1-3-2-8' => [3],     # correct
        '1-3-2-9' => [3],     # correct
        '1-3-2-10' => [3],    # correct
      }
    end

    specify { expect(assessment).to be_passed }
    specify { expect(assessment).not_to be_failed }
  end

  context 'with insufficient correct responses' do
    let(:questions) do
      {
        '1-3-2-1' => [2, 3],  # incorrect
        '1-3-2-2' => [2, 4],  # incorrect
        '1-3-2-3' => [3, 4],  # correct
        '1-3-2-4' => [3],     # correct
        '1-3-2-5' => [3],     # correct
        '1-3-2-6' => [3],     # correct
        '1-3-2-7' => [3],     # correct
        '1-3-2-8' => [3],     # correct
        '1-3-2-9' => [5],     # incorrect
        '1-3-2-10' => [5],    # incorrect
      }
    end

    specify { expect(assessment).to be_failed }
    specify { expect(assessment).not_to be_passed }
  end

  describe '#score' do
    context 'with no answers' do
      let(:questions) { {} }

      it 'defaults to zero' do
        expect(assessment.score).to be 0.0
      end
    end

    context 'with some correct answers' do
      let(:questions) do
        {
          '1-3-2-1' => [1, 3],  # correct
          '1-3-2-2' => [2, 3],  # correct
          '1-3-2-3' => [3, 4],  # correct
          '1-3-2-4' => [4],     # incorrect
          '1-3-2-5' => [5],     # correct
          '1-3-2-6' => [3],     # correct
          '1-3-2-7' => [3],     # correct
          '1-3-2-8' => [3],     # correct
          '1-3-2-9' => [3],     # correct
          '1-3-2-10' => [3],    # correct
        }
      end

      it 'calculates %' do
        expect(assessment.score).to be 80.0
      end
    end
  end
end
