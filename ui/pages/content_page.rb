module Pages
  class ContentPage < Base
    set_url '/modules{/module_name}/content-pages{/page_name}'

    element :next_action, id: 'next_action'
    element :next_button, '.govuk-button', text: 'Next'
    element :start_test, '.govuk-button', text: 'Start test'
    element :finish_button, '.govuk-button', text: 'Finish'
    element :save_and_continue_button, 'input[type="submit"]'

    def starting_test(args = {})
      wait_until_start_test_visible
      start_test.click
      sleep(2)

      QuestionPage.new(args).tap do |page|
        wait { page.displayed? }
      end
    end

    def next_page(args = {})
      wait_until_next_action_visible
      next_action.click
      sleep(2)
      next_page_object(args).tap do |page|
        wait { page.displayed? }
      end
    end

    def finish_module(args = {})
      wait_until_finish_button_visible
      finish_button.click
      sleep(2)
      ContentPage.new(args).tap do |page|
        wait { page.displayed? }
      end
    end
  end
end
