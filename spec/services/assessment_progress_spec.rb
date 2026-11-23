require 'rails_helper'

RSpec.describe AssessmentProgress do
  subject(:assessment) { described_class.new(user: user, mod: alpha) }

  include_context 'with progress'

  let(:attempt) do
    create :assessment, training_module: 'alpha', user: user
  end

  before do
    questions.each do |question_name, answers|
      create :response, user: user,
                        assessment: attempt,
                        training_module: 'alpha',
                        question_name: question_name,
                        question_type: 'summative',
                        answers: answers
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

  describe 'stray empty attempts' do
    let(:questions) do
      {
        '1-3-2-1' => [1, 3],
        '1-3-2-2' => [2, 3],
        '1-3-2-3' => [3, 4],
        '1-3-2-4' => [3],
        '1-3-2-5' => [3],
        '1-3-2-6' => [3],
        '1-3-2-7' => [3],
        '1-3-2-8' => [3],
        '1-3-2-9' => [3],
        '1-3-2-10' => [3],
      }
    end

    context 'when created moments after the answered attempt' do
      before do
        create :assessment, user: user, started_at: attempt.started_at + 0.005
      end

      it 'grades the answered attempt' do
        assessment.grade!
        expect(attempt.reload.score).to eq 100.0
      end
    end

    context 'when created moments before the answered attempt' do
      before do
        create :assessment, user: user, started_at: attempt.started_at - 0.005
      end

      it 'grades the answered attempt' do
        assessment.grade!
        expect(attempt.reload.score).to eq 100.0
      end
    end

    context 'when the empty attempt was already graded at 0%' do
      before do
        create :assessment, :failed, user: user, started_at: attempt.started_at + 0.005, completed_at: Time.zone.now
      end

      it 'grades the answered attempt' do
        assessment.grade!
        expect(attempt.reload).to have_attributes(score: 100.0, passed: true)
      end
    end

    context 'when left over after a failed attempt' do
      before do
        create :assessment, user: user, started_at: attempt.started_at - 0.005
        attempt.update!(score: 40.0, passed: false, completed_at: Time.zone.now)
      end

      it 'is ignored in favour of the failed result' do
        expect(described_class.new(user: user, mod: alpha)).to have_attributes(assessment: attempt, graded?: true, failed?: true)
      end
    end
  end

  describe '#complete?' do
    let(:questions) { { '1-3-2-1' => [1, 3] } }

    it 'is false until every summative question is answered' do
      expect(assessment).not_to be_complete
    end
  end
end
