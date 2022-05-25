# frozen_string_literal: true

module Pages
  class TermsAndConditions < Base
    set_url '/static/terms_and_conditions'

    element :heading, 'h1', text: 'Terms and conditions'
  end
end
