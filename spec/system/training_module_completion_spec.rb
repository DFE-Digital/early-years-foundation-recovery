require 'rails_helper'

RSpec.describe 'Training Module completion', type: :system do
  include_context 'with user'
  include_context 'with automated path'

  context 'when all answers are correct' do
    let(:fixture) { 'spec/support/ast/alpha-pass-response-skip-feedback.yml' }

    it 'records answers and milestones' do
      %w[
        module_start
        user_note_created
        summative_assessment_start
        summative_assessment_complete
        confidence_check_start
        confidence_check_complete
        module_complete
      ].each do |event_name|
        expect(Event.find_by(name: event_name)).to be_present
      end

      expect(Assessment.count).to be 1
      expect(Response.count(&:correct)).to be 17

      expect(Note.count).to be 1
      expect(Note.first.body).to eq 'hello world'
    end
  end

  context 'when the assessment threshold is not passed' do
    let(:fixture) { 'spec/support/ast/alpha-fail-response.yml' }

    it 'records answers and milestones' do
      %w[
        module_start
        user_note_created
        summative_assessment_start
        summative_assessment_complete
      ].each do |event_name|
        expect(Event.find_by(name: event_name)).to be_present
      end

      %w[
        confidence_check_start
        confidence_check_complete
        feedback_start
        feedback_complete
        module_complete
      ].each do |event_name|
        expect(Event.find_by(name: event_name)).not_to be_present
      end

      expect(Assessment.count).to be 1
      expect(Response.count(&:correct)).to be 0

      expect(Note.count).to be 1
      expect(Note.first.body).to eq 'hello world'
    end
  end
end
