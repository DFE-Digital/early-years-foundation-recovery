# frozen_string_literal: true

require_relative 'base'

module Pages
  class AssessmentResult < Base
    set_url '/modules{/module_name}/assessment-result{/page_name}'

    element :next_button, '.govuk-button', text: 'Next'

    def next_page(args = {})
      next_button.click
      sleep(2)
      ContentPage.new(args).tap do |page|
        wait { page.displayed? }
      end
    end
  end
end
