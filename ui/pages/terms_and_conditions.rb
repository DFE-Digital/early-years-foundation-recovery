# frozen_string_literal: true

module Pages
  class TermsAndConditions < Base
    set_url '/terms-and-conditions'

    element :heading, 'h1', text: 'Terms and conditions'
    element :back_link, '.govuk-back-link', text:"Back"
  end
end
