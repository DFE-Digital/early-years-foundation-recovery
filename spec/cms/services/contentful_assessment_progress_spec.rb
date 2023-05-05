require 'rails_helper'

RSpec.describe ContentfulAssessmentProgress do
  subject(:assessment) { described_class.new(user: user, mod: alpha) }

  include_context 'with progress'

  before do
    skip 'WIP' unless Rails.application.cms?

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

  context 'with all correct user responses' do
    let(:questions) do
      {
        '1-3-2-1' => [1, 3],
        '1-3-2-2' => [2, 3],
        '1-3-2-3' => [3, 4],
        '1-3-2-4' => [3],
      }
    end

    specify { expect(assessment).to be_passed }
    specify { expect(assessment).not_to be_failed }
  end

  context 'with incorrect answers below threshold' do
    let(:questions) do
      {
        '1-3-2-1' => [2, 3],  # incorrect
        '1-3-2-2' => [2, 4],  # incorrect
        '1-3-2-3' => [3, 4],  # correct
        '1-3-2-4' => [3],     # correct
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
        }
      end

      it 'calculates %' do
        expect(assessment.score).to be 75.0
      end
    end
  end
end
