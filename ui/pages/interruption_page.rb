# frozen_string_literal: true

module Pages
  class InterruptionPage < Base
    set_url '/modules/child-development-and-the-eyfs/content-pages/before-you-start'

    element :next_button, '.govuk-button', text: 'Next'
    element :previous_button, 'button.govuk-button', text: 'Previous'
    element :next_button_1,'input[type="submit"]'
    element :finish_button, '.govuk-button', text: 'Finish'

  end
end