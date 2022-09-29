# frozen_string_literal: true

module Pages
  class FooterAccessibilityStatement < Base
    set_url '/accessibility-statement'

    element :heading, 'h1', text: 'Accessibility statement for Child development training'
  end
end
