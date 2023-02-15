module Pages
  class QuestionPage < Base
    set_url "/modules{/module_name}/questionnaires{/question}"

    element :next_button, '.govuk-button', text: 'Next'
    elements :radio_buttons, '.govuk-radios__label'
    
    def answer_with(answer:)
      choose(answer)
      next_button.click
      sleep(2)
      self
    end

    def answers_with(answers:)
      answers.each{|answer| choose(answer)}
      next_button.click
      sleep(2)
      self
    end
    
    def next_page(notes: false)
      next_button.click
      sleep(2)
      notes ? ui.content_page_with_notes : ui.content_page
    end
  end
end