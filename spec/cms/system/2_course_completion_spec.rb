require 'rails_helper'
require 'content_schema'

RSpec.describe 'Course Completion (refactor)', :cms, type: :system do
  include_context 'with user'

  # let(:ast) { ContentSchema.new(mod: 'alpha').call }
  let(:ast) { ContentSchema.new.call }

  def make_note(field, input)
    fill_in field, with: input
  end

  context 'happy path' do
    it 'gets to end' do
      ast.each do |content|
        visit content[:path]

        expect(page).to have_current_path content[:path]
        expect(page).to have_content content[:text]

        content[:inputs].each do |args|
          send(args.shift, *args)
        end
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
      expect(UserAnswer.count).to be 10
      # expect(UserAnswer.count(&:correct)).to be 10 # 7 until confidence is fixed

      expect(Note.count).to be 1
      expect(Note.first.body).to eq 'hello world'
    end
  end
end
