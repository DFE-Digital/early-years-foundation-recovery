# frozen_string_literal: true

module Pages
  class CheckYourEmail < Base
    set_url '/my-account/check-email-confirmation'

    element :heading, 'h1', text: 'Check your email'
    element :back_link, '.govuk-back-link', text: 'Back'
  end
end
