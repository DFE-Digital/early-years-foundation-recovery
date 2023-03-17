require 'rails_helper'

RSpec.describe SummativeAssessmentProgress do
  subject(:assessment) { described_class.new(user: user, mod: alpha) }

  let(:questionnaire) { Questionnaire.find_by!(training_module: 'alpha') }
  let(:correct_answer_count) { 0 }

  before do
    correct_answer_count.times do
      user.user_answers.create!(
        assessments_type: 'summative_assessment',
        module: 'alpha',
        questionnaire_id: questionnaire.id,
        correct: true,
      )
    end
  end

  include_context 'with progress'

  # describe '#wrong_answers_feedback' do
  #   it 'does something' do
  #   end
  # end

  # describe '#attempted?' do
  #   it 'does something' do
  #   end
  # end

  # describe '#result' do
  #   it 'does something' do
  #   end
  # end

  # describe '#archive_attempt' do
  #   it 'does something' do
  #   end
  # end

  # describe '#status' do
  #   it 'does something' do
  #   end
  # end

  describe '#passed?' do
    context 'with all answers correct' do
      let(:correct_answer_count) { 4 }

      specify do
        expect(assessment).to be_passed
      end
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
