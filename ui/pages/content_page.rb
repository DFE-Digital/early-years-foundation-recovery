module Pages
  class ContentPage < Base
    set_url "/modules{/module_name}/content-pages{/page_name}"

    attr_reader :module_name, :page_name

    element :next_button, '.govuk-button', text: 'Next'
    element :start_test, '.govuk-button', text: 'Start test'
    element :finish_button, '.govuk-button', text: 'Finish'

    def initialize(*attrs)
      @module_name = attrs[0]&.fetch(:module_name, nil)
      @page_name = attrs[0]&.fetch(:page_name, nil)
    end

    def starting_test
      start_test.click 
      ui.question_page
    end

    def next_page(notes: false, question: false)
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

    def finish_module
      finish_button.click
      sleep(2)
      ui.content_page
    end
  end
end