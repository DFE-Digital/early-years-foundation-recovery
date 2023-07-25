require 'rails_helper'

RSpec.describe SummativeAssessmentProgress do
  subject(:assessment) { described_class.new(user: user, mod: alpha) }

  let(:questionnaire) { Questionnaire.find_by!(training_module: 'alpha') }
  let(:correct_answer_count) { 0 }

  before do
    skip 'DEPRECATED' if Rails.application.cms?

    correct_answer_count.times do
      user.user_answers.create!(
        assessments_type: 'summative_assessment',
        module: 'alpha',
        questionnaire_id: questionnaire.id,
        answer: [1_000],  # CMS migration introduces a presence validation
        correct: true,    # <- is all that is required for this spec
      )
    end
  end

  include_context 'with progress'

  describe '#passed?' do
    context 'with all answers correct' do
      let(:correct_answer_count) { 4 }

      specify { expect(assessment).to be_passed }
    end

    context 'with insufficient answers correct' do
      let(:correct_answer_count) { 2 }

      specify { expect(assessment).not_to be_passed }
    end
  end

  describe '#failed?' do
    context 'with all answers correct' do
      let(:correct_answer_count) { 4 }

      specify { expect(assessment).not_to be_failed }
    end

    context 'with insufficient answers correct' do
      let(:correct_answer_count) { 2 }

      specify { expect(assessment).to be_failed }
    end
  end

  describe '#score' do
    context 'with no answers' do
      it 'defaults to zero' do
        expect(assessment.score).to be 0.0
      end
    end

    context 'with some answers' do
      let(:correct_answer_count) { 3 }

      it 'calculates a percentage (3 out of 4)' do
        expect(assessment.score).to be 75.0
      end
    end
  end
end
