require 'rails_helper'
require 'content_test_schema'

RSpec.describe 'Training Module Completion', type: :system do
  subject(:mod) { alpha }

  include_context 'with user'
  include_context 'with progress'

  let(:schema) { ContentTestSchema.new(mod: mod) }

  def make_note(field, input)
    fill_in field, with: input
  end

  before do
    skip 'WIP' if ENV['DISABLE_USER_ANSWER'].present?

    visit "/modules/#{mod.name}"
    click_on 'Start module'
  end

  context 'when all answers are correct' do
    let(:ast) { schema.call }

    it 'completes the module' do
      ast.each do |content|
        expect(page).to have_current_path content[:path]
        expect(page).to have_content content[:text]
        content[:inputs].each { |args| send(*args) }
      end

      %w[
        learning_page
        module_start
        user_note_created
        summative_assessment_start
        summative_assessment_complete
        confidence_check_start
        confidence_check_complete
        module_complete
      ].each do |event_name|
        expect(Ahoy::Event.find_by(name: event_name)).to be_present
      end

      expect(UserAssessment.count).to be 1
      expect(UserAnswer.count(&:correct)).to be 10

      expect(Note.count).to be 1
      expect(Note.first.body).to eq 'hello world'
    end
  end

  context 'when the assessment threshold is not passed' do
    let(:ast) { schema.call(pass: false) }

    it 'does not complete the module' do
      ast.each do |content|
        next if content.nil?

        expect(page).to have_current_path content[:path]
        expect(page).to have_content content[:text]
        content[:inputs].each { |args| send(*args) }
      end

      %w[
        learning_page
        module_start
        user_note_created
        summative_assessment_start
        summative_assessment_complete
      ].each do |event_name|
        expect(Ahoy::Event.find_by(name: event_name)).to be_present
      end

      %w[
        confidence_check_start
        confidence_check_complete
        module_complete
      ].each do |event_name|
        expect(Ahoy::Event.find_by(name: event_name)).not_to be_present
      end

      expect(UserAssessment.count).to be 1
      expect(UserAnswer.count(&:correct)).to be 0

      expect(Note.count).to be 1
      expect(Note.first.body).to eq 'hello world'
    end
  end
end
