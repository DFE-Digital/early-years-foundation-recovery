require 'rails_helper'

RSpec.describe SummativeAssessmentProgress do
  subject(:assessment) { described_class.new(user: user, mod: alpha) }

  let(:questionnaire) { Questionnaire.find_by!(training_module: 'alpha') }
  let(:correct_answer_count) { 0 }

  before do
    skip 'WIP' if Rails.application.cms?

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
      let(:correct_answer_count) { 10 }

      specify { expect(assessment).to be_passed }
    end

    context 'with insufficient answers correct' do
      let(:correct_answer_count) { 6 }

      specify { expect(assessment).not_to be_passed }
    end
  end

  describe '#failed?' do
    context 'with all answers correct' do
      let(:correct_answer_count) { 10 }

      specify { expect(assessment).not_to be_failed }
    end

    context 'with insufficient answers correct' do
      let(:correct_answer_count) { 6 }

      specify { expect(assessment).to be_failed }
    end
  end

  describe '#score' do
    context 'with no answers correct' do
      specify { expect(assessment.score).to be 0.0 }
    end

    context 'with 3/10 answers correct' do
      let(:correct_answer_count) { 3 }

      specify { expect(assessment.score).to be 30.0 }
    end
  end
end
