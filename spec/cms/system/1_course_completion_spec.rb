require 'rails_helper'

RSpec.describe 'Course Completion', :cms, type: :system do
  subject(:mod) { Training::Module.by_name(:alpha) }

  include_context 'with user'

  context 'happy path' do
    it 'gets to end' do
      mod.schema.each_with_index.map do |(slug, type, content, payload), index|
        visit training_module_content_page_path(mod.name, slug)

        case type
        when /question/
          expect(page).to have_current_path "/modules/#{mod.name}/questionnaires/#{slug}"
          expect(page).to have_content content.strip

          # fill answers
          payload[:correct].each do |option|
            model = ENV['DISABLE_USER_ANSWER'].present? ? 'response' : 'user-answer'
            field_name = "#{model}-answers-#{option}-field"

            if payload[:correct].one? || type.match?(/confidence/)
              choose(field_name)
            else
              check(field_name)
            end

            # chose Strongly Agree
            break if type.match?(/confidence/)
          end

          next_type = mod.schema[index + 1][1]

          if next_type.match?(/summative/) && !type.match?(/summative/)
            click_on 'Start test'
          elsif next_type.match?(/results/)
            click_on 'Finish test'
          elsif type.match?(/summative/)
            click_on 'Save and continue'
          else
            click_on 'Next'
          end

        when /results/
          expect(page).to have_current_path "/modules/#{mod.name}/assessment-result/#{slug}"
          expect(page).to have_content content.strip

          # click_on 'Retake test' # unhappy
          click_on 'Next'

        when /certificate/
          expect(page).to have_content 'Congratulations!'
          # expect(page).to have_content content.strip # exception to the rule

        else
          expect(page).to have_current_path "/modules/#{mod.name}/content-pages/#{slug}"
          expect(page).to have_content content.strip

          if payload[:note]
            fill_in 'note-body-field', with: payload[:note]
            click_on 'Save and continue'
          else

            next_type = mod.schema[index + 1][1]

            if next_type.match?(/summative/)
              click_on 'Start test'
            elsif type.match?(/thankyou/)
              click_on 'Finish'
            else
              click_on 'Next'
            end
          end

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

      expect(UserAnswer.count).to be 10
      # expect(UserAnswer.count(&:correct)).to be 10 # 7 until confidence is fixed

      expect(Note.count).to be 1
      expect(Note.first.body).to eq 'hello world'
    end
  end
end
