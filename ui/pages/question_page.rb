module Pages
  class QuestionPage < Base
    set_url "/modules{/module_name}/questionnaires{/question}"

    element :next_button, '.govuk-button', text: 'Next'
    element :finish_test, '.govuk-button', text: 'Finish test'
    elements :radio_buttons, '.govuk-radios__label'
    
    element :save_and_continue_button, 'button[type="submit"]', text: 'Save and continue'
    element :confidence_check_next, 'button[type="submit"]', text: 'Next'

    def answer_with(response:)
      sleep(2)
      choose(response)
      next_button.click
      sleep(2)
      self
    end

    def quiz_answer_with(response:)
      sleep(2)
      choose(response)
      save_and_continue_button.click
      sleep(2)
      self
    end

    def confidence_answer_with(response:)
      sleep(2)
      choose(response)
      confidence_check_next.click
      sleep(2)
      self
    end

    def finish_quiz_answer_with(response:)
      sleep(2)
      choose(response)
      finish_test.click
      sleep(2)
      ui.assessment_result
    end

    def finish_confidence_answer_with(response:)
      sleep(2)
      choose(response)
      confidence_check_next.click
      sleep(2)
      ui.content_page
    end

    def answers_with(response:)
      sleep(2)
      response.each{|answer| check(answer)}
      next_button.click
      sleep(2)
      self
    end

    def quiz_answers_with(response:)
      sleep(2)
      response.each{|answer| check(answer)}
      save_and_continue_button.click
      sleep(2)
      self
    end
    
    def next_page(notes: false, question: false)
      sleep(2)
      next_button.click
      sleep(2)
      if notes
        ui.content_page_with_notes
      elsif question
        ui.question_page
      else
        ui.content_page
      end
    end
  end
end